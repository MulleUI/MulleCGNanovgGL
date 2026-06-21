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
