#!/bin/bash

# "asciidoc2html.sh"  by Tristano Ajmone                     v1.0.0 | 2020/11/25
#-------------------------------------------------------------------------------
# Convert to HTML all AsciiDoc files with extension "*.asciidoc" inside current
# folder. Requires Asciidoctor (Ruby) to be installed:
# 	https://asciidoctor.org
#-------------------------------------------------------------------------------

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
# Every document in current folder with extension "*.asciidoc":

for doc in *.asciidoc ; do
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
			$doc
done
