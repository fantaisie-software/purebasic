﻿XIncludeFile "common.pbi"

Import "pdh.lib"
       Api(DLLInit, (arg1, arg2, arg3), 12)
  AnsiWide(PdhAddCounter, (arg1, arg2, arg3, arg4), 16)
  AnsiWide(PdhBrowseCounters, (arg1), 4)
       Api(PdhCalculateCounterFromRawValue, (arg1, arg2, arg3, arg4, arg5), 20)
       Api(PdhCloseQuery, (arg1), 4)
       Api(PdhCollectQueryData, (arg1), 4)
       Api(PdhComputeCounterStatistics, (arg1, arg2, arg3, arg4, arg5, arg6), 24)
  AnsiWide(PdhConnectMachine, (arg1), 4)
  AnsiWide(PdhEnumMachines, (arg1, arg2, arg3), 12)
  AnsiWide(PdhEnumObjectItems, (arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9), 36)
  AnsiWide(PdhEnumObjects, (arg1, arg2, arg3, arg4, arg5, arg6), 24)
  AnsiWide(PdhExpandCounterPath, (arg1, arg2, arg3), 12)
  AnsiWide(PdhGetCounterInfo, (arg1, arg2, arg3, arg4), 16)
  AnsiWide(PdhGetDefaultPerfCounter, (arg1, arg2, arg3, arg4, arg5), 20)
  AnsiWide(PdhGetDefaultPerfObject, (arg1, arg2, arg3, arg4), 16)
       Api(PdhGetDllVersion, (arg1), 4)
       Api(PdhGetFormattedCounterValue, (arg1, arg2, arg3, arg4), 16)
       Api(PdhGetRawCounterValue, (arg1, arg2, arg3), 12)
  AnsiWide(PdhMakeCounterPath, (arg1, arg2, arg3, arg4), 16)
       Api(PdhOpenQuery, (arg1, arg2, arg3), 12)
  AnsiWide(PdhParseCounterPath, (arg1, arg2, arg3, arg4), 16)
  AnsiWide(PdhParseInstanceName, (arg1, arg2, arg3, arg4, arg5, arg6), 24)
       Api(PdhRemoveCounter, (arg1), 4)
       Api(PdhSetCounterScaleFactor, (arg1, arg2), 8)
  AnsiWide(PdhValidatePath, (arg1), 4)
       Api(PdhVbAddCounter, (arg1, arg2, arg3), 12)
       Api(PdhVbCreateCounterPathList, (arg1, arg2), 8)
       Api(PdhVbGetCounterPathElements, (arg1, arg2, arg3, arg4, arg5, arg6, arg7), 28)
       Api(PdhVbGetCounterPathFromList, (arg1, arg2, arg3), 12)
       Api(PdhVbGetDoubleCounterValue, (arg1, arg2), 8)
       Api(PdhVbGetOneCounterPath, (arg1, arg2, arg3, arg4), 16)
       Api(PdhVbIsGoodStatus, (arg1), 4)
       Api(PdhVbOpenQuery, (arg1), 4)
EndImport
