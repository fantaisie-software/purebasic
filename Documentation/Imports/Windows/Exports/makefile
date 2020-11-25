# PureBasic - Windows export makefile
#

EXPORTS = $(PUREBASIC_HOME)/PureLibraries/Windows/Libraries

OBJECTS = $(EXPORTS)/version.lib \
          $(EXPORTS)/aclui.lib \
          $(EXPORTS)/activeds.lib \
          $(EXPORTS)/advapi32.lib \
          $(EXPORTS)/atl.lib \
          $(EXPORTS)/bdnapi.lib \
          $(EXPORTS)/cap.lib \
          $(EXPORTS)/comctl32.lib \
          $(EXPORTS)/comdlg32.lib \
          $(EXPORTS)/crypt32.lib \
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
          $(EXPORTS)/gdi32.lib \
          $(EXPORTS)/glu32.lib \
          $(EXPORTS)/glut32.lib \
          $(EXPORTS)/hlink.lib \
          $(EXPORTS)/icmp.lib \
          $(EXPORTS)/icmui.lib \
          $(EXPORTS)/imagehlp.lib \
          $(EXPORTS)/imm32.lib \
          $(EXPORTS)/iphlpapi.lib \
          $(EXPORTS)/loadperf.lib \
          $(EXPORTS)/lz32.lib \
          $(EXPORTS)/mapi32.lib \
          $(EXPORTS)/mpr.lib \
          $(EXPORTS)/mprapi.lib \
          $(EXPORTS)/msacm32.lib \
          $(EXPORTS)/mscms.lib \
          $(EXPORTS)/msi.lib \
          $(EXPORTS)/msimg32.lib \
          $(EXPORTS)/mslsp32.lib \
          $(EXPORTS)/nal.lib \
          $(EXPORTS)/netapi32.lib \
          $(EXPORTS)/ntdll.lib \
          $(EXPORTS)/ntmsapi.lib \
          $(EXPORTS)/odbc32.lib \
          $(EXPORTS)/odbccp32.lib \
          $(EXPORTS)/ole32.lib \
          $(EXPORTS)/oleaut32.lib \
          $(EXPORTS)/oledlg.lib \
          $(EXPORTS)/opengl32.lib \
          $(EXPORTS)/pdh.lib \
          $(EXPORTS)/penwin32.lib \
          $(EXPORTS)/rasapi32.lib \
          $(EXPORTS)/rasdlg.lib \
          $(EXPORTS)/rassapi.lib \
          $(EXPORTS)/resutils.lib \
          $(EXPORTS)/rpcns4.lib \
          $(EXPORTS)/rpcrt4.lib \
          $(EXPORTS)/rtm.lib \
          $(EXPORTS)/secur32.lib \
          $(EXPORTS)/setupapi.lib \
          $(EXPORTS)/shell32.lib \
          $(EXPORTS)/shfolder.lib \
          $(EXPORTS)/shlwapi.lib \
          $(EXPORTS)/snmpapi.lib \
          $(EXPORTS)/tapi32.lib \
          $(EXPORTS)/url.lib \
          $(EXPORTS)/urlmon.lib \
          $(EXPORTS)/user32.lib \
          $(EXPORTS)/userenv.lib \
          $(EXPORTS)/uxtheme.lib \
          $(EXPORTS)/win32spl.lib \
          $(EXPORTS)/winfax.lib \
          $(EXPORTS)/wininet.lib \
          $(EXPORTS)/winmm.lib \
          $(EXPORTS)/wintrust.lib \
          $(EXPORTS)/wsock32.lib \
          $(EXPORTS)/ws2_32.lib \


all: $(OBJECTS)
	

ifeq ($(PB_PROCESSOR),X64)
  LINKER_FORMAT=X64
else
  LINKER_FORMAT=X86
endif


# General rule to easily compile all imports.
#
$(EXPORTS)/%.lib : %.def
	polib /MACHINE:$(LINKER_FORMAT) /DEF:$< /OUT:"$@"

clean:
	rm -f $(OBJECTS)
