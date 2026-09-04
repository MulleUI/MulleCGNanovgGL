<!-- keywords: MulleCGNanovgGL, patterns, CGNanoVGBackendFunctionTable, text layout, framebuffer, shaders -->

# Patterns

## Import the umbrella header when you only need this package wired in

- `test/10-first/noleak.m` is the minimal consumer shape: import `<MulleCGNanovgGL/MulleCGNanovgGL.h>` and then use the normal `MulleCG` / `MulleUI` surfaces supplied by dependencies.
- Do not expect many repo-local declarations from the umbrella header itself; the local addition is mainly the NanoVG backend glue.

```objc
#import <MulleCGNanovgGL/MulleCGNanovgGL.h>
```

## Wire the NanoVG backend through the function table

- Use `CGNanoVGBackendFunctionTable` as the handoff point from `CGContext` to backend-specific framebuffer operations.
- Keep OpenGL wrappers thin and signature-only. In `src/CGBackendFunctionTable+nanovg.m` the GL bind/delete helpers ignore `ctx` only because the table requires that shape.
- Set `_cgBackend.backendFunctions` after the NanoVG context exists; `src/CGContext+nanovg-gl.m` does this in `_initNanovg`.

```objc
_cgBackend.context = nvgCreateGL3( _cgBackend.flags);
_cgBackend.backendFunctions = CGNanoVGBackendFunctionTable;
```

## Use `CGLayoutContext` tests as the happy path for text work

- Start with a fresh layout context, select a font, set size, then set combined alignment before asking for bounds or rows.
- `test/50-layoutcontext/cglayoutcontext.m` is the reference for `getTextBounds:`, `visualBoundsOfText:length:`, and `getGlyphPositions:count:text:length:`.
- `test/50-layoutcontext/multiline.m` is the reference for multiline row breaking.

```objc
context = [CGLayoutContext instance];
[context useDefaultFont];
[context setFontSize:16.0f];
[context setCombinedTextAlignment:CGTextAlignLeft | CGTextAlignMiddle];

n = [context getTextRows:rows
                   count:8
             textRowSize:sizeof( struct UITextRow)
                    text:text
                  length:(NSUInteger) -1
           breakRowWidth:100.0];
```

## Allow extended row structs, but keep `UITextRow` first

- The `breaklines-tricky` tests show the supported extension pattern: embed `struct UITextRow` as the first member, pass the real stride as `textRowSize`, and cast the buffer to `struct UITextRow *` when calling.
- This is the local way to attach per-row side data without changing the row-breaking API.

```objc
struct MyUITextRow
{
   struct UITextRow   inherit;
   unsigned long long extra;
};

n = CGContextTextBreakLines( context, text, -1, INFINITY,
                             (struct UITextRow *) rows,
                             3,
                             sizeof( struct MyUITextRow));
```

## Read back pixels through the existing helpers

- For the current framebuffer, prefer `readFramebufferBitmap:framebufferBitmapType:allocator:` or the convenience `framebufferBitmap`.
- For images, use `RGBABytesBitmapOfImage:allocator:` instead of adding direct GL readback code; the backend already handles GLES/core-profile/MSAA cases.
- When blitting a non-multisample image into the current target, the repo path is `drawRect:options:context:` wrapped in save/copy/restore. Multisample images go through the framebuffer blit path in `src/gpu/CGContext+GPU-opengl.m`.

## Let the backend supply the shader version header

- In `src/gpu/CGContext+GPUShader-opengl.m`, shader compilation prepends the backend-specific `#version` header only when your source does not already have one.
- That makes simple backend-local shaders easier to write; omit `#version` unless you need a deliberate override.
- Keep `uniform` declarations plain `uniform type name;` if you want the simple local uniform parser to see them.

## Create a path-only context for offline tessellation

- Use `[CGContextBase pathContext]` (`src/CGContext+nanovg-gl.m:276`) when you need NanoVG path operations without a GL drawing surface.
- The resulting `CGContext` uses `NVG_PATH_ONLY` and has no backend function table (`.backendFunctions = NULL`).
- This is useful for path hit testing, bounding box queries, or serialization before real rendering.

```objc
CGContext   *pathContext;

pathContext = [CGContextBase pathContext];
// use [pathContext beginPath] etc.
```

## Check backend errors after raw GL calls

- Use `CGContextCheckBackendError( self, "label")` or `[self assertNoBackendError:"label"]` after explicit GL calls in repo code.
- The error check glGetError and log GL_INVALID_* errors to stderr with backend name, symbolic error, hex code, and the human string.
- The check returns early if `_backend == UIGraphicsBackendNone` so it is safe in code paths that may run without a live context.

```objc
glGenFramebuffers( 1, &fbo);
CGContextCheckBackendError( self, "glGenFramebuffers");
```
