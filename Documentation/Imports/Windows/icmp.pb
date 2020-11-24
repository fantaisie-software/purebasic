XIncludeFile "common.pbi"

Import "icmp.lib"
       Api(do_echo_rep, (arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10), 40)
       Api(do_echo_req, (arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10), 40)
       Api(IcmpCloseHandle, (arg1), 4)
       Api(IcmpCreateFile, (), 0)
       Api(IcmpParseReplies, (arg1, arg2), 8)
       Api(IcmpSendEcho, (arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8), 32)
       Api(IcmpSendEcho2, (arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11), 44)
       Api(register_icmp, (), 0)
EndImport
