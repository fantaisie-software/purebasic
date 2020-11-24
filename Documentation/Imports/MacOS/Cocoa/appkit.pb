XIncludeFile "common.pbi"

ImportC "-framework AppKit"
  ApiC(NSBeep, ())
  ApiC(NSDisableScreenUpdates, ())
  ApiC(NSEnableScreenUpdates, ())
  ApiC(NSPerformService, (itemName, pboard))
EndImport
