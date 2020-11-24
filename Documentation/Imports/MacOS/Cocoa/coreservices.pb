XIncludeFile "common.pbi"

ImportC "-framework CoreServices"
  ApiC(LSOpenCFURLRef, (inURL, *outLaunchedURL))
EndImport
