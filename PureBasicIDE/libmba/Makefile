# PureBasic plugin makefile
#
LIBRARY = libmba
TARGET = $(PB_BUILDTARGET)/ide/libmba
DEPENDENCIES = $(TARGET)/dummy

ifeq ($(PB_WINDOWS),1)
	LIBRARYFILE = $(TARGET)/libmba.lib
else
	LIBRARYFILE = $(TARGET)/libmba.a
endif

# cfg.c doesn't compile on OS X, so it is removed for now

# The IDE does not need all of this. just the diff one and all its dependencies
OBJECTS = $(TARGET)/allocator.$(PB_OBJ) \
					$(TARGET)/bitset.$(PB_OBJ) \
					$(TARGET)/csv.$(PB_OBJ) \
					$(TARGET)/dbug.$(PB_OBJ) \
					$(TARGET)/diff.$(PB_OBJ) \
					$(TARGET)/eval.$(PB_OBJ) \
					$(TARGET)/hashmap.$(PB_OBJ) \
					$(TARGET)/hexdump.$(PB_OBJ) \
					$(TARGET)/linkedlist.$(PB_OBJ) \
					$(TARGET)/misc.$(PB_OBJ) \
					$(TARGET)/msgno.$(PB_OBJ) \
					$(TARGET)/path.$(PB_OBJ) \
					$(TARGET)/pool.$(PB_OBJ) \
					$(TARGET)/stack.$(PB_OBJ) \
					$(TARGET)/suba.$(PB_OBJ) \
					$(TARGET)/time.$(PB_OBJ) \
					$(TARGET)/varray.$(PB_OBJ)

# need to add one empty tab line after the target, otherwise it fails here!?
$(LIBRARY): $(LIBRARYFILE)


ifeq ($(PB_WINDOWS),1)

$(LIBRARYFILE): $(OBJECTS)
	$(PB_LIBRARIAN) /out:$(LIBRARYFILE) $(OBJECTS)

# General rule to easily compile all the objs.
#
$(TARGET)/%.$(PB_OBJ) : %.c $(DEPENDENCIES)
	$(PB_VC8_ANSI) /O2 /MD /D_CRT_SECURE_NO_DEPRECATE /DFRONTEND /DLIBMBA_EXPORTS /DNDEBUG /DWIN32 /D_WINDOWS /DENABLE_THREAD_SAFETY $(PB_IOFIX) /DLIBMBA_API=extern /I. /c $< /Fo$@


else


$(LIBRARYFILE): $(OBJECTS)
	rm -f  $(LIBRARYFILE)
	ar crs $(LIBRARYFILE) $(OBJECTS)

$(TARGET)/%.$(PB_OBJ) : %.c $(DEPENDENCIES)
	$(PB_GCC) -DFRONTEND -DNDEBUG -DENABLE_THREAD_SAFETY -I. $(PB_OPT_SPEED) -c $< -o $@

endif

# without the "" it fails on windows
$(TARGET)/dummy:
	mkdir "$(TARGET)"
	touch $(TARGET)/dummy

clean:
	rm -rf $(TARGET)
