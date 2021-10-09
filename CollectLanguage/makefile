#
# PureBasic tool makefile
# 

ifeq ($(PB_WINDOWS),1)
  COLLECTLANGUAGE  = Build/CollectLanguage.exe
else
  COLLECTLANGUAGE  = Build/collectlanguage
endif
  

collectlanguage: $(COLLECTLANGUAGE)
	$(COLLECTLANGUAGE)


Build/dummy:
	mkdir "Build"
	touch Build/dummy

clean:
	rm -rf Build


ifeq ($(PB_WINDOWS),1)

$(COLLECTLANGUAGE): CollectLanguage.pb ../PureBasicIDE/Language.pb Build/dummy
	pbcompiler CollectLanguage.pb /QUIET /CONSOLE /EXE $(COLLECTLANGUAGE)

else

$(COLLECTLANGUAGE): CollectLanguage.pb ../PureBasicIDE/Language.pb Build/dummy
	pbcompiler CollectLanguage.pb --quiet -e $(COLLECTLANGUAGE)

endif
