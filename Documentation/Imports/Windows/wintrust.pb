XIncludeFile "common.pbi"

Import "wintrust.lib"
       Api(WinLoadTrustProvider, (arg1), 4)
       Api(WinSubmitCertificate, (arg1), 4)
       Api(WinVerifyTrust, (arg1, arg2, arg3), 12)
EndImport
