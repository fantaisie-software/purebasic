XIncludeFile "common.pbi"

Import "loadperf.lib"
  AnsiWide(LoadPerfCounterTextStrings, (arg1, arg2), 8)
  AnsiWide(UnloadPerfCounterTextStrings, (arg1, arg2), 8)
EndImport
