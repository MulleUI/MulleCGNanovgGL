//
// CGContext+ImageEffect.m
// MulleCGNanovgGL
//
#import "import-private.h"

#import <MulleCG/CGContext+ImageEffect.h>


//
// Fullscreen quad — normal orientation, Y flip handled in vertex shader.
//
static float   s_quadVertices[] =
{
   -1.0f, -1.0f, 0.0f,
    1.0f, -1.0f, 0.0f,
   -1.0f,  1.0f, 0.0f,
    1.0f,  1.0f, 0.0f
};


static void   applyUniforms( CGShaderID shader, struct CGUniform *uniforms, NSUInteger count)
{
   GLuint       program = (GLuint) (uintptr_t) shader;
   GLint        loc;
   NSUInteger   i;

   for( i = 0; i < count; i++)
   {
      loc = glGetUniformLocation( program, uniforms[ i].name);
      if( loc == -1)
         continue;

      switch( uniforms[ i].type)
      {
      case CGUniformTypeFloat :
         glUniform1f( loc, uniforms[ i].floatValue);
         break;

      case CGUniformTypeVec2 :
         glUniform2fv( loc, 1, uniforms[ i].vec2);
         break;

      case CGUniformTypeVec4 :
         glUniform4fv( loc, 1, uniforms[ i].vec4);
         break;

      case CGUniformTypeInt :
         glUniform1i( loc, uniforms[ i].intValue);
         break;
      }
   }
}


static void  beginEffectRender( CGContext *self,
                                CGImage *image,
                                CGShaderID shader,
                                CGFramebuffer **p_framebuffer,
                                struct CGFramebufferRenderInfo *p_memo,
                                GLuint *p_VBO)
{
   NSUInteger   flags;

   flags = [image textureFlags];

   *p_framebuffer = [self framebufferWithSize:[image bitmapSize]
                                textureFlags:flags
                              nameUTF8String:"effect"];

   [*p_framebuffer beginFBRenderWithBackgroundColor:CGColorMakeClear()
                                  devicePixelRatio:1.0
                                   layerRenderInfo:p_memo];
   [self suspendRender];

   glGenBuffers( 1, p_VBO);
   glBindBuffer( GL_ARRAY_BUFFER, *p_VBO);
   glBufferData( GL_ARRAY_BUFFER, sizeof( s_quadVertices), s_quadVertices, GL_STATIC_DRAW);
   glVertexAttribPointer( 0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof( float), (void *) 0);
   glEnableVertexAttribArray( 0);

   [self useShader:shader];
   [self bindImage:image toTextureUnit:0];

   //
   // Force GL_NEAREST sampling on the source texture.  The shader does a
   // 1:1 pixel transfer (same resolution), so bilinear would just blur
   // for no reason.  The output FBO inherits the source's original
   // textureFlags, so the final draw-to-screen filtering is unchanged.
   //
   if( ! (flags & CGImageFlagNearest))
   {
      glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
      glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
   }

   glUniform1i( glGetUniformLocation( (GLuint) (uintptr_t) shader, "u_tex0"), 0);
}


static CGImage   *endEffectRender( CGContext *self,
                                   CGImage *image,
                                   CGFramebuffer *framebuffer,
                                   struct CGFramebufferRenderInfo *p_memo,
                                   GLuint VBO)
{
   glDrawArrays( GL_TRIANGLE_STRIP, 0, 4);

   //
   // Restore source texture filter if we forced GL_NEAREST.
   // The source texture is still bound on unit 0.
   //
   if( ! ([image textureFlags] & CGImageFlagNearest))
   {
      glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
      glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
   }

   glDisableVertexAttribArray( 0);
   glBindBuffer( GL_ARRAY_BUFFER, 0);
   glDeleteBuffers( 1, &VBO);
   glUseProgram( 0);

   [self resumeRender];
   [framebuffer endFBRender:p_memo];

   return( (CGImage *) framebuffer);
}


@implementation CGContext( ImageEffectFuture)

- (CGImage *) imageByRenderingImage:(CGImage *) image
                         withShader:(CGShaderID) shader
                           uniforms:(struct CGUniform *) uniforms
                              count:(NSUInteger) count
{
   CGFramebuffer                  *framebuffer;
   struct CGFramebufferRenderInfo memo;
   GLuint                         VBO;

   if( ! image || ! shader)
      return( nil);

   beginEffectRender( self, image, shader, &framebuffer, &memo, &VBO);
   if( ! framebuffer)
      return( nil);

   applyUniforms( shader, uniforms, count);

   return( endEffectRender( self, image, framebuffer, &memo, VBO));
}


- (CGImage *) imageByRenderingImage:(CGImage *) image
                         withShader:(CGShaderID) shader
                      setupCallback:(CGShaderSetupCallback *) setup
                           userInfo:(void *) info
{
   CGFramebuffer                  *framebuffer;
   struct CGFramebufferRenderInfo memo;
   GLuint                         VBO;

   if( ! image || ! shader)
      return( nil);

   beginEffectRender( self, image, shader, &framebuffer, &memo, &VBO);
   if( ! framebuffer)
      return( nil);

   if( setup)
      setup( shader, info);

   return( endEffectRender( self, image, framebuffer, &memo, VBO));
}

@end
