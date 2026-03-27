#
# You rarely need to edit this file. To add or remove files in your
# project edit the "src" folders contents and run `mulle-sde reflect`
#
#
# A convenient way to add a new source file is:
#    mulle-sde add src/foo.m
#
cmake_minimum_required( VERSION 3.13...99.99)

project( MulleCGNanovgGL VERSION 0.0.1 LANGUAGES C)

# if use embedded project with symlinks and you want to distribute their
# headers you probably need to turn this on
SET( RESOLVE_INSTALLABLE_HEADER_SYMLINKS OFF CACHE BOOL "Copy headers as files")

set( MULLE_PROJECT_TYPE "Library")

### mulle-sde environment

# add cmake module paths to search path
list( INSERT CMAKE_MODULE_PATH 0 "${CMAKE_CURRENT_SOURCE_DIR}/cmake/share")
list( INSERT CMAKE_MODULE_PATH 0 "${CMAKE_CURRENT_SOURCE_DIR}/cmake/reflect")
list( INSERT CMAKE_MODULE_PATH 0 "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include( Environment)

include( Files)

include( IDESupport OPTIONAL)


if( "${MULLE_PROJECT_TYPE}" STREQUAL "Executable")

   ### Executable

   include( Dependencies)
   include( Executable)

   # use EXECUTABLE_COMPILE_TARGET for compiler options
   target_compile_definitions( "${EXECUTABLE_COMPILE_TARGET}" PUBLIC)
   target_compile_options( "${EXECUTABLE_COMPILE_TARGET}" PUBLIC)
   # use EXECUTABLE_LINK_TARGET for linker options
   if( LINK_PHASE)
      target_link_options( "${EXECUTABLE_LINK_TARGET}" PUBLIC)
   endif()

   include( InstallExecutable)

   # only for Executable
   include( Motd OPTIONAL)


elseif( "${MULLE_PROJECT_TYPE}" STREQUAL "Framework")

   ### Framework

   if( LINK_PHASE)
      include( Dependencies)
   endif()

   include( Framework)
   include( InstallFramework)

elseif( "${MULLE_PROJECT_TYPE}" STREQUAL "Library")

   ### Library

   if( HEADER_PHASE)
      install( FILES ${INSTALL_PUBLIC_HEADERS}  DESTINATION "include/${PROJECT_NAME}")
      install( FILES ${INSTALL_PRIVATE_HEADERS} DESTINATION "include/${PROJECT_NAME}")
      install( FILES ${INSTALL_CMAKE_INCLUDES}  DESTINATION "include/${PROJECT_NAME}/cmake")

      # short cut out
      if( NOT COMPILE_PHASE AND NOT LINK_PHASE)
         return()
      endif()
   endif()

   if( LINK_PHASE)
      include( Dependencies OPTIONAL)
   endif()

   include( Library)

   # use LIBRARY_COMPILE_TARGET for compiler options
   target_compile_definitions( "${LIBRARY_COMPILE_TARGET}" PUBLIC MULLE_CG_BACKEND_OPENGL)
   target_compile_definitions( "${LIBRARY_COMPILE_TARGET}" PRIVATE
      CG_COLOR_STRUCT_DEFINED   # nanovg defines struct NVGcolor, CGColor.h must not redefine it
      MULLE__NANOVG_GL_BUILD    # export nanovg_gl.h functions from this DLL
      MULLE__NANOVG_BUILD       # nanovg.c symbols are statically linked in, not dllimport
   )
   # Only CGContext+nanovg-gl.m needs to emit the nanovg GL implementation
   set_source_files_properties( src/CGContext+nanovg-gl.m PROPERTIES
      COMPILE_DEFINITIONS "DEFINE_NANOVG_GL_IMPLEMENTATION"
   )
   target_compile_options( "${LIBRARY_COMPILE_TARGET}" PRIVATE
      -include mulle-nanovg/nanovg.h  # force nanovg.h before any header so NVGcolor is defined first
   )
   # use LIBRARY_LINK_TARGET for linker options
   if( LINK_PHASE)
      target_link_options( "${LIBRARY_LINK_TARGET}" PUBLIC)
   endif()

   include( InstallLibrary)

   if( LINK_PHASE)
      include( InstallCMakeInclude)
      include( InstallCMakePackage)
   endif()

else()

   message( ERROR "Unknown project type \"${MULLE_PROJECT_TYPE}\"")

endif()



include( FinalOutput OPTIONAL)
