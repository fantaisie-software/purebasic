
# We use the same target dir for debugger and IDE for simplicity as some
# data and sources are shared as well.
TARGET = $(PB_BUILDTARGET)/ide

ifeq ($(PB_WINDOWS),1)
	PBCOMPILER = $(PUREBASIC_HOME)/Compilers/PBCompiler /QUIET
	GUIDEBUGGER = $(PUREBASIC_HOME)/Compilers/PBDebugger.exe
	DEBUGGERFLAGS = /XP /USER /ICON ../PureBasicIDE/data/PBLogoSmall.ico
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
	DEBUGGERFLAGS = --front -n "../PureBasicIDE/data/logo/PB3D_MacIcon.icns"
else
	GUIDEBUGGER = $(PUREBASIC_HOME)/compilers/pbdebugger
	DEBUGGERFLAGS = --subsystem gtk2
endif

	MAKEEXE = -e
	ECHOQUOTE = "
endif

GuiDebugger : *.pb Data/*.png ../PureBasicIDE/data/DefaultTheme/*.png
	$(PBCOMPILER) StandaloneDebugger.pb $(MAKEEXE) $(GUIDEBUGGER) $(DEBUGGERFLAGS) $(UNICODE) $(CONSTANT) BUILD_DIRECTORY=$(TARGET)/

debug : *.pb Data/*.png ../PureBasicIDE/data/DefaultTheme/*.png
	$(PBCOMPILER) StandaloneDebugger.pb $(MAKEEXE) $(GUIDEBUGGER) $(DEBUGGERFLAGS) $(UNICODE) $(DEBUGFLAG) $(CONSTANT) BUILD_DIRECTORY=$(TARGET)/ $(CONSTANT) DEBUG=1

purifier : *.pb Data/*.png ../PureBasicIDE/data/DefaultTheme/*.png
	$(PBCOMPILER) StandaloneDebugger.pb $(MAKEEXE) $(GUIDEBUGGER) $(DEBUGGERFLAGS)  $(UNICODE) $(DEBUGFLAG) $(CONSTANT) BUILD_DIRECTORY=$(TARGET)/ $(CONSTANT) DEBUG=1 $(PURIFIER)

# copying / converting of images
#
$(TARGET)/dummy:
	mkdir "$(TARGET)"
	touch $(TARGET)/dummy

clean:
	rm -rf $(TARGET)
