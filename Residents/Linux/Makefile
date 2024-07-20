# Small makefile to build the residents easily

all: resident
	

resident:
	pbcompiler -q PureBasic.pb -r "$(PUREBASIC_HOME)/residents/purebasic.res" -ir purebasic.res
	pbcompiler -q PureBasic.pb -r "$(PUREBASIC_HOME)/subsystems/qt/residents/purebasic.res" -ir purebasic.res -s qt
	pbcompiler -q ../expat.pb -r "$(PUREBASIC_HOME)/residents/expat.res" -ir expat.res
	pbcompiler -q ../Scintilla.pb -r "$(PUREBASIC_HOME)/residents/scintilla.res" -ir scintilla.res
	pbcompiler -q ../OpenGL.pb -r "$(PUREBASIC_HOME)/residents/opengl.res" -ir opengl.res
	cd gtk2/gtk/; pbcompiler -q PureBasic.pb -r "$(PUREBASIC_HOME)/residents/gtk.res" -ir gtk.res
	cd SDL/; pbcompiler -q PB_SDL.pb -r "$(PUREBASIC_HOME)/residents/sdl.res" -ir sdl.res

