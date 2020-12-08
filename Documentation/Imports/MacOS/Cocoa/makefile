# PureBasic - MacOS import makefile
#

IMPORTS = $(PUREBASIC_HOME)/PureLibraries/macos

OBJECTS = $(IMPORTS)/accelerate.imp \
          $(IMPORTS)/appkit.imp \
          $(IMPORTS)/applicationservices.imp \
          $(IMPORTS)/audiounit.imp \
          $(IMPORTS)/corefoundation.imp \
          $(IMPORTS)/coreservices.imp \
          $(IMPORTS)/foundation.imp \
          $(IMPORTS)/iokit.imp \
          $(IMPORTS)/carbon.imp \

all: $(OBJECTS)
	pbcompiler residents.pb -q -r $(PUREBASIC_HOME)/residents/corecocoa.res -ir corecocoa.res


# General rule to easily compile all imports.
#
$(IMPORTS)/%.imp : %.pb
	pbcompiler --quiet $< --import "$(IMPORTS)/$*.imp"

clean:
	rm -f $(OBJECTS)
