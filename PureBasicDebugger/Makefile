
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
	NETWORKSUPPORT = $(TARGET)/NetworkSupport.obj
	PURIFIER = /PURIFIER

	ICONS = \
		$(TARGET)/arrow.ico \
		$(TARGET)/select.ico \
		$(TARGET)/zoomin.ico \
		$(TARGET)/zoomout.ico \
		$(TARGET)/zoomall.ico \
		$(TARGET)/cross.ico \
		$(TARGET)/TemplateUp.ico \
		$(TARGET)/TemplateDown.ico \

else
	PBCOMPILER = $(PUREBASIC_HOME)/compilers/pbcompiler -q
	CONSTANT = --constant
	UNICODE = --unicode
	DEBUGFLAG = -d
	NETWORKSUPPORT = $(TARGET)/NetworkSupport.o
	PURIFIER = --purifier

	ICONS = \
		$(TARGET)/arrow.png \
		$(TARGET)/select.png \
		$(TARGET)/zoomin.png \
		$(TARGET)/zoomout.png \
		$(TARGET)/zoomall.png \
		$(TARGET)/cross.png \
		$(TARGET)/TemplateUp.png \
		$(TARGET)/TemplateDown.png

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

GuiDebugger : *.pb Data/*.png $(ICONS) $(NETWORKSUPPORT)
	$(PBCOMPILER) StandaloneDebugger.pb $(MAKEEXE) $(GUIDEBUGGER) $(DEBUGGERFLAGS) $(UNICODE) $(CONSTANT) BUILD_DIRECTORY=$(TARGET)/

debug : *.pb Data/*.png $(ICONS) $(NETWORKSUPPORT)
	$(PBCOMPILER) StandaloneDebugger.pb $(MAKEEXE) $(GUIDEBUGGER) $(DEBUGGERFLAGS) $(UNICODE) $(DEBUGFLAG) $(CONSTANT) BUILD_DIRECTORY=$(TARGET)/ $(CONSTANT) DEBUG=1

purifier : *.pb Data/*.png $(ICONS) $(NETWORKSUPPORT)
	$(PBCOMPILER) StandaloneDebugger.pb $(MAKEEXE) $(GUIDEBUGGER) $(DEBUGGERFLAGS)  $(UNICODE) $(DEBUGFLAG) $(CONSTANT) BUILD_DIRECTORY=$(TARGET)/ $(CONSTANT) DEBUG=1 $(PURIFIER)

# copying / converting of images
#
$(TARGET)/%.ico : Data/%.png $(TARGET)/dummy
	../PureBasicIDE/tools/png2ico.exe $@ $<

$(TARGET)/%.ico : ../PureBasicIDE/data/DefaultTheme/%.png $(TARGET)/dummy
	../PureBasicIDE/tools/png2ico.exe $@ $<

$(TARGET)/%.png : Data/%.png $(TARGET)/dummy
	cp $< $@

$(TARGET)/%.png : ../PureBasicIDE/data/DefaultTheme/%.png $(TARGET)/dummy
	cp $< $@

# compile the NetworkSupport.c
#
ifeq ($(PB_WINDOWS),1)

$(NETWORKSUPPORT) : NetworkSupport.c $(PB_LIBRARIES)/Debugger/DebuggerInternal.h $(PB_LIBRARIES)/Debugger/OSSpecific.h
	$(PB_VC8_ANSI) /O1 /c $< /Fo$@

else

$(NETWORKSUPPORT) : NetworkSupport.c $(PB_LIBRARIES)/Debugger/DebuggerInternal.h $(PB_LIBRARIES)/Debugger/OSSpecific.h
	$(PB_GCC_ANSI) $(PB_OPT_SPEED) -c $< -o $@

endif

$(TARGET)/dummy:
	mkdir "$(TARGET)"
	touch $(TARGET)/dummy

clean:
	rm -rf $(TARGET)
