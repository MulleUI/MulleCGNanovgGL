#import <MulleCGNanoVG_GL/MulleCGNanoVG_GL.h>


int   main( int argc, char *argv[])
{
#if defined( __MULLE_OBJC__)
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) != mulle_objc_universe_is_ok)
      return( 1);
#endif

   mulle_printf( "VfL Bochum 1848\n");
   return( 0);
}
