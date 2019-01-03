#!/bin/bash

STEM=stm8tl5x

## parameter check

if [ $# -ne 1 ]; then
	cat << "EOF"
split the library into individual source files for every single function,
compile them seperately and pack them all together into one big library.

usage: $0 cputype

supported cpu types as found in inc/$STEM.h:
EOF
	grep defined inc/$STEM.h|fmt -1|sed -n 's,.*(STM8,\tSTM8,p'|sed 's,).*,,'|sort|uniq
	exit 1
fi

CPU=$1


### main part starts here


# define the compile parameter
CC="sdcc"
AR="sdar"
CFLAGS="-mstm8 -D${CPU} -I ../inc -I ../src --opt-code-size -I."
LDFLAGS="-rc"

BUILDDIR="build-${CPU}"



# name of the library: $CPU.lib in lower case
#
# for POSIX compliance (busybox compatibility) pipe through 'tr' instead of
# using 'LIBRARY=${CPU,,}.lib' (bash only)
#LIBRARY=$(echo ${CPU}|tr '[:upper:]' '[:lower:]').lib
LIBRARY=${CPU}.lib

# check the dependencies, generate the list of needed c source files
HFILES=$($CC -mstm8 -Iinc -Isrc -D$CPU "-Wp-MM" -E inc/$STEM.h|\
	fmt -1|\
	sed -n "s, *inc/${STEM}_,${STEM}_,p")
CFILES=${HFILES//.h/.c}
# remove (the non-existing) stm8tl5x_conf.c from the list of c files:
CFILES=${CFILES//${STEM}_conf.c/}

# debug output
echo "Needed source code modules for CPU $CPU:"
echo $CFILES
echo "Library name: $LIBRARY"
echo "cflags: $CFLAGS"


# the most important function: split on c source file in to a collection
# of single-function source files.
#
# The split is done on every line with only "/**" (the beginning of a
# doxygen comment header). The first section always contains the module
# internal definitions and prototypes. It is saved as a .h file that will be
# included by all the other parts.
#
# For busybox compatibility this awk script does not use the gawk extention
# BEGINFILE.
splitit() {
	awk -e '
# beginning (first line) of a new file
FNR==1 {
	# start a new output file: generate a .h file
	sub(".*/","",FILENAME)		# remove directory prefix
	n=0;				# reset parts counter
	print "split",FILENAME;
	file=FILENAME ".h";# generate .h file first
}

# action in lines with only "/**"
# (but ignore the sparator at the start of a file)
/\/\*\*$/ && (FNR>1) {
	# start a new part
	n++;
	file=FILENAME "-" n ".c";
	print "#include \"" FILENAME ".h\"">file
}

# default action for every line
{
	print >file			# copy line into output file
}' $*
}


# prepare a fresh build directory
#BUILDDIR=$(mktemp -dp.)
rm -rf $BUILDDIR
mkdir $BUILDDIR
cd $BUILDDIR
echo "using $BUILDDIR"

# split all needed source files into single-function source files
for i in $CFILES; do
	splitit ../src/$i
done

# compile all split files
#cp ../compilelib.mk Makefile
#make CPU=$CPU
for i in ${STEM}_*.c; do
	echo "compiling $i"
	${CC} ${CFLAGS} -c $i || break
done

# build the library
mkdir -p ../lib
${AR} ${LDFLAGS} ../lib/${LIBRARY} *.rel

# get the generated library
#mv *.lib ..
