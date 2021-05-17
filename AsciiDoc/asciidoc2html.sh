#!/bin/bash

# "asciidoc2html.sh" by Tristano Ajmone                      v2.1.1 | 2020/12/10
#-------------------------------------------------------------------------------
# Convert to HTML an array of AsciiDoc files from the current folder to specific
# destination folders designated for each document.
# Requires Asciidoctor (Ruby) to be installed:
# 	https://asciidoctor.org
#-------------------------------------------------------------------------------

# ==============
# Documents List
# ==============
# Each source document and its destination folder are stored in an associative
# array (aka map or hash table). AsciiDoc source files must be stored without
# file extension (the "*.asciidoc" extension is implicitly assumed); all output
# paths are relative to the repository root folder.

declare -A docsL
docsL=( \
	["DocMaker-Help"]=Documentation \
	["DocMaker-Tags"]=Documentation \
	["PB-Documentation-Guide"]=Documentation \
	["PureUnit-Help"]=PureBasicIDE/sdk \
	["CompilerInterface"]=PureBasicIDE/sdk \
	["PB-Library-SDK"]=PureBasicIDE/sdk \
	["PB-DLL-Importer"]=PureBasicIDE/sdk \
)

# ==================
# Check Dependencies
# ==================
# Check that Asciidoctor is installed on the user machine:

if ! asciidoctor --version > /dev/null 2>&1 ; then
	echo -e "\033[31;1m~~~ ERROR! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	echo -e "\033[31;1mIn order to run this script you need to install Asciidoctor (Ruby):\n"
	echo -e "\033[31;1m\thttps://asciidoctor.org"
	echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\033[0m"
	echo -e "If you've already installed Ruby on your machine, type:\n"
	echo -e "\033[33;1m\tgem install asciidoctor"
	echo -e "\033[31;1m\n/// Aborting Conversion ///\033[0m"
	exit 1
fi

# ===============
# Convert to HTML
# ===============
# Convert every "*.asciidoc" document in the array, from the current folder, to
# its designated output folder.

for doc in "${!docsL[@]}"; do
	destDir=${docsL[$doc]}
	echo -e "\033[1;34m========================================================================"
	echo -e "\033[1;34mSource: \033[1;33m${doc}.asciidoc"
	echo -e "\033[1;34mTarget: \033[1;33m../$destDir/${doc}.html"
	echo -e "\033[1;34m========================================================================\033[1;30m"
	asciidoctor \
		--failure-level WARN \
		--timings \
		--verbose \
		--safe-mode unsafe \
		-a data-uri \
		-a experimental \
		-a icons=font \
		-a sectanchors \
		-a toc=left \
		-a reproducible \
		-D ../$destDir \
			${doc}.asciidoc
done

echo -e "\n\033[1;32m/// Finished ///"
