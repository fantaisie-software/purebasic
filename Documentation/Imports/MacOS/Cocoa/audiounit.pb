XIncludeFile "common.pbi"

ImportC "-framework AudioUnit"
  ApiC(AudioComponentFindNext, (inComponent, *inDesc))
  ApiC(AudioComponentInstanceNew, (inComponent, *outInstance))
  ApiC(AudioComponentInstanceDispose, (inInstance))
  ApiC(AudioOutputUnitStart, (ci))
  ApiC(AudioOutputUnitStop, (ci))
  ApiC(AudioUnitInitialize, (inUnit))
  ApiC(AudioUnitUninitialize, (inUnit))
  ApiC(AudioUnitSetProperty, (inUnit, inID, inScope, inElement, *inData, inDataSize))
EndImport
