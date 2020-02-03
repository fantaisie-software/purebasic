#!/bin/bash
#Linux x64
#Create a copy of your purebasic folder and set the export PUREBASIC_HOME to that directory
#***the dirty part***
#Copy the files in purebasic/subsystems/gtk2/purelibraries into purbasic/purelibraries overwriting them
#this is to avoid it linking in a gtk3 lib which would result in the IDE crashing.
#Run this script to create the ide and standalone debugger
#on sucess
#modify the launch.sh add #export PUREBASIC_HOME="/home/yourusername/purebasic571copy" to 1st line
#then you can build and debug the ide without it conflicting with your installed purebasic.
export PUREBASIC_HOME="/home/andrew/purebasic1"
export PB_PROCESSOR=X64
export PB_ENABLE_GTK2=1
export PB_LIBRARIES="$PWD/Libraries"
export PB_BUILDTARGET="$PWD/Build/x64"
export PATH="$PUREBASIC_HOME/compilers:$PUREBASIC_HOME/sdk/pureunit:$PATH"
#For OGRE
export LD_LIBRARY_PATH=$PUREBASIC_HOME/compilers:$LD_LIBRARY_PATH
mkdir -p Build/x64
#we use -D_GNU_SOURCE to avoid __isoc99sprintf() etc. which is only glibc7
#we don't put -Winvalid-pch as we can temporarely put NO_UNICODE_ALIASES even for libs with precompiled headers
export PB_GCC_ANSI="gcc -D_GNU_SOURCE -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=0 -DLINUX -Wimplicit -fsigned-char -fno-ident -fshort-wchar -fno-optimize-sibling-calls -Wno-write-strings -Wno-pointer-sign -fno-stack-protector -Wno-deprecated-declarations -I$PB_LIBRARIES -D$PB_PROCESSOR"
export PB_GPP_ANSI="g++ -DLINUX -D_GNU_SOURCE -fPIC -fno-stack-protector -fsigned-char -fno-ident -fshort-wchar -Wno-write-strings -Wno-deprecated-declarations -I$PB_LIBRARIES -D$PB_PROCESSOR"
export PB_OGREFLAGS="-O2 -fvisibility=hidden -Wno-narrowing"
#We don't use -O3 for gcc, as it is known to be less performant in overall than -O2 (bigger code generation could not fit in small caches)
export PB_OPT_SPEED="-O2"
export PB_OPT_SIZE="-Os"
export PB_OBJ="o"
export PB_LIB="a"
export PB_OS="Linux"
export PB_NASM="nasm -f elf64 -O3 -DLINUX"
export PB_GCC_ANSI="$PB_GCC_ANSI -fPIC"
export PB_GPP_ANSI="$PB_GPP_ANSI -fPIC"
export PB_GCC="$PB_GCC_ANSI -DUNICODE"
export PB_GPP="$PB_GPP_ANSI -DUNICODE"
export PB_LINUX=1
export PB_ASM_HEADER="IncludeLinux"
export PATH=$PATH:$PUREBASIC_HOME/compilers
export PB_GTK=2
export PB_INCLUDE="-DGTK_2 `pkg-config --cflags gtk+-2.0`"
export PB_SUBSYSTEM=subsystems/gtk2/purelibraries/
export PB_TARGET_POSTFIX=
export PB_LIBRARYMAKER="pblibrarymaker /NOLOG /CONSTANT LINUX /CONSTANT $PB_PROCESSOR /CONSTANT GTK2"
cd PureBasicIDE
make ide
cd ../PureBasicDebugger
make GuiDebugger
