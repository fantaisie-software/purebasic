
ifeq ($(PB_WINDOWS),1)
	PBCOMPILER = $(PUREBASIC_HOME)/Compilers/PBCompiler /QUIET
	GUIDEBUGGER = $(PUREBASIC_HOME)/Compilers/PBDebugger.exe
	GUIDEBUGGERFLAGS = /DPIAWARE /XP /USER /ICON ../PureBasicIDE/data/PBLogoSmall.ico
	MAKEEXE = /EXE
	ECHOQUOTE =
	CONSTANT = /CONSTANT
	UNICODE = /UNICODE
	DEBUGFLAG = /DEBUGGER
	PURIFIER = /PURIFIER

else
	PBCOMPILER = $(PUREBASIC_HOME)/compilers/pbcompiler -q
	CONSTANT = --constant
	UNICODE = --unicode
	DEBUGFLAG = -d
	PURIFIER = --purifier

ifeq ($(PB_MACOS),1)
	GUIDEBUGGER = $(PUREBASIC_HOME)/compilers/pbdebugger.app
	GUIDEBUGGERFLAGS = --front -n "../PureBasicIDE/data/logo/PB3D_MacIcon.icns"
else
	GUIDEBUGGER = $(PUREBASIC_HOME)/compilers/pbdebugger
	DEBUGGERFLAGS = 
	ifeq ($(PB_GTK),2)
		DEBUGGERFLAGS += --subsystem gtk2
	endif
endif

	MAKEEXE = -e
	ECHOQUOTE = "
endif

GuiDebugger : *.pb Data/*.png ../PureBasicIDE/data/DefaultTheme/*.png
	$(PBCOMPILER) StandaloneDebugger.pb $(MAKEEXE) $(GUIDEBUGGER) $(GUIDEBUGGERFLAGS) $(UNICODE)

debug : *.pb Data/*.png ../PureBasicIDE/data/DefaultTheme/*.png
	$(PBCOMPILER) StandaloneDebugger.pb $(MAKEEXE) $(GUIDEBUGGER) $(GUIDEBUGGERFLAGS) $(UNICODE) $(DEBUGFLAG) $(CONSTANT) DEBUG=1

purifier : *.pb Data/*.png ../PureBasicIDE/data/DefaultTheme/*.png
	$(PBCOMPILER) StandaloneDebugger.pb $(MAKEEXE) $(GUIDEBUGGER) $(GUIDEBUGGERFLAGS)  $(UNICODE) $(DEBUGFLAG) $(CONSTANT) DEBUG=1 $(PURIFIER)

clean:
	
