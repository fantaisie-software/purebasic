; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


; linux only file
CompilerIf #CompileLinux
  
  ; The splitter makes the IDE crash on 24.04. According to valgring it's some memory freed in scintilla
  ; which cause that, but it's unclear why it does crash in the help window and not in the session history
  ; as it uses the same setup (panel/scintilla and splitter)
  ; So for now, disable the splitter until we find a way to fix it (we could change the scintilla by webgadget
  ; and use proper HTML help, which would allow images and other enhancement)
  ;
  #UseHelpSplitter = #False 
  #HelpPanelWidth = 400 ; Fixed width of the Panel when the splitter isn't used.
  
  UseBriefLZPacker()
  
  Structure Help_Contents
    SubLevel.l
    Name$
    link$
  EndStructure
  
  Structure Help_Index
    Name$
    link$
  EndStructure
  
  Structure Help_Directory
    link$
    Pointer.i
    Length.l
  EndStructure
  
  Structure Help_Link
    LinkStart.l  ; start position in the text buffer
    LinkEnd.l    ; end position in the text buffer
    Link$        ; target of the link
  EndStructure
  
  Structure Help_StyleInfo
    Style.l
    Length.l
  EndStructure
  
  Global Dim Help_Contents.Help_Contents(0)
  Global Dim Help_Index.Help_Index(0)
  Global Dim Help_Directory.Help_Directory(0)
  
  Global NewList Help_Links.Help_Link()
  Global NewList Help_Styles.Help_StyleInfo()
  
  
  Global Help_Contents_Size, Help_Index_Size, Help_Directory_Size, Help_LinkCount
  Global *LinkMask, LinkCursor, HelpLanguage$, Help_Loaded
  Global HelpButtonHeight
  
  Global NewList Help_History.s()
  Global NewList Help_Search.s()
  
  ; styles for the help
  ;
  Enumeration
    #STYLE_Normal         ; {TEXT}             - use normal text font
    #STYLE_Normal_Function; {COLOR:color:text} - colored text. color values: FUNCTION CONSTANT COMMENT KEYWORD
    #STYLE_Normal_Constant
    #STYLE_Normal_Comment
    #STYLE_Normal_Keyword
    #STYLE_Normal_Red     ; for @Orange etc
    #STYLE_Normal_Green
    #STYLE_Normal_Blue
    #STYLE_Normal_Orange
    
    #STYLE_Code           ; {EXAMPLE}          - use fixed example font
    #STYLE_Code_Function  ; {COLOR:color:text} - colored text. color values: FUNCTION CONSTANT COMMENT KEYWORD
    #STYLE_Code_Constant
    #STYLE_Code_Comment
    #STYLE_Code_Keyword   ; No red/green/blue in code sections
    
    #STYLE_Bold           ; {BOLD}             - for the bold/black header lines
    #STYLE_Title          ; {TITLE}            - for the big/bold title line
    #STYLE_Function       ; {FUNCTION}         - for the bold function header
    #STYLE_Link           ; {LINK:target:text} - link
  EndEnumeration
  
  
  Procedure GetNextPackFile(Pack)
    If NextPackEntry(Pack)
      EntrySize = PackEntrySize(Pack, #PB_Packer_UncompressedSize)
      *Buffer = AllocateMemory(EntrySize)
      If *Buffer
        If UncompressPackMemory(Pack, *Buffer, EntrySize, "") = EntrySize; Uncompress the current entry
          ProcedureReturn *Buffer
        EndIf
        
        FreeMemory(*Buffer) ; Failed
      EndIf
    EndIf
  EndProcedure
  
  
  Procedure InitLinuxHelp()
    
    If Help_Loaded = 0
      
      HelpLanguage$ = CurrentLanguage$ ; to know when to update the help
      
      CompilerIf #SpiderBasic
        
        ; For now we ship only english help in SpiderBasic
        File$ = LCase(#ProductName$)+".help"
        
      CompilerElse
        
        If UCase(HelpLanguage$) = "DEUTSCH"
          File$ = LCase(#ProductName$)+"_german.help"
        ElseIf UCase(HelpLanguage$) = "FRANCAIS"
          File$ = LCase(#ProductName$)+"_french.help"
        Else
          File$ = LCase(#ProductName$)+".help"
        EndIf
        
      CompilerEndIf
      
      If FileSize(PureBasicPath$ + File$) <= 0 ; just in case someone renamed the files (like was done in 3.94)
        File$ = LCase(#ProductName$)+".help"
      EndIf
      
      If OpenPack(0, PureBasicPath$ + File$, #PB_PackerPlugin_BriefLZ)
        
        ExaminePack(0)
        
        ; Structure of the packed archive
        ;
        ; 1) contents table : LONG (sublevel) + STRING (name) + STRING (link)
        ; 2) index table    : STRING (functionname) + STRING (link)
        ; 3) directory table: LONG (pointer) + LONG (length) + STRING (link)
        ; 4) data
        ;
        ; Note: The directorytable pointer is still a long on x64 (as it is just relative to the data start)
        ;   so we have a compatible format. In memory, it is stored in an integer though as the base will be
        ;   added to have a real pointer.
        ;
        
        ; contents table
        ;
        *Buffer = GetNextPackFile(0)
        *BufferEnd = *Buffer + PackEntrySize(0, #PB_Packer_UncompressedSize)
        
        If *Buffer = 0
          MessageRequester(#ProductName$,Language("Misc","ReadError")+" '"+PureBasicPath$+File$+"' !", #FLAG_Error)
          Help_Contents_Size = 0
          Help_Index_Size    = 0
          Help_Directory_Size= 0
          ProcedureReturn
        EndIf
        
        ; do a count first
        *Cursor = *Buffer
        Help_Contents_Size = 0
        While *Cursor < *BufferEnd
          Help_Contents_Size + 1
          *Cursor + 4 ; sublevel
          *Cursor + MemoryStringLength(*Cursor, #PB_Ascii) + 1 ; name
          *Cursor + MemoryStringLength(*Cursor, #PB_Ascii) + 1 ; link
        Wend
        
        ; now read the data
        Dim Help_Contents.Help_Contents(Help_Contents_Size-1)
        *Cursor = *Buffer
        For i = 0 To Help_Contents_Size-1
          Help_Contents(i)\Sublevel = PeekL(*Cursor): *Cursor + 4
          Help_Contents(i)\Name$    = PeekS(*Cursor, -1, #PB_Ascii): *Cursor + MemoryStringLength(*Cursor, #PB_Ascii) + 1
          Help_Contents(i)\link$    = PeekS(*Cursor, -1, #PB_Ascii): *Cursor + MemoryStringLength(*Cursor, #PB_Ascii) + 1
        Next i
        
        FreeMemory(*Buffer)
        
        ; index table
        ;
        *Buffer    = GetNextPackFile(0)
        *BufferEnd = *Buffer + PackEntrySize(0, #PB_Packer_UncompressedSize)
        
        If *Buffer = 0
          MessageRequester(#ProductName$,Language("Misc","ReadError")+" '"+PureBasicPath$+File$+"' !", #FLAG_Error)
          Help_Contents_Size = 0
          Help_Index_Size    = 0
          Help_Directory_Size= 0
          ProcedureReturn
        EndIf
        
        ; do a count first
        *Cursor = *Buffer
        Help_Index_Size = 0
        While *Cursor < *BufferEnd
          Help_Index_Size + 1
          *Cursor + MemoryStringLength(*Cursor, #PB_Ascii) + 1 ; name
          *Cursor + MemoryStringLength(*Cursor, #PB_Ascii) + 1 ; link
        Wend
        
        ; now read the data
        Dim Help_Index.Help_Index(Help_Index_Size-1)
        *Cursor = *Buffer
        For i = 0 To Help_Index_Size-1
          Help_Index(i)\Name$ = PeekS(*Cursor, -1, #PB_Ascii): *Cursor + MemoryStringLength(*Cursor, #PB_Ascii) + 1
          Help_Index(i)\link$ = PeekS(*Cursor, -1, #PB_Ascii): *Cursor + MemoryStringLength(*Cursor, #PB_Ascii) + 1
        Next i
        
        FreeMemory(*Buffer)
        
        ; directory table
        ;
        *Buffer    = GetNextPackFile(0)
        *BufferEnd = *Buffer + PackEntrySize(0, #PB_Packer_UncompressedSize)
        
        If *Buffer = 0
          MessageRequester(#ProductName$,Language("Misc","ReadError")+" '"+PureBasicPath$+File$+"' !", #FLAG_Error)
          Help_Contents_Size = 0
          Help_Index_Size    = 0
          Help_Directory_Size= 0
          ProcedureReturn
        EndIf
        
        ; do a count first
        *Cursor = *Buffer
        Help_Directory_Size = 0
        While *Cursor < *BufferEnd
          Help_Directory_Size + 1
          *Cursor + 8 ; pointer + length
          *Cursor + MemoryStringLength(*Cursor, #PB_Ascii) + 1 ; link
        Wend
        
        ; now read the data
        Dim Help_Directory.Help_Directory(Help_Directory_Size-1)
        *Cursor = *Buffer
        For i = 0 To Help_Directory_Size-1
          Help_Directory(i)\Pointer = PeekL(*Cursor): *Cursor + 4 ; pointer stored as long in the file
          Help_Directory(i)\Length  = PeekL(*Cursor): *Cursor + 4
          Help_Directory(i)\link$   = PeekS(*Cursor, -1, #PB_Ascii): *Cursor + MemoryStringLength(*Cursor, #PB_Ascii) + 1
        Next i
        
        FreeMemory(*Buffer)
        
        ; help data
        ;
        *Buffer = GetNextPackFile(0)
        
        If *Buffer = 0
          MessageRequester(#ProductName$,Language("Misc","ReadError")+" '"+PureBasicPath$+File$+"' !", #FLAG_Error)
          Help_Contents_Size = 0
          Help_Index_Size    = 0
          Help_Directory_Size= 0
          ProcedureReturn
        EndIf
        
        ; copy the buffer as it is
        *Help_Data = *Buffer
        
        ; update the pointers in Help_Directory for direct access, and find the size of the largest page
        ;
        MaxLength = 0
        For i = 0 To Help_Directory_Size-1
          Help_Directory(i)\Pointer + *Help_Data
          If Help_Directory(i)\Length > MaxLength
            MaxLength = Help_Directory(i)\Length
          EndIf
        Next i
        
        ClosePack(0)
        Help_Loaded = 1
      Else
        MessageRequester(#ProductName$,Language("Misc","ReadError")+" '"+PureBasicPath$+File$+"' !", #FLAG_Error)
      EndIf
    EndIf
    
  EndProcedure
  
  
  Procedure LoadHelpPage(Link$, AddToHistory)
    
    If Link$ <> ""
      
      Found = 0
      Link$ = LCase(Link$)
      For index = 0 To Help_Directory_Size-1
        If Link$ = Help_Directory(index)\link$
          Found = 1
          Break
        EndIf
      Next index
      
      If Found
        
        *PageBuffer = AllocateMemory(Help_Directory(index)\Length+1)
        If *PageBuffer
          
          ; Keywords
          ;
          ; {TITLE}            - for the big/bold title line
          ; {BOLD}             - for the bold/black header lines
          ; {FUNCTION}         - for the bold function header
          ; {EXAMPLE}          - use fixed example font
          ; {TEXT}             - use normal text font
          ; {LINK:target:text} - link
          ; {COLOR:color:text} - colored text. color values: FUNCTION CONSTANT COMMENT KEYWORD RED GREEN BLUE ORANGE
          ;
          ; Images are not supported.
          
          IsCodeSection = 0
          CurrentStyle  = #STYLE_Normal
          
          ClearList(Help_Links())
          ClearList(Help_Styles())
          
          *Cursor.BYTE = Help_Directory(index)\Pointer
          *StringStart = *Cursor
          *BufferEnd   = *Cursor + Help_Directory(index)\Length
          
          *PageCursor.BYTE  = *PageBuffer
          
          While *Cursor < *BufferEnd
            If *Cursor\b = '{'
              
              ; add styling info for the previous text
              If *Cursor-*StringStart > 0
                AddElement(Help_Styles())
                Help_Styles()\Style = CurrentStyle
                Help_Styles()\Length = *Cursor-*StringStart
              EndIf
              
              If CompareMemory(*Cursor, ToAscii("{TITLE}"), 7) = 1
                *Cursor + 7
                *StringStart = *Cursor
                IsCodeSection = 0
                CurrentStyle = #STYLE_Title
                
              ElseIf CompareMemory(*Cursor, ToAscii("{BOLD}"), 6) = 1
                *Cursor + 6
                *StringStart = *Cursor
                IsCodeSection = 0
                CurrentStyle = #STYLE_Bold
                
              ElseIf CompareMemory(*Cursor, ToAscii("{FUNCTION}"), 10) = 1
                *Cursor + 10
                *StringStart = *Cursor
                IsCodeSection = 0
                CurrentStyle = #STYLE_Function
                
              ElseIf CompareMemory(*Cursor, ToAscii("{EXAMPLE}"), 9) = 1
                *Cursor + 9
                *StringStart = *Cursor
                IsCodeSection = 1
                CurrentStyle = #STYLE_Code
                
              ElseIf CompareMemory(*Cursor, ToAscii("{TEXT}"), 6) = 1
                *Cursor + 6
                *StringStart = *Cursor
                IsCodeSection = 0
                CurrentStyle = #STYLE_Normal
                
              ElseIf CompareMemory(*Cursor, ToAscii("{COLOR:"), 7) = 1
                *Cursor + 7
                Color$ = ""
                While *Cursor\b <> ':'
                  Color$ + Chr(*Cursor\b & $FF)
                  *Cursor + 1
                Wend
                *Cursor + 1
                
                AddElement(Help_Styles())
                
                If IsCodeSection
                  Select Color$
                    Case "FUNCTION": Help_Styles()\Style  = #STYLE_Code_Function
                    Case "CONSTANT": Help_Styles()\Style  = #STYLE_Code_Constant
                    Case "COMMENT" : Help_Styles()\Style  = #STYLE_Code_Comment
                    Case "KEYWORD" : Help_Styles()\Style  = #STYLE_Code_Keyword
                  EndSelect
                Else
                  Select Color$
                    Case "FUNCTION": Help_Styles()\Style  = #STYLE_Normal_Function
                    Case "CONSTANT": Help_Styles()\Style  = #STYLE_Normal_Constant
                    Case "COMMENT" : Help_Styles()\Style  = #STYLE_Normal_Comment
                    Case "KEYWORD" : Help_Styles()\Style  = #STYLE_Normal_Keyword
                    Case "RED"     : Help_Styles()\Style  = #STYLE_Normal_Red
                    Case "GREEN"   : Help_Styles()\Style  = #STYLE_Normal_Green
                    Case "BLUE"    : Help_Styles()\Style  = #STYLE_Normal_Blue
                    Case "ORANGE"  : Help_Styles()\Style  = #STYLE_Normal_Orange
                  EndSelect
                EndIf
                
                *StringStart = *Cursor
                While *Cursor\b <> '}'
                  *PageCursor\b = *Cursor\b
                  *PageCursor + 1
                  *Cursor + 1
                Wend
                
                Help_Styles()\Length = *Cursor - *StringStart
                *Cursor + 1
                *StringStart = *Cursor
                
              ElseIf CompareMemory(*Cursor, ToAscii("{LINK:"), 6) = 1
                
                *Cursor + 6
                *StringStart = *Cursor
                While *Cursor\b <> ':'
                  *Cursor + 1
                Wend
                
                AddElement(Help_Links())
                Help_Links()\Link$ = PeekS(*StringStart, *Cursor - *StringStart, #PB_Ascii)
                Help_Links()\LinkStart = *PageCursor - *PageBuffer
                
                *Cursor + 1
                *StringStart = *Cursor
                While *Cursor\b <> '}'
                  *PageCursor\b = *Cursor\b
                  *PageCursor + 1
                  *Cursor + 1
                Wend
                Help_Links()\LinkEnd = *PageCursor - *PageBuffer
                
                AddElement(Help_Styles())
                Help_Styles()\Style = #STYLE_Link
                Help_Styles()\Length = *Cursor-*StringStart
                
                *Cursor + 1
                *StringStart = *Cursor
                
              Else ; literal char, just skip it
                *StringStart = *Cursor ; as we finished the last style, we need to update this!
                
                *PageCursor\b = *Cursor\b
                *PageCursor + 1
                *Cursor + 1
                
              EndIf
              
            Else
              *PageCursor\b = *Cursor\b
              *PageCursor + 1
              *Cursor + 1
            EndIf
          Wend
          
          If *StringStart < *Cursor
            AddElement(Help_Styles())
            If *StringStart = Help_Directory(index)\Pointer
              ; the whole file has no coloring/formatting marks, so it is probably an example file, use the fixed font
              Help_Styles()\Style = #STYLE_Code
            Else
              Help_Styles()\Style = CurrentStyle
            EndIf
            Help_Styles()\Length = *Cursor-*StringStart
          EndIf
          
          *PageCursor\b = 0 ; 0-terminate the buffer
          
          ScintillaSendMessage(#GADGET_Help_Editor, #SCI_SETREADONLY, 0, 0) ; must be off for the styling
          ScintillaSendMessage(#GADGET_Help_Editor, #SCI_SETCODEPAGE, 0, 0) ; All help are in ASCII form for now
          
          ScintillaSendMessage(#GADGET_Help_Editor, #SCI_SETTEXT, 0, *PageBuffer)
          
          FreeMemory(*PageBuffer)
          
          ; now do the styling
          ;
          ScintillaSendMessage(#GADGET_Help_Editor, #SCI_STARTSTYLING, 0, $FFFFFF)
          
          ForEach Help_Styles()
            ScintillaSendMessage(#GADGET_Help_Editor, #SCI_SETSTYLING, Help_Styles()\Length, Help_Styles()\Style)
          Next Help_Styles()
          ClearList(Help_Styles())
          
          ScintillaSendMessage(#GADGET_Help_Editor, #SCI_SETREADONLY, 1, 0)
          
          If AddToHistory
            If ListSize(Help_History()) > 0
              If Help_History() <> Link$
                AddElement(Help_History())
                Help_History() = Link$
              EndIf
            Else
              AddElement(Help_History())
              Help_History() = Link$
            EndIf
          EndIf
          
          
          ; select right item in tree if possible
          For i = 0 To Help_Contents_Size-1
            If Link$ = Help_Contents(i)\Link$
              SetGadgetState(#GADGET_Help_Tree, i)
              Break
            EndIf
          Next i
          
          If PageTitle$ <> ""
            If Left(PageTitle$, 12) = "PureBasic - "  ; library commandlist
              PageTitle$ = Trim(Right(PageTitle$, Len(PageTitle$)-12))
            EndIf
            
            SetWindowTitle(#WINDOW_Help, Language("Help","Title") + " - "+PageTitle$)
          Else
            SetWindowTitle(#WINDOW_Help, Language("Help","Title"))
          EndIf
          
        EndIf
        
      EndIf
    EndIf
    
  EndProcedure
  
  CompilerIf #CompileLinuxGtk
    ProcedureC HelpMouseEventsGtk(*Window.GtkWidget, *Event.GdkEventButton, user_type)
      If *Event\button = 1
        
        position = ScintillaSendMessage(#GADGET_Help_Editor, #SCI_POSITIONFROMPOINTCLOSE, WindowMouseX(#WINDOW_Help)-GadgetX(#GADGET_Help_Editor)-GadgetX(#GADGET_Help_Splitter), WindowMouseY(#WINDOW_Help)-GadgetY(#GADGET_Help_Editor)-GadgetY(#GADGET_Help_Splitter))
        If position <> -1
          ForEach Help_Links()
     
            If Help_Links()\LinkStart <= position And Help_Links()\LinkEnd >= position
              ;LoadHelpPage(Help_Links()\Link$, 1) move to HelpWindowEvents
              PostEvent(#PB_Event_Gadget, #WINDOW_Help, #GADGET_Help_Editor, #EVENTTYPE_LoadHelpPage)
              ProcedureReturn 1 ; ignore event
              
            EndIf
            
          Next Help_Links()
        EndIf
      EndIf
      
      ProcedureReturn 0
    EndProcedure
  CompilerEndIf
  
  CompilerIf #CompileLinuxQt
    ProcedureC HelpMouseEventsQt(*Event)
      If QT_EventType(*Event) = 2 And QT_EventButton(*Event) = 1 ; QEvent::MouseButtonPress on Qt::LeftButton

        position = ScintillaSendMessage(#GADGET_Help_Editor, #SCI_POSITIONFROMPOINTCLOSE, WindowMouseX(#WINDOW_Help)-GadgetX(#GADGET_Help_Editor, #PB_Gadget_WindowCoordinate), WindowMouseY(#WINDOW_Help)-GadgetY(#GADGET_Help_Editor, #PB_Gadget_WindowCoordinate))
        If position <> -1
          ForEach Help_Links()
            
            If Help_Links()\LinkStart <= position And Help_Links()\LinkEnd >= position
              ;LoadHelpPage(Help_Links()\Link$, 1) move to HelpWindowEvents
              PostEvent(#PB_Event_Gadget, #WINDOW_Help, #GADGET_Help_Editor, #EVENTTYPE_LoadHelpPage)
              ProcedureReturn 1 ; ignore event
              
            EndIf
            
          Next Help_Links()
        EndIf
        
      EndIf
      
      ProcedureReturn 0
    EndProcedure
  CompilerEndIf

  Procedure ResizePanelContent()
    PanelWidth  = GetGadgetAttribute(#GADGET_Help_Panel, #PB_Panel_ItemWidth)
    PanelHeight = GetGadgetAttribute(#GADGET_Help_Panel, #PB_Panel_ItemHeight)
    
    GetRequiredSize(#GADGET_Help_SearchGo, @ButtonWidth, @ButtonHeight)
    ButtonWidth  = Max(ButtonWidth, 100)
    StringHeight = GetRequiredHeight(#GADGET_Help_SearchValue)
    
    ResizeGadget(#GADGET_Help_Tree         , 0, 0, PanelWidth, PanelHeight)
    ResizeGadget(#GADGET_Help_Index        , 0, 0, PanelWidth, PanelHeight)
    ResizeGadget(#GADGET_Help_SearchValue  , 10, 10, PanelWidth-20, StringHeight)
    ResizeGadget(#GADGET_Help_SearchGo     , (PanelWidth-ButtonWidth)/2, 20+StringHeight, ButtonWidth, ButtonHeight)
    ResizeGadget(#GADGET_Help_SearchResults, 0, 30+StringHeight+ButtonHeight, PanelWidth, PanelHeight-30-StringHeight-ButtonHeight)
  EndProcedure  
  
  
  Procedure ResizeHelpContent()
    CompilerIf #UseHelpSplitter
      ResizeGadget(#GADGET_Help_Splitter, 5, 10+HelpButtonHeight, WindowWidth(#WINDOW_Help)-10, WindowHeight(#WINDOW_Help)-15-HelpButtonHeight)
    CompilerElse
      ResizeGadget(#GADGET_Help_Panel , 5, 10+HelpButtonHeight, #HelpPanelWidth, WindowHeight(#WINDOW_Help)-15-HelpButtonHeight)
      ResizePanelContent()
      ResizeGadget(#GADGET_Help_Editor, #HelpPanelWidth+10, 10+HelpButtonHeight, WindowWidth(#WINDOW_Help)-#HelpPanelWidth-10, WindowHeight(#WINDOW_Help)-15-HelpButtonHeight)
    CompilerEndIf
  EndProcedure
  
  Procedure OpenHelpWindow()
    
    If IsWindow(#WINDOW_Help) = 0
      
      Flags = #PB_Window_SystemMenu | #PB_Window_SizeGadget | #PB_Window_MaximizeGadget | #PB_Window_MinimizeGadget | #PB_Window_Invisible
      If HelpWindowX = -1 And HelpWindowY = -1
        Flags | #PB_Window_ScreenCentered
      EndIf
      
      If HelpWindowMaximized
        Flags | #PB_Window_Maximize
      EndIf
      
      
      If OpenWindow(#WINDOW_Help, HelpWindowX, HelpWindowY, HelpWindowWidth, HelpWindowHeight, Language("Help","Title"), Flags)
        
        ButtonGadget(#GADGET_Help_Parent,     5, 5, 80, 25, Language("Help", "Parent"))
        ButtonGadget(#GADGET_Help_Back,      90, 5, 80, 25, Language("Help", "Back"))
        ButtonGadget(#GADGET_Help_Previous, 185, 5, 80, 25, "<<")
        ButtonGadget(#GADGET_Help_Next,     270, 5, 80, 25, ">>")
        
        GetRequiredSize(#GADGET_Help_Parent, @ButtonWidth, @HelpButtonHeight)
        ButtonWidth = Max(ButtonWidth, 80)
        ButtonWidth = Max(ButtonWidth, GetRequiredWidth(#GADGET_Help_Back))
        ButtonWidth = Max(ButtonWidth, GetRequiredWidth(#GADGET_Help_Previous))
        ButtonWidth = Max(ButtonWidth, GetRequiredWidth(#GADGET_Help_Next))
        
        ResizeGadget(#GADGET_Help_Parent,   5, 5, ButtonWidth, HelpButtonHeight)
        ResizeGadget(#GADGET_Help_Back,     10+ButtonWidth, 5, ButtonWidth, HelpButtonHeight)
        ResizeGadget(#GADGET_Help_Previous, 20+ButtonWidth*2, 5, ButtonWidth, HelpButtonHeight)
        ResizeGadget(#GADGET_Help_Next,     25+ButtonWidth*3, 5, ButtonWidth, HelpButtonHeight)
        
        PanelGadget(#GADGET_Help_Panel, 0, 0, 0, 0)
        
        AddGadgetItem(#GADGET_Help_Panel, -1, Language("Help", "Contents"))
        TreeGadget(#GADGET_Help_Tree, 0, 0, 0, 0)
        
        AddGadgetItem(#GADGET_Help_Panel, -1, Language("Help", "Index"))
        ListViewGadget(#GADGET_Help_Index, 0, 0, 0, 0)
        
        AddGadgetItem(#GADGET_Help_Panel, -1, Language("Help", "Search"))
        StringGadget(#GADGET_Help_SearchValue, 10, 10, 0, 25, "")
        ButtonGadget(#GADGET_Help_SearchGo, 0, 45, 100, 25, Language("Help", "StartSearch"))
        ListViewGadget(#GADGET_Help_SearchResults, 0, 80, 0, 0)
        
        CloseGadgetList()
        
        
        ScintillaGadget(#GADGET_Help_Editor, 0, 0, 0, 0, 0)
        
        CompilerIf #CompileLinuxGtk
          ; GTKSignalConnect(GadgetID(#GADGET_Help_Panel), "size-allocate", @PanelSizeChangeSignal(), 0)
          GTKSignalConnect(GadgetID(#GADGET_Help_Editor), "button-press-event", @HelpMouseEventsGtk(), 0)
        CompilerElse
          ; Note: The mouse events happen on the QAbstractScrollArea::viewport() instead of the main widget!
          QT_SetEventFilter(QT_GetViewPort(GadgetID(#GADGET_Help_Editor)), @HelpMouseEventsQt())
        CompilerEndIf
        
        ScintillaSendMessage(#GADGET_Help_Editor, #SCI_SETCARETSTYLE, 0); Hide the blinking caret
        
        ScintillaSendMessage(#GADGET_Help_Editor, #SCI_USEPOPUP, 1, 0) ; use the scintilla popup
        ScintillaSendMessage(#GADGET_Help_Editor, #SCI_SETMARGINWIDTHN, 0, 0)
        ScintillaSendMessage(#GADGET_Help_Editor, #SCI_SETMARGINWIDTHN, 1, 0)
        ScintillaSendMessage(#GADGET_Help_Editor, #SCI_SETWRAPMODE, 1, 0) ; wrap at word boundaries
        
        FontSize = 10
        TitleSize = 14
        
        ;ScintillaSendMessage(#GADGET_Help_Editor, #SCI_STYLESETFONT,  #STYLE_DEFAULT, "") - do not call this, use the default font
        ScintillaSendMessage(#GADGET_Help_Editor, #SCI_STYLESETSIZE, #STYLE_DEFAULT,  FontSize)
        
        ScintillaSendMessage(#GADGET_Help_Editor, #SCI_STYLESETBACK, #STYLE_DEFAULT, Colors(#COLOR_GlobalBackground)\DisplayValue)
        ScintillaSendMessage(#GADGET_Help_Editor, #SCI_STYLESETFORE, #STYLE_DEFAULT, Colors(#COLOR_NormalText)\DisplayValue)
        ScintillaSendMessage(#GADGET_Help_Editor, #SCI_STYLECLEARALL, 0, 0) ; apply these settings to all styles
        
        ScintillaSendMessage(#GADGET_Help_Editor, #SCI_STYLESETFORE, #STYLE_Normal_Function, Colors(#COLOR_PureKeyword)\DisplayValue)
        ScintillaSendMessage(#GADGET_Help_Editor, #SCI_STYLESETFORE, #STYLE_Normal_Constant, Colors(#COLOR_Constant)\DisplayValue)
        ScintillaSendMessage(#GADGET_Help_Editor, #SCI_STYLESETFORE, #STYLE_Normal_Comment,  Colors(#COLOR_Comment)\DisplayValue)
        ScintillaSendMessage(#GADGET_Help_Editor, #SCI_STYLESETFORE, #STYLE_Normal_Keyword,  Colors(#COLOR_BasicKeyword)\DisplayValue)
        ScintillaSendMessage(#GADGET_Help_Editor, #SCI_STYLESETBOLD, #STYLE_Normal_Keyword,  1)
        
        ScintillaSendMessage(#GADGET_Help_Editor, #SCI_STYLESETFORE, #STYLE_Normal_Red,    $000099)
        ScintillaSendMessage(#GADGET_Help_Editor, #SCI_STYLESETFORE, #STYLE_Normal_Green,  $009900)
        ScintillaSendMessage(#GADGET_Help_Editor, #SCI_STYLESETFORE, #STYLE_Normal_Blue,   $990000)
        ScintillaSendMessage(#GADGET_Help_Editor, #SCI_STYLESETFORE, #STYLE_Normal_Orange, $009999)
        
        ScintillaSendMessage(#GADGET_Help_Editor, #SCI_STYLESETFORE, #STYLE_Code_Function, Colors(#COLOR_PureKeyword)\DisplayValue)
        ScintillaSendMessage(#GADGET_Help_Editor, #SCI_STYLESETFORE, #STYLE_Code_Constant, Colors(#COLOR_Constant)\DisplayValue)
        ScintillaSendMessage(#GADGET_Help_Editor, #SCI_STYLESETFORE, #STYLE_Code_Comment, Colors(#COLOR_Comment)\DisplayValue)
        ScintillaSendMessage(#GADGET_Help_Editor, #SCI_STYLESETFORE, #STYLE_Code_Keyword, Colors(#COLOR_BasicKeyword)\DisplayValue)
        
        ScintillaSendMessage(#GADGET_Help_Editor, #SCI_STYLESETFONT, #STYLE_Code, ToAscii(EditorFontName$))
        ScintillaSendMessage(#GADGET_Help_Editor, #SCI_STYLESETFONT, #STYLE_Code_Function, ToAscii(EditorFontName$))
        ScintillaSendMessage(#GADGET_Help_Editor, #SCI_STYLESETFONT, #STYLE_Code_Constant, ToAscii(EditorFontName$))
        ScintillaSendMessage(#GADGET_Help_Editor, #SCI_STYLESETFONT, #STYLE_Code_Comment, ToAscii(EditorFontName$))
        ScintillaSendMessage(#GADGET_Help_Editor, #SCI_STYLESETFONT, #STYLE_Code_Keyword, ToAscii(EditorFontName$))
        
        ScintillaSendMessage(#GADGET_Help_Editor, #SCI_STYLESETSIZE, #STYLE_Code, EditorFontSize)
        ScintillaSendMessage(#GADGET_Help_Editor, #SCI_STYLESETSIZE, #STYLE_Code_Function, EditorFontSize)
        ScintillaSendMessage(#GADGET_Help_Editor, #SCI_STYLESETSIZE, #STYLE_Code_Constant, EditorFontSize)
        ScintillaSendMessage(#GADGET_Help_Editor, #SCI_STYLESETSIZE, #STYLE_Code_Comment, EditorFontSize)
        ScintillaSendMessage(#GADGET_Help_Editor, #SCI_STYLESETSIZE, #STYLE_Code_Keyword, EditorFontSize)
        
        ScintillaSendMessage(#GADGET_Help_Editor, #SCI_STYLESETBOLD, #STYLE_Bold, 1)
        ScintillaSendMessage(#GADGET_Help_Editor, #SCI_STYLESETSIZE, #STYLE_Title, TitleSize)
        ScintillaSendMessage(#GADGET_Help_Editor, #SCI_STYLESETBOLD, #STYLE_Title, 1)
        ScintillaSendMessage(#GADGET_Help_Editor, #SCI_STYLESETFORE, #STYLE_Function, Colors(#COLOR_PureKeyword)\DisplayValue)
        ScintillaSendMessage(#GADGET_Help_Editor, #SCI_STYLESETBOLD, #STYLE_Function, 1)
        ScintillaSendMessage(#GADGET_Help_Editor, #SCI_STYLESETFORE, #STYLE_Link, Colors(#COLOR_PureKeyword)\DisplayValue)
        ScintillaSendMessage(#GADGET_Help_Editor, #SCI_STYLESETHOTSPOT, #STYLE_Link, 1)
        ScintillaSendMessage(#GADGET_Help_Editor, #SCI_STYLESETUNDERLINE, #STYLE_Link, 1)
        
        CompilerIf #UseHelpSplitter
          SplitterGadget(#GADGET_Help_Splitter, 5, 10+HelpButtonHeight, HelpWindowWidth-10, HelpWindowHeight-15-HelpButtonHeight, #GADGET_Help_Panel, #GADGET_Help_Editor, #PB_Splitter_Vertical)
        CompilerEndIf
        
        InitLinuxHelp() ; load the help file and prepare the data
        
        ;SubLevel = 0
        For i = 0 To Help_Contents_Size-1
          AddGadgetItem(#GADGET_Help_Tree, -1, Help_Contents(i)\Name$, 0, Help_Contents(i)\Sublevel)
        Next i
        
        For i = 0 To Help_Index_Size-1
          AddGadgetItem(#GADGET_Help_Index, -1, Help_Index(i)\Name$)
        Next i
        
        AddKeyboardShortcut(#WINDOW_Help, #PB_Shortcut_Return, #MENU_Help_Enter)
        
        EnsureWindowOnDesktop(#WINDOW_Help)
        HideWindow(#WINDOW_Help, 0)
        LoadHelpPage("", -1) ; make sure the colors are initialized
        
        ResizeHelpContent()
        
        CompilerIf #UseHelpSplitter
          SetGadgetState(#GADGET_Help_Splitter, HelpWindowSplitter)
        CompilerEndIf
        
        ClearList(Help_History())
        
        SetWindowForeground(#WINDOW_Help)
      EndIf
    Else
      SetWindowForeground(#WINDOW_Help)
    EndIf
    
  EndProcedure
  
  
  Procedure HelpWindowEvents(EventID)
    
    If EventID = #PB_Event_Gadget
      EventGadget = EventGadget()
      
    ElseIf EventID = #PB_Event_Menu
      If EventMenu() = #MENU_Help_Enter And GetActiveGadget() = #GADGET_Help_SearchValue
        EventID = #PB_Event_Gadget
        EventGadget = #GADGET_Help_SearchGo
      EndIf
    EndIf
    
    Select EventID
        
      Case #PB_Event_CloseWindow
        If MemorizeWindow And IsWindowMinimized(#WINDOW_Help) = 0
          HelpWindowMaximized = IsWindowMaximized(#WINDOW_Help)
          If HelpWindowMaximized = 0
            HelpWindowX      = WindowX(#WINDOW_Help)
            HelpWindowY      = WindowY(#WINDOW_Help)
            HelpWindowWidth  = WindowWidth(#WINDOW_Help)
            HelpWindowHeight = WindowHeight(#WINDOW_Help)
          EndIf
         
          CompilerIf #UseHelpSplitter
            HelpWindowSplitter = GetGadgetState(#GADGET_Help_Splitter)
          CompilerEndIf

        EndIf
        CloseWindow(#WINDOW_Help)
        
        
      Case #PB_Event_Gadget
        Select EventGadget
            
          Case #GADGET_Help_Tree
            index = GetGadgetState(#GADGET_Help_Tree)
            If index <> -1
              LoadHelpPage( Help_Contents(index)\link$ , 1)
            EndIf
            
          Case #GADGET_Help_Index
            index = GetGadgetState(#GADGET_Help_Index)
            If index <> -1
              LoadHelpPage( Help_Index(index)\link$ , 1)
            EndIf
            
          Case #GADGET_Help_Parent
            Found = 0
            For i = 0 To Help_Contents_Size-1
              If Help_Contents(i)\Link$ = Help_History()
                Found = 1
                Break
              EndIf
            Next i
            
            If Found And i > 0
              SubLevel = Help_Contents(i)\SubLevel - 1
              For i = i-1 To 0 Step -1
                If Help_Contents(i)\SubLevel = SubLevel
                  LoadHelpPage(Help_Contents(i)\Link$, 1)
                  Break
                EndIf
              Next i
            EndIf
            
          Case #GADGET_Help_Back
            If ListSize(Help_History()) > 1
              DeleteElement(Help_History())
              LoadHelpPage(Help_History(), 0)
            EndIf
            
          Case #GADGET_Help_Previous
            Found = 0
            For i = 0 To Help_Contents_Size-1
              If Help_Contents(i)\Link$ = Help_History()
                Found = 1
                Break
              EndIf
            Next i
            
            If Found And i > 0
              If Help_Contents(i-1)\SubLevel = Help_Contents(i)\SubLevel
                LoadHelpPage(Help_Contents(i-1)\Link$, 1)
              EndIf
            EndIf
            
          Case #GADGET_Help_Next
            Found = 0
            For i = 0 To Help_Contents_Size-1
              If Help_Contents(i)\Link$ = Help_History()
                Found = 1
                Break
              EndIf
            Next i
            
            If Found And i < Help_Contents_Size-1
              If Help_Contents(i+1)\SubLevel = Help_Contents(i)\SubLevel
                LoadHelpPage(Help_Contents(i+1)\Link$, 1)
              EndIf
            EndIf
            
          Case #GADGET_Help_SearchGo
            Search$ = GetGadgetText(#GADGET_Help_SearchValue)
            SearchLength = Len(Search$)
            ClearList(Help_Search())
            ClearGadgetItems(#GADGET_Help_SearchResults)
            
            If Search$
              For page = 0 To Help_Directory_Size-1
                *Cursor    = Help_Directory(page)\Pointer
                *BufferEnd = *Cursor + Help_Directory(page)\Length - SearchLength
                
                word_found = 0
                title_found = 0
                
                While *Cursor < *BufferEnd
                  If word_found = 0 And CompareMemoryString(ToAscii(Search$), *Cursor, #PB_String_NoCase, SearchLength, #PB_Ascii) = 0
                    
                    ; page matches search.
                    word_found = 1
                    If title_found = 1
                      AddElement(Help_Search())
                      Help_Search() = Help_Directory(page)\link$
                      AddGadgetItem(#GADGET_Help_SearchResults, -1, PageTitle$)
                      Break
                    EndIf
                    
                  ElseIf title_found = 0 And CompareMemoryString(ToAscii("{TITLE}"), *Cursor, #PB_String_CaseSensitive, 7, #PB_Ascii) = 0
                    *Cursor + 7
                    *Cursor2.BYTE = *Cursor
                    While *Cursor2\b <> '{'
                      *Cursor2 + 1
                    Wend
                    PageTitle$ = PeekS(*Cursor, *Cursor2-*Cursor, #PB_Ascii)
                    
                    title_found = 1
                    If word_found = 1
                      AddElement(Help_Search())
                      Help_Search() = Help_Directory(page)\link$
                      AddGadgetItem(#GADGET_Help_SearchResults, -1, PageTitle$)
                      Break
                    EndIf
                    
                  EndIf
                  *Cursor + 1
                Wend
                
                If word_found = 1 And title_found = 0
                  AddElement(Help_Search())
                  Help_Search() = Help_Directory(page)\link$
                  AddGadgetItem(#GADGET_Help_SearchResults, -1, Help_Search())
                EndIf
                
              Next page
            EndIf
            
          Case #GADGET_Help_SearchResults
            index = GetGadgetState(#GADGET_Help_SearchResults)
            If index <> -1
              SelectElement(Help_Search(), index)
              LoadHelpPage( Help_Search() , 1)
            EndIf
            
          Case #GADGET_Help_Splitter
            ResizePanelContent()
            
          Case #GADGET_HELP_Editor
            Select EventType()
              Case #EVENTTYPE_LoadHelpPage
                LoadHelpPage(Help_Links()\Link$, 1)
            EndSelect
            
        EndSelect
        
      Case #PB_Event_SizeWindow
        ResizeHelpContent()
        
    EndSelect
    
  EndProcedure
  
  
  
  Procedure UpdateHelpWindow()
    
    SetWindowTitle(#WINDOW_Help, Language("Help","Title"))
    
    SetGadgetText(#GADGET_Help_Parent,   Language("Help", "Parent"))
    SetGadgetText(#GADGET_Help_Back,     Language("Help", "Back"))
    SetGadgetText(#GADGET_Help_SearchGo, Language("Help", "StartSearch"))
    
    SetGadgetItemText(#GADGET_Help_Panel, 0, Language("Help", "Contents"), 0)
    SetGadgetItemText(#GADGET_Help_Panel, 1, Language("Help", "Index"), 0)
    SetGadgetItemText(#GADGET_Help_Panel, 2, Language("Help", "Search"), 0)
    
    ; Update sizes of the buttons
    GetRequiredSize(#GADGET_Help_Parent, @ButtonWidth, @HelpButtonHeight)
    ButtonWidth = Max(ButtonWidth, 80)
    ButtonWidth = Max(ButtonWidth, GetRequiredWidth(#GADGET_Help_Back))
    ButtonWidth = Max(ButtonWidth, GetRequiredWidth(#GADGET_Help_Previous))
    ButtonWidth = Max(ButtonWidth, GetRequiredWidth(#GADGET_Help_Next))
    
    ResizeGadget(#GADGET_Help_Parent,   5, 5, ButtonWidth, HelpButtonHeight)
    ResizeGadget(#GADGET_Help_Back,     10+ButtonWidth, 5, ButtonWidth, HelpButtonHeight)
    ResizeGadget(#GADGET_Help_Previous, 20+ButtonWidth*2, 5, ButtonWidth, HelpButtonHeight)
    ResizeGadget(#GADGET_Help_Next,     25+ButtonWidth*3, 5, ButtonWidth, HelpButtonHeight)
 
    ResizeHelpContent()
    
    ; Reload the helpfile if the language really changed
    ;
    If HelpLanguage$ <> CurrentLanguage$
      If ListSize(Help_History()) > 0
        Link$ = Help_History()
      Else
        Link$ = "reference/reference"
      EndIf
      
      HelpWindowEvents(#PB_Event_CloseWindow)
      Help_Loaded = 0  ; will cause a reload of the file
      OpenHelpWindow() ; will load the new helpfile
      
      LoadHelpPage(Link$, #True)
    EndIf
    
  EndProcedure
  
  
  
  Procedure DisplayHelp(CurrentWord$)
    
    OpenHelpWindow()
    
    If CurrentWord$ = ""
      LoadHelpPage("reference/reference", 1) ; load the default page
      
    ElseIf CheckPureBasicKeyWords(CurrentWord$) <> ""
      LoadHelpPage(LCase(CheckPureBasicKeyWords(CurrentWord$)), 1)
      
    Else
      Found = 0
      CurrentWord$ = LCase(CurrentWord$)
      For i = 0 To Help_Index_Size-1
        If CurrentWord$ = LCase(Help_Index(i)\Name$)
          Found = 1
          Break
        EndIf
      Next i
      
      If Found
        LoadHelpPage(Help_Index(i)\Link$, 1)
        
      Else
        LoadHelpPage("reference/reference", 1) ; load the default page
        
      EndIf
    EndIf
    
  EndProcedure
  
CompilerEndIf