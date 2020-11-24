XIncludeFile "common.pbi"

Import "shfolder.lib"
  AnsiWide(SHGetFolderPath, (arg1, arg2, arg3, arg4, arg5), 20)
EndImport
