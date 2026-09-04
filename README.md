# MulleCGNanovgGL

Part of [MulleUI](https://github.com/MulleUI) — UIKit-shaped modular GUI libraries for mulle-objc.

#### ☄️ MulleCGNanovgGL is the OpenGL implementation of MulleCGNanovg

MulleCGNanovgGL provides the OpenGL implementation of the MulleCGNanovg backend.
It fills the `CGBackendFunctionTable` with OpenGL calls for framebuffer creation,
context setup and frame begin/end. It also bundles GLAD for OpenGL loading.

Use this library when targeting desktop or OpenGL ES platforms.



| Release Version                                       | Release Notes  | AI Documentation
|-------------------------------------------------------|----------------|---------------
| ![Mulle kybernetiK tag](https://img.shields.io/github/tag/MulleUI/MulleCGNanovgGL.svg) [![Build Status](https://github.com/MulleUI/MulleCGNanovgGL/workflows/CI/badge.svg)](//github.com/MulleUI/MulleCGNanovgGL/actions) | [RELEASENOTES](RELEASENOTES.md) | [DeepWiki for MulleCGNanovgGL](https://deepwiki.com/MulleUI/MulleCGNanovgGL)




## Documentation & Guides

* [API Summary](asset/dox/api/toc)
* [Coder Guide](asset/howto/coder/mulle-cg-nanovg-gl)
* [Debugger Guide](asset/howto/debugger/mulle-cg-nanovg-gl)
* [Verifier Guide](asset/howto/verifier/mulle-cg-nanovg-gl)




### You are here

![Overview](overview.dot.svg)





## Add

Use [mulle-sde](//github.com/mulle-sde) to add MulleCGNanovgGL to your project:

``` sh
mulle-sde add github:MulleUI/MulleCGNanovgGL
```

To only add the sources of MulleCGNanovgGL with dependency
sources use [clib](https://github.com/clibs/clib):


``` sh
clib install --out src/MulleUI MulleUI/MulleCGNanovgGL
```

Add `-isystem src/MulleUI` to your `CFLAGS` and compile all the sources that were downloaded with your project.


## Install

Use [mulle-sde](//github.com/mulle-sde) to build and install MulleCGNanovgGL and all dependencies:

``` sh
mulle-sde install --prefix /usr/local \
   https://github.com/MulleUI/MulleCGNanovgGL/archive/latest.tar.gz
```

### Legacy Installation

Install the requirements:

| Requirements                                 | Description
|----------------------------------------------|-----------------------
| [MulleCGNanovg](https://github.com/MulleUI/MulleCGNanovg)             | 🛰️ MulleCGNanovg is the nanovg rendering backend for MulleCG
| [mulle-objc-list](https://github.com/mulle-objc/mulle-objc-list)             | 📒 Lists mulle-objc runtime information contained in executables.

Download the latest [tar](https://github.com/MulleUI/MulleCGNanovgGL/archive/refs/tags/latest.tar.gz) or [zip](https://github.com/MulleUI/MulleCGNanovgGL/archive/refs/tags/latest.zip) archive and unpack it.

Install **MulleCGNanovgGL** into `/usr/local` with [cmake](https://cmake.org):

``` sh
PREFIX_DIR="/usr/local"
cmake -B build                               \
      -DMULLE_SDK_PATH="${PREFIX_DIR}"       \
      -DCMAKE_INSTALL_PREFIX="${PREFIX_DIR}" \
      -DCMAKE_PREFIX_PATH="${PREFIX_DIR}"    \
      -DCMAKE_BUILD_TYPE=Release &&
cmake --build build --config Release &&
cmake --install build --config Release
```


## Author

[Nat!](https://mulle-kybernetik.com/weblog) for Mulle kybernetiK  



