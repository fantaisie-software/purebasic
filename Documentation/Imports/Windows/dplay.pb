XIncludeFile "common.pbi"

Import "dplay.lib"
       Api(DirectPlayCreateOLD, (arg1, arg2, arg3), 12)
       Api(DirectPlayEnumerateOLD, (arg1, arg2), 8)
EndImport
