
# Put . /home/yourname/therightpath/EnvironmentVariables.bash OSNAME in your ~/.bashrc
#

# Optional environment variable:
#
# PB_POWERPC_GCC4=1   ; set this to use gcc on OSX for ppc compilation as well
# PB_COCOA=1          ; set this to build cocoa libs on OSX (instead of Carbon)
#

if [ "x$1" == "x" ]; then
	echo "[PureBasic] The OSNAME parameter must be specified for EnvironmentVariables.bash"
fi

if [ "x$PB_PROCESSOR" == "x" ]; then
	echo "[PureBasic] PB_PROCESSOR environment variable not declared."
fi

if [ "x$PUREBASIC_HOME" == "x" ]; then
	echo "[PureBasic] PUREBASIC_HOME environment variable not declared."
fi

if [ "x$PB_LIBRARIES" == "x" ]; then
	echo "[PureBasic] PB_LIBRARIES environment variable not declared."
fi

if [ "x$PB_BUILDTARGET" == "x" ]; then
	echo "[PureBasic] PB_BUILDTARGET environment variable not declared."
fi

##############################################################################################
#
# For Linux
#
##############################################################################################

if [ "$1" == "LINUX" ]; then

# we use -D_GNU_SOURCE to avoid __isoc99sprintf() etc. which is only glibc7
# we don't put -Winvalid-pch as we can temporarily put NO_UNICODE_ALIASES even for libs with precompiled headers
export PB_GCC_ANSI="gcc -D_GNU_SOURCE -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=0 -DLINUX -Wimplicit -fsigned-char -fno-ident -fshort-wchar -fno-optimize-sibling-calls -Wno-write-strings -Wno-pointer-sign -fno-stack-protector -Wno-deprecated-declarations -I$PB_LIBRARIES -D$PB_PROCESSOR"
export PB_GPP_ANSI="g++ -DLINUX -D_GNU_SOURCE -fPIC -fno-stack-protector -fsigned-char -fno-ident -fshort-wchar -Wno-write-strings -Wno-deprecated-declarations -I$PB_LIBRARIES -D$PB_PROCESSOR"
export PB_OGREFLAGS="-O2 -fvisibility=hidden -Wno-narrowing"
# We don't use -O3 for gcc, as it is known to be less performant in overall than -O2 (bigger code generation could not fit in small caches)
export PB_OPT_SPEED="-O2"
export PB_OPT_SIZE="-Os"
export PB_OBJ=o
export PB_LIB=a
export PB_OS=Linux

if [ "$PB_PROCESSOR" == "X64" ]; then
	export PB_NASM="nasm -f elf64 -O3 -DLINUX"
	export PB_GCC_ANSI="$PB_GCC_ANSI -fPIC"
	export PB_GPP_ANSI="$PB_GPP_ANSI -fPIC"
else
	export PB_NASM="nasm -f elf -O3 -DLINUX"
fi

export PB_GCC="$PB_GCC_ANSI -DUNICODE"
export PB_GPP="$PB_GPP_ANSI -DUNICODE"

export PB_LINUX=1
export PB_ASM_HEADER="IncludeLinux"

export PATH=$PATH:$PUREBASIC_HOME/compilers

# For GTK1, it is now overridden by the GTK2 config just below
# No gtk-config on modern linux systems, so comment this
#
#export PB_GTK=1
#export PB_INCLUDE=`gtk-config --cflags`
#export PB_CARBON=0
#export PB_SUBSYSTEM="subsystems/gtk1/purelibraries/"

# Reset all subsystems (so the script can be called several time in the same bash)
unset PB_QT
unset PB_GTK

if [ "$PB_ENABLE_QT" == "1" ]; then
	echo "Using Qt"
	export PB_QT=1
	export PB_INCLUDE="-DQT -DQT_NO_VERSION_TAGGING -I`qmake -query QT_INSTALL_HEADERS`"
	export PB_SUBSYSTEM=subsystems/qt/purelibraries/
	export PB_LIBRARYMAKER="pblibrarymaker /NOLOG /CONSTANT LINUX /CONSTANT $PB_PROCESSOR /CONSTANT QT"
	export PB_MOC="moc -DLINUX -D_GNU_SOURCE -DQT -DQT_NO_VERSION_TAGGING -DUNICODE"
	export PB_TARGET_POSTFIX=_qt
elif [ "$PB_ENABLE_GTK2" == "1" ]; then
	echo "Using GTK2"
	export PB_GTK=2
	export PB_INCLUDE="-DGTK_2 `pkg-config --cflags gtk+-2.0`"
	export PB_SUBSYSTEM=subsystems/gtk2/purelibraries/
	export PB_TARGET_POSTFIX=
	export PB_LIBRARYMAKER="pblibrarymaker /NOLOG /CONSTANT LINUX /CONSTANT $PB_PROCESSOR /CONSTANT GTK2"
else
	echo "Using GTK3"
	export PB_GTK=3
	export PB_INCLUDE="-DGTK_2 -DGTK_3 `pkg-config --cflags gtk+-3.0`"
	export PB_SUBSYSTEM=purelibraries/
	export PB_TARGET_POSTFIX=_gtk3
	export PB_LIBRARYMAKER="pblibrarymaker /NOLOG /CONSTANT LINUX /CONSTANT $PB_PROCESSOR /CONSTANT GTK2 /CONSTANT GTK3"
fi

fi

##############################################################################################
#
# For OS X
#
##############################################################################################

if [ $1 == "OSX" ]; then

if [ $PB_PROCESSOR == "X86" ]; then
	export PB_GCC_ANSI="gcc -arch i386 -mmacosx-version-min=10.8 -DMAC_OS_X_VERSION_MIN_REQUIRED=1080 -DMAC_OS_X_VERSION_MAX_ALLOWED=1080 -DPB_MACOS -Winvalid-pch -Wno-deprecated-declarations -Wimplicit -fno-common -fsigned-char -fshort-wchar -Wno-multichar -fno-optimize-sibling-calls -Wno-pointer-sign -Wno-parentheses -Wno-write-strings -I$PB_LIBRARIES -D$PB_PROCESSOR"
	export PB_GCC="$PB_GCC_ANSI -DUNICODE"
	export PB_GPP_ANSI="g++ -arch i386 -mmacosx-version-min=10.8 -DMAC_OS_X_VERSION_MIN_REQUIRED=1080 -DMAC_OS_X_VERSION_MAX_ALLOWED=1080 -DPB_MACOS -Winvalid-pch -Wno-deprecated-declarations -Wimplicit -fsigned-char -fshort-wchar -Wno-multichar  -Wno-parentheses -Wno-write-strings -I$PB_LIBRARIES -D$PB_PROCESSOR"
	export PB_GPP="$PB_GPP_ANSI -DUNICODE"

	export PB_NASM="nasm -O3 -f macho -DMACOS"
	export PB_OGREFLAGS="-O2 -fvisibility=hidden"

elif [ $PB_PROCESSOR == "X64" ]; then
	export PB_GCC_ANSI="gcc -arch x86_64 -m64 -stdlib=libc++ -mmacosx-version-min=10.8 -DMAC_OS_X_VERSION_MIN_REQUIRED=1080 -DMAC_OS_X_VERSION_MAX_ALLOWED=1080 -DPB_MACOS -Winvalid-pch -Wno-deprecated-declarations -Wimplicit -fno-common -fsigned-char -fshort-wchar -Wno-multichar -fno-optimize-sibling-calls -Wno-pointer-sign -Wno-parentheses -Wno-write-strings -I$PB_LIBRARIES -D$PB_PROCESSOR"
	export PB_GCC="$PB_GCC_ANSI -DUNICODE"
	export PB_GPP_ANSI="g++ -arch x86_64 -m64 -stdlib=libc++ -mmacosx-version-min=10.8 -DMAC_OS_X_VERSION_MIN_REQUIRED=1080 -DMAC_OS_X_VERSION_MAX_ALLOWED=1080 -DPB_MACOS -Winvalid-pch -Wno-deprecated-declarations -Wimplicit -fsigned-char -fshort-wchar -Wno-multichar -Wno-parentheses -Wno-write-strings -I$PB_LIBRARIES -D$PB_PROCESSOR"
	export PB_GPP="$PB_GPP_ANSI -DUNICODE"

	export PB_NASM="yasm -O3 -f macho64 -DMACOS"
	export PB_OGREFLAGS="-O2 -fvisibility=hidden -stdlib=libstdc++"
fi

export PB_OPT_SPEED="-O2"
export PB_OPT_SIZE="-Os"
export PB_LIBRARY_NOLIBELF=1
export PB_MACOS=1
export PB_OBJ=o
export PB_LIB=a

if [ "x$PB_COCOA" == "x" ]; then
	export PB_INCLUDE=-DPB_CARBON
	export PB_LIBRARYMAKER="pblibrarymaker /NOLOG /CONSTANT CARBON /CONSTANT MACOS /CONSTANT $PB_PROCESSOR"
	export PB_SUBSYSTEM=subsystems/carbon/purelibraries/

	export PB_CARBON=1
	export PB_TARGET_POSTFIX=
	echo "Using Carbon subsystem"
else
	export PB_INCLUDE=-DPB_COCOA
	export PB_LIBRARYMAKER="pblibrarymaker /NOLOG /CONSTANT COCOA /CONSTANT MACOS /CONSTANT $PB_PROCESSOR"
	export PB_SUBSYSTEM=purelibraries/

	# in the makefiles we check for =1, so make sure it is set to that
	export PB_COCOA=1
	export PB_TARGET_POSTFIX=_cocoa
	export PB_CARBON= # remove the carbon env var, if set
	echo "Using Cocoa subsystem"
fi

fi


##############################################################################################
#
# For Windows (used by the build server)
#
##############################################################################################


# NOTE: we use /Oi /Ot /Oy /Ob2 /Gs /GF /Gy instead of /O2 to omit /Og which breaks the stack on return ('int PreviousPosition' is changed on the caller stack !)
# NOTE2: we have to use /O2, or all the optimizations will be gone (/Og is the main switch here). We we can't use the above trick. Too bad.
# NOTE3: The DX sdk -I should be after the others, as it may create weird errors else.
#
# WARNING ! When putting a PATH in windows, you have to remove the '"' around long path name and change the '\' in '/'
# or you will have problem with makefile (command 'cl' not found..)
#
# PB_PROCESSOR=X86 or PB_PROCESSOR=X64


if [ $1 == "WINDOWS" ]; then

	# C:/Program Files (x86)/Microsoft Visual Studio 8
	if [ "x$PB_VS8" == "x" ]; then
		echo "[PureBasic] PB_VS8 environment variable not declared."
	fi

	# C:/Program Files (x86)/Microsoft Platform SDK
	if [ "x$PB_PLATEFORM_SDK" == "x" ]; then
		echo "[PureBasic] PB_PLATEFORM_SDK environment variable not declared."
	fi

	# C:/Program Files (x86)/Microsoft DirectX 7.0 SDK (December 2004)
	if [ "x$PB_DIRECTX7_SDK" == "x" ]; then
		echo "[PureBasic] PB_DIRECTX7_SDK environment variable not declared."
	fi

	# C:/Program Files (x86)/Microsoft DirectX 9.0 SDK (August 2009)
	if [ "x$PB_DIRECTX9_SDK" == "x" ]; then
		echo "[PureBasic] PB_DIRECTX9_SDK environment variable not declared."
	fi

	if [ $PB_PROCESSOR == "X86" ]; then
		export PB_VC8_ANSI="cl.exe -I\"$PB_VS8/VC/include\" -I"$PB_LIBRARIES" -DWINDOWS -DVISUALC -D_USING_V110_SDK71_ -DX86 -I\"$PB_PLATEFORM_SDK/Include\" -I\"$PB_PLATEFORM_SDK/Include/crt\" -I. -I\"$PB_DIRECTX9_SDK/Include\" -I\"$PB_DIRECTX7_SDK/Include\" /nologo /arch:IA32 /GS- /D_CRT_NOFORCE_MANIFEST /D_USE_32BIT_TIME_T"
		export PB_VC8="$PB_VC8_ANSI -DUNICODE"
		export PB_NASM="nasm -DWINDOWS -fwin32 -O3"
		export PB_LINKER=polink
		export PB_LIBRARIAN=polib
		export PB_LIBRARYMAKER="\"$PUREBASIC_HOME/SDK/LibraryMaker.exe\" /NOLOG /COMPRESSED /CONSTANT WINDOWS /CONSTANT $PB_PROCESSOR"
		export PB_IOFIX="-D__iob_func=__p__iob -D_gmtime32=gmtime -D_mktime32=mktime"
	else
		export PB_VC8_ANSI="cl.exe -I\"$PB_VS8/VC/include\" -I"$PB_LIBRARIES" -DWINDOWS -DVISUALC -D_USING_V110_SDK71_ -DX64 -DPB_64 -I\"$PB_PLATEFORM_SDK/Include\" -I\"$PB_PLATEFORM_SDK/Include/crt\" -I. -I\"$PB_DIRECTX9_SDK/Include\" -I\"$PB_DIRECTX7_SDK/Include\" /nologo /GS- /D_CRT_NOFORCE_MANIFEST"
		export PB_VC8="$PB_VC8_ANSI -DUNICODE"
		export PB_NASM="nasm -DWINDOWS -fwin64 -O3"
		export PB_LIBRARIAN="lib /nologo"
		export PB_LIBRARYMAKER="\"$PUREBASIC_HOME/SDK/LibraryMaker.exe\" /NOLOG /CONSTANT WINDOWS /CONSTANT $PB_PROCESSOR"
		export PB_IOFIX=
	fi

	export PB_OGRELIBRARIAN="lib /NOLOGO"
	export PB_WINDOWS=1
	export PB_OBJ=obj
	export PB_LIB=lib

	# set a default subsystem
	export PB_SUBSYSTEM=purelibraries/

	if [ "x$PB_JAVASCRIPT" == "x1" ]; then
		export PB_LIBRARYMAKER="\"$SPIDERBASIC_HOME/SDK/LibraryMaker.exe\" /COMPRESSED /NOLOG /CONSTANT JAVASCRIPT"
		export PB_SUBSYSTEM=libraries/
	fi
fi
