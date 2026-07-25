<!-- keywords: MulleCGNanovgGL, quirks, line breaking, visual bounds, framebuffer, MSAA, shader -->

# Quirks

## Backend/bootstrap quirks

- `CGNanoVGBackendFunctionTable` is the only repo-local exported hook. If you change framebuffer behavior, keep the table and the `_initNanovg` assignment in sync.
- Do not create or destroy NanoVG font/context objects outside the existing locked paths in `src/CGContext+nanovg-gl.m`; both font init and graphics init are wrapped by `CGLayoutContextFreeTypeLock`.
- On Windows the GL loader runs only for drawing contexts. `NVG_FONT_ONLY` and `NVG_NO_DRAWING` skip that path.
- A `DEBUG` build unconditionally sets `NVG_DEBUG` in both font-only and drawing NanoVG context flags (`src/CGContext+nanovg-gl.m:43-46`, `src/CGContext+nanovg-gl.m:452-454`), and prints the context name and backend info string at init.
- `_initNanoVGWithGraphicsOptions:nameUTF8String:` (`src/CGContext+nanovg-gl.m:372`) asserts that all MulleCG enum values match their NanoVG counterparts (composite ops, blend factors, line caps, text alignment, image flags, tessellation modes, winding directions). If a new enum value is added to `MulleCG` without a corresponding NanoVG entry, these assertions fail.
- The `_checkBackendError:` helper (`src/CGContext+nanovg-gl.m:220`) returns early when `_backend == UIGraphicsBackendNone`, so GL error checks are harmless in path-only or font-only contexts.

## Text/layout quirks

- Empty lines are real rows here. `test/01-nogl/breaklines.m` shows that `"\n  Ahoi! \n \n"` yields three rows, including empty first and last rows.
- If you use a larger row struct, `struct UITextRow` must stay first and `textRowSize` must match the real stride. The `breaklines-tricky` tests are the contract.
- `test/50-layoutcontext/multiline.m` only exercises `NSLineBreakByWordWrapping`, and the source comment says that is the only supported mode currently.
- Do not manually shrink `visualBoundsOfText:` to “remove padding”. The comment block in `test/50-layoutcontext/cglayoutcontext.m` explains that one anti-aliasing pixel is intentionally still represented in the NanoVG visual bounds.

## GPU/framebuffer quirks

- `readFramebufferBitmap:framebufferBitmapType:allocator:` only supports RGBA bytes/floats everywhere, plus stencil/depth float readback on non-GLES builds. Unsupported bitmap types return an empty bitmap.
- Do not assume `glGetTexImage` is available. The backend falls back to framebuffer attachment plus `glReadPixels`, and resolves multisample textures first when needed.
- `barrier` uses `glFinish()`. That is deliberate here to make shared textures stable; replacing it with a weaker sync primitive changes behavior.
- `src/gpu/CGFramebuffer+GPU-opengl.m` relies on `_endFBRender:` to restore viewport state and flush the frame. Do not bypass that helper when touching framebuffer render flow.
- The `_framebufferBits` ivar is set during `_initNanoVGWithGraphicsOptions:nameUTF8String:` (`src/CGContext+nanovg-gl.m:490`): `GL_COLOR_BUFFER_BIT` always, plus `GL_STENCIL_BUFFER_BIT` when `UIGraphicsUseStencilStrokes` is set. It is used by `clearFramebufferBits:color:` and `framebufferBitsWithColorBit:` in `src/gpu/CGContext+GPU-opengl.m`. Changing framebuffer clear behavior requires updating `_framebufferBits`.
- `NVG_MSAA` flag is only set when `UIGraphicsUseMSAA` is present **and** the backend is GL3 or GLES3 (`src/CGContext+nanovg-gl.m:457`). On GLES2 builds `NVG_MSAA` is never set.

## Shader quirks

- If a shader source already starts with `#version`, the backend will not prepend one. If it does not, the backend injects the version that matches the active NanoVG backend.
- The local uniform parser is token-based. It only understands simple `uniform ...;` declarations and is not a full GLSL parser.
