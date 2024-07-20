; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

If OpenWindow(0, 0, 0, 800, 600, "LinuxHelp Viewer", #PB_Window_SystemMenu|#PB_Window_SizeGadget|#PB_Window_MinimizeGadget|#PB_Window_MaximizeGadget|#PB_Window_ScreenCentered)
  
  ExplorerListGadget(0, 0, 0, 0, 0, "*.*", #PB_Explorer_AlwaysShowSelection|#PB_Explorer_AutoSort)
  *RichEdit = EditorGadget(1, 0, 0, 0, 0, #ES_READONLY)
  SplitterGadget(2, 5, 5, 790, 590, 0, 1, #PB_Splitter_Vertical|#PB_Splitter_FirstFixed)
  SetGadgetState(2, 200)
  
  SendMessage_(*RichEdit, #EM_SETBKGNDCOLOR, 0, $DFFFFF)
  
  Quit = 0
  Repeat
    Select WaitWindowEvent()
        
      Case #PB_Event_CloseWindow
        Quit = 1
        
      Case #PB_Event_SizeWindow
        ResizeGadget(2, 5, 5, WindowWidth()-10, WindowHeight()-10)
        
      Case #PB_Event_Gadget
        If EventGadget() = 0 And EventType() = #PB_EventType_LeftClick
          If GetGadgetItemState(0, GetGadgetState(0)) & #PB_Explorer_File
            FileName$ = GetGadgetText(0) + GetGadgetItemText(0, GetGadgetState(0), 0)
            Gosub LoadHelpPage
          EndIf
        EndIf
        
    EndSelect
  Until Quit
  
EndIf

End


LoadHelpPage:

ClearGadgetItems(1)

If ReadFile(0, FileName$)
  Length = Lof()
  *Buffer = AllocateMemory(Length)
  
  If *Buffer
    ReadData(*Buffer, Length)
    
    *Cursor.BYTE = *Buffer
    *BufferEnd   = *Buffer + Length
    *StringStart = *Buffer
    
    formatlink.CHARFORMAT\cbSize = SizeOf(CHARFORMAT)
    formatlink\dwMask            = #CFM_COLOR | #CFM_BOLD |  #CFM_FACE
    formatlink\crTextColor       = $E00000
    formatlink\dwEffects         = 0
    PeekS(@formatlink\szFaceName[0], "Times")
    
    format.CHARFORMAT\cbSize = SizeOf(CHARFORMAT)
    format\dwMask            = #CFM_COLOR | #CFM_BOLD |  #CFM_FACE
    format\crTextColor       = $000000
    format\dwEffects         = 0
    PeekS(@format\szFaceName[0], "Times")
    
    PageTitle$ = ""
    
    While *Cursor < *BufferEnd
      If *Cursor\b = '{'
        
        If *Cursor - *StringStart > 0  ; output everything before
          SendMessage_(*RichEdit, #EM_SETCHARFORMAT, #SCF_SELECTION, @format)
          SendMessage_(*RichEdit, #EM_REPLACESEL, 0, PeekS(*StringStart, *Cursor - *StringStart))
          
          If format\yHeight = 16 And  PageTitle$ = ""
            PageTitle$ = Trim(PeekS(*StringStart, *Cursor - *StringStart))
          EndIf
          
        EndIf
        
        If CompareMemory(*Cursor, @"{TITLE}", 7) = 1
          *Cursor + 7
          *StringStart = *Cursor
          format\crTextColor = $000000
          format\dwEffects   = #CFE_BOLD
          PeekS(@format\szFaceName[0], "Times")
          
        ElseIf CompareMemory(*Cursor, @"{BOLD}", 6) = 1
          *Cursor + 6
          *StringStart = *Cursor
          format\crTextColor = $000000
          format\dwEffects   = #CFE_BOLD
          PeekS(@format\szFaceName[0], "Times")
          
        ElseIf CompareMemory(*Cursor, @"{FUNCTION}", 10) = 1
          *Cursor + 10
          *StringStart = *Cursor
          format\crTextColor = $666600
          format\dwEffects   = #CFE_BOLD
          PeekS(@format\szFaceName[0], "Times")
          
        ElseIf CompareMemory(*Cursor, @"{EXAMPLE}", 9) = 1
          *Cursor + 9
          *StringStart = *Cursor
          format\crTextColor = $000000
          format\dwEffects   = 0
          PeekS(@format\szFaceName[0], "Courier New")
          
        ElseIf CompareMemory(*Cursor, @"{TEXT}", 6) = 1
          *Cursor + 6
          *StringStart = *Cursor
          format\crTextColor = $000000
          format\dwEffects   = 0
          PeekS(@format\szFaceName[0], "Times")
          
        ElseIf CompareMemory(*Cursor, @"{LINK:", 6) = 1
          
          *Cursor + 6
          *StringStart = *Cursor
          While *Cursor\b <> ':'
            *Cursor + 1
          Wend
          Target$ = PeekS(*StringStart, *Cursor - *StringStart)
          
          *Cursor + 1
          *StringStart = *Cursor
          While *Cursor\b <> '}'
            *Cursor + 1
          Wend
          
          SendMessage_(*RichEdit, #EM_SETCHARFORMAT, #SCF_SELECTION, @formatlink)
          SendMessage_(*RichEdit, #EM_REPLACESEL, 0, PeekS(*StringStart, *Cursor - *StringStart))
          SendMessage_(*RichEdit, #EM_SETCHARFORMAT, #SCF_SELECTION, @format)
          
          *Cursor + 1
          *StringStart = *Cursor
          
        Else ; unknown
          *StringStart = *Cursor
          *Cursor + 1
          
        EndIf
        
      Else
        *Cursor + 1
      EndIf
    Wend
    
    If *StringStart < *Cursor
      SendMessage_(*RichEdit, #EM_SETCHARFORMAT, #SCF_SELECTION, @format)
      SendMessage_(*RichEdit, #EM_REPLACESEL, 0, PeekS(*StringStart, *Cursor - *StringStart))
    EndIf
    
  EndIf
  
  CloseFile(0)
EndIf

SendMessage_(*RichEdit, #EM_SETSEL, 0, 0)

Return

