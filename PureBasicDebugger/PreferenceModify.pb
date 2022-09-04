; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


;
; General purpose (not debugger/ide specific) functions to modify a Preference file
; without loading all its keys individually
;
;

Structure PreferenceModify_Entry
  Group$
  Key$
  Value$
  IsSaved.l ; flag for the saving process
EndStructure

Global NewList PreferenceModify_List.PreferenceModify_Entry()
Global PreferenceModify_Group$

; loads a preference file into a list
; you can then modify & add keys and groups
;
Procedure PreferenceModify_Load(FileName$)
  File = ReadFile(#PB_Any, FileName$)
  If File
    
    ClearList(PreferenceModify_List())
    Group$ = ""
    
    While Eof(File) = 0
      Line$ = RTrim(ReadString(File))
      
      If Left(Line$, 1) = ";" Or Line$ = "" ; comments, do nothing
        
      ElseIf Left(Line$, 1) = "[" And FindString(Line$, "]", 1) <> 0 ; group name
        Group$ = Mid(Line$, 2, FindString(Line$, "]", 1)-2)
        
      ElseIf FindString(Line$, "=", 1) <> 0 ; key, otherwise invalid entry
        pos = FindString(Line$, "=", 1)
        AddElement(PreferenceModify_List())
        PreferenceModify_List()\Group$ = Group$
        PreferenceModify_List()\Key$   = Trim(Left(Line$, pos-1))
        PreferenceModify_List()\Value$ = Right(Line$, Len(Line$)-pos)
        
        If Left(PreferenceModify_List()\Value$, 1) = " " ; usually like this: "Key = Value"
          PreferenceModify_List()\Value$ = Right(PreferenceModify_List()\Value$, Len(PreferenceModify_List()\Value$)-1)
        EndIf
      EndIf
    Wend
    
    PreferenceModify_Group$ = ""
    CloseFile(File)
    
    ProcedureReturn 1
  Else
    ProcedureReturn 0
  EndIf
EndProcedure

; saves the currently loaded list into FileName$
;
Procedure PreferenceModify_Save(FileName$)
  If CreatePreferences(FileName$)
    
    ; first we must output all with an empty group!
    ; also set the IsSaved flag correctly
    ;
    ForEach PreferenceModify_List()
      If PreferenceModify_List()\Group$ = ""
        WritePreferenceString(PreferenceModify_List()\Key$, PreferenceModify_List()\Value$)
        PreferenceModify_List()\IsSaved = 1
      Else
        PreferenceModify_List()\IsSaved = 0
      EndIf
    Next PreferenceModify_List()
    
    ; now output all the groups
    ;
    ForEach PreferenceModify_List()
      If PreferenceModify_List()\IsSaved = 0 ; only process unsaved entries
                                             ; start a new group
        Group$ = PreferenceModify_List()\Group$
        
        PreferenceComment("") ; do an empty line before a new group
        PreferenceGroup(Group$)
        WritePreferenceString(PreferenceModify_List()\Key$, PreferenceModify_List()\Value$)
        PreferenceModify_List()\IsSaved = 1
        
        ; search all entries with the same group
        *Current = @PreferenceModify_List()
        While NextElement(PreferenceModify_List())
          If UCase(PreferenceModify_List()\Group$) = UCase(Group$)
            WritePreferenceString(PreferenceModify_List()\Key$, PreferenceModify_List()\Value$)
            PreferenceModify_List()\IsSaved = 1
          EndIf
        Wend
        
        ; continue searching for the next unsaved group
        ChangeCurrentElement(PreferenceModify_List(), *Current)
      EndIf
    Next PreferenceModify_List()
    
    ClosePreferences()
    
    ProcedureReturn 1
  Else
    ProcedureReturn 0
  EndIf
EndProcedure

; select the PreferenceGroup() to edit
;
Procedure PreferenceModify_Group(Group$)
  PreferenceModify_Group$ = Group$
EndProcedure

; shared procedures, only used by this file
;
Procedure _PreferenceModify_FindKey(Key$)
  ; search the list
  ;
  ForEach PreferenceModify_List()
    If UCase(PreferenceModify_List()\Group$) = UCase(PreferenceModify_Group$) And UCase(PreferenceModify_List()\Key$) = UCase(Key$)
      ProcedureReturn 1; found the key, Return success
    EndIf
  Next PreferenceModify_List()
  
  ; not found
  ProcedureReturn 0
EndProcedure

Procedure _PreferenceModify_FindOrAddKey(Key$)
  If _PreferenceModify_FindKey(Key$) = 0
    ; not found, add a new one
    LastElement(PreferenceModify_List())
    AddElement(PreferenceModify_List())
    PreferenceModify_List()\Group$ = PreferenceModify_Group$
    PreferenceModify_List()\Key$   = Key$
  EndIf
EndProcedure

Procedure PreferenceModify_SetLong(Key$, Value.l)
  _PreferenceModify_FindOrAddKey(Key$)
  PreferenceModify_List()\Value$ = Str(Value)
EndProcedure

Procedure PreferenceModify_SetFloat(Key$, Value.f)
  _PreferenceModify_FindOrAddKey(Key$)
  PreferenceModify_List()\Value$ = StrF(Value)
EndProcedure

Procedure PreferenceModify_SetString(Key$, Value$)
  _PreferenceModify_FindOrAddKey(Key$)
  PreferenceModify_List()\Value$ = Value$
EndProcedure

Procedure PreferenceModify_GetLong(Key$, DefValue.l)
  If _PreferenceModify_FindKey(Key$)
    ProcedureReturn Val(PreferenceModify_List()\Value$)
  Else
    ProcedureReturn DefValue
  EndIf
EndProcedure

Procedure.f PreferenceModify_GetFloat(Key$, DefValue.f)
  If _PreferenceModify_FindKey(Key$)
    ProcedureReturn ValF(PreferenceModify_List()\Value$)
  Else
    ProcedureReturn DefValue
  EndIf
EndProcedure

Procedure.s PreferenceModify_GetString(Key$, DefValue$)
  If _PreferenceModify_FindKey(Key$)
    ProcedureReturn PreferenceModify_List()\Value$
  Else
    ProcedureReturn DefValue$
  EndIf
EndProcedure

Procedure PreferenceModify_IsKey(Key$)
  ProcedureReturn _PreferenceModify_FindKey(Key$)
EndProcedure

Procedure PreferenceModify_DeleteKey(Key$)
  If _PreferenceModify_FindKey(Key$)
    DeleteElement(PreferenceModify_List())
  EndIf
EndProcedure


