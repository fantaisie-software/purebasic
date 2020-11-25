# PureBasic - Windows import makefile
#

ifeq ($(PB_WINDOWS),1)
  IMPORTS = $(PUREBASIC_HOME)/PureLibraries/Windows
else
ifeq ($(PB_MACOS),1)
  IMPORTS = $(PUREBASIC_HOME)/PureLibraries/macos
else
  IMPORTS = $(PUREBASIC_HOME)/purelibraries/linux
endif
endif


OBJECTS = $(IMPORTS)/expat.imp \
          $(IMPORTS)/sqlite3.imp \
          $(IMPORTS)/opengl.imp \
          $(IMPORTS)/glu.imp \
          $(IMPORTS)/glut.imp \


ifeq ($(PB_WINDOWS),1)

all: $(OBJECTS)
	make --quiet --directory Windows

else
ifeq ($(PB_MACOS),1)

all: $(OBJECTS)
	make --quiet --directory MacOS

else

all: $(OBJECTS)
	make --quiet --directory Linux

endif
endif



ifeq ($(PB_WINDOWS),1)

# General rule to easily compile all imports.
#
$(IMPORTS)/%.imp : %.pb
	pbcompiler /QUIET $< /UNICODE /IMPORT "$@"
	pbcompiler /QUIET $< /IMPORT "$(IMPORTS)/Ansi/$*.imp"


else

$(IMPORTS)/%.imp : %.pb
	pbcompiler --quiet $< --import "$@"

endif


clean:
	rm -f $(OBJECTS)
