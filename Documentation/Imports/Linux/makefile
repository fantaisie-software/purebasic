# PureBasic - Linux import makefile
#

ifeq ($(PB_MACOS),1)
  IMPORTS = $(PUREBASIC_HOME)/PureLibraries/macos
else
  IMPORTS = $(PUREBASIC_HOME)/purelibraries/linux
endif


OBJECTS = $(IMPORTS)/glibc.imp \
          $(IMPORTS)/pthread.imp \



ifeq ($(PB_LINUX),1)

  OBJECTS += $(IMPORTS)/sdl.imp \

 
endif


all: $(OBJECTS)
	


# General rule to easily compile all imports.
#
$(IMPORTS)/%.imp : %.pb
	pbcompiler --quiet $< --import "$(IMPORTS)/$*.imp"

clean:
	rm -f $(OBJECTS)
