XIncludeFile "common.pbi"

Import "activeds.lib"
       Api(ADsBuildEnumerator, (arg1, arg2), 8)
       Api(ADsBuildVarArrayInt, (arg1, arg2, arg3), 12)
       Api(ADsBuildVarArrayStr, (arg1, arg2, arg3), 12)
       Api(ADsDecodeBinaryData, (arg1, arg2, arg3), 12)
       Api(ADsEncodeBinaryData, (arg1, arg2, arg3), 12)
       Api(ADsEnumerateNext, (arg1, arg2, arg3, arg4), 16)
       Api(AdsFreeAdsValues, (arg1, arg2), 8)
       Api(ADsFreeEnumerator, (arg1), 4)
       Api(ADsGetLastError, (arg1, arg2, arg3, arg4, arg5), 20)
       Api(ADsGetObject, (arg1, arg2, arg3), 12)
       Api(ADsOpenObject, (arg1, arg2, arg3, arg4, arg5, arg6), 24)
       Api(ADsSetLastError, (arg1, arg2, arg3), 12)
       Api(AdsTypeToPropVariant, (arg1, arg2, arg3), 12)
       Api(AllocADsMem, (arg1), 4)
       Api(AllocADsStr, (arg1), 4)
       Api(FreeADsMem, (arg1), 4)
       Api(FreeADsStr, (arg1), 4)
       Api(PropVariantToAdsType, (arg1, arg2, arg3, arg4), 16)
       Api(ReallocADsMem, (arg1, arg2, arg3), 12)
       Api(ReallocADsStr, (arg1, arg2), 8)
EndImport
