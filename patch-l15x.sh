#!/bin/bash

# This script patches the original SPL files from ST for use with sduino.
#
# This part patches the SPL for the STM8L15x series.
#
# The archive en.stsw-stm8016.zip from ST is patches with
# - the SDCC patch from https://github.com/gicking/STM8-SPL_SDCC_patch
# - some local patches in patches/

TOPDIR=STM8L15x-16x-05x-AL31-L_StdPeriph_Lib
LIBDIR=STM8L15x_StdPeriph_Driver

# unpack the STM8L15 library
unzip zips/en.stsw-stm8016.zip 
chmod +w -R ${TOPDIR}

# apply Georg's patch:
patch -p0 < ../STM8-SPL_SDCC_patch/STM8L15x-16x-05x-AL31-L_StdPeriph_Lib_V1.6.2_sdcc.patch

# grab the needed files
mv ${TOPDIR}/Libraries/$LIBDIR .
rm -f $LIBDIR/*.chm
cp -a STM8L15x-16x-05x-AL31-L_StdPeriph_Lib/Project/STM8L15x_StdPeriph_Examples/GPIO/GPIO_Toggle/stm8l15x_conf.h $LIBDIR/inc

# Linux only: correct the line endings from CRLF (DOS/Windows) to LF
if test $(uname) = Linux; then
	find $LIBDIR -name "*.[ch]"|xargs fromdos
fi

# apply all patches in order
for i in patches/l15-*.patch; do
	patch -p1 < $i
done
