XIncludeFile "common.pbi"

Import "lz32.lib"
       Api(CopyLZFile, (arg1, arg2), 8)
  AnsiWide(GetExpandedName, (arg1, arg2), 8)
       Api(LZClose, (arg1), 4)
       Api(LZCopy, (arg1, arg2), 8)
       Api(LZDone, (), 0)
       Api(LZInit, (arg1), 4)
  AnsiWide(LZOpenFile, (arg1, arg2, arg3), 12)
       Api(LZRead, (arg1, arg2, arg3), 12)
       Api(LZSeek, (arg1, arg2, arg3), 12)
       Api(LZStart, (), 0)
EndImport
