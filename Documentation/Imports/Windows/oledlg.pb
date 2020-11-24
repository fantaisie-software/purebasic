XIncludeFile "common.pbi"

Import "oledlg.lib"
  AnsiWide(OleUIAddVerbMenu, (arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9), 36)
  AnsiWide(OleUIBusy, (arg1), 4)
       Api(OleUICanConvertOrActivateAs, (arg1, arg2, arg3), 12)
  AnsiWide(OleUIChangeIcon, (arg1), 4)
  AnsiWide(OleUIChangeSource, (arg1), 4)
  AnsiWide(OleUIConvert, (arg1), 4)
  AnsiWide(OleUIEditLinks, (arg1), 4)
  AnsiWide(OleUIInsertObject, (arg1), 4)
  AnsiWide(OleUIObjectProperties, (arg1), 4)
  AnsiWide(OleUIPasteSpecial, (arg1), 4)
  AnsiWide(OleUIUpdateLinks, (arg1, arg2, arg3, arg4), 16)
EndImport
