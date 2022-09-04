; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


XIncludeFile "Object_Base.pb"
XIncludeFile "GetRequiredSize.pb"

;
; splitter - SplitterGadget()
;
; Accepted keys in the XML:
;
;  firstmin  = pixel value or "request" (default)
;  secondmin
;
; If firstmin or secondmin is set, they will be set for the gadget, if they are not set
; (or to "request"), the minimum will be the size request of the child.
;
; Note: The vertical mode is determined by the flags parameter
;


Structure DlgSplitter Extends DlgBase
  IsVertical.l
  NbChildren.l  ; max 2
  
  Minimum.l[2]
  RequestedWidth.l[2]
  RequestedHeight.l[2]
  
  ChildGadget.i[2] ; initialized to two container gadgets, later changed if possible
  
  StructureUnion
    Child.DialogObject[2]
    *ChildData.DlgBase[2]
  EndStructureUnion
  
  CompilerIf #CompileWindows
    OldCallback.i ; to monitor gadget resizing events
  CompilerEndIf
EndStructure

; Crossplatform child resize handler
; Needs to be called from the platform-specific event handlers
;
Procedure DlgSplitter_ResizeChildren(*THIS.DlgSplitter)
  For i = 0 To 1
    If *THIS\Child[i]
      Width  = GadgetWidth(*THIS\ChildGadget[i])
      Height = GadgetHeight(*THIS\ChildGadget[i])
      
      ; no longer needed since 4.60
      ;       CompilerIf #CompileLinux
      ;         ; Even a borderless container adds a pixel offset on linux!
      ;         Width  - 8
      ;         Height - 8
      ;       CompilerEndIf
      
      *THIS\Child[i]\SizeApply(0, 0, Width, Height)
    EndIf
  Next i
EndProcedure

CompilerIf #CompileWindows
  
  Procedure DlgSplitter_ResizeCallback(Window, Message, wParam, lParam)
    *THIS.DlgSplitter = GetWindowLongPtr_(Window, #GWL_USERDATA)
    
    If Message = #WM_SIZE
      DlgSplitter_ResizeChildren(*THIS)
    EndIf
    
    ProcedureReturn CallWindowProc_(*THIS\OldCallback, Window, Message, wParam, lParam)
  EndProcedure
  
CompilerEndIf


Procedure DlgSplitter_New(*StaticData.DialogObjectData)
  *THIS.DlgSplitter = AllocateMemory(SizeOf(DlgSplitter))
  
  If *THIS
    *THIS\VTable     = ?DlgSplitter_VTable
    *THIS\StaticData = *StaticData
    
    ; Create 2 containers to put the children in
    ;
    *THIS\ChildGadget[0] = ContainerGadget(#PB_Any, 0, 0, 0, 0, #PB_Container_BorderLess)
    CloseGadgetList()
    
    *THIS\ChildGadget[1] = ContainerGadget(#PB_Any, 0, 0, 0, 0, #PB_Container_BorderLess)
    CloseGadgetList()
    
    *THIS\Gadget = SplitterGadget(*StaticData\Gadget, 0, 0, 0, 0, *THIS\ChildGadget[0], *THIS\ChildGadget[1], *StaticData\Flags)
    
    If *StaticData\Gadget <> #PB_Any
      *THIS\Gadget = *StaticData\Gadget
    EndIf
    
    Value$ = DialogObjectKey(*StaticData, "FIRSTMIN")
    If Value$ = "" Or UCase(Value$) = "REQUEST"
      *THIS\Minimum[0] = -1
    Else
      *THIS\Minimum[0] = Val(Value$)
      ;SetGadgetAttribute(*THIS\Gadget, #PB_Splitter_FirstMinimumSize, *THIS\Minimum[0])
    EndIf
    
    Value$ = DialogObjectKey(*StaticData, "SECONDMIN")
    If Value$ = "" Or UCase(Value$) = "REQUEST"
      *THIS\Minimum[1] = -1
    Else
      *THIS\Minimum[1] = Val(Value$)
      ;SetGadgetAttribute(*THIS\Gadget, #PB_Splitter_SecondMinimumSize, *THIS\Minimum[1])
    EndIf
    
    If *StaticData\Flags & #PB_Splitter_Vertical
      *THIS\IsVertical = #True
    EndIf
    
    CompilerIf #CompileWindows
      ;
      ; Set a resize handler on the first container to catch splitter move events
      ;
      SetWindowLongPtr_(GadgetID(*THIS\ChildGadget[0]), #GWL_USERDATA, *THIS) ; this field is not used by the lib
      *THIS\OldCallback = SetWindowLongPtr_(GadgetID(*THIS\ChildGadget[0]), #GWL_WNDPROC, @DlgSplitter_ResizeCallback())
    CompilerEndIf
    
    ; Add any new gadgets inside the first child
    ;
    OpenGadgetList(*THIS\ChildGadget[0])
  EndIf
  
  ProcedureReturn *THIS
EndProcedure



Procedure DlgSplitter_SizeRequest(*THIS.DlgSplitter, *Width.LONG, *Height.LONG)
  For i = 0 To 1
    *THIS\RequestedWidth[i]  = 0
    *THIS\RequestedHeight[i] = 0
    
    If *THIS\Child[i]
      *THIS\Child[i]\SizeRequest(@*THIS\RequestedWidth[i], @*THIS\RequestedHeight[i])
    EndIf
    
    ; no longer needed since 4.60
    ;     CompilerIf #CompileLinux
    ;       ; Even a borderless container adds a pixel offset on linux!
    ;       *THIS\RequestedWidth[i]  + 8
    ;       *THIS\RequestedHeight[i] + 8
    ;     CompilerEndIf
    
    If *THIS\Minimum[i] = -1
      If *THIS\IsVertical
        SetGadgetAttribute(*THIS\Gadget, #PB_Splitter_FirstMinimumSize, *THIS\RequestedWidth[i])
      Else
        SetGadgetAttribute(*THIS\Gadget, #PB_Splitter_FirstMinimumSize, *THIS\RequestedHeight[i])
      EndIf
    EndIf
  Next i
  
  CompilerIf #CompileWindows
    If *THIS\StaticData\Flags & #PB_Splitter_Separator
      SplitterWidth = 7 ; fixed values set in the splitter sources
    Else
      SplitterWidth = 4
    EndIf
  CompilerEndIf
  
  CompilerIf #CompileLinux
    ; TODO: try :handle-size style property (default=5)
    SplitterWidth = 5
  CompilerEndIf
  
  CompilerIf #CompileMac
    SplitterWidth = 7 ; fixed value set in the splitter sources
  CompilerEndIf
  
  If *THIS\IsVertical
    *Width\l  = *THIS\RequestedWidth[0] + *THIS\RequestedWidth[0] + SplitterWidth
    *Height\l = Max(*THIS\RequestedHeight[0], *THIS\RequestedHeight[1])
  Else
    *Width\l  = Max(*THIS\RequestedWidth[0], *THIS\RequestedWidth[0])
    *Height\l = *THIS\RequestedHeight[0] + *THIS\RequestedHeight[1] + SplitterWidth
  EndIf
  
  *Width\l  = Max(*Width\l,  *THIS\StaticData\MinWidth)
  *Height\l = Max(*Height\l, *THIS\StaticData\MinHeight)
EndProcedure

Procedure DlgSplitter_SizeApply(*THIS.DlgSplitter, x, y, Width, Height)
  ResizeGadget(*THIS\Gadget, x, y, Width, Height)
  DlgSplitter_ResizeChildren(*THIS)
EndProcedure

Procedure DlgSplitter_AddChild(*THIS.DlgSplitter, Child.DialogObject)
  If *THIS\NbChildren >= 2
    CompilerIf #PB_Compiler_Debugger
      MessageRequester("Dialog Manager", "Object can only hold two children !")
    CompilerEndIf
    
    ProcedureReturn
  EndIf
  
  index = *THIS\NbChildren
  *THIS\NbChildren + 1
  
  ; NOTE: AddChild() is called after all child gadgets are created, that is why the
  ;   first OpenGadgetList() is in DlgSplitter_New() and we do the close here
  ;
  ; close the gadgetlist of the current child
  CloseGadgetList()
  
  ; open the gadgetlist of the next child (if any)
  If *THIS\NbChildren < 2
    OpenGadgetList(*THIS\ChildGadget[index+1])
  EndIf
  
  *THIS\Child[index] = Child
  *THIS\ChildData[index]\Parent = *THIS
EndProcedure

Procedure DlgSplitter_Find(*THIS.DlgSplitter, Name$)
  If DialogObjectName(*THIS\StaticData) = Name$
    ProcedureReturn *THIS ; now returns the object pointer!
  EndIf
  
  For i = 0 To *THIS\NbChildren-1
    Result = *THIS\Child[i]\Find(Name$)
    If Result <> 0
      ProcedureReturn Result
    EndIf
  Next i
EndProcedure


Procedure DlgSplitter_Update(*THIS.DlgSplitter)
  For i = 0 To *THIS\NbChildren-1
    *THIS\Child[i]\Update()
  Next i
EndProcedure



Procedure DlgSplitter_Destroy(*THIS.DlgSplitter)
  For i = 0 To *THIS\NbChildren-1
    *THIS\Child[i]\Destroy()
  Next i
  
  FreeMemory(*THIS)
EndProcedure

DataSection
  
  DlgSplitter_VTable:
  Data.i @DlgBase_SizeRequestWrapper()
  Data.i @DlgSplitter_SizeRequest()
  Data.i @DlgSplitter_SizeApply()
  Data.i @DlgSplitter_AddChild()
  Data.i @DlgBase_FoldApply()
  Data.i @DlgSplitter_Find()
  Data.i @DlgBase_Finish()
  Data.i @DlgSplitter_Update()
  Data.i @DlgSplitter_Destroy()
  
  
EndDataSection



