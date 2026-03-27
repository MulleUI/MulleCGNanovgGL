// mulle_glad_load.c — one-shot GL function loader for Windows
#if defined( _WIN32) || defined( __MINGW32__)

#include "gl.h"
#include <windows.h>

static HMODULE   opengl32_module;

static GLADapiproc mulle_win32_gl_get_proc( const char *name)
{
   GLADapiproc   p;

   p = (GLADapiproc) wglGetProcAddress( name);
   if( p)
      return( p);

   // fallback to opengl32.dll for GL 1.1 functions
   if( ! opengl32_module)
      opengl32_module = LoadLibraryA( "opengl32.dll");
   if( opengl32_module)
      p = (GLADapiproc) GetProcAddress( opengl32_module, name);
   return( p);
}


int   mulle_glad_load_gl( void)
{
   return( gladLoadGL( mulle_win32_gl_get_proc));
}

#endif
