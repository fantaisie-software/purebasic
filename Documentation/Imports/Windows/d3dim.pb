XIncludeFile "common.pbi"

Import "d3dim.lib"
       Api(Direct3D_HALCleanUp, (arg1, arg2), 8)
       Api(Direct3DCreate, (arg1, arg2, arg3), 12)
       Api(FlushD3DDevices, (arg1), 4)
       Api(FlushD3DDevices2, (arg1), 4)
       Api(PaletteAssociateNotify, (arg1, arg2, arg3, arg4), 16)
       Api(PaletteUpdateNotify, (arg1, arg2, arg3, arg4, arg5), 20)
       Api(SurfaceFlipNotify, (arg1), 4)
EndImport
