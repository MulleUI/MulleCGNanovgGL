<!-- keywords: CGBackendFunctionTable, NanoVG, CGLayoutContext, framebuffer, shader, ImageEffect, pathContext -->

# mulle-cg-nanovg-gl

Use this topic when you are changing the local NanoVG/OpenGL backend glue in this repo, or when a fix touches the text/layout and GPU behavior that this backend contributes to `MulleCG`.

## Understand first

```bash
mulle-sde api apropos nanovg
mulle-sde api apropos CGContext
mulle-sde api apropos CGLayoutContext
mulle-sde code search CGNanoVGBackendFunctionTable
mulle-sde code search pathContext
mulle-sde code search readFramebufferBitmap
mulle-sde code search CGContextCheckBackendError
```

## Main local surfaces

| Scenario | Use | Local refs |
| --- | --- | --- |
| Wire or change the backend hooks | `CGNanoVGBackendFunctionTable` and the NanoVG context init path | `src/CGBackendFunctionTable+nanovg.h`, `src/CGBackendFunctionTable+nanovg.m`, `src/CGContext+nanovg-gl.m` |
| Debug text metrics, line breaking, or glyph bounds | `CGLayoutContext` as exercised by the no-GL and layout tests | `test/01-nogl/breaklines.m`, `test/01-nogl/breaklines-tricky.m`, `test/01-nogl/breaklines-tricky2.m`, `test/50-layoutcontext/cglayoutcontext.m`, `test/50-layoutcontext/multiline.m` |
| Debug image, framebuffer, or shader behavior | `CGContext` OpenGL categories and framebuffer helpers | `src/gpu/CGContext+GPU-opengl.m`, `src/gpu/CGFramebuffer+GPU-opengl.m`, `src/gpu/CGContext+GPUShader-opengl.m`, `test/60-context/cgcontext-framebuffer.m` |
| Apply image effects (desaturation, etc.) | `CGContext(ImageEffectFuture)` protocol implementation | `src/CGContext+ImageEffect.h`, `src/CGContext+ImageEffect.m` |
| Create a path-only offline context | `pathContext` class method on `CGContextBase` | `src/CGContext+nanovg-gl.m` (line 276), uses `NVG_PATH_ONLY` |

## Local delta

- `src/MulleCGNanovgGL.h` is a thin umbrella; the only repo-local exported C surface is the backend table in `src/CGBackendFunctionTable+nanovg.h`.
- Most user-facing drawing APIs still come from `MulleCG`, but this repo changes how those APIs behave on NanoVG/OpenGL: context setup, framebuffer plumbing, image readback, shader source handling, and text metrics.
- `src/CGContext+ImageEffect.h` is a thin implementation of the `CGContext(ImageEffectFuture)` protocol; it exists mainly so `mulle-sde reflect` picks up the `.m` file.
- `pathContext` (on `CGContextBase`) creates a path-only NanoVG context without a GL drawing surface, useful for offline path tessellation.
- Treat `CGLayoutContext` and `CGContext` tests here as the best local spec. The repo README is generic; the tests are where the backend-specific expectations live.

## Primary local workflow

1. Start from the relevant family above.
2. Read the paired test before changing code; the tests here are short and usually encode the real invariant.
3. Keep backend glue thin: wrapper functions only when the NanoVG/OpenGL signature does not match `CGBackendFunctionTable`.
4. Re-run the narrow tests that match the family you touched.

## Relevant local references

- `src/MulleCGNanovgGL.h`
- `src/CGBackendFunctionTable+nanovg.h`
- `src/CGBackendFunctionTable+nanovg.m`
- `src/CGContext+nanovg-gl.m`
- `src/CGContext+ImageEffect.h`
- `src/CGContext+ImageEffect.m`
- `src/gpu/CGContext+GPU-opengl.m`
- `src/gpu/CGFramebuffer+GPU-opengl.m`
- `src/gpu/CGContext+GPUShader-opengl.m`
- `test/10-first/noleak.m`
- `test/01-nogl/breaklines.m`
- `test/01-nogl/breaklines-tricky.m`
- `test/01-nogl/breaklines-tricky2.m`
- `test/50-layoutcontext/cglayoutcontext.m`
- `test/50-layoutcontext/multiline.m`
- `test/60-context/cgcontext-framebuffer.m`

## Verify with repo tests

```bash
mulle-sde test run test/10-first/noleak.m
mulle-sde test run test/01-nogl/breaklines.m
mulle-sde test run test/01-nogl/breaklines-tricky.m
mulle-sde test run test/01-nogl/breaklines-tricky2.m
mulle-sde test run test/50-layoutcontext/cglayoutcontext.m
mulle-sde test run test/50-layoutcontext/multiline.m
mulle-sde test run test/60-context/cgcontext-framebuffer.m
```
