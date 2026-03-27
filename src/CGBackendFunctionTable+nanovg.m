//
// CGBackendFunctionTable+nanovg.m
// MulleCGNanovgGL
//
// nanovg backend implementation of CGBackendFunctionTable.
//
#import "import-private.h"

#include <mulle-nanovg/nanovg_gl_utils.h>



static void *  _createFramebuffer( void *ctx, int w, int h, int imageFlags)
{
   return( mnvgCreateFramebuffer( (NVGcontext *) ctx, w, h, imageFlags));
}

static void    _deleteFramebuffer( void *ctx, void *fb)
{
   mnvgDeleteFramebuffer( (NVGcontext *) ctx, fb);
}

static void    _bindFramebuffer( void *ctx, void *fb)
{
   mnvgBindFramebuffer( (NVGcontext *) ctx, fb);
}

static void    _bindDrawFramebuffer( void *ctx, void *fb)
{
   mnvgBindDrawFramebuffer( (NVGcontext *) ctx, fb);
}

static int     _framebufferTextureID( void *ctx, void *fb)
{
#if defined( MULLE_CG_HAVE_MODERN_OPENGL) || defined( MULLE_CG_HAVE_DEPRECATED_OPENGL)
   return( ((NVGLUframebuffer *) fb)->image);
#else
   (void) ctx;
   (void) fb;
   return( -1);
#endif
}


MULLE_CG_NANOVG_GL_GLOBAL_VAR
CGBackendFunctionTable   CGNanoVGBackendFunctionTable =
{
   .createFramebuffer    = _createFramebuffer,
   .deleteFramebuffer    = _deleteFramebuffer,
   .bindFramebuffer      = _bindFramebuffer,
   .bindDrawFramebuffer  = _bindDrawFramebuffer,
   .framebufferTextureID = _framebufferTextureID,
};
