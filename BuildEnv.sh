#!/bin/bash

# ************************************************************************
# *         Setup the build Environment for builds on Linux/OSX          *
# ************************************************************************
#
# Run this script to setup a command shell with the proper environment
# variables required for building the IDE and other programs in this
# repository.
#
# The commandline for execution of this script is the following:
#
#    ./BuildEnv.sh <TargetPureBasicDirectory>
#
# For inclusion into the .bashrc file or other scripts, it can be sourced:
#
#    . BuildEnv.sh <TargetPureBasicDirectory>
#
# The <TargetPureBasicDirectory> parameter is mandatory. It specifies
# the compiler to use and building the IDE will actually override
# the IDE and other resources within that target directory. It is
# therefore recommended to setup a dedicated PB installation for
# IDE development and testing.
#
# If the target directory is a SpiderBasic installation, the SB IDE
# will be built instead. Note that for this case you will need a
# regular PB installation available in the PATH as well.
#
# By default this script will launch a command shell with the build
# environment. You can suppress this by setting the PB_BATCH=1 env
# variable before running this script. Alternatively, if you source the
# script into another script, the automatic shell creation is disabled.
#
# The used operating system as well as other needed settings are detected
# automatically. The following options can be set manually for further
# customization:
#
#    PB_SUBSYSTEM=<path to subsystem folder>
#
#      Specify the subsystem subfolder for compilation of residents
#      or import definitions. This setting is not needed to compile the
#      IDE or debugger
#
#    PB_GTK=2
#
#      Specify to use Gtk2 for IDE and debugger build. Gtk3 is default
#
# ************************************************************************


# Test mandatory PureBasic path parameter
if [ -z "$1" ]; then
	echo "Invalid parameters: Missing argument for target PureBasic directory"
	exit 1
fi


# Set PUREBASIC_HOME and ensure compiler and IDE are in the PATH
export PUREBASIC_HOME=$1
export PATH="$PUREBASIC_HOME/compilers:$PUREBASIC_HOME:$PATH"


# Test if the PureBasic home is valid and check if this is PB or SB
if [ -f "$PUREBASIC_HOME/compilers/pbcompiler" ]; then

	unset PB_JAVASCRIPT

	# Detect processor architecture
	$PUREBASIC_HOME/compilers/pbcompiler --version | grep -q "x64"
	if [ $? == 0 ]; then
		export PB_PROCESSOR=X64
	else
		export PB_PROCESSOR=X86
	fi

	echo "Setting environment for PureBasic $PB_PROCESSOR in $PUREBASIC_HOME"
	echo

elif [ -f "$PUREBASIC_HOME/compilers/sbcompiler" ]; then

	export PB_JAVASCRIPT=1

	echo "Setting environment for SpiderBasic in $PUREBASIC_HOME"
	echo

else
	echo "Failed to detect PB or SB compiler in $PUREBASIC_HOME"
	exit 1
fi


# Detect the OS used
if [ "$(uname -s)" == "Darwin" ]; then
	export PB_MACOS=1
else
	export PB_LINUX=1
fi


# Subsystem for Imports/Residents compilation (not neede for the IDE build)
# Default is no subsystem
export PB_SUBSYSTEM=${PB_SUBSYSTEM-purelibraries/}

# Specify GTK Version to use (default is Gtk2 for now)
export PB_GTK=${PB_GTK-3}


# Start shell if the script is not sourced and PB_BATCH is not set
if [ -z "$PB_BATCH" ] && [ "$0" = "$BASH_SOURCE" ]; then
	bash
fi


