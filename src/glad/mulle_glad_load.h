#ifndef mulle_glad_load_h__
#define mulle_glad_load_h__

#if defined( _WIN32) || defined( __MINGW32__)
// Load all GL function pointers via wglGetProcAddress.
// Must be called after a GL context is made current.
// Returns the GL version (nonzero) on success, 0 on failure.
int   mulle_glad_load_gl( void);
#endif

#endif
