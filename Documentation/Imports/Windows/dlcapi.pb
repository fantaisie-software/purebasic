XIncludeFile "common.pbi"

Import "dlcapi.lib"
       Api(AcsLan, (arg1, arg2), 8)
       Api(DlcCallDriver, (arg1, arg2, arg3, arg4, arg5, arg6), 24)
       Api(NtAcsLan, (arg1, arg2, arg3, arg4), 16)
EndImport
