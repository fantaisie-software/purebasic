# Small makefile to build the residents easily
# NOTE: the interfaces must be built before the Windows.pb resident, as it uses IUnknown and it's important for the C compiler to has the correct interface information

all:
	pbcompiler PureBasic.pb /IGNORERESIDENT PureBasic.res /RESIDENT "$(PUREBASIC_HOME)\Residents\PureBasic.res" /QUIET
	pbcompiler Interface.pb /IGNORERESIDENT Interface.res /RESIDENT "$(PUREBASIC_HOME)\Residents\Interface.res" /QUIET
	pbcompiler InterfaceDX.pb /IGNORERESIDENT InterfaceDX.res /RESIDENT "$(PUREBASIC_HOME)\Residents\InterfaceDX.res" /QUIET
	pbcompiler Interface/WebView2.pb /IGNORERESIDENT WebView2.res /RESIDENT "$(PUREBASIC_HOME)\Residents\WebView2.res" /QUIET
	pbcompiler Windows.pb /IGNORERESIDENT Windows.res /RESIDENT "$(PUREBASIC_HOME)\Residents\Windows.res" /QUIET
	pbcompiler ../expat.pb /IGNORERESIDENT Expat.res /RESIDENT "$(PUREBASIC_HOME)\Residents\Expat.res" /QUIET
	pbcompiler ../Scintilla.pb /IGNORERESIDENT Scintilla.res /RESIDENT "$(PUREBASIC_HOME)\Residents\Scintilla.res" /QUIET
	pbcompiler ../OpenGL.pb /IGNORERESIDENT OpenGL.res /RESIDENT "$(PUREBASIC_HOME)\Residents\OpenGL.res" /QUIET
