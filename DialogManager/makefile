#
# needed for building the IDE
#

TARGET = $(PB_BUILDTARGET)/dialogcompiler

ifeq ($(PB_WINDOWS),1)
	PBCOMPILER = $(PUREBASIC_HOME)/Compilers/PBCompiler /QUIET
	MAKEEXE = /EXE
	DIALOGCOMPILER = $(TARGET)/DialogCompiler.exe
else
	PBCOMPILER = $(PUREBASIC_HOME)/compilers/pbcompiler -q
	MAKEEXE = -e
	DIALOGCOMPILER = $(TARGET)/dialogcompiler
endif


dialogcompiler : DialogCompiler.pb $(TARGET)/dummy
	$(PBCOMPILER) DialogCompiler.pb $(MAKEEXE) $(DIALOGCOMPILER) $(PBPACKFLAGS)

$(TARGET)/dummy:
	mkdir "$(TARGET)"
	touch $(TARGET)/dummy

clean:
	rm -rf $(TARGET)
