; Root file for gtk/gobject
;
CompilerIf SizeOf(Integer) = 4 ; x86, PowerPC
  Macro PB_Align(pad32, pad64, index=)
    CompilerIf pad32 > 0
      PB_Alignment#index.b[pad32]
    CompilerEndIf
  EndMacro
CompilerElse ; x64
  Macro PB_Align(pad32, pad64, index=)
    CompilerIf pad64 > 0
      PB_Alignment#index.b[pad64]
    CompilerEndIf
  EndMacro
CompilerEndIf

XIncludeFile "galloca.pb"
XIncludeFile "garray.pb"
XIncludeFile "gasyncqueue.pb"
XIncludeFile "gatomic.pb"
XIncludeFile "gbacktrace.pb"
XIncludeFile "gcache.pb"
XIncludeFile "gcompletion.pb"
XIncludeFile "gconvert.pb"
XIncludeFile "gdataset.pb"
XIncludeFile "gdate.pb"
XIncludeFile "gdir.pb"
XIncludeFile "gerror.pb"
XIncludeFile "gfileutils.pb"
XIncludeFile "ghash.pb"
XIncludeFile "ghook.pb"
XIncludeFile "gi18n-lib.pb"
XIncludeFile "gi18n.pb"
XIncludeFile "giochannel.pb"
XIncludeFile "gkeyfile.pb"
XIncludeFile "glist.pb"
; XIncludeFile "gmacros.pb"
XIncludeFile "gmain.pb"
XIncludeFile "gmarkup.pb"
XIncludeFile "gmem.pb"
XIncludeFile "gmessages.pb"
XIncludeFile "gnode.pb"
XIncludeFile "goption.pb"
XIncludeFile "gpattern.pb"
XIncludeFile "gprimes.pb"
XIncludeFile "gprintf.pb"
XIncludeFile "gqsort.pb"
XIncludeFile "gquark.pb"
XIncludeFile "gqueue.pb"
XIncludeFile "grand.pb"
XIncludeFile "grel.pb"
XIncludeFile "gscanner.pb"
XIncludeFile "gshell.pb"
XIncludeFile "gslist.pb"
XIncludeFile "gspawn.pb"
XIncludeFile "gstdio.pb"
XIncludeFile "gstrfuncs.pb"
XIncludeFile "gstring.pb"
XIncludeFile "gthread.pb"
XIncludeFile "gthreadpool.pb"
XIncludeFile "gtimer.pb"
XIncludeFile "gtree.pb"
XIncludeFile "gtypes.pb"
XIncludeFile "gunicode.pb"
XIncludeFile "gutils.pb"
XIncludeFile "gwin32.pb"
