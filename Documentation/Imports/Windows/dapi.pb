XIncludeFile "common.pbi"

Import "dapi.lib"
  AnsiWide(BatchExport, (arg1), 4)
  AnsiWide(BatchImport, (arg1), 4)
       Api(DAPIAllocBuffer, (arg1, arg2), 8)
       Api(DAPIEnd, (arg1), 4)
       Api(DAPIFreeMemory, (arg1), 4)
  AnsiWide(DAPIGetSiteInfo, (arg1, arg2, arg3), 12)
       Api(DapiLibMain, (arg1, arg2, arg3), 12)
  AnsiWide(DAPIRead, (arg1, arg2, arg3, arg4, arg5, arg6), 24)
  AnsiWide(DAPIStart, (arg1, arg2), 8)
       Api(DAPIUninitialize, (arg1), 4)
  AnsiWide(DAPIWrite, (arg1, arg2, arg3, arg4, arg5, arg6, arg7), 28)
  AnsiWide(NTExport, (arg1), 4)
  AnsiWide(NWExport, (arg1), 4)
  AnsiWide(SchemaPreload, (arg1, arg2), 8)
EndImport
