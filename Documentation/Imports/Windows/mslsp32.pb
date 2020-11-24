XIncludeFile "common.pbi"

Import "mslsp32.lib"
       Api(LSEnumProviders, (arg1, arg2), 8)
       Api(LSFreeHandle, (arg1), 4)
       Api(LSGetMessage, (arg1, arg2, arg3, arg4), 16)
       Api(LSInstall, (arg1), 4)
       Api(LSLicenseUnitsGet, (arg1, arg2, arg3, arg4, arg5, arg6), 24)
       Api(LSLicenseUnitsSet, (arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9), 36)
       Api(LSQuery, (arg1, arg2, arg3, arg4, arg5), 20)
       Api(LSRelease, (arg1, arg2, arg3), 12)
       Api(LSRequest, (arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9), 36)
       Api(LSUpdate, (arg1, arg2, arg3, arg4, arg5, arg6), 24)
EndImport
