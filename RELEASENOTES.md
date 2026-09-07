## 0.1.0



feature: add GL platform dispatch and headless backend safety

* GL loading now dispatches by platform: Windows uses the runtime glad loader, Linux/GLES pulls system GL headers, Apple uses the framework headers
* backend selection driven by `MulleCGNanovg/_MulleCGBackend.h` instead of hardcoded Windows-only glad path
* barrier() no longer crashes on headless/no-backend contexts where glFinish would dereference a NULL GL context
