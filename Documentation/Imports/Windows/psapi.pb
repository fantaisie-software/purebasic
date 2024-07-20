XIncludeFile "common.pbi"

Import "psapi.lib"
       Api(GetProcessMemoryInfo, (arg1, arg2, arg3), 12)
EndImport
