//
//  CGContext+GPU-opengl.m
//  MulleCGNanovgGL
//
//  Copyright (c) 2026 Nat! - Mulle kybernetiK.
//  All rights reserved.
//
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  Neither the name of Mulle kybernetiK nor the names of its contributors
//  may be used to endorse or promote products derived from this software
//  without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
#define MULLE_CG_USE_APPLE_GL2

#import "import-private.h"

#import <MulleCG/CGContext+DebugPrivate.h>
#import <MulleCG/CGContext+CGFramebuffer+Private.h>
#include <ctype.h>


@implementation CGContext ( GPU)


@dependency CGContext( UIGraphicsDrawing);


- (CGPixelSize) bitmapSizeOfFramebuffer:(struct CGContextFramebuffer) fb
{
   switch( fb.type)
   {
   case CGContextDefaultFramebuffer :
   case CGContextDefaultMultiSampleFramebuffer :
      return( _CGContextBitmapSizeOfDefaultFramebuffer( self, fb));
   case CGContextLayerFramebuffer :
   case CGContextLayerMultiSampleFramebuffer :
      return( _CGContextBitmapSizeOfLayerFramebuffer( self, fb));
   case CGContextOpenGLFramebuffer :
   case CGContextOpenGLMultiSampleFramebuffer :
      return( _CGContextBitmapSizeOfGPUFramebuffer( self, fb));
   }
   abort();
}


- (NSUInteger) framebufferBitsWithColorBit:(BOOL) flag
{
   if( flag)
      return( _framebufferBits | GL_COLOR_BUFFER_BIT);
   return( _framebufferBits & ~GL_COLOR_BUFFER_BIT);
}


- (void) clearFramebufferBits:(NSUInteger) bits
                        color:(CGColor) color
{
   if( bits & GL_COLOR_BUFFER_BIT)
      glClearColor( color.r, color.g, color.b, color.a);

   glClear( bits);
   CGContextCheckBackendError( self, "clear framebuffer");
}


- (void) clearFramebufferNoColor
{
   [self clearFramebufferBits:_framebufferBits & ~GL_COLOR_BUFFER_BIT
                        color:CGColorMakeWithHexColor(0x00000000)];
}


- (void) _changeRenderGPU:(struct CGFrameInfo *) info
{
   glViewport( info->viewportFrame.origin.x,
               info->viewportFrame.origin.y,
               info->viewportFrame.size.width,
               info->viewportFrame.size.height);
   CGContextCheckBackendError( self, "glViewport");
}


- (CGPixelRect) viewport
{
   return( _viewport);
}


- (void) setViewport:(CGPixelRect) rect
{
   _viewport = rect;

   if( rect.size.width == -1)
   {
      glViewport( _currentFrameInfo.viewportFrame.origin.x,
                  _currentFrameInfo.viewportFrame.origin.y,
                  _currentFrameInfo.viewportFrame.size.width,
                  _currentFrameInfo.viewportFrame.size.height);
   }
   else
   {
      glViewport( rect.origin.x, rect.origin.y,
                  rect.size.width, rect.size.height);
   }
}


- (void) bindDefaultGPUFramebuffer
{
   CGContextRenderLog( "");

   CGContextBFN(self)->bindFramebuffer( CGContextVG(self), NULL);
   CGContextCheckBackendError( self, "bind buffer");
}


- (void) bindGPUFramebuffer:(void *) framebuffer
{
   CGContextRenderLog( "");

   glBindFramebuffer( GL_FRAMEBUFFER, (GLuint) (uintptr_t) framebuffer);
   CGContextCheckBackendError( self, "glBindFramebuffer");
}


//
// used by CGImage when sharing textures to ensure that a texture is ready
// to be used:
// https://stackoverflow.com/questions/23300895/sharing-textures-between-opengl-contexts-with-glfw3-is-not-working
//
- (void) barrier
{
   // headless / no-backend contexts have no current GL context, so glFinish
   // would dereference a NULL context and crash (notably on Apple libGL)
   if( _backend == UIGraphicsBackendNone)
      return;

   // 15.6.2023: if i comment glFinish out, the display flickers slightly
   glFinish();
   CGContextCheckBackendError( self, "glFinish");
}


- (struct CGBitmap) framebufferBitmap
{
   struct CGBitmap      bitmap;
   struct CGFrameInfo   frameInfo;
   CGPixelRect          rect;

   [self getCurrentFrameInfo:&frameInfo];

   rect   = CGPixelRectMakeWithPixelSize( frameInfo.window.framebufferSize);
   bitmap = [self readFramebufferBitmap:rect
                  framebufferBitmapType:CGFramebufferRGBABytes
                              allocator:NULL];

   return( bitmap);
}


- (void) bindImage:(CGImage *) image
     toTextureUnit:(NSUInteger) index
{
   void   *gpuTexture;
   GLint   samplerType;

   CGContextRenderLog( "%#@ texture unit: %tu", image, index);

   gpuTexture  = [self gpuTextureForImageID:[image textureID]];
   samplerType = [image isMultiSample] ? GL_TEXTURE_2D_MULTISAMPLE : GL_TEXTURE_2D;

   assert( GL_TEXTURE15 == GL_TEXTURE0 + 15);
   glActiveTexture( GL_TEXTURE0 + index);
   CGContextCheckBackendError( self, "glActiveTexture");
   glBindTexture( samplerType, (GLuint) (uintptr_t) gpuTexture);
   glBindTexture( samplerType, (GLuint) (uintptr_t) gpuTexture);
   CGContextCheckBackendError( self, "glBindTexture");
}


static BOOL  _CGContextCurrentContextIsMultiSample( CGContext *self,  GLint FBO)
{
#if defined( GL_ES_VERSION_3_0) || defined( GL_VERSION_3_0)
   GLint   samples;
   GLint   defaultRBO;
   GLint   stencilRenderbuffer;

   // Queries of default framebuffers are supported only if the GL version is
   // 4.5 or higher. Otherwise, an GL_INVALID_OPERATION error is generated.
   // shucks,  Queries of the framebuffer-dependent parameters
   // GL_SAMPLES, GL_SAMPLE_BUFFERS supported only if the GL version is 4.5
   // or higher. Double shucks.
   if( FBO == 0)
   {
      glGetIntegerv( GL_SAMPLES, &samples);
      CGContextCheckBackendError( self, "glGetIntegerv");
   }
   else
   {
      glGetIntegerv( GL_RENDERBUFFER_BINDING, &defaultRBO);
      CGContextCheckBackendError( self, "glGetIntegerv");
      glGetFramebufferAttachmentParameteriv( GL_FRAMEBUFFER,
                                             GL_STENCIL_ATTACHMENT,
                                             GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME,
                                             &stencilRenderbuffer);
      CGContextCheckBackendError( self, "glGetFramebufferAttachmentParameteriv");
      glBindRenderbuffer(GL_RENDERBUFFER, stencilRenderbuffer);
      glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_SAMPLES, &samples);
      CGContextCheckBackendError( self, "glGetRenderbufferParameteriv");
      glBindRenderbuffer(GL_RENDERBUFFER, defaultRBO);
      CGContextCheckBackendError( self, "glBindRenderbuffer");
   }
   return( samples > 1);
#else
   return( NO);
#endif
}


struct CGContextFramebuffer
   CGContextCurrentGPUFramebuffer( CGContext *self)
{
   BOOL    isMultiSample;
   GLint   defaultFBO;

   glGetIntegerv( GL_FRAMEBUFFER_BINDING, &defaultFBO);
   CGContextCheckBackendError( self, "glGetIntegerv");

   isMultiSample = _CGContextCurrentContextIsMultiSample( self, defaultFBO);
   return( CGContextFramebufferMakeWithOpenGLHandle( (void *) (intptr_t) defaultFBO,
                                                      isMultiSample));
}


void   CGContextSetCurrentGPUFramebuffer( CGContext *self,
                                             struct CGContextFramebuffer fb)
{
   assert( fb.type == CGContextOpenGLFramebuffer
           || fb.type == CGContextDefaultFramebuffer
           || fb.type == CGContextOpenGLMultiSampleFramebuffer
           || fb.type == CGContextDefaultMultiSampleFramebuffer);

   CGContextRenderLog( "");

   glBindFramebuffer(GL_FRAMEBUFFER, (GLuint) (uintptr_t) fb.handle);
   CGContextCheckBackendError( self, "glBindFramebuffer");
}


CGPixelSize
   _CGContextBitmapSizeOfGPUFramebuffer( CGContext *self,
                                            struct CGContextFramebuffer fb)
{
#if defined( GL_ES_VERSION_3_0) || defined( GL_VERSION_3_0)
   GLint    defaultFBO;
   GLint    texture;
   GLint    width, height;
   GLint    samplerType;

   assert( fb.type == CGContextOpenGLFramebuffer
           || fb.type == CGContextDefaultFramebuffer
           || fb.type == CGContextOpenGLMultiSampleFramebuffer
           || fb.type == CGContextDefaultMultiSampleFramebuffer);

   glGetIntegerv(GL_FRAMEBUFFER_BINDING, &defaultFBO);
   glBindFramebuffer(GL_FRAMEBUFFER, (GLuint) (uintptr_t) fb.handle);
   {
      CGContextCheckBackendError( self, "glBindTexture");
      glGetFramebufferAttachmentParameteriv(GL_FRAMEBUFFER,
                                            GL_COLOR_ATTACHMENT0,
                                            GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME,
                                            &texture);
      CGContextCheckBackendError( self, "glGetFramebufferAttachmentParameteriv");
      samplerType = CGContextFramebufferIsMultiSample( fb)
                    ? GL_TEXTURE_2D_MULTISAMPLE
                    : GL_TEXTURE_2D;

      glBindTexture( samplerType, texture);
      glGetTexLevelParameteriv( samplerType, 0, GL_TEXTURE_WIDTH, &width);
      glGetTexLevelParameteriv( samplerType, 0, GL_TEXTURE_HEIGHT, &height);
      glBindTexture( samplerType, 0);

      CGContextCheckBackendError( self, "glGetTexLevelParameteriv");
   }
   glBindFramebuffer( GL_FRAMEBUFFER, defaultFBO);

   CGContextCheckBackendError( self, "glBindTexture");
   return( CGPixelSizeMake( width, height));
#else
   abort();
#endif
}


void   _CGContextBindFramebuffer( CGContext *self,
                                  CGContextFramebufferMode type,
                                  struct CGContextFramebuffer fb)
{
#if defined( GL_ES_VERSION_3_0) || defined( GL_VERSION_3_0)
   static GLint  glType[] = {
                              GL_FRAMEBUFFER,
                              GL_READ_FRAMEBUFFER,
                              GL_DRAW_FRAMEBUFFER
                             };
   GLuint   handle;
   void     *gpuTexture;

   assert( type >= 0 && type <= 2);
   CGContextRenderLog( "");

   switch( fb.type)
   {
   case CGContextDefaultFramebuffer :
   case CGContextOpenGLFramebuffer  :
   case CGContextDefaultMultiSampleFramebuffer :
   case CGContextOpenGLMultiSampleFramebuffer  :
      handle = (GLuint) (uintptr_t) fb.handle;
      break;

   case CGContextLayerFramebuffer :
   case CGContextLayerMultiSampleFramebuffer :
      gpuTexture = [self gpuTextureForTextureID:[(CGFramebuffer *) fb.handle textureID]];
      handle     = (GLuint) (uintptr_t) gpuTexture;
      break;
   }

   glBindFramebuffer( glType[ type], handle);
   CGContextCheckBackendError( self, "glBindFramebuffer");
#else
   abort();
#endif
}


void   _CGContextBlitFramebufferFramebuffer( CGContext *self,
                                             struct CGContextFramebuffer dst,
                                             CGRect rect,
                                             struct CGContextFramebuffer src,
                                             BOOL interpolate)
{
#if defined( GL_ES_VERSION_3_0) || defined( GL_VERSION_3_0)
   CGPixelSize   srcSize;
   CGPixelSize   dstSize;

   CGContextRenderLog( "");

   srcSize = CGContextBitmapSizeOfFramebuffer( self, src);
   dstSize = CGContextBitmapSizeOfFramebuffer( self, dst);

   // maybe overzealous
   if( CGPixelSizeEqualToPixelSize( srcSize, dstSize))
      interpolate = NO;

   /* When using glBlitFramebuffer, it is not a problem to specify attachments
      that do not exist. The function will simply ignore the non-existent
      attachments and perform the blit operation on the attachments that do
      exist. This means that you can use glBlitFramebuffer to copy specific
      color, depth, or stencil buffers from one framebuffer to another,
      even if not all of these buffers exist in both framebuffers.
    */
   {
      _CGContextBindFramebuffer( self, CGContextFramebufferModeWrite, dst);
      _CGContextBindFramebuffer( self, CGContextFramebufferModeRead, src);
      glBlitFramebuffer( 0, 0, srcSize.width, srcSize.height,
                         (int) rect.origin.x, (int) rect.origin.y,
                         (int) rect.size.width, (int) rect.size.height,
                         GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT,
                         interpolate ? GL_LINEAR : GL_NEAREST);
      CGContextCheckBackendError( self, "glBlitFramebuffer");
      // return to consistent state
      _CGContextBindFramebuffer( self, CGContextFramebufferModeRead, dst);
   }
#else
   abort();
#endif
}


void   _CGContextBlitFramebufferImage( CGContext *self,
                                       struct CGContextFramebuffer dst,
                                       CGRect rect,
                                       CGImage *src,
                                       BOOL interpolate)
{
#if defined( GL_ES_VERSION_3_0) || defined( GL_VERSION_3_0)
   GLuint        tmpFBO;
   GLuint        samplerType;
   void          *gpuTexture;
   BOOL          isMultiSample;
   CGPixelSize   srcSize;

   CGContextRenderLog( "");

   isMultiSample = [src isMultiSample];
   samplerType   = isMultiSample ? GL_TEXTURE_2D_MULTISAMPLE : GL_TEXTURE_2D;
   gpuTexture    = [self gpuTextureForTextureID:[src textureID]];
   srcSize       = [src bitmapSize];

   // create a temporary FBO, attach the source texture, blit to dst
   glGenFramebuffers( 1, &tmpFBO);
   glBindFramebuffer( GL_READ_FRAMEBUFFER, tmpFBO);
   glFramebufferTexture2D( GL_READ_FRAMEBUFFER,
                           GL_COLOR_ATTACHMENT0,
                           samplerType,
                           (GLuint) (uintptr_t) gpuTexture,
                           0);
   CGContextCheckBackendError( self, "setup read framebuffer");

   // bind dst as write target
   glBindFramebuffer( GL_DRAW_FRAMEBUFFER, (GLuint) (uintptr_t) dst.handle);

   glBlitFramebuffer( 0, 0, srcSize.width, srcSize.height,
                      (int) rect.origin.x, (int) rect.origin.y,
                      (int) (rect.origin.x + rect.size.width),
                      (int) (rect.origin.y + rect.size.height),
                      GL_COLOR_BUFFER_BIT,
                      interpolate ? GL_LINEAR : GL_NEAREST);
   CGContextCheckBackendError( self, "glBlitFramebuffer");

   // cleanup
   glBindFramebuffer( GL_READ_FRAMEBUFFER, (GLuint) (uintptr_t) dst.handle);
   glDeleteFramebuffers( 1, &tmpFBO);
   CGContextCheckBackendError( self, "cleanup");
#else
   abort();
#endif
}


- (void) blitRect:(CGRect) rect
            image:(id) image
            scale:(BOOL) scale
{
   struct CGContextFramebuffer   dst;
   CGDrawableOptions             *options;

   if( [image isMultiSample])
   {
      dst = CGContextCurrentGPUFramebuffer( self);
      _CGContextBlitFramebufferImage( self, dst, rect, image, NO);
      CGContextSetCurrentGPUFramebuffer( self, dst);
      return;
   }

   CGContextSave( self);
   {
      CGContextGlobalCompositeOperation( self, CGCompositeOperationCopy);
      options = scale ? &CGDrawableOptionsScaleToFit : &CGDrawableOptionsDefault;
      [image drawRect:rect
              options:options
              context:self];
   }
   CGContextRestore( self);
}

@end
