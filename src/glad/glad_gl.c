// glad_gl.c — compile the GLAD 2 GL loader implementation (Windows only)
#if defined( _WIN32) || defined( __MINGW32__)
# define GLAD_GL_IMPLEMENTATION
# include "gl.h"
#endif
