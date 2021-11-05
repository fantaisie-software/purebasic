
ifeq ($(PB_JAVASCRIPT),1)
	HOME=$(SPIDERBASIC_HOME)
	IDENAME=SpiderBasic
	ICOFILE=data/SpiderBasic/Logo.ico
	ICOSOURCEFILE=data/SpiderBasic/Logo.ico
	OSXICOFILE=data/SpiderBasic/Logo.icns
else
	HOME=$(PUREBASIC_HOME)
	IDENAME=PureBasic
	ICOFILE=data/PBLogoBig.ico
	ICOSOURCEFILE=data/PBSourceFile.ico
	OSXICOFILE=data/logo/PB3D_MacIcon.icns
endif


ifeq ($(PB_WINDOWS),1)
	PBCOMPILER = $(PUREBASIC_HOME)/Compilers/PBCompiler /QUIET
	IDE = $(HOME)/$(IDENAME).exe
	IDEFLAGS = /THREAD /UNICODE /XP /USER /ICON $(ICOFILE) /DPIAWARE
	MAKEEXE = /EXE
	MAKEBUILDINFO = Build/makebuildinfo.exe
	TOOLFLAGS = /LINENUMBERING /CONSOLE
	DEBUGFLAGS = /LINENUMBERING /DEBUGGER /CONSOLE
	VERSIONFLAG = /RESOURCE Build/VersionInfo.rc
	CONSTANT = /CONSTANT
	PURIFIER = /PURIFIER
	DEBUGSYMBOLS =
	CPUMONITORLIB =
	DIALOGCOMPILER = ../DialogManager/Build/DialogCompiler.exe
	MACPLIST =
	MACPLISTCOMMAND =
	ONERROR = /LINENUMBERING
	COLORTABLE = $(HOME)/Catalogs/ColorTable.xml
	ECHOQUOTE =
	ICON = ico
	THEMEFOLDER = $(HOME)/Themes

else
	PBCOMPILER = pbcompiler -q

ifeq ($(PB_MACOS),1)
	IDE = $(HOME)/$(IDENAME).app
	IDEFLAGS = --thread --unicode -n "$(OSXICOFILE)"
	MACPLIST = Build/macplist
	MACPLISTCOMMAND = Build/macplist $(HOME)/$(IDENAME).app

	ifeq ($(PB_CARBON),1)
		IDEFLAGS += --subsystem carbon
	endif
else
	IDENAME_LOWERCASE = $(shell echo $(IDENAME) | tr A-Z a-z)
	IDE = $(HOME)/compilers/$(IDENAME_LOWERCASE)
	IDEFLAGS = --thread --unicode
	MACPLIST =
	MACPLISTCOMMAND =
	ifeq ($(PB_GTK),2)
		IDEFLAGS += --subsystem gtk2
	endif
endif

	CONSTANT = --constant
	PURIFIER = --purifier
	MAKEEXE = -e
	MAKEBUILDINFO = Build/makebuildinfo
	TOOLFLAGS =
	DEBUGFLAGS = -d
	DEBUGSYMBOLS = -ds
	VERSIONFLAG =
	CPUMONITORLIB =
	DIALOGCOMPILER = ../DialogManager/Build/dialogcompiler
	ONERROR = --linenumbering
	COLORTABLE = $(HOME)/catalogs/ColorTable.xml
	ECHOQUOTE = "
	ICON = png
	THEMEFOLDER = $(HOME)/themes

endif

PACKLEVEL = -q -l4

THEMES = \
	Build/DefaultTheme.zip \
	$(THEMEFOLDER)/SilkTheme.zip

DIALOGS = \
Build/Find.pb \
Build/Grep.pb \
Build/Goto.pb \
Build/CompilerOptions.pb \
Build/AddTools.pb \
Build/About.pb \
Build/Preferences.pb \
Build/Templates.pb \
Build/StructureViewer.pb \
Build/Projects.pb \
Build/Build.pb \
Build/Diff.pb \
Build/FileMonitor.pb \
Build/History.pb \
Build/HistoryShutdown.pb \
Build/CreateApp.pb \
Build/Updates.pb

DEPENDENCIES = \
	$(COLORTABLE) \
	*.pb \
	../PureBasicDebugger/*.pb \
	$(DIALOGS) \
	$(VERSIONINFO) \
	$(CPUMONITORLIB) \
	$(MACPLIST) \
	$(THEMES) \
	$(MAKEBUILDINFO)


ifeq ($(PB_JAVASCRIPT),1)
	IDEFLAGS+=$(CONSTANT) SpiderBasic=1
endif

#
# default target
#
ide : VERSION $(DEPENDENCIES)
	$(MAKEBUILDINFO) Build
	$(PBCOMPILER) PureBasic.pb $(MAKEEXE) $(IDE) $(IDEFLAGS) $(VERSIONFLAG)
	$(MACPLISTCOMMAND)

#
# demo version of the IDE
#
demo : VERSION_DEMO $(DEPENDENCIES)
	$(MAKEBUILDINFO) Build
	$(PBCOMPILER) PureBasic.pb $(MAKEEXE) $(IDE) $(IDEFLAGS) $(VERSIONFLAG) $(CONSTANT) DEMO=1
	$(MACPLISTCOMMAND)

#
# debug version (with linenumbering / gtk error messages)
#
debug : VERSION_DEBUG $(DEPENDENCIES)
	$(MAKEBUILDINFO) Build
	$(PBCOMPILER) PureBasic.pb $(MAKEEXE) $(IDE) $(IDEFLAGS) $(DEBUGFLAGS) $(DEBUGSYMBOLS) $(VERSIONFLAG) $(CONSTANT) DEBUG=1
	$(MACPLISTCOMMAND)

#
# debug version + Purifier
#
purifier : VERSION_DEBUG $(DEPENDENCIES)
	$(MAKEBUILDINFO) Build
	$(PBCOMPILER) PureBasic.pb $(MAKEEXE) $(IDE) $(IDEFLAGS) $(DEBUGFLAGS) $(DEBUGSYMBOLS) $(PURIFIER) $(VERSIONFLAG) $(CONSTANT) DEBUG=1
	$(MACPLISTCOMMAND)

#
# default target, but without stripping debug symbols (for gdk debugging)
#
symbols : VERSION $(DEPENDENCIES)
	$(MAKEBUILDINFO) Build
	$(PBCOMPILER) PureBasic.pb $(MAKEEXE) $(IDE) $(IDEFLAGS) $(DEBUGSYMBOLS) $(VERSIONFLAG)
	$(MACPLISTCOMMAND)

#
# default target, but with onerror support
#
onerror : VERSION $(DEPENDENCIES)
	$(MAKEBUILDINFO) Build
	$(PBCOMPILER) PureBasic.pb $(MAKEEXE) $(IDE) $(IDEFLAGS) $(VERSIONFLAG) $(ONERROR)
	$(MACPLISTCOMMAND)

#
# special target to build all needed files, but not the IDE itself. (good for testing from inside the ide)
#
nocompile :  Build/dummy VERSION  $(DEPENDENCIES)
	$(MAKEBUILDINFO) Build

#
# required other targets
#

$(MAKEBUILDINFO) : tools/makebuildinfo.pb Build/dummy
	$(PBCOMPILER) tools/makebuildinfo.pb $(MAKEEXE) $(MAKEBUILDINFO) $(TOOLFLAGS)

Build/%.pb : dialogs/%.xml $(DIALOGCOMPILER) Build/dummy
	$(DIALOGCOMPILER) $< $@

# theme targets (-mkdir suppresses errors if the directory exists)
#
Build/DefaultTheme.zip: data/DefaultTheme/*
	rm -f Build/DefaultTheme.zip
	zip -jq Build/DefaultTheme.zip data/DefaultTheme/*

$(THEMEFOLDER)/SilkTheme.zip: data/SilkTheme/*
	-mkdir "$(THEMEFOLDER)"
	rm -f $(THEMEFOLDER)/SilkTheme.zip
	zip -jq $(THEMEFOLDER)/SilkTheme.zip data/SilkTheme/*

$(COLORTABLE): data/ColorTable.xml
	cp -f data/ColorTable.xml $(COLORTABLE)

# this also works on windows
#
$(DIALOGCOMPILER) : ../DialogManager/DialogCompiler.pb Build/dummy
	make --directory ../DialogManager


#
# Windows only: create version information resource
#
ifeq ($(PB_WINDOWS),1)

Build/makeversion.exe : tools/makeversion.pb Build/dummy
	$(PBCOMPILER) tools/makeversion.pb /EXE Build/makeversion.exe /CONSOLE

VERSION: Build/makeversion.exe Build/dummy
	Build/makeversion.exe ide Build/VersionInfo.rc $(shell PWD)/$(ICOSOURCEFILE)

VERSION_DEBUG: Build/makeversion.exe Build/dummy
	Build/makeversion.exe debug Build/VersionInfo.rc $(shell PWD)/$(ICOSOURCEFILE)

VERSION_DEMO: Build/makeversion.exe Build/dummy
	Build/makeversion.exe demo Build/VersionInfo.rc $(shell PWD)/$(ICOSOURCEFILE)

# Windows only: Syntax highlighting dll
dll : tools/HighlightingDll.pb
	$(PBCOMPILER) tools/HighlightingDll.pb /dll /exe "$(HOME)/SDK/Syntax Highlighting/SyntaxHighlighting.dll" /CONSTANT MAKEFILE=1
	cp "tools\HighlightingDll_example.pb" "$(HOME)/SDK/Syntax Highlighting/Example.pb"

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

$(MACPLIST) : tools/macplist.pb Build/dummy
	$(PBCOMPILER) tools/macplist.pb -e $(MACPLIST)

endif

Build/dummy:
	mkdir "Build"
	touch Build/dummy

clean:
	rm -rf Build
	make clean --directory ../DialogManager
