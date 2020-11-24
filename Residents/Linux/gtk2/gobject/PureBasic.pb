
IncludePath "../glib"
XIncludeFile "PureBasic.pb"
IncludePath "../gobject"

Macro g_signal_connect_(a,b,c,d)
  g_signal_connect_data_(a,b,c,d,0,0)
EndMacro

XIncludeFile "gboxed.pb"
XIncludeFile "gtype.pb"
XIncludeFile "gclosure.pb"
XIncludeFile "genums.pb"
XIncludeFile "gmarshal.pb"
XIncludeFile "gobject.pb"
XIncludeFile "gvalue.pb"
XIncludeFile "gparam.pb"
XIncludeFile "gparamspecs.pb"
XIncludeFile "gsignal.pb"
XIncludeFile "gsourceclosure.pb"
XIncludeFile "gtypemodule.pb"
XIncludeFile "gtypeplugin.pb"
XIncludeFile "gvaluearray.pb"
XIncludeFile "gvaluecollector.pb"
XIncludeFile "gvaluetypes.pb"
