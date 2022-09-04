; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------
;
; Windows unicode dependent structures and constants
;

Structure WIN32_FIND_DATA
  dwFileAttributes.l
  ftCreationTime.FILETIME
  ftLastAccessTime.FILETIME
  ftLastWriteTime.FILETIME
  nFileSizeHigh.l
  nFileSizeLow.l
  dwReserved0.l
  dwReserved1.l
  cFileName.c[#MAX_PATH]
  cAlternateFileName.c[14]
  CompilerIf #PB_Compiler_Unicode = 0
    PB_Align(2, 2)
  CompilerEndIf
EndStructure


Structure TEXTMETRIC
  tmHeight.l
  tmAscent.l
  tmDescent.l
  tmInternalLeading.l
  tmExternalLeading.l
  tmAveCharWidth.l
  tmMaxCharWidth.l
  tmWeight.l
  tmOverhang.l
  tmDigitizedAspectX.l
  tmDigitizedAspectY.l
  tmFirstChar.c
  tmLastChar.c
  tmDefaultChar.c
  tmBreakChar.c
  tmItalic.b
  tmUnderlined.b
  tmStruckOut.b
  tmPitchAndFamily.b
  tmCharSet.b
  PB_Align(3, 3)
EndStructure


Structure OUTLINETEXTMETRIC
  otmSize.l
  otmTextMetrics.TEXTMETRIC
  otmFiller.b
  otmPanoseNumber.PANOSE
  PB_Align(1, 1, 1)
  otmfsSelection.l
  otmfsType.l
  otmsCharSlopeRise.l
  otmsCharSlopeRun.l
  otmItalicAngle.l
  otmEMSquare.l
  otmAscent.l
  otmDescent.l
  otmLineGap.l
  otmsCapEmHeight.l
  otmsXHeight.l
  otmrcFontBox.RECT
  otmMacAscent.l
  otmMacDescent.l
  otmMacLineGap.l
  otmusMinimumPPEM.l
  otmptSubscriptSize.POINT
  otmptSubscriptOffset.POINT
  otmptSuperscriptSize.POINT
  otmptSuperscriptOffset.POINT
  otmsStrikeoutSize.l
  otmsStrikeoutPosition.l
  otmsUnderscoreSize.l
  otmsUnderscorePosition.l
  CompilerIf #PB_Compiler_Unicode = 0
    PB_Align(0, 4, 2)
  CompilerEndIf
  *otmpFamilyName
  *otmpFaceName
  *otmpStyleName
  *otmpFullName
EndStructure


Structure NEWTEXTMETRIC
  tmHeight.l
  tmAscent.l
  tmDescent.l
  tmInternalLeading.l
  tmExternalLeading.l
  tmAveCharWidth.l
  tmMaxCharWidth.l
  tmWeight.l
  tmOverhang.l
  tmDigitizedAspectX.l
  tmDigitizedAspectY.l
  tmFirstChar.c
  tmLastChar.c
  tmDefaultChar.c
  tmBreakChar.c
  tmItalic.b
  tmUnderlined.b
  tmStruckOut.b
  tmPitchAndFamily.b
  tmCharSet.b
  PB_Align(3, 3)
  ntmFlags.l
  ntmSizeEM.l
  ntmCellHeight.l
  ntmAvgWidth.l
EndStructure


Structure NEWTEXTMETRICEX
  ntmTm.NEWTEXTMETRIC
  ntmFontSig.FONTSIGNATURE
EndStructure



Structure LOGFONT
  lfHeight.l
  lfWidth.l
  lfEscapement.l
  lfOrientation.l
  lfWeight.l
  lfItalic.b
  lfUnderline.b
  lfStrikeOut.b
  lfCharSet.b
  lfOutPrecision.b
  lfClipPrecision.b
  lfQuality.b
  lfPitchAndFamily.b
  lfFaceName.c[#LF_FACESIZE]
EndStructure


Structure NONCLIENTMETRICS
  cbSize.l
  iBorderWidth.l
  iScrollWidth.l
  iScrollHeight.l
  iCaptionWidth.l
  iCaptionHeight.l
  lfCaptionFont.LOGFONT
  iSMCaptionWidth.l
  iSMCaptionHeight.l
  lfSMCaptionFont.LOGFONT
  iMenuWidth.l
  iMenuHeight.l
  lfMenuFont.LOGFONT
  lfStatusFont.LOGFONT
  lfMessageFont.LOGFONT
EndStructure


Structure ICONMETRICS
  cbSize.l
  iHorzSpacing.l
  iVertSpacing.l
  iTitleWrap.l
  lfFont.LOGFONT
EndStructure



Structure ENUMLOGFONT
  elfLogFont.LOGFONT
  elfFullName.c[#LF_FULLFACESIZE]
  elfStyle.c[#LF_FACESIZE]
EndStructure


Structure EXTLOGFONT
  elfLogFont.LOGFONT
  elfFullName.c[#LF_FULLFACESIZE]
  elfStyle.c[#LF_FACESIZE]
  elfVersion.l
  elfStyleSize.l
  elfMatch.l
  elfReserved.l
  elfVendorId.b[#ELF_VENDOR_SIZE]
  elfCulture.l
  elfPanose.PANOSE
  PB_Align(2, 2)
EndStructure


Structure DEVMODE_PRINTER
  dmOrientation.w
  dmPaperSize.w
  dmPaperLength.w
  dmPaperWidth.w
  dmScale.w
  dmCopies.w
  dmDefaultSource.w
  dmPrintQuality.w
EndStructure


Structure DEVMODE_DISPLAY
  dmPosition.POINT
  dmDisplayOrientation.l
  dmDisplayFixedOutput.l
EndStructure


Structure DEVMODE
  dmDeviceName.c[#CCHDEVICENAME]
  dmSpecVersion.w
  dmDriverVersion.w
  dmSize.w
  dmDriverExtra.w
  dmFields.l
  StructureUnion
    Printer.DEVMODE_PRINTER
    Display.DEVMODE_DISPLAY
  EndStructureUnion
  dmColor.w
  dmDuplex.w
  dmYResolution.w
  dmTTOption.w
  dmCollate.w
  dmFormName.c[#CCHFORMNAME]
  dmLogPixels.w
  dmBitsPerPel.l
  dmPelsWidth.l
  dmPelsHeight.l
  StructureUnion
    dmDisplayFlags.l
    dmNup.l
  EndStructureUnion
  dmDisplayFrequency.l
  dmICMMethod.l
  dmICMIntent.l
  dmMediaType.l
  dmDitherType.l
  dmReserved1.l
  dmReserved2.l
  dmPanningWidth.l
  dmPanningHeight.l
EndStructure



Structure ENUMLOGFONTEX
  elfLogFont.LOGFONT
  elfFullName.c[#LF_FULLFACESIZE]
  elfStyle.c[#LF_FACESIZE]
  elfScript.c[#LF_FACESIZE]
EndStructure

Structure LOGCOLORSPACE
  lcsSignature.l
  lcsVersion.l
  lcsSize.l
  lcsCSType.l
  lcsIntent.l
  lcsEndPoints.CIEXYZTRIPLE
  lcsGammaRed.l
  lcsGammaGreen.l
  lcsGammaBlue.l
  lcsFileName.c[#MAX_PATH]
EndStructure

Structure LOGCOLORSPACEA
  lcsSignature.l
  lcsVersion.l
  lcsSize.l
  lcsCSType.l
  lcsIntent.l
  lcsEndPoints.CIEXYZTRIPLE
  lcsGammaRed.l
  lcsGammaGreen.l
  lcsGammaBlue.l
  lcsFileName.a[#MAX_PATH] ; always ASCII, important for structure EMRCREATECOLORSPACE
EndStructure

Structure LOGCOLORSPACEW
  lcsSignature.l
  lcsVersion.l
  lcsSize.l
  lcsCSType.l
  lcsIntent.l
  lcsEndPoints.CIEXYZTRIPLE
  lcsGammaRed.l
  lcsGammaGreen.l
  lcsGammaBlue.l
  lcsFileName.u[#MAX_PATH] ; always Unicode
EndStructure


Structure MIXERCAPS
  wMid.w
  wPid.w
  vDriverVersion.l
  szPname.c[#MAXPNAMELEN]
  fdwSupport.l
  cDestinations.l
EndStructure


Structure MIXERLINE_TARGET
  dwType.l
  dwDeviceID.l
  wMid.w
  wPid.w
  vDriverVersion.l
  szPname.c[#MAXPNAMELEN]
EndStructure


Structure MIXERLINE
  cbStruct.l
  dwDestination.l
  dwSource.l
  dwLineID.l
  fdwLine.l
  dwUser.i
  dwComponentType.l
  cChannels.l
  cConnections.l
  cControls.l
  szShortName.c[#MIXER_SHORT_NAME_CHARS]
  szName.c[#MIXER_LONG_NAME_CHARS]
  Target.MIXERLINE_TARGET
EndStructure


Structure WAVEOUTCAPS
  wMid.w
  wPid.w
  vDriverVersion.l
  szPname.c[#MAXPNAMELEN]
  dwFormats.l
  wChannels.w
  wReserved1.w
  dwSupport.l
EndStructure

Structure WAVEINCAPS
  wMid.w
  wPid.w
  vDriverVersion.l
  szPname.c[#MAXPNAMELEN]
  dwFormats.l
  wChannels.w
  wReserved1.w
EndStructure


Structure MIDIOUTCAPS
  wMid.w
  wPid.w
  vDriverVersion.l
  szPname.c[#MAXPNAMELEN]
  wTechnology.w
  wVoices.w
  wNotes.w
  wChannelMask.w
  dwSupport.l
EndStructure

Structure MIDIINCAPS
  wMid.w
  wPid.w
  vDriverVersion.l
  szPname.c[#MAXPNAMELEN]
  dwSupport.l
EndStructure


Structure AUXCAPS
  wMid.w
  wPid.w
  vDriverVersion.l
  szPname.c[#MAXPNAMELEN]
  wTechnology.w
  wReserved1.w
  dwSupport.l
EndStructure

Structure JOYCAPS
  wMid.w
  wPid.w
  szPname.c[#MAXPNAMELEN]
  wXmin.l
  wXmax.l
  wYmin.l
  wYmax.l
  wZmin.l
  wZmax.l
  wNumButtons.l
  wPeriodMin.l
  wPeriodMax.l
  wRmin.l
  wRmax.l
  wUmin.l
  wUmax.l
  wVmin.l
  wVmax.l
  wCaps.l
  wMaxAxes.l
  wNumAxes.l
  wMaxButtons.l
  szRegKey.c[#MAXPNAMELEN]
  szOEMVxD.c[#MAX_JOYSTICKOEMVXDNAME]
EndStructure


Structure STYLEBUF
  dwStyle.l
  szDescription.c[#STYLE_DESCRIPTION_SIZE]
EndStructure

Structure NOTIFYICONDATA
  cbSize.l
  PB_Align(0, 4, 1)
  hWnd.i
  uID.l
  uFlags.l
  uCallbackMessage.l
  PB_Align(0, 4, 2)
  hIcon.i
  szTip.c[64]
EndStructure

Structure SHFILEINFO
  hIcon.i
  iIcon.l
  dwAttributes.l
  szDisplayName.c[#MAX_PATH]
  szTypeName.c[80]
  Compilerif #PB_Compiler_Unicode = 0
    PB_Align(0, 4)
  CompilerEndIf
EndStructure

Structure OSVERSIONINFO
  dwOSVersionInfoSize.l
  dwMajorVersion.l
  dwMinorVersion.l
  dwBuildNumber.l
  dwPlatformId.l
  szCSDVersion.c[128]
EndStructure


Structure CHARFORMAT
  cbSize.l
  dwMask.l
  dwEffects.l
  yHeight.l
  yOffset.l
  crTextColor.l
  bCharSet.b
  bPitchAndFamily.b
  szFaceName.c[#LF_FACESIZE]
  PB_Align(2, 2)
EndStructure

Structure CHARFORMAT2 Extends CHARFORMAT
  wWeight.w
  sSpacing.w
  crBackColor.l
  lcid.l
  dwReserved.l
  sStyle.w
  wKerning.w
  bUnderlineType.b
  bAnimation.b
  bRevAuthor.b
  bReserved1.b
EndStructure


Structure NMCBEDRAGBEGIN
  hdr.NMHDR
  iItemid.l
  szText.c[#CBEMAXSTRLEN]
  Compilerif #PB_Compiler_Unicode
    PB_Align(0, 4)
  CompilerEndIf
EndStructure

Structure NMCBEENDEDIT
  hdr.NMHDR
  fChanged.l
  iNewSelection.l
  szText.c[#CBEMAXSTRLEN]
  iWhy.l
  Compilerif #PB_Compiler_Unicode
    PB_Align(0, 4)
  CompilerEndIf
EndStructure


Structure NMDATETIMEFORMAT
  nmhdr.NMHDR
  *pszFormat
  st.SYSTEMTIME
  *pszDisplay
  szDisplay.c[64]
EndStructure


Structure NMTTDISPINFO
  hdr.NMHDR
  *lpszText
  szText.c[80]
  hinst.i
  uFlags.l
  PB_Align(0, 4)
  lParam.i
EndStructure

; The C version (although defined the same way) is much smaller. dunno whats wrong here
Structure EMRCREATECOLORSPACE
  emr.EMR
  ihCS.l
  lcs.LOGCOLORSPACEA
EndStructure



; Service related
;
#MAX_MODULE_NAME32 = 255

Structure MODULEENTRY32
  dwSize.l
  th32ModuleID.l
  th32ProcessID.l
  GlblcntUsage.l
  ProccntUsage.l
  PB_Align(0, 4, 1)
  *modBaseAddr
  modBaseSize.l
  PB_Align(0, 4, 2)
  hModule.i
  szModule.c[#MAX_MODULE_NAME32 + 1]
  szExePath.c[#MAX_PATH]
  Compilerif #PB_Compiler_Unicode = 0
    PB_Align(0, 4, 3)
  CompilerEndIf
EndStructure

Structure PROCESSENTRY32
  dwSize.l
  cntUsage.l
  th32ProcessID.l
  PB_Align(0, 4)
  th32DefaultHeapID.i
  th32ModuleID.l
  cntThreads.l
  th32ParentProcessID.l
  pcPriClassBase.l
  dwFlags.l
  szExeFile.c[#MAX_PATH]
  Compilerif #PB_Compiler_Unicode
    PB_Align(0, 4, 2)
  CompilerEndIf
EndStructure


Structure TBBUTTONINFO
  cbSize.l        ; Unsigned
  dwMask.l        ; Unsigned
  idCommand.l
  iImage.l
  fsState.b
  fsStyle.b
  cx.w            ; Unsigned
  PB_Align(0, 4, 1)
  lParam.i        ; Unsigned
 *pszText
  cchText.l
  PB_Align(0, 4, 2)
EndStructure


Structure OSVERSIONINFOEX
  dwOSVersionInfoSize.l
  dwMajorVersion.l
  dwMinorVersion.l
  dwBuildNumber.l
  dwPlatformId.l
  szCSDVersion.c[128]
  wServicePackMajor.w
  wServicePackMinor.w
  wSuiteMask.w
  wProductType.b
  wReserved.b
EndStructure


Structure DISPLAY_DEVICE
  cb.l
  DeviceName.c[32]
  DeviceString.c[128]
  StateFlags.l
  DeviceID.c[128]
  DeviceKey.c[128]
EndStructure

Structure DEV_BROADCAST_PORT
  dbcp_size.l
  dbcp_devicetype.l
  dbcp_reserved.l
  StructureUnion
    dbcp_name.c[0]
    dummydbcp_name.c[1]
  EndStructureUnion
  CompilerIf #PB_Compiler_Unicode = 0
    PB_Align(3, 3)
  CompilerElse
    PB_Align(2, 2)
  CompilerEndif
EndStructure

Structure MULTIKEYHELP
  mkSize.l
  mkKeylist.c
  StructureUnion
    szKeyphrase.c[0]
    dummyszKeyphrase.c[1]
  EndStructureUnion
  CompilerIf #PB_Compiler_Unicode = 0
    PB_Align(2, 2)
  CompilerEndIf
EndStructure

Structure HELPWININFO
  wStructSize.l
  x.l
  y.l
  dx.l
  dy.l
  wMax.l
  rgchMember.c[2]
  CompilerIf #PB_Compiler_Unicode = 0
    PB_Align(2, 2)
  CompilerEndIf
EndStructure


Structure MONHSZSTRUCT
  cb.l
  fsAction.l
  dwTime.l
  PB_Align(0, 4, 1)
  hsz.i
  hTask.i
  StructureUnion
    str.c[0]
    dummystr.c[1]
  EndStructureUnion
  CompilerIf #PB_Compiler_Unicode = 0
    PB_Align(3, 7, 2)
  CompilerElse
    PB_Align(2, 6, 2)
  CompilerEndIf
EndStructure


; Deprecated structures
;
Structure TOOLTIPTEXT Extends NMTTDISPINFO : EndStructure


CompilerIf #PB_Compiler_Unicode

  #ACM_OPEN = 1127
  
  #HDM_GETITEM = 4619
  #HDM_INSERTITEM = 4618
  #HDM_SETITEM =4620
  
  #HDN_BEGINTRACK = (-326)
  #HDN_DIVIDERDBLCLICK =(-325)
  #HDN_ENDTRACK = (-327)
  #HDN_ITEMCHANGED =(-321)
  #HDN_ITEMCHANGING = (-320)
  #HDN_ITEMCLICK =(-322)
  #HDN_ITEMDBLCLICK = (-323)
  #HDN_TRACK =(-328)
  #HDN_GETDISPINFO = #HDN_GETDISPINFOW
  
  #LVM_EDITLABEL =4214
  #LVM_FINDITEM = 4179
  #LVM_GETISEARCHSTRING = 4213
  #LVM_GETITEM =4171
  #LVM_GETITEMTEXT =4211
  #LVM_GETSTRINGWIDTH = 4183
  #LVM_INSERTCOLUMN = 4193
  #LVM_INSERTITEM = 4173
  #LVM_GETCOLUMN =4191
  #LVM_SETCOLUMN =4192
  #LVM_SETITEM =4172
  #LVM_SETITEMTEXT =4212
  #LVM_GETCOLUMNWIDTH = 4125
  #LVM_SETCOLUMNWIDTH = 4126
  #LVM_SETBKIMAGE = (#LVM_FIRST+138)
  #LVM_GETBKIMAGE = (#LVM_FIRST+139)

  #LVN_BEGINLABELEDIT = (-175)
  #LVN_ENDLABELEDIT = (-176)
  #LVN_GETDISPINFO =(-177)
  #LVN_SETDISPINFO =(-178)
  #LVN_ODFINDITEM = (#LVN_FIRST-79)
  #LVN_GETINFOTIP = #LVN_FIRST - 58
  #LVN_INCREMENTALSEARCH = #LVN_FIRST - 63
  
  #SB_GETTEXT = 1037
  #SB_GETTEXTLENGTH = 1036
  #SB_SETTEXT = 1035
  #SB_SETTIPTEXT = (#WM_USER+17)
  #SB_GETTIPTEXT = (#WM_USER+19)
  
  #TB_ADDSTRING = 1101
  #TB_GETBUTTONTEXT = 1099
  #TB_SAVERESTORE = 1100
  #TB_INSERTBUTTON =(#WM_USER+67)
  #TB_ADDBUTTONS =(#WM_USER+68)
  #TB_GETBUTTONINFO = #WM_USER+63
  #TB_SETBUTTONINFO = #WM_USER+64
  #TB_GETSTRING = #WM_USER+91
  #TB_MAPACCELERATOR = #TB_MAPACCELERATORW

  #TBN_GETBUTTONINFO = (-720)
  #TBN_GETINFOTIP    = (#TBN_FIRST-19)
  #TBN_GETDISPINFO   = (#TBN_FIRST-17)
 
  #TCM_GETITEM =4924
  #TCM_INSERTITEM = 4926
  #TCM_SETITEM =4925
  
  #TTM_ADDTOOL =1074
  #TTM_DELTOOL =1075
  #TTM_ENUMTOOLS =1082
  #TTM_GETCURRENTTOOL = 1083
  #TTM_GETTEXT =1080
  #TTM_GETTOOLINFO =1077
  #TTM_HITTEST =1079
  #TTM_NEWTOOLRECT =1076
  #TTM_SETTOOLINFO =1078
  #TTM_UPDATETIPTEXT =1081
  #TTM_SETTITLE = 1057
  
  #TTN_GETDISPINFO =(#TTN_FIRST - 10)
  #TTN_NEEDTEXT = (-530)
  
  #TVM_EDITLABEL =4417
  #TVM_GETISEARCHSTRING = 4416
  #TVM_GETITEM =4414
  #TVM_INSERTITEM = 4402
  #TVM_SETITEM =4415
  
  #TVN_BEGINDRAG =(-456)
  #TVN_BEGINLABELEDIT = (-459)
  #TVN_BEGINRDRAG = (-457)
  #TVN_DELETEITEM = (-458)
  #TVN_ENDLABELEDIT = (-460)
  #TVN_ITEMEXPANDED = (-455)
  #TVN_ITEMEXPANDING =(-454)
  #TVN_SELCHANGING = #TVN_FIRST-50
  #TVN_SELCHANGED = #TVN_FIRST-51
  #TVN_GETDISPINFO = #TVN_FIRST-52
  #TVN_SETDISPINFO = #TVN_FIRST-53
  #TVN_GETINFOTIP  = (#TVN_FIRST-14)
  #TVN_ITEMCHANGED = #TVN_FIRST - 19
  
  #RB_INSERTBAND =(#WM_USER+10)
  #RB_SETBANDINFO = (#WM_USER+11)
  #RB_GETBANDINFO =(#WM_USER+28)
  
  #EM_FINDTEXT = (#WM_USER+123)
  #EM_FINDTEXTEX = (#WM_USER+124)
  
  #EMR_EXTTEXTOUT = 84
  #EMR_POLYTEXTOUT = 97
  
  #CBEM_INSERTITEM = (#WM_USER+11)
  #CBEM_GETITEM    = (#WM_USER+13)
  #CBEM_SETITEM    = (#WM_USER+12)
  
  #CBEN_GETDISPINFO = (#CBEN_FIRST - 7)
  #CBEN_DRAGBEGIN   = (#CBEN_FIRST - 9)
  #CBEN_ENDEDIT     = (#CBEN_FIRST - 6)
  
  #DTM_SETFORMAT = $1050

  #DTN_USERSTRING  = -745
  #DTN_WMKEYDOWN   = -744
  #DTN_FORMAT      = -743
  #DTN_FORMATQUERY = -742
  
  #JOY_CONFIGCHANGED_MSGSTRINGW = "MSJSTICK_VJOYD_MSGSTR"
  #JOY_CONFIGCHANGED_MSGSTRING = #JOY_CONFIGCHANGED_MSGSTRINGW

  #WM_CAP_DRIVER_GET_NAME = #WM_CAP_DRIVER_GET_NAMEW
  #WM_CAP_DRIVER_GET_VERSION = #WM_CAP_DRIVER_GET_VERSIONW
  #WM_CAP_FILE_GET_CAPTURE_FILE = #WM_CAP_FILE_GET_CAPTURE_FILEW
  #WM_CAP_FILE_SAVEAS = #WM_CAP_FILE_SAVEASW
  #WM_CAP_FILE_SAVEDIB = #WM_CAP_FILE_SAVEDIBW
  #WM_CAP_FILE_SET_CAPTURE_FILE = #WM_CAP_FILE_SET_CAPTURE_FILEW
  #WM_CAP_GET_MCI_DEVICE = #WM_CAP_GET_MCI_DEVICEW
  #WM_CAP_PAL_OPEN = #WM_CAP_PAL_OPENW
  #WM_CAP_PAL_SAVE = #WM_CAP_PAL_SAVEW
  #WM_CAP_SET_CALLBACK_ERROR = #WM_CAP_SET_CALLBACK_ERRORW
  #WM_CAP_SET_CALLBACK_STATUS = #WM_CAP_SET_CALLBACK_STATUSW
  #WM_CAP_SET_MCI_DEVICE = #WM_CAP_SET_MCI_DEVICEW

CompilerElse

  ; ANSI Constants ----------------------------------------------
  ;
  ;

  #ACM_OPEN = #WM_USER+100

  #HDM_INSERTITEM = #HDM_FIRST+1
  #HDM_GETITEM = #HDM_FIRST+3
  #HDM_SETITEM = #HDM_FIRST+4
  #HDN_ITEMCHANGING = #HDN_FIRST-0
  #HDN_ITEMCHANGED = #HDN_FIRST-1
  #HDN_ITEMCLICK = #HDN_FIRST-2
  #HDN_ITEMDBLCLICK = #HDN_FIRST-3
  #HDN_DIVIDERDBLCLICK = #HDN_FIRST-5
  #HDN_BEGINTRACK = #HDN_FIRST-6
  #HDN_ENDTRACK = #HDN_FIRST-7
  #HDN_TRACK = #HDN_FIRST-8
  #HDN_GETDISPINFO = #HDN_GETDISPINFOA

  #LVM_GETCOLUMN = #LVM_FIRST+25
  #LVM_SETCOLUMN = #LVM_FIRST+26
  #LVM_GETCOLUMNWIDTH = #LVM_FIRST+29
  #LVM_SETCOLUMNWIDTH = #LVM_FIRST+30
  #LVM_INSERTCOLUMN = #LVM_FIRST+27
  #LVM_EDITLABEL = #LVM_FIRST+23
  #LVM_FINDITEM = #LVM_FIRST+13
  #LVM_GETITEMTEXT = #LVM_FIRST+45
  #LVM_SETITEMTEXT = #LVM_FIRST+46
  #LVM_GETISEARCHSTRING = #LVM_FIRST+52
  #LVM_GETITEM = #LVM_FIRST+5
  #LVM_SETITEM = #LVM_FIRST+6
  #LVM_INSERTITEM = #LVM_FIRST+7
  #LVM_GETSTRINGWIDTH = #LVM_FIRST+17
  #LVM_SETBKIMAGE = (#LVM_FIRST+68)
  #LVM_GETBKIMAGE = (#LVM_FIRST+69)
  #LVN_ODFINDITEM = (#LVN_FIRST-52)

  #LVN_GETDISPINFO = #LVN_FIRST-50
  #LVN_SETDISPINFO = #LVN_FIRST-51
  #LVN_BEGINLABELEDIT = #LVN_FIRST-5
  #LVN_ENDLABELEDIT = #LVN_FIRST-6
  #LVN_GETINFOTIP = #LVN_FIRST - 57
  #LVN_INCREMENTALSEARCH = #LVN_FIRST - 62


  #SB_SETTEXT = #WM_USER+1
  #SB_GETTEXT = #WM_USER+2
  #SB_GETTEXTLENGTH = #WM_USER+3
  #SB_SETTIPTEXT = (#WM_USER+16)
  #SB_GETTIPTEXT = (#WM_USER+18)

  #TB_ADDSTRING = #WM_USER+28
  #TB_GETBUTTONTEXT = #WM_USER+45
  #TB_SAVERESTORE = #WM_USER+26
  #TB_ADDBUTTONS = #WM_USER+20
  #TB_INSERTBUTTON = #WM_USER+21
  #TB_GETBUTTONINFO = #WM_USER+65
  #TB_SETBUTTONINFO = #WM_USER+66
  #TB_GETSTRING = #WM_USER+92
  #TB_MAPACCELERATOR = #TB_MAPACCELERATORA

  #TBN_GETBUTTONINFO = #TBN_FIRST-0
  #TBN_GETINFOTIP    = (#TBN_FIRST-18)
  #TBN_GETDISPINFO   = (#TBN_FIRST-16)
 
  #TCM_GETITEM = #TCM_FIRST+5
  #TCM_SETITEM = #TCM_FIRST+6
  #TCM_INSERTITEM = #TCM_FIRST+7

  #TTM_ADDTOOL =1028
  #TTM_DELTOOL =1029
  #TTM_ENUMTOOLS =1038
  #TTM_GETTEXT =1035
  #TTM_GETCURRENTTOOL =1039
  #TTM_GETTOOLINFO =1032
  #TTM_SETTOOLINFO =1033
  #TTM_HITTEST =1034
  #TTM_NEWTOOLRECT= 1030
  #TTM_UPDATETIPTEXT= 1036
  #TTM_SETTITLE = #WM_USER + 32

  #TTN_GETDISPINFO =(#TTN_FIRST - 0)
  #TTN_NEEDTEXT =(-520)

  #TVM_GETITEM = #TV_FIRST+12
  #TVM_SETITEM = #TV_FIRST+13
  #TVM_EDITLABEL = #TV_FIRST+14
  #TVM_INSERTITEM = #TV_FIRST+0
  #TVM_GETISEARCHSTRING = #TV_FIRST+23

  #TVN_ITEMEXPANDING = #TVN_FIRST-5
  #TVN_ITEMEXPANDED = #TVN_FIRST-6
  #TVN_BEGINDRAG = #TVN_FIRST-7
  #TVN_BEGINRDRAG = #TVN_FIRST-8
  #TVN_DELETEITEM = #TVN_FIRST-9
  #TVN_BEGINLABELEDIT = #TVN_FIRST-10
  #TVN_ENDLABELEDIT = #TVN_FIRST-11
  #TVN_SELCHANGING = #TVN_FIRST-1
  #TVN_SELCHANGED = #TVN_FIRST-2
  #TVN_GETDISPINFO = #TVN_FIRST-3
  #TVN_SETDISPINFO = #TVN_FIRST-4
  #TVN_GETINFOTIP = (#TVN_FIRST-13)
  #TVN_ITEMCHANGED = #TVN_FIRST - 18
  
  #RB_INSERTBAND = #WM_USER+1
  #RB_GETBANDINFO = #WM_USER+5
  #RB_SETBANDINFO = #WM_USER+6
  
  #EM_FINDTEXT = #WM_USER+56
  #EM_FINDTEXTEX = #WM_USER+79
  
  #EMR_EXTTEXTOUT = 83
  #EMR_POLYTEXTOUT = 96
  
  #CBEM_INSERTITEM = (#WM_USER+1)
  #CBEM_GETITEM    = (#WM_USER+4)
  #CBEM_SETITEM    = (#WM_USER+5)

  #CBEN_GETDISPINFO = (#CBEN_FIRST - 0)
  #CBEN_DRAGBEGIN   = (#CBEN_FIRST - 8)
  #CBEN_ENDEDIT     = (#CBEN_FIRST - 5)
  
  #DTM_SETFORMAT    = $1005
  
  #DTN_USERSTRING  = -758
  #DTN_WMKEYDOWN   = -757
  #DTN_FORMAT      = -756
  #DTN_FORMATQUERY = -755
  
  #JOY_CONFIGCHANGED_MSGSTRINGA = "MSJSTICK_VJOYD_MSGSTR"
  #JOY_CONFIGCHANGED_MSGSTRING = #JOY_CONFIGCHANGED_MSGSTRINGA
  
  #WM_CAP_DRIVER_GET_NAME = #WM_CAP_DRIVER_GET_NAMEA
  #WM_CAP_DRIVER_GET_VERSION = #WM_CAP_DRIVER_GET_VERSIONA
  #WM_CAP_FILE_GET_CAPTURE_FILE = #WM_CAP_FILE_GET_CAPTURE_FILEA
  #WM_CAP_FILE_SAVEAS = #WM_CAP_FILE_SAVEASA
  #WM_CAP_FILE_SAVEDIB = #WM_CAP_FILE_SAVEDIBA
  #WM_CAP_FILE_SET_CAPTURE_FILE = #WM_CAP_FILE_SET_CAPTURE_FILEA
  #WM_CAP_GET_MCI_DEVICE = #WM_CAP_GET_MCI_DEVICEA
  #WM_CAP_PAL_OPEN = #WM_CAP_PAL_OPENA
  #WM_CAP_PAL_SAVE = #WM_CAP_PAL_SAVEA
  #WM_CAP_SET_CALLBACK_ERROR = #WM_CAP_SET_CALLBACK_ERRORA
  #WM_CAP_SET_CALLBACK_STATUS = #WM_CAP_SET_CALLBACK_STATUSA
  #WM_CAP_SET_MCI_DEVICE = #WM_CAP_SET_MCI_DEVICEA
 
CompilerEndIf


#CFSTR_SHELLIDLIST                   = "Shell IDList Array"
#CFSTR_SHELLIDLISTOFFSET             = "Shell Object Offsets"
#CFSTR_NETRESOURCES                  = "Net Resource"
#CFSTR_FILEDESCRIPTORA               = "FileGroupDescriptor"
#CFSTR_FILEDESCRIPTORW               = "FileGroupDescriptorW"
#CFSTR_FILECONTENTS                  = "FileContents"
#CFSTR_FILENAMEA                     = "FileName"
#CFSTR_FILENAMEW                     = "FileNameW"
#CFSTR_PRINTERGROUP                  = "PrinterFriendlyName"
#CFSTR_FILENAMEMAPA                  = "FileNameMap"
#CFSTR_FILENAMEMAPW                  = "FileNameMapW"
#CFSTR_SHELLURL                      = "UniformResourceLocator"
#CFSTR_INETURLA                      = #CFSTR_SHELLURL
#CFSTR_INETURLW                      = "UniformResourceLocatorW"
#CFSTR_PREFERREDDROPEFFECT           = "Preferred DropEffect"
#CFSTR_PERFORMEDDROPEFFECT           = "Performed DropEffect"
#CFSTR_PASTESUCCEEDED                = "Paste Succeeded"
#CFSTR_INDRAGLOOP                    = "InShellDragLoop"
#CFSTR_DRAGCONTEXT                   = "DragContext"
#CFSTR_MOUNTEDVOLUME                 = "MountedVolume"
#CFSTR_PERSISTEDDATAOBJECT           = "PersistedDataObject"
#CFSTR_TARGETCLSID                   = "TargetCLSID"
#CFSTR_LOGICALPERFORMEDDROPEFFECT    = "Logical Performed DropEffect"
#CFSTR_AUTOPLAY_SHELLIDLISTS         = "Autoplay Enumerated IDList Array"
#CFSTR_UNTRUSTEDDRAGDROP             = "UntrustedDragDrop"


#HOTKEY_CLASS  = "msctls_hotkey32"
#PROGRESS_CLASS  = "msctls_progress32"
#STATUSCLASSNAME  = "msctls_statusbar32"
#TOOLBARCLASSNAME  = "ToolbarWindow32"
#TOOLTIPS_CLASS  = "tooltips_class32"
#TRACKBAR_CLASS  = "msctls_trackbar32"
#UPDOWN_CLASS  = "msctls_updown32"
#ANIMATE_CLASS  = "SysAnimate32"
#DATETIMEPICK_CLASS = "SysDateTimePick32"
#MONTHCAL_CLASS = "SysMonthCal32"
#REBARCLASSNAME = "ReBarWindow32"
#WC_COMBOBOXEX = "ComboBoxEx32"
#WC_IPADDRESS = "SysIPAddress32"
#WC_LISTVIEW = "SysListView32"
#WC_TABCONTROL = "SysTabControl32"
#WC_TREEVIEW = "SysTreeView32"
#WC_HEADER = "SysHeader32"
#WC_PAGESCROLLER = "SysPager"
#WC_NATIVEFONTCTL = "NativeFontCtl"
#WC_BUTTON = "Button"
#WC_STATIC = "Static"
#WC_EDIT = "Edit"
#WC_LISTBOX = "ListBox"
#WC_COMBOBOX = "ComboBox"
#WC_SCROLLBAR = "ScrollBar"


CompilerIf #PB_Compiler_Unicode
  #CFSTR_FILEDESCRIPTOR    = #CFSTR_FILEDESCRIPTORW
  #CFSTR_FILENAME          = #CFSTR_FILENAMEW
  #CFSTR_FILENAMEMAP       = #CFSTR_FILENAMEMAPW
  #CFSTR_INETURL           = #CFSTR_INETURLW
CompilerElse
  #CFSTR_FILEDESCRIPTOR    = #CFSTR_FILEDESCRIPTORA
  #CFSTR_FILENAME          = #CFSTR_FILENAMEA
  #CFSTR_FILENAMEMAP       = #CFSTR_FILENAMEMAPA
  #CFSTR_INETURL           = #CFSTR_INETURLA
CompilerEndIf

#CF_RTF = "Rich Text Format"
#CF_RTFNOOBJS = "Rich Text Format Without Objects"
#CF_RETEXTOBJ = "RichEdit Text and Objects"

#SE_DEBUG_NAME = "SeDebugPrivilege"

Structure MONITORINFOEX
 cbSize.l
 rcMonitor.RECT
 rcWork.RECT
 dwFlags.l
 szDevice.c[#CCHDEVICENAME]
EndStructure
