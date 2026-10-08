# MulleCGNanovgGL

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





### Add MulleCGNanovgGL as a cmake subproject

In your code include its header:

``` c
#include <MulleCGNanovgGL/MulleCGNanovgGL.h>
```

Add MulleCGNanovgGL and dependencies as git submodules and link against
them:

``` bash
git submodule add -f --branch * --name "mintomic" \
                            "clib:mulle-concurrent/mintomic@*" \
                            "stash/mintomic"
git submodule add -f --branch * --name "dlfcn-win32" \
                            "clib:mulle-core/dlfcn-win32@*" \
                            "stash/dlfcn-win32"
git submodule add -f --branch * --name "src/mulle-aba" \
                            "clib:mulle-concurrent/mulle-aba@*" \
                            "stash/src/mulle-aba"
git submodule add -f --branch * --name "src/mulle-allocator" \
                            "clib:mulle-c/mulle-allocator@*" \
                            "stash/src/mulle-allocator"
git submodule add -f --branch * --name "src/mulle-buffer" \
                            "clib:mulle-c/mulle-buffer@*" \
                            "stash/src/mulle-buffer"
git submodule add -f --branch * --name "src/mulle-c11" \
                            "clib:mulle-c/mulle-c11@*" \
                            "stash/src/mulle-c11"
git submodule add -f --branch * --name "src/mulle-concurrent" \
                            "clib:mulle-concurrent/mulle-concurrent@*" \
                            "stash/src/mulle-concurrent"
git submodule add -f --branch * --name "src/mulle-container-debug" \
                            "clib:mulle-c/mulle-container-debug@*" \
                            "stash/src/mulle-container-debug"
git submodule add -f --branch * --name "src/mulle-container" \
                            "clib:mulle-c/mulle-container@*" \
                            "stash/src/mulle-container"
git submodule add -f --branch * --name "src/mulle-data" \
                            "clib:mulle-c/mulle-data@*" \
                            "stash/src/mulle-data"
git submodule add -f --branch * --name "src/mulle-dlfcn" \
                            "clib:mulle-core/mulle-dlfcn@*" \
                            "stash/src/mulle-dlfcn"
git submodule add -f --branch * --name "src/mulle-dtostr" \
                            "clib:mulle-core/mulle-dtostr@*" \
                            "stash/src/mulle-dtostr"
git submodule add -f --branch * --name "src/mulle-fifo" \
                            "clib:mulle-concurrent/mulle-fifo@*" \
                            "stash/src/mulle-fifo"
git submodule add -f --branch * --name "src/mulle-fprintf" \
                            "clib:mulle-core/mulle-fprintf@*" \
                            "stash/src/mulle-fprintf"
git submodule add -f --branch * --name "src/mulle-http" \
                            "clib:mulle-c/mulle-http@*" \
                            "stash/src/mulle-http"
git submodule add -f --branch * --name "src/mulle-linkedlist" \
                            "clib:mulle-concurrent/mulle-linkedlist@*" \
                            "stash/src/mulle-linkedlist"
git submodule add -f --branch * --name "src/mulle-mmap" \
                            "clib:mulle-core/mulle-mmap@*" \
                            "stash/src/mulle-mmap"
git submodule add -f --branch * --name "src/mulle-multififo" \
                            "clib:mulle-concurrent/mulle-multififo@*" \
                            "stash/src/mulle-multififo"
git submodule add -f --branch * --name "src/mulle-rbtree" \
                            "clib:mulle-c/mulle-rbtree@*" \
                            "stash/src/mulle-rbtree"
git submodule add -f --branch * --name "src/mulle-rbtree-debug" \
                            "clib:mulle-core/mulle-rbtree-debug@*" \
                            "stash/src/mulle-rbtree-debug"
git submodule add -f --branch * --name "src/mulle-regex" \
                            "clib:mulle-c/mulle-regex@*" \
                            "stash/src/mulle-regex"
git submodule add -f --branch * --name "src/mulle-slug" \
                            "clib:mulle-c/mulle-slug@*" \
                            "stash/src/mulle-slug"
git submodule add -f --branch * --name "src/mulle-sprintf" \
                            "clib:mulle-core/mulle-sprintf@*" \
                            "stash/src/mulle-sprintf"
git submodule add -f --branch * --name "src/mulle-storage" \
                            "clib:mulle-c/mulle-storage@*" \
                            "stash/src/mulle-storage"
git submodule add -f --branch * --name "src/mulle-thread" \
                            "clib:mulle-concurrent/mulle-thread@*" \
                            "stash/src/mulle-thread"
git submodule add -f --branch * --name "src/mulle-time" \
                            "clib:mulle-core/mulle-time@*" \
                            "stash/src/mulle-time"
git submodule add -f --branch * --name "src/mulle-unicode" \
                            "clib:mulle-c/mulle-unicode@*" \
                            "stash/src/mulle-unicode"
git submodule add -f --branch * --name "src/mulle-url" \
                            "clib:mulle-c/mulle-url@*" \
                            "stash/src/mulle-url"
git submodule add -f --branch * --name "src/mulle-utf" \
                            "clib:mulle-c/mulle-utf@*" \
                            "stash/src/mulle-utf"
git submodule add -f --branch * --name "src/mulle-vararg" \
                            "clib:mulle-c/mulle-vararg@*" \
                            "stash/src/mulle-vararg"
git submodule add -f --name "stdthreads" \
                            "" \
                            "stash/stdthreads"
git submodule add -f --name "pthread" \
                            "" \
                            "stash/pthread"
git submodule add -f --name "src/mulle-spawn" \
                            "clib:mulle-core/mulle-spawn@*" \
                            "stash/src/mulle-spawn"
git submodule add -f --name "src/mulle-socket" \
                            "clib:mulle-core/mulle-socket@*" \
                            "stash/src/mulle-socket"
git submodule add -f --name "ws2_32" \
                            "" \
                            "stash/ws2_32"
git submodule add -f --name "mulle-core" \
                            "https://github.com/mulle-core/mulle-core.git" \
                            "stash/mulle-core"
git submodule add -f --name "zlib" \
                            "https://github.com/madler/zlib.git" \
                            "stash/zlib"
git submodule add -f --name "src/mulle-bitmap" \
                            "clib:mulle-gfx/mulle-bitmap" \
                            "stash/src/mulle-bitmap"
git submodule add -f --name "src/mulle-frame" \
                            "clib:mulle-gfx/mulle-frame" \
                            "stash/src/mulle-frame"
git submodule add -f --name "src/mulle-geometry" \
                            "clib:mulle-gfx/mulle-geometry" \
                            "stash/src/mulle-geometry"
git submodule add -f --name "src/mulle-layout" \
                            "clib:mulle-gfx/mulle-layout" \
                            "stash/src/mulle-layout"
git submodule add -f --name "src/mulle-quadtree" \
                            "clib:mulle-gfx/mulle-quadtree" \
                            "stash/src/mulle-quadtree"
git submodule add -f --name "src/mulle-fparray" \
                            "clib:mulle-gfx/mulle-fparray" \
                            "stash/src/mulle-fparray"
git submodule add -f --name "src/mulle-hexcolor" \
                            "clib:mulle-c/mulle-hexcolor" \
                            "stash/src/mulle-hexcolor"
git submodule add -f --branch * --name "src/mulle-path" \
                            "clib:mulle-gfx/mulle-path@*" \
                            "stash/src/mulle-path"
git submodule add -f --branch * --name "src/mulle-color" \
                            "clib:mulle-gfx/mulle-color@*" \
                            "stash/src/mulle-color"
git submodule add -f --name "math" \
                            "" \
                            "stash/math"
git submodule add -f --name "z" \
                            "" \
                            "stash/z"
git submodule add -f --name "mulle-gfx" \
                            "https://github.com/mulle-gfx/mulle-gfx.git" \
                            "stash/mulle-gfx"
git submodule add -f --name "craftinfo/libbacktrace-craftinfo" \
                            "" \
                            "stash/craftinfo/libbacktrace-craftinfo"
git submodule add -f --name "libbacktrace" \
                            "https://github.com/mulle-core/libbacktrace.git" \
                            "stash/libbacktrace"
git submodule add -f --branch * --name "src/mulle-atinit" \
                            "clib:mulle-core/mulle-atinit@*" \
                            "stash/src/mulle-atinit"
git submodule add -f --branch * --name "src/mulle-atexit" \
                            "clib:mulle-core/mulle-atexit@*" \
                            "stash/src/mulle-atexit"
git submodule add -f --branch * --name "src/mulle-stacktrace" \
                            "clib:mulle-core/mulle-stacktrace@*" \
                            "stash/src/mulle-stacktrace"
git submodule add -f --name "mulle-core-all-load" \
                            "https://github.com/mulle-core/mulle-core-all-load.git" \
                            "stash/mulle-core-all-load"
git submodule add -f --name "mulle-objc-runtime" \
                            "https://github.com/mulle-objc/mulle-objc-runtime.git" \
                            "stash/mulle-objc-runtime"
git submodule add -f --name "mulle-objc-debug" \
                            "https://github.com/mulle-objc/mulle-objc-debug.git" \
                            "stash/mulle-objc-debug"
git submodule add -f --name "mulle-objc-cc" \
                            "https://github.com/mulle-cc/mulle-objc-cc.git" \
                            "stash/mulle-objc-cc"
git submodule add -f --name "MulleObjC" \
                            "https://github.com/mulle-objc/MulleObjC.git" \
                            "stash/MulleObjC"
git submodule add -f --name "MulleUIBase" \
                            "https://github.com/MulleUI/MulleUIBase.git" \
                            "stash/MulleUIBase"
git submodule add -f --name "m" \
                            "m" \
                            "stash/m"
git submodule add -f --name "MulleCG" \
                            "https://github.com/MulleUI/MulleCG.git" \
                            "stash/MulleCG"
git submodule add -f --name "craftinfo/freetype-craftinfo" \
                            "" \
                            "stash/craftinfo/freetype-craftinfo"
git submodule add -f --name "harfbuzz" \
                            "https://github.com/harfbuzz/harfbuzz.git" \
                            "stash/harfbuzz"
git submodule add -f --name "freetype" \
                            "https://github.com/MulleUI/freetype.git" \
                            "stash/freetype"
git submodule add -f --name "harfbuzz" \
                            "" \
                            "stash/harfbuzz"
git submodule add -f --name "png" \
                            "" \
                            "stash/png"
git submodule add -f --name "z" \
                            "" \
                            "stash/z"
git submodule add -f --name "libpng" \
                            "https://github.com/glennrp/libpng.git" \
                            "stash/libpng"
git submodule add -f --name "mulle-freetype" \
                            "https://github.com/MulleUI/mulle-freetype.git" \
                            "stash/mulle-freetype"
git submodule add -f --name "src/stb_image_resize2.h" \
                            "https://raw.githubusercontent.com/nothings/stb/master/stb_image_resize2.h" \
                            "stash/src/stb_image_resize2.h"
git submodule add -f --name "src/stb_truetype.h" \
                            "https://raw.githubusercontent.com/nothings/stb/refs/heads/master/stb_truetype.h" \
                            "stash/src/stb_truetype.h"
git submodule add -f --name "src/stb_image.h" \
                            "https://raw.githubusercontent.com/nothings/stb/refs/heads/master/stb_image.h" \
                            "stash/src/stb_image.h"
git submodule add -f --name "harfbuzz" \
                            "" \
                            "stash/harfbuzz"
git submodule add -f --name "freetype" \
                            "" \
                            "stash/freetype"
git submodule add -f --name "mulle-nanovg" \
                            "https://github.com/MulleUI/mulle-nanovg.git" \
                            "stash/mulle-nanovg"
git submodule add -f --name "GL" \
                            "" \
                            "stash/GL"
git submodule add -f --name "opengl32" \
                            "" \
                            "stash/opengl32"
git submodule add -f --name "harfbuzz" \
                            "" \
                            "stash/harfbuzz"
git submodule add -f --name "png" \
                            "" \
                            "stash/png"
git submodule add -f --name "z" \
                            "" \
                            "stash/z"
git submodule add -f --name "freetype" \
                            "freetype" \
                            "stash/freetype"
git submodule add -f --name "MulleCGNanovg" \
                            "https://github.com/MulleUI/MulleCGNanovg.git" \
                            "stash/MulleCGNanovg"
git submodule add -f --name "mulle-objc-tools" \
                            "https://github.com/mulle-objc/mulle-objc-tools.git" \
                            "stash/mulle-objc-tools"
git submodule add -f --name "MulleCGNanovgGL" \
                        "https://github.com/MulleUI/MulleCGNanovgGL" \
                        "stash/MulleCGNanovgGL"
git submodule update --init --recursive
```

``` cmake
include_directories( SYSTEM "${CMAKE_BINARY_DIR}/include")

add_subdirectory( stash/mintomic)
add_subdirectory( stash/dlfcn-win32)
add_subdirectory( stash/src/mulle-aba)
add_subdirectory( stash/src/mulle-allocator)
add_subdirectory( stash/src/mulle-buffer)
add_subdirectory( stash/src/mulle-c11)
add_subdirectory( stash/src/mulle-concurrent)
add_subdirectory( stash/src/mulle-container-debug)
add_subdirectory( stash/src/mulle-container)
add_subdirectory( stash/src/mulle-data)
add_subdirectory( stash/src/mulle-dlfcn)
add_subdirectory( stash/src/mulle-dtostr)
add_subdirectory( stash/src/mulle-fifo)
add_subdirectory( stash/src/mulle-fprintf)
add_subdirectory( stash/src/mulle-http)
add_subdirectory( stash/src/mulle-linkedlist)
add_subdirectory( stash/src/mulle-mmap)
add_subdirectory( stash/src/mulle-multififo)
add_subdirectory( stash/src/mulle-rbtree)
add_subdirectory( stash/src/mulle-rbtree-debug)
add_subdirectory( stash/src/mulle-regex)
add_subdirectory( stash/src/mulle-slug)
add_subdirectory( stash/src/mulle-sprintf)
add_subdirectory( stash/src/mulle-storage)
add_subdirectory( stash/src/mulle-thread)
add_subdirectory( stash/src/mulle-time)
add_subdirectory( stash/src/mulle-unicode)
add_subdirectory( stash/src/mulle-url)
add_subdirectory( stash/src/mulle-utf)
add_subdirectory( stash/src/mulle-vararg)
add_subdirectory( stash/stdthreads)
add_subdirectory( stash/pthread)
add_subdirectory( stash/src/mulle-spawn)
add_subdirectory( stash/src/mulle-socket)
add_subdirectory( stash/ws2_32)
add_subdirectory( stash/mulle-core)
add_subdirectory( stash/zlib)
add_subdirectory( stash/src/mulle-bitmap)
add_subdirectory( stash/src/mulle-frame)
add_subdirectory( stash/src/mulle-geometry)
add_subdirectory( stash/src/mulle-layout)
add_subdirectory( stash/src/mulle-quadtree)
add_subdirectory( stash/src/mulle-fparray)
add_subdirectory( stash/src/mulle-hexcolor)
add_subdirectory( stash/src/mulle-path)
add_subdirectory( stash/src/mulle-color)
add_subdirectory( stash/math)
add_subdirectory( stash/z)
add_subdirectory( stash/mulle-gfx)
add_subdirectory( stash/craftinfo/libbacktrace-craftinfo)
add_subdirectory( stash/libbacktrace)
add_subdirectory( stash/src/mulle-atinit)
add_subdirectory( stash/src/mulle-atexit)
add_subdirectory( stash/src/mulle-stacktrace)
add_subdirectory( stash/mulle-core-all-load)
add_subdirectory( stash/mulle-objc-runtime)
add_subdirectory( stash/mulle-objc-debug)
add_subdirectory( stash/mulle-objc-cc)
add_subdirectory( stash/MulleObjC)
add_subdirectory( stash/MulleUIBase)
add_subdirectory( stash/m)
add_subdirectory( stash/MulleCG)
add_subdirectory( stash/craftinfo/freetype-craftinfo)
add_subdirectory( stash/harfbuzz)
add_subdirectory( stash/freetype)
add_subdirectory( stash/harfbuzz)
add_subdirectory( stash/png)
add_subdirectory( stash/z)
add_subdirectory( stash/libpng)
add_subdirectory( stash/mulle-freetype)
add_subdirectory( stash/src/stb_image_resize2.h)
add_subdirectory( stash/src/stb_truetype.h)
add_subdirectory( stash/src/stb_image.h)
add_subdirectory( stash/harfbuzz)
add_subdirectory( stash/freetype)
add_subdirectory( stash/mulle-nanovg)
add_subdirectory( stash/GL)
add_subdirectory( stash/opengl32)
add_subdirectory( stash/harfbuzz)
add_subdirectory( stash/png)
add_subdirectory( stash/z)
add_subdirectory( stash/freetype)
add_subdirectory( stash/MulleCGNanovg)
add_subdirectory( stash/mulle-objc-tools)
add_subdirectory( stash/MulleCGNanovgGL)

target_link_libraries( ${PROJECT_NAME} PUBLIC mintomic)
target_link_libraries( ${PROJECT_NAME} PUBLIC dlfcn-win32)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-aba)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-allocator)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-buffer)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-c11)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-concurrent)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-container-debug)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-container)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-data)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-dlfcn)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-dtostr)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-fifo)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-fprintf)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-http)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-linkedlist)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-mmap)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-multififo)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-rbtree)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-rbtree-debug)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-regex)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-slug)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-sprintf)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-storage)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-thread)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-time)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-unicode)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-url)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-utf)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-vararg)
target_link_libraries( ${PROJECT_NAME} PUBLIC stdthreads)
target_link_libraries( ${PROJECT_NAME} PUBLIC pthread)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-spawn)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-socket)
target_link_libraries( ${PROJECT_NAME} PUBLIC ws2_32)
target_link_libraries( ${PROJECT_NAME} PUBLIC mulle-core)
target_link_libraries( ${PROJECT_NAME} PUBLIC zlib)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-bitmap)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-frame)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-geometry)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-layout)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-quadtree)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-fparray)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-hexcolor)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-path)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-color)
target_link_libraries( ${PROJECT_NAME} PUBLIC math)
target_link_libraries( ${PROJECT_NAME} PUBLIC z)
target_link_libraries( ${PROJECT_NAME} PUBLIC mulle-gfx)
target_link_libraries( ${PROJECT_NAME} PUBLIC craftinfo/libbacktrace-craftinfo)
target_link_libraries( ${PROJECT_NAME} PUBLIC libbacktrace)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-atinit)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-atexit)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-stacktrace)
target_link_libraries( ${PROJECT_NAME} PUBLIC mulle-core-all-load)
target_link_libraries( ${PROJECT_NAME} PUBLIC mulle-objc-runtime)
target_link_libraries( ${PROJECT_NAME} PUBLIC mulle-objc-debug)
target_link_libraries( ${PROJECT_NAME} PUBLIC mulle-objc-cc)
target_link_libraries( ${PROJECT_NAME} PUBLIC MulleObjC)
target_link_libraries( ${PROJECT_NAME} PUBLIC MulleUIBase)
target_link_libraries( ${PROJECT_NAME} PUBLIC m)
target_link_libraries( ${PROJECT_NAME} PUBLIC MulleCG)
target_link_libraries( ${PROJECT_NAME} PUBLIC craftinfo/freetype-craftinfo)
target_link_libraries( ${PROJECT_NAME} PUBLIC harfbuzz)
target_link_libraries( ${PROJECT_NAME} PUBLIC freetype)
target_link_libraries( ${PROJECT_NAME} PUBLIC harfbuzz)
target_link_libraries( ${PROJECT_NAME} PUBLIC png)
target_link_libraries( ${PROJECT_NAME} PUBLIC z)
target_link_libraries( ${PROJECT_NAME} PUBLIC libpng)
target_link_libraries( ${PROJECT_NAME} PUBLIC mulle-freetype)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/stb_image_resize2.h)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/stb_truetype.h)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/stb_image.h)
target_link_libraries( ${PROJECT_NAME} PUBLIC harfbuzz)
target_link_libraries( ${PROJECT_NAME} PUBLIC freetype)
target_link_libraries( ${PROJECT_NAME} PUBLIC mulle-nanovg)
target_link_libraries( ${PROJECT_NAME} PUBLIC GL)
target_link_libraries( ${PROJECT_NAME} PUBLIC opengl32)
target_link_libraries( ${PROJECT_NAME} PUBLIC harfbuzz)
target_link_libraries( ${PROJECT_NAME} PUBLIC png)
target_link_libraries( ${PROJECT_NAME} PUBLIC z)
target_link_libraries( ${PROJECT_NAME} PUBLIC freetype)
target_link_libraries( ${PROJECT_NAME} PUBLIC MulleCGNanovg)
target_link_libraries( ${PROJECT_NAME} PUBLIC mulle-objc-tools)
target_link_libraries( ${PROJECT_NAME} PUBLIC MulleCGNanovgGL)
```

Or let [mulle-sde](//github.com/mulle-sde) do it:

``` sh
mulle-sde add github:MulleUI/MulleCGNanovgGL
```

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



