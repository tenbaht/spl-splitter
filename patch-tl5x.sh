#!/bin/bash

# This script patches the original SPL files from ST for use with sduino.
#
# This part patches the SPL for the STM8TL5x series.
#
# The archive en.stsw-stm8030.zip from ST is patches with
# - the SDCC patch from https://github.com/gicking/STM8-SPL_SDCC_patch
# - some local patches in patches/

TOPDIR=STM8TL5x_StdPeriph_Lib_V1.0.1
LIBDIR=STM8TL5x_StdPeriph_Driver

# unpack the STM8TL5x library
unzip zips/en.stsw-stm8030.zip 
chmod +w -R ${TOPDIR}

# apply Georg's patch:
patch -p0 < ../STM8-SPL_SDCC_patch/STM8TL5x_StdPeriph_Lib_V1.0.1.patch

# grab the needed files
mv ${TOPDIR}/Libraries/$LIBDIR .
rm -f $LIBDIR/*.chm
cp -a STM8TL5x_StdPeriph_Lib_V1.0.1/Projects/STM8TL5x_StdPeriph_Template/stm8tl5x_conf.h $LIBDIR/inc

# Linux only: correct the line endings from CRLF (DOS/Windows) to LF
if test $(uname) = Linux; then
	find $LIBDIR -name "*.[ch]"|xargs fromdos
fi

# apply all patches in order
for i in patches/tl5-*.patch; do
	patch -p1 < $i
done
