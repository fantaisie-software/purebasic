
ifeq ($(PB_WINDOWS),1)
	PBCOMPILER = "$(PUREBASIC_HOME)/Compilers/PBCompiler" /QUIET
	GUIDEBUGGER = "$(PUREBASIC_HOME)/Compilers/PBDebugger.exe"
	GUIDEBUGGERFLAGS = /DPIAWARE /XP /USER /ICON ../PureBasicIDE/data/PBLogoSmall.ico
	MAKEEXE = /EXE
	ECHOQUOTE =
	CONSTANT = /CONSTANT
	UNICODE = /UNICODE
	DEBUGFLAG = /DEBUGGER
	PURIFIER = /PURIFIER

else
	PBCOMPILER = "$(PUREBASIC_HOME)/compilers/pbcompiler" -q
	CONSTANT = --constant
	UNICODE = --unicode
	DEBUGFLAG = -d
	PURIFIER = --purifier

ifeq ($(PB_MACOS),1)
	GUIDEBUGGER = "$(PUREBASIC_HOME)/compilers/pbdebugger.app"
	GUIDEBUGGERFLAGS = --front -n "../PureBasicIDE/data/logo/PB3D_MacIcon.icns"
else
	GUIDEBUGGER = "$(PUREBASIC_HOME)/compilers/pbdebugger"
	DEBUGGERFLAGS = 
	ifeq ($(PB_GTK),2)
		DEBUGGERFLAGS += --subsystem gtk2
	endif
	ifeq ($(PB_QT),1)
		DEBUGGERFLAGS += --subsystem qt
		QT_HELPERS = Build/QtHelpers.a
	endif
endif

	MAKEEXE = -e
	ECHOQUOTE = "
endif

GuiDebugger : *.pb Data/*.png ../PureBasicIDE/data/DefaultTheme/*.png $(QT_HELPERS)
	$(PBCOMPILER) StandaloneDebugger.pb $(MAKEEXE) $(GUIDEBUGGER) $(GUIDEBUGGERFLAGS) $(UNICODE)

debug : *.pb Data/*.png ../PureBasicIDE/data/DefaultTheme/*.png
	$(PBCOMPILER) StandaloneDebugger.pb $(MAKEEXE) $(GUIDEBUGGER) $(GUIDEBUGGERFLAGS) $(UNICODE) $(DEBUGFLAG) $(CONSTANT) DEBUG=1

purifier : *.pb Data/*.png ../PureBasicIDE/data/DefaultTheme/*.png
	$(PBCOMPILER) StandaloneDebugger.pb $(MAKEEXE) $(GUIDEBUGGER) $(GUIDEBUGGERFLAGS)  $(UNICODE) $(DEBUGFLAG) $(CONSTANT) DEBUG=1 $(PURIFIER)

ifeq ($(PB_QT),1)

ifeq ($(PB_PROCESSOR),X64)
  GPP_FLAGS = -fPIC -DPB_64
endif
ifeq ($(PB_PROCESSOR),ARM64)
  GPP_FLAGS = -fPIC -DPB_64
endif

$(QT_HELPERS) : ../PureBasicIDE/qt/QtHelpers.cpp ../PureBasicIDE/qt/QtHelpers.h Build/dummy
	moc -D_GNU_SOURCE -DQT_NO_VERSION_TAGGING -I`qmake -query QT_INSTALL_HEADERS` ../PureBasicIDE/qt/QtHelpers.h -o Build/QtHelpers.moc.cpp
	g++ $(GPP_FLAGS) -DQT_NO_VERSION_TAGGING -I`qmake -query QT_INSTALL_HEADERS` -c Build/QtHelpers.moc.cpp -o Build/QtHelpers.moc.o
	g++ $(GPP_FLAGS) -DQT_NO_VERSION_TAGGING -I`qmake -query QT_INSTALL_HEADERS` -I../PureBasicIDE/qt -c ../PureBasicIDE/qt/QtHelpers.cpp -o Build/QtHelpers.o
	ar crs $(QT_HELPERS) Build/QtHelpers.o Build/QtHelpers.moc.o

endif

Build/dummy:
	mkdir "Build"
	touch Build/dummy


clean:
	rm -rf Build
	
