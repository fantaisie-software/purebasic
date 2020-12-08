#
# Makefile for all included targets
# 

TARGET = $(PB_BUILDTARGET)

ifeq ($(PB_WINDOWS),1)

doc:
	"$(SPIDERBASIC_HOME)/SDK/DocMaker/DocMaker.exe" /LANGUAGE English /DOCUMENTATIONPATH "$(PB_SVN)/Documentation/SpiderBasic" /OUTPUTPATH "$(TARGET)/documentation"
	explorer "$(TARGET)\documentation"

else

doc:
	rm -rf $(TARGET)/docs
	mkdir $(TARGET)/docs
	sbdocmaker /DOCUMENTATIONPATH $(PB_SVN)/Documentation/SpiderBasic /OUTPUTPATH $(TARGET)/docs /OS Linux /LANGUAGE English /FORMAT LINUX
	mv $(TARGET)/docs/purebasic.help $(SPIDERBASIC_HOME)/spiderbasic.help

endif