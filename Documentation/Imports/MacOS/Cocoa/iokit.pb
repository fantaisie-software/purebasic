XIncludeFile "common.pbi"

ImportC "-framework IOKit"
  ApiC(IOHIDDeviceGetProperty, (device, key))
  ApiC(IOHIDManagerCopyDevices, (manager))
  ApiC(IOHIDManagerCreate, (allocator, options))
  ApiC(IOHIDManagerOpen, (manager, options))
  ApiC(IOHIDManagerSetDeviceMatching, (manager, matching))
  ApiC(IOObjectRelease, (object))
  ApiC(IORegistryEntryCreateCFProperty, (entry, key, allocator, options))
  ApiC(IORegistryEntryFromPath, (masterPort, path.p-ascii))
EndImport
