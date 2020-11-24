XIncludeFile "common.pbi"

Import "ddraw.lib"
       Api(DirectDrawCreate, (arg1, arg2, arg3), 12)
       Api(DirectDrawCreateClipper, (arg1, arg2, arg3), 12)
  AnsiWide(DirectDrawEnumerate, (arg1, arg2), 8)
EndImport
