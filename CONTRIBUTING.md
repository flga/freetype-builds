# Contributing

## Code of Conduct
Be nice.

## Adding another FreeType version

1. Open up an issue asking to create another branch for the version you wish to add
1. Create a new branch from `master`, with the same name as the FreeType version (ex `2.10.0`)
    * Note: some FreeType versions do not have the patch value set, (ex `2.8`), in that case, add a `.0`
1. Create a folder named `src` and extract the source code of FreeType and its dependencies, without making any modifications.
1. Modify the variables defined in `version.sh` so that they reflect the new versions. These should match the folder names in `src`, ex:
    ```bash
    export FTB_VERSION=2.10.1
    export FTB_FREETYPE=freetype-$FTB_VERSION
    export FTB_ZLIB=zlib-1.2.11
    export FTB_LIBPNG=libpng-1.6.37
    export FTB_HARFBUZZ=harfbuzz-2.5.3
    ```
1. Create a new PR (using the branch created in step 1 as base) and the build will be run automatically

I'm not very familiar with Github, Travis and all their bells and whistles, so if you have any suggestions on how to improve the workflow they'll be most welcome.