; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

;
;  Gadget size helpers, shared by the IDE and the debugger:
;
;  GetRequiredSize(), GetRequiredWidth(), GetRequiredHeight():
;    Minimum required size to properly display the gadget content (GadgetWidth/Height() with
;    #PB_Gadget_RequiredSize, with some minimum heights on OSX).
;    Should be used for text gadgets like Button, Text, String etc to ensure a fully scalable GUI.
;    For those with variable content (ComboBox, String) only the height is useful.
;
;  Frame3DTopOffset(): height of the label at the top of a FrameGadget
;

; Also in Common.pb, repeated here for the standalone debugger
CompilerIf Defined(Max, #PB_Procedure) = 0
  Procedure Max(a, b)
    If a > b
      ProcedureReturn a
    Else
      ProcedureReturn b
    EndIf
  EndProcedure
CompilerEndIf

Procedure GetRequiredSize(Gadget, *Width.LONG, *Height.LONG)
  
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
Procedure GetRequiredWidth(Gadget)
  Protected Width.l, Height.l
  GetRequiredSize(Gadget, @Width, @Height)
  ProcedureReturn Width
EndProcedure

Procedure GetRequiredHeight(Gadget)
  Protected Width.l, Height.l
  GetRequiredSize(Gadget, @Width, @Height)
  ProcedureReturn Height
EndProcedure

CompilerIf #CompileLinuxQt
  ImportC "PureBasicIDE/Build/QtHelpers.a" ; relative to this file (repository root)
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

