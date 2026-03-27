//
// CGContext+nanovg-gl.m
// MulleCGNanovgGL
//
// OpenGL-specific categories extracted from MulleCGNanovg's CGContext+nanovg.m
//


//
// so to actually compile nanovg on Apple we needs to tweak stuff
//
#define MULLE_CG_USE_APPLE_GL2


#import "import-private.h"

#import <MulleCG/CGContext+DebugPrivate.h>
#include <ctype.h>


MULLE_CG_NANOVG_GLOBAL
CGFunctionTable   CGNanoVGFunctionTable;

MULLE_CG_GLOBAL
mulle_thread_mutex_t   CGLayoutContextFreeTypeLock;


@implementation CGLayoutContext ( OpenGL)



#if defined( _WIN32) || defined( __MINGW32__)
extern int   mulle_glad_load_gl( void);
#endif

- (void) _initNanovg
{
   mulle_thread_mutex_do( CGLayoutContextFreeTypeLock)
   {
#if defined( _WIN32) || defined( __MINGW32__)
      if( ! (_backendFlags & (NVG_NO_DRAWING|NVG_FONT_ONLY)))
      {
         if( ! mulle_glad_load_gl())
         {
            fprintf( stderr, "gladLoadGL failed\n");
            abort();
         }
      }
#endif
#ifdef NANOVG_GL3_IMPLEMENTATION
      _cgBackend.context  = nvgCreateGL3( _backendFlags);
#else
# ifdef NANOVG_GLES2_IMPLEMENTATION
      _cgBackend.context  = nvgCreateGLES2( _backendFlags);
# else
#  ifdef NANOVG_GLES3_IMPLEMENTATION
      _cgBackend.context  = nvgCreateGLES3( _backendFlags);
#  else
#   ifdef NANOVG_D3D11_IMPLEMENTATION
      assert( _backendDevicePointer);
      _cgBackend.context  = nvgCreateD3D11( _backendDevicePointer, (_backendFlags & NVG_ANTIALIAS) ? 1 : 0);
#   else
#    error "Any of NANOVG_GL3/GLES2/GLES3/D3D11_IMPLEMENTATION must be defined"
#   endif
#  endif
# endif
#endif
   }
   assert( _cgBackend.context);
   _cgBackend.functions = CGNanoVGFunctionTable, _cgBackend.backendFunctions = CGNanoVGBackendFunctionTable;
}


- (void) _doneNanovg
{
   if( ! _cgBackend.context)
      return;

   mulle_thread_mutex_do( CGLayoutContextFreeTypeLock)
   {
#ifdef NANOVG_GL3_IMPLEMENTATION
      nvgDeleteGL3( _cgBackend.context);
      _cgBackend.context = NULL;
#else
# ifdef NANOVG_GLES2_IMPLEMENTATION
      nvgDeleteGLES2(_cgBackend.context);
      _cgBackend.context = NULL;
# else
#  ifdef NANOVG_GLES3_IMPLEMENTATION
      nvgDeleteGLES3(_cgBackend.context);
      _cgBackend.context = NULL;
#  else
#   ifdef NANOVG_D3D11_IMPLEMENTATION
      nvgDeleteD3D11( _cgBackend.context);
      _cgBackend.context = NULL;
#   endif
#  endif
# endif
#endif
   }
}

@end


@implementation CGContext( Errors)

static char   *_CGNVGBackendErrorShortUTF8String( void *error)
{
   switch( (intptr_t) error)
   {
   case GL_INVALID_ENUM      : return( "GL_INVALID_ENUM");
   case GL_INVALID_VALUE     : return( "GL_INVALID_VALUE");
   case GL_INVALID_OPERATION : return( "GL_INVALID_OPERATION");
   case GL_NO_ERROR          : return( "GL_NO_ERROR");
#if ! defined( NANOVG_GLES2_IMPLEMENTATION) && ! defined( NANOVG_GLES3_IMPLEMENTATION)  && ! defined( __APPLE__)
   case GL_STACK_OVERFLOW    : return( "GL_STACK_OVERFLOW");
   case GL_STACK_UNDERFLOW   : return( "GL_STACK_UNDERFLOW");
#endif
   case GL_OUT_OF_MEMORY     : return( "GL_OUT_OF_MEMORY");
   case GL_INVALID_FRAMEBUFFER_OPERATION : return( "GL_INVALID_FRAMEBUFFER_OPERATION");
   default                   : abort();
   }
}

static char   *_CGNVGBackendErrorUTF8String( void *error)
{
   switch( (intptr_t) error)
   {
   case GL_INVALID_ENUM      : return( "An unacceptable value was specified for an enumerated argument");
   case GL_INVALID_VALUE     : return( "A numeric argument was out of range");
   case GL_INVALID_OPERATION : return( "The specified operation is not allowed in the current state");
   case GL_NO_ERROR          : return( NULL);
#if ! defined( NANOVG_GLES2_IMPLEMENTATION) && ! defined( NANOVG_GLES3_IMPLEMENTATION) && ! defined( __APPLE__)
   case GL_STACK_OVERFLOW    : return( "This function caused a stack overflow");
   case GL_STACK_UNDERFLOW   : return( "This function caused a stack underflow");
#endif
   case GL_OUT_OF_MEMORY     : return( "There is not enough memory left to execute the function");
   case GL_INVALID_FRAMEBUFFER_OPERATION : return( "Wrong or no framebuffer selected");
   default                   : abort();
   }
}


- (void) _checkBackendError:(char *) str
{
   GLenum       err;
   static int   counter;
   char         *s;

   if( _backend == UIGraphicsBackendNone)
      return;

   err = glGetError();
   if( err != GL_NO_ERROR)
   {
      if( counter < 50)  // gets tedious fast
      {
         s = [self backendUTF8String];
         if( ! s)
            s = [CGContext nanoVGBackendUTF8String];

         mulle_fprintf( stderr, "%s error %@ %s( 0x%x) \"%s\": %s\n",
                                 s,
                                 self,
                                 _CGNVGBackendErrorShortUTF8String( (void *) (intptr_t) err),
                                 err,
                                 _CGNVGBackendErrorUTF8String( (void *) (intptr_t) err),
                                 str ? str : "???");
         ++counter;
      }
      assert( err == GL_NO_ERROR);
      return;
   }
}


- (BOOL) resetBackendError
{
   GLenum       err;
   BOOL         flag;

   for( flag = NO;; flag = YES)
   {
      err = glGetError();
      if( err == GL_NO_ERROR)
         return( flag);
   }
}


- (void) assertNoBackendError:(char *) str
{
   [self _checkBackendError:str];
}

@end


@implementation CGContextBase( nanovgGL)

+ (CGContext *) createPathContext
{
   return( [[[CGContext alloc] initWithOSGraphicsContext:nil
                                                shareID:0
                                                options:UIGraphicsNoDrawing] autorelease]);
}

@end


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

@implementation CGContext ( nanovgGL)


+ (BOOL) supportsAntiAliasing
{
#ifdef NANOVG_HAVE_MSAA
   return( YES);
#endif
   return( NO);
}


+ (char *) nanoVGBackendUTF8String
{
#ifdef NANOVG_GL3_IMPLEMENTATION
   return( "OpenGL v3.2+");
#endif
#ifdef NANOVG_GLES2_IMPLEMENTATION
   return( "GLES v2.0+");
#endif
#ifdef NANOVG_GLES3_IMPLEMENTATION
   return( "GLES v3.2+");
#endif
#ifdef NANOVG_D3D11_IMPLEMENTATION
   return( "Direct3D 11");
#endif
   abort();
}


+ (CGContextNanoVGBackend) nanoVGBackend
{
#ifdef NANOVG_GL3_IMPLEMENTATION
   return( CG_GL3_2);
#endif
#ifdef NANOVG_GLES2_IMPLEMENTATION
   return( CG_GLES2);
#endif
#ifdef NANOVG_GLES3_IMPLEMENTATION
   return( CG_GLES3_2);
#endif
#ifdef NANOVG_D3D11_IMPLEMENTATION
   return( CG_D3D11);
#endif
   abort();
}


- (char *) nanovgInfoUTF8String
{
   char   *s;

   s = MulleObjC_asprintf( "%s%s%s%s%s",
                           [[self class] nanoVGBackendUTF8String],
                           _backendFlags & NVG_ANTIALIAS ? " EdgeAA" : "",
                           _backendFlags & NVG_CLEARTYPE ? " ClearType" : "",
                           _backendFlags & NVG_STENCIL_STROKES ? " Stencil" : "",
                           _backendFlags & NVG_MSAA ? " MSAA" : "");
   return( s);
}


#if defined(__GNUC__) || defined(__clang__)
# pragma GCC diagnostic push
# pragma GCC diagnostic ignored "-Wenum-compare"
#endif

- (void) _initNanoVGWithGraphicsOptions:(UIGraphicsOptions) options
{
   NSUInteger   flags;

   MULLE_C_ASSERT( UIGraphicsSourceOver == NVG_SOURCE_OVER);
   MULLE_C_ASSERT( UIGraphicsXor        == NVG_XOR);
   MULLE_C_ASSERT( UIGraphicsCopy       == NVG_COPY);

   // Context Type assertions
   MULLE_C_ASSERT( CGContextTypeFull == NVG_FULL_CONTEXT);
   MULLE_C_ASSERT( CGContextTypePath == NVG_PATH_CONTEXT);
   MULLE_C_ASSERT( CGContextTypeFont == NVG_FONT_CONTEXT);

   // Winding assertions
   MULLE_C_ASSERT( CARotationDirectionCounterClockWise == NVG_CCW);
   MULLE_C_ASSERT( CARotationDirectionClockWise == NVG_CW);

   // Line Cap assertions
   MULLE_C_ASSERT( CGLineCapButt == NVG_BUTT);
   MULLE_C_ASSERT( CGLineCapRound == NVG_ROUND);
   MULLE_C_ASSERT( CGLineCapSquare == NVG_SQUARE);
   MULLE_C_ASSERT( CGLineCapBevel == NVG_BEVEL);
   MULLE_C_ASSERT( CGLineCapMiter == NVG_MITER);

   // Text Align assertions
   MULLE_C_ASSERT( CGTextAlignLeft == NVG_ALIGN_LEFT);
   MULLE_C_ASSERT( CGTextAlignCenter == NVG_ALIGN_CENTER);
   MULLE_C_ASSERT( CGTextAlignRight == NVG_ALIGN_RIGHT);
   MULLE_C_ASSERT( CGTextAlignTop == NVG_ALIGN_TOP);
   MULLE_C_ASSERT( CGTextAlignMiddle == NVG_ALIGN_MIDDLE);
   MULLE_C_ASSERT( CGTextAlignBottom == NVG_ALIGN_BOTTOM);
   MULLE_C_ASSERT( CGTextAlignBaseline == NVG_ALIGN_BASELINE);

   // Blend Factor assertions
   MULLE_C_ASSERT( CGBlendFactorZero == NVG_ZERO);
   MULLE_C_ASSERT( CGBlendFactorOne == NVG_ONE);
   MULLE_C_ASSERT( CGBlendFactorSrcColor == NVG_SRC_COLOR);
   MULLE_C_ASSERT( CGBlendFactorOneMinusSrcColor == NVG_ONE_MINUS_SRC_COLOR);
   MULLE_C_ASSERT( CGBlendFactorDstColor == NVG_DST_COLOR);
   MULLE_C_ASSERT( CGBlendFactorOneMinusDstColor == NVG_ONE_MINUS_DST_COLOR);
   MULLE_C_ASSERT( CGBlendFactorSrcAlpha == NVG_SRC_ALPHA);
   MULLE_C_ASSERT( CGBlendFactorOneMinusSrcAlpha == NVG_ONE_MINUS_SRC_ALPHA);
   MULLE_C_ASSERT( CGBlendFactorDstAlpha == NVG_DST_ALPHA);
   MULLE_C_ASSERT( CGBlendFactorOneMinusDstAlpha == NVG_ONE_MINUS_DST_ALPHA);
   MULLE_C_ASSERT( CGBlendFactorSrcAlphaSaturate == NVG_SRC_ALPHA_SATURATE);

   // Composite Operation assertions
   MULLE_C_ASSERT( CGCompositeOperationSourceOver == NVG_SOURCE_OVER);
   MULLE_C_ASSERT( CGCompositeOperationSourceIn == NVG_SOURCE_IN);
   MULLE_C_ASSERT( CGCompositeOperationSourceOut == NVG_SOURCE_OUT);
   MULLE_C_ASSERT( CGCompositeOperationAtop == NVG_ATOP);
   MULLE_C_ASSERT( CGCompositeOperationDestinationOver == NVG_DESTINATION_OVER);
   MULLE_C_ASSERT( CGCompositeOperationDestinationIn == NVG_DESTINATION_IN);
   MULLE_C_ASSERT( CGCompositeOperationDestinationOut == NVG_DESTINATION_OUT);
   MULLE_C_ASSERT( CGCompositeOperationDestinationAtop == NVG_DESTINATION_ATOP);
   MULLE_C_ASSERT( CGCompositeOperationLighter == NVG_LIGHTER);
   MULLE_C_ASSERT( CGCompositeOperationCopy == NVG_COPY);
   MULLE_C_ASSERT( CGCompositeOperationXOR == NVG_XOR);

   // Image Flags assertions
   MULLE_C_ASSERT( CGImageFlagGenerateMipmaps == NVG_IMAGE_GENERATE_MIPMAPS);
   MULLE_C_ASSERT( CGImageFlagRepeatX == NVG_IMAGE_REPEATX);
   MULLE_C_ASSERT( CGImageFlagRepeatY == NVG_IMAGE_REPEATY);
   MULLE_C_ASSERT( CGImageFlagFlipY == NVG_IMAGE_FLIPY);
   MULLE_C_ASSERT( CGImageFlagPremultiplied == NVG_IMAGE_PREMULTIPLIED);
   MULLE_C_ASSERT( CGImageFlagNearest == NVG_IMAGE_NEAREST);
   MULLE_C_ASSERT( CGImageFlagMSAA == NVG_IMAGE_MSAA);
   MULLE_C_ASSERT( CGImageFlagRBOLess == NVG_IMAGE_RBO_LESS);

   // Tessellation assertions
   MULLE_C_ASSERT( CGTessellationSubdivision == NVG_TESS_SUBDIVISION);
   MULLE_C_ASSERT( CGTessellationAFD == NVG_TESS_AFD);

   flags  = (options & UIGraphicsEdgeAntiAliasing)  ? NVG_ANTIALIAS : 0;
   flags |= (options & UIGraphicsUseStencilStrokes) ? NVG_STENCIL_STROKES : 0;
   flags |= (options & UIGraphicsUseClearType)      ? NVG_CLEARTYPE : 0;
   flags |= (options & UIGraphicsNoDrawing)         ? NVG_NO_DRAWING : 0;
#ifdef DEBUG
   flags |= NVG_DEBUG;
#endif

#if defined( NANOVG_GL3_IMPLEMENTATION) || defined( NANOVG_GLES3_IMPLEMENTATION)
   flags |= (options & UIGraphicsUseMSAA) ? NVG_MSAA : 0;
#endif

   _backendFlags = flags;
   [self _initBackend];

   assert( _cgBackend.context);
#ifdef DEBUG
   fprintf( stderr, "nanovg context          : %s\n", [self nanovgInfoUTF8String]);
#endif

   // we always set this
#ifndef NVG_TRACECODE_DISABLED
   nvgTraceName( _cgBackend.context, _nameUTF8String);
#endif
   if( options & UIGraphicsTraceDrawCalls)
   {
#ifndef NVG_TRACECODE_DISABLED
      nvgTrace( _cgBackend.context, stderr);
#else
      mulle_fprintf( "nvg trace not available (NVG_TRACECODE_DISABLED)\n");
#endif
   }

   _framebufferBits = GL_COLOR_BUFFER_BIT;
   if( options & UIGraphicsUseStencilStrokes)
      _framebufferBits |= GL_STENCIL_BUFFER_BIT;
}

#if defined(__GNUC__) || defined(__clang__)
#pragma GCC diagnostic pop
#endif


- (void *) gpuTextureForImageID:(NSInteger) textureID
{
#ifdef NANOVG_GL3_IMPLEMENTATION
   return( (void *) (uintptr_t) nvglImageHandleGL3( _cgBackend.context, textureID));
#endif
#ifdef NANOVG_GLES2_IMPLEMENTATION
   return( (void *) (uintptr_t) nvglImageHandleGLES2( _cgBackend.context, textureID));
#endif
#ifdef NANOVG_GLES3_IMPLEMENTATION
   return( (void *) (uintptr_t) nvglImageHandleGLES3( _cgBackend.context, textureID));
#endif
   abort();
}


//
// https://stackoverflow.com/questions/3073796/how-to-use-glcopyimage2d
//
// glGetTexImage doesn't exist in OpenGL ES 1.1 or 2.0. This means, if we
// have GLES we need to create a temporary CGFramebuffer
//
#if defined( NANOVG_GLES2_IMPLEMENTATION) || defined( NANOVG_GLES3_IMPLEMENTATION)

- (struct CGBitmap) RGBABytesBitmapOfImage:(CGImage *) image
                                 allocator:(struct mulle_allocator *) allocator
{
   void                          *gpuTexture;
   GLuint                        tmpFramebuffer;
   GLint                         samplerType;
   struct CGBitmap               bitmap;
   struct CGContextFramebuffer   next;
   struct CGContextFramebuffer   previous;
   CGPixelSize                   bitmapSize;
   size_t                        size;
   BOOL                          isMultiSample;
#if defined( NANOVG_GLES3_IMPLEMENTATION)
   NVGframebuffer              *nvgResultFramebuffer;
#endif

   bitmapSize       = [image bitmapSize];
   size             = bitmapSize.width * bitmapSize.height * 4;
   assert( size);

   // circumvent nvidia bug
   size            += 16;

   // implicity transparent background
   bitmap.allocator = allocator ? allocator : &mulle_default_allocator;
   bitmap.bytes     = mulle_allocator_calloc( bitmap.allocator, 1, size);
   // flipped not flipped ?
   bitmap.info      = CGBitmapInfoMake( bitmapSize, 0, CGBitmapEncodingFlipYRGBABytes);

   glGenFramebuffers( 1, &tmpFramebuffer);
   CGContextCheckBackendError( self, "glGenFramebuffers");

   isMultiSample = [image isMultiSample];
   next          = CGContextFramebufferMakeWithOpenGLHandle( (void *) (uintptr_t) tmpFramebuffer,
                                                             isMultiSample);
   samplerType   = isMultiSample ? GL_TEXTURE_2D_MULTISAMPLE : GL_TEXTURE_2D;
   gpuTexture    = [self gpuTextureForTextureID:[image textureID]];
   previous      = [self bindFramebuffer:next];
   {
      glFramebufferTexture2D( GL_FRAMEBUFFER,
                              GL_COLOR_ATTACHMENT0,
                              samplerType,
                              (GLuint) (uintptr_t) gpuTexture,
                              0);
      CGContextCheckBackendError( self, "glFramebufferTexture2D");

#if defined( NANOVG_GLES3_IMPLEMENTATION)
      if( samplerType == GL_TEXTURE_2D_MULTISAMPLE)
      {
         nvgResultFramebuffer = CGContextBFN(self)->createFramebuffer( _cgBackend.context, bitmapSize.width,
                                                            bitmapSize.height,
                                                            NVG_IMAGE_RBO_LESS);
         CGContextBFN(self)->bindDrawFramebuffer( _cgBackend.context, nvgResultFramebuffer);
         CGContextCheckBackendError( self, "nvgluBindDrawFramebuffer");
         glBindFramebuffer( GL_READ_FRAMEBUFFER, (GLuint) (uintptr_t) next.handle);
         CGContextCheckBackendError( self, "glBindFramebuffer");
         glBlitFramebuffer( 0, 0, bitmapSize.width, bitmapSize.height,
                            0, 0, bitmapSize.width, bitmapSize.height,
                            GL_COLOR_BUFFER_BIT, GL_NEAREST);
         CGContextCheckBackendError( self, "glBlitFramebuffer");
         CGContextBFN(self)->bindFramebuffer( _cgBackend.context, nvgResultFramebuffer);
      }
#endif
      glReadPixels( 0, 0,
                    bitmapSize.width,
                    bitmapSize.height,
                    GL_RGBA,
                    GL_UNSIGNED_BYTE,
                    bitmap.bytes);
      CGContextCheckBackendError( self, "glReadPixels");

#if defined( NANOVG_GLES3_IMPLEMENTATION)
      if( samplerType == GL_TEXTURE_2D_MULTISAMPLE)
      {
         CGContextBFN(self)->bindFramebuffer( _cgBackend.context, NULL);
         CGContextBFN(self)->deleteFramebuffer( _cgBackend.context, nvgResultFramebuffer);
      }
#endif
   }
   [self bindFramebuffer:previous];

   glDeleteFramebuffers( 1, &tmpFramebuffer);
   CGContextCheckBackendError( self, "glDeleteFramebuffers");

   return( bitmap);
}

#else

- (struct CGBitmap) RGBABytesBitmapOfImage:(CGImage *) image
                                 allocator:(struct mulle_allocator *) allocator
{
   struct CGBitmap    bitmap;
   CGPixelSize        bitmapSize;
   CGBitmapEncoding   encoding;
   GLenum             format;
   GLenum             type;
   GLint              samplerType;
   size_t             size;
   NSUInteger         textureID;
   void               *gpuTexture;

   encoding = CGBitmapEncodingFlipYRGBABytes;
   format   = GL_RGBA;
   type     = GL_UNSIGNED_BYTE;

   assert( [image context] == self);

   textureID = [image textureID];
   nvgImageTextureInfo( _cgBackend.context, textureID, NULL, NULL, &gpuTexture);

   bitmapSize        = [image bitmapSize];
   size              = bitmapSize.width * bitmapSize.height * 4;
   assert( size);

   size             += 16;
   bitmap.allocator  = allocator ? allocator : &mulle_default_allocator;
   bitmap.bytes      = mulle_allocator_malloc( bitmap.allocator, size);
   bitmap.info       = CGBitmapInfoMake( bitmapSize, 0, encoding);

   samplerType       = [image gpuSamplerType];

   // glGetTexImage is only available in GL compatibility profile, not core profile.
   // Check GL_CONTEXT_PROFILE_MASK to decide which path to use.
   {
      GLint profileMask = 0;
      glGetIntegerv( GL_CONTEXT_PROFILE_MASK, &profileMask);
      if( profileMask & GL_CONTEXT_COMPATIBILITY_PROFILE_BIT)
      {
         glBindTexture( samplerType, (int) (intptr_t) gpuTexture);
         CGContextCheckBackendError( self, "glBindTexture");
         glGetTexImage( samplerType, 0, format, type, bitmap.bytes);
         CGContextCheckBackendError( self, "glGetTexImage");
         glBindTexture( samplerType, 0);
         CGContextCheckBackendError( self, "glBindTexture");
      }
      else
      {
         // Core profile: use framebuffer readback, with MSAA resolve if needed
         GLuint   readFBO;
         GLuint   attachFBO;

         glGenFramebuffers( 1, &attachFBO);
         CGContextCheckBackendError( self, "glGenFramebuffers");
         glBindFramebuffer( GL_FRAMEBUFFER, attachFBO);
         glFramebufferTexture2D( GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                                 samplerType, (GLuint) (uintptr_t) gpuTexture, 0);
         CGContextCheckBackendError( self, "glFramebufferTexture2D");

         if( samplerType == GL_TEXTURE_2D_MULTISAMPLE)
         {
            // Resolve MSAA into a plain 2D texture first
            GLuint resolveTex;
            glGenTextures( 1, &resolveTex);
            glBindTexture( GL_TEXTURE_2D, resolveTex);
            glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA8,
                          bitmapSize.width, bitmapSize.height,
                          0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
            glBindTexture( GL_TEXTURE_2D, 0);

            glGenFramebuffers( 1, &readFBO);
            glBindFramebuffer( GL_DRAW_FRAMEBUFFER, readFBO);
            glFramebufferTexture2D( GL_DRAW_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                                    GL_TEXTURE_2D, resolveTex, 0);
            CGContextCheckBackendError( self, "glFramebufferTexture2D resolve");

            glBindFramebuffer( GL_READ_FRAMEBUFFER, attachFBO);
            glBlitFramebuffer( 0, 0, bitmapSize.width, bitmapSize.height,
                               0, 0, bitmapSize.width, bitmapSize.height,
                               GL_COLOR_BUFFER_BIT, GL_NEAREST);
            CGContextCheckBackendError( self, "glBlitFramebuffer");

            glBindFramebuffer( GL_READ_FRAMEBUFFER, readFBO);
            glReadPixels( 0, 0, bitmapSize.width, bitmapSize.height,
                          format, type, bitmap.bytes);
            CGContextCheckBackendError( self, "glReadPixels");

            glBindFramebuffer( GL_FRAMEBUFFER, 0);
            glDeleteFramebuffers( 1, &readFBO);
            glDeleteTextures( 1, &resolveTex);
         }
         else
         {
            glReadPixels( 0, 0, bitmapSize.width, bitmapSize.height,
                          format, type, bitmap.bytes);
            CGContextCheckBackendError( self, "glReadPixels");
            glBindFramebuffer( GL_FRAMEBUFFER, 0);
         }
         glDeleteFramebuffers( 1, &attachFBO);
         CGContextCheckBackendError( self, "glDeleteFramebuffers");
      }
   }

   return( bitmap);
}

#endif


- (struct CGBitmap) readFramebufferBitmap:(CGPixelRect) rect
                    framebufferBitmapType:(CGFramebufferBitmapType) fType
                                allocator:(struct mulle_allocator *) allocator
{
   struct CGBitmap    bitmap;
   CGBitmapEncoding   encoding;
   GLenum             format;
   GLenum             type;
   size_t             size;

   switch( fType)
   {
   case CGFramebufferRGBABytes     : encoding = CGBitmapEncodingFlipYRGBABytes;
                                     format   = GL_RGBA;
                                     type     = GL_UNSIGNED_BYTE;
                                     break;
   case CGFramebufferRGBAFloats    : encoding = CGBitmapEncodingFlipYRGBABytes;
                                     format   = GL_RGBA;
                                     type     = GL_FLOAT;
                                     break;
#if ! defined( NANOVG_GLES2_IMPLEMENTATION) && ! defined( NANOVG_GLES3_IMPLEMENTATION)
   case CGFramebufferStencilFloats : encoding = CGBitmapEncodingFlipYMonochromeFloats;
                                     format   = GL_STENCIL_INDEX;
                                     type     = GL_FLOAT;
                                     break;
   case CGFramebufferDepthFloats   : encoding = CGBitmapEncodingFlipYMonochromeFloats;
                                     format   = GL_DEPTH_COMPONENT;
                                     type     = GL_FLOAT;
                                     break;
#endif

   default :
#ifdef DEBUG
      fprintf( stderr, "CGFramebufferBitmapType %td is not supported\n", fType);
#endif
      memset( &bitmap, 0, sizeof( bitmap));
      return( bitmap);
   }

   bitmap.info      = CGBitmapInfoMake( rect.size, 0, encoding);
   size             = CGBitmapInfoGetAllocationLength( bitmap.info);
   bitmap.allocator = allocator ? allocator : &mulle_default_allocator;
   size            += 16;
   bitmap.bytes     = mulle_allocator_malloc( bitmap.allocator, size);

   glReadPixels( (int) rect.origin.x,   (int) rect.origin.y,
                 (int) rect.size.width, (int) rect.size.height,
                 format,
                 type,
                 bitmap.bytes);
   CGContextCheckBackendError( self, "glReadPixels");

   return( bitmap);
}


@end

#pragma clang diagnostic pop
