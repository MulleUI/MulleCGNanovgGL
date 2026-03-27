#ifndef nanovg_backend_h__
#define nanovg_backend_h__

//
// nanovg-backend.h — backend-neutral framebuffer API
//
// Normalizes nvglu* (GL), d3dnvg* (D3D11), and mnvg* (Metal) into a
// single mnvg* interface used by nanovg-specific/ drawing code.
//
// Must be included AFTER _MulleCGBackend.h and the relevant nanovg_*.h headers.
//

#if defined( NANOVG_GL3_IMPLEMENTATION) || defined( NANOVG_GL2_IMPLEMENTATION) \
 || defined( NANOVG_GLES2_IMPLEMENTATION) || defined( NANOVG_GLES3_IMPLEMENTATION) \
 || defined( NANOVG_GL3) || defined( NANOVG_GL2) \
 || defined( NANOVG_GLES2) || defined( NANOVG_GLES3) \
 || defined( MULLE_CG_HAVE_MODERN_OPENGL) || defined( MULLE_CG_HAVE_DEPRECATED_OPENGL)

// nanovg_gl_utils.h must already be included before this header
# define mnvgCreateFramebuffer( ctx, w, h, f)          nvgluCreateFramebuffer( ctx, w, h, f)
# define mnvgDeleteFramebuffer( ctx, fb)                nvgluDeleteFramebuffer( fb)
# define mnvgBindFramebuffer( ctx, fb)                  nvgluBindFramebuffer( fb)
# define mnvgBindDrawFramebuffer( ctx, fb)              nvgluBindDrawFramebuffer( fb)
# define mnvgReadPixels( ctx, fb, x, y, w, h, d)       glnvgReadPixels( ctx, fb, x, y, w, h, d)

#elif defined( NANOVG_D3D11_IMPLEMENTATION) || defined( NANOVG_D3D11)

# include <mulle-nanovg/nanovg_d3d11.h>

# define mnvgCreateFramebuffer( ctx, w, h, f)          d3dnvgCreateFramebuffer( ctx, w, h, f)
# define mnvgDeleteFramebuffer( ctx, fb)                d3dnvgDeleteFramebuffer( ctx, fb)
# define mnvgBindFramebuffer( ctx, fb)                  d3dnvgBindFramebuffer( ctx, fb)
# define mnvgBindDrawFramebuffer( ctx, fb)              d3dnvgBindFramebuffer( ctx, fb)
# define mnvgReadPixels( ctx, fb, x, y, w, h, d)       d3dnvgReadPixels( ctx, fb, x, y, w, h, d)

#elif defined( NANOVG_MTL_IMPLEMENTATION) || defined( NANOVG_MTL)

# include <mulle-nanovg/nanovg_mtl.h>

// Metal nanovg already uses mnvg* names natively — no remapping needed.
# define mnvgBindDrawFramebuffer( ctx, fb)              mnvgBindFramebuffer( ctx, fb)

#endif

#endif /* nanovg_backend_h__ */
