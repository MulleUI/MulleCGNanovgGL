<!-- keywords: MulleCGNanovgGL, quirks, line breaking, visual bounds, framebuffer, MSAA, shader -->

# Quirks

## Backend/bootstrap quirks

- `CGNanoVGBackendFunctionTable` is the only repo-local exported hook. If you change framebuffer behavior, keep the table and the `_initNanovg` assignment in sync.
- Do not create or destroy NanoVG font/context objects outside the existing locked paths in `src/CGContext+nanovg-gl.m`; both font init and graphics init are wrapped by `CGLayoutContextFreeTypeLock`.
- On Windows the GL loader runs only for drawing contexts. `NVG_FONT_ONLY` and `NVG_NO_DRAWING` skip that path.

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

## Shader quirks

- If a shader source already starts with `#version`, the backend will not prepend one. If it does not, the backend injects the version that matches the active NanoVG backend.
- The local uniform parser is token-based. It only understands simple `uniform ...;` declarations and is not a full GLSL parser.
