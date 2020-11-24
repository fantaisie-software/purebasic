XIncludeFile "common.pbi"

Import "ws2_32.lib"
       Api(freeaddrinfo, (arg1), 4)
       Api(getaddrinfo, (arg1, arg2, arg3, arg4), 16)
       Api(getnameinfo, (arg1, arg2, arg3, arg4, arg5, arg6, arg7), 28)
       Api(inet_ntop, (arg1, arg2, arg3, arg4), 16)
       Api(inet_pton, (arg1, arg2, arg3), 12)
       Api(WSAIoctl, (arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9), 36)
  AnsiWide(WSASocket, (arg1, arg2, arg3, arg4, arg5, arg6), 24)
EndImport
