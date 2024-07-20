# Small makefile to build the residents easily

all: residents


# We need to separate imports and constants for the build server
residents:
	rm -f "$(PUREBASIC_HOME)/$(SUBSYSTEM)residents/purebasic.res"
	pbcompiler PureBasic.pb -q -r "$(PUREBASIC_HOME)/residents/purebasic.res" -ir purebasic.res
	pbcompiler ../expat.pb -q -r "$(PUREBASIC_HOME)/residents/expat.res" -ir expat.res
	pbcompiler ../Scintilla.pb -q -r "$(PUREBASIC_HOME)/residents/scintilla.res" -ir scintilla.res
	pbcompiler ../OpenGL.pb -q -r "$(PUREBASIC_HOME)/residents/opengl.res" -ir opengl.res
