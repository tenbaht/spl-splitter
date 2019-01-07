#!/bin/sh

# This script patches the original SPL files from ST for use with sduino.
#
# This part patches the SPL for the STM8S series.
#
# The archive en.stsw-stm8069.zip from ST is patches with
# - the SDCC patch from https://github.com/gicking/STM8-SPL_SDCC_patch
# - some local patches in patches/

TOPDIR=STM8S_StdPeriph_Lib
LIBDIR=STM8S_StdPeriph_Driver

# unpack the STM8S library
unzip zips/en.stsw-stm8069.zip 
chmod +w -R ${TOPDIR}

# apply Georg's patch:
patch -p0 < STM8-SPL_SDCC_patch/STM8S_StdPeriph_Lib_V2.3.1_sdcc.patch

# grab the needed files
mv ${TOPDIR}/Libraries/$LIBDIR .
rm -f $LIBDIR/*.chm
cp -a STM8S_StdPeriph_Lib/Project/STM8S_StdPeriph_Examples/GPIO/GPIO_Toggle/stm8s_conf.h $LIBDIR/inc

# Linux only: correct the line endings from CRLF (DOS/Windows) to LF
if test $(uname) = Linux; then
	find $LIBDIR -name "*.[ch]"|xargs fromdos
fi

# apply all patches in order
for i in patches/stm8s-*.patch; do
	patch -p1 < $i
done
