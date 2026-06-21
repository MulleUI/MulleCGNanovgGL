<!-- keywords: MulleCGNanovgGL, debugger, quirks, line breaking, framebuffer, shader -->

# Quirks

## Scope quirks

- `src/MulleCGNanovgGL.h` is almost empty import glue. Real debugging usually starts in tests or backend categories, not there.
- `test/10-first/noleak.m` is only a package smoke test. It does not prove text, framebuffer, or shader behavior.

## Backend/bootstrap quirks

- The GL function-table wrappers in `src/CGBackendFunctionTable+nanovg.m` ignore `ctx` on purpose; that is only to satisfy the `CGBackendFunctionTable` signature.
- `_initNanovg` in `src/CGContext+nanovg-gl.m` must assign `_cgBackend.backendFunctions = CGNanoVGBackendFunctionTable` after context creation. A non-null `_cgBackend.context` alone is not enough.
- Font and NanoVG context create/delete paths are wrapped by `CGLayoutContextFreeTypeLock`; moving them outside that lock changes behavior.
- On Windows the GL loader path is skipped for `NVG_NO_DRAWING` and `NVG_FONT_ONLY`.

## Text/layout quirks

- Empty lines are real rows here. `test/01-nogl/breaklines.m` expects `"\n  Ahoi! \n \n"` to yield three rows.
- If you extend row storage, `struct UITextRow` must stay first and `textRowSize` must be the real stride. `test/01-nogl/breaklines-tricky.m` and `test/01-nogl/breaklines-tricky2.m` are the contract.
- `visualBoundsOfText:` intentionally keeps the remaining one-pixel anti-aliasing border described in `test/50-layoutcontext/cglayoutcontext.m`; do not "fix" it by trimming more.
- `test/50-layoutcontext/multiline.m` only exercises `NSLineBreakByWordWrapping`; other modes are not the local reference path.

## GPU/framebuffer quirks

- Unsupported `CGFramebufferBitmapType` values return an empty `struct CGBitmap` and only emit a debug stderr message in debug builds.
- `glGetTexImage` is not the universal readback path. GLES and GL core-profile code fall back to framebuffer attachment plus `glReadPixels`, with MSAA resolve first when needed.
- `barrier` in `src/gpu/CGContext+GPU-opengl.m` deliberately uses `glFinish()`.
- `src/gpu/CGFramebuffer+GPU-opengl.m` relies on `_endFBRender:` to restore viewport state and flush the frame; bypassing that helper changes behavior.

## Shader quirks

- If a shader source already begins with `#version`, the backend does not prepend another one.
- Uniform parsing in `src/gpu/CGContext+GPUShader-opengl.m` is token-based and only understands simple `uniform type name;` declarations.
