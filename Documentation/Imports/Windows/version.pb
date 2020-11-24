XIncludeFile "common.pbi"

Import "version.lib"
  AnsiWide(GetFileVersionInfo, (arg1, arg2, arg3, arg4), 16)
  AnsiWide(GetFileVersionInfoSize, (arg1, arg2), 8)
  AnsiWide(VerFindFile, (arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8), 32)
  AnsiWide(VerInstallFile, (arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8), 32)
  AnsiWide(VerQueryValue, (arg1, arg2, arg3, arg4), 16)
  AnsiWide(VerQueryValueIndex, (arg1, arg2, arg3, arg4, arg5, arg6), 24)
EndImport
