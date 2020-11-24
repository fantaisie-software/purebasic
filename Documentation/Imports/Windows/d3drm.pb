XIncludeFile "common.pbi"

Import "d3drm.lib"
       Api(D3DRMColorGetAlpha, (arg1), 4)
       Api(D3DRMColorGetBlue, (arg1), 4)
       Api(D3DRMColorGetGreen, (arg1), 4)
       Api(D3DRMColorGetRed, (arg1), 4)
  AnsiWide(D3DRMCreateColorRGB, (arg1, arg2, arg3, arg4), 16)
       Api(D3DRMMatrixFromQuaternion, (arg1, arg2), 8)
       Api(D3DRMQuaternionFromRotation, (arg1, arg2, arg3), 12)
       Api(D3DRMQuaternionMultiply, (arg1, arg2, arg3), 12)
       Api(D3DRMQuaternionSlerp, (arg1, arg2, arg3, arg4), 16)
       Api(D3DRMVectorAdd, (arg1, arg2, arg3), 12)
       Api(D3DRMVectorCrossProduct, (arg1, arg2, arg3), 12)
       Api(D3DRMVectorDotProduct, .f(arg1, arg2), 8)
       Api(D3DRMVectorModulus, (arg1), 4)
       Api(D3DRMVectorNormalize, (arg1), 4)
       Api(D3DRMVectorRandom, (arg1), 4)
       Api(D3DRMVectorReflect, (arg1, arg2, arg3), 12)
       Api(D3DRMVectorRotate, (arg1, arg2, arg3, arg4), 16)
       Api(D3DRMVectorScale, (arg1, arg2, arg3), 12)
       Api(D3DRMVectorSubtract, (arg1, arg2, arg3), 12)
       Api(Direct3DRMCreate, (arg1), 4)
EndImport
