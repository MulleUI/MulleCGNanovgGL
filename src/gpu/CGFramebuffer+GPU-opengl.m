//
//  CGFramebuffer+GPU-opengl.m
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
