//
// Copyright (c) <|YEAR|> Nat!, Mulle kybernetiK
//

#import "import-private.h"


@implementation CGFramebuffer ( OpenGL)

- (void) beginFBRenderWithBackgroundColor:(CGColor) color
                         devicePixelRatio:(CGFloat) ratio
                          layerRenderInfo:(struct CGFramebufferRenderInfo *) memo
{
#ifdef _CGLMACRO_H
   CGLContextObj       cgl_ctx = CGLGetCurrentContext();
#endif
   CGFloat             rgba[ 4];
   CGPixelSize         bitmapSize;

   [self _beginFBRender:memo];

   CGColorGetRGBAComponents( color, rgba);

   bitmapSize = [self bitmapSize];
   glClearColor( rgba[ 0], rgba[ 1], rgba[ 2], rgba[ 3]);
   glClear( GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT|GL_STENCIL_BUFFER_BIT);

// this here is a little suspicious
   glViewport( 0, 0, bitmapSize.width, bitmapSize.height);

   CGContextCheckBackendError( _context, "glViewport");

// TODO: this here is also a little suspicious
   [self _didBeginFBRenderWithBitmapSize:bitmapSize
                        devicePixelRatio:ratio];
}


- (void) endFBRender:(struct CGFramebufferRenderInfo *) memo
{
//   struct NVGcontext   *vg;
//
//   vg = CGContextGetNVGContext( _context);
//
   [self _willEndFBRender:memo];

   // if we do just nvgFlushFrame here, then we don't torch font maps
   // nvgEndFrame( vg);

// TODO: not doing nvgFlushFrame is also a little suspicious

   // this will reset the viewport and call nvgFlushFrame
   [self _endFBRender:memo];
}

@end
