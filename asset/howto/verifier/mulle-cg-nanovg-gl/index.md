<!-- keywords: NanoVG, OpenGL, draw-call tracing, shader compile, framebuffer readback, text metrics -->

# mulle-cg-nanovg-gl

Use this topic when user code already draws through `MulleCG`, but the failure only shows up on this NanoVG/OpenGL backend: GL error spam, missing draw output, shader compile/link failures, framebuffer readback trouble, or text bounds/row mismatches.

## Understand first

```bash
mulle-sde howto show debug
mulle-sde api apropos CGContextCheckBackendError
mulle-sde api apropos UIGraphicsTraceDrawCalls
mulle-sde api apropos nanovg
mulle-sde code search assertNoBackendError
mulle-sde code search shaderHeaderUTF8String
```

## Main local surfaces

| Symptom | Inspect | Local refs |
| --- | --- | --- |
| Backend/bootstrap or generic GL errors | `CGContextCheckBackendError`, NanoVG context setup, backend name reporting | `src/CGContext+nanovg-gl.m`, `src/CGBackendFunctionTable+nanovg.m` |
| Missing or surprising draw calls | `UIGraphicsTraceDrawCalls` and DEBUG-only NanoVG context info on stderr | `src/CGContext+nanovg-gl.m` |
| Shader compile/link failures | automatic version-header injection, compile/link logs, `_debuggingFlags` logs | `src/gpu/CGContext+GPUShader-opengl.m` |
| Text rows, bounds, or clipping mismatches | row-stride tests, visual-bounds test, multiline row expectations | `test/01-nogl/breaklines.m`, `test/01-nogl/breaklines-tricky.m`, `test/01-nogl/breaklines-tricky2.m`, `test/50-layoutcontext/cglayoutcontext.m`, `test/50-layoutcontext/multiline.m` |
| Framebuffer readback failures | readback path, MSAA resolve path, unsupported bitmap type message | `src/CGContext+nanovg-gl.m`, `src/gpu/CGFramebuffer+GPU-opengl.m`, `test/60-context/cgcontext-framebuffer.m` |

## Local verifier delta

- No repo-local `MULLE_*_TRACE` or similar environment variables showed up here. Use the shared `debug` howto for generic `mulle-sde` debug/sanitizer workflow.
- The real local switch is a `DEBUG` build: `src/CGContext+nanovg-gl.m` adds `NVG_DEBUG` for both font-only and drawing contexts, and prints `nanovg context "<name>" : <backend+flags>` on context creation.
- `UIGraphicsTraceDrawCalls` is the backend-specific draw trace knob. It calls `nvgTrace( ..., stderr)` unless compiled with `NVG_TRACECODE_DISABLED`, in which case you get the explicit line `nvg trace not available (NVG_TRACECODE_DISABLED)`.
- Backend error checks are concrete here: `CGContextCheckBackendError`/`assertNoBackendError:` report backend name, GL symbolic error, hex code, and a human string such as `Wrong or no framebuffer selected`.
- Shader failures already self-report to `stderr`: compile errors include shader stage and name; link errors include shader name; `_debuggingFlags` adds shader-version logging in `src/gpu/CGContext+GPUShader-opengl.m`.

## Primary local workflow

1. Reproduce in a `DEBUG` build first; this backend only emits its NanoVG context banner and `NVG_DEBUG` checks there.
2. If you own context creation, add `UIGraphicsTraceDrawCalls` and capture `stderr` before changing code.
3. For text-only failures, reduce to `CGLayoutContext` behavior first. The short tests in `test/01-nogl` and `test/50-layoutcontext` are the local oracle for row stride, multiline splitting, and visual bounds.
4. For GPU failures, stop on the first `CGContextCheckBackendError` line or shader compile/link log. Later symptoms are usually fallout.
5. For readback bugs, check whether the failing path is plain `glReadPixels`, compatibility-profile `glGetTexImage`, or the MSAA resolve branch in `src/CGContext+nanovg-gl.m`.

## Relevant local references

- `README.md`
- `src/CGContext+nanovg-gl.m`
- `src/CGBackendFunctionTable+nanovg.m`
- `src/gpu/CGContext+GPUShader-opengl.m`
- `src/gpu/CGFramebuffer+GPU-opengl.m`
- `test/01-nogl/breaklines.m`
- `test/01-nogl/breaklines-tricky.m`
- `test/01-nogl/breaklines-tricky2.m`
- `test/50-layoutcontext/cglayoutcontext.m`
- `test/50-layoutcontext/multiline.m`
- `test/60-context/cgcontext-framebuffer.m`

## Verify/report

- Include the first backend line, not the last one: `CGContextCheckBackendError`, shader compile/link output, or `gladLoadGL failed`.
- Say whether `UIGraphicsTraceDrawCalls` produced NanoVG trace output or the `NVG_TRACECODE_DISABLED` message.
- For text bugs, report which nearby spec your output diverges from: `test/01-nogl/breaklines*.m` for row layout or `test/50-layoutcontext/cglayoutcontext.m` for `visualBoundsOfText`.
- For framebuffer bugs, report bitmap type, MSAA/non-MSAA status, and whether the failure happened before `glReadPixels`, during `glBlitFramebuffer`, or on framebuffer attachment.
