; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

;
;
;  Get the minimum required size to properly display the gadget content.
;  This file is independent from the DialogManager so it can be used on gadgets
;  even when not a full dialog creation is done. The Flags value can be given to
;  include stuff like borders in the calculation
;
;  NOTE: This function should be used always for text gadgets like Button, Text, String etc
;        to ensure a fully scalable GUI.
;
; Supported Gadgets:
;   Button, Checkbox, Option, Text, String, ComboBox, Image, ButtonImage
;
; For those with variable content (ComboBox, String) only the Height value is useful (width is mostly reported as 0)
;

; Repeated here, so it works with and without the Dialog framework
CompilerIf Defined(Max, #PB_Procedure) = 0
  Procedure Max(a, b)
    If a > b
      ProcedureReturn a
    Else
      ProcedureReturn b
    EndIf
  EndProcedure
CompilerEndIf

CompilerIf #PB_Compiler_OS = #PB_OS_Linux
  CompilerIf Defined(PB_Gadget, #PB_Structure) = 0
    Structure PB_Gadget
      *Gadget.GtkWidget
      *Container.GtkWidget
      *VT
      UserData.i
      GadgetData.i[4]
    EndStructure
  CompilerEndIf
CompilerEndIf

CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
  Structure OSX_Rect
    top.w
    left.w
    bottom.w
    right.w
  EndStructure
  
  #noErr = 0
CompilerEndIf

CompilerIf #CompileMacCocoa
  ImportC ""
    PB_Gadget_GetBestSize(Gadget.i, *Width, *Height)
  EndImport
CompilerEndIf

Procedure GetRequiredSize(Gadget, *Width.LONG, *Height.LONG, Flags = 0)
  
  *Width\l  = GadgetWidth(Gadget, #PB_Gadget_RequiredSize)
  *Height\l = GadgetHeight(Gadget, #PB_Gadget_RequiredSize)
  
  CompilerIf #CompileMac
    Select GadgetType(Gadget)
      Case #PB_GadgetType_Button
        If *Height\l < 28
          *Height\l = 28
        EndIf
      Case #PB_GadgetType_String
        If *Height\l < 24
          *Height\l = 24
        EndIf
    EndSelect
  CompilerEndIf
  
EndProcedure

; convenience wrappers if only one size is needed
;
Procedure GetRequiredWidth(Gadget, Flags = 0)
  Protected Width.l, Height.l
  GetRequiredSize(Gadget, @Width, @Height, Flags)
  ProcedureReturn Width
EndProcedure

Procedure GetRequiredHeight(Gadget, Flags = 0)
  Protected Width.l, Height.l
  GetRequiredSize(Gadget, @Width, @Height, Flags)
  ProcedureReturn Height
EndProcedure

CompilerIf #CompileLinuxQt
  ImportC "../PureBasicIDE/Build/QtHelpers.a"
    QT_Frame3DTopOffset(*Widget)
  EndImport
CompilerEndIf

; Calculate the top offset for a Frame3DGadget
Procedure Frame3DTopOffset(Gadget)
  CompilerIf #CompileWindows
    Text$ = GetGadgetText(Gadget)
    DC = GetDC_(GadgetID(Gadget))
    oldFont = SelectObject_(DC, GetGadgetFont(Gadget)) ; important, as font size calculations are wrong else (especially for long strings)
    GetTextExtentPoint32_(DC, Text$, Len(Text$), @Size.SIZE)
    SelectObject_(DC, oldFont)
    ReleaseDC_(GadgetID(Gadget), DC)
    ProcedureReturn Max(Size\cy, 10)
  CompilerEndIf
  
  CompilerIf #CompileLinuxGtk
    gtk_widget_size_request_(gtk_frame_get_label_widget_(GadgetID(Gadget)), @Size.GtkRequisition)
    ProcedureReturn Size\Height
  CompilerEndIf
  
  CompilerIf #CompileLinuxQt
    ; Imported via PureBasicIDE/LinuxExtensions.pb
    ProcedureReturn QT_Frame3DTopOffset(GadgetID(Gadget))
  CompilerEndIf
  
  CompilerIf #CompileMac
    ; TODO: a way to at least calculate the top border correctly would be good
    ProcedureReturn 16
  CompilerEndIf
EndProcedure

