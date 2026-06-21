// nanovg_gl-extensions.inc
//
// Included at the end of nanovg_gl.h via NANOVG_GL_EXTENSION_SOURCE.
// Provides alternate ClearType shader for A/B comparison.
//

static GLNVGshader  s_nvggl__altShader;
static int          s_nvggl__altShaderReady;

//
// Alternate ClearType fragment: outputs premultiplied color with per-channel
// coverage so that GL blending (GL_ONE, GL_ONE_MINUS_SRC_COLOR) composites
// correctly against whatever background is actually in the framebuffer.
//
// The key change in type==4 branch:
//   result.xyz = color.xyz * innerCol.xyz;
//   result.w = max(color.x, max(color.y, color.z)) * innerCol.w;
//
// Instead of blending against outerCol in the shader, we let the GPU
// blend against the real framebuffer content.
//

int  nvggl__createAlternateShader( NVGcontext *ctx)
{
   GLNVGcontext  *gl = (GLNVGcontext *) nvgInternalParams( ctx)->userPtr;

   if( s_nvggl__altShaderReady)
      return( 1);

   // Duplicate the shader header/vert from the current build config
   static const char *shaderHeader =
#if defined NANOVG_GL2
      "#define NANOVG_GL2 1\n"
#elif defined NANOVG_GL3
      "#version 150 core\n"
      "#define NANOVG_GL3 1\n"
#elif defined NANOVG_GLES2
      "#version 100\n"
      "#extension GL_OES_standard_derivatives : enable\n"
      "#define NANOVG_GL2 1\n"
#elif defined NANOVG_GLES3
      "#version 300 es\n"
      "#define NANOVG_GL3 1\n"
#endif
#if NANOVG_GL_USE_UNIFORMBUFFER
      "#define USE_UNIFORMBUFFER 1\n"
#else
      "#define UNIFORMARRAY_SIZE 11\n"
#endif
      "\n";

   static const char *fillVertShader =
      "#ifdef NANOVG_GL3\n"
      "\tuniform vec2 viewSize;\n"
      "\tin vec2 vertex;\n"
      "\tin vec2 tcoord;\n"
      "\tout vec2 ftcoord;\n"
      "\tout vec2 fpos;\n"
      "#else\n"
      "\tuniform vec2 viewSize;\n"
      "\tattribute vec2 vertex;\n"
      "\tattribute vec2 tcoord;\n"
      "\tvarying vec2 ftcoord;\n"
      "\tvarying vec2 fpos;\n"
      "#endif\n"
      "void main(void) {\n"
      "\tftcoord = tcoord;\n"
      "\tfpos = vertex;\n"
      "\tgl_Position = vec4(2.0*vertex.x/viewSize.x - 1.0, 1.0 - 2.0*vertex.y/viewSize.y, 0, 1);\n"
      "}\n";

   // Same frag shader but with modified ClearType (type==4) branch
   static const char *altFragShader =
      "#ifdef GL_ES\n"
      "#if defined(GL_FRAGMENT_PRECISION_HIGH) || defined(NANOVG_GL3)\n"
      " precision highp float;\n"
      "#else\n"
      " precision mediump float;\n"
      "#endif\n"
      "#endif\n"
      "#ifdef NANOVG_GL3\n"
      "#ifdef USE_UNIFORMBUFFER\n"
      "\tlayout(std140) uniform frag {\n"
      "\t\tmat3 scissorMat;\n"
      "\t\tmat3 paintMat;\n"
      "\t\tvec4 innerCol;\n"
      "\t\tvec4 outerCol;\n"
      "\t\tvec2 scissorExt;\n"
      "\t\tvec2 scissorScale;\n"
      "\t\tvec2 extent;\n"
      "\t\tfloat radius;\n"
      "\t\tfloat feather;\n"
      "\t\tfloat strokeMult;\n"
      "\t\tfloat strokeThr;\n"
      "\t\tint texType;\n"
      "\t\tint type;\n"
      "\t};\n"
      "#else\n"
      "\tuniform vec4 frag[UNIFORMARRAY_SIZE];\n"
      "#endif\n"
      "\tuniform sampler2D tex;\n"
      "\tin vec2 ftcoord;\n"
      "\tin vec2 fpos;\n"
      "\tout vec4 outColor;\n"
      "#else\n"
      "\tuniform vec4 frag[UNIFORMARRAY_SIZE];\n"
      "\tuniform sampler2D tex;\n"
      "\tvarying vec2 ftcoord;\n"
      "\tvarying vec2 fpos;\n"
      "#endif\n"
      "#ifndef USE_UNIFORMBUFFER\n"
      "\t#define scissorMat mat3(frag[0].xyz, frag[1].xyz, frag[2].xyz)\n"
      "\t#define paintMat mat3(frag[3].xyz, frag[4].xyz, frag[5].xyz)\n"
      "\t#define innerCol frag[6]\n"
      "\t#define outerCol frag[7]\n"
      "\t#define scissorExt frag[8].xy\n"
      "\t#define scissorScale frag[8].zw\n"
      "\t#define extent frag[9].xy\n"
      "\t#define radius frag[9].z\n"
      "\t#define feather frag[9].w\n"
      "\t#define strokeMult frag[10].x\n"
      "\t#define strokeThr frag[10].y\n"
      "\t#define texType int(frag[10].z)\n"
      "\t#define type int(frag[10].w)\n"
      "#endif\n"
      "\n"
      "float sdroundrect(vec2 pt, vec2 ext, float rad) {\n"
      "\tvec2 ext2 = ext - vec2(rad,rad);\n"
      "\tvec2 d = abs(pt) - ext2;\n"
      "\treturn min(max(d.x,d.y),0.0) + length(max(d,0.0)) - rad;\n"
      "}\n"
      "\n"
      "float scissorMask(vec2 p) {\n"
      "\tvec2 sc = (abs((scissorMat * vec3(p,1.0)).xy) - scissorExt);\n"
      "\tsc = vec2(0.5,0.5) - sc * scissorScale;\n"
      "\treturn clamp(sc.x,0.0,1.0) * clamp(sc.y,0.0,1.0);\n"
      "}\n"
      "#ifdef EDGE_AA\n"
      "float strokeMask() {\n"
      "\treturn min(1.0, (1.0-abs(ftcoord.x*2.0-1.0))*strokeMult) * min(1.0, ftcoord.y);\n"
      "}\n"
      "#endif\n"
      "\n"
      "void main(void) {\n"
      "   vec4 result;\n"
      "\tfloat scissor = scissorMask(fpos);\n"
      "#ifdef EDGE_AA\n"
      "\tfloat strokeAlpha = strokeMask();\n"
      "\tif (strokeAlpha < strokeThr) discard;\n"
      "#else\n"
      "\tfloat strokeAlpha = 1.0;\n"
      "#endif\n"
      "\tif (type == 0) {\n"
      "\t\tvec2 pt = (paintMat * vec3(fpos,1.0)).xy;\n"
      "\t\tfloat d = clamp((sdroundrect(pt, extent, radius) + feather*0.5) / feather, 0.0, 1.0);\n"
      "\t\tvec4 color = mix(innerCol,outerCol,d);\n"
      "\t\tcolor *= strokeAlpha * scissor;\n"
      "\t\tresult = color;\n"
      "\t} else if (type == 1) {\n"
      "\t\tvec2 pt = (paintMat * vec3(fpos,1.0)).xy / extent;\n"
      "#ifdef NANOVG_GL3\n"
      "\t\tvec4 color = texture(tex, pt);\n"
      "#else\n"
      "\t\tvec4 color = texture2D(tex, pt);\n"
      "#endif\n"
      "\t\tif (texType == 1) color = vec4(color.xyz*color.w,color.w);"
      "\t\tif (texType == 2) color = vec4(color.x);"
      "\t\tcolor *= innerCol;\n"
      "\t\tcolor *= strokeAlpha * scissor;\n"
      "\t\tresult = color;\n"
      "\t} else if (type == 2) {\n"
      "\t\tresult = vec4(1,1,1,1);\n"
      "\t} else if (type == 3) {\n"
      "#ifdef NANOVG_GL3\n"
      "\t\tvec4 color = texture(tex, ftcoord);\n"
      "#else\n"
      "\t\tvec4 color = texture2D(tex, ftcoord);\n"
      "#endif\n"
      "\t\tif (texType == 1) color = vec4(color.xyz*color.w,color.w);"
      "\t\tif (texType == 2) color = vec4(color.x);"
      "\t\tcolor *= scissor;\n"
      "\t\tresult = color * innerCol;\n"
      "\t}\n"
      // --- MODIFIED ClearType branch ---
      "  else if ( type == 4 )\n"
      "  {\n"
      "#ifdef NANOVG_GL3\n"
      "     vec4 color = texture(tex, ftcoord);\n"
      "#else\n"
      "     vec4 color = texture2D(tex, ftcoord);\n"
      "#endif\n"
      "     float deriv = dFdx( ftcoord.x );\n"
      "     if( deriv < 0.0 )\n"
      "        color.xz = color.zx;\n"
      "     else if ( deriv == 0.0 )\n"
      "        color = vec4( ( color.x + color.y + color.z ) * ( 1.0 / 3.0 ) );\n"
      "\n"
      "     if( color.w * scissor * innerCol.w < ( 1.0 / 256.0 ) )\n"
      "        discard;\n"
      "\n"
      "     // Premultiplied output — let GL blend against real framebuffer\n"
      "     result.xyz = color.xyz * innerCol.xyz;\n"
      "     result.w = max(color.x, max(color.y, color.z)) * innerCol.w;\n"
      "     result *= scissor;\n"
      "  }\n"
      "  else if ( type == 5 )\n"
      "  {\n"
      "#ifdef NANOVG_GL3\n"
      "     vec4 color = texture(tex, ftcoord);\n"
      "#else\n"
      "     vec4 color = texture2D(tex, ftcoord);\n"
      "#endif\n"
      "     result = color * scissor * innerCol.a;\n"
      "  }\n"
      "#ifdef NANOVG_GL3\n"
      "\toutColor = result;\n"
      "#else\n"
      "\tgl_FragColor = result;\n"
      "#endif\n"
      "}\n";

   if( gl->flags & NVG_ANTIALIAS)
   {
      if( ! glnvg__createShader( &s_nvggl__altShader, "alt_shader", shaderHeader, "#define EDGE_AA 1\n", fillVertShader, altFragShader))
         return( 0);
   }
   else
   {
      if( ! glnvg__createShader( &s_nvggl__altShader, "alt_shader", shaderHeader, NULL, fillVertShader, altFragShader))
         return( 0);
   }
   glnvg__getUniforms( &s_nvggl__altShader);
   s_nvggl__altShaderReady = 1;
   return( 1);
}


void  nvggl__useAlternateShader( NVGcontext *ctx, int use)
{
   GLNVGcontext        *gl = (GLNVGcontext *) nvgInternalParams( ctx)->userPtr;
   static GLNVGshader   savedShader;

   if( use)
   {
      savedShader = gl->shader;
      gl->shader  = s_nvggl__altShader;
   }
   else
   {
      gl->shader = savedShader;
   }
}


// Query if GL_EXT_shader_framebuffer_fetch or GL_NV_shader_framebuffer_fetch
// is available
int  nvggl__hasFramebufferFetch( void)
{
   const char  *extensions = (const char *) glGetString( GL_EXTENSIONS);

   if( ! extensions)
      return( 0);
   if( strstr( extensions, "GL_EXT_shader_framebuffer_fetch"))
      return( 1);
   if( strstr( extensions, "GL_NV_shader_framebuffer_fetch"))
      return( 2);
   return( 0);
}
