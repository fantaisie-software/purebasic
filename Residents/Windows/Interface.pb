; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

IncludePath "Interface\"

IncludeFile "Oaidl.pb"
IncludeFile "tnef.pb"
IncludeFile "tom.pb"
IncludeFile "unknwn.pb"
IncludeFile "urlmon.pb"
IncludeFile "vfw.pb"
IncludeFile "wbemads.pb"
IncludeFile "wbemcli.pb"
IncludeFile "wbemdisp.pb"
IncludeFile "wbemprov.pb"
IncludeFile "wbemtran.pb"
IncludeFile "aclui.pb"
IncludeFile "bits.pb"
IncludeFile "comcat.pb"
IncludeFile "confpriv.pb"
IncludeFile "dimm.pb"
IncludeFile "dispex.pb"
IncludeFile "docobj.pb"
IncludeFile "dsadmin.pb"
IncludeFile "exdisp.pb"
IncludeFile "faxcom.pb"
IncludeFile "gpedit.pb"
IncludeFile "hlink.pb"
IncludeFile "iads.pb"
IncludeFile "ils.pb"
IncludeFile "intshcut.pb"
IncludeFile "MAPIdefs.pb"
IncludeFile "mapiform.pb"
IncludeFile "mapix.pb"
IncludeFile "mmc.pb"
IncludeFile "mqoai.pb"
IncludeFile "mshtmhst.pb"
IncludeFile "mshtmlc.pb"
IncludeFile "msxml.pb"
IncludeFile "netmon.pb"
IncludeFile "Objidl.pb"
IncludeFile "ocidl.pb"
IncludeFile "oleacc.pb"
IncludeFile "oledlg.pb"
IncludeFile "propidl.pb"
IncludeFile "reconcil.pb"
IncludeFile "richole.pb"
IncludeFile "servprov.pb"
IncludeFile "shldisp.pb"
IncludeFile "shlobj.pb"
IncludeFile "shlwapi.pb"
IncludeFile "shobjidl.pb"
IncludeFile "tapi3if.pb"
IncludeFile "Bdatif.pb"
IncludeFile "danim.pb"
IncludeFile "oleidl.pb"

; Manually added interfaces should be here, or the script will kill them
;

; ICDBurn interface definition
; usually in shlobjidl.pb, but needs manual editing because of a wrong p-unicode
;
Interface ICDBurn Extends IUnknown
  GetRecorderDriveLetter(a.l, b.l)
  Burn(a.l)
  HasRecordableDrive(a.l)
EndInterface


Interface IImageList Extends IUnknown
  Add(a, b, c)
  ReplaceIcon(a, b, c)
  SetOverlayImage(a, b)
  Replace(a, b, c)
  AddMasked(a, b, c)
  Draw(a)
  Remove(a)
  GetIcon(a, b, c)
  GetImageInfo(a, b)
  Copy(a, b, c, c)
  Merge(a, b, c, d, e, f, g)
  Clone(a, b)
  GetImageRect(a, b)
  GetIconSize(a, b)
  SetIconSize(a, b)
  GetImageCount(a)
  SetImageCount(a)
  SetBkColor(a, b)
  GetBkColor(a)
  BeginDrag(a, b, c)
  EndDrag()
  DragEnter(a, b, c)
  DragLeave(a)
  DragMove(a, b)
  SetDragCursorImage(a, b, c, d)
  DragShowNolock(a)
  GetDragImage(a, b, c, d)
  GetItemFlags(a, b)
  GetOverlayImage(a, b)
EndInterface
