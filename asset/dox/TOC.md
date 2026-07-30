# MulleCGNanovgGL Library Documentation for AI
<!-- Keywords: nanovg, opengl, gles, gpu, backend, framebuffer, shader -->
## 1. Introduction & Purpose

MulleCGNanovgGL is the **OpenGL/GPU backend provider** for the MulleCGNanovg
vector graphics library. It contains all GPU-specific initialization,
rendering, framebuffer management, shader compilation, and error-checking code
that decouples the high-level `MulleCGNanovg` API from specific graphics APIs.

Key features:
- Creates and tears down NanoVG contexts for **GL3, GLES2, GLES3, D3D11, and Metal** backends
- Provides `CGNanoVGBackendFunctionTable` mapping backend-specific framebuffer operations
- Implements GL framebuffer rendering, readback, viewport, and barrier operations
- Compiles and links OpenGL/GLES shader programs from source strings
- Implements fullscreen quad image-effect rendering with custom shaders
- WIN32 GLAD function-pointer loading for OpenGL context initialization
- NanoVG GL shader extensions (alternate ClearType shader, framebuffer-fetch)
- OpenGL error checking with human-readable error translation

Depends on `MulleCGNanovg` and `mulle-objc-list`, and is part of the MulleCG
vector graphics stack.

## 2. Key Concepts & Design Philosophy

**Backend abstraction:** This library bridges the gap between `MulleCGNanovg`'s
abstract rendering API and concrete GPU APIs. All GPU-specific code lives in
Objective-C categories on `CGContext`, `CGLayoutContext`, and `CGFramebuffer`.

**Multi-backend support:** Compile-time selection via `MULLE_CG_BACKEND_OPENGL`,
`MULLE_CG_BACKEND_D3D11`, or `MULLE_CG_BACKEND_METAL` determines which NanoVG
implementation is linked. Within OpenGL, further selection via
`NANOVG_GL3_IMPLEMENTATION`, `NANOVG_GLES2_IMPLEMENTATION`, or
`NANOVG_GLES3_IMPLEMENTATION` picks the GL version.

**Function table pattern:** The `CGBackendFunctionTable` struct stores
backend-specific function pointers (create/delete/bind framebuffer, texture ID
query) so the core library can invoke backend operations without knowing which
GPU API is active.

**Font context sharing:** A `CGLayoutContext` (font-only NanoVG context) can be
created independently via `createPathContext` or `_initFontNanovg`, and
protected by a FreeType mutex for thread safety.

**Assertion-based enum mapping:** Compile-time `MULLE_C_ASSERT` macros verify
that `MulleCGNanovg` constants (blend factors, composite ops, text align, etc.)
match NanoVG's constants exactly, allowing direct casting between the two.

**Categories are the API surface:** Public API is exposed through Objective-C
categories. No standalone C functions compose the public interface (aside from
the `CGBackendFunctionTable` global and the `nvggl__*` shader extension
functions).

## 3. Core API & Data Structures

### 3.1. `CGBackendFunctionTable+nanovg.h`

#### `CGBackendFunctionTable CGNanoVGBackendFunctionTable`
- **Purpose:** A global, pre-populated function table providing backend-specific framebuffer operations. The core library invokes these through a function-pointer indirection so it never calls GL/D3D/Metal directly.
- **Fields in the table (read-only):**
  | Field | Signature | Purpose |
  |-------|-----------|---------|
  | `createFramebuffer` | `void *(*)(void *, int, int, int)` | Create a GPU framebuffer object (GL: `nvgluCreateFramebuffer`, D3D: `d3dnvgCreateFramebuffer`, Metal: `mnvgCreateFramebuffer`) |
  | `deleteFramebuffer` | `void (*)(void *, void *)` | Destroy a GPU framebuffer object |
  | `bindFramebuffer` | `void (*)(void *, void *)` | Bind framebuffer for drawing |
  | `bindDrawFramebuffer` | `void (*)(void *, void *)` | Bind framebuffer specifically as draw target |
  | `framebufferTextureID` | `int (*)(void *, void *)` | Extract the texture ID from a framebuffer object |

### 3.2. `CGContext+ImageEffect.h` — Category `CGContext(ImageEffectFuture)`

Implements fullscreen quad image-effect rendering using a custom OpenGL shader.

```objc
- (CGImage *) imageByRenderingImage:(CGImage *) image
                         withShader:(CGShaderID) shader
                           uniforms:(struct CGUniform *) uniforms
                              count:(NSUInteger) count;
```
Renders `image` through `shader` on a fullscreen quad into a new framebuffer-backed image. Applies the given uniforms.

```objc
- (CGImage *) imageByRenderingImage:(CGImage *) image
                         withShader:(CGShaderID) shader
                      setupCallback:(CGShaderSetupCallback *) setup
                           userInfo:(void *) info;
```
Same but uses a setup callback instead of a uniform array. The callback receives `(shader, userInfo)` after the shader is bound and before the quad is drawn.

### 3.3. `CGContext+nanovg-gl.m` — Multiple Categories

#### Category `CGContext(nanovgGLInit)` — NanoVG Context Lifecycle

```objc
- (void) _initNanovg;
```
Creates the NanoVG rendering context (`nvgCreateGL3/GLES2/GLES3/D3D11`) with backend flags. On WIN32 calls `mulle_glad_load_gl()` first. Sets `_cgBackend.backendFunctions = CGNanoVGBackendFunctionTable`.

```objc
- (void) _doneNanovg;
```
Destroys the NanoVG context (`nvgDeleteGL3/GLES2/GLES3/D3D11`).

```objc
- (void) _doneGraphicsBackend;
```
Calls `_doneNanovg`.

#### Category `CGLayoutContext(OpenGL)` — Font Context Lifecycle

```objc
- (void) _initFontNanovg;
```
Creates a font-only NanoVG context (`nvgCreateGL3/GLES2/GLES3/D3D11` with `NVG_FONT_ONLY` flag) under a FreeType mutex. Stores in `_fontContext`.

```objc
- (void) _doneFontBackend;
```
Destroys the font context (`nvgDeleteGL3/GLES2/GLES3`) under the FreeType mutex. Only destroys if `_ownsFontContext` is YES.

#### Category `CGContext(nanovgGL)` — Backend Info & Init

```objc
+ (BOOL) supportsAntiAliasing;
```
Returns YES if compiled with `NANOVG_HAVE_MSAA`.

```objc
+ (char *) nanoVGBackendUTF8String;
```
Returns a human-readable string for the active backend: `"OpenGL v3.2+"`, `"GLES v2.0+"`, `"GLES v3.2+"`, or `"Direct3D 11"`.

```objc
+ (CGContextNanoVGBackend) nanoVGBackend;
```
Returns the enum value: `CG_GL3_2`, `CG_GLES2`, `CG_GLES3_2`, or `CG_D3D11`.

```objc
- (char *) nanovgInfoUTF8String;
```
Returns a dynamically allocated string describing the NanoVG context capabilities (backend + flags like EdgeAA, ClearType, Stencil, MSAA). Caller must free.

```objc
- (void) _initNanoVGWithGraphicsOptions:(UIGraphicsOptions) options
                         nameUTF8String:(char *) nameUTF8String;
```
Maps `UIGraphicsOptions` flags to NanoVG flags (`NVG_ANTIALIAS`, `NVG_STENCIL_STROKES`, `NVG_CLEARTYPE`, `NVG_NO_DRAWING`, `NVG_PATH_ONLY`, `NVG_MSAA`). Calls `_initGraphicsBackend`. Sets up trace names. Builds `_framebufferBits` for GL clear operations.

```objc
- (void *) gpuTextureForImageID:(NSInteger) textureID;
```
Returns the GPU-native texture handle (GLuint as `void *`) for a NanoVG image ID via `nvglImageHandleGL3/GLES2/GLES3`.

```objc
- (struct CGBitmap) RGBABytesBitmapOfImage:(CGImage *) image
                                  allocator:(struct mulle_allocator *) allocator;
```
Reads back the RGBA bytes of a NanoVG image. On GLES2/GLES3 uses glReadPixels with a temporary framebuffer (since glGetTexImage is unavailable). On desktop GL, tries glGetTexImage in compatibility profile, falls back to framebuffer readback with MSAA resolve in core profile.

```objc
- (struct CGBitmap) readFramebufferBitmap:(CGPixelRect) rect
                    framebufferBitmapType:(CGFramebufferBitmapType) fType
                                allocator:(struct mulle_allocator *) allocator;
```
Reads back framebuffer pixels via `glReadPixels`. Supports: `CGFramebufferRGBABytes` (GL_RGBA/GL_UNSIGNED_BYTE), `CGFramebufferRGBAFloats` (GL_RGBA/GL_FLOAT), `CGFramebufferStencilFloats` (GL_STENCIL_INDEX) and `CGFramebufferDepthFloats` (GL_DEPTH_COMPONENT) — the last two only on desktop GL.

#### Category `CGContext(Errors)` — GL Error Checking

```objc
- (void) _checkBackendError:(char *) str;
```
Checks `glGetError()`. On error, prints a descriptive message (max 50 times). Uses `_CGNVGBackendErrorShortUTF8String` and `_CGNVGBackendErrorUTF8String` for human-readable GL error codes.

```objc
- (BOOL) resetBackendError;
```
Drains all pending `glGetError()` errors. Returns YES if any errors were present.

```objc
- (void) assertNoBackendError:(char *) str;
```
Same as `_checkBackendError:`.

#### Category `CGContextBase(nanovgGL)` — Path Context Factory

```objc
+ (CGContext *) createPathContext;
```
Creates a path-only NanoVG context (via `nvgCreateGL3/GLES2/GLES3` with `NVG_PATH_ONLY`) and wraps it in a `CGContext` via `_initAsPathContext` with `CGNanoVGFunctionTable` and no backend function table.

### 3.4. `src/gpu/CGContext+GPU-opengl.m` — Category `CGContext(GPU)`

GL framebuffer, viewport, blit, and barrier operations.

```objc
- (CGPixelSize) bitmapSizeOfFramebuffer:(struct CGContextFramebuffer) fb;
```
Returns the pixel size for a given framebuffer. Dispatches by framebuffer type (default, layer, OpenGL, MSAA variants).

```objc
- (NSUInteger) framebufferBitsWithColorBit:(BOOL) flag;
```
Returns `_framebufferBits` optionally OR'd with `GL_COLOR_BUFFER_BIT`.

```objc
- (void) clearFramebufferBits:(NSUInteger) bits color:(CGColor) color;
```
Calls `glClearColor` and `glClear` with the given bitmask.

```objc
- (void) clearFramebufferNoColor;
```
Clears non-color framebuffer bits only.

```objc
- (void) _changeRenderGPU:(struct CGFrameInfo *) info;
```
Sets `glViewport` from the frame info.

```objc
- (CGPixelRect) viewport;
```

```objc
- (void) setViewport:(CGPixelRect) rect;
```
GL viewport get/set (cached in `_viewport`).

Additional internal methods for `glBlitFramebuffer`, `glFlush`, `glFinish`, `glMemoryBarrier`, and default/layer framebuffer size queries.

### 3.5. `src/gpu/CGContext+GPUShader-opengl.m` — Category `CGContext(GPUShader)`

OpenGL/GLES shader program compilation and linking.

```objc
void CGShaderUTF8SourcesParseUniforms(struct CGShaderUTF8Sources *sources,
                                       struct mulle_assoc *assoc);
```
Parses `uniform` declarations from shader sources and populates a `mulle_assoc` mapping uniform names to types.

Internal methods handle: shader compilation (`glCreateShader`, `glShaderSource`, `glCompileShader`), program linking (`glCreateProgram`, `glAttachShader`, `glLinkProgram`), uniform queries, error logging via `glGetShaderInfoLog`/`glGetProgramInfoLog`, and shader/program deletion.

### 3.6. `src/gpu/CGFramebuffer+GPU-opengl.m` — Category `CGFramebuffer(OpenGL)`

GL framebuffer render begin/end.

```objc
- (void) beginFBRenderWithBackgroundColor:(CGColor) color
                         devicePixelRatio:(CGFloat) ratio
                          layerRenderInfo:(struct CGFramebufferRenderInfo *) memo;
```
Sets up an offscreen GL framebuffer for rendering: binds the framebuffer, calls `glClear` with the background color, sets `glViewport` to the bitmap size, and calls `_didBeginFBRenderWithBitmapSize:devicePixelRatio:`.

```objc
- (void) endFBRender:(struct CGFramebufferRenderInfo *) memo;
```
Finishes offscreen rendering: calls `_willEndFBRender:memo`, then `_endFBRender:memo` which resets the viewport and flushes NanoVG.

### 3.7. `src/glad/mulle_glad_load.h`

```objc
int   mulle_glad_load_gl( void);
```
WIN32 only. Loads all GL function pointers via `wglGetProcAddress` using GLAD. Must be called after a GL context is made current. Returns the GL version on success, 0 on failure.

### 3.8. `src/glad/gl.h`

GLAD-generated header providing OpenGL 3.3 compatibility-profile function pointer types, macros, and constants. Header-only mode (no loader implementation). Includes extensions: `GL_ARB_multisample`, `GL_ARB_robustness`, `GL_KHR_debug`. Included on WIN32 instead of platform GL headers.

### 3.9. `src/nanovg_gl-extensions.inc`

NanoVG GL shader extension functions:

```objc
int   nvggl__createAlternateShader( NVGcontext *ctx);
```
Creates an alternate ClearType shader with premultiplied alpha output. The modified `type==4` branch outputs `result.xyz = color.xyz * innerCol.xyz` and `result.w = max(color.x, max(color.y, color.z)) * innerCol.w` — letting GL blend against the real framebuffer instead of blending against `outerCol` in the shader.

```objc
void  nvggl__useAlternateShader( NVGcontext *ctx, int use);
```
Swaps the active NanoVG shader with the alternate ClearType shader. Swaps back when `use` is 0.

```objc
int   nvggl__hasFramebufferFetch( void);
```
Queries `glGetString(GL_EXTENSIONS)` for `GL_EXT_shader_framebuffer_fetch` or `GL_NV_shader_framebuffer_fetch`. Returns 0 if not available, 1 for EXT, 2 for NV.

### 3.10. `MulleObjCDeps+MulleCGNanovgGL.h`

```objc
@interface MulleObjCDeps( MulleCGNanovgGL)
+ (struct _mulle_objc_dependency *) dependencies;
@end
```
Standard mulle-objc dependency declaration. Required for proper classloader ordering.

## 4. Performance Characteristics

- **Context creation:** O(1) — a single call to `nvgCreateGL3/GLES2/GLES3/D3D11`. GLAD loading on WIN32 adds O(n) where n is the number of GL extension functions.
- **Font context creation:** O(1), serialized via `CGLayoutContextFreeTypeLock` mutex.
- **Framebuffer readback:** O(w * h) pixel copies via `glReadPixels`. On GLES, MSAA framebuffers require a `glBlitFramebuffer` resolve step before readback.
- **Shader compilation:** O(source length) — synchronous GL shader compile + link. Cached results via the NanoVG GL context (shaders are created once per context).
- **Image effect rendering:** O(1) — single fullscreen quad draw call.
- **Thread safety:** Font context creation/destruction is protected by `CGLayoutContextFreeTypeLock`. General rendering is NOT thread-safe and should occur on the GL context's thread.
- **Error checking:** `_checkBackendError:` calls `glGetError()` on every invocation, rate-limited to 50 prints to avoid spam.

## 5. AI Usage Recommendations & Patterns

- **Best Practices:**
  - Do not call `_initNanovg` or `_doneNanovg` directly. These are called internally by the CGContext lifecycle (`_initNanoVGWithGraphicsOptions:nameUTF8String:`).
  - Use `+[CGContextBase createPathContext]` to obtain a path-only CGContext for text layout without a full rendering context.
  - For framebuffer readback, prefer `RGBABytesBitmapOfImage:allocator:` if you need CPU-side RGBA pixels. The returned `struct CGBitmap` owns its memory via the given allocator; free it with `mulle_allocator_free`.
  - When writing custom image-effect shaders, use `imageByRenderingImage:withShader:setupCallback:userInfo:` for flexibility beyond simple uniforms.
  - Always check for `CGImageFlagNearest` when rendering with image effects — the implementation forces `GL_NEAREST` during the effect pass and restores the original filter afterward.

- **Common Pitfalls:**
  - Do not access `_cgBackend`, `_fontContext`, `_backendFlags`, or `_framebufferBits` directly. These are internal ivars managed by the categories.
  - Do not call `CGNanoVGBackendFunctionTable` functions directly. The table is consumed by MulleCGNanovg internals via `CGContextBFN(self)->...` macros.
  - The `createPathContext` factory method creates a context without a `CGBackendFunctionTable` (passes NULL). Path-only contexts cannot render framebuffers.
  - `_checkBackendError:` asserts `err == GL_NO_ERROR` after its rate-limited print window. In debug builds, this aborts the process.
  - `RGBABytesBitmapOfImage:allocator:` adds 16 bytes of padding to the allocation to work around an NVIDIA bug. Do not rely on exact allocation size.

- **Idiomatic Usage:**
  - Create a full rendering CGContext with `[[CGContext alloc] initWithOSGraphicsContext:window shareID:0 options:options] autorelease]`.
  - Create a font-only context via `+[CGContextBase createPathContext]`.
  - Render to a framebuffer with `beginFBRenderWithBackgroundColor:devicePixelRatio:layerRenderInfo:` / `endFBRender:`.
  - Apply a post-processing shader with `imageByRenderingImage:withShader:setupCallback:userInfo:`.

## 6. Integration Examples

### Example 1: Creating a Path-Only Context for Text Layout

```c
#import <MulleCGNanovgGL/MulleCGNanovgGL.h>

int   main( int argc, char *argv[])
{
   CGLayoutContext   *context;
   CGRect            bounds;

   @autoreleasepool
   {
      context = [CGLayoutContext instance];
      [context useDefaultFont];
      [context setFontSize:16.0f];
      [context getTextBounds:&bounds
                        text:"VfL Bochum 1848"
                      length:(NSUInteger) -1];
      printf( "%s\n", CGRectUTF8String( bounds));
   }
   return( 0);
}
```

### Example 2: Applying an Image Effect with a Custom Shader

```c
#import <MulleCGNanovgGL/MulleCGNanovgGL.h>

static void   blurSetup( CGShaderID shader, void *userInfo)
{
   CGFloat   *radius = (CGFloat *) userInfo;
   GLint     loc;

   loc = glGetUniformLocation( (GLuint) (uintptr_t) shader, "u_blurRadius");
   glUniform1f( loc, *radius);
}

int   main( int argc, char *argv[])
{
   CGContext    *context;
   CGImage      *inputImage;
   CGImage      *outputImage;
   CGShaderID   blurShader;
   CGFloat      radius;

   @autoreleasepool
   {
      context    = ...;
      inputImage = ...;
      blurShader = ...; // previously compiled GL shader program
      radius     = 2.0;

      outputImage = [context imageByRenderingImage:inputImage
                                        withShader:blurShader
                                     setupCallback:blurSetup
                                          userInfo:&radius];
   }
   return( 0);
}
```

### Example 3: Reading Back Pixels from a Rendered Image

```c
#import <MulleCGNanovgGL/MulleCGNanovgGL.h>

int   main( int argc, char *argv[])
{
   CGContext       *context;
   CGImage         *image;
   struct CGBitmap bitmap;

   @autoreleasepool
   {
      context = ...;
      image   = ...;

      bitmap = [context RGBABytesBitmapOfImage:image
                                     allocator:NULL];
      if( bitmap.bytes)
      {
         // bitmap.info has CGPixelSize and encoding
         // bitmap.bytes is RGBA data (malloc'd, caller must free)
         mulle_allocator_free( bitmap.allocator, bitmap.bytes);
      }
   }
   return( 0);
}
```

## 7. Dependencies

- `MulleCGNanovg` — Core NanoVG vector graphics library (provides CGContext, CGLayoutContext, CGFramebuffer base classes and the NanoVG C library)
- `mulle-objc-list` — ObjC list utility (no-link, no-header; used internally)

Transitive dependencies (via MulleCGNanovg):
- `mulle-nanovg` — The NanoVG C rendering library
- `MulleCG` — MulleCG core graphics types and protocols
- `mulle-objc` — The mulle-objc runtime
- `mulle-c11` — C11 compatibility and utility headers
