; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


XIncludeFile "Object_BoxBase.pb" ; DlgPanel is a Box
XIncludeFile "Object_BinBase.pb" ; DlgTab is a Bin
XIncludeFile "GetRequiredSize.pb"

;
; panel - panel gadget
;
; The direct children of a Panel must be "Tab" items, which are containers for the real gadgets
;
; Accepted keys in the XML:
;
;
;

; tab - PanelGadget children
;
; Accepted keys in the XML:
;
;   All accepted by DlgBinBase
;

; We need to keep track of the current PanelGadget, so the DlgTab knows where
; to add the new GadgetItem
;
Structure PanelGadgetStack
  Gadget.i
  Item.i
EndStructure

Global NewList DlgPanel_Stack.PanelGadgetStack()


Structure DlgPanel Extends DlgBoxBase
  ;   CompilerIf #CompileWindows
  ;     Multiline.l ; windows only
  ;   CompilerEndIf
  
EndStructure


Procedure DlgPanel_New(*StaticData.DialogObjectData)
  *THIS.DlgPanel = AllocateMemory(SizeOf(DlgPanel))
  
  If *THIS
    *THIS\VTable     = ?DlgPanel_VTable
    *THIS\StaticData = *StaticData
    
    *THIS\Gadget = PanelGadget(*StaticData\Gadget, 0, 0, 0, 0)
    
    If *StaticData\Gadget <> -1
      *THIS\Gadget = *StaticData\Gadget
    EndIf
    
    ; Multiline flag (windows)
    ;
    ; NOTE: The multiline flag cannot be supported, as it messes up the size calculation
    ;       as the PanelTabHeight is not constant anymore
    ;
    ;     CompilerIf #CompileWindows
    ;       If UCase(DialogObjectKey(*StaticData, "MULTILINE")) = "YES"
    ;         *THIS\Multiline = 1 ; is applied when all children are added.
    ;       EndIf
    ;     CompilerEndIf
    
    ; Push the Gadget info on our stack
    ;
    LastElement(DlgPanel_Stack())
    AddElement(DlgPanel_Stack())
    DlgPanel_Stack()\Gadget = *THIS\Gadget
    DlgPanel_Stack()\Item   = 0
  EndIf
  
  ProcedureReturn *THIS
EndProcedure



Procedure DlgPanel_SizeRequest(*THIS.DlgPanel, *Width.LONG, *Height.LONG)
  *Width\l  = 0
  *Height\l = 0
  
  For i = 0 To *THIS\NbChildren-1
    Height = 0
    Width  = 0
    
    *THIS\Children[i]\SizeRequest(@Width, @Height)
    
    *Width\l  = Max(*Width\l,  Width)
    *Height\l = Max(*Height\l, Height)
  Next i
  
  CompilerIf #CompileWindows
    *Width\l  + 4
    *Height\l + GetGadgetAttribute(*THIS\Gadget, #PB_Panel_TabHeight) + 2
  CompilerEndIf
  
  CompilerIf #CompileMac
    *Width\l  + 8
    *Height\l + GetGadgetAttribute(*THIS\Gadget, #PB_Panel_TabHeight) + 40
  CompilerEndIf
  
  CompilerIf #CompileLinuxGtk
    If *THIS\NbChildren > 0
      ; works in most places.. still a bit a hack though
      *Label.GtkWidget = gtk_notebook_get_tab_label_(GadgetID(*THIS\Gadget), gtk_notebook_get_nth_page_(GadgetID(*THIS\Gadget), 0))
      gtk_widget_size_request_(*Label, @Size.GtkRequisition)     ; get the min required size
      
      *Height\l + Size\height + 14
      *Width\l  + 4
    EndIf
  CompilerEndIf
  
  CompilerIf #CompileLinuxQt
    *Width\l  + 4
    *Height\l + GetGadgetAttribute(*THIS\Gadget, #PB_Panel_TabHeight) + 2
  CompilerEndIf
  
  *Width\l  = Max(*Width\l,  *THIS\StaticData\MinWidth)
  *Height\l = Max(*Height\l, *THIS\StaticData\MinHeight)
EndProcedure



Procedure DlgPanel_SizeApply(*THIS.DlgPanel, x, y, Width, Height)
  ResizeGadget(*THIS\Gadget, x, y, Width, Height)
  
  CompilerIf #CompileWindows | #CompileMac
    Width  = GetGadgetAttribute(*THIS\Gadget, #PB_Panel_ItemWidth)
    Height = GetGadgetAttribute(*THIS\Gadget, #PB_Panel_ItemHeight)
  CompilerEndIf
  
  Debug "" + Width + "  " + Height

  CompilerIf #CompileLinuxGtk
    If *THIS\NbChildren > 0
      ; works in most places.. still a bit a hack though
      *Label.GtkWidget = gtk_notebook_get_tab_label_(GadgetID(*THIS\Gadget), gtk_notebook_get_nth_page_(GadgetID(*THIS\Gadget), 0))
      gtk_widget_size_request_(*Label, @Size.GtkRequisition)     ; get the min required size
      
      Height - Size\height - 14
      Width  - 4
    EndIf
  CompilerEndIf
  
  CompilerIf #CompileLinuxQt
    ; We have to wait for the resize events to be fully processed after ResizeGadget() for #PB_Panel_ItemWidth etc to be correct
    ; So calculate some estimated values here instead to have them available immediately
    Height - GetGadgetAttribute(*THIS\Gadget, #PB_Panel_TabHeight) - 2
    Width - 4
  CompilerEndIf
  
  For i = 0 To *THIS\NbChildren-1
    *THIS\Children[i]\SizeApply(0, 0, Width, Height)
  Next i
EndProcedure


Procedure DlgPanel_Finish(*THIS.DlgPanel)
  CloseGadgetList()
  
  ; Multiline flag (windows, must be after CloseGadgetList())
  ;   CompilerIf #CompileWindows
  ;     If *THIS\Multiline
  ;       SetWindowLongPtr_(GadgetID(*THIS\Gadget), #GWL_STYLE, GetWindowLongPtr_(GadgetID(*THIS\Gadget), #GWL_STYLE) | #TCS_MULTILINE)
  ;     EndIf
  ;   CompilerEndIf
  ;
  ; Pop our Panel stack
  ;
  If LastElement(DlgPanel_Stack())
    DeleteElement(DlgPanel_Stack())
  EndIf
EndProcedure


DataSection
  
  DlgPanel_VTable:
  Data.i @DlgBase_SizeRequestWrapper()
  Data.i @DlgPanel_SizeRequest()
  Data.i @DlgPanel_SizeApply()
  Data.i @DlgBoxBase_AddChild()
  Data.i @DlgBoxBase_FoldApply()
  Data.i @DlgBase_Find()
  Data.i @DlgPanel_Finish()
  Data.i @DlgBoxBase_Update()
  Data.i @DlgBoxBase_Destroy()
  
EndDataSection


; ------------------------------------------------------------------------------------------



Structure DlgTab Extends DlgBinBase
  ParentGadget.i
  ItemIndex.i
EndStructure


Procedure DlgTab_New(*StaticData.DialogObjectData)
  *THIS.DlgTab = AllocateMemory(SizeOf(DlgTab))
  
  If *THIS And LastElement(DlgPanel_Stack()) ; access to our panel stack
    *THIS\VTable       = ?DlgTab_VTable
    *THIS\StaticData   = *StaticData
    *THIS\ParentGadget = DlgPanel_Stack()\Gadget
    *THIS\ItemIndex    = DlgPanel_Stack()\Item
    
    AddGadgetItem(*THIS\ParentGadget, *THIS\ItemIndex, DialogObjectText(*StaticData))
    
    DlgPanel_Stack()\Item + 1 ; increase item count for next tab
    
    DlgBinBase_GetOptions(*THIS) ; read all the margin etc options
  EndIf
  
  ProcedureReturn *THIS
EndProcedure



Procedure DlgTab_SizeRequest(*THIS.DlgTab, *Width.LONG, *Height.LONG)
  *THIS\RequestedWidth  = 0
  *THIS\RequestedHeight = 0
  
  If *THIS\Child
    *THIS\Child\SizeRequest(@*THIS\RequestedWidth, @*THIS\RequestedHeight)
  EndIf
  
  *Width\l  = Max(*THIS\RequestedWidth +*THIS\lMargin+*THIS\lMargin,  *THIS\StaticData\MinWidth)
  *Height\l = Max(*THIS\RequestedHeight+*THIS\tMargin+*THIS\bMargin, *THIS\StaticData\MinHeight)
EndProcedure



Procedure DlgTab_SizeApply(*THIS.DlgTab, x, y, Width, Height)
  
  If *THIS\Child
    x = 0
    y = 0
    DlgBinBase_CalculateChildSize(*THIS, @x, @y, @Width, @Height)
    *THIS\Child\SizeApply(x, y, Width, Height)
  EndIf
  
EndProcedure

Procedure DlgTab_Update(*THIS.DlgTab)
  If *THIS\StaticData\HasText
    SetGadgetItemText(*THIS\ParentGadget, *THIS\ItemIndex, DialogObjectText(*THIS\StaticData), 0)
  EndIf
  
  If *THIS\Child
    *THIS\Child\Update()
  EndIf
EndProcedure




DataSection
  
  DlgTab_VTable:
  Data.i @DlgBase_SizeRequestWrapper()
  Data.i @DlgTab_SizeRequest()
  Data.i @DlgTab_SizeApply()
  Data.i @DlgBinBase_AddChild()
  Data.i @DlgBinBase_FoldApply()
  Data.i @DlgBase_Find()
  Data.i @DlgBase_Finish()
  Data.i @DlgTab_Update()
  Data.i @DlgBinBase_Destroy()
  
EndDataSection
