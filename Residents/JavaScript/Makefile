# Small makefile to build the residents easily

ifeq ($(PB_WINDOWS),1)
  QUIET = /QUIET
  IGNORERESIDENT=/IGNORERESIDENT
  RESIDENT=/RESIDENT
else
  QUIET=--quiet
  IGNORERESIDENT=--ignoreresident
  RESIDENT=--resident
endif


all:
	sbcompiler PureBasic.pb $(IGNORERESIDENT) spiderbasic.res $(RESIDENT) "$(SPIDERBASIC_HOME)/residents/spiderbasic.res" $(QUIET)
