XIncludeFile "common.pbi"

Import "win32spl.lib"
       Api(InitializePrintMonitor, (arg1), 4)
       Api(InitializePrintProvidor, (arg1, arg2, arg3), 12)
EndImport
