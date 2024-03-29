#!/bin/bash

# "validate.sh"  by Tristano Ajmone                          v3.2.0 | 2022/05/15
#-------------------------------------------------------------------------------
# 1. Check that PureBasic sources don't contain saved IDE settings.
# 2. Validate code style consistency in the repository via EditorConfig settings
#    and the EClint validator tool:
#      https://editorconfig.org
#      https://www.npmjs.com/package/eclint
#-------------------------------------------------------------------------------

# *******************************************
# 1. Check PureBasic Sources for IDE Settings
# *******************************************

echo -e "\n\033[34;1m==========================================="
echo -e "\033[33;1mChecking PureBasic Sources for IDE Settings "
echo -e "\033[34;1m===========================================\033[0m"

tmpLog=$(mktemp)
passed=true

# Change Internal Field Separator ($IFS) to handle filenames with spaces:
IFS_COPY=$IFS
IFS=$(echo -en "\n\b")

for pbfile in $(find . 	-name '*.pb'  -o \
						-name '*.pbi' -o \
						-name '*.pbf' );
do
	result="$(grep -c '^; IDE Options =' $pbfile)"
	if [ "$result" != "0" ] ; then
		echo "$pbfile" >> $tmpLog
		passed=
	fi
done
IFS=$IFS_COPY # Restore original IFS!

if [ "$passed" != true ] ; then
	echo -e "\033[31;1m~~~ ERROR! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	echo -e "\033[31;1mThe following files contain IDE settings:\n\033[33;1m"
	cat $tmpLog
	rm $tmpLog
	echo -e "\033[31;1m\nPlease change your PureBasic IDE preferences for:"
	echo -e "\033[37;1m    Editor \033[34;1m>\033[37;1m Save Settings to \033[34;1m>\033[37;1m The end of the source file"
	echo -e "\033[31;1mto some other option in order to prevent this from happening."
	echo -e "\033[31;1m~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	echo -e "\033[31;1m/// Aborting All Tests ///\033[0m"
	exit 1
fi
echo -e "\033[32;1m/// Test Passed ///\033[0m"
rm $tmpLog

# *******************************************
# 2. Check Sources for Code Style Consistency
# *******************************************

echo -e "\n\033[34;1m================================================"
echo -e "\033[33;1mValidating Code Styles via EditorConfig Settings"
echo -e "\033[34;1m================================================\033[0m"

# ==================
# Check Dependencies
# ==================
# Since the script might also be run locally by end users, check that EClint is
# installed on the user machine:

if eclint --version > /dev/null 2>&1 ; then
	echo -e "Using:"
	echo -e "\033[34;1m*\033[35m Node.js $(node -v)"
	echo -e "\033[34;1m*\033[35m EClint v$(eclint --version).\n\033[31;1m"
else
	echo -e "\033[31;1m~~~ ERROR! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	echo -e "\033[31;1mIn order to run this script you need to install EClint (Node.js):\n"
	echo -e "\033[31;1m\thttps://www.npmjs.com/package/eclint"
	echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\033[0m"
	echo -e "If you've already installed Node.js on your machine, type:\n"
	echo -e "\033[33;1m\tnpm install -g eclint"
	echo -e "\033[31;1m\n/// Aborting All Tests ///\033[0m"
	exit 1
fi

# ==============
# Validate Files
# ==============
# Check that project files meet the code style standards set in `.editorconfig`;
# if not, print only the list of files that failed -- because EClint reports are
# usually too long.

tmpLog=$(mktemp)
eclint check 2> $tmpLog || {
	echo -e "\033[31;1m~~~ ERROR! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~";
	echo -e "\033[31;1mThe following files didn't pass the validation test:\n\033[33;1m";
	cat $tmpLog | grep  "^[^ ]";
	echo -e "\033[31;1m\nRun ECLint locally for detailed information about the problems.";
	echo -e "\033[31;1m~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~";
	echo -e "\033[31;1m/// Aborting All Tests ///\033[0m";
	rm $tmpLog;
	exit 1;
	}
rm $tmpLog;
echo -e "\033[32;1m/// Test Passed ///\033[0m"
exit

# EOF #
