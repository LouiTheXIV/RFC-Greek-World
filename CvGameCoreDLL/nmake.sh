#!/bin/bash
#Author: bluepotato
#This script is released into the public domain.
#A small addition to nmake; its linking step with wine 1.7 fails every time
#(for me, at least), so this script does the linking manually.
#This only works with Danny Daemonic's makefile (1.0). Since compile.sh has
#been completely rewritten and I won't use this in the future, I'll only leave
#it here for future reference.
#The currently included makefile (2.5) most likely won't work with this.

#You might want to change these variables here:
wine17="$HOME/.wine_versions/linux-x86/1.7.55/bin/wine" #Your wine 1.7.55 installation directory.
PSDK="C:\Program Files\Microsoft Platform SDK"
VCTOOLKIT="C:\Program Files\Microsoft Visual C++ Toolkit 2003"
DLLOUTPUT="../Assets/CvGameCoreDLL.dll"

#You probably don't have to change these:
ARGS=$#
#Default to Release.
if (( $ARGS<1 )); then
	TARGET=Release
elif test $1 = "Release" || test $1 = "Debug"; then
	TARGET=$1
else
	echo "Invalid target: $1"
	exit 2
fi

echo "TARGET: $TARGET"

#Your wineprefix for compilation.
export WINEPREFIX="$HOME/compile_linux"

#Clean mode.
if test "$2" = "clean"; then
	rm -rf ./"$TARGET"
fi

#Use nmake to compile the files.
$wine17 "$PSDK\Bin\nmake" $TARGET

#Make a list of files to link.
FILES=""
for FILE in $(ls $TARGET)
do
	if [[ $FILE == *.obj ]]; then
		FILES="$FILES $TARGET/$FILE"
	fi
done

echo "FILES: $FILES"

PDB=$TARGET"\CvGameCoreDLL.pdb"
IMPLIB=$TARGET"\CvGameCoreDLL.lib"

GLOBALFLAGS="$FILES /SUBSYSTEM:WINDOWS /LARGEADDRESSAWARE /TLBID:1 /DLL /NOLOGO /PDB:$PDB"
DEBUGFLAGS="$GLOBALFLAGS /DEBUG /INCREMENTAL /IMPLIB:$IMPLIB"
RELEASEFLAGS="$GLOBALFLAGS /INCREMENTAL:NO /OPT:REF /OPT:ICF"


#Create a DLL.
if test $TARGET = "Release"; then #For Release:
	$wine17 "$VCTOOLKIT\bin\link.exe" /LIBPATH:Python24/libs /LIBPATH:"boost-1.32.0/libs" /LIBPATH:"$VCTOOLKIT\lib" /LIBPATH:"$PSDK\Lib" /out:"../Assets/CvGameCoreDLL.dll" "boost-1.32.0\libs\boost_python-vc71-mt-1_32.lib" winmm.lib user32.lib "$VCTOOLKIT\lib\msvcprt.lib" "$VCTOOLKIT\lib\msvcrt.lib" "Python24\libs\python24.lib" "$VCTOOLKIT\lib\OLDNAMES.lib" $RELEASEFLAGS
elif test $TARGET = "Debug"; then #For Debug:
	$wine17 "$VCTOOLKIT/bin/link.exe" /LIBPATH:"boost-1.32.0\libs" /LIBPATH:"$VCTOOLKIT\lib" /LIBPATH:"$PSDK\Lib" /out:"../Assets/CvGameCoreDLL.dll" "boost-1.32.0\libs\boost_python-vc71-mt-1_32.lib" winmm.lib user32.lib "$VCTOOLKIT\lib\msvcprt.lib" "$VCTOOLKIT\lib\msvcrt.lib" "Python24\libs\python24.lib" "$VCTOOLKIT\lib\OLDNAMES.lib" "$PSDK\Lib\AMD64\msvcprtd.lib" $DEBUGFLAGS
else #We should never get here.
	echo "ERROR: Wrong target " $TARGET
	exit 2
fi

echo "Done!"
