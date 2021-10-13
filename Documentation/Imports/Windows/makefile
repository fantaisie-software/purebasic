# PureBasic - Windows import makefile
#

IMPORTS = $(PUREBASIC_HOME)/PureLibraries/Windows

OBJECTS = $(IMPORTS)/version.imp \
          $(IMPORTS)/aclui.imp \
          $(IMPORTS)/activeds.imp \
          $(IMPORTS)/advapi32.imp \
          $(IMPORTS)/atl.imp \
          $(IMPORTS)/bdnapi.imp \
          $(IMPORTS)/cap.imp \
          $(IMPORTS)/comctl32.imp \
          $(IMPORTS)/comdlg32.imp \
          $(IMPORTS)/crypt32.imp \
          $(IMPORTS)/ctl3d32.imp \
          $(IMPORTS)/d3dim.imp \
          $(IMPORTS)/d3drm.imp \
          $(IMPORTS)/d3dxof.imp \
          $(IMPORTS)/dapi.imp \
          $(IMPORTS)/ddraw.imp \
          $(IMPORTS)/dflayout.imp \
          $(IMPORTS)/dinput_a.imp \
          $(IMPORTS)/dlcapi.imp \
          $(IMPORTS)/dplay.imp \
          $(IMPORTS)/dplayx.imp \
          $(IMPORTS)/dsetup.imp \
          $(IMPORTS)/dsound.imp \
          $(IMPORTS)/edbbcli.imp \
          $(IMPORTS)/gdi32.imp \
          $(IMPORTS)/hlink.imp \
          $(IMPORTS)/icmp.imp \
          $(IMPORTS)/icmui.imp \
          $(IMPORTS)/imagehlp.imp \
          $(IMPORTS)/imm32.imp \
          $(IMPORTS)/iphlpapi.imp \
          $(IMPORTS)/kernel32.imp \
          $(IMPORTS)/loadperf.imp \
          $(IMPORTS)/lz32.imp \
          $(IMPORTS)/mapi32.imp \
          $(IMPORTS)/mpr.imp \
          $(IMPORTS)/mprapi.imp \
          $(IMPORTS)/msacm32.imp \
          $(IMPORTS)/mscms.imp \
          $(IMPORTS)/msi.imp \
          $(IMPORTS)/msimg32.imp \
          $(IMPORTS)/mslsp32.imp \
          $(IMPORTS)/nal.imp \
          $(IMPORTS)/netapi32.imp \
          $(IMPORTS)/ntdll.imp \
          $(IMPORTS)/ntmsapi.imp \
          $(IMPORTS)/odbc32.imp \
          $(IMPORTS)/odbccp32.imp \
          $(IMPORTS)/ole32.imp \
          $(IMPORTS)/oleaut32.imp \
          $(IMPORTS)/oledlg.imp \
          $(IMPORTS)/pdh.imp \
          $(IMPORTS)/penwin32.imp \
          $(IMPORTS)/psapi.imp \
          $(IMPORTS)/rasapi32.imp \
          $(IMPORTS)/rasdlg.imp \
          $(IMPORTS)/rassapi.imp \
          $(IMPORTS)/resutils.imp \
          $(IMPORTS)/rpcns4.imp \
          $(IMPORTS)/rpcrt4.imp \
          $(IMPORTS)/rtm.imp \
          $(IMPORTS)/secur32.imp \
          $(IMPORTS)/setupapi.imp \
          $(IMPORTS)/shell32.imp \
          $(IMPORTS)/shfolder.imp \
          $(IMPORTS)/shlwapi.imp \
          $(IMPORTS)/snmpapi.imp \
          $(IMPORTS)/tapi32.imp \
          $(IMPORTS)/url.imp \
          $(IMPORTS)/urlmon.imp \
          $(IMPORTS)/user32.imp \
          $(IMPORTS)/userenv.imp \
          $(IMPORTS)/uxtheme.imp \
          $(IMPORTS)/win32spl.imp \
          $(IMPORTS)/winfax.imp \
          $(IMPORTS)/wininet.imp \
          $(IMPORTS)/winmm.imp \
          $(IMPORTS)/winspool.imp \
          $(IMPORTS)/wintrust.imp \
          $(IMPORTS)/wsock32.imp \
          $(IMPORTS)/ws2_32.imp \


all: $(OBJECTS)
	


# General rule to easily compile all imports.
#
$(IMPORTS)/%.imp : %.pb
	pbcompiler /QUIET $< /UNICODE /IMPORT "$@"

clean:
	rm -f $(OBJECTS)
