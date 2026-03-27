#import "import.h"
#import <MulleUIBase/UITextTypes.h>



int   main( int argc, char *argv[])
{
   CGLayoutContext    *context;
   NSUInteger         nRows;
   NSUInteger         again;
   NSUInteger         i;
   struct UITextRow   rows[ 3];
   static char        *text = "\n  Ahoi! \n \n";

   mulle_memset_uint32( rows, 0xDEADFACE, sizeof( rows));

   @autoreleasepool
   {
      context = [CGLayoutContext object];

      CGContextFontFace( context, NULL);
      CGContextFontSize( context, 12.0);
      CGContextTextAlignment( context, UITextAlignmentCenter);
      CGContextTextLetterSpacing( context, 0.5);

      nRows = CGContextTextBreakLines( context, text,
                                                -1,
                                                INFINITY,
                                                NULL,
                                                NSIntegerMax,
                                                sizeof( struct UITextRow));
      if( nRows != 3)
      {
         mulle_fprintf( stderr, "nRows = %tu unexpected\n", nRows);
         return( 1);
      }

      mulle_fprintf( stderr, "sizeof( struct UITextRow)  = %td\n", sizeof( struct UITextRow));
      mulle_fprintf( stderr, "sizeof( struct UITextRow) = %td\n", sizeof( struct UITextRow));
      mulle_fprintf( stderr, "sizeof( struct UITextRow[ 3])  = %td\n", sizeof( struct UITextRow[3]));
      mulle_fprintf( stderr, "sizeof( struct UITextRow[ 3]) = %td\n", sizeof( struct UITextRow[3]));

      again = CGContextTextBreakLines( context, text,
                                                -1,
                                                INFINITY,
                                                rows,
                                                3,
                                                sizeof( struct UITextRow));
      if( again != nRows)
      {
         mulle_fprintf( stderr, "again = %tu unexpected\n", again);
         return( 1);
      }

      for( i = 0; i < nRows; i++)
      {
         mulle_printf( "%#tu\n", i);
         mulle_printf( "\trange : [%tu %tu]\n", rows[ i].range.location, rows[ i].range.length);
         mulle_printf( "\twidth : %.2f\n",      rows[ i].width);
         mulle_printf( "\tminx  : %.2f\n",      rows[ i].minx);
         mulle_printf( "\tmaxx  : %.2f\n",      rows[ i].maxx);
      }
   }
   return( 0);
}
