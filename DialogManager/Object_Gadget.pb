; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


XIncludeFile "Object_Base.pb"
XIncludeFile "GetRequiredSize.pb"

;
; button, checkbox, option, listview, combobox, text, string
;
; Accepted keys in the XML:
;
;  only the default options (see Object_Base.pb)
;
;
; for ComboBox:
;   boxheight = size of the dropdown Box (Default=200)
;
; for scrollbar:
;   min, max, page
;
;
; Note: A ListIcon is created with 1 column, but if <column> is used, the default column is removed
;

Structure DlgGadget Extends DlgBase
  HasTitle.l
  StringAlign.l ; for TextGadget, Checkbox, Option. extra vertical offset
  ColumnAdded.l ; to know which is the first <column> element (to remove the default columns)
EndStructure

; Special structure to easily assign a fixed list of items to a gadget (and manage its language)
; For example for Combobox with fixed choices
;
; supported by: combobox, tree, listicon (for the columns)
;
; xml commands:
;
;  item   (supports only lang and text fields) for tree: "sublevel" field
;  column (supports lang, text and width fields)
;
Structure DlgItemGadget Extends DlgGadget
  NbItems.l
  *Items.DialogObjectData[#MAX_CHILDLIST]  ; we only save the static data, no extra object
EndStructure

; on windows, the callback is required
; Note: so this works also without the Scintilla lib, we use a constant
;       to indicate whether or not it should be used.
;
CompilerIf Defined(DIALOG_USE_SCINTILLA, #PB_Constant)
  
  ProcedureDLL Dialog_ScintillaCallback(EditorGadget.l, *scinotify.SCNotification)
  EndProcedure
  
CompilerEndIf


Procedure DlgGadget_New(*StaticData.DialogObjectData)
  If *StaticData\Type = #DIALOG_ComboBox Or *StaticData\Type = #DIALOG_Tree Or *StaticData\Type = #DIALOG_ListIcon
    *THIS.DlgGadget = AllocateMemory(SizeOf(DlgItemGadget))
  Else
    *THIS.DlgGadget = AllocateMemory(SizeOf(DlgGadget))
  EndIf
  
  If *THIS
    ;
    ; Note: Most Gadgets have the same stuff to do. (gtk_size_request simply), so this object
    ;  represents most gadgets. Some (like list, tree etc) do not do a size_request, but simply
    ;  return the minimal value. these use a separate vtable. finally, combobox is a bit special,
    ;  because of the meaning of its height parameter.
    ;
    *THIS\VTable     = ?DlgGadget_VTable
    *THIS\StaticData = *StaticData
    *THIS\HasTitle   = #True
    
    
    Select *StaticData\Type
        
      Case #DIALOG_Text
        *THIS\Gadget = TextGadget(*StaticData\Gadget, 0, 0, 0, 0, DialogObjectText(*StaticData), *StaticData\Flags)
        
      Case #DIALOG_String
        *THIS\Gadget = StringGadget(*StaticData\Gadget, 0, 0, 0, 0, DialogObjectText(*StaticData), *StaticData\Flags)
        
      Case #DIALOG_ShortcutGadget
        *THIS\Gadget = ShortcutGadget(*StaticData\Gadget, 0, 0, 0, 0, 0)
        
      Case #DIALOG_Button
        *THIS\Gadget = ButtonGadget(*StaticData\Gadget, 0, 0, 0, 0, DialogObjectText(*StaticData), *StaticData\Flags)
        
      Case #DIALOG_Image
        *THIS\Gadget   = ImageGadget(*StaticData\Gadget, 0, 0, 0, 0, 0, *StaticData\Flags)
        *THIS\HasTitle = #False
        
      Case #DIALOG_ButtonImage
        *THIS\Gadget   = ButtonImageGadget(*StaticData\Gadget, 0, 0, 0, 0, 0, *StaticData\Flags)
        *THIS\HasTitle = #False
        
      Case #DIALOG_Checkbox
        *THIS\Gadget = CheckBoxGadget(*StaticData\Gadget, 0, 0, 0, 0, DialogObjectText(*StaticData), *StaticData\Flags)
        
      Case #DIALOG_Option
        *THIS\Gadget = OptionGadget(*StaticData\Gadget, 0, 0, 0, 0, DialogObjectText(*StaticData))
        
      Case #DIALOG_ListView
        *THIS\VTable   = ?DlgListView_VTable ; special vtable for windows (see below)
        *THIS\Gadget   = ListViewGadget(*StaticData\Gadget, 0, 0, 0, 0, *StaticData\Flags)
        *THIS\HasTitle = #False
        
      Case #DIALOG_ListIcon
        *THIS\VTable   = ?DlgFixedGadget_VTable
        *THIS\Gadget   = ListIconGadget(*StaticData\Gadget, 0, 0, 0, 0, DialogObjectText(*StaticData), 300, *StaticData\Flags)
        *THIS\HasTitle = #False
        
      Case #DIALOG_Tree
        *THIS\VTable   = ?DlgFixedGadget_VTable
        *THIS\Gadget   = TreeGadget(*StaticData\Gadget, 0, 0, 0, 0, *StaticData\Flags)
        *THIS\HasTitle = #False
        
      Case #DIALOG_ComboBox
        CompilerIf #CompileMac
          ; Fixed macOS background drawing issue from the ComboBox, needs minimum size
          *THIS\Gadget = ComboBoxGadget(*StaticData\Gadget, 0, 0, 100, 25, *StaticData\Flags)
        CompilerElse
          *THIS\Gadget = ComboBoxGadget(*StaticData\Gadget, 0, 0, 0, 0, *StaticData\Flags)
        CompilerEndIf
        *THIS\HasTitle = #False
        
        CompilerIf Defined(DIALOG_USE_EXPLORER, #PB_Constant)
          
        Case #DIALOG_ExplorerList
          *THIS\VTable   = ?DlgFixedGadget_VTable
          *THIS\Gadget   = ExplorerListGadget(*StaticData\Gadget, 0, 0, 0, 0, DialogObjectText(*StaticData), *StaticData\Flags)
          *THIS\HasTitle = #True
          
        Case #DIALOG_ExplorerTree
          *THIS\VTable   = ?DlgFixedGadget_VTable
          *THIS\Gadget   = ExplorerTreeGadget(*StaticData\Gadget, 0, 0, 0, 0, DialogObjectText(*StaticData), *StaticData\Flags)
          *THIS\HasTitle = #True
          
        Case #DIALOG_ExplorerCombo
          *THIS\Gadget   = ExplorerComboGadget(*StaticData\Gadget, 0, 0, 0, 0, DialogObjectText(*StaticData), *StaticData\Flags)
          *THIS\HasTitle = #True
          
        CompilerEndIf
        
      Case #DIALOG_Editor
        *THIS\VTable   = ?DlgFixedGadget_VTable
        *THIS\Gadget   = EditorGadget(*StaticData\Gadget, 0, 0, 0, 0, *StaticData\Flags)
        If *StaticData\HasText
          If *StaticData\Gadget = #PB_Any
            SetGadgetText(*THIS\Gadget, DialogObjectText(*StaticData))
          Else
            SetGadgetText(*StaticData\Gadget, DialogObjectText(*StaticData))
          EndIf
        EndIf
        
        CompilerIf Defined(DIALOG_USE_SCINTILLA, #PB_Constant)
          
        Case #DIALOG_Scintilla
          *THIS\VTable   = ?DlgFixedGadget_VTable
          *THIS\Gadget   = ScintillaGadget(*StaticData\Gadget, 0, 0, 0, 0, @Dialog_ScintillaCallback())
          
        CompilerEndIf
        
      Case #DIALOG_ScrollBar
        Value$ = DialogObjectKey(*StaticData, "MIN")
        If Value$
          Min = Val(Value$)
        Else
          Min = 0
        EndIf
        
        Value$ = DialogObjectKey(*StaticData, "MAX")
        If Value$
          Max = Val(Value$)
        Else
          Max = 100
        EndIf
        
        Value$ = DialogObjectKey(*StaticData, "PAGE")
        If Value$
          Page = Val(Value$)
        Else
          Page = 10
        EndIf
        
        *THIS\VTable   = ?DlgFixedGadget_VTable
        *THIS\Gadget   = ScrollBarGadget(*StaticData\Gadget, 0, 0, 0, 0, Min, Max, Page, *StaticData\Flags)
        
      Case #DIALOG_ProgressBar
        Value$ = DialogObjectKey(*StaticData, "MIN")
        If Value$
          Min = Val(Value$)
        Else
          Min = 0
        EndIf
        
        Value$ = DialogObjectKey(*StaticData, "MAX")
        If Value$
          Max = Val(Value$)
        Else
          Max = 100
        EndIf
        
        *THIS\VTable   = ?DlgFixedGadget_VTable
        *THIS\Gadget   = ProgressBarGadget(*StaticData\Gadget, 0, 0, 0, 0, Min, Max, *StaticData\Flags)
        
      Case #DIALOG_TrackBar
        Value$ = DialogObjectKey(*StaticData, "MIN")
        If Value$
          Min = Val(Value$)
        Else
          Min = 0
        EndIf
        
        Value$ = DialogObjectKey(*StaticData, "MAX")
        If Value$
          Max = Val(Value$)
        Else
          Max = 10
          Max = 10
        EndIf
        
        *THIS\VTable   = ?DlgFixedGadget_VTable
        *THIS\Gadget   = TrackBarGadget(*StaticData\Gadget, 0, 0, 0, 0, Min, Max, *StaticData\Flags)
        
      Case #DIALOG_HyperLink
        Value$ = DialogObjectKey(*StaticData, "COLOR")
        If Value$
          Color = Val(Value$)
        Else
          Color = 0
        EndIf
        *THIS\Gadget = HyperLinkGadget(*StaticData\Gadget, 0, 0, 0, 0, DialogObjectText(*StaticData), Color, *StaticData\Flags)
        
        
    EndSelect
    
    
    If *StaticData\Gadget <> #PB_Any
      *THIS\Gadget = *StaticData\Gadget
    EndIf
  EndIf
  
  ProcedureReturn *THIS
EndProcedure

; for the gadgets that can handle child items in the xml (combobox, tree, listicon (for columns))
Procedure DlgGadget_AddItem(*Gadget.DlgItemGadget, *StaticData.DialogObjectData)
  If *StaticData\Type = #DIALOG_Item
    AddGadgetItem(*Gadget\Gadget, *Gadget\NbItems, DialogObjectText(*StaticData), 0, *StaticData\Flags) ; flags stores the sublevel for tree items
  Else
    If *Gadget\ColumnAdded = 0
      ; no columns were added yet, so we first must remove the default columns
      *Gadget\ColumnAdded = 1
      
      If GadgetType(*Gadget\Gadget) = #PB_GadgetType_ListIcon
        RemoveGadgetColumn(*Gadget\Gadget, 0)
      Else
        CompilerIf #CompileMac = 0 ; no columns support on OSX for explorerlist
          For i = 1 To 4           ; 4 default columns
            RemoveGadgetColumn(*Gadget\Gadget, 0)
          Next i
        CompilerEndIf
      EndIf
    EndIf
    
    AddGadgetColumn(*Gadget\Gadget, *Gadget\NbItems, DialogObjectText(*StaticData), *StaticData\MinWidth)
  EndIf
  
  *Gadget\Items[*Gadget\NbItems] = *StaticData
  *Gadget\NbItems + 1
EndProcedure


Procedure DlgGadget_SizeRequest(*THIS.DlgGadget, *Width.LONG, *Height.LONG)
  GetRequiredSize(*THIS\Gadget, *Width, *Height, *THIS\StaticData\Flags)
  *Width\l  = Max(*Width\l, *THIS\StaticData\MinWidth)
  *Height\l = Max(*Height\l, *THIS\StaticData\MinHeight)
EndProcedure


Procedure DlgGadget_Update(*THIS.DlgGadget)
  If *THIS\HasTitle And *THIS\StaticData\HasText
    SetGadgetText(*THIS\Gadget, DialogObjectText(*THIS\StaticData))
  EndIf
  
  ; Update itemlists / columns
  If *THIS\StaticData\Type = #DIALOG_ComboBox Or *THIS\StaticData\Type = #DIALOG_Tree
    selection = GetGadgetState(*THIS\Gadget)
    *List.DlgItemGadget = *THIS
    For i = 0 To *List\NbItems -1
      SetGadgetItemText(*THIS\Gadget, i, DialogObjectText(*List\Items[i]), 0)
    Next i
    SetGadgetState(*THIS\Gadget, selection)
    
  ElseIf *THIS\StaticData\Type = #DIALOG_ListIcon
    *List.DlgItemGadget = *THIS
    For i = 0 To *List\NbItems -1
      SetGadgetItemText(*THIS\Gadget, -1, DialogObjectText(*List\Items[i]), i) ; change column title
    Next i
    
  EndIf
EndProcedure

Procedure DlgGadget_SizeApply(*THIS.DlgGadget, x.l, y.l, Width.l, Height.l)
  
  ; On windows, when resizing a text, checkbox, option higher than it needs to be, its
  ; text is not put in the center (vertically) as it is on linux, so this looks bad when
  ; a text/checkbox is put next to a String/Combobox for example.
  ; actually, centering only is not good either. For windows it is needed to offset
  ; the textgadget 2px down to look good... what an ugly hack!
  ;
  ; Note: it's exactly the same issue on OS X cocoa, so enable the hack as well (works perfectly)
  ;
  ; Note: here on Ubuntu 12.04 (x64) and gtk 2.24.10 it seems to be needed as well
  ;       so I enable this for all OS (needs to be checked on other Linux distros)
  ;
  ;CompilerIf #CompileWindows Or #CompileMacCocoa
  If *THIS\StaticData\Type = #DIALOG_Text And *THIS\StaticData\Flags & #PB_Text_Border = 0
    NeededHeight = Max(*THIS\StaticData\MinHeight, GetRequiredHeight(*THIS\Gadget, *THIS\StaticData\Flags))
    If NeededHeight <= Height-2
      ResizeGadget(*THIS\Gadget, x, y+2, Width, Height-2)
      ProcedureReturn
    EndIf
  EndIf
  ;CompilerEndIf
  
  ResizeGadget(*THIS\Gadget, x, y, Width, Height)
EndProcedure


Procedure DlgListView_SizeRequest(*THIS.DlgGadget, *Width.LONG, *Height.LONG)
  *Width\l  = *THIS\StaticData\MinWidth
  *Height\l = *THIS\StaticData\MinHeight
  
  ; Note: On Windows, the ListViewGadget always displays full items when scrolling,
  ;   never a partial one. So there can be an ugly gap at the bottom if the size
  ;   is not a multiple if the item height. So we request a size that is a multiple
  ;   of that on windows for a better look:
  ;
  CompilerIf #CompileWindows
    ItemHeight = SendMessage_(GadgetID(*THIS\Gadget), #LB_GETITEMHEIGHT, 0, 0)
    
    If ItemHeight > 0
      Border = GetSystemMetrics_(#SM_CYEDGE)*2
      Count  = (*Height\l - Border) / ItemHeight
      
      If (Count * ItemHeight + Border) < *Height\l
        *Height\l = (Count+1) * ItemHeight + Border
      EndIf
    EndIf
  CompilerEndIf
EndProcedure

DataSection
  
  DlgGadget_VTable:
  Data.i @DlgBase_SizeRequestWrapper()
  Data.i @DlgGadget_SizeRequest()
  Data.i @DlgGadget_SizeApply()
  Data.i @DlgBase_AddChild()
  Data.i @DlgBase_FoldApply()
  Data.i @DlgBase_Find()
  Data.i @DlgBase_Finish()
  Data.i @DlgGadget_Update()
  Data.i @DlgBase_Destroy()
  
  ; Special VTable for Gadgets with fixed minimal size (Tree, List, etc)
  ;
  DlgFixedGadget_VTable:
  Data.i @DlgBase_SizeRequestWrapper()
  Data.i @DlgBase_SizeRequest()
  Data.i @DlgBase_SizeApply()
  Data.i @DlgBase_AddChild()
  Data.i @DlgBase_FoldApply()
  Data.i @DlgBase_Find()
  Data.i @DlgBase_Finish()
  Data.i @DlgGadget_Update()
  Data.i @DlgBase_Destroy()
  
  
  ; Special VTable for ListView on windows
  ; As we use a special way for height request
  ;
  DlgListView_VTable:
  Data.i @DlgBase_SizeRequestWrapper()
  Data.i @DlgListView_SizeRequest()
  Data.i @DlgBase_SizeApply()
  Data.i @DlgBase_AddChild()
  Data.i @DlgBase_FoldApply()
  Data.i @DlgBase_Find()
  Data.i @DlgBase_Finish()
  Data.i @DlgGadget_Update()
  Data.i @DlgBase_Destroy()
  
  
EndDataSection
