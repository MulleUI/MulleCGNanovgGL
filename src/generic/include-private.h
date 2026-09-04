//
//  include-private.h
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
#ifndef mulle_cg_nanovg_gl_include_private_h__
#define mulle_cg_nanovg_gl_include_private_h__

#include "include.h"

#include "_MulleCGNanovgGL-include-private.h"

// _MulleCGBackend.h sets NANOVG_GL3/GLES2/GLES3_IMPLEMENTATION based on
// DEFINE_NANOVG_GL_IMPLEMENTATION + MULLE_CG_GLVERSION — must come first
#include <MulleCGNanovg/_MulleCGBackend.h>

// ---- OpenGL ----
#ifdef MULLE_CG_BACKEND_OPENGL

# ifdef __APPLE__
#  define GL_GLEXT_PROTOTYPES
#  define GL_SILENCE_DEPRECATION
#  if defined( MULLE_CG_USE_APPLE_MACROS)
#   define MULLE_CG_HAVE_DEPRECATED_OPENGL 1
#   include <OpenGL/OpenGL.h>
#   include <OpenGL/CGLMacro.h>
#  else
#   if defined( MULLE_CG_USE_APPLE_GL)
#    define MULLE_CG_HAVE_DEPRECATED_OPENGL 1
#    include <OpenGL/gl.h>
#   endif
#   if defined( MULLE_CG_USE_APPLE_GL_EXT)
#    include <OpenGL/glext.h>
#   endif
#   if defined( MULLE_CG_USE_APPLE_GL3) || (! defined( MULLE_CG_USE_APPLE_GL) && ! defined( MULLE_CG_USE_APPLE_GL_EXT))
#    define MULLE_CG_HAVE_MODERN_OPENGL 1
#    include <OpenGL/gl3.h>
#   endif
#  endif
# elif defined( _WIN32) || defined( __MINGW32__)
#  define MULLE_CG_HAVE_MODERN_OPENGL 1
#  include "../glad/gl.h"
# else
#  if MULLE_CG_GLVERSION == MULLE_CG_GL3_2
#   define GL_GLEXT_PROTOTYPES
#   define MULLE_CG_HAVE_MODERN_OPENGL 1
#   include <GL/gl.h>
#   include <GL/glext.h>
#  elif MULLE_CG_GLVERSION == MULLE_CG_GLES2
#   define GL_GLEXT_PROTOTYPES
#   define MULLE_CG_HAVE_MODERN_OPENGL 1
#   include <GLES2/gl2.h>
#   include <GLES2/gl2ext.h>
#  elif MULLE_CG_GLVERSION == MULLE_CG_GLES3 || MULLE_CG_GLVERSION == MULLE_CG_GLES3_2
#   define GL_GLEXT_PROTOTYPES
#   define MULLE_CG_HAVE_MODERN_OPENGL 1
#   include <GLES3/gl3.h>
#   include <GLES3/gl3ext.h>
#   ifndef GL_MULTISAMPLE
#    define GL_MULTISAMPLE 0x809D
#   endif
#  endif
# endif

# include <mulle-nanovg/nanovg.h>
# include <mulle-nanovg/nanovg_gl.h>
# include <mulle-nanovg/nanovg_gl_utils.h>

#endif /* MULLE_CG_BACKEND_OPENGL */

#endif
