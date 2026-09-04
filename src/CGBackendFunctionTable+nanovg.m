//
//  CGBackendFunctionTable+nanovg.m
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
// CGBackendFunctionTable+nanovg.m
// MulleCGNanovgGL
//
#import "CGBackendFunctionTable+nanovg.h"

#import "import-private.h"


static int   _framebufferTextureID( void *ctx, void *fb)
{
   (void) ctx;
#if defined( MULLE_CG_BACKEND_OPENGL)
   return( ((NVGLUframebuffer *) fb)->image);
#else
   // D3D11 and Metal store framebuffer as (NVGframebuffer)(intptr_t)imageID
   return( (int)(intptr_t) fb);
#endif
}


#if defined( MULLE_CG_BACKEND_OPENGL)
// GL bind/delete don't take ctx — need thin wrappers to match table signature
static void   _gl_deleteFramebuffer( void *ctx, void *fb)    { (void) ctx; nvgluDeleteFramebuffer( fb);   }
static void   _gl_bindFramebuffer( void *ctx, void *fb)      { (void) ctx; nvgluBindFramebuffer( fb);     }
static void   _gl_bindDrawFramebuffer( void *ctx, void *fb)  { (void) ctx; nvgluBindDrawFramebuffer( fb); }
#endif


MULLE_CG_NANOVG_GL_GLOBAL_VAR
CGBackendFunctionTable   CGNanoVGBackendFunctionTable =
{
#if defined( MULLE_CG_BACKEND_OPENGL)
   .createFramebuffer    = (void *(*)(void *, int, int, int))   nvgluCreateFramebuffer,
   .deleteFramebuffer    = _gl_deleteFramebuffer,
   .bindFramebuffer      = _gl_bindFramebuffer,
   .bindDrawFramebuffer  = _gl_bindDrawFramebuffer,
#elif defined( MULLE_CG_BACKEND_D3D11)
   .createFramebuffer    = (void *(*)(void *, int, int, int))   d3dnvgCreateFramebuffer,
   .deleteFramebuffer    = (void (*)(void *, void *))           d3dnvgDeleteFramebuffer,
   .bindFramebuffer      = (void (*)(void *, void *))           d3dnvgBindFramebuffer,
   .bindDrawFramebuffer  = (void (*)(void *, void *))           d3dnvgBindFramebuffer,
#elif defined( MULLE_CG_BACKEND_METAL)
   .createFramebuffer    = (void *(*)(void *, int, int, int))   mnvgCreateFramebuffer,
   .deleteFramebuffer    = (void (*)(void *, void *))           mnvgDeleteFramebuffer,
   .bindFramebuffer      = (void (*)(void *, void *))           mnvgBindFramebuffer,
   .bindDrawFramebuffer  = (void (*)(void *, void *))           mnvgBindFramebuffer,
#endif
   .framebufferTextureID = _framebufferTextureID,
};
