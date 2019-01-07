# Compile the ST SPL libraries for STM8 in a linker-friendly way

These scripts are a workaround to overcome a
[SDCC](http://sdcc.sourceforge.net/) linker limitation.


## The problem

The SDCC linker does not detect unused functions and constants in an object
file. It always links the whole file even if only a single symbol contained
in the file is referenced. This results in pretty bloated binaries if the
SPL is used.

These scripts assist the SDCC linker by splitting the source into smaller
units, usually only one function per file. All split files are compiled
individually and packed together into a CPU-specific library.

This way every function can be linked independently and dead code is
automatically eleminated at linking time, saving precious flash memory
space.


## Usage

Clone this repository and the [SDCC SPL
patches](https://github.com/gicking/STM8-SPL_SDCC_patch).
Enter the spl-splitter directory:

	git clone --recursive https://github.com/tenbaht/spl-splitter.git
	cd spl-splitter


Download the SPL archive file from the ST website (free registration
required) into a subdirectory `zips/`:
  - STM8S/A: [STSW-STM8069](https://www.st.com/en/embedded-software/stsw-stm8069.html)
  - STM8L10x: [STSW-STM8012](https://www.st.com/en/embedded-software/stsw-stm8012.html)
  - STM8L15x-16x-05x-AL31-L: [STSW-STM8016](https://www.st.com/en/embedded-software/stsw-stm8016.html)
  - STM8TL5x: [STSW-STM8030](https://www.st.com/en/embedded-software/stsw-stm8030.html)



Unpack, patch and compile the SPL archive:
  - STM8S/A: `make s`
  - STM8L10x: `make l10`
  - STM8L15x-16x-05x-AL31-L: `make l15`
  - STM8TL5x: `make tl5`
  - or all of them at once with a single command: `make all`

The compiled libraries are generated in the `lib/` folder.

The `build-*` directories are not needed anymore and can safely be deleted.
They are only left for reference.



## Using windows

The patch and build scripts are simple bash scripts. Enviroments like msys2,
mingw or cygwin will definitely do. Busybox would be great and the easiest
solution, but I am not sure if all scripts will work. At least it should be
close. Pull requests welcome!

The line endings might be a problem when applying the patches. If so, check
your `core.autocrlf` setting in git (see [Dealing with line
endings](https://help.github.com/articles/dealing-with-line-endings/#platform-windows)
and consider using `patch --binary`. If you are using msysgit or [git for
windows](https://gitforwindows.org/), configure it for "Checkout
Windows-style")


## The stategy

This hack only works because the SPL files are very regulary structured.

All functions are documented with a doxygen comment block. The beginning of
this comment block is a line with only "/**", that can easily be used as a
marker for splitting the files.

Only the very first block is special. It contains definitions and prototypes
that are needed all over the module. This block is saved as a `.h` file and
`#include`'d by all the following blocks.

In most cases this is already sufficient. Only in very rare cases the
position of a split needs the be edited. This is automatically done by the
patches in the `patches/` directory.

**To prevent a split**: Change the `/**` line into something different, `/***`
is used in the scripts.

**To force a split**: Add an empty Doxygen comment block:
```c
/**
 */
```

