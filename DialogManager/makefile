#
# needed for building the IDE
#

ifeq ($(PB_WINDOWS),1)
	PBCOMPILER = "$(PUREBASIC_HOME)/Compilers/PBCompiler" /QUIET
	MAKEEXE = /EXE
	DIALOGCOMPILER = Build/DialogCompiler.exe
else
	PBCOMPILER = "$(PUREBASIC_HOME)/compilers/pbcompiler" -q
	MAKEEXE = -e
	DIALOGCOMPILER = Build/dialogcompiler
endif


dialogcompiler : DialogCompiler.pb Build/dummy
	$(PBCOMPILER) DialogCompiler.pb $(MAKEEXE) $(DIALOGCOMPILER)

Build/dummy:
	mkdir "Build"
	touch Build/dummy

clean:
	rm -rf Build
