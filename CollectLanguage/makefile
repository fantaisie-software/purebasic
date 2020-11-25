#
# PureBasic tool makefile
# 

ifeq ($(PB_WINDOWS),1)
  COLLECTLANGUAGE  = $(PB_BUILDTARGET)/CollectLanguage.exe
else
  COLLECTLANGUAGE  = $(PB_BUILDTARGET)/collectlanguage
endif
  

collectlanguage: $(COLLECTLANGUAGE)
	$(COLLECTLANGUAGE)


clean:
	rm -f $(COLLECTLANGUAGE)


ifeq ($(PB_WINDOWS),1)

$(COLLECTLANGUAGE): CollectLanguage.pb ../PureBasicIDE/Language.pb
	pbcompiler CollectLanguage.pb /QUIET /CONSOLE /EXE $(COLLECTLANGUAGE)

else

$(COLLECTLANGUAGE): CollectLanguage.pb ../PureBasicIDE/Language.pb
	pbcompiler CollectLanguage.pb --quiet -e $(COLLECTLANGUAGE)

endif
