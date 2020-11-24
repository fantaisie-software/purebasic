XIncludeFile "common.pbi"

Import "rtm.lib"
       Api(RtmAddRoute, (arg1, arg2, arg3, arg4, arg5, arg6), 24)
       Api(RtmBlockConvertRoutesToStatic, (arg1, arg2, arg3), 12)
       Api(RtmBlockDeleteRoutes, (arg1, arg2, arg3), 12)
       Api(RtmBlockSetRouteEnable, (arg1, arg2, arg3, arg4), 16)
       Api(RtmCloseEnumerationHandle, (arg1), 4)
       Api(RtmCreateEnumerationHandle, (arg1, arg2, arg3), 12)
       Api(RtmCreateRouteTable, (arg1, arg2), 8)
       Api(RtmDeleteRoute, (arg1, arg2, arg3, arg4), 16)
       Api(RtmDeleteRouteTable, (arg1), 4)
       Api(RtmDequeueRouteChangeMessage, (arg1, arg2, arg3, arg4), 16)
       Api(RtmDeregisterClient, (arg1), 4)
       Api(RtmEnumerateGetNextRoute, (arg1, arg2), 8)
       Api(RtmGetFirstRoute, (arg1, arg2, arg3), 12)
       Api(RtmGetNetworkCount, (arg1), 4)
       Api(RtmGetNextRoute, (arg1, arg2, arg3), 12)
       Api(RtmGetRouteAge, (arg1), 4)
       Api(RtmIsRoute, (arg1, arg2, arg3), 12)
       Api(RtmRegisterClient, (arg1, arg2, arg3, arg4), 16)
EndImport
