# To level makefile


ifeq ($(PB_WINDOWS),1)
  DIRECTORY = Windows
endif

ifeq ($(PB_LINUX),1)
  DIRECTORY = Linux
endif

ifeq ($(PB_MACOS),1)
  DIRECTORY = MacOS
endif

# Javascript last as it has the priority over the others
ifeq ($(PB_JAVASCRIPT),1)
  DIRECTORY = JavaScript
endif


default:
	make --quiet --directory $(DIRECTORY)
