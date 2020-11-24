XIncludeFile "common.pbi"

Import "dplayx.lib"
       Api(DirectPlayCreate, (arg1, arg2, arg3), 12)
  AnsiWide(DirectPlayEnumerate, (arg1, arg2), 8)
  AnsiWide(DirectPlayLobbyCreate, (arg1, arg2, arg3, arg4, arg5), 20)
EndImport
