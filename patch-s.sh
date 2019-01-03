#!/bin/sh

# This script patches the original SPL files from ST for use with sduino.
#
# The archive en.stsw-stm8069.zip from ST is patches with
# - the SDCC patches from https://github.com/gicking/STM8-SPL_SDCC_patch
# - some local patches in patches/

# unpack the STM8S library
unzip  zips/en.stsw-stm8069.zip 
chmod +w -R .

# apply Georg's patch:
patch -p0 < ../STM8-SPL_SDCC_patch/STM8S_StdPeriph_Lib_V2.3.1_sdcc.patch 

# grab the needed files
mv STM8S_StdPeriph_Lib/Libraries/STM8S_StdPeriph_Driver .
rm STM8S_StdPeriph_Driver/stm8s-a_stdperiph_drivers_um.chm 
cp -a STM8S_StdPeriph_Lib/Project/STM8S_StdPeriph_Examples/GPIO/GPIO_Toggle/stm8s_conf.h STM8S_StdPeriph_Driver/inc/

# Linux only: correct the line endings from CRLF (DOS/Windows) to LF
if test $(uname) = Linux; then
	find -name "*.h"|xargs fromdos
	find -name "*.c"|xargs fromdos
fi

# apply all patches in order
for i in patches/*.patch; do
	patch -p1 < $i
done
