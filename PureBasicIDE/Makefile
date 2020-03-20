
# shared with debugger makefile for simplicity
TARGET = $(PB_BUILDTARGET)/ide

ifeq ($(PB_JAVASCRIPT),1)
	HOME=$(SPIDERBASIC_HOME)
	IDENAME=SpiderBasic
	STARTUPIMAGE=data/SpiderBasic/SplashScreen.png
	ABOUTIMAGE=data/SpiderBasic/About.bmp
	ICOFILE=data/SpiderBasic/Logo.ico
	ICOSOURCEFILE=data/SpiderBasic/Logo.ico
	OSXICOFILE=data/SpiderBasic/Logo.icns
else
	HOME=$(PUREBASIC_HOME)
	IDENAME=PureBasic
	STARTUPIMAGE=data/startuplogo.png
	ABOUTIMAGE=data/purebasiclogo.bmp
	ICOFILE=data/PBLogoBig.ico
	ICOSOURCEFILE=data/PBSourceFile.ico
	OSXICOFILE=data/logo/PB3D_MacIcon.icns
endif


ifeq ($(PB_WINDOWS),1)
	PBCOMPILER = pbcompiler /QUIET
	IDE = $(HOME)/$(IDENAME).exe
	IDEFLAGS = /THREAD /UNICODE /XP /USER /ICON "$(ICOFILE)" /DPIAWARE
	MAKEEXE = /EXE
	PBPACK = $(TARGET)/pbpack.exe
	MAKEBUILDINFO = $(TARGET)/makebuildinfo.exe
	PBPACKFLAGS = /LINENUMBERING /CONSOLE
	DEBUGFLAGS = /LINENUMBERING /DEBUGGER /CONSOLE
	VERSIONFLAG = /RESOURCE $(TARGET)/VersionInfo.rc
	CONSTANT = /CONSTANT
	PURIFIER = /PURIFIER
	DEBUGSYMBOLS =
	CPUMONITORLIB =
	DIALOGCOMPILER = $(PB_BUILDTARGET)/dialogcompiler/DialogCompiler.exe
	MACPLIST =
	MACPLISTCOMMAND =
	ONERROR = /LINENUMBERING
	NETWORKSUPPORT = $(TARGET)/NetworkSupport.obj
	LIBMBA = $(TARGET)/libmba/libmba.lib
	DOMAINSOCKET =
	COLORTABLE = $(HOME)/Catalogs/ColorTable.xml

	ECHOQUOTE =

	ICON = ico
	THEMEFOLDER = $(HOME)/Themes

else
	PBCOMPILER = pbcompiler -q

ifeq ($(PB_MACOS),1)
	IDE = $(HOME)/$(IDENAME).app
	IDEFLAGS = --thread --unicode -n "$(OSXICOFILE)"
	MACPLIST = $(TARGET)/macplist
	MACPLISTCOMMAND = $(TARGET)/macplist $(HOME)/$(IDENAME).app

	ifeq ($(PB_CARBON),1)
		IDEFLAGS += --subsystem carbon
	endif
else
	IDENAME_LOWERCASE = $(shell echo $(IDENAME) | tr A-Z a-z)
	IDE = $(HOME)/compilers/$(IDENAME_LOWERCASE)
	IDEFLAGS = --thread --unicode --subsystem gtk2
	MACPLIST =
	MACPLISTCOMMAND =
endif

	CONSTANT = --constant
	PURIFIER = --purifier
	MAKEEXE = -e
	PBPACK = $(TARGET)/pbpack
	MAKEBUILDINFO = $(TARGET)/makebuildinfo
	PBPACKFLAGS =
	DEBUGFLAGS = -d
	DEBUGSYMBOLS = -ds
	VERSIONFLAG =
	CPUMONITORLIB =
	DIALOGCOMPILER = $(PB_BUILDTARGET)/dialogcompiler/dialogcompiler
	ONERROR = --linenumbering
	NETWORKSUPPORT = $(TARGET)/NetworkSupport.o
	DOMAINSOCKET = $(TARGET)/AutomationDomainSocket.o
	LIBMBA = $(TARGET)/libmba/libmba.a
	COLORTABLE = $(HOME)/catalogs/ColorTable.xml

	ECHOQUOTE = "

	ICON = png
	THEMEFOLDER = $(HOME)/themes

endif

PACKLEVEL = -q -l4

THEMES = \
	$(TARGET)/DefaultTheme.zip \
	$(THEMEFOLDER)/SilkTheme.zip

PROFILERICONS = \
	$(TARGET)/arrow.$(ICON) \
	$(TARGET)/select.$(ICON) \
	$(TARGET)/zoomin.$(ICON) \
	$(TARGET)/zoomout.$(ICON) \
	$(TARGET)/zoomall.$(ICON) \
	$(TARGET)/cross.$(ICON)

DIALOGS = \
$(TARGET)/Find.pb \
$(TARGET)/Grep.pb \
$(TARGET)/Goto.pb \
$(TARGET)/CompilerOptions.pb \
$(TARGET)/AddTools.pb \
$(TARGET)/About.pb \
$(TARGET)/Preferences.pb \
$(TARGET)/Templates.pb \
$(TARGET)/StructureViewer.pb \
$(TARGET)/Projects.pb \
$(TARGET)/Build.pb \
$(TARGET)/Diff.pb \
$(TARGET)/FileMonitor.pb \
$(TARGET)/History.pb \
$(TARGET)/HistoryShutdown.pb \
$(TARGET)/CreateApp.pb \
$(TARGET)/Updates.pb

DEPENDENCIES = \
	$(COLORTABLE) \
	$(TARGET)/images.pak \
	*.pb \
	../PureBasicDebugger/*.pb \
	$(DIALOGS) \
	$(VERSIONINFO) \
	$(CPUMONITORLIB) \
	$(MACPLIST) \
	$(PROFILERICONS) \
	$(THEMES) \
	$(MAKEBUILDINFO) \
	$(NETWORKSUPPORT) \
	$(DOMAINSOCKET)


ifeq ($(PB_JAVASCRIPT),1)
	IDEFLAGS+=$(CONSTANT) SpiderBasic=1
endif

#
# default target
#
ide : VERSION $(DEPENDENCIES)
	make --directory libmba
	$(MAKEBUILDINFO) $(TARGET)
	$(PBCOMPILER) PureBasic.pb $(MAKEEXE) $(IDE) $(IDEFLAGS) $(VERSIONFLAG) $(CONSTANT) BUILD_DIRECTORY=$(TARGET)/
	$(MACPLISTCOMMAND)

#
# demo version of the IDE
#
demo : VERSION_DEMO $(DEPENDENCIES)
	make --directory libmba
	$(MAKEBUILDINFO) $(TARGET)
	$(PBCOMPILER) PureBasic.pb $(MAKEEXE) $(IDE) $(IDEFLAGS) $(VERSIONFLAG) $(CONSTANT) DEMO=1 $(CONSTANT) BUILD_DIRECTORY=$(TARGET)/
	$(MACPLISTCOMMAND)

#
# debug version (with linenumbering / gtk error messages)
#
debug : VERSION_DEBUG $(DEPENDENCIES)
	make --directory libmba
	$(MAKEBUILDINFO) $(TARGET)
	$(PBCOMPILER) PureBasic.pb $(MAKEEXE) $(IDE) $(IDEFLAGS) $(DEBUGFLAGS) $(DEBUGSYMBOLS) $(VERSIONFLAG) $(CONSTANT) DEBUG=1 $(CONSTANT) BUILD_DIRECTORY=$(TARGET)/
	$(MACPLISTCOMMAND)

#
# debug version + Purifier
#
purifier : VERSION_DEBUG $(DEPENDENCIES)
	make --directory libmba
	$(MAKEBUILDINFO) $(TARGET)
	$(PBCOMPILER) PureBasic.pb $(MAKEEXE) $(IDE) $(IDEFLAGS) $(DEBUGFLAGS) $(DEBUGSYMBOLS) $(PURIFIER) $(VERSIONFLAG) $(CONSTANT) DEBUG=1 $(CONSTANT) BUILD_DIRECTORY=$(TARGET)/
	$(MACPLISTCOMMAND)

#
# default target, but without stripping debug symbols (for gdk debugging)
#
symbols : VERSION $(DEPENDENCIES)
	make --directory libmba
	$(MAKEBUILDINFO) $(TARGET)
	$(PBCOMPILER) PureBasic.pb $(MAKEEXE) $(IDE) $(IDEFLAGS) $(DEBUGSYMBOLS) $(VERSIONFLAG) $(CONSTANT) BUILD_DIRECTORY=$(TARGET)/
	$(MACPLISTCOMMAND)

#
# default target, but with onerror support
#
onerror : VERSION $(DEPENDENCIES)
	make --directory libmba
	$(MAKEBUILDINFO) $(TARGET)
	$(PBCOMPILER) PureBasic.pb $(MAKEEXE) $(IDE) $(IDEFLAGS) $(VERSIONFLAG) $(ONERROR) $(CONSTANT) BUILD_DIRECTORY=$(TARGET)/
	$(MACPLISTCOMMAND)

#
# special target to build all needed files, but not the IDE itself. (good for testing from inside the ide)
#
nocompile :  $(TARGET)/dummy VERSION  $(DEPENDENCIES)
	make --directory libmba
	$(MAKEBUILDINFO) $(TARGET)

#
# required other targets
#


$(TARGET)/images.pak :  $(TARGET)/dummy $(STARTUPIMAGE) $(ABOUTIMAGE) $(TARGET)/ToolsPanelRight.$(ICON) $(TARGET)/ToolsPanelLeft.$(ICON) $(TARGET)/CloseButton.$(ICON) data/EmptySpace.png data/MissingIcon.png $(PBPACK)
	$(PBPACK) $(PACKLEVEL) $(TARGET)/images.pak $(STARTUPIMAGE) $(ABOUTIMAGE) $(TARGET)/ToolsPanelRight.$(ICON) $(TARGET)/ToolsPanelLeft.$(ICON) $(TARGET)/CloseButton.$(ICON) data/EmptySpace.png data/MissingIcon.png

$(PBPACK) : tools/pbpack.pb $(TARGET)/dummy
	$(PBCOMPILER) tools/pbpack.pb $(MAKEEXE) $(PBPACK) $(PBPACKFLAGS)

$(MAKEBUILDINFO) : tools/makebuildinfo.pb $(TARGET)/dummy
	$(PBCOMPILER) tools/makebuildinfo.pb $(MAKEEXE) $(MAKEBUILDINFO) $(PBPACKFLAGS)

$(TARGET)/%.ico : ../PureBasicDebugger/Data/%.png $(TARGET)/dummy
	tools/png2ico.exe $@ $<

$(TARGET)/%.ico : data/%.png $(TARGET)/dummy
	tools/png2ico.exe $@ $<

# for a few png, we simply copy them to make it easier. (the single cases in images.pak like $(TARGET)/ToolsPanelRight.$(ICON))
$(TARGET)/%.png : data/%.png $(TARGET)/dummy
	cp $< $@

$(TARGET)/%.png : ../PureBasicDebugger/Data/%.png $(TARGET)/dummy
	cp $< $@

$(TARGET)/%.pb : dialogs/%.xml $(DIALOGCOMPILER) $(TARGET)/dummy
	$(DIALOGCOMPILER) $< $@

# theme targets (-mkdir suppresses errors if the directory exists)
#
$(TARGET)/DefaultTheme.zip: data/DefaultTheme/*
	rm -f $(TARGET)/DefaultTheme.zip
	zip -jq $(TARGET)/DefaultTheme.zip data/DefaultTheme/*

$(THEMEFOLDER)/SilkTheme.zip: data/SilkTheme/*
	-mkdir "$(THEMEFOLDER)"
	rm -f $(THEMEFOLDER)/SilkTheme.zip
	zip -jq $(THEMEFOLDER)/SilkTheme.zip data/SilkTheme/*

$(COLORTABLE): data/ColorTable.xml
	cp -f data/ColorTable.xml $(COLORTABLE)

# this also works on windows
#
$(DIALOGCOMPILER) : ../DialogManager/DialogCompiler.pb $(TARGET)/dummy
	make --directory ../DialogManager


#
# Windows only: create version information resource
#
ifeq ($(PB_WINDOWS),1)

$(TARGET)/makeversion.exe : tools/makeversion.pb $(TARGET)/dummy
	$(PBCOMPILER) tools/makeversion.pb /EXE $(TARGET)/makeversion.exe /CONSOLE

VERSION: $(TARGET)/makeversion.exe $(TARGET)/dummy
	$(TARGET)/makeversion.exe ide $(TARGET)/VersionInfo.rc $(shell PWD)/$(ICOSOURCEFILE)

VERSION_DEBUG: $(TARGET)/makeversion.exe $(TARGET)/dummy
	$(TARGET)/makeversion.exe debug $(TARGET)/VersionInfo.rc $(shell PWD)/$(ICOSOURCEFILE)

VERSION_DEMO: $(TARGET)/makeversion.exe $(TARGET)/dummy
	$(TARGET)/makeversion.exe demo $(TARGET)/VersionInfo.rc $(shell PWD)/$(ICOSOURCEFILE)

# Windows only: Syntax highlighting dll
dll : tools/HighlightingDll.pb
	$(PBCOMPILER) tools/HighlightingDll.pb /dll /exe "$(HOME)/SDK/Syntax Highlighting/SyntaxHighlighting.dll" /CONSTANT MAKEFILE=1
	cp "tools\HighlightingDll_example.pb" "$(HOME)/SDK/Syntax Highlighting/Example.pb"

# (Currently windows only, later hopefully crossplatform)
# IDE Automation sdk (dll + examples)
automation_sdk : sdk/Example.pb sdk/Automation.pb AutomationLibrary.pb FileSystem.pb RemoteProcedureCall.pb CompilerFlags.pb Macro.pb
	-mkdir "$(HOME)/SDK/Automation"
	$(PBCOMPILER) AutomationLibrary.pb /dll /exe "$(HOME)/SDK/Automation/Automation.dll"
	$(PBCOMPILER) AutomationLibrary.pb /dll /exe "$(HOME)/SDK/Automation/AutomationUnicode.dll" /UNICODE
	cp sdk/Automation.pb "$(HOME)/SDK/Automation/Automation.pb"
	cp sdk/Example.pb "$(HOME)/SDK/Automation/Example.pb"


#
# For other os: dummy version targets
#
else

VERSION:
VERSION_DEBUG:
VERSION_DEMO:
dll:
sdk:

endif

#
# Special target for the program that creates the Info.plist for mac.
# On the other OS this is not needed
#
ifeq ($(PB_MACOS),1)

$(MACPLIST) : tools/macplist.pb $(TARGET)/dummy
	$(PBCOMPILER) tools/macplist.pb -e $(MACPLIST)

endif

# compile the NetworkSupport.c
#
ifeq ($(PB_WINDOWS),1)

$(NETWORKSUPPORT) : ../PureBasicDebugger/NetworkSupport.c $(PB_LIBRARIES)/Debugger/DebuggerInternal.h $(PB_LIBRARIES)/Debugger/OSSpecific.h
	$(PB_VC8_ANSI) /O1 /c $< /Fo$@

# not needed on Windows
$(DOMAINSOCKET):

else

$(NETWORKSUPPORT) : ../PureBasicDebugger/NetworkSupport.c $(PB_LIBRARIES)/Debugger/DebuggerInternal.h $(PB_LIBRARIES)/Debugger/OSSpecific.h
	$(PB_GCC_ANSI) $(PB_OPT_SPEED) -c $< -o $@

# domain socket function for IDE automation
$(DOMAINSOCKET) : AutomationDomainSocket.c
	$(PB_GCC_ANSI) $(PB_OPT_SPEED) -c $< -o $@

endif



$(TARGET)/dummy:
	mkdir "$(TARGET)"
	touch $(TARGET)/dummy

clean:
	rm -rf $(TARGET)
	make clean --directory ../DialogManager
