<!-- keywords: MulleCGNanovgGL, debugger, NanoVG, CGLayoutContext, framebuffer, shader -->

# mulle-cg-nanovg-gl

Use this topic when you are debugging repo-local NanoVG/OpenGL behavior in this package, especially when a normal `MulleCG` API call turns into wrong text rows or bounds, backend bootstrap failures, or bad framebuffer/shader output only in this backend.

## Understand first

```bash
mulle-sde api apropos nanovg
mulle-sde api apropos CGLayoutContext
mulle-sde api apropos framebufferBitmap
mulle-sde code search CGNanoVGBackendFunctionTable
mulle-sde code search visualBoundsOfText
mulle-sde code search shaderHeaderUTF8String
```

## Main local surfaces

| Scenario | Inspect | Local refs |
| --- | --- | --- |
| Backend/bootstrap failures | NanoVG context creation, backend table assignment, backend error paths | `src/CGBackendFunctionTable+nanovg.h`, `src/CGBackendFunctionTable+nanovg.m`, `src/CGContext+nanovg-gl.m` |
| Text/layout mismatches | no-GL line breaking, bounds, visual bounds, multiline rows | `test/01-nogl/breaklines.m`, `test/01-nogl/breaklines-tricky.m`, `test/01-nogl/breaklines-tricky2.m`, `test/50-layoutcontext/cglayoutcontext.m`, `test/50-layoutcontext/multiline.m` |
| Framebuffer/image/shader failures | readback helpers, framebuffer lifecycle, shader header injection | `src/CGContext+nanovg-gl.m`, `src/gpu/CGContext+GPU-opengl.m`, `src/gpu/CGFramebuffer+GPU-opengl.m`, `src/gpu/CGContext+GPUShader-opengl.m` |

## Local debugging delta

- `src/MulleCGNanovgGL.h` is only thin umbrella glue; the repo-local exported hook is `CGNanoVGBackendFunctionTable` in `src/CGBackendFunctionTable+nanovg.h`.
- The repo `README.md` is generic. The short tests in `test/01-nogl` and `test/50-layoutcontext` are the real local spec.
- Split failures early: `test/01-nogl` isolates layout behavior without live GL drawing, while `src/gpu/*.m` and `src/CGContext+nanovg-gl.m` cover runtime/backend state.

## Primary local workflow

1. Map the symptom to one of the families above.
2. Reproduce with the smallest nearby test before reading wider code.
3. Follow the local handoff: context init -> backend table -> family-specific helper.
4. Report the smallest failing test and the first backend error or shader compile log, not only the final visual symptom.

## Relevant local references

- `README.md`
- `test/README.md`
- `src/MulleCGNanovgGL.h`
- `src/CGBackendFunctionTable+nanovg.h`
- `src/CGBackendFunctionTable+nanovg.m`
- `src/CGContext+nanovg-gl.m`
- `src/gpu/CGContext+GPU-opengl.m`
- `src/gpu/CGFramebuffer+GPU-opengl.m`
- `src/gpu/CGContext+GPUShader-opengl.m`
- `test/10-first/noleak.m`
- `test/01-nogl/breaklines.m`
- `test/01-nogl/breaklines-tricky.m`
- `test/01-nogl/breaklines-tricky2.m`
- `test/50-layoutcontext/cglayoutcontext.m`
- `test/50-layoutcontext/multiline.m`

## Verify/report

```bash
mulle-sde test run test/10-first/noleak.m
mulle-sde test run test/01-nogl/breaklines.m
mulle-sde test run test/01-nogl/breaklines-tricky.m
mulle-sde test run test/50-layoutcontext/cglayoutcontext.m
mulle-sde test run test/50-layoutcontext/multiline.m
```
