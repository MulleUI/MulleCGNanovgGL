# Header files in `reflect`

## External consumption only

### `MulleCGNanovgGL-export.h`

This file is generated for the Objective-C envelope header (typically
`MulleCGNanovgGL
.h`). It contains the list of Objective-C headers that
are advertised to consumers of this library


### `MulleCGNanovgGL-provide.h`

This file is generated for the Objective-C or C envelope header (typically
`MulleCGNanovgGL
.h`). It contains the list of C headers that will be
advertised to consumers of this library.


### `objc-deps.inc`

This file contains Objective-C dependency information of this library.
It's updated during a build.


## Internal and External consumption


### `MulleCGNanovgGL-import.h`

Objective-C dependency headers that this project uses are imported via
this file. Dependencies are managed with `mulle-sde dependency`
These dependencies are also available to consumers of this library.


### `MulleCGNanovgGL-include.h`

C dependency and library headers that this project uses are imported via
this file. Dependencies are managed with `mulle-sde dependency`.
Libraries with `mulle-sde library`.
These dependencies are also available to consumers of this library.


## Internal consumption only


### `MulleCGNanovgGL-import-private.h`

Objective-C dependency headers that this project uses privately are imported
via this file.


### `MulleCGNanovgGL-include-private.h`

C dependency and library headers that this project uses privately are imported
via this file.
