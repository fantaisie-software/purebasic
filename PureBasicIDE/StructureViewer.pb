; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

Global Dim StructureList.s(0)
Global Dim InterfaceList.s(0)
Global Dim ConstantList.s(0)
Global Dim ConstantValueList.s(0)

; The values stored in the tree are indexes into StructureList(), InterfaceList() and ConstantList() "index+1" actually
; This is for easy access with RadixFindRange(). The +1 is to avoid 0 value which are not stored in the radix tree
Global ConstantTree.RadixTree
Global StructureTree.RadixTree
Global InterfaceTree.RadixTree

; Still used to show structure content based on selection of the first start character below
Global Dim ConstantHT.l(27, 1)
Global Dim StructureHT.l(27, 1)
Global Dim InterfaceHT.l(27, 1)

Structure StructureHistory
  Name$
  Line.l
EndStructure

Global NewList StructureHistory.StructureHistory()

Global StructureViewerMode, IsRootDisplay, CurrentDisplayChar


Procedure LoadConstantList()
  
  ; This function is called from CompilerReady(), so the compiler is always ready here
  ;
  ClearList(TempList())
  
  CompilerWrite("CONSTANTLIST")
  
  NbConstants$ = CompilerRead() ; Don't use this number as it was broken before 5.40. We don't need it anyway.
  
  Repeat
    Response$ = CompilerRead_NoDebug(#PB_UTF8)
    
    If Response$ = ~"OUTPUT\tCOMPLETE" ; End of list
      Break
    Else
      ; The same handling for all type (float/string/long)
      ; We don't unescape the strings, as it is only for display in the structure viewer and it's better to see '\n' then a blank char
      ;
      AddElement(TempList())
      TempList() = "#" + StringField(Response$, 2, #TAB$) + "=" + StringField(Response$, 3, #TAB$)
    EndIf
  ForEver
  
  ConstantListSize = ListSize(TempList())
  Dim ConstantList.s(ConstantListSize)
  Dim ConstantValueList.s(ConstantListSize)
  RadixFree(ConstantTree)
  
  ; make all HT entries invalid
  For i = 0 To 27
    ConstantHT(i, 1) = -1
  Next i
  
  index = 0
  ForEach TempList()
    separator = FindString(TempList(), "=", 1)
    
    ; invalid entries
    If separator = 0 Or Left(TempList(), separator-1) = "#"
      ConstantListSize - 1
      
      ; Note: In the constant list, there is "#CR" and "#CR$". The $ is sorted wrong, because
      ;  we append <name>=<value> for easy sorting, and "=" > "$" in lexical order,
      ;  so the $-name sorts before the non-$ one, which is wrong (And causes problems With later item comparrison)
      ;
      ; Solution: Detect the $, replace it with a char that is > "=", but < all alpha chars,
      ;  so the sorting is correct. later undo this replace below.
      ;
    ElseIf Mid(TempList(), separator-1, 1) = "$"
      ConstantList(index) = Left(TempList(), separator-2) + "?" + Right(TempList(), Len(TempList())-(separator-1))
      index + 1
      
    Else
      ConstantList(index) = TempList()
      index + 1
      
    EndIf
  Next TempList()
  SortArray(ConstantList(), 2, 0, ConstantListSize-1)
  
  ; split the values from the full line and build ht
  k = 0
  For i = 0 To ConstantListSize - 1
    ConstantValueList(i) = Right(ConstantList(i), Len(ConstantList(i))-FindString(ConstantList(i), "=", 1))
    ConstantList(i)      = Left (ConstantList(i), FindString(ConstantList(i), "=", 1)-1)
    
    ; undo the above fix for the $ in constant names from above
    ;
    If Right(ConstantList(i), 1) = "?"
      ConstantList(i) = Left(ConstantList(i), Len(ConstantList(i))-1) + "$"
    EndIf
    
    RadixInsert(ConstantTree, ConstantList(i), i+1)
    
    c = Asc(UCase(Mid(ConstantList(i), 2, 1)))
    If c = '_'
      c = 27
    Else
      c - 'A' + 1
    EndIf
    
    If k <> c
      ConstantHT(c, 0) = i
      ConstantHT(k, 1) = i-1
      k = c
    EndIf
  Next i
  ConstantHT(k, 1) = ConstantListSize - 1
  
  ConstantHT(0, 0) = 0  ; this is for the full list
  ConstantHT(0, 1) = ConstantListSize - 1
  
  ClearList(TempList())
  
EndProcedure



Procedure InitStructureViewer()
  
  ; This function is called from CompilerReady(), so the compiler is always ready here
  ;
  LoadConstantList()
  
  CompilerWrite("STRUCTURELIST")
  Response$ = CompilerRead()
  
  StructureListSize = Val(Response$)
  Dim StructureList.s(StructureListSize) ; no -1 here in case StructureListSize = 0
  RadixFree(StructureTree)
  
  ; We read until OUTPUT<T>COMPLETE. Even if we read all entries yet.
  ; If this is not done, the OUTPUT<T>COMPLETE will remain in the buffer!
  index = 0
  Repeat
    Response$ = CompilerRead_NoDebug()
    
    If Response$ = "OUTPUT"+Chr(9)+"COMPLETE"
      Break
    ElseIf index < StructureListSize And Response$ <> ""
      StructureList(index) = Response$
      index + 1
    EndIf
  ForEver
  
  SortArray(StructureList(), 2, 0, StructureListSize-1)
  
  ; make all HT entries invalid
  For i = 0 To 27
    StructureHT(i, 1) = -1
  Next i
  
  ; build ht
  k = 0
  For i = 0 To StructureListSize - 1
    RadixInsert(StructureTree, StructureList(i), i+1)
    
    c = Asc(UCase(Left(StructureList(i), 1)))
    If c = '_'
      c = 27
    Else
      c - 'A' + 1
    EndIf
    
    If k <> c
      StructureHT(c, 0) = i
      StructureHT(k, 1) = i-1
      k = c
    EndIf
  Next i
  StructureHT(k, 1) = StructureListSize - 1
  
  StructureHT(0, 0) = 0  ; this is for the full list
  StructureHT(0, 1) = StructureListSize - 1
  
  
  CompilerWrite("INTERFACELIST")
  Response$ = CompilerRead()
  
  InterfaceListSize = Val(Response$)
  Dim InterfaceList.s(InterfaceListSize) ; no -1 here in case InterfaceListSize = 0
  RadixFree(InterfaceTree)
  
  ; We read until OUTPUT<T>COMPLETE. Even if we read all entries yet.
  ; If this is not done, the OUTPUT<T>COMPLETE will remain in the buffer!
  index = 0
  Repeat
    Response$ = CompilerRead_NoDebug()
    
    If Response$ = "OUTPUT"+Chr(9)+"COMPLETE"
      Break
    ElseIf index < InterfaceListSize And Response$ <> ""
      InterfaceList(index) = Response$
      index + 1
    EndIf
  ForEver
  
  SortArray(InterfaceList(), 2, 0, InterfaceListSize-1)
  
  ; make all HT entries invalid
  For i = 0 To 27
    InterfaceHT(i, 1) = -1
  Next i
  
  ; build ht
  k = 0
  For i = 0 To InterfaceListSize - 1
    RadixInsert(InterfaceTree, InterfaceList(i), i+1)
    
    c = Asc(UCase(Left(InterfaceList(i), 1)))
    If c = '_'
      c = 27
    Else
      c - 'A' + 1
    EndIf
    
    If k <> c
      InterfaceHT(c, 0) = i
      InterfaceHT(k, 1) = i-1
      k = c
    EndIf
  Next i
  InterfaceHT(k, 1) = InterfaceListSize - 1
  
  InterfaceHT(0, 0) = 0  ; this is for the full list
  InterfaceHT(0, 1) = InterfaceListSize - 1
  
EndProcedure


Procedure DisplayStructureRootList()
  
  CompilerIf #CompileLinuxGtk
    *tree_model = gtk_tree_view_get_model_(GadgetID(#GADGET_StructureViewer_List))
    g_object_ref_(*tree_model) ; must be ref'ed or it is destroyed
    gtk_tree_view_set_model_(GadgetID(#GADGET_StructureViewer_List), #Null) ; disconnect the model for a faster update
  CompilerEndIf
  
  ; Stop the redraw for a faster update
  StartGadgetFlickerFix(#GADGET_StructureViewer_List)
  
  ClearGadgetItems(#GADGET_StructureViewer_List)
  
  SetGadgetText(#GADGET_StructureViewer_Name, "")
  SetWindowTitle(#WINDOW_StructureViewer, Language("StructureViewer","Title"))
  
  DisableGadget(#GADGET_StructureViewer_Parent, 1)
  DisableGadget(#GADGET_StructureViewer_InsertName, 1)
  DisableGadget(#GADGET_StructureViewer_InsertStruct, 1)
  DisableGadget(#GADGET_StructureViewer_InsertCopy, 1)
  For i = 0 To 27
    If i = CurrentDisplayChar
      SetGadgetState(#GADGET_StructureViewer_Char0+i, 1)
    Else
      SetGadgetState(#GADGET_StructureViewer_Char0+i, 0)
    EndIf
  Next i
  
  
  If StructureViewerMode = 0
    For i = 0 To 27
      If StructureHT(i, 1) = -1
        DisableGadget(#GADGET_StructureViewer_Char0+i, 1)
      Else
        DisableGadget(#GADGET_StructureViewer_Char0+i, 0)
      EndIf
    Next i
    For i = StructureHT(CurrentDisplayChar, 0) To StructureHT(CurrentDisplayChar, 1)
      AddGadgetItem(#GADGET_StructureViewer_List, -1, StructureList(i))
    Next i
    
  ElseIf StructureViewerMode = 1
    For i = 0 To 27
      If InterfaceHT(i, 1) = -1
        DisableGadget(#GADGET_StructureViewer_Char0+i, 1)
      Else
        DisableGadget(#GADGET_StructureViewer_Char0+i, 0)
      EndIf
    Next i
    For i = InterfaceHT(CurrentDisplayChar, 0) To InterfaceHT(CurrentDisplayChar, 1)
      AddGadgetItem(#GADGET_StructureViewer_List, -1, InterfaceList(i))
    Next i
    
  Else
    For i = 0 To 27
      If ConstantHT(i, 1) = -1
        DisableGadget(#GADGET_StructureViewer_Char0+i, 1)
      Else
        DisableGadget(#GADGET_StructureViewer_Char0+i, 0)
      EndIf
    Next i
    For i = ConstantHT(CurrentDisplayChar, 0) To ConstantHT(CurrentDisplayChar, 1)
      AddGadgetItem(#GADGET_StructureViewer_List, -1, ConstantList(i)+" = "+ConstantValueList(i))
    Next i
    
  EndIf
  
  ; NOTE! must be done before the SetGadgetState, as it accesses the tree model which we removed!
  CompilerIf #CompileLinuxGtk
    gtk_tree_view_set_model_(GadgetID(#GADGET_StructureViewer_List), *tree_model) ; reconnect the model
    g_object_unref_(*tree_model)                                                  ; release reference
  CompilerEndIf
  
  StopGadgetFlickerFix(#GADGET_StructureViewer_List)
  
  If ListSize(StructureHistory()) = 1
    If IsRootDisplay
      If StructureViewerMode = 0
        index = StructureHistory()\Line - StructureHT(CurrentDisplayChar, 0)
      ElseIf StructureViewerMode = 1
        index = StructureHistory()\Line - InterfaceHT(CurrentDisplayChar, 0)
      Else
        index = StructureHistory()\Line - ConstantHT(CurrentDisplayChar, 0)
      EndIf
    Else
      index = StructureHistory()\Line
    EndIf
    
    If index >= 0 And index < CountGadgetItems(#GADGET_StructureViewer_List)
      SetGadgetState(#GADGET_StructureViewer_List, index)
    EndIf
  EndIf
  ClearList(StructureHistory())
  
  IsRootDisplay = 1
  
EndProcedure

Procedure DisplayStructure(Name$)
  IsRootDisplay = 0
  DisableGadget(#GADGET_StructureViewer_Parent, 0)
  DisableGadget(#GADGET_StructureViewer_InsertName, 0)
  DisableGadget(#GADGET_StructureViewer_InsertStruct, 0)
  DisableGadget(#GADGET_StructureViewer_InsertCopy, 0)
  
  For i = 0 To 27
    DisableGadget(#GADGET_StructureViewer_Char0+i, 1)
  Next i
  
  SetWindowTitle(#WINDOW_StructureViewer, Language("StructureViewer","Title") + " - " + Name$)
  ClearGadgetItems(#GADGET_StructureViewer_List)
  
  SetGadgetText(#GADGET_StructureViewer_Name, "")
  
  ; A Compiler newstart could have happened, so check this!
  ;
  If CompilerReady
    AddGadgetItem(#GADGET_StructureViewer_List, -1, "Structure " + Name$)
    
    ForceDefaultCompiler()
    CompilerWrite("STRUCTURE"+Chr(9)+Trim(Name$))
    
    Repeat
      Response$ = CompilerRead()
      
      If Response$ = "OUTPUT"+Chr(9)+"COMPLETE"
        Break
      Else
        AddGadgetItem(#GADGET_StructureViewer_List, -1, "  " + Response$)
      EndIf
    ForEver
    
    AddGadgetItem(#GADGET_StructureViewer_List, -1, "EndStructure")
  EndIf
  
EndProcedure

Procedure DisplayInterface(Name$)
  IsRootDisplay = 0
  DisableGadget(#GADGET_StructureViewer_Parent, 0)
  DisableGadget(#GADGET_StructureViewer_InsertName, 0)
  DisableGadget(#GADGET_StructureViewer_InsertCopy, 0)
  
  For i = 0 To 27
    DisableGadget(#GADGET_StructureViewer_Char0+i, 1)
  Next i
  
  SetWindowTitle(#WINDOW_StructureViewer, Language("StructureViewer","Title") + " - " + Name$)
  ClearGadgetItems(#GADGET_StructureViewer_List)
  
  SetGadgetText(#GADGET_StructureViewer_Name, "")
  
  ; A Compiler newstart could have happened, so check this!
  ;
  If CompilerReady
    AddGadgetItem(#GADGET_StructureViewer_List, -1, "Interface " + Name$)
    
    ForceDefaultCompiler()
    CompilerWrite("INTERFACE"+Chr(9)+Trim(Name$))
    
    Repeat
      Response$ = CompilerRead()
      
      If Response$ = "OUTPUT"+Chr(9)+"COMPLETE"
        Break
      Else
        AddGadgetItem(#GADGET_StructureViewer_List, -1, "  " + Response$)
      EndIf
    ForEver
    
    AddGadgetItem(#GADGET_StructureViewer_List, -1, "EndInterface")
  EndIf
  
EndProcedure


Procedure OpenStructureViewerWindow()
  
  If IsWindow(#WINDOW_StructureViewer) = 0
    
    StructureViewerDialog = OpenDialog(?Dialog_StructureViewer, 0, @StructureViewerPosition)
    If StructureViewerDialog
      EnsureWindowOnDesktop(#WINDOW_StructureViewer)
      
      CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
        ; https://www.purebasic.fr/english/viewtopic.php?f=24&t=63494
        ; Warning, DisplayStructureRootList() does the resize, so it must be after
        ;
        WindowBounds(#WINDOW_StructureViewer, 500, 300, #PB_Ignore, #PB_Ignore)
      CompilerEndIf
      
      CurrentDisplayChar = 0
      SetWindowStayOnTop(#WINDOW_StructureViewer, StructureViewerStayOnTop)
      SetGadgetState(#GADGET_StructureViewer_OnTop, StructureViewerStayOnTop)
      
      Word$ = LCase(GetCurrentWord())
      
      If Word$ <> ""
        Found = 0
        For index = 0 To StructureListSize-1
          If LCase(StructureList(index)) = Word$
            Found = 1
            Break
          EndIf
        Next index
        
        If Found
          StructureViewerMode = 0
        Else
          For index = 0 To InterfaceListSize-1
            If LCase(InterfaceList(index)) = Word$
              Found = 1
              Break
            EndIf
          Next index
          
          If Found
            StructureViewerMode = 1
          Else
            Word$ = "#" + Word$
            For index = 0 To StructureListSize-1
              If LCase(StructureList(index)) = Word$
                Found = 1
                Break
              EndIf
            Next index
            
            If Found
              StructureViewerMode = 2
            Else
              StructureViewerMode = 0
              index = -1
            EndIf
          EndIf
        EndIf
      Else
        StructureViewerMode = 0
        index = -1
      EndIf
      
      SetGadgetState(#GADGET_StructureViewer_Panel, StructureViewerMode)
      DisplayStructureRootList()
      HideWindow(#WINDOW_StructureViewer, 0) ; DisplayStructureRootList() does the resize too, so show the window only when its done.
      SetGadgetState(#GADGET_StructureViewer_List, index)
      
      EnableGadgetDrop(#GADGET_StructureViewer_List, #PB_Drop_Text, #PB_Drag_Copy)
      
    EndIf
    
  Else
    SetWindowForeground(#WINDOW_StructureViewer)
  EndIf
  
  SetActiveGadget(#GADGET_StructureViewer_List)
  
EndProcedure


Procedure StructureViewerWindowEvents(EventID)
  
  If EventID = #PB_Event_Menu
    EventID = #PB_Event_Gadget
    EventGadgetID = EventMenu()
  ElseIf EventID = #PB_Event_Gadget
    EventGadgetID = EventGadget()
  EndIf
  
  Select EventID
      
    Case #PB_Event_CloseWindow
      If MemorizeWindow
        StructureViewerDialog\Close(@StructureViewerPosition)
      Else
        StructureViewerDialog\Close()
      EndIf
      StructureViewerDialog = 0
      
    Case #PB_Event_SizeWindow
      StructureViewerDialog\SizeUpdate()
      
    Case #PB_Event_GadgetDrop
      Text$ = RemoveString(RemoveString(EventDropText(), Chr(9)), " ")
      
      ; try to locate the struct/interface
      If Text$ <> "" And Text$ <> "#" ; a single "#" will be problematic below
        
        ascii = Asc(UCase(Left(RemoveString(Text$, "#"), 1)))
        If ascii = '_'
          char = 27
        ElseIf ascii >= 'A' And ascii <= 'Z'
          char = ascii - 'A' + 1
        Else
          char = 0 ; the HT at index 0 spans the whole list
        EndIf
        
        IsStructure = -1
        IsInterface = -1
        IsConstant  = -1
        
        If Left(Text$, 1) = "#" ; must be a constant
          For i = ConstantHT(char, 0) To ConstantHT(char, 1)
            If CompareMemoryString(@Text$, @ConstantList(i), #PB_String_NoCaseAscii) = 0
              IsConstant = i
              Break
            EndIf
          Next i
          
        Else ; can be anything...
          For i = StructureHT(char, 0) To StructureHT(char, 1)
            If CompareMemoryString(@Text$, @StructureList(i), #PB_String_NoCaseAscii) = 0
              IsStructure = i
              Break
            EndIf
          Next i
          
          For i = InterfaceHT(char, 0) To InterfaceHT(char, 1)
            If CompareMemoryString(@Text$, @InterfaceList(i), #PB_String_NoCaseAscii) = 0
              IsInterface = i
              Break
            EndIf
          Next i
          
          Text$ = "#" + Text$ ; try also constants here
          For i = ConstantHT(char, 0) To ConstantHT(char, 1)
            If CompareMemoryString(@Text$, @ConstantList(i), #PB_String_NoCaseAscii) = 0
              IsConstant = i
              Break
            EndIf
          Next i
        EndIf
        
        ; select the action to do based on the current mode and what type
        ; the dropped text is...
        ;
        If StructureViewerMode = 0 And IsStructure <> -1
          AddElement(StructureHistory())
          StructureHistory()\Name$ = StructureList(IsStructure)
          StructureHistory()\Line  = GetGadgetState(#GADGET_StructureViewer_List)
          DisplayStructure(StructureList(IsStructure))
          
        ElseIf StructureViewerMode = 1 And IsInterface <> -1
          AddElement(StructureHistory())
          StructureHistory()\Name$ = InterfaceList(IsInterface)
          StructureHistory()\Line  = GetGadgetState(#GADGET_StructureViewer_List)
          DisplayInterface(InterfaceList(IsInterface))
          
        ElseIf StructureViewerMode = 2 And IsConstant <> -1
          ClearList(StructureHistory())
          If CurrentDisplayChar <> 0 And CurrentDisplayChar <> char
            CurrentDisplayChar = 0
            DisplayStructureRootList()
          EndIf
          SetGadgetState(#GADGET_StructureViewer_List, IsConstant - ConstantHT(CurrentDisplayChar, 0))
          DisableGadget(#GADGET_StructureViewer_InsertName, 0)
          DisableGadget(#GADGET_StructureViewer_InsertCopy, 0)
          
        ElseIf IsStructure <> -1
          StructureViewerMode = 0
          SetGadgetState(#GADGET_StructureViewer_Panel, 0)
          ClearList(StructureHistory())
          AddElement(StructureHistory())
          StructureHistory()\Name$ = StructureList(IsStructure)
          StructureHistory()\Line  = -1
          DisplayStructure(StructureList(IsStructure))
          
        ElseIf IsInterface <> -1
          StructureViewerMode = 1
          SetGadgetState(#GADGET_StructureViewer_Panel, 1)
          ClearList(StructureHistory())
          AddElement(StructureHistory())
          StructureHistory()\Name$ = InterfaceList(IsInterface)
          StructureHistory()\Line  = -1
          DisplayInterface(InterfaceList(IsInterface))
          
        ElseIf IsConstant <> -1
          ClearList(StructureHistory())
          StructureViewerMode = 2
          CurrentDisplayChar = 0
          SetGadgetState(#GADGET_StructureViewer_Panel, 2)
          DisplayStructureRootList()
          SetGadgetState(#GADGET_StructureViewer_List, IsConstant - ConstantHT(CurrentDisplayChar, 0))
          DisableGadget(#GADGET_StructureViewer_InsertName, 0)
          DisableGadget(#GADGET_StructureViewer_InsertCopy, 0)
          
        EndIf
        
      EndIf
      
    Case #PB_Event_Gadget
      Select EventGadgetID
          
        Case #GADGET_StructureViewer_Panel
          If StructureViewerMode <> GetGadgetState(#GADGET_StructureViewer_Panel)
            StructureViewerMode = GetGadgetState(#GADGET_StructureViewer_Panel)
            CurrentDisplayChar = 0
            ClearList(StructureHistory())
            DisplayStructureRootList()
          EndIf
          
        Case #GADGET_StructureViewer_List
          If EventType() = #PB_EventType_DragStart
            index = GetGadgetState(#GADGET_StructureViewer_List)
            If index <> -1
              DragText(Trim(GetGadgetItemText(#GADGET_StructureViewer_List, index)))
            EndIf
            
          ElseIf EventType() = #PB_EventType_LeftDoubleClick
            index = GetGadgetState(#GADGET_StructureViewer_List)
            If index <> -1
              If StructureViewerMode = 0
                
                If IsRootDisplay
                  index + StructureHT(CurrentDisplayChar, 0)
                  AddElement(StructureHistory())
                  StructureHistory()\Name$ = StructureList(index)
                  StructureHistory()\Line  = index
                  DisplayStructure(StructureList(index))
                  
                Else
                  Name$ = GetGadgetItemText(#GADGET_StructureViewer_List, index, 0)
                  position = FindString(Name$, ".", 1)
                  If position <> 0
                    Name$ = Right(Name$, Len(Name$)-position)
                    
                    position = FindString(Name$, "[", 1)
                    If position <> 0
                      Name$ = Left(Name$, position-1)
                    EndIf
                    
                    If Len(Name$) > 1 Or FindString("bwlfs", LCase(Name$), 1) = 0
                      
                      AddElement(StructureHistory())
                      StructureHistory()\Name$ = Name$
                      StructureHistory()\Line = index
                      DisplayStructure(Name$)
                      
                    EndIf
                  EndIf
                EndIf
                
              ElseIf StructureViewerMode = 1
                If IsRootDisplay
                  index + InterfaceHT(CurrentDisplayChar, 0)
                  AddElement(StructureHistory())
                  StructureHistory()\Line  = index
                  StructureHistory()\Name$ = InterfaceList(index)
                  DisplayInterface(InterfaceList(index))
                EndIf
                
                ; do noting for mode 3 (Constant display)
              EndIf
            EndIf
            
          ElseIf EventType() = #PB_EventType_LeftClick
            If IsRootDisplay
              index = GetGadgetState(#GADGET_StructureViewer_List)
              If index = -1
                SetWindowTitle(#WINDOW_StructureViewer, Language("StructureViewer","Title"))
                DisableGadget(#GADGET_StructureViewer_InsertName, 1)
                DisableGadget(#GADGET_StructureViewer_InsertCopy, 1)
              Else
                If StructureViewerMode = 2
                  Name$ = ConstantList(index + ConstantHT(CurrentDisplayChar, 0))
                Else
                  Name$ = GetGadgetItemText(#GADGET_StructureViewer_List, index, 0)
                EndIf
                SetWindowTitle(#WINDOW_StructureViewer, Language("StructureViewer","Title") + " - " + Name$)
                SetGadgetText(#GADGET_StructureViewer_Name, Name$)
                DisableGadget(#GADGET_StructureViewer_InsertName, 0)
                If StructureViewerMode = 2
                  DisableGadget(#GADGET_StructureViewer_InsertCopy, 0)
                EndIf
              EndIf
            EndIf
            
          EndIf
          
        Case #GADGET_StructureViewer_Parent
          If IsRootDisplay = 0 And StructureViewerMode <> 2
            If ListSize(StructureHistory()) = 1
              DisplayStructureRootList()
            ElseIf ListSize(StructureHistory()) > 0
              Line = StructureHistory()\Line
              DeleteElement(StructureHistory())
              If StructureViewerMode = 0
                DisplayStructure(StructureHistory()\Name$)
              Else
                DisplayInterface(StructureHistory()\Name$)
              EndIf
              SetGadgetState(#GADGET_StructureViewer_List, Line)
            EndIf
          EndIf
          
        Case #GADGET_StructureViewer_Name
          If EventType() = #PB_EventType_Change
            If IsRootDisplay
              index = 0
              Text$ = GetGadgetText(#GADGET_StructureViewer_Name)
              Length = Len(Text$)
              If Text$ <> ""
                If StructureViewerMode = 0
                  If StructureListSize > 0
                    While index < StructureListSize And CompareMemoryString(@Text$, @StructureList(index), #PB_String_NoCaseAscii, Length) > 0
                      index + 1
                    Wend
                    If CompareMemoryString(@Text$, @StructureList(index), 1, Length) < 0
                      index - 1
                    EndIf
                    index - StructureHT(CurrentDisplayChar, 0)
                  EndIf
                ElseIf StructureViewerMode = 1
                  If InterfaceListSize > 0
                    While index < InterfaceListSize And CompareMemoryString(@Text$, @InterfaceList(index), #PB_String_NoCaseAscii, Length) > 0
                      index + 1
                    Wend
                    If CompareMemoryString(@Text$, @InterfaceList(index), #PB_String_NoCaseAscii, Length) < 0
                      index - 1
                    EndIf
                    index - InterfaceHT(CurrentDisplayChar, 0)
                  EndIf
                Else
                  If ConstantListSize > 0
                    If Left(Text$, 1) <> "#": Text$ = "#" + Text$: EndIf
                    Length = Len(Text$)
                    While index < ConstantListSize And CompareMemoryString(@Text$, @ConstantList(index), #PB_String_NoCaseAscii, Length) > 0
                      index + 1
                    Wend
                    If index > 0 And CompareMemoryString(@Text$, @ConstantList(index), #PB_String_NoCaseAscii, Length) < 0
                      index - 1
                    EndIf
                    index - ConstantHT(CurrentDisplayChar, 0)
                  EndIf
                EndIf
                
                If index < 0
                  SetGadgetState(#GADGET_StructureViewer_List, -1)
                  DisableGadget(#GADGET_StructureViewer_InsertName, 1)
                  DisableGadget(#GADGET_StructureViewer_InsertCopy, 1)
                Else
                  SetGadgetState(#GADGET_StructureViewer_List, index)
                  DisableGadget(#GADGET_StructureViewer_InsertName, 0)
                  If StructureViewerMode = 2
                    DisableGadget(#GADGET_StructureViewer_InsertCopy, 0)
                  EndIf
                EndIf
              EndIf
            EndIf
          EndIf
          
          
        Case #GADGET_StructureViewer_Ok
          If StructureViewerMode <> 2  ; no action if constants are displayed!
            Name$ = GetGadgetText(#GADGET_StructureViewer_Name)
            If Trim(Name$) <> ""
              If StructureViewerMode = 0
                For i = 0 To StructureListSize-1
                  If CompareMemoryString(@Name$, @StructureList(i), #PB_String_NoCaseAscii) = 0
                    AddElement(StructureHistory())
                    StructureHistory()\Name$ = Name$
                    StructureHistory()\Line  = index
                    DisplayStructure(Name$)
                    Break
                  EndIf
                Next i
              Else
                For i = 0 To InterfaceListSize-1
                  If CompareMemoryString(@Name$, @InterfaceList(i), #PB_String_NoCaseAscii) = 0
                    AddElement(StructureHistory())
                    StructureHistory()\Name$ = Name$
                    StructureHistory()\Line  = index
                    DisplayInterface(Name$)
                    Break
                  EndIf
                Next i
              EndIf
            EndIf
          EndIf
          
          
        Case #GADGET_StructureViewer_Cancel
          If MemorizeWindow
            StructureViewerX      = WindowX(#WINDOW_StructureViewer)
            StructureViewerY      = WindowY(#WINDOW_StructureViewer)
            StructureViewerWidth  = WindowWidth(#WINDOW_StructureViewer)
            StructureViewerHeight = WindowHeight(#WINDOW_StructureViewer)
          EndIf
          CloseWindow(#WINDOW_StructureViewer)
          
          
        Case #GADGET_StructureViewer_OnTop
          StructureViewerStayOnTop = GetGadgetState(#GADGET_StructureViewer_OnTop)
          SetWindowStayOnTop(#WINDOW_StructureViewer, StructureViewerStayOnTop)
          
          
        Case #GADGET_StructureViewer_InsertName
          If *ActiveSource <> *ProjectInfo
            index = GetGadgetState(#GADGET_StructureViewer_List)
            If index <> -1
              If StructureViewerMode = 2
                InsertCodeString(ConstantList(index + ConstantHT(CurrentDisplayChar, 0)))
              Else
                If IsRootDisplay
                  InsertCodeString("." + GetGadgetItemText(#GADGET_StructureViewer_List, index, 0))
                Else
                  InsertCodeString("." + StructureHistory()\Name$)
                EndIf
              EndIf
            EndIf
          EndIf
          
          
        Case #GADGET_StructureViewer_InsertCopy
          If *ActiveSource <> *ProjectInfo
            index = GetGadgetState(#GADGET_StructureViewer_List)
            If StructureViewerMode = 2
              If index <> -1
                InsertCodeString(GetGadgetItemText(#GADGET_StructureViewer_List, index, 0))
              EndIf
            Else
              GetCursorPosition()
              intend = *ActiveSource\CurrentColumnChars-1
              Line$ = GetCurrentLine()
              
              While intend > 0 And Left(Line$, 1) = Chr(9) Or Left(Line$, 1) = " "
                intend - 1
                Intend$ + Left(Line$, 1)
                Line$ = Right(Line$, Len(Line$)-1)
              Wend
              
              If intend > 0
                If RealTab
                  Intend$ + RSet("", (intend / TabLength), Chr(9))
                  If intend % TabLength <> 0
                    Intend$ + Space(intend % TabLength)
                  EndIf
                Else
                  Intend$ + Space(intend)
                EndIf
              EndIf
              
              If RealTab
                ExtraIntend$ = Chr(9)
              Else
                ExtraIntend$ = Space(TabLength)
              EndIf
              
              InsertCodeString(GetGadgetItemText(#GADGET_StructureViewer_List, 0, 0)+#NewLine)
              For i = 1 To CountGadgetItems(#GADGET_StructureViewer_List)-2
                InsertCodeString(Intend$ + ExtraIntend$ + Trim(GetGadgetItemText(#GADGET_StructureViewer_List, i, 0)) +#NewLine)
              Next i
              InsertCodeString(Intend$ + GetGadgetItemText(#GADGET_StructureViewer_List, CountGadgetItems(#GADGET_StructureViewer_List)-1, 0)+#NewLine)
            EndIf
          EndIf
          
          
        Case #GADGET_StructureViewer_InsertStruct
          If *ActiveSource <> *ProjectInfo
            If StructureViewerMode = 0
              Var$ = InputRequester(Language("StructureViewer","GetVarName"), Language("StructureViewer","InputVarName"), Language("StructureViewer","DefaultVar"))
              If Var$ <> ""
                GetCursorPosition()
                intend = *ActiveSource\CurrentColumnChars-1
                Line$ = GetCurrentLine()
                
                While intend > 0 And Left(Line$, 1) = Chr(9) Or Left(Line$, 1) = " "
                  intend - 1
                  Intend$ + Left(Line$, 1)
                  Line$ = Right(Line$, Len(Line$)-1)
                Wend
                
                If intend > 0
                  If RealTab
                    Intend$ + RSet("", (intend / TabLength), Chr(9))
                    If intend % TabLength <> 0
                      Intend$ + Space(intend % TabLength)
                    EndIf
                  Else
                    Intend$ + Space(intend)
                  EndIf
                EndIf
                
                InsertCodeString(Var$ + "." + StructureHistory()\Name$+#NewLine)
                
                ; find longest line
                length = 0
                For i = 1 To CountGadgetItems(#GADGET_StructureViewer_List)-2
                  Line$ =  LTrim(Trim(GetGadgetItemText(#GADGET_StructureViewer_List, i, 0)), "*") ; We need to remove the '*' when inserting the item.
                  newlength = FindString(Line$, ".", 1) - 1
                  If FindString(Line$, "[", 1) <> 0
                    newlength + Len(Line$) - FindString(Line$, "[", 1) + 1
                  EndIf
                  If newlength > length
                    length = newlength
                  EndIf
                Next i
                
                ; output the lines
                For i = 1 To CountGadgetItems(#GADGET_StructureViewer_List)-2
                  Line$ = LTrim(Trim(GetGadgetItemText(#GADGET_StructureViewer_List, i, 0)), "*") ; We need to remove the '*' when inserting the item.
                  Field$ = Left(Line$, FindString(Line$, ".", 1)-1)
                  
                  If FindString(Line$, "[", 1) <> 0
                    Field$ + "[" + RSet("0", Len(Line$) - FindString(Line$, "[", 1) - 1) + "]"
                  EndIf
                  
                  InsertCodeString(Intend$ + Var$ + "\" + LSet(Field$, length) + " = " + #NewLine)
                Next i
                
              EndIf
            EndIf
          EndIf
          
        Default
          If IsRootDisplay And EventGadgetID >= #GADGET_StructureViewer_Char0 And EventGadgetID <= #GADGET_StructureViewer_Char27
            If GetGadgetState(EventGadgetID) = 0  ; can't unset the current one
              SetGadgetState(EventGadgetID, 1)
            Else
              CurrentDisplayChar = EventGadgetID - #GADGET_StructureViewer_Char0
              DisplayStructureRootList()
            EndIf
          EndIf
          
      EndSelect
      
  EndSelect
  
EndProcedure
