XIncludeFile "common.pbi"

Import "dsound.lib"
       Api(DirectSoundCaptureCreate, (arg1, arg2, arg3), 12)
  AnsiWide(DirectSoundCaptureEnumerate, (arg1, arg2), 8)
       Api(DirectSoundCreate, (arg1, arg2, arg3), 12)
  AnsiWide(DirectSoundEnumerate, (arg1, arg2), 8)
EndImport
