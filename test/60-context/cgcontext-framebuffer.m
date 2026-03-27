#import <MulleCG/MulleCG.h>


@interface FakeOSContext :NSObject <UIOSGraphicsContext>
@end

@implementation FakeOSContext

- (UIGraphicsBackend) backend
{
   return( UIGraphicsBackendNone);
}

- (NSThread *) activeThread
{
   return( [NSThread currentThread]);
}

@end


@interface CGFakeFramebuffer : CGFramebuffer
@end


@implementation CGFakeFramebuffer

//
// avoid delayed call to nvgDeleteImage
// by clobbering -didRemoveFromContext:
//
- (void) didRemoveFromContext:(CGContext *) context
{
   assert( context == _context);

   _textureID = 0;
   _context   = nil;
}

@end



int   main( int argc, char *argv[])
{
   CGContext       *context;
   CGFramebuffer   *framebuffer;
   CGFramebuffer   *other;
   FakeOSContext   *window;

   @autoreleasepool
   {
      window  = [FakeOSContext instance];
      context = [[[CGContext alloc] initWithOSGraphicsContext:window
                                                      shareID:0
                                                      options:0] autorelease];

      framebuffer = [[[CGFakeFramebuffer alloc] initWithTextureID:(CGTextureID) 0x1848
                                                       bitmapSize:CGPixelSizeMake( 128, 128)
                                                     textureFlags:0
                                                   nameUTF8String:"test"
                                                          context:context] autorelease];
      mulle_fprintf( stderr, "%td %td\n", [framebuffer retainCount], [NSAutoreleasePool mulleCountObject:framebuffer]);
      [context provideRenderedFramebuffer:framebuffer];
      mulle_fprintf( stderr, "%td %td\n", [framebuffer retainCount], [NSAutoreleasePool mulleCountObject:framebuffer]);
      other = [context acquireRenderedFramebuffer];
      if( other != framebuffer)
      {
         mulle_fprintf( stderr, "Bummer\n");
         return( 1);
      }

      [context recycleAcquiredRenderedFramebuffer:framebuffer];
      mulle_fprintf( stderr, "%td %td\n", [framebuffer retainCount], [NSAutoreleasePool mulleCountObject:framebuffer]);
      other = [context repossessRenderedFramebuffer];
      mulle_fprintf( stderr, "%td %td\n", [framebuffer retainCount], [NSAutoreleasePool mulleCountObject:framebuffer]);

      if( other != framebuffer)
      {
         mulle_fprintf( stderr, "Bummer\n");
         return( 1);
      }
   }
   return( 0);
}
