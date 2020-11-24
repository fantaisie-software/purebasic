XIncludeFile "common.pbi"

Import "edbbcli.lib"
       Api(BackupFree, (arg1), 4)
       Api(HrBackupClose, (arg1), 4)
       Api(HrBackupEnd, (arg1), 4)
  AnsiWide(HrBackupGetBackupLogs, (arg1, arg2, arg3), 12)
  AnsiWide(HrBackupGetDatabaseNames, (arg1, arg2, arg3), 12)
  AnsiWide(HrBackupOpenFile, (arg1, arg2, arg3, arg4), 16)
  AnsiWide(HrBackupPrepare, (arg1, arg2, arg3, arg4, arg5), 20)
       Api(HrBackupRead, (arg1, arg2, arg3, arg4), 16)
       Api(HrBackupTruncateLogs, (arg1), 4)
       Api(HrRestoreEnd, (arg1), 4)
  AnsiWide(HrRestoreGetDatabaseLocations, (arg1, arg2, arg3), 12)
  AnsiWide(HrRestorePrepare, (arg1, arg2, arg3), 12)
  AnsiWide(HrRestoreRegister, (arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8), 32)
       Api(HrRestoreRegisterComplete, (arg1, arg2), 8)
  AnsiWide(HrSetCurrentBackupLog, (arg1, arg2, arg3), 12)
       Api(I_HrCheckBackupLogs, (arg1), 4)
EndImport
