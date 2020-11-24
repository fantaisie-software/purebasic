XIncludeFile "common.pbi"

Import "rassapi.lib"
       Api(RasAdminCompressPhoneNumber, (arg1, arg2), 8)
       Api(RasAdminDLLInit, (arg1, arg2, arg3), 12)
       Api(RasAdminFreeBuffer, (arg1), 4)
       Api(RasAdminGetErrorString, (arg1, arg2, arg3), 12)
       Api(RasAdminGetUserAccountServer, (arg1, arg2, arg3), 12)
       Api(RasAdminGetUserParms, (arg1, arg2), 8)
       Api(RasAdminPortClearStatistics, (arg1, arg2), 8)
       Api(RasAdminPortDisconnect, (arg1, arg2), 8)
       Api(RasAdminPortEnum, (arg1, arg2, arg3), 12)
       Api(RasAdminPortGetInfo, (arg1, arg2, arg3, arg4, arg5), 20)
       Api(RasAdminServerGetInfo, (arg1, arg2), 8)
       Api(RasAdminSetUserParms, (arg1, arg2, arg3), 12)
       Api(RasAdminUserGetInfo, (arg1, arg2, arg3), 12)
       Api(RasAdminUserSetInfo, (arg1, arg2, arg3), 12)
EndImport
