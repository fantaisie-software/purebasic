XIncludeFile "common.pbi"

ImportC "-framework Carbon"
  
  ApiC(AECountItems, (arg1, arg2))
  ApiC(AECreateDesc, (arg1, arg2, arg3, arg4))
  ApiC(AEDisposeDesc, (arg1))
  ApiC(AEGetNthPtr, (arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8))
  ApiC(AEGetParamDesc, (arg1, arg2, arg3, arg4))
  ApiC(AEInstallEventHandler, (arg1, arg2, arg3, arg4, arg5))
  
  ApiC(EventAvail, (arg1, arg2))
  ApiC(FSRefMakePath, (arg1, arg2, arg3))
  ApiC(LaunchApplication, (arg1))
  ApiC(NativePathNameToFSSpec, (arg1, arg2, arg3))
  ApiC(RunApplicationEventLoop, ())
  
  ApiC(CallNextEventHandler, (arg1, arg2))
  ApiC(CopyEvent, (arg1))
  ApiC(GetControlEventTarget, (arg1))
  ApiC(GetCurrentEventKeyModifiers, ())
  ApiC(GetEventKind, (arg1))
  ApiC(GetEventParameter, (arg1, arg2, arg3, arg4, arg5, arg6, arg7))
  ApiC(GetMainEventLoop, ())
  ApiC(GetWindowEventTarget, (arg1))
  ApiC(InstallEventHandler, (arg1, arg2, arg3, arg4, arg5, arg6))
  ApiC(InstallEventLoopTimer, (arg1, arg2, arg3, arg4, arg5, arg6))
  ApiC(NewEventHandlerUPP, (arg1))
  ApiC(NewEventLoopTimerUPP, (arg1))
  ApiC(SendEventToEventTarget, (arg1, arg2))
  
  ApiC(TISCopyCurrentKeyboardLayoutInputSource, ())
  ApiC(TISGetInputSourceProperty, (inputSource, propertyKey))
  
EndImport
