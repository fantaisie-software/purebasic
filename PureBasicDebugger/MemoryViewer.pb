; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------
Global Dim MemoryViewer_Chars.s(31)

#MEMORY_VIEW_TABLE_DATA_DEC = 0
#MEMORY_VIEW_TABLE_DATA_HEX = 1
#MEMORY_VIEW_TABLE_DATA_OCT = 2

Global MemoryViewTableData.i

Procedure.s OCT(number.q)
  Protected Oct.s=Space(23)
  For a = 22 To 0 Step -1
    PokeS(@Oct+a*SizeOf(Character),Str(number & 7),SizeOf(Character),#PB_String_NoZero)
    number >> 3
  Next
  Oct = LTrim(Oct,"0")
  If Oct = ""
    Oct = "0"
  EndIf
  ProcedureReturn Oct
EndProcedure

;Wrappers to simplify the handling of the different variable types.
Prototype.s MemoryViewer_PeekVal(*Pointer)

Procedure.s MemoryViewer_PeekB(*Pointer)
  Select MemoryViewTableData
    Case #MEMORY_VIEW_TABLE_DATA_HEX
      ProcedureReturn "$" + RSet(Hex(PeekB(*Pointer),#PB_Byte),2,"0")
    Case #MEMORY_VIEW_TABLE_DATA_DEC
      ProcedureReturn Str(PeekB(*Pointer))
    Case #MEMORY_VIEW_TABLE_DATA_OCT
      ProcedureReturn OCT(PeekB(*Pointer) & $FF)
  EndSelect
EndProcedure

Procedure.s MemoryViewer_PeekCA(*Pointer)
  Select MemoryViewTableData
    Case #MEMORY_VIEW_TABLE_DATA_HEX
      ProcedureReturn "$"+ RSet(Hex(PeekB(*Pointer) & $FF,#PB_Byte),2,"0")
    Case #MEMORY_VIEW_TABLE_DATA_DEC
      ProcedureReturn Str(PeekB(*Pointer) & $FF)
    Case #MEMORY_VIEW_TABLE_DATA_OCT
      ProcedureReturn OCT(PeekB(*Pointer) & $FF)
  EndSelect
EndProcedure

Procedure.s MemoryViewer_PeekCU(*Pointer)
  Select MemoryViewTableData
    Case #MEMORY_VIEW_TABLE_DATA_HEX
      ProcedureReturn "$" + RSet(Hex(PeekW(*Pointer) & $FFFF,#PB_Word),4,"0")
    Case #MEMORY_VIEW_TABLE_DATA_DEC
      ProcedureReturn Str(PeekW(*Pointer) & $FFFF)
    Case #MEMORY_VIEW_TABLE_DATA_OCT
      ProcedureReturn OCT(PeekW(*Pointer) & $FFFF)
  EndSelect
EndProcedure

Procedure.s MemoryViewer_PeekW(*Pointer)
  Select MemoryViewTableData
    Case #MEMORY_VIEW_TABLE_DATA_HEX
      ProcedureReturn "$" + RSet(Hex(PeekW(*Pointer),#PB_Word),4,"0")
    Case #MEMORY_VIEW_TABLE_DATA_DEC
      ProcedureReturn Str(PeekW(*Pointer))
    Case #MEMORY_VIEW_TABLE_DATA_OCT
      ProcedureReturn OCT(PeekW(*Pointer) & $FFFF)
  EndSelect
EndProcedure

Procedure.s MemoryViewer_PeekL(*Pointer)
  Select MemoryViewTableData
    Case #MEMORY_VIEW_TABLE_DATA_HEX
      ProcedureReturn "$" + RSet(Hex(PeekL(*Pointer),#PB_Long),8,"0")
    Case #MEMORY_VIEW_TABLE_DATA_DEC
      ProcedureReturn Str(PeekL(*Pointer))
    Case #MEMORY_VIEW_TABLE_DATA_OCT
      ProcedureReturn OCT(PeekL(*Pointer) & $FFFFFFFF)
  EndSelect
EndProcedure

Procedure.s MemoryViewer_PeekQ(*Pointer)
  Select MemoryViewTableData
    Case #MEMORY_VIEW_TABLE_DATA_HEX
      ProcedureReturn "$" + RSet(Hex(PeekQ(*Pointer),#PB_Quad),16,"0")
    Case #MEMORY_VIEW_TABLE_DATA_DEC
      ProcedureReturn Str(PeekQ(*Pointer))
    Case #MEMORY_VIEW_TABLE_DATA_OCT
      ProcedureReturn OCT(PeekQ(*Pointer))
  EndSelect
EndProcedure

Procedure.s MemoryViewer_PeekF(*Pointer)
  Select MemoryViewTableData
    Case #MEMORY_VIEW_TABLE_DATA_HEX
      ProcedureReturn "$" + RSet(Hex(PeekL(*Pointer),#PB_Long),8,"0")
    Case #MEMORY_VIEW_TABLE_DATA_DEC
      ProcedureReturn StrF(PeekF(*Pointer))
    Case #MEMORY_VIEW_TABLE_DATA_OCT
      ProcedureReturn OCT(PeekL(*Pointer) & $FFFFFFFF)
  EndSelect
EndProcedure

Procedure.s MemoryViewer_PeekD(*Pointer)
  Select MemoryViewTableData
    Case #MEMORY_VIEW_TABLE_DATA_HEX
      ProcedureReturn "$" + RSet(Hex(PeekQ(*Pointer),#PB_Quad),16,"0")
    Case #MEMORY_VIEW_TABLE_DATA_DEC
      ProcedureReturn StrD(PeekD(*Pointer))
    Case #MEMORY_VIEW_TABLE_DATA_OCT
      ProcedureReturn OCT(PeekQ(*Pointer))
  EndSelect
EndProcedure

Procedure MemoryViewer_Table(*Debugger.DebuggerData, VariableSize, PeekVal.MemoryViewer_PeekVal)
  
  If MemoryOneColumnOnly
    *Pointer = *Debugger\MemoryDump
    *BufferEnd = *Debugger\MemoryDump + *Debugger\MemoryDumpSize - (VariableSize - 1)
    
    While *Pointer < *BufferEnd
      ; in table view, we have only offsets, so no 16chars for 64bits needed
      AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_List], -1, RSet(Hex(*Pointer-*Debugger\MemoryDump), 8, "0")+":   " + PeekVal(*Pointer))
      *Pointer + VariableSize
    Wend
    
  Else
    
    Columns = (16 / VariableSize)
    Width   = (GadgetWidth(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_List]) - 110) / Columns
    If Width < 40
      Width = 40
    EndIf
    
    For i = 0 To Columns-1
      AddGadgetColumn(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_List], i+1, Hex(i * VariableSize), Width)
    Next i
    
    *Pointer = *Debugger\MemoryDump
    *BufferEnd = *Debugger\MemoryDump + *Debugger\MemoryDumpSize
    
    ; output full lines
    ;
    While *Pointer < *BufferEnd - 15
      Line$ = RSet(Hex(*Pointer-*Debugger\MemoryDump), 8, "0")
      
      For i = 1 To columns
        Line$ + Chr(10) + PeekVal(*Pointer)
        *Pointer + VariableSize
      Next i
      AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_List], -1, Line$)
    Wend
    
    ; output last line
    If *Pointer < *BufferEnd - (VariableSize - 1)
      Line$ = RSet(Hex(*Pointer-*Debugger\MemoryDump), 8, "0")
      
      While *Pointer < *BufferEnd - (VariableSize - 1)
        Line$ + Chr(10) + PeekVal(*Pointer)
        *Pointer + VariableSize
      Wend
      AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_List], -1, Line$)
    EndIf
    
  EndIf
  
EndProcedure


Procedure MemoryViewer_Hex(*Debugger.DebuggerData)
  
  ; allocate a buffer to prepare the text
  *Buffer = AllocateMemory(((*Debugger\MemoryDumpSize / 16 + 2) * 85) * #CharSize)
  
  If *Buffer
    *OutPointer.Character = *Buffer
    CopyMemoryString("", @*OutPointer)
    
    *Pointer.BYTE = *Debugger\MemoryDump
    *BufferEnd = *Debugger\MemoryDump + *Debugger\MemoryDumpSize
    Location.q = *Debugger\MemoryDumpStart
    
    ; output all full line outputs
    While *Pointer < *BufferEnd - 15  ; at least one full line left to output
      If *Debugger\Is64bit
        HexData$ = RSet(Hex(Location, #PB_Quad), 16, "0") + "  "
      Else
        HexData$ = RSet(Hex(Location, #PB_Long), 8, "0") + "  "
      EndIf
      
      String$ = " "
      
      For i = 0 To 15
        HexData$ + RSet(Hex(*Pointer\b & $FF, #PB_Byte), 2, "0") + " "
        
        If *Pointer\b & $FF < 32
          String$ + "."
        Else
          String$ + Chr(*Pointer\b & $FF)
        EndIf
        
        *Pointer + 1
      Next i
      
      CopyMemoryString(HexData$)
      CopyMemoryString(String$)
      CopyMemoryString(#NewLine)
      Location + 16
    Wend
    
    ; output any last part line
    If *Pointer < *BufferEnd
      If *Debugger\Is64bit
        HexData$ = RSet(Hex(Location, #PB_Quad), 16, "0") + "  "
      Else
        HexData$ = RSet(Hex(Location, #PB_Long), 8, "0") + "  "
      EndIf
      
      String$ = " "
      
      While *Pointer < *BufferEnd
        HexData$ + RSet(Hex(*Pointer\b & $FF, #PB_Byte), 2, "0") + " "
        
        If *Pointer\b & $FF < 32
          String$ + "."
        Else
          String$ + Chr(*Pointer\b & $FF)
        EndIf
        
        *Pointer + 1
      Wend
      
      If *Debugger\Is64bit
        HexData$ = LSet(HexData$, 66, " ")
      Else
        HexData$ = LSet(HexData$, 58, " ")
      EndIf
      
      CopyMemoryString(HexData$)
      CopyMemoryString(String$)
      CopyMemoryString(#NewLine)
    EndIf
    
    ; output the Result
    ;
    SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Editor], PeekS(*Buffer, (*OutPointer-*Buffer)/#CharSize))
    FreeMemory(*Buffer)
    
  EndIf
  
EndProcedure


; Works for ascii and UTF8 as well, as only the peeks part is different.
;
Procedure MemoryViewer_AsciiUtf8(*Debugger.DebuggerData, Mode)
  
  ; calculate required buffer size
  ;
  Size = *Debugger\MemoryDumpSize
  *Pointer.BYTE = *Debugger\MemoryDump
  *BufferEnd    = *Debugger\MemoryDump + *Debugger\MemoryDumpSize
  
  While *Pointer < *BufferEnd
    If *Pointer\b >= 0 And *Pointer\b < 32 ; a special char
      Size + Len(MemoryViewer_Chars(*Pointer\b)) - 1 ; subtract the 1 byte calculated before
      If *Pointer\b = 0 Or *Pointer\b = 10 Or *Pointer\b = 13
        Size + Len(#NewLine) ; we add a newline after linefeed and NULL for an easier string view
      EndIf
    EndIf
    *Pointer + 1
  Wend
  
  *Buffer = AllocateMemory(Size + 1) ; leave some space for the added 0!
  
  ; fill the buffer
  ;
  If *Buffer
    *Pointer      = *Debugger\MemoryDump
    *Output.BYTE  = *Buffer
    
    While *Pointer < *BufferEnd
      If *Pointer\b >= 0 And *Pointer\b < 32 ; a special char
        PokeS(*Output, MemoryViewer_Chars(*Pointer\b), -1, #PB_Ascii)
        *Output + Len(MemoryViewer_Chars(*Pointer\b))
        
        ; add one newline after line feed or NULL
        If *Pointer\b = 0 Or *Pointer\b = 10 Or (*Pointer\b = 13 And PeekB(*Pointer+1) <> 10)
          PokeS(*Output, #NewLine, -1, #PB_Ascii)
          *Output + Len(#NewLine)
        EndIf
      Else
        *Output\b = *Pointer\b
        *Output + 1
      EndIf
      
      *Pointer + 1
    Wend
    *Output\b = 0
    
    SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Editor], PeekS(*Buffer, -1, Mode))
    FreeMemory(*Buffer)
  EndIf
  
EndProcedure

Procedure MemoryViewer_Unicode(*Debugger.DebuggerData)
  
  ; calculate required buffer size
  ;
  Size = *Debugger\MemoryDumpSize / 2
  *Pointer.WORD = *Debugger\MemoryDump
  *BufferEnd    = *Debugger\MemoryDump + *Debugger\MemoryDumpSize
  
  If *Debugger\MemoryDumpSize % 2 = 1 ; safeguard against uneven buffer sizes
    *BufferEnd - 1
  EndIf
  
  While *Pointer < *BufferEnd
    If *Pointer\w >= 0 And *Pointer\w < 32 ; a special char
      Size + Len(MemoryViewer_Chars(*Pointer\w)) - 1 ; subtract the 1 byte calculated before
      If *Pointer\w = 0 Or *Pointer\w = 10 Or *Pointer\w = 13
        Size + Len(#NewLine) ; we add a newline after linefeed and NULL for an easier string view
      EndIf
    EndIf
    *Pointer + 2
  Wend
  
  *Buffer = AllocateMemory(Size * 2 + 2) ; leave some space for the added 0!
  
  ; fill the buffer
  ;
  If *Buffer
    *Pointer      = *Debugger\MemoryDump
    *Output.WORD  = *Buffer
    
    While *Pointer < *BufferEnd
      If *Pointer\w >= 0 And *Pointer\w < 32 ; a special char
        PokeS(*Output, MemoryViewer_Chars(*Pointer\w), -1, #PB_Unicode)
        *Output + Len(MemoryViewer_Chars(*Pointer\w)) * 2
        
        ; add one newline after line feed or NULL
        If *Pointer\w = 0 Or *Pointer\w = 10 Or (*Pointer\w = 13 And PeekW(*Pointer+1) <> 10)
          PokeS(*Output, #NewLine, -1, #PB_Unicode)
          *Output + Len(#NewLine) * 2
        EndIf
      Else
        *Output\w = *Pointer\w
        *Output + 2
      EndIf
      
      *Pointer + 2
    Wend
    *Output\w = 0
    
    SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Editor], PeekS(*Buffer, -1, #PB_Unicode))
    FreeMemory(*Buffer)
  EndIf
  
EndProcedure

Procedure MemoryViewer_Update(*Debugger.DebuggerData, Action, File) ; 0=display only, 1=display+copy to clipboard, 2=display+save to file
  Protected Datatype.s, OptExportDS=1
  ViewType = GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_ViewType])
  OptExportDS = GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_ChkformatDataSection])
  
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Editor], Language("Debugger","NoData"))
  
  If ViewType = 0 Or ViewType >= 8 ; hex display or string display
    ClearGadgetItems(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_List])
    
    HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Container], 1)
    HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Editor], 0)
    
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Display_DataView],1)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_ChkformatDataSection],1)
  Else
    FreeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_List]) ; recreate this to change the number of columns
    OpenGadgetList(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Container])
    If MemoryOneColumnOnly
      *Debugger\Gadgets[#DEBUGGER_GADGET_Memory_List] = ListViewGadget(#PB_Any, 0, 0, WindowWidth(*Debugger\Windows[#DEBUGGER_WINDOW_Memory])-20, WindowHeight(*Debugger\Windows[#DEBUGGER_WINDOW_Memory])-90)
    Else
      *Debugger\Gadgets[#DEBUGGER_GADGET_Memory_List] = ListIconGadget(#PB_Any, 0, 0, WindowWidth(*Debugger\Windows[#DEBUGGER_WINDOW_Memory])-20, WindowHeight(*Debugger\Windows[#DEBUGGER_WINDOW_Memory])-90, "", 80, #PB_ListIcon_GridLines|#PB_ListIcon_FullRowSelect|#PB_ListIcon_MultiSelect)
    EndIf
    CloseGadgetList()
    
    HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Container], 0)
    HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Editor], 1)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Display_DataView],0)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_ChkformatDataSection],0)
  EndIf
  
  Select ViewType
    Case  0: MemoryViewer_Hex(*Debugger)
    Case  1: MemoryViewer_Table(*Debugger, 1, @MemoryViewer_PeekB()): Columns = 16 : Datatype="Data.b "
      
    Case  2 ; Character must work according to the exe mode
      If *Debugger\IsUnicode = 0
        MemoryViewer_Table(*Debugger, 1, @MemoryViewer_PeekCA()): Columns = 16 : Datatype="Data.a "
      Else
        MemoryViewer_Table(*Debugger, 2, @MemoryViewer_PeekCU()): Columns = 8  : Datatype="Data.u "
      EndIf
      
    Case  3: MemoryViewer_Table(*Debugger, 2, @MemoryViewer_PeekW()): Columns = 8 : Datatype="Data.w "
    Case  4: MemoryViewer_Table(*Debugger, 4, @MemoryViewer_PeekL()): Columns = 4 : Datatype="Data.l "
    Case  5: MemoryViewer_Table(*Debugger, 8, @MemoryViewer_PeekQ()): Columns = 2 : Datatype="Data.q "
    Case  6: MemoryViewer_Table(*Debugger, 4, @MemoryViewer_PeekF())
      Columns = 4
      If MemoryViewTableData = #MEMORY_VIEW_TABLE_DATA_DEC
        Datatype="Data.f "
      Else
        Datatype="Data.l "
      EndIf
    Case  7: MemoryViewer_Table(*Debugger, 8, @MemoryViewer_PeekD())
      Columns = 2
      If MemoryViewTableData = #MEMORY_VIEW_TABLE_DATA_DEC
        Datatype="Data.d "
      Else
        Datatype="Data.q "
      EndIf
    Case  8: MemoryViewer_AsciiUtf8(*Debugger, #PB_Ascii)
    Case  9: MemoryViewer_Unicode(*Debugger)
    Case 10: MemoryViewer_AsciiUtf8(*Debugger, #PB_UTF8)
  EndSelect
  
  
  If Action <> 0
    
    If ViewType > 0 And ViewType < 8 ; table view
      
      Text$ = ""
      Count = CountGadgetItems(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_List])
      
      If MemoryOneColumnOnly
        
        For i = 0 To Count-1
          Text$ + GetGadgetItemText(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_List], i, 0) + #NewLine
        Next i
        
      Else
        
        For i = 0 To Count-1
          If OptExportDS
            Text$ + Datatype
          Else
            Text$ + GetGadgetItemText(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_List], i, 0)
          EndIf
          For c = 1 To Columns
            If OptExportDS
              Text$ + GetGadgetItemText(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_List], i, c)
              If c < Columns
                Text$ + ","
              EndIf
            Else
              Text$ + Chr(9) + GetGadgetItemText(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_List], i, c)
            EndIf
          Next c
          Text$ + #NewLine
        Next i
        
      EndIf
      
    Else
      Text$ = GetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Editor])
    EndIf
    
    If Action = 1 ; Clipboard
      SetClipboardText(Text$)
      
    ElseIf Action = 2 ; File
      
      If ViewType = 9 ; Unicode
        WriteStringFormat(File, #PB_Unicode)
        WriteString(File, Text$, #PB_Unicode)
        
      ElseIf ViewType = 10 ; Utf8
        WriteStringFormat(File, #PB_UTF8)
        WriteString(File, Text$, #PB_UTF8)
        
      Else ; normal text
        WriteString(File, Text$)
      EndIf
      
    EndIf
    
  EndIf
  
EndProcedure

Procedure MemoryViewerWindowEvents(*Debugger.DebuggerData, EventID)
  
  If EventID = #PB_Event_Gadget
    Select EventGadget()
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Display_DataView]
        If EventType() = #PB_EventType_Change
          MemoryViewTableData = GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Display_DataView])
          If *Debugger\MemoryDump ; is there any data ?
            MemoryViewer_Update(*Debugger, 0, 0)
          EndIf
        EndIf
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Display]
        Command.CommandInfo\Command = #COMMAND_GetMemory
        
        AddrFrom$ = Trim(GetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Start]))
        AddrTo$   = Trim(GetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_End]))
        
        If Left(AddrTo$, 1) = "+"
          AddrTo$ = Right(AddrTo$, Len(AddrTo$)-1)
          Command\Value1 = 1 ; relative address
        Else
          Command\Value1 = 0 ; absolute address
        EndIf
        
        All$ = AddrFrom$ + " " + AddrTo$
        PokeC(@All$ + Len(AddrFrom$) * SizeOf(Character), 0) ; put a 0 between the two
        
        Command\DataSize = (Len(AddrFrom$) + Len(AddrTo$) + 2) * SizeOf(Character)
        SendDebuggerCommandWithData(*Debugger, @Command, @All$)
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Memory_ViewType]
        If *Debugger\MemoryDump ; is there any data ?
          MemoryViewer_Update(*Debugger, 0, 0)
        EndIf
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Memory_CopyText]
        If *Debugger\MemoryDump ; is there any data ?
          MemoryViewer_Update(*Debugger, 1, 0)
        EndIf
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Memory_SaveText]
        If *Debugger\MemoryDump ; is there any data ?
          FileName$ = CurrentDirectory$
          Repeat
            FileName$ = SaveFileRequester(Language("Debugger","SaveFileTitle"), FileName$, Language("Debugger","SaveFilePattern"), 1)
            If FileName$ = ""
              Break
            EndIf
            
            If FileSize(FileName$) <> -1
              Result = MessageRequester("PureBasic Debugger",Language("FileStuff","FileExists")+#NewLine+Language("FileStuff","OverWrite"), #FLAG_Warning|#PB_MessageRequester_YesNoCancel)
              If Result = #PB_MessageRequester_Cancel
                Break ; abort
              ElseIf Result = #PB_MessageRequester_No
                Continue ; ask again
              EndIf
            EndIf
            
            File = CreateFile(#PB_Any, FileName$)
            If File
              MemoryViewer_Update(*Debugger, 2, File)
              CloseFile(File)
            Else
              MessageRequester("PureBasic Debugger",ReplaceString(Language("Debugger","SaveError"), "%filename%", FileName$, 1), #FLAG_Error)
            EndIf
            
            Break ; if we got here, then do not try again
          ForEver
        EndIf
        
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Memory_SaveRaw]
        If *Debugger\MemoryDump ; is there any data ?
          FileName$ = MemoryViewerFile$
          Repeat
            FileName$ = SaveFileRequester(Language("Debugger","SaveFileTitle"), FileName$, Language("Debugger","SaveFilePattern"), 1)
            If FileName$ = ""
              Break
            EndIf
            
            ; auto-add extension
            If GetExtensionPart(FileName$) = "" And SelectedFilePattern() = 0
              FileName$ + ".txt"
            EndIf
            
            If FileSize(FileName$) <> -1
              Result = MessageRequester("PureBasic Debugger",Language("FileStuff","FileExists")+#NewLine+Language("FileStuff","OverWrite"), #FLAG_Warning|#PB_MessageRequester_YesNoCancel)
              If Result = #PB_MessageRequester_Cancel
                Break ; abort
              ElseIf Result = #PB_MessageRequester_No
                Continue ; ask again
              EndIf
            EndIf
            
            File = CreateFile(#PB_Any, FileName$)
            If File
              WriteData(File, *Debugger\MemoryDump, *Debugger\MemoryDumpSize)
              CloseFile(File)
              MemoryViewerFile$ = FileName$ ; store for next use
            Else
              MessageRequester("PureBasic Debugger",ReplaceString(Language("Debugger","SaveError"), "%filename%", FileName$, 1), #FLAG_Error)
            EndIf
            
            Break ; if we got here, then do not try again
          ForEver
        EndIf
        
    EndSelect
    
  ElseIf EventID = #PB_Event_SizeWindow
    Width  = WindowWidth (*Debugger\Windows[#DEBUGGER_WINDOW_Memory])
    Height = WindowHeight(*Debugger\Windows[#DEBUGGER_WINDOW_Memory])
    
    GetRequiredSize(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Display], @DisplayWidth, @ButtonHeight)
    DisplayWidth = Max(DisplayWidth, 100)
    TextWidth    = Max(65, GetRequiredWidth(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Text]))
    
    ButtonHeight = Max(ButtonHeight, GetRequiredHeight(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_ViewType]))
    DataWidth    = MAX(100, GetRequiredWidth(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_ChkformatDataSection]))
    CopyWidth    = Max(100, GetRequiredWidth(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_CopyText]))
    SaveWidth    = Max(100, GetRequiredWidth(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_SaveText]))
    SaveRawWidth = Max(100, GetRequiredWidth(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_SaveRaw]))
    
    If Width >= TextWidth+DisplayWidth+335
      ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Text],    10, 10, TextWidth, ButtonHeight)
      ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Start],   15+TextWidth, 10, 140, ButtonHeight)
      ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_To],      155+TextWidth, 10, 20, ButtonHeight)
      ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_End],     175+TextWidth, 10, 140, ButtonHeight)
      ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Display], 325+TextWidth, 10, DisplayWidth, ButtonHeight)
    Else
      ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Text],     10, 10, (Width-50)/7-5, ButtonHeight)
      ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Start],    10+(Width-50)/7, 10, ((Width-50)*2)/7, ButtonHeight)
      ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_To],       10+((Width-50)*3)/7, 10, 20, ButtonHeight)
      ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_End],      30+((Width-50)*3)/7, 10, ((Width-50))/7, ButtonHeight)
      ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Display],  40+((Width-50)*5)/7, 10, ((Width-50))/7, ButtonHeight)
    EndIf
    
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Editor], 10, 20+ButtonHeight, Width-20, Height-40-2*ButtonHeight)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Container], 10, 20+ButtonHeight, Width-20, Height-40-2*ButtonHeight)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_List], 0, 0, Width-20, Height-40-2*ButtonHeight)
    
    Y = Height - 10 - ButtonHeight
    If Width >= CopyWidth+SaveWidth+SaveRawWidth+250
      ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_ViewType], 10, Y, 150, ButtonHeight)
      ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Display_DataView], 170, Y, DisplayWidth, ButtonHeight)
      ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_ChkformatDataSection],width-40-SaveRawWidth-SaveWidth-CopyWidth-DataWidth,Y,DataWidth,ButtonHeight)
      ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_CopyText], Width-30-SaveRawWidth-SaveWidth-CopyWidth, Y, CopyWidth, ButtonHeight)
      ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_SaveText], Width-20-SaveRawWidth-SaveWidth, Y, SaveWidth, ButtonHeight)
      ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_SaveRaw], Width-10-SaveRawWidth, Y, SaveRawWidth, ButtonHeight)
    Else
      ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_ViewType], 10, Y, (Width-50)/6, ButtonHeight)
      ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Display_DataView], 20+((Width-50))/6, Y, (Width-50)/6, ButtonHeight)
      ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_ChkformatDataSection],30+((Width-50)*2)/6,Y,(Width-50)/6,ButtonHeight)
      ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_CopyText], 40+((Width-50)*3)/6, Y, (Width-50)/6, ButtonHeight)
      ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_SaveText], 50+((Width-50)*4)/6, Y, (Width-50)/6, ButtonHeight)
      ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_SaveRaw], 60+((Width-50)*5)/6, Y, (Width-50)/6, ButtonHeight)
    EndIf
    
  ElseIf EventID = #PB_Event_CloseWindow
    
    If DebuggerMemorizeWindows And IsWindowMinimized(*Debugger\Windows[#DEBUGGER_WINDOW_Memory]) = 0
      MemoryViewerMaximize = IsWindowMaximized(*Debugger\Windows[#DEBUGGER_WINDOW_Memory])
      If MemoryViewerMaximize = 0
        MemoryViewerX = WindowX(*Debugger\Windows[#DEBUGGER_WINDOW_Memory])
        MemoryViewerY = WindowY(*Debugger\Windows[#DEBUGGER_WINDOW_Memory])
        MemoryViewerWidth  = WindowWidth (*Debugger\Windows[#DEBUGGER_WINDOW_Memory])
        MemoryViewerHeight = WindowHeight(*Debugger\Windows[#DEBUGGER_WINDOW_Memory])
      EndIf
    EndIf
    MemoryDisplayType = GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_ViewType])
    
    If *Debugger\MemoryDump  ; free any displayed buffer
      FreeMemory(*Debugger\MemoryDump)
      *Debugger\MemoryDump = 0
    EndIf
    
    CloseWindow(*Debugger\Windows[#DEBUGGER_WINDOW_Memory])
    *Debugger\Windows[#DEBUGGER_WINDOW_Memory] = 0
    Debugger_CheckDestroy(*Debugger)
    
  EndIf
  
EndProcedure

Procedure UpdateMemoryViewerWindowState(*Debugger.DebuggerData)
  
  If *Debugger\ProgramState = -1 ; exe not loaded
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Start], 1)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_End], 1)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Display], 1)
  Else
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Start], 0)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_End], 0)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Display], 0)
  EndIf
  
EndProcedure

Procedure OpenMemoryViewerWindow(*Debugger.DebuggerData)
  
  MemoryViewTableData = MemoryIsHex
  
  If *Debugger\Windows[#DEBUGGER_WINDOW_Memory]
    SetWindowForeground(*Debugger\Windows[#DEBUGGER_WINDOW_Memory])
    
  Else
    Window = OpenWindow(#PB_Any, MemoryViewerX, MemoryViewerY, MemoryViewerWidth, MemoryViewerHeight, Language("Debugger","MemoryWindowTitle") + " - " + DebuggerTitle(*Debugger\FileName$), #PB_Window_SystemMenu|#PB_Window_SizeGadget|#PB_Window_MinimizeGadget|#PB_Window_Invisible|#PB_Window_MaximizeGadget)
    If Window
      *Debugger\Windows[#DEBUGGER_WINDOW_Memory] = Window
      
      *Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Text]     = TextGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","Range")+":", #PB_Text_Right)
      *Debugger\Gadgets[#DEBUGGER_GADGET_Memory_To]       = TextGadget(#PB_Any, 0, 0, 0, 0, "-", #PB_Text_Center)
      *Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Start]    = StringGadget(#PB_Any, 0, 0, 0, 0, "")
      *Debugger\Gadgets[#DEBUGGER_GADGET_Memory_End]      = StringGadget(#PB_Any, 0, 0, 0, 0, "")
      *Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Display]  = ButtonGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","Display"))
      *Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Editor]   = EditorGadget(#PB_Any, 0, 0, 0, 0)
      *Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Container]= ContainerGadget(#PB_Any, 0, 0, 0, 0, #PB_Container_BorderLess)
      *Debugger\Gadgets[#DEBUGGER_GADGET_Memory_List]     = ListIconGadget(#PB_Any, 0, 0, 0, 0, "", 80, #PB_ListIcon_GridLines|#PB_ListIcon_FullRowSelect|#PB_ListIcon_MultiSelect)
      CloseGadgetList()
      *Debugger\Gadgets[#DEBUGGER_GADGET_Memory_ViewType] = ComboBoxGadget(#PB_Any, 0, 0, 0, 0)
      *Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Display_DataView] = ComboBoxGadget(#PB_Any, 0, 0, 0, 0)
      
      AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Display_DataView],0,"DEC")
      AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Display_DataView],1,"HEX")
      AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Display_DataView],2,"OCT")
      SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Display_DataView],MemoryViewTableData)
      
      *Debugger\Gadgets[#DEBUGGER_GADGET_Memory_ChkformatDataSection] = CheckBoxGadget(#PB_Any,0,0,0,0,"Data")
      *Debugger\Gadgets[#DEBUGGER_GADGET_Memory_CopyText] = ButtonGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","CopyText"))
      *Debugger\Gadgets[#DEBUGGER_GADGET_Memory_SaveText] = ButtonGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","SaveText"))
      *Debugger\Gadgets[#DEBUGGER_GADGET_Memory_SaveRaw]  = ButtonGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","SaveRaw"))
      
      AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_ViewType], -1, Language("Debugger","ViewHex"))
      AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_ViewType], -1, Language("Debugger","ViewByte"))
      AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_ViewType], -1, Language("Debugger","ViewChar"))
      AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_ViewType], -1, Language("Debugger","ViewWord"))
      AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_ViewType], -1, Language("Debugger","ViewLong"))
      AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_ViewType], -1, Language("Debugger","ViewQuad"))
      AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_ViewType], -1, Language("Debugger","ViewFloat"))
      AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_ViewType], -1, Language("Debugger","ViewDouble"))
      AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_ViewType], -1, Language("Debugger","ViewString") + " (Ascii)")
      AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_ViewType], -1, Language("Debugger","ViewString") + " (Unicode)")
      AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_ViewType], -1, Language("Debugger","ViewString") + " (Utf-8)")
      SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_ViewType], MemoryDisplayType)
      
      HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Container], 1)
      
      If EditorFontID
        SetGadgetFont(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Editor], EditorFontID)
      EndIf
      SetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Editor], #PB_Editor_ReadOnly, 1)
      
      CompilerIf #DEFAULT_CanWindowStayOnTop
        SetWindowStayOnTop(Window, DebuggerOnTop)
      CompilerEndIf
      
      Debugger_AddShortcuts(Window)
      
      Restore MemoryViewer_SpecialChars
      For i = 0 To 31
        Read.s MemoryViewer_Chars(i)
      Next i
      
      EnsureWindowOnDesktop(Window)
      If MemoryViewerMaximize
        ShowWindowMaximized(Window)
      Else
        HideWindow(Window, 0)
      EndIf
      
      MemoryViewerWindowEvents(*Debugger, #PB_Event_SizeWindow)
      UpdateMemoryViewerWindowState(*Debugger)
      
      Debugger_ProcessEvents(Window, #PB_Event_ActivateWindow) ; makes all debugger windows go to the top
    EndIf
  EndIf
  
EndProcedure

Procedure UpdateMemoryViewerWindow(*Debugger.DebuggerData)
  
  SetWindowTitle(*Debugger\Windows[#DEBUGGER_WINDOW_Memory], Language("Debugger","MemoryWindowTitle") + " - " + GetFilePart(*Debugger\FileName$))
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Text], Language("Debugger","Range")+":")
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Display], Language("Debugger","Display"))
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_ChkformatDataSection],"Data")
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_CopyText], Language("Debugger","CopyText"))
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_SaveText], Language("Debugger","SaveText"))
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_SaveRaw], Language("Debugger","SaveRaw"))
  
  type = GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_ViewType])
  ClearGadgetItems(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_ViewType])
  AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_ViewType], -1, Language("Debugger","ViewHex"))
  AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_ViewType], -1, Language("Debugger","ViewByte"))
  AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_ViewType], -1, Language("Debugger","ViewChar"))
  AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_ViewType], -1, Language("Debugger","ViewWord"))
  AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_ViewType], -1, Language("Debugger","ViewLong"))
  AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_ViewType], -1, Language("Debugger","ViewQuad"))
  AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_ViewType], -1, Language("Debugger","ViewFloat"))
  AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_ViewType], -1, Language("Debugger","ViewDouble"))
  AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_ViewType], -1, Language("Debugger","ViewString") + " (Ascii)")
  AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_ViewType], -1, Language("Debugger","ViewString") + " (Unicode)")
  AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_ViewType], -1, Language("Debugger","ViewString") + " (Utf-8)")
  SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_ViewType], type)
  
  MemoryViewerWindowEvents(*Debugger, #PB_Event_SizeWindow) ; Update gadget sizes
  
EndProcedure

Procedure MemoryViewer_DebuggerEvent(*Debugger.DebuggerData)
  
  If *Debugger\Command\Command = #COMMAND_ControlMemoryViewer
    If *Debugger\Command\Value1 = 1 ; show
      OpenMemoryViewerWindow(*Debugger)
      
    ElseIf *Debugger\Command\Value1 = 2 ; show with data range
      OpenMemoryViewerWindow(*Debugger)
      
      If *Debugger\CommandData
        If *Debugger\Is64bit
          SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Start], StrU(PeekQ(*Debugger\CommandData), #PB_Quad))
          SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_End], "+ "+StrU(PeekQ(*Debugger\CommandData+8), #PB_Quad))
        Else
          SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Start], StrU(PeekL(*Debugger\CommandData), #PB_Long))
          SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_End], "+ "+StrU(PeekL(*Debugger\CommandData+4), #PB_Long))
        EndIf
      EndIf
      
    EndIf
    
    ProcedureReturn     ; do not run the rest of this code
  EndIf
  
  ; ignore further messages when the window is closed
  ;
  If *Debugger\Windows[#DEBUGGER_WINDOW_Memory] = 0
    ProcedureReturn
  EndIf
  
  If *Debugger\Command\Command = #COMMAND_Memory
    
    If *Debugger\Command\Value1 Or *Debugger\Command\Value2; indicates success
      If *Debugger\MemoryDump                              ; free the previous displayed buffer
        FreeMemory(*Debugger\MemoryDump)
      EndIf
      *Debugger\MemoryDump     = *Debugger\CommandData
      *Debugger\MemoryDumpSize = *Debugger\Command\DataSize
      *Debugger\CommandData    = 0 ; do not free this buffer!
      
      If *Debugger\Is64bit
        *Debugger\MemoryDumpStart = PeekQ(@*Debugger\Command\Value1)
      Else
        *Debugger\MemoryDumpStart = PeekL(@*Debugger\Command\Value1)
      EndIf
      
      MemoryViewer_Update(*Debugger, 0, 0)
      
    Else
      ; no data available (invalid memory address or parse error in values)
      ;
      If *Debugger\MemoryDump  ; free the previous displayed buffer
        FreeMemory(*Debugger\MemoryDump)
      EndIf
      *Debugger\MemoryDump = 0
      
      Message$ = Language("Debugger","InvalidMemory")
      
      If *Debugger\Command\DataSize > 0 ; there is a message
        Message$ + #NewLine + #NewLine + "Argument error:" +#NewLine+"  "+ PeekS(*Debugger\CommandData, *Debugger\Command\DataSize, #PB_Ascii)
      EndIf
      
      HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_List], 1)
      HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Editor], 0)
      
      ClearGadgetItems(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_List])
      SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Memory_Editor], Message$)
      
    EndIf
    
  EndIf
  
EndProcedure

DataSection
  
  MemoryViewer_SpecialChars:  ; char 0 - 31
  Data$ "[NULL]","[SOH]", "[STX]", "[ETX]", "[EOT]", "[ENQ]", "[ACK]", "[BEL]"
  Data$ "[BS]" , "[TAB]", "[LF]" , "[VT]" , "[FF]" , "[CR]" , "[SO]" , "[SI]"
  Data$ "[DLE]", "[DC1]", "[DC2]", "[DC3]", "[DC4]", "[NAK]", "[SYN]", "[ETB]"
  Data$ "[CAN]", "[EM]" , "[SUB]", "[ESC]", "[FS]" , "[GS]" , "[RS]" , "[US]"
  
EndDataSection
