XIncludeFile "common.pbi"

Import "rasdlg.lib"
  AnsiWide(RasAutodialDisableDlg, (arg1), 4)
  AnsiWide(RasAutodialQueryDlg, (arg1, arg2, arg3), 12)
  AnsiWide(RasDialDlg, (arg1, arg2, arg3, arg4), 16)
  AnsiWide(RasEntryDlg, (arg1, arg2, arg3), 12)
  AnsiWide(RasMonitorDlg, (arg1, arg2), 8)
  AnsiWide(RasPhonebookDlg, (arg1, arg2, arg3), 12)
EndImport
