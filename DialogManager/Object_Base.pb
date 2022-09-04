; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------



XIncludeFile "Common.pb"

;
; Accepted keys in the XML by all objects:
;
; width  = specify a minimum dimension for the particular object
; height
;
; text  = literal string for display
; lang  = "Group:Key" pair for language specific display
;         if lang and text are present, the text will be appended to the lang string
; id    = Constant used for Gadget/WindowID. (PB_Any is used if not set)
; flags = extra gadget/window flags to set
; name  = name tag to know a gadget with Dialog\Gadget(Name)
;
; invisible = yes/no (default) - only for real gadgets/windows
; disabled  = yes/no (default) - only for real gadgets/windows
;
; folded = yes/no (default)
;          Every object can be folded (completely hidden and taking up no space)
;          It can be done with this tag or with the Window\Fold() command
;          (the object must have a 'name' tag for that)
;
;
; Specal tags:
;
;  <dialoggroup>    - to group multiple dialogs in one file.. no special meaning otherwise
;  <compiler if=""> - compilerif block. pass a constant expr for the if
;  <compilerelse /> - compilerelse
;  <shortcut key="#KeyConstant" id="#IDConstant)
;

; Base for the Dialog objects
;
Structure DlgBase
  *VTable
  
  *StaticData.DialogObjectData
  *Parent.DlgBase
  
  Gadget.i          ; for Gadgets
  Folded.l          ; applicable to all object types
EndStructure


; Helper function to get the object name (if set)
;
Procedure.s DialogObjectName(*StaticData.DialogObjectData)
  ProcedureReturn PeekS(*StaticData + SizeOf(DialogObjectData)) ; its right after the numeric stuff
EndProcedure


; Helper function to get the correct language string for any object
;
Procedure.s DialogObjectText(*StaticData.DialogObjectData)
  *Pointer = *StaticData + SizeOf(DialogObjectData)
  *Pointer + (MemoryStringLength(*Pointer) + 1) * SizeOf(Character) ; Skip Object Name field
  Literal$ = PeekS(*Pointer): *Pointer + (Len(Literal$) + 1)  * SizeOf(Character)
  
  ; Saveguard, so it can also be used in programs with no language support
  ;
  CompilerIf Defined(Language, #PB_Procedure)
    Group$ = PeekS(*Pointer): *Pointer + (Len(Group$) + 1) * SizeOf(Character)
    Key$   = PeekS(*Pointer)
    
    If Key$ <> "" And Group$ <> ""
      ProcedureReturn Language(Group$, Key$) + Literal$
    EndIf
  CompilerEndIf
  
  ProcedureReturn Literal$
EndProcedure


; Helper function to get the value of a set key. returns "" if unset
;
Procedure.s DialogObjectKey(*StaticData.DialogObjectData, Key$)
  If *StaticData\KeyCount > 0
    *Pointer = *StaticData + SizeOf(DialogObjectData)
    *Pointer + (MemoryStringLength(*Pointer) + 1) * SizeOf(Character) ; skip the 4 strings
    *Pointer + (MemoryStringLength(*Pointer) + 1) * SizeOf(Character)
    *Pointer + (MemoryStringLength(*Pointer) + 1) * SizeOf(Character)
    *Pointer + (MemoryStringLength(*Pointer) + 1) * SizeOf(Character)
    
    For i = 1 To *StaticData\KeyCount
      If CompareMemoryString(@Key$, *Pointer, 1) = 0
        *Pointer + (MemoryStringLength(*Pointer) + 1) * SizeOf(Character) ; skip name
        ProcedureReturn PeekS(*Pointer)                                   ; return found value
      Else
        *Pointer + (MemoryStringLength(*Pointer) + 1) * SizeOf(Character) ; skip this pair
        *Pointer + (MemoryStringLength(*Pointer) + 1) * SizeOf(Character)
      EndIf
    Next i
    
  EndIf
  
  ProcedureReturn ""
EndProcedure


; An often needed function here
; Protected against double declaration as it is in GetRequiredSize.pb as well
;
CompilerIf Defined(Max, #PB_Procedure) = 0
  Procedure Max(a, b)
    If a > b
      ProcedureReturn a
    Else
      ProcedureReturn b
    EndIf
  EndProcedure
CompilerEndIf


; Note: This is a wrapper that always calls the SizeRequestReal() on
;   the own object and then applies the width="ignore" type settings
;   before returning to the original caller. It should be put as
;   SizeRequest() for all Object interfaces!
;
;   This also handles the "folded" flag for the size request, so it
;   does not need to be done manually.
;
Procedure DlgBase_SizeRequestWrapper(*THIS.DlgBase, *Width.LONG, *Height.LONG)
  ; if folded, an object takes no space
  ;
  If *THIS\Folded
    *Width\l = 0
    *Height\l = 0
    
  Else
    THIS.DialogObject = *THIS
    THIS\SizeRequestReal(*Width, *Height) ; call the real function
    
    ; apply the ignore settings (-1 as MinWidth/Height means ignore)
    ;
    If *THIS\StaticData\MinWidth = -1
      *Width\l = 0
    EndIf
    
    If *THIS\StaticData\MinHeight = -1
      *Height\l = 0
    EndIf
    
  EndIf
EndProcedure

; Standard implementations of the interface functions
;
Procedure DlgBase_SizeRequest(*THIS.DlgBase, *Width.LONG, *Height.LONG)
  *Width\l  = *THIS\StaticData\MinWidth
  *Height\l = *THIS\StaticData\MinHeight
EndProcedure


Procedure DlgBase_SizeApply(*THIS.DlgBase, x, y, Width, Height)
  If *THIS\Gadget
    ResizeGadget(*THIS\Gadget, x, y, Width, Height)
  EndIf
EndProcedure


Procedure DlgBase_AddChild(*THIS.DlgBase, Child.DialogObject)
EndProcedure

Procedure DlgBase_FoldApply(*THIS.DlgBase, State)
  If *THIS\Gadget
    ; hiding is always done, showing only if there is no "fold" tag set on this object too
    If State Or *THIS\Folded = 0
      HideGadget(*THIS\Gadget, State)
    EndIf
  EndIf
EndProcedure


Procedure DlgBase_Find(*THIS.DlgBase, Name$)
  If DialogObjectName(*THIS\StaticData) = Name$
    ProcedureReturn *THIS ; now returns the object pointer
  Else
    ProcedureReturn 0
  EndIf
EndProcedure


Procedure DlgBase_Finish(*THIS.DlgBase)
EndProcedure


Procedure DlgBase_Update(*THIS.DlgBase)
  If *THIS\Gadget And *THIS\StaticData\HasText
    SetGadgetText(*THIS\Gadget, DialogObjectText(*THIS\StaticData))
  EndIf
EndProcedure


Procedure DlgBase_Destroy(*THIS.DlgBase)
  FreeMemory(*THIS)
EndProcedure



; Dummy empty object used to leave grid entries free
; Only width/height are allowed
;
Procedure DlgEmpty_New(*StaticData.DialogObjectData)
  *THIS.DlgBase = AllocateMemory(SizeOf(DlgBase))
  If *THIS
    *THIS\VTable     = ?DlgEmpty_VTable
    *THIS\StaticData = *StaticData
  EndIf
  ProcedureReturn *THIS
EndProcedure



DataSection
  
  DlgEmpty_VTable:
  Data.i @DlgBase_SizeRequestWrapper()
  Data.i @DlgBase_SizeRequest()
  Data.i @DlgBase_SizeApply()
  Data.i @DlgBase_AddChild()
  Data.i @DlgBase_FoldApply()
  Data.i @DlgBase_Find()
  Data.i @DlgBase_Finish()
  Data.i @DlgBase_Update()
  Data.i @DlgBase_Destroy()
  
EndDataSection

