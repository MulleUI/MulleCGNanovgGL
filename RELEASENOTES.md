### 0.0.1

* new mulle-sde config projects style
* fix for multi-window

feature: add multi-backend NanoVG GPU support and refactor backend interface

* introduce CGNanoVGBackendFunctionTable and wire backend-specific framebuffer functions for OpenGL, D3D11 and Metal
* add unified `_cgBackend` (flags/devicePointer) usage and initialize/teardown paths for NanoVG font & graphics contexts (MSAA-aware)
* improve framebuffer texture handling (supports multisampled textures and backend-specific image IDs) and safer GL wrapper functions






* supportsAntiAliasing, nanoVGBackend, nanoVGBackendUTF8String, nanovgInfoUTF8String
  back here where `NANOVG_GL3/GLES2/GLES3/D3D11_IMPLEMENTATION` are defined
* `_initNanoVGWithGraphicsOptions:` set `_backendFlags` then call [self `_initBackend]`




feature: initial commit — OpenGL backend for MulleCGNanovg

* CGContext+nanovg-gl.m: GL init/done, error checking, RGBABytesBitmap, readFramebufferBitmap
* CGBackendFunctionTable+nanovg.m: GL framebuffer vtable
* CGContext+GPU-opengl.m: GL framebuffer/blit/viewport/barrier ops
* CGContext+GPUShader-opengl.m: GL shader compile/link
* CGFramebuffer+GPU-opengl.m: GL framebuffer render begin/end
* backend info methods (supportsAntiAliasing, nanoVGBackend, etc.) moved to MulleCGNanovg
