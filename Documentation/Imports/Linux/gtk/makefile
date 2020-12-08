# PureBasic - Linux import makefile
#

IMPORTS = $(PUREBASIC_HOME)/$(PB_SUBSYSTEM)/linux


OBJECTS = $(IMPORTS)/gdk.imp \
          $(IMPORTS)/glib.imp \
          $(IMPORTS)/gtk.imp \
          $(IMPORTS)/gobject.imp \


all: $(OBJECTS)
	


# General rule to easily compile all imports.
#
$(IMPORTS)/%.imp : %.pb
	pbcompiler --quiet $< --constant PB_GTK=$(PB_GTK) --import "$(IMPORTS)/$*.imp"

clean:
	rm -f $(OBJECTS)
