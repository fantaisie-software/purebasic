XIncludeFile "common.pbi"

Import "dsetup.lib"
  AnsiWide(DirectXDeviceDriverSetup, (arg1, arg2, arg3, arg4), 16)
       Api(DirectXLoadString, (arg1, arg2, arg3), 12)
  AnsiWide(DirectXRegisterApplication, (arg1, arg2), 8)
  AnsiWide(DirectXSetup, (arg1, arg2, arg3), 12)
       Api(DirectXSetupCallback, (arg1, arg2, arg3, arg4, arg5), 20)
       Api(DirectXSetupGetFileVersion, (arg1, arg2, arg3), 12)
       Api(DirectXSetupGetVersion, (arg1, arg2), 8)
       Api(DirectXSetupIsEng, (), 0)
       Api(DirectXSetupIsJapan, (), 0)
       Api(DirectXSetupIsJapanNec, (), 0)
       Api(DirectXSetupSetCallback, (arg1), 4)
       Api(DirectXUnRegisterApplication, (arg1, arg2), 8)
EndImport
