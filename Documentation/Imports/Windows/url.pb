XIncludeFile "common.pbi"

Import "url.lib"
       Api(AddMIMEFileTypesPS, (arg1, arg2), 8)
       Api(InetIsOffline, (arg1), 4)
  AnsiWide(MIMEAssociationDialog, (arg1, arg2, arg3, arg4, arg5, arg6), 24)
  AnsiWide(TranslateURL, (arg1, arg2, arg3), 12)
  AnsiWide(URLAssociationDialog, (arg1, arg2, arg3, arg4, arg5, arg6), 24)
EndImport
