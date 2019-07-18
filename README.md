# freetype-builds

>Portions of this software are copyright © 2019 The FreeType
Project (www.freetype.org).  All rights reserved.

### Static pre-built versions of the FreeType project and its dependencies.

The master branch is merely a template, all the code is in the version branches.  
Builds are run automatically by [TravisCI](https://travis-ci.org/flga/freetype-builds). Headers and binaries are shipped as [Github Releases](https://github.com/flga/freetype-builds/releases).

Every build produces 3 binaries, you should link against *one* of:
* FreeType
* FreeType + Harfbuzz
* FreeType + Harfbuzz + Harfbuzz Subset

### Support Matrix
OS | Arch
------ | ------
Linux  | `amd64`, `386`
OSX    | `amd64`, `386`

### Builds
Branch | Dependencies | Status | Release
------ | ------------ | ------ | -------
2.10.1 | `zlib-1.2.11` `libpng-1.6.37` `harfbuzz-2.5.3` | [![Build Status](https://travis-ci.org/flga/freetype-builds.svg?branch=2.10.1)](https://travis-ci.org/flga/freetype-builds) | [Download](https://github.com/flga/freetype-builds/releases/tag/2.10.1)

### Disclaimer

This repo contains the sources "as-is" of the FreeType, harfbuzz, libpng and zlib projects, and all rights are reserved to the respective owners.

Please review the LICENSE file, which contains all 3 licenses bundled. The individual license files are in their respective folders, except for zlib which does not ship with one, but can be found [here](https://zlib.net/zlib_license.html).
