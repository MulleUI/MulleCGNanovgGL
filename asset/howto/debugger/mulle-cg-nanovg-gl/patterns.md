<!-- keywords: MulleCGNanovgGL, debugger, patterns, CGLayoutContext, framebuffer, shader -->

# Patterns

## Use `test/10-first/noleak.m` as the package smoke test

- Start here when you suspect import/link/package trouble.
- If this fails, stop chasing NanoVG rendering details first; the package is not wired in cleanly yet.

```bash
mulle-sde test run test/10-first/noleak.m
```

## Confirm the backend handoff before deeper GPU debugging

- `src/CGContext+nanovg-gl.m` creates the NanoVG context and immediately stores `CGNanoVGBackendFunctionTable`.
- `src/CGBackendFunctionTable+nanovg.m` shows the intended thin-wrapper shape for GL framebuffer hooks.
- If context creation succeeds but framebuffer calls misbehave, debug the table wiring before the larger render path.

```objc
_cgBackend.context = nvgCreateGL3( _cgBackend.flags);
_cgBackend.backendFunctions = CGNanoVGBackendFunctionTable;
```

## Reproduce line breaking without GPU noise

- Start with `test/01-nogl/breaklines.m` for empty lines, widths, and row ranges.
- Use `test/01-nogl/breaklines-tricky.m` and `test/01-nogl/breaklines-tricky2.m` when the suspect change touches row stride or custom row storage.

```bash
mulle-sde test run test/01-nogl/breaklines.m
mulle-sde test run test/01-nogl/breaklines-tricky.m
mulle-sde test run test/01-nogl/breaklines-tricky2.m
```

## Separate logical bounds from visual bounds

- `test/50-layoutcontext/cglayoutcontext.m` is the local reference for `getTextBounds:`, `visualBoundsOfText:length:`, and glyph positions.
- Compare those outputs before blaming framebuffer or shader code; many "cropped text" bugs are layout or bounds issues first.

```objc
[context getTextBounds:&bounds
                  text:text
                length:(NSUInteger) -1];
vbounds = [context visualBoundsOfText:text
                               length:(NSUInteger) -1];
n = [context getGlyphPositions:positions
                         count:32
                          text:text
                        length:(NSUInteger) -1];
```

## Treat multiline diagnostics as a separate path

- `test/50-layoutcontext/multiline.m` is the local spec for `getTextRows:...breakRowWidth:`.
- Use it when single-line metrics look sane but wrapping still fails.

```objc
n = [context getTextRows:rows
                   count:8
             textRowSize:sizeof( struct UITextRow)
                    text:text
                  length:(NSUInteger) -1
           breakRowWidth:100.0];
```

## Trace framebuffer and image readback through the existing helpers

- `src/CGContext+nanovg-gl.m` owns `RGBABytesBitmapOfImage:allocator:` and `readFramebufferBitmap:framebufferBitmapType:allocator:`.
- `src/gpu/CGContext+GPU-opengl.m` uses `framebufferBitmap` as the normal current-framebuffer readback path.
- If pixels are wrong, stay in those helpers until you know whether the fault is readback, MSAA resolve, or earlier drawing.

```objc
bitmap = [self readFramebufferBitmap:rect
               framebufferBitmapType:CGFramebufferRGBABytes
                           allocator:NULL];
```

## Debug shader failures at the injected-header boundary

- `src/gpu/CGContext+GPUShader-opengl.m` prepends the backend version header only when the source does not already begin with `#version`.
- The existing compile log already reports shader kind and name; use that before adding ad hoc logging.

```objc
headerAndSource[ 0] = has_version_header( source) ? "" : [self shaderHeaderUTF8String];
headerAndSource[ 1] = source;
```
