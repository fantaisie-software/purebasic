# PureBasic - Windows export makefile
#

EXPORTS = $(PUREBASIC_HOME)/PureLibraries/Windows/Libraries

OBJECTS = $(EXPORTS)/atl.lib \
					$(EXPORTS)/bdnapi.lib \
					$(EXPORTS)/cap.lib \
					$(EXPORTS)/ctl3d32.lib \
					$(EXPORTS)/d3dim.lib \
					$(EXPORTS)/d3drm.lib \
					$(EXPORTS)/d3dxof.lib \
					$(EXPORTS)/dapi.lib \
					$(EXPORTS)/ddraw.lib \
					$(EXPORTS)/dflayout.lib \
					$(EXPORTS)/dinput_a.lib \
					$(EXPORTS)/dlcapi.lib \
					$(EXPORTS)/dplay.lib \
					$(EXPORTS)/dplayx.lib \
					$(EXPORTS)/dsetup.lib \
					$(EXPORTS)/dsound.lib \
					$(EXPORTS)/edbbcli.lib \
					$(EXPORTS)/glut32.lib \
					$(EXPORTS)/hlink.lib \
					$(EXPORTS)/icmp.lib \
					$(EXPORTS)/mslsp32.lib \
          $(EXPORTS)/msvcrt.lib \
					$(EXPORTS)/nal.lib \
					$(EXPORTS)/ntdll.lib \
					$(EXPORTS)/penwin32.lib \
					$(EXPORTS)/rassapi.lib \
					$(EXPORTS)/shfolder.lib \
					$(EXPORTS)/url.lib \
					$(EXPORTS)/win32spl.lib \

all: $(OBJECTS)
	

# General rule to easily compile all imports.
#
$(EXPORTS)/%.lib : %.def
	polib /MACHINE:X64 /DEF:$< /OUT:"$@"

clean:
	rm -f $(OBJECTS)
