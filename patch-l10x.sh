#!/bin/bash

# This script patches the original SPL files from ST for use with sduino.
#
# This part patches the SPL for the STM8L10x series.
#
# The archive en.stsw-stm8012.zip from ST is patches with
# - the SDCC patch from https://github.com/gicking/STM8L10x_StdPeriph_Lib_V1.2.1_sdcc.patch
# - some local patches in patches/

TOPDIR=STM8L10x_StdPeriph_Lib
LIBDIR=STM8L10x_StdPeriph_Driver

# unpack the STM8L10 library
unzip zips/en.stsw-stm8012.zip 
chmod +w -R ${TOPDIR}

# apply Georg's patch:
patch -p0 < ../STM8-SPL_SDCC_patch/STM8L10x_StdPeriph_Lib_V1.2.1_sdcc.patch

# grab the needed files
mv ${TOPDIR}/Libraries/$LIBDIR .
cp -a STM8L10x_StdPeriph_Lib/Project/STM8L10x_StdPeriph_Examples/GPIO/GPIO_IOToggle/stm8l10x_conf.h $LIBDIR/inc

# Linux only: correct the line endings from CRLF (DOS/Windows) to LF
if test $(uname) = Linux; then
	find $LIBDIR -name "*.[ch]"|xargs fromdos
fi

# apply all patches in order
for i in patches/l10-*.patch; do
	patch -p1 < $i
done
