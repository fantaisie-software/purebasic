# PureBasic - MacOS import makefile
#

IMPORTS = $(PUREBASIC_HOME)/PureLibraries/macos

OBJECTS =


all: $(OBJECTS)
	make --quiet --directory Cocoa
	make --quiet --directory ../Linux


# General rule to easily compile all imports.
#
$(IMPORTS)/%.imp : %.pb
	pbcompiler --quiet $< --import "$(IMPORTS)/$*.imp"

clean:
	rm -f $(OBJECTS)
