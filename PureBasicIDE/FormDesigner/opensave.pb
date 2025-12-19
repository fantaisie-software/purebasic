; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software and Gaetan DUPONT-PANON. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------
Procedure FD_NewWindow(x=0,y=0,width=600,height=400,file.s = "")
  ForEach FormWindows()
    countunderscore = CountString(FormWindows()\variable,"_")
    
    If countunderscore
      leftvar.s = StringField(FormWindows()\variable, countunderscore, "_")
      num = Val(StringField(FormWindows()\variable, countunderscore + 1, "_"))
      If leftvar = "Window"
        If num >= c_window
          c_window = num + 1
        EndIf
      EndIf
    EndIf
  Next
  
  AddElement(FormWindows())
  FormWindows()\x = 0
  FormWindows()\y = 0
  FormWindows()\width = width
  FormWindows()\height = height
  FormWindows()\variable = "Window_"+Str(c_window)
  FormWindows()\pbany = FormVariable
  FormWindows()\captionvariable = FormVariableCaption
  FormWindows()\color = -1
  FormWindows()\flags = FlagValue("#PB_Window_SystemMenu")
  FormWindows()\current_file = file
  FormWindows()\generateeventloop = 1
  
  currentwindow = FormWindows()
  FD_UpdateObjList()
  
  If currentview = 0
    FD_SelectWindow(currentwindow)
  Else
    FD_SelectCode()
  EndIf
  
  redraw = 1
  ProcedureReturn FormWindows()
EndProcedure

Procedure FD_Save(Filename$)
  If FormWindows()\current_view = 1
    FD_SetDesignView()
  EndIf
  
  If *ActiveSource\Parser\Encoding = 0 ; Ascii
    Format = #PB_Ascii
  Else ; UTF-8
    Format = #PB_UTF8
  EndIf
  
  handle = CreateFile(#PB_Any, Filename$, Format)
  If handle
    If *ActiveSource\Parser\Encoding = 1 ; UTF-8
      WriteStringFormat(handle, #PB_UTF8); Write the BOM: https://www.purebasic.fr/english/viewtopic.php?f=4&t=63080
    EndIf
    
    code.s = FD_SelectCode(1)
    
    num = CountString(code,#Endline)
    
    For i = 1 To num
      WriteStringN(handle,StringField(code,i,#Endline))
    Next
    
    FormWindows()\current_file = Filename$
    CloseFile(handle)
    FormChanges(0)
    
    ProcedureReturn #True
  EndIf
EndProcedure

Procedure OpenReadNextParam(line.s,pos,includeequal = 0)
  If includeequal
    pos = FindString(line,"=",pos)
    ProcedureReturn pos
  EndIf
  
  Repeat
    char.s = PeekS(@line + (pos - 1) * SizeOf(Character), 1)
    
    If char = Chr(34)
      pos = FindString(line, Chr(34), pos + 1) + 1
      Continue
    EndIf
    
    If char = "("
      pos = FindString(line, ")", pos + 1) + 1
      Continue
    EndIf
    
    If char = "," Or char = ")"
      ProcedureReturn pos
    EndIf
    
    pos + 1
    
    If pos > Len(line)
      ProcedureReturn Len(line)
    EndIf
  ForEver
EndProcedure

Procedure OpenReadNextParamOld(line.s,pos,includeequal = 0)
  Repeat
    If includeequal
      newpos = FindString(line,"=",pos)
    EndIf
    
    If Not newpos
      newpos = FindString(line,",",pos)
    EndIf
    
    If Not newpos
      newpos = FindString(line,")",pos)
      Repeat
        If FindString(line,")",newpos + 1)
          newpos = FindString(line,")",newpos + 1)
        Else
          Break
        EndIf
      ForEver
    EndIf
    
    
    string = FindString(line,Chr('"'),pos)
    proc = FindString(line,"(",pos)
    
    
    ; check for strings
    If string > 0 And string < newpos And string < proc
      pos = FindString(line,Chr('"'),string + 1) + 1
      newpos = 0
      Continue
    EndIf
    
    ; check for procedure calls - doesn't do nested procedure calls.
    If proc > 0 And proc < newpos
      pos = FindString(line,")",proc + 1) + 1
      newpos = 0
      Continue
    EndIf
    
    Break
  ForEver
  
  ProcedureReturn newpos
EndProcedure

Procedure OpenReadGadgetParams(line.s)
  FormWindows()\FormGadgets()\itemnumber = itemnumbers
  itemnumbers + 1
  
  pbany = FindString(line, "=")
  start = FindString(line, "(") + 1
  If pbany
    FormWindows()\FormGadgets()\variable = Trim(Left(line,pbany - 1))
    FormWindows()\FormGadgets()\pbany = 1
    start = OpenReadNextParam(line,start) + 1
  Else
    startnext = OpenReadNextParam(line,start)
    FormWindows()\FormGadgets()\variable = Trim(Mid(line,start,startnext-start))
    FormWindows()\FormGadgets()\variable = Right(FormWindows()\FormGadgets()\variable,Len(FormWindows()\FormGadgets()\variable) -1)
    start = startnext + 1
  EndIf
  
  ;{ Update window's gadget counts
  countunderscore = CountString(FormWindows()\FormGadgets()\variable,"_")
  
  If countunderscore
    leftvar.s = StringField(FormWindows()\FormGadgets()\variable, countunderscore, "_")
    num = Val(StringField(FormWindows()\FormGadgets()\variable, countunderscore + 1, "_"))
    If leftvar = "Button"
      If num >= FormWindows()\c_button
        FormWindows()\c_button = num + 1
      EndIf
    ElseIf leftvar = "ButtonImage"
      If num >= FormWindows()\c_buttonimg
        FormWindows()\c_buttonimg = num + 1
      EndIf
    ElseIf leftvar = "String"
      If num >= FormWindows()\c_string
        FormWindows()\c_string = num + 1
      EndIf
    ElseIf leftvar = "Checkbox"
      If num >= FormWindows()\c_checkbox
        FormWindows()\c_checkbox = num + 1
      EndIf
    ElseIf leftvar = "Text"
      If num >= FormWindows()\c_text
        FormWindows()\c_text = num + 1
      EndIf
    ElseIf leftvar = "Option"
      If num >= FormWindows()\c_option
        FormWindows()\c_option = num + 1
      EndIf
    ElseIf leftvar = "Tree"
      If num >= FormWindows()\c_tree
        FormWindows()\c_tree = num + 1
      EndIf
    ElseIf leftvar = "ListView"
      If num >= FormWindows()\c_listview
        FormWindows()\c_listview = num + 1
      EndIf
    ElseIf leftvar = "ListIcon"
      If num >= FormWindows()\c_listicon
        FormWindows()\c_listicon = num + 1
      EndIf
    ElseIf leftvar = "Combo"
      If num >= FormWindows()\c_combo
        FormWindows()\c_combo = num + 1
      EndIf
    ElseIf leftvar = "Spin"
      If num >= FormWindows()\c_spin
        FormWindows()\c_spin = num + 1
      EndIf
    ElseIf leftvar = "TrackBar"
      If num >= FormWindows()\c_trackbar
        FormWindows()\c_trackbar = num + 1
      EndIf
    ElseIf leftvar = "ProgressBar"
      If num >= FormWindows()\c_progressbar
        FormWindows()\c_progressbar = num + 1
      EndIf
    ElseIf leftvar = "Image"
      If num >= FormWindows()\c_image
        FormWindows()\c_image = num + 1
      EndIf
    ElseIf leftvar = "IP"
      If num >= FormWindows()\c_ip
        FormWindows()\c_ip = num + 1
      EndIf
    ElseIf leftvar = "Scrollbar"
      If num >= FormWindows()\c_scrollbar
        FormWindows()\c_scrollbar = num + 1
      EndIf
    ElseIf leftvar = "Hyperlink"
      If num >= FormWindows()\c_hyperlink
        FormWindows()\c_hyperlink = num + 1
      EndIf
    ElseIf leftvar = "Editor"
      If num >= FormWindows()\c_editor
        FormWindows()\c_editor = num + 1
      EndIf
    ElseIf leftvar = "ExplorerTree"
      If num >= FormWindows()\c_explorertree
        FormWindows()\c_explorertree = num + 1
      EndIf
    ElseIf leftvar = "ExplorerList"
      If num >= FormWindows()\c_explorerlist
        FormWindows()\c_explorerlist = num + 1
      EndIf
    ElseIf leftvar = "ExplorerCombo"
      If num >= FormWindows()\c_explorercombo
        FormWindows()\c_explorercombo = num + 1
      EndIf
    ElseIf leftvar = "Date"
      If num >= FormWindows()\c_date
        FormWindows()\c_date = num + 1
      EndIf
    ElseIf leftvar = "Calendar"
      If num >= FormWindows()\c_calendar
        FormWindows()\c_calendar = num + 1
      EndIf
    ElseIf leftvar = "Scintilla"
      If num >= FormWindows()\c_scintilla
        FormWindows()\c_scintilla = num + 1
      EndIf
    ElseIf leftvar = "Splitter"
      If num >= FormWindows()\c_splitter
        FormWindows()\c_splitter = num + 1
      EndIf
    ElseIf leftvar = "Frame"
      If num >= FormWindows()\c_frame3D
        FormWindows()\c_frame3D = num + 1
      EndIf
    ElseIf leftvar = "ScrollArea"
      If num >= FormWindows()\c_scrollarea
        FormWindows()\c_scrollarea = num + 1
      EndIf
    ElseIf leftvar = "WebView"
      If num >= FormWindows()\c_web
        FormWindows()\c_web = num + 1
      EndIf
    ElseIf leftvar = "Container"
      If num >= FormWindows()\c_container
        FormWindows()\c_container = num + 1
      EndIf
    ElseIf leftvar = "Panel"
      If num >= FormWindows()\c_panel
        FormWindows()\c_panel = num + 1
      EndIf
    ElseIf leftvar = "Canvas"
      If num >= FormWindows()\c_canvas
        FormWindows()\c_canvas = num + 1
      EndIf
    EndIf
  EndIf
  ;}
  
  
  startnext = OpenReadNextParam(line,start)
  
  ;{ x1
  tempvalue.s = Trim(Mid(line,start,startnext-start))
  
  relpos = FindString(tempvalue,"GadgetWidth")
  
  If Not relpos
    relpos = FindString(tempvalue,"WindowWidth")
  EndIf
  
  If Not relpos
    relpos = FindString(tempvalue,"GetGadgetAttribute")
  EndIf
  
  If relpos
    relposend = FindString(tempvalue, "-",relpos)
    FormWindows()\FormGadgets()\lock_right = 1
    
    tempvalue = Mid(tempvalue, relposend + 1, Len(tempvalue) - (relposend - 1))
  Else
    FormWindows()\FormGadgets()\lock_left = 1
  EndIf
  
  FormWindows()\FormGadgets()\x1 = DesktopScaledX(Val(Trim(tempvalue)))
  ;}
  
  start = startnext + 1
  startnext = OpenReadNextParam(line,start)
  
  ;{ y1
  tempvalue.s = Trim(Mid(line,start,startnext-start))
  
  ; remove toolbarheight/menuheight
  tempvalue = ReplaceString(tempvalue,"MenuHeight()","")
  tempvalue = ReplaceString(tempvalue,"+","")
  ;- Change
  tempvalue = ReplaceString(tempvalue,"FormWindowTop","")
  tempvalue = ReplaceString(tempvalue,"+","")
  toolpos = FindString(tempvalue,"ToolBarHeight(")
  If toolpos
    toolend = FindString(tempvalue,")",toolpos) + 1
    tempvalue = Left(tempvalue,toolpos - 1) + Right(tempvalue,Len(tempvalue) - toolend)
  EndIf
  
  relpos = FindString(tempvalue,"GadgetHeight")
  
  If Not relpos
    relpos = FindString(tempvalue,"WindowHeight")
  EndIf
  
  If Not relpos
    relpos = FindString(tempvalue,"GetGadgetAttribute")
  EndIf
  
  If relpos
    relposend = FindString(tempvalue, "-",relpos)
    FormWindows()\FormGadgets()\lock_bottom = 1
    
    tempvalue = Mid(tempvalue, relposend + 1, Len(tempvalue) - (relposend - 1))
    ; after loading the file, the actual width/height of the parent will be computed into this.
  Else
    FormWindows()\FormGadgets()\lock_top = 1
  EndIf
  
  FormWindows()\FormGadgets()\y1 = DesktopScaledY(Val(Trim(tempvalue)))
  ;}
  
  start = startnext + 1
  startnext = OpenReadNextParam(line,start)
  
  ;{ x2
  tempvalue.s = Trim(Mid(line,start,startnext-start))
  tempvalue = ReplaceString(tempvalue,"MenuHeight()","")
  relpos = FindString(tempvalue,"GadgetWidth")
  
  If Not relpos
    relpos = FindString(tempvalue,"WindowWidth")
  EndIf
  
  If Not relpos
    relpos = FindString(tempvalue,"GetGadgetAttribute")
  EndIf
  
  If relpos
    relposend = FindString(tempvalue, "-",relpos)
    FormWindows()\FormGadgets()\lock_left = 1
    FormWindows()\FormGadgets()\lock_right = 1
    
    tempvalue = Mid(tempvalue, relposend + 1, Len(tempvalue) - (relposend - 1))
    ; after loading the file, the actual width/height of the parent will be computed into this.
  EndIf
  
  FormWindows()\FormGadgets()\x2 = FormWindows()\FormGadgets()\x1 + DesktopScaledX(Val(tempvalue))
  ;}
  
  start = startnext + 1
  startnext = OpenReadNextParam(line,start)
  
  ;{ y2
  tempvalue.s = Trim(Mid(line,start,startnext-start))
  toolpos = FindString(tempvalue,"ToolBarHeight(")
  ;- Change
  tempvalue = ReplaceString(tempvalue,"FormWindowTop","")
  tempvalue = ReplaceString(tempvalue,"+","")
  If toolpos
    toolend = FindString(tempvalue,")",toolpos) + 1
    tempvalue = Left(tempvalue,toolpos - 1) + Right(tempvalue,Len(tempvalue) - toolend)
  EndIf
  
  toolpos = FindString(tempvalue,"StatusBarHeight(")
  If toolpos
    toolend = FindString(tempvalue,")",toolpos) + 1
    tempvalue = Left(tempvalue,toolpos - 1) + Right(tempvalue,Len(tempvalue) - toolend)
  EndIf
  
  relpos = FindString(tempvalue,"GadgetHeight")
  
  If Not relpos
    relpos = FindString(tempvalue,"WindowHeight")
  EndIf
  
  If Not relpos
    relpos = FindString(tempvalue,"GetGadgetAttribute")
  EndIf
  
  If relpos
    relposend = FindString(tempvalue, "-",relpos)
    FormWindows()\FormGadgets()\lock_bottom = 1
    FormWindows()\FormGadgets()\lock_top = 1
    
    tempvalue = Mid(tempvalue, relposend + 1, Len(tempvalue) - (relposend - 1))
    ; after loading the file, the actual width/height of the parent will be computed into this.
  EndIf
  
  FormWindows()\FormGadgets()\y2 = FormWindows()\FormGadgets()\y1 + DesktopScaledY(Val(tempvalue))
  ;}
  
  start = startnext + 1
  
  ProcedureReturn start
EndProcedure

Procedure OpenReadGadgetFlags(line.s, start)
  startnext = OpenReadNextParam(line,start)
  
  If startnext
    flags.s = Trim(Mid(line,start,startnext-start))
    winflag = 0
    numflags = CountString(flags,"|")
    
    For i = 0 To numflags
      If numflags = 0
        thisflags.s = Trim(flags)
      Else
        thisflags.s = Trim(StringField(flags,i+1,"|"))
      EndIf
      
      ForEach Gadgets()
        ForEach Gadgets()\Flags()
          If thisflags = Gadgets()\Flags()\name
            If winflag = 0
              winflag = Gadgets()\Flags()\ivalue
            Else
              winflag | Gadgets()\Flags()\ivalue
            EndIf
          EndIf
        Next
      Next
    Next
  EndIf
  FormWindows()\FormGadgets()\flags = winflag
EndProcedure

Procedure OpenReadGadgetCaption(line.s, start)
  startnext = OpenReadNextParam(line,start)
  
  If startnext
    FormWindows()\FormGadgets()\caption = Trim(Mid(line,start,startnext-start))
    If Left(FormWindows()\FormGadgets()\caption,1) = Chr(34)
      FormWindows()\FormGadgets()\caption = Mid(FormWindows()\FormGadgets()\caption,2,Len(FormWindows()\FormGadgets()\caption) - 2)
    Else
      FormWindows()\FormGadgets()\captionvariable = 1
    EndIf
  EndIf
  ProcedureReturn startnext + 1
EndProcedure

Procedure OpenReadGadgetImageID(line.s, start)
  oldstart = start
  start = FindString(line,"(",start) + 1 ; searching for ImageID(
  startnext = FindString(line,")",start)
  
  If start > 1 And startnext
    ; ImageID() found
    imageid.s = Trim(Mid(line,start,startnext-start))
    start = startnext + 1
    startnext = OpenReadNextParam(line,start)
    
  Else
    ; no ImageID()
    startnext = OpenReadNextParam(line,oldstart)
  EndIf
  
  If imageid
    ForEach OpenTempImg()
      If OpenTempImg()\id = imageid
        FormWindows()\FormGadgets()\image = ListIndex(OpenTempImg()) + 1
        Break
      EndIf
    Next
  EndIf
  
  ProcedureReturn startnext + 1
EndProcedure

Procedure OpenReadGadgetMinMax(line.s, start)
  startnext = OpenReadNextParam(line,start)
  
  If startnext
    FormWindows()\FormGadgets()\min = Val(Trim(Mid(line,start,startnext-start)))
  EndIf
  start = startnext + 1
  
  startnext = OpenReadNextParam(line,start)
  
  If startnext
    FormWindows()\FormGadgets()\max = Val(Trim(Mid(line,start,startnext-start)))
  EndIf
  
  ProcedureReturn startnext + 1
EndProcedure

Macro OpenReadGadgetParent()
  If LastElement(GadgetList())
    FormWindows()\FormGadgets()\parent = GadgetList()\a
    FormWindows()\FormGadgets()\parent_item = GadgetList()\b
  EndIf
EndMacro

Procedure OpenReadStatusFlags(line.s, start)
  startnext = OpenReadNextParam(line,start)
  
  If startnext
    flags.s = Trim(Mid(line,start,startnext-start))
    winflag = 0
    numflags = CountString(flags,"|")
    
    For i = 0 To numflags
      If numflags = 0
        thisflags.s = Trim(flags)
      Else
        thisflags.s = Trim(StringField(flags,i+1,"|"))
      EndIf
      
      ForEach Gadgets()
        If Gadgets()\type = #Form_Type_StatusBar
          ForEach Gadgets()\Flags()
            If thisflags = Gadgets()\Flags()\name
              If winflag = 0
                winflag = Gadgets()\Flags()\ivalue
              Else
                winflag | Gadgets()\Flags()\ivalue
              EndIf
            EndIf
          Next
        EndIf
      Next
    Next
  EndIf
  FormWindows()\FormStatusbars()\flags = winflag
EndProcedure

Procedure OpenReadStatusFlagsImageID(line.s, start)
  start = FindString(line,"(",start) + 1 ; searching for ImageID(
  startnext = FindString(line,")",start)
  If startnext
    imageid.s = Trim(Mid(line,start,startnext-start))
    start = startnext + 1
  EndIf
  
  startnext = OpenReadNextParam(line,start)
  
  ForEach OpenTempImg()
    If OpenTempImg()\id = imageid
      FormWindows()\FormStatusbars()\img = ListIndex(OpenTempImg()) + 1
      Break
    EndIf
  Next
  
  ProcedureReturn startnext + 1
EndProcedure

Procedure.s OpenReadProcName(line.s)
  pos = FindString(line,"(")
  
  start = 1
  equal = FindString(line, "=")
  
  If equal And equal < pos
    start = equal + 1
  EndIf
  
  proc.s = Trim(Mid(line,start,pos - start))
  
  ProcedureReturn proc
EndProcedure

Procedure FD_Open(file.s,update = 0)
  
  ; If any changes or new features in this procedure would break backward compatibility with earlier form designer versions,
  ; for example, implementing a new gadget or including a new command in the output code,
  ; please update FD_VersionCheck so that the IDE will be aware of this and can warn properly.
  
  If Not update
    PushListPosition(FormWindows())
    found = 0
    ForEach FormWindows()
      If file = FormWindows()\current_file
        found = 1
      EndIf
    Next
    PopListPosition(FormWindows())
    
    If found
      MessageRequester(#ProductName$, Language("Form", "FileAlreadyOpened"))
      ProcedureReturn
    EndIf
    
    handle = ReadFile(#PB_Any,file)
    Format = ReadStringFormat(handle)
  Else
    handle = 1
    
    FileLength = GetSourceLength()
    
    If FileLength > 0
      *Buffer = AllocateMemory(FileLength+1)
      If *Buffer
        StreamTextOut(*Buffer, FileLength)
        
        If SendEditorMessage(#SCI_GETCODEPAGE) = #SC_CP_UTF8
          Format = #PB_UTF8
        Else
          Format = #PB_Ascii
        EndIf
        
        content.s = PeekS(*Buffer, -1, Format)
        FreeMemory(*Buffer)
      EndIf
    EndIf
    
    ClearList(FormWindows()\FormGadgets())
    ClearList(FormWindows()\FormImg())
    ClearList(FormWindows()\FormMenus())
    ClearList(FormWindows()\FormStatusbars())
    ClearList(FormWindows()\FormToolbars())
    ClearList(FormWindows()\FormCustomFlags())
    
    count = GetLinesCount(*ActiveSource)
    
    line_num = 1
  EndIf
  
  If handle
    SetCurrentDirectory(GetPathPart(file))
    
    loop_enumeration = 0
    loop_datasection = 0
    loop_resizeproc = 0
    
    loop_events = 0
    loop_events_menu = 0
    loop_events_var.s = ""
    loop_events_win = 0
    
    NewList GadgetList.two()
    NewList Fonts.fontlist()
    NewList CustGadgInit.twomixed()
    ClearList(OpenTempImg())
    gadgetlist_item = 0
    menu_level = 0
    is_custgadgetinit = 0
    is_custgadgetcreate = 0
    custgadgetcreate.s = ""
    custgadgetnb = -1
    event_file.s = ""
    
    Repeat
      If update
        line.s = Trim(StringField(content, line_num, #LF$))
        line_num + 1
        
      Else
        line.s = Trim(ReadString(handle, Format))
      EndIf
      
      If update
        If line_num >= count
          end_condition = 1
        EndIf
      Else
        If Eof(handle)
          end_condition = 1
        EndIf
      EndIf
      
      If FindString(line, "Custom gadget initialisation")
        templine.s = Mid(line,3,Len(line) - 2)
        custgadgetnb = Val(StringField(templine,1," "))
        is_custgadgetinit = 1
        Continue
      EndIf
      If FindString(line,"Custom gadget creation")
        templine.s = Mid(line,3,Len(line) - 2)
        custgadgetnb = Val(StringField(templine,1," "))
        
        pos = FindString(line, ") ") + 2
        custgadgetcreate = Mid(line,pos,Len(line) - pos + 1)
        is_custgadgetcreate = 1
        Continue
      EndIf
      
      ; Comment/var definition - skip
      If Left(line,1) = ";" Or line = "" Or Left(line,6) = "Global" Or Left(line,9) = "Protected" Or Left(line,9) = "Procedure" Or Left(line,12) = "EndProcedure"
        If Not FindString(line, "Procedure Open")
          Continue
        EndIf
      EndIf
      
      ; Skip resize gadgets procedure
      If FindString(line, "Procedure ResizeGadgets")
        loop_resizeproc = 1
      EndIf
      
      If loop_resizeproc
        If FindString(line, "EndProcedure")
          loop_resizeproc = 0
        EndIf
        Continue
      EndIf
      
      If Left(line,11) = "Enumeration" Or Left(line,17) = "EnumerationBinary"
        loop_enumeration = 1
      EndIf
      If Left(line,14) = "EndEnumeration"
        loop_enumeration = 0
      EndIf
      
      If loop_enumeration
        Continue
      EndIf
      
      If FindString(line, "DataSection")
        loop_datasection = 1
        Continue
      EndIf
      
      If FindString(line, "EndDataSection")
        loop_datasection = 0
        Continue
      EndIf
      
      If loop_datasection
        startnext = FindString(line, ":")
        label.s = Left(line,startnext - 1)
        
        start = FindString(line, Chr(34)) + 1
        startnext = FindString(line, Chr(34),start)
        
        img.s = Mid(line,start,startnext - start)
        
        ForEach OpenTempImg()
          If OpenTempImg()\img = label
            OpenTempImg()\img = img
          EndIf
        Next
      EndIf
      
      
      If FindString(line, "Select EventGadget()")
        FormWindows()\generateeventloop = 1
        loop_events = 1
        Continue
      EndIf
      
      If FindString(line, "Select EventMenu()")
        FormWindows()\generateeventloop = 1
        loop_events_menu = 1
        Continue
      EndIf
      
      If loop_events_menu And FindString(line, "EndSelect")
        loop_events_menu = 0
        Continue
      EndIf
      
      If loop_events And FindString(line, "EndSelect")
        Continue
      EndIf
      
      If loop_events_menu
        If FindString(line, "Case")
          loop_events_var = Trim(Right(line,Len(line) - 5))
          Continue
        EndIf
        
        If loop_events_var <> ""
          pos = FindString(line,"(") - 1
          proc.s = Left(line,pos)
          
          ForEach FormWindows()\FormMenus()
            If FormWindows()\FormMenus()\id = loop_events_var
              FormWindows()\FormMenus()\event = proc
              Break
            EndIf
          Next
          
          ForEach FormWindows()\FormToolbars()
            If FormWindows()\FormToolbars()\id = loop_events_var
              FormWindows()\FormToolbars()\event = proc
              Break
            EndIf
          Next
          loop_events_var = ""
          Continue
        EndIf
      EndIf
      
      If loop_events
        If FindString(line, "Case")
          loop_events_var = Trim(Right(line,Len(line) - 5))
          If Left(loop_events_var,1) = "#"
            loop_events_var = Right(loop_events_var,Len(loop_events_var) - 1)
          EndIf
          Continue
        EndIf
        
        If FindString(line, "Default")
          loop_events_win = 1
          Continue
        EndIf
        
        If loop_events_win
          pos = FindString(line,"(") - 1
          proc.s = Left(line,pos)
          
          If ListSize(FormWindows())
            FormWindows()\event_proc = proc
          EndIf
          loop_events_win = 0
        EndIf
        
        If loop_events_var <> ""
          pos = FindString(line,"(") - 1
          proc.s = Left(line,pos)
          
          ForEach FormWindows()\FormGadgets()
            If FormWindows()\FormGadgets()\variable = loop_events_var
              FormWindows()\FormGadgets()\event_proc = proc
              Break
            EndIf
          Next
          
          loop_events_var = ""
          Continue
        EndIf
      EndIf
      
      procname.s = OpenReadProcName(line)
      
      If is_custgadgetinit ;{
        is_custgadgetinit = 0
        AddElement(CustGadgInit())
        CustGadgInit()\a = custgadgetnb
        CustGadgInit()\b = line
        Continue
      EndIf ;}
      If is_custgadgetcreate ;{ will parse element values (only if they are next to each others)
        is_custgadgetcreate = 0
        
        ForEach CustGadgInit()
          If CustGadgInit()\a = custgadgetnb
            found = 1
            Break
          EndIf
        Next
        AddElement(FormWindows()\FormGadgets())
        
        FormWindows()\FormGadgets()\itemnumber = itemnumbers
        itemnumbers + 1
        FormWindows()\FormGadgets()\type = #Form_Type_Custom
        If found
          FormWindows()\FormGadgets()\cust_init = CustGadgInit()\b
        EndIf
        
        FormWindows()\FormGadgets()\cust_create = custgadgetcreate
        
        NewList tempgadgcreate.twomixed()
        posequal = FindString(custgadgetcreate,"=")
        pos = FindString(custgadgetcreate,"%id%")
        If pos
          AddElement(tempgadgcreate())
          tempgadgcreate()\a = pos
          tempgadgcreate()\b = "id"
        EndIf
        pos = FindString(custgadgetcreate,"%x%")
        If pos
          AddElement(tempgadgcreate())
          tempgadgcreate()\a = pos
          tempgadgcreate()\b = "x"
        EndIf
        pos = FindString(custgadgetcreate,"%y%")
        If pos
          AddElement(tempgadgcreate())
          tempgadgcreate()\a = pos
          tempgadgcreate()\b = "y"
        EndIf
        pos = FindString(custgadgetcreate,"%w%")
        If pos
          AddElement(tempgadgcreate())
          tempgadgcreate()\a = pos
          tempgadgcreate()\b = "w"
        EndIf
        pos = FindString(custgadgetcreate,"%h%")
        If pos
          AddElement(tempgadgcreate())
          tempgadgcreate()\a = pos
          tempgadgcreate()\b = "h"
        EndIf
        pos = FindString(custgadgetcreate,"%txt%")
        If pos
          AddElement(tempgadgcreate())
          tempgadgcreate()\a = pos
          tempgadgcreate()\b = "txt"
        EndIf
        pos = FindString(custgadgetcreate,"%hwnd%")
        If pos
          AddElement(tempgadgcreate())
          tempgadgcreate()\a = pos
          tempgadgcreate()\b = "hwnd"
        EndIf
        SortStructuredList(tempgadgcreate(),#PB_Sort_Ascending,OffsetOf(twomixed\a),#PB_Integer)
        
        ForEach tempgadgcreate()
          If posequal > tempgadgcreate()\a
            start = 0
            startnext = OpenReadNextParam(line, start, 1)
          Else
            If start = 0
              start = FindString(line, "(") + 1
            EndIf
            startnext = OpenReadNextParam(line, start)
          EndIf
          
          If tempgadgcreate()\b = "id"
            variable.s = Trim(Mid(line,start + 1,startnext - 1))
            
            If Not FindString(variable,"#")
              FormWindows()\FormGadgets()\pbany = 1
              ;variable = ReplaceString(variable,"#","")
            EndIf
            FormWindows()\FormGadgets()\variable = variable
          ElseIf tempgadgcreate()\b = "x"
            tempvalue.s = Trim(Mid(line,start,startnext-start))
            
            relpos = FindString(tempvalue,"GadgetWidth")
            
            If Not relpos
              relpos = FindString(tempvalue,"WindowWidth")
            EndIf
            
            If Not relpos
              relpos = FindString(tempvalue,"GetGadgetAttribute")
            EndIf
            
            If relpos
              relposend = FindString(tempvalue, "-",relpos)
              FormWindows()\FormGadgets()\lock_right = 1
              
              tempvalue = Mid(tempvalue, relposend + 1, Len(tempvalue) - (relposend - 1))
            Else
              FormWindows()\FormGadgets()\lock_left = 1
            EndIf
            
            FormWindows()\FormGadgets()\x1 = Val(Trim(tempvalue))
          ElseIf tempgadgcreate()\b = "y"
            tempvalue.s = Trim(Mid(line,start,startnext-start))
            
            ; remove toolbarheight/menuheight
            tempvalue = ReplaceString(tempvalue,"MenuHeight()","")
            tempvalue = ReplaceString(tempvalue,"+","")
            toolpos = FindString(tempvalue,"ToolBarHeight(")
            If toolpos
              toolend = FindString(tempvalue,")",toolpos) + 1
              tempvalue = Left(tempvalue,toolpos - 1) + Right(tempvalue,Len(tempvalue) - toolend)
            EndIf
            
            relpos = FindString(tempvalue,"GadgetHeight")
            
            If Not relpos
              relpos = FindString(tempvalue,"WindowHeight")
            EndIf
            
            If Not relpos
              relpos = FindString(tempvalue,"GetGadgetAttribute")
            EndIf
            
            If relpos
              relposend = FindString(tempvalue, "-",relpos)
              FormWindows()\FormGadgets()\lock_bottom = 1
              
              tempvalue = Mid(tempvalue, relposend + 1, Len(tempvalue) - (relposend - 1))
              ; after loading the file, the actual width/height of the parent will be computed into this.
            Else
              FormWindows()\FormGadgets()\lock_top = 1
            EndIf
            
            FormWindows()\FormGadgets()\y1 = Val(Trim(tempvalue))
          ElseIf tempgadgcreate()\b = "w"
            tempvalue.s = Trim(Mid(line,start,startnext-start))
            tempvalue = ReplaceString(tempvalue,"MenuHeight()","")
            relpos = FindString(tempvalue,"GadgetWidth")
            
            If Not relpos
              relpos = FindString(tempvalue,"WindowWidth")
            EndIf
            
            If Not relpos
              relpos = FindString(tempvalue,"GetGadgetAttribute")
            EndIf
            
            If relpos
              relposend = FindString(tempvalue, "-",relpos)
              FormWindows()\FormGadgets()\lock_left = 1
              FormWindows()\FormGadgets()\lock_right = 1
              
              tempvalue = Mid(tempvalue, relposend + 1, Len(tempvalue) - (relposend - 1))
              ; after loading the file, the actual width/height of the parent will be computed into this.
            EndIf
            
            FormWindows()\FormGadgets()\x2 = FormWindows()\FormGadgets()\x1 + Val(tempvalue)
          ElseIf tempgadgcreate()\b = "h"
            tempvalue.s = Trim(Mid(line,start,startnext-start))
            toolpos = FindString(tempvalue,"ToolBarHeight(")
            If toolpos
              toolend = FindString(tempvalue,")",toolpos) + 1
              tempvalue = Left(tempvalue,toolpos - 1) + Right(tempvalue,Len(tempvalue) - toolend)
            EndIf
            
            toolpos = FindString(tempvalue,"StatusBarHeight(")
            If toolpos
              toolend = FindString(tempvalue,")",toolpos) + 1
              tempvalue = Left(tempvalue,toolpos - 1) + Right(tempvalue,Len(tempvalue) - toolend)
            EndIf
            
            relpos = FindString(tempvalue,"GadgetHeight")
            
            If Not relpos
              relpos = FindString(tempvalue,"WindowHeight")
            EndIf
            
            If Not relpos
              relpos = FindString(tempvalue,"GetGadgetAttribute")
            EndIf
            
            If relpos
              relposend = FindString(tempvalue, "-",relpos)
              FormWindows()\FormGadgets()\lock_bottom = 1
              FormWindows()\FormGadgets()\lock_top = 1
              
              tempvalue = Mid(tempvalue, relposend + 1, Len(tempvalue) - (relposend - 1))
              ; after loading the file, the actual width/height of the parent will be computed into this.
            EndIf
            
            FormWindows()\FormGadgets()\y2 = FormWindows()\FormGadgets()\y1 + Val(tempvalue)
          ElseIf tempgadgcreate()\b = "txt"
            caption.s = Trim(Mid(line,start,startnext))
            If Left(caption,1) = Chr(34)
              FormWindows()\FormGadgets()\captionvariable = 1
              caption = Mid(caption,2,Len(caption) - 2)
            EndIf
            FormWindows()\FormGadgets()\caption = caption
          EndIf
          
          If posequal = -1
            start = startnext + 1
          Else
            posequal = -1
          EndIf
        Next
        
        FormWindows()\FormGadgets()\backcolor = -1
        FormWindows()\FormGadgets()\frontcolor = -1
        OpenReadGadgetParent()
      EndIf ;}
      If FindString(line, "XIncludeFile") ;{
        start = FindString(line, Chr(34)) + 1
        startend = FindString(line, Chr(34),start)
        event_file = Trim(Mid(line,start, startend - start))
      EndIf ;}
      If FindString(line, "Procedure Open")
        start = FindString(line, "(") + 1
        startnext = OpenReadNextParam(line,start)
        var.s = Trim(Mid(line,start,startnext-start))
        var = ReplaceString(var, "x =", "")
        var = ReplaceString(var, "x=", "")
        var = Trim(var)
        
        If var = "#PB_Ignore"
          var = "-65535"
        EndIf
        
        FormWindows()\x = DesktopScaledX(Val(var))
        
        start = startnext + 1
        
        startnext = OpenReadNextParam(line,start)
        var.s = Trim(Mid(line,start,startnext-start))
        var = ReplaceString(var, "y =", "")
        var = ReplaceString(var, "y=", "")
        var = Trim(var)
        
        If var = "#PB_Ignore"
          var = "-65535"
        EndIf
        
        FormWindows()\y = DesktopScaledY(Val(var))
        
        start = startnext + 1
        
        startnext = OpenReadNextParam(line,start)
        var.s = Trim(Mid(line,start,startnext-start))
        var = ReplaceString(var, "width =", "")
        var = ReplaceString(var, "width=", "")
        var = Trim(var)
        
        FormWindows()\width = DesktopScaledX(Val(var))
        start = startnext + 1
        
        startnext = OpenReadNextParam(line,start)
        var.s = Trim(Mid(line,start,startnext-start))
        var = ReplaceString(var, "height =", "")
        var = ReplaceString(var, "height=", "")
        var = Trim(var)
        
        FormWindows()\height = DesktopScaledY(Val(var))
        
        Continue
        
      EndIf
      If procname = "OpenWindow" ;{
        FormWindows()\current_file = file
        FormWindows()\generateeventloop = 0
        pbany = FindString(line, "=")
        start = FindString(line, "(") + 1
        
        If pbany
          FormWindows()\variable = Trim(Left(line,pbany - 1))
          FormWindows()\pbany = 1
          start = FindString(line,",",start) + 1
          
        Else
          startnext = OpenReadNextParam(line,start)
          FormWindows()\variable = Trim(Mid(line,start,startnext-start))
          FormWindows()\variable = Right(FormWindows()\variable,Len(FormWindows()\variable) -1)
          FormWindows()\pbany = 0
          
          start = startnext + 1
        EndIf
        
        startnext = OpenReadNextParam(line,start)
        winx.s = Trim(Mid(line,start,startnext-start))
        
        If winx = "#PB_Ignore"
          winx = "-65535"
        EndIf
        
        If winx <> "x"
          FormWindows()\x = DesktopScaledX(Val(winx))
        EndIf
        
        start = startnext + 1
        startnext = OpenReadNextParam(line,start)
        winy.s = Trim(Mid(line,start,startnext-start))
        
        If winy = "#PB_Ignore"
          winy = "-65535"
        EndIf
        
        If winy <> "y"
          FormWindows()\y = DesktopScaledY(Val(winy))
        EndIf
        
        start = startnext + 1
        startnext = OpenReadNextParam(line,start)
        var = Trim(Mid(line,start,startnext-start))
        If var <> "width"
          FormWindows()\width = DesktopScaledX(Val(var))
        EndIf
        
        start = startnext + 1
        startnext = OpenReadNextParam(line,start)
        var = Trim(Mid(line,start,startnext-start))
        If var <> "height"
          FormWindows()\height = DesktopScaledY(Val(var))
        EndIf
        start = startnext + 1
        
        startnext = OpenReadNextParam(line,start)
        
        FormWindows()\caption = Trim(Mid(line,start,startnext-start))
        If Left(FormWindows()\caption,1) = Chr(34)
          FormWindows()\caption = Mid(FormWindows()\caption,2,Len(FormWindows()\caption) - 2)
        Else
          FormWindows()\captionvariable = 1
        EndIf
        
        start = startnext + 1
        startnext = OpenReadNextParam(line,start)
        
        If startnext
          flags.s = Trim(Mid(line,start,startnext-start))
          winflag = 0
          numflags = CountString(flags,"|")
          addCustomFlag = #False
          
          If numflags = 0
            thisflags.s = Trim(flags)
            ForEach Gadgets()
              If Gadgets()\type = #Form_Type_Window
                flagsDone = #False
                ForEach Gadgets()\Flags()
                  If thisflags = Gadgets()\Flags()\name
                    winflag = Gadgets()\Flags()\ivalue
                    flagsDone = #True
                    Break
                  EndIf
                Next
                If Not flagsDone And thisflags And thisflags <> "0"
                  ;add custom flags to an extra list.
                  ;custom flags have no effect on the display of the form in the Form Designer
                  addCustomFlag = #True
                  ForEach FormWindows()\FormCustomFlags()
                    If FormWindows()\FormCustomFlags() = thisflags
                      addCustomFlag = #False
                      Break
                    EndIf
                  Next
                  If addCustomFlag
                    LastElement(FormWindows()\FormCustomFlags())
                    AddElement(FormWindows()\FormCustomFlags())
                    FormWindows()\FormCustomFlags() = thisflags
                  EndIf
                EndIf
              EndIf
            Next
          Else
            For i = 0 To numflags
              thisflags.s = Trim(StringField(flags,i+1,"|"))
              ForEach Gadgets()
                If Gadgets()\type = #Form_Type_Window
                  flagsDone = #False
                  ForEach Gadgets()\Flags()
                    If thisflags = Gadgets()\Flags()\name
                      If winflag = 0
                        winflag = Gadgets()\Flags()\ivalue
                      Else
                        winflag | Gadgets()\Flags()\ivalue
                      EndIf
                      flagsDone = #True
                      Break
                    EndIf
                  Next
                  If Not flagsDone And thisflags
                    ;add custom flags to an extra list.
                    ;custom flags have no effect on the display of the form in the Form Designer
                    addCustomFlag = #True
                    ForEach FormWindows()\FormCustomFlags()
                      If FormWindows()\FormCustomFlags() = thisflags
                        addCustomFlag = #False
                        Break
                      EndIf
                    Next
                    If addCustomFlag
                      LastElement(FormWindows()\FormCustomFlags())
                      AddElement(FormWindows()\FormCustomFlags())
                      FormWindows()\FormCustomFlags() = thisflags
                    EndIf
                  EndIf
                EndIf
              Next
            Next
          EndIf
          
          FormWindows()\flags = winflag
          
          ; Read parent ID
          start = startnext + 1
          startnext = OpenReadNextParam(line,start)
          
          If startnext
            parentwin.s = Trim(Mid(line,start,startnext-start))
            If FindString(parentwin, "WindowID(")
              parentwin = ReplaceString(parentwin, "WindowID(", "")
              parentwin = ReplaceString(parentwin, ")", "")
            ElseIf parentwin
              parentwin = "=" + parentwin
            EndIf
            FormWindows()\parent = parentwin
          EndIf
        EndIf
        
        
        FormWindows()\color = -1
        FormWindows()\event_file = event_file
        
        If Not update
          ;           pos = AddTabBarGadgetItem(#Form_WindowTabs, #PB_Default,GetFilePart(FormWindows()\current_file))
          ;           SetTabBarGadgetItemData(#Form_WindowTabs,pos,FormWindows())
          ;           SetTabBarGadgetState(#Form_WindowTabs,pos)
          currentwindow = FormWindows()
        EndIf
        
        Continue
      EndIf ;}
      If procname = "ButtonGadget" ;{
        AddElement(FormWindows()\FormGadgets())
        FormWindows()\FormGadgets()\type = #Form_Type_Button
        start = OpenReadGadgetParams(line)
        start = OpenReadGadgetCaption(line, start)
        OpenReadGadgetFlags(line, start)
        FormWindows()\FormGadgets()\backcolor = -1
        FormWindows()\FormGadgets()\frontcolor = -1
        OpenReadGadgetParent()
        Continue
      EndIf ;}
      If procname = "ButtonImageGadget" ;{
        AddElement(FormWindows()\FormGadgets())
        FormWindows()\FormGadgets()\type = #Form_Type_ButtonImg
        start = OpenReadGadgetParams(line)
        start = OpenReadGadgetImageID(line, start)
        OpenReadGadgetFlags(line, start)
        FormWindows()\FormGadgets()\backcolor = -1
        FormWindows()\FormGadgets()\frontcolor = -1
        OpenReadGadgetParent()
        Continue
      EndIf ;}
      If procname = "CalendarGadget" ;{
        AddElement(FormWindows()\FormGadgets())
        FormWindows()\FormGadgets()\type = #Form_Type_Calendar
        start = OpenReadGadgetParams(line)
        start = OpenReadNextParam(line,start) + 1 ; ignore
        
        OpenReadGadgetFlags(line, start)
        FormWindows()\FormGadgets()\backcolor = -1
        FormWindows()\FormGadgets()\frontcolor = -1
        OpenReadGadgetParent()
        Continue
      EndIf ;}
      If procname = "CanvasGadget" ;{
        AddElement(FormWindows()\FormGadgets())
        FormWindows()\FormGadgets()\type = #Form_Type_Canvas
        start = OpenReadGadgetParams(line)
        OpenReadGadgetFlags(line, start)
        FormWindows()\FormGadgets()\backcolor = -1
        FormWindows()\FormGadgets()\frontcolor = -1
        OpenReadGadgetParent()
        Continue
      EndIf ;}
      If procname = "CheckBoxGadget" ;{
        AddElement(FormWindows()\FormGadgets())
        FormWindows()\FormGadgets()\type = #Form_Type_Checkbox
        start = OpenReadGadgetParams(line)
        start = OpenReadGadgetCaption(line, start)
        OpenReadGadgetFlags(line, start)
        FormWindows()\FormGadgets()\backcolor = -1
        FormWindows()\FormGadgets()\frontcolor = -1
        OpenReadGadgetParent()
        Continue
      EndIf ;}
      If procname = "ComboBoxGadget" ;{
        AddElement(FormWindows()\FormGadgets())
        FormWindows()\FormGadgets()\type = #Form_Type_Combo
        start = OpenReadGadgetParams(line)
        OpenReadGadgetFlags(line, start)
        FormWindows()\FormGadgets()\backcolor = -1
        FormWindows()\FormGadgets()\frontcolor = -1
        OpenReadGadgetParent()
        Continue
      EndIf ;}
      If procname = "DateGadget" ;{
        AddElement(FormWindows()\FormGadgets())
        FormWindows()\FormGadgets()\type = #Form_Type_Date
        start = OpenReadGadgetParams(line)
        start = OpenReadGadgetCaption(line, start) ; mask
        start = OpenReadNextParam(line, start) + 1 ; ignore current date
        
        OpenReadGadgetFlags(line, start)
        FormWindows()\FormGadgets()\backcolor = -1
        FormWindows()\FormGadgets()\frontcolor = -1
        OpenReadGadgetParent()
        Continue
      EndIf ;}
      If procname = "EditorGadget" ;{
        AddElement(FormWindows()\FormGadgets())
        FormWindows()\FormGadgets()\type = #Form_Type_Editor
        start = OpenReadGadgetParams(line)
        OpenReadGadgetFlags(line, start)
        FormWindows()\FormGadgets()\backcolor = -1
        FormWindows()\FormGadgets()\frontcolor = -1
        OpenReadGadgetParent()
        Continue
      EndIf ;}
      If procname = "ExplorerComboGadget" ;{
        AddElement(FormWindows()\FormGadgets())
        FormWindows()\FormGadgets()\type = #Form_Type_ExplorerCombo
        start = OpenReadGadgetParams(line)
        start = OpenReadGadgetCaption(line, start)
        OpenReadGadgetFlags(line, start)
        FormWindows()\FormGadgets()\backcolor = -1
        FormWindows()\FormGadgets()\frontcolor = -1
        OpenReadGadgetParent()
        Continue
      EndIf ;}
      If procname = "ExplorerListGadget" ;{
        AddElement(FormWindows()\FormGadgets())
        FormWindows()\FormGadgets()\type = #Form_Type_ExplorerList
        start = OpenReadGadgetParams(line)
        start = OpenReadGadgetCaption(line, start)
        OpenReadGadgetFlags(line, start)
        FormWindows()\FormGadgets()\backcolor = -1
        FormWindows()\FormGadgets()\frontcolor = -1
        OpenReadGadgetParent()
        Continue
      EndIf ;}
      If procname = "ExplorerTreeGadget" ;{
        AddElement(FormWindows()\FormGadgets())
        FormWindows()\FormGadgets()\type = #Form_Type_ExplorerTree
        start = OpenReadGadgetParams(line)
        start = OpenReadGadgetCaption(line, start)
        OpenReadGadgetFlags(line, start)
        FormWindows()\FormGadgets()\backcolor = -1
        FormWindows()\FormGadgets()\frontcolor = -1
        OpenReadGadgetParent()
        Continue
      EndIf ;}
      If procname = "HyperLinkGadget" ;{
        AddElement(FormWindows()\FormGadgets())
        FormWindows()\FormGadgets()\type = #Form_Type_HyperLink
        start = OpenReadGadgetParams(line)
        start = OpenReadGadgetCaption(line, start)
        start = OpenReadNextParam(line, start) + 1 ; ignore color
        OpenReadGadgetFlags(line, start)
        FormWindows()\FormGadgets()\backcolor = -1
        FormWindows()\FormGadgets()\frontcolor = -1
        OpenReadGadgetParent()
        Continue
      EndIf ;}
      If procname = "FrameGadget" Or procname = "Frame3DGadget"  ;{
        AddElement(FormWindows()\FormGadgets())
        FormWindows()\FormGadgets()\type = #Form_Type_Frame3D
        start = OpenReadGadgetParams(line)
        start = OpenReadGadgetCaption(line, start)
        OpenReadGadgetFlags(line, start)
        FormWindows()\FormGadgets()\backcolor = -1
        FormWindows()\FormGadgets()\frontcolor = -1
        OpenReadGadgetParent()
        If FormWindows()\FormGadgets()\flags & #PB_Frame_Container
          LastElement(GadgetList())
          AddElement(GadgetList()) : GadgetList()\a = FormWindows()\FormGadgets()\itemnumber : GadgetList()\b = -1
        EndIf
        Continue
      EndIf ;}
      If procname = "IPAddressGadget" ;{
        AddElement(FormWindows()\FormGadgets())
        FormWindows()\FormGadgets()\type = #Form_Type_IP
        start = OpenReadGadgetParams(line)
        FormWindows()\FormGadgets()\backcolor = -1
        FormWindows()\FormGadgets()\frontcolor = -1
        OpenReadGadgetParent()
        Continue
      EndIf ;}
      If procname = "ImageGadget" ;{
        AddElement(FormWindows()\FormGadgets())
        FormWindows()\FormGadgets()\type = #Form_Type_Img
        start = OpenReadGadgetParams(line)
        start = OpenReadGadgetImageID(line, start)
        OpenReadGadgetFlags(line, start)
        FormWindows()\FormGadgets()\backcolor = -1
        FormWindows()\FormGadgets()\frontcolor = -1
        OpenReadGadgetParent()
        Continue
      EndIf ;}
      If procname = "ListIconGadget" ;{
        AddElement(FormWindows()\FormGadgets())
        FormWindows()\FormGadgets()\type = #Form_Type_ListIcon
        start = OpenReadGadgetParams(line)
        startend = OpenReadNextParam(line, start) ;  title
        
        AddElement(FormWindows()\FormGadgets()\Columns())
        name.s = Trim(Mid(line,start,startend - start))
        name = Mid(name,2, Len(name) - 2)
        FormWindows()\FormGadgets()\Columns()\name = name
        
        start = startend + 1
        startend = OpenReadNextParam(line, start) ;  title width
        FormWindows()\FormGadgets()\Columns()\width = Val(Trim(Mid(line,start,startend - start)))
        
        start = startend + 1
        OpenReadGadgetFlags(line, start)
        FormWindows()\FormGadgets()\backcolor = -1
        FormWindows()\FormGadgets()\frontcolor = -1
        OpenReadGadgetParent()
        Continue
      EndIf ;}
      If procname = "ListViewGadget" ;{
        AddElement(FormWindows()\FormGadgets())
        FormWindows()\FormGadgets()\type = #Form_Type_ListView
        start = OpenReadGadgetParams(line)
        OpenReadGadgetFlags(line, start)
        FormWindows()\FormGadgets()\backcolor = -1
        FormWindows()\FormGadgets()\frontcolor = -1
        OpenReadGadgetParent()
        Continue
      EndIf ;}
      If procname = "OpenGLGadget" ;{
        AddElement(FormWindows()\FormGadgets())
        FormWindows()\FormGadgets()\type = #Form_Type_OpenGL
        start = OpenReadGadgetParams(line)
        OpenReadGadgetFlags(line, start)
        FormWindows()\FormGadgets()\backcolor = -1
        FormWindows()\FormGadgets()\frontcolor = -1
        OpenReadGadgetParent()
        Continue
      EndIf ;}
      If procname = "OptionGadget" ;{
        AddElement(FormWindows()\FormGadgets())
        FormWindows()\FormGadgets()\type = #Form_Type_Option
        start = OpenReadGadgetParams(line)
        start = OpenReadGadgetCaption(line, start)
        FormWindows()\FormGadgets()\backcolor = -1
        FormWindows()\FormGadgets()\frontcolor = -1
        OpenReadGadgetParent()
        Continue
      EndIf ;}
      If procname = "ProgressBarGadget" ;{
        AddElement(FormWindows()\FormGadgets())
        FormWindows()\FormGadgets()\type = #Form_Type_ProgressBar
        start = OpenReadGadgetParams(line)
        start = OpenReadGadgetMinMax(line, start)
        OpenReadGadgetFlags(line, start)
        FormWindows()\FormGadgets()\backcolor = -1
        FormWindows()\FormGadgets()\frontcolor = -1
        OpenReadGadgetParent()
        Continue
      EndIf ;}
      If procname = "ScintillaGadget" ;{
        AddElement(FormWindows()\FormGadgets())
        FormWindows()\FormGadgets()\type = #Form_Type_Scintilla
        start = OpenReadGadgetParams(line)
        
        ; read callback name
        startnext = OpenReadNextParam(line,start)
        If startnext
          FormWindows()\FormGadgets()\caption = Trim(Mid(line, start, startnext - start))
          FormWindows()\FormGadgets()\caption = Right(FormWindows()\FormGadgets()\caption, Len(FormWindows()\FormGadgets()\caption) - 1)
        EndIf
        start = startnext + 1
        
        FormWindows()\FormGadgets()\backcolor = -1
        FormWindows()\FormGadgets()\frontcolor = -1
        OpenReadGadgetParent()
        Continue
      EndIf ;}
      If procname = "ScrollBarGadget" ;{
        AddElement(FormWindows()\FormGadgets())
        FormWindows()\FormGadgets()\type = #Form_Type_Scrollbar
        start = OpenReadGadgetParams(line)
        start = OpenReadGadgetMinMax(line, start)
        start = OpenReadNextParam(line, start) + 1 ; ignore page length
        OpenReadGadgetFlags(line, start)
        FormWindows()\FormGadgets()\backcolor = -1
        FormWindows()\FormGadgets()\frontcolor = -1
        OpenReadGadgetParent()
        Continue
      EndIf ;}
      If procname = "SpinGadget" ;{
        AddElement(FormWindows()\FormGadgets())
        FormWindows()\FormGadgets()\type = #Form_Type_Spin
        start = OpenReadGadgetParams(line)
        start = OpenReadGadgetMinMax(line, start)
        OpenReadGadgetFlags(line, start)
        FormWindows()\FormGadgets()\backcolor = -1
        FormWindows()\FormGadgets()\frontcolor = -1
        OpenReadGadgetParent()
        Continue
      EndIf ;}
      If procname = "StringGadget" ;{
        AddElement(FormWindows()\FormGadgets())
        FormWindows()\FormGadgets()\type = #Form_Type_StringGadget
        start = OpenReadGadgetParams(line)
        start = OpenReadGadgetCaption(line, start)
        OpenReadGadgetFlags(line, start)
        FormWindows()\FormGadgets()\backcolor = -1
        FormWindows()\FormGadgets()\frontcolor = -1
        OpenReadGadgetParent()
        Continue
      EndIf ;}
      If procname = "TextGadget" ;{
        AddElement(FormWindows()\FormGadgets())
        FormWindows()\FormGadgets()\type = #Form_Type_Text
        start = OpenReadGadgetParams(line)
        start = OpenReadGadgetCaption(line, start)
        OpenReadGadgetFlags(line, start)
        FormWindows()\FormGadgets()\backcolor = -1
        FormWindows()\FormGadgets()\frontcolor = -1
        OpenReadGadgetParent()
        Continue
      EndIf ;}
      If procname = "TrackBarGadget" ;{
        AddElement(FormWindows()\FormGadgets())
        FormWindows()\FormGadgets()\type = #Form_Type_Trackbar
        start = OpenReadGadgetParams(line)
        start = OpenReadGadgetMinMax(line, start)
        OpenReadGadgetFlags(line, start)
        FormWindows()\FormGadgets()\backcolor = -1
        FormWindows()\FormGadgets()\frontcolor = -1
        OpenReadGadgetParent()
        Continue
      EndIf ;}
      If procname = "TreeGadget" ;{
        AddElement(FormWindows()\FormGadgets())
        FormWindows()\FormGadgets()\type = #Form_Type_TreeGadget
        start = OpenReadGadgetParams(line)
        OpenReadGadgetFlags(line, start)
        FormWindows()\FormGadgets()\backcolor = -1
        FormWindows()\FormGadgets()\frontcolor = -1
        OpenReadGadgetParent()
        Continue
      EndIf ;}
      If procname = "WebGadget" ;{
        AddElement(FormWindows()\FormGadgets())
        FormWindows()\FormGadgets()\type = #Form_Type_Web
        start = OpenReadGadgetParams(line)
        start = OpenReadGadgetCaption(line, start)
        OpenReadGadgetFlags(line, start)
        FormWindows()\FormGadgets()\backcolor = -1
        FormWindows()\FormGadgets()\frontcolor = -1
        OpenReadGadgetParent()
        Continue
      EndIf ;}
      If procname = "WebViewGadget" ;{
        AddElement(FormWindows()\FormGadgets())
        FormWindows()\FormGadgets()\type = #Form_Type_WebView
        start = OpenReadGadgetParams(line)
        OpenReadGadgetFlags(line, start)
        FormWindows()\FormGadgets()\backcolor = -1
        FormWindows()\FormGadgets()\frontcolor = -1
        OpenReadGadgetParent()
        Continue
      EndIf ;}
      If procname = "ContainerGadget" ;{
        AddElement(FormWindows()\FormGadgets())
        FormWindows()\FormGadgets()\type = #Form_Type_Container
        start = OpenReadGadgetParams(line)
        OpenReadGadgetFlags(line, start)
        FormWindows()\FormGadgets()\backcolor = -1
        FormWindows()\FormGadgets()\frontcolor = -1
        OpenReadGadgetParent()
        LastElement(GadgetList())
        AddElement(GadgetList()) : GadgetList()\a = FormWindows()\FormGadgets()\itemnumber : GadgetList()\b = -1
        Continue
      EndIf ;}
      If procname = "ScrollAreaGadget" ;{
        AddElement(FormWindows()\FormGadgets())
        FormWindows()\FormGadgets()\type = #Form_Type_ScrollArea
        start = OpenReadGadgetParams(line)
        start = OpenReadGadgetMinMax(line, start)
        start = OpenReadNextParam(line, start) + 1 ; ignore page length
        OpenReadGadgetFlags(line, start)
        FormWindows()\FormGadgets()\backcolor = -1
        FormWindows()\FormGadgets()\frontcolor = -1
        OpenReadGadgetParent()
        LastElement(GadgetList())
        AddElement(GadgetList()) : GadgetList()\a = FormWindows()\FormGadgets()\itemnumber : GadgetList()\b = -1
        Continue
      EndIf ;}
      If procname = "PanelGadget" ;{
        AddElement(FormWindows()\FormGadgets())
        FormWindows()\FormGadgets()\type = #Form_Type_Panel
        start = OpenReadGadgetParams(line)
        FormWindows()\FormGadgets()\backcolor = -1
        FormWindows()\FormGadgets()\frontcolor = -1
        OpenReadGadgetParent()
        LastElement(GadgetList())
        AddElement(GadgetList()) : GadgetList()\a = FormWindows()\FormGadgets()\itemnumber : GadgetList()\b = -1
        Continue
      EndIf ;}
      If procname = "SplitterGadget" ;{
        AddElement(FormWindows()\FormGadgets())
        FormWindows()\FormGadgets()\type = #Form_Type_Splitter
        start = OpenReadGadgetParams(line)
        
        startnext = OpenReadNextParam(line,start)
        If startnext
          gadget1.s = Trim(Mid(line,start,startnext-start))
          If Left(gadget1,1) = "#"
            gadget1 = Right(gadget1,Len(gadget1) - 1)
          EndIf
        EndIf
        start = startnext + 1
        
        startnext = OpenReadNextParam(line,start)
        If startnext
          gadget2.s = Trim(Mid(line,start,startnext-start))
          If Left(gadget2,1) = "#"
            gadget2 = Right(gadget2,Len(gadget2) - 1)
          EndIf
        EndIf
        start = startnext + 1
        OpenReadGadgetFlags(line, start)
        
        FormWindows()\FormGadgets()\backcolor = -1
        FormWindows()\FormGadgets()\frontcolor = -1
        
        idsplitter = FormWindows()\FormGadgets()\itemnumber
        PushListPosition(FormWindows()\FormGadgets())
        ForEach FormWindows()\FormGadgets()
          If FormWindows()\FormGadgets()\variable = gadget1
            valgadget1 = FormWindows()\FormGadgets()\itemnumber
            FormWindows()\FormGadgets()\splitter = idsplitter
          EndIf
          If FormWindows()\FormGadgets()\variable = gadget2
            valgadget2 = FormWindows()\FormGadgets()\itemnumber
            FormWindows()\FormGadgets()\splitter = idsplitter
          EndIf
        Next
        PopListPosition(FormWindows()\FormGadgets())
        
        FormWindows()\FormGadgets()\gadget1 = valgadget1
        FormWindows()\FormGadgets()\gadget2 = valgadget2
        
        OpenReadGadgetParent()
        
        FD_UpdateSplitter()
        
        LastElement(GadgetList())
        AddElement(GadgetList()) : GadgetList()\a = FormWindows()\FormGadgets()\itemnumber : GadgetList()\b = -1
        ;        AddElement(GadgetList()) : GadgetList()\a = @FormWindows()\FormGadgets() : GadgetList()\b = -1
        Continue
      EndIf ;}
      If procname = "CloseGadgetList" ;{
        LastElement(GadgetList())
        DeleteElement(GadgetList())
        Continue
      EndIf ;}
      If procname = "AddGadgetItem" ;{
        start = FindString(line, "(") + 1
        
        startnext = OpenReadNextParam(line,start)
        
        If startnext
          variable.s = Trim(Mid(line,start,startnext-start))
          If Left(variable,1) = "#"
            variable = Right(variable,Len(variable) -1)
          EndIf
        EndIf
        start = startnext + 1
        
        startnext = OpenReadNextParam(line,start)
        
        If startnext
          pos = Val(Trim(Mid(line,start,startnext-start)))
        EndIf
        start = startnext + 1
        
        startnext = OpenReadNextParam(line,start)
        
        If startnext
          value.s = Trim(Mid(line,start,startnext-start))
          value = Mid(value,2,Len(value) - 2)
          
          value.s = ReplaceString(value,Chr(34) + " + Chr(10) + " + Chr(34),"|")
        EndIf
        start = startnext + 1
        
        startnext = OpenReadNextParam(line,start)
        
        level = 0
        If startnext
          ; imageid (ignored for now)
          start = startnext + 1
          
          startnext = OpenReadNextParam(line,start)
          
          If startnext
            ; level
            level = Val(Trim(Mid(line,start,startnext-start)))
          EndIf
        EndIf
        
        PushListPosition(FormWindows()\FormGadgets())
        ForEach FormWindows()\FormGadgets()
          If FormWindows()\FormGadgets()\variable = variable
            If pos = -1
              LastElement(FormWindows()\FormGadgets()\Items())
              AddElement(FormWindows()\FormGadgets()\Items())
            Else
              SelectElement(FormWindows()\FormGadgets()\Items(),pos)
              InsertElement(FormWindows()\FormGadgets()\Items())
            EndIf
            FormWindows()\FormGadgets()\Items()\name = value
            FormWindows()\FormGadgets()\Items()\level = level
            
            If FormWindows()\FormGadgets()\type = #Form_Type_Panel
              ForEach GadgetList()
                If GadgetList()\a = FormWindows()\FormGadgets()\itemnumber
                  GadgetList()\b = ListIndex(FormWindows()\FormGadgets()\Items())
                EndIf
              Next
            EndIf
            
            Break
          EndIf
        Next
        PopListPosition(FormWindows()\FormGadgets())
        Continue
      EndIf ;}
      If procname = "LoadImage" ;{
        AddElement(OpenTempImg())
        OpenTempImg()\inline = 0
        pbany = FindString(line, "=")
        start = FindString(line, "(") + 1
        If pbany
          OpenTempImg()\id = Trim(Left(line,pbany - 1))
          start = FindString(line,",",start + 1) + 1
          OpenTempImg()\pbany = 1
        Else
          startnext = FindString(line,",",start + 1)
          OpenTempImg()\id = Trim(Mid(line,start,startnext-start))
          start = startnext + 1
        EndIf
        startnext = OpenReadNextParam(line,start)
        
        If startnext
          OpenTempImg()\img = Trim(Mid(line,start,startnext-start))
          OpenTempImg()\img = Mid(OpenTempImg()\img,2,Len(OpenTempImg()\img) - 2)
        EndIf
        Continue
      EndIf ;}
      If procname = "CatchImage" ;{
        AddElement(OpenTempImg())
        OpenTempImg()\inline = 1
        pbany = FindString(line, "=")
        start = FindString(line, "(") + 1
        If pbany
          OpenTempImg()\id = Trim(Left(line,pbany - 1))
          start = FindString(line,",",start + 1) + 1
          OpenTempImg()\pbany = 1
        Else
          startnext = FindString(line,",",start + 1)
          OpenTempImg()\id = Trim(Mid(line,start,startnext-start))
          start = startnext + 1
        EndIf
        startnext = OpenReadNextParam(line,start)
        If startnext
          OpenTempImg()\img = Trim(Mid(line,start,startnext-start))
          OpenTempImg()\img = ReplaceString(OpenTempImg()\img,"?","") ; remove the ? from data label
        EndIf
        Continue
      EndIf ;}
      If procname = "ToolBarImageButton" ;{
        AddElement(FormWindows()\FormToolbars())
        
        start = FindString(line, "(") + 1
        startnext = FindString(line,",",start + 1)
        FormWindows()\FormToolbars()\id = Trim(Mid(line,start,startnext-start))
        start = startnext + 1
        
        start = FindString(line,"(",start) + 1 ; searching for ImageID(
        startnext = FindString(line,")",start)
        If startnext
          imageid.s = Trim(Mid(line,start,startnext-start))
          start = startnext + 2
        EndIf
        
        startnext = OpenReadNextParam(line,start)
        
        If startnext
          If Trim(Mid(line,start,startnext-start)) = "#PB_ToolBar_Toggle"
            FormWindows()\FormToolbars()\toggle = 1
          EndIf
          
        EndIf
        ForEach OpenTempImg()
          If OpenTempImg()\id = imageid
            FormWindows()\FormToolbars()\img = ListIndex(OpenTempImg()) + 1
            Break
          EndIf
        Next
      EndIf ;}
      If procname = "ToolBarToolTip" ;{
        start = FindString(line, "(") + 1
        startnext = OpenReadNextParam(line,start)
        ;toolbarid = Trim(Mid(line,start,startnext-start))
        start = startnext + 1
        
        startnext = OpenReadNextParam(line,start)
        toolbarbuttonid.s = Trim(Mid(line,start,startnext-start))
        start = startnext + 1
        
        startnext = OpenReadNextParam(line,start)
        
        tooltip.s = Trim(Mid(line,start,startnext-start))
        tooltip = Mid(tooltip,2,Len(tooltip) - 2)
        
        ForEach FormWindows()\FormToolbars()
          If FormWindows()\FormToolbars()\id = toolbarbuttonid
            FormWindows()\FormToolbars()\tooltip = tooltip
            Break
          EndIf
        Next
      EndIf ;}
      If procname = "ToolBarSeparator" ;{
        AddElement(FormWindows()\FormToolbars())
        FormWindows()\FormToolbars()\separator = 1
      EndIf ;}
      If procname = "MenuTitle" ;{
        AddElement(FormWindows()\FormMenus())
        start = FindString(line, "(") + 1
        startnext = OpenReadNextParam(line,start)
        
        title.s = Trim(Mid(line,start,startnext-start))
        title = Mid(title,2,Len(title) - 2)
        
        FormWindows()\FormMenus()\item = title
        FormWindows()\FormMenus()\level = 0
        menu_level = 1
      EndIf ;}
      If procname = "MenuBar" ;{
        AddElement(FormWindows()\FormMenus())
        FormWindows()\FormMenus()\separator = 1
        FormWindows()\FormMenus()\level = menu_level
        Continue
      EndIf ;}
      If procname = "OpenSubMenu" ;{
        AddElement(FormWindows()\FormMenus())
        start = FindString(line, "(") + 1
        startnext = OpenReadNextParam(line,start)
        
        title.s = Trim(Mid(line,start,startnext-start))
        title = Mid(title,2,Len(title) - 2)
        
        FormWindows()\FormMenus()\item = title
        FormWindows()\FormMenus()\level = menu_level
        menu_level + 1
        Continue
      EndIf ;}
      If procname = "MenuItem" ;{
        AddElement(FormWindows()\FormMenus())
        start = FindString(line, "(") + 1
        startnext = OpenReadNextParam(line,start)
        
        id.s = Trim(Mid(line,start,startnext-start))
        start = startnext + 1
        
        startnext = OpenReadNextParam(line,start)
        
        title.s = Trim(Mid(line,start,startnext-start))
        title = Mid(title,2,Len(title) - 2)
        
        pos = FindString(title, Chr(34))
        If pos ; shortcut
          posend = FindString(title, Chr(34),pos + 1) + 1
          FormWindows()\FormMenus()\shortcut = Mid(title, posend, Len(title) - posend + 1)
          
          title = Left(title,pos - 1)
        EndIf
        
        start = startnext + 1
        start = FindString(line,"(",start) + 1 ; searching for ImageID(
        startnext = FindString(line,")",start)
        
        If startnext
          imageid.s = Trim(Mid(line,start,startnext-start))
          start = startnext + 2
          
          ForEach OpenTempImg()
            If OpenTempImg()\id = imageid
              FormWindows()\FormMenus()\icon = ListIndex(OpenTempImg()) + 1
              Break
            EndIf
          Next
        EndIf
        
        FormWindows()\FormMenus()\id = id
        FormWindows()\FormMenus()\item = title
        FormWindows()\FormMenus()\level = menu_level
        Continue
      EndIf ;}
      If procname = "CloseSubMenu" ;{
        menu_level - 1
        Continue
      EndIf ;}
      If procname = "AddStatusBarField" ;{
        AddElement(FormWindows()\FormStatusbars())
        start = FindString(line, "(") + 1
        startnext = OpenReadNextParam(line,start)
        
        title.s = Trim(Mid(line,start,startnext-start))
        If title = "#PB_Ignore"
          width = -1
        Else
          width = Val(title)
        EndIf
        
        FormWindows()\FormStatusbars()\width = width
        Continue
      EndIf ;}
      If procname = "StatusBarText" ;{
        start = FindString(line, "(") + 1
        startnext = OpenReadNextParam(line,start)
        ;toolbarid = Trim(Mid(line,start,startnext-start))
        start = startnext + 1
        
        startnext = OpenReadNextParam(line,start)
        fieldindex = Val(Trim(Mid(line,start,startnext-start)))
        start = startnext + 1
        
        startnext = OpenReadNextParam(line,start)
        
        tooltip.s = Trim(Mid(line,start,startnext-start))
        tooltip = Mid(tooltip,2,Len(tooltip) - 2)
        start = startnext + 1
        
        SelectElement(FormWindows()\FormStatusbars(),fieldindex)
        FormWindows()\FormStatusbars()\text = tooltip
        OpenReadStatusFlags(line,start)
      EndIf ;}
      If procname = "StatusBarProgress" ;{
        start = FindString(line, "(") + 1
        startnext = OpenReadNextParam(line,start)
        ;toolbarid = Trim(Mid(line,start,startnext-start))
        start = startnext + 1
        
        startnext = OpenReadNextParam(line,start)
        fieldindex = Val(Trim(Mid(line,start,startnext-start)))
        start = startnext + 1
        
        start = OpenReadNextParam(line.s, start) + 1
        
        SelectElement(FormWindows()\FormStatusbars(),fieldindex)
        FormWindows()\FormStatusbars()\progressbar = 1
        OpenReadStatusFlags(line,start)
      EndIf ;}
      If procname = "StatusBarImage" ;{
        start = FindString(line, "(") + 1
        startnext = OpenReadNextParam(line,start)
        ;toolbarid = Trim(Mid(line,start,startnext-start))
        start = startnext + 1
        
        startnext = OpenReadNextParam(line,start)
        fieldindex = Val(Trim(Mid(line,start,startnext-start)))
        start = startnext + 1
        
        SelectElement(FormWindows()\FormStatusbars(),fieldindex)
        start = OpenReadStatusFlagsImageID(line, start)
        
        OpenReadStatusFlags(line,start)
      EndIf ;}
      If procname = "SetGadgetColor" ;{
        start = FindString(line, "(") + 1
        startnext = OpenReadNextParam(line,start)
        gadgetid.s = Trim(Mid(line,start,startnext-start))
        If Left(gadgetid,1) = "#"
          gadgetid = Right(gadgetid,Len(gadgetid) - 1)
        EndIf
        start = startnext + 1
        
        startnext = OpenReadNextParam(line,start)
        coltype.s = Trim(Mid(line,start,startnext-start))
        start = startnext + 1
        
        startnext = FindString(line,")",start)
        color.s = Trim(Mid(line,start,startnext-start)) ;in the form of RGB(a,b,c without the last parenthesis
        color = ReplaceString(color,"RGB(","")
        
        If Left(color,1) = "$"
          newcolor = Val(color)
          
        Else
          
          start = 0
          startnext = FindString(color,",",start + 1)
          red = Val(Trim(Mid(color,start,startnext-start)))
          start = startnext + 1
          startnext = FindString(color,",",start + 1)
          green = Val(Trim(Mid(color,start,startnext-start)))
          start = startnext + 1
          blue = Val(Trim(Right(color,Len(color) - start + 1)))
          
          newcolor = RGB(red,green,blue)
        EndIf
        
        ForEach FormWindows()\FormGadgets()
          If FormWindows()\FormGadgets()\variable = gadgetid
            If coltype = "#PB_Gadget_BackColor"
              FormWindows()\FormGadgets()\backcolor = newcolor
            ElseIf coltype = "#PB_Gadget_FrontColor"
              FormWindows()\FormGadgets()\frontcolor = newcolor
            EndIf
            Break
          EndIf
        Next
      EndIf ;}
      If procname = "SetWindowColor" ;{
        start = FindString(line, "(") + 1
        startnext = OpenReadNextParam(line,start)
        gadgetid.s = Trim(Mid(line,start,startnext-start))
        If Left(gadgetid,1) = "#"
          gadgetid = Right(gadgetid,Len(gadgetid) - 1)
        EndIf
        start = startnext + 1
        
        startnext = FindString(line,")",start)
        color.s = Trim(Mid(line,start,startnext-start)) ;in the form of RGB(a,b,c without the last parenthesis
        color = ReplaceString(color,"RGB(","")
        
        
        If Left(color,1) = "$"
          newcolor = Val(color)
          
        Else
          
          start = 0
          startnext = FindString(color,",",start + 1)
          red = Val(Trim(Mid(color,start,startnext-start)))
          start = startnext + 1
          startnext = FindString(color,",",start + 1)
          green = Val(Trim(Mid(color,start,startnext-start)))
          start = startnext + 1
          blue = Val(Trim(Right(color,Len(color) - start + 1)))
          
          newcolor = RGB(red,green,blue)
        EndIf
        
        If FormWindows()\variable = gadgetid
          FormWindows()\color = newcolor
        EndIf
      EndIf ;}
      If procname = "HideWindow" ;{
        start = FindString(line, "(") + 1
        startnext = OpenReadNextParam(line,start)
        gadgetid.s = Trim(Mid(line,start,startnext-start))
        If Left(gadgetid,1) = "#"
          gadgetid = Right(gadgetid,Len(gadgetid) - 1)
        EndIf
        start = startnext + 1
        
        startnext = OpenReadNextParam(line,start)
        val = Val(Trim(Mid(line,start,startnext-start)))
        
        If FormWindows()\variable = gadgetid
          FormWindows()\hidden = val
        EndIf
      EndIf ;}
      If procname = "DisableWindow" ;{
        start = FindString(line, "(") + 1
        startnext = OpenReadNextParam(line,start)
        gadgetid.s = Trim(Mid(line,start,startnext-start))
        If Left(gadgetid,1) = "#"
          gadgetid = Right(gadgetid,Len(gadgetid) - 1)
        EndIf
        start = startnext + 1
        
        startnext = OpenReadNextParam(line,start)
        val = Val(Trim(Mid(line,start,startnext-start)))
        
        If FormWindows()\variable = gadgetid
          FormWindows()\disabled = val
        EndIf
      EndIf ;}
      If procname = "HideGadget" ;{
        start = FindString(line, "(") + 1
        startnext = OpenReadNextParam(line,start)
        gadgetid.s = Trim(Mid(line,start,startnext-start))
        If Left(gadgetid,1) = "#"
          gadgetid = Right(gadgetid,Len(gadgetid) - 1)
        EndIf
        start = startnext + 1
        
        startnext = OpenReadNextParam(line,start)
        val = Val(Trim(Mid(line,start,startnext-start)))
        
        ForEach FormWindows()\FormGadgets()
          If FormWindows()\FormGadgets()\variable = gadgetid
            FormWindows()\FormGadgets()\hidden = val
            Break
          EndIf
        Next
      EndIf ;}
      If procname = "GadgetToolTip" ;{
        start = FindString(line, "(") + 1
        startnext = OpenReadNextParam(line, start)
        gadgetid.s = Trim(Mid(line, start, startnext - start))
        
        If Left(gadgetid, 1) = "#"
          gadgetid = Right(gadgetid, Len(gadgetid) - 1)
        EndIf
        start = startnext + 1
        
        startnext = OpenReadNextParam(line, start)
        
        tooltip.s = Trim(Mid(line, start, startnext - start))
        tooltipvariable = 0
        
        If Left(tooltip, 1) = Chr(34)
          tooltip.s = Mid(tooltip, 2, Len(tooltip) - 2)
        Else
          tooltipvariable = 1
        EndIf
        
        ForEach FormWindows()\FormGadgets()
          If FormWindows()\FormGadgets()\variable = gadgetid
            FormWindows()\FormGadgets()\tooltip = tooltip
            FormWindows()\FormGadgets()\tooltipvariable = tooltipvariable
            Break
          EndIf
        Next
      EndIf ;}
      If procname = "DisableGadget" ;{
        start = FindString(line, "(") + 1
        startnext = OpenReadNextParam(line,start)
        gadgetid.s = Trim(Mid(line,start,startnext-start))
        If Left(gadgetid,1) = "#"
          gadgetid = Right(gadgetid,Len(gadgetid) - 1)
        EndIf
        start = startnext + 1
        
        startnext = OpenReadNextParam(line,start)
        val = Val(Trim(Mid(line,start,startnext-start)))
        
        ForEach FormWindows()\FormGadgets()
          If FormWindows()\FormGadgets()\variable = gadgetid
            FormWindows()\FormGadgets()\disabled = val
            Break
          EndIf
        Next
      EndIf ;}
      If procname = "LoadFont" ;{
        AddElement(Fonts())
        start = FindString(line, "(") + 1
        startnext = FindString(line,",",start + 1)
        Fonts()\id = Trim(Mid(line,start,startnext-start))
        start = startnext + 1
        
        startnext = OpenReadNextParam(line,start)
        tooltip.s = Trim(Mid(line,start,startnext-start))
        Fonts()\name = Mid(tooltip,2,Len(tooltip) - 2)
        start = startnext + 1
        
        startnext = OpenReadNextParam(line,start)
        Fonts()\size = Val(Trim(Mid(line,start,startnext-start)))
        start = startnext + 1
        
        startnext = OpenReadNextParam(line,start)
        
        If startnext
          flags.s = Trim(Mid(line,start,startnext-start))
          winflag = 0
          numflags = CountString(flags,"|")
          
          For i = 0 To numflags
            If numflags = 0
              thisflags.s = Trim(flags)
            Else
              thisflags.s = Trim(StringField(flags,i+1,"|"))
            EndIf
            
            ForEach FontFlags()
              If thisflags = FontFlags()\name
                If winflag = 0
                  winflag = FontFlags()\ivalue
                Else
                  winflag | FontFlags()\ivalue
                EndIf
              EndIf
            Next
          Next
        EndIf
        Fonts()\flags = winflag
      EndIf ;}
      If procname = "SetGadgetFont" ;{
        start = FindString(line, "(") + 1
        startnext = OpenReadNextParam(line,start)
        gadgetid.s = Trim(Mid(line,start,startnext-start))
        If Left(gadgetid,1) = "#"
          gadgetid = Right(gadgetid,Len(gadgetid) - 1)
        EndIf
        start = startnext + 1
        
        startnext = FindString(line,")",start)
        color.s = Trim(Mid(line,start,startnext-start))
        color = ReplaceString(color,"FontID(","")
        color = Trim(color)
        
        ForEach Fonts()
          If Fonts()\id = color
            
            ForEach FormWindows()\FormGadgets()
              If FormWindows()\FormGadgets()\variable = gadgetid
                FormWindows()\FormGadgets()\gadgetfont = Fonts()\name
                FormWindows()\FormGadgets()\gadgetfontflags = Fonts()\flags
                FormWindows()\FormGadgets()\gadgetfontsize = Fonts()\size
                Break
              EndIf
            Next
            
            Break
          EndIf
        Next
        
      EndIf ;}
      If procname = "SetGadgetState" ;{
        start = FindString(line, "(") + 1
        startnext = OpenReadNextParam(line,start)
        gadgetid.s = Trim(Mid(line,start,startnext-start))
        If Left(gadgetid,1) = "#"
          gadgetid = Right(gadgetid,Len(gadgetid) - 1)
        EndIf
        start = startnext + 1
        
        startnext = OpenReadNextParam(line,start)
        value.s = Trim(Mid(line,start,startnext-start))
        
        If value = "#PB_Checkbox_Checked"
          val = 1
        Else
          val = Val(value)
        EndIf
        
        ForEach FormWindows()\FormGadgets()
          If FormWindows()\FormGadgets()\variable = gadgetid
            FormWindows()\FormGadgets()\state = val
            FD_UpdateSplitter()
            Break
          EndIf
        Next
      EndIf ;}
      If procname = "AddGadgetColumn" ;{
        start = FindString(line, "(") + 1
        startnext = OpenReadNextParam(line,start)
        gadgetid.s = Trim(Mid(line,start,startnext-start))
        If Left(gadgetid,1) = "#"
          gadgetid = Right(gadgetid,Len(gadgetid) - 1)
        EndIf
        start = startnext + 1
        
        start = OpenReadNextParam(line,start) + 1 ; ignore position
        
        startnext = OpenReadNextParam(line,start) ; name
        
        name.s = Trim(Mid(line,start,startnext - start))
        name = Mid(name,2, Len(name) - 2)
        
        start = startnext + 1
        startnext = OpenReadNextParam(line, start) ;  title width
        width = Val(Trim(Mid(line,start,startnext - start)))
        
        ForEach FormWindows()\FormGadgets()
          If FormWindows()\FormGadgets()\variable = gadgetid
            AddElement(FormWindows()\FormGadgets()\Columns())
            FormWindows()\FormGadgets()\Columns()\name = name
            FormWindows()\FormGadgets()\Columns()\width = width
            Break
          EndIf
        Next
      EndIf ;}
      If procname = "ResizeGadget" ;{
        start = FindString(line, "(") + 1
        startnext = OpenReadNextParam(line,start)
        gadgetid.s = Trim(Mid(line,start,startnext-start))
        If Left(gadgetid,1) = "#"
          gadgetid = Right(gadgetid,Len(gadgetid) - 1)
        EndIf
        start = startnext + 1
        
        startnext = OpenReadNextParam(line,start) ; x
        g_x.s = Trim(Mid(line,start,startnext - start))
        start = startnext + 1
        
        startnext = OpenReadNextParam(line,start) ; y
        g_y.s = Trim(Mid(line,start,startnext - start))
        start = startnext + 1
        
        startnext = OpenReadNextParam(line,start) ; width
        g_width.s = Trim(Mid(line,start,startnext - start))
        start = startnext + 1
        
        startnext = OpenReadNextParam(line,start) ; height
        g_height.s = Trim(Mid(line,start,startnext - start))
        start = startnext + 1
        
        
        ForEach FormWindows()\FormGadgets()
          If FormWindows()\FormGadgets()\variable = gadgetid
            If FindString(g_x, "FormWindowWidth") Or FindString(g_x, "WindowWidth") Or FindString(g_x, "GadgetWidth") Or FindString(g_x, "GetGadgetAttribute")
              FormWindows()\FormGadgets()\lock_left = 0
              FormWindows()\FormGadgets()\lock_right = 1
            EndIf
            If FindString(g_y, "FormWindowHeight") Or FindString(g_y, "WindowHeight") Or FindString(g_y, "GadgetHeight") Or FindString(g_y, "GetGadgetAttribute")
              FormWindows()\FormGadgets()\lock_top = 0
              FormWindows()\FormGadgets()\lock_bottom = 1
            EndIf
            If FindString(g_width, "FormWindowWidth") Or FindString(g_width, "WindowWidth") Or FindString(g_width, "GadgetWidth") Or FindString(g_width, "GetGadgetAttribute")
              FormWindows()\FormGadgets()\lock_left = 1
              FormWindows()\FormGadgets()\lock_right = 1
            EndIf
            If FindString(g_height, "FormWindowHeight") Or FindString(g_height, "WindowHeight") Or FindString(g_height, "GadgetHeight") Or FindString(g_height, "GetGadgetAttribute")
              FormWindows()\FormGadgets()\lock_top = 1
              FormWindows()\FormGadgets()\lock_bottom = 1
            EndIf
            
            Break
          EndIf
        Next
        Continue
      EndIf ;}
      
      
    Until end_condition
    
    If Not update
      CloseFile(handle)
    EndIf
    
    ; images are stored in a temp list as they can be loaded before the window is opened
    ; after the file is loaded, the following code sort up the image list
    CopyList(OpenTempImg(),FormWindows()\FormImg())
    
    ForEach FormWindows()\FormToolbars()
      If FormWindows()\FormToolbars()\img
        SelectElement(FormWindows()\FormImg(),FormWindows()\FormToolbars()\img - 1)
        FormWindows()\FormToolbars()\img = @FormWindows()\FormImg()
      EndIf
    Next
    
    ForEach FormWindows()\FormGadgets()
      If FormWindows()\FormGadgets()\image
        SelectElement(FormWindows()\FormImg(),FormWindows()\FormGadgets()\image - 1)
        FormWindows()\FormGadgets()\image = @FormWindows()\FormImg()
      EndIf
      
      ;       If Not FormWindows()\FormGadgets()\lock_left
      ;         If FormWindows()\FormGadgets()\parent
      ;           PushListPosition(FormWindows()\FormGadgets())
      ;           FindParent(FormWindows()\FormGadgets()\parent)
      ;           width = FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1
      ;           PopListPosition(FormWindows()\FormGadgets())
      ;
      ;           FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1
      ;           FormWindows()\FormGadgets()\x1 = width - FormWindows()\FormGadgets()\x1
      ;           FormWindows()\FormGadgets()\x2 + FormWindows()\FormGadgets()\x1
      ;         Else
      ;           FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1
      ;           FormWindows()\FormGadgets()\x1 = FormWindows()\width - FormWindows()\FormGadgets()\x1
      ;           FormWindows()\FormGadgets()\x2 + FormWindows()\FormGadgets()\x1
      ;         EndIf
      ;       EndIf
      ;
      ;       If Not FormWindows()\FormGadgets()\lock_top
      ;         If FormWindows()\FormGadgets()\parent
      ;           PushListPosition(FormWindows()\FormGadgets())
      ;           FindParent(FormWindows()\FormGadgets()\parent)
      ;           height = FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1
      ;
      ;           If FormWindows()\FormGadgets()\type = #Form_Type_Panel
      ;             height - Panel_Height
      ;           EndIf
      ;
      ;           PopListPosition(FormWindows()\FormGadgets())
      ;           FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1
      ;           FormWindows()\FormGadgets()\y1 = height - FormWindows()\FormGadgets()\y1
      ;           FormWindows()\FormGadgets()\y2 + FormWindows()\FormGadgets()\y1
      ;         Else
      ;           FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1
      ;           FormWindows()\FormGadgets()\y1 = FormWindows()\height - FormWindows()\FormGadgets()\y1
      ;           FormWindows()\FormGadgets()\y2 + FormWindows()\FormGadgets()\y1
      ;         EndIf
      ;       EndIf
      ;
      ;       If FormWindows()\FormGadgets()\lock_left And FormWindows()\FormGadgets()\lock_right
      ;         If FormWindows()\FormGadgets()\parent
      ;           PushListPosition(FormWindows()\FormGadgets())
      ;           FindParent(FormWindows()\FormGadgets()\parent)
      ;           width = FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1
      ;           PopListPosition(FormWindows()\FormGadgets())
      ;
      ;           FormWindows()\FormGadgets()\x2 = FormWindows()\FormGadgets()\x1 + width - (FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1)
      ;         Else
      ;           FormWindows()\FormGadgets()\x2 = FormWindows()\FormGadgets()\x1 + FormWindows()\width - (FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1)
      ;         EndIf
      ;       EndIf
      ;
      ;       If FormWindows()\FormGadgets()\lock_top And FormWindows()\FormGadgets()\lock_bottom
      ;         If FormWindows()\FormGadgets()\parent
      ;           PushListPosition(FormWindows()\FormGadgets())
      ;           FindParent(FormWindows()\FormGadgets()\parent)
      ;           height = FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1
      ;
      ;           If FormWindows()\FormGadgets()\type = #Form_Type_Panel
      ;             height - Panel_Height
      ;           EndIf
      ;
      ;           PopListPosition(FormWindows()\FormGadgets())
      ;           FormWindows()\FormGadgets()\y2 = FormWindows()\FormGadgets()\y1 + height - (FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1)
      ;         Else
      ;           height = FormWindows()\height
      ;
      ;           If ListSize(FormWindows()\FormStatusbars())
      ;             height - P_Status
      ;           EndIf
      ;
      ;           If FormSkin <> #PB_OS_MacOS
      ;             If ListSize(FormWindows()\FormMenus())
      ;               height - P_Menu
      ;             EndIf
      ;
      ;             If ListSize(FormWindows()\FormToolbars())
      ;               toptoolpadding = 16
      ;               toptoolpadding + 6
      ;             Else
      ;               toptoolpadding = 0
      ;             EndIf
      ;             height - toptoolpadding
      ;           EndIf
      ;
      ;           FormWindows()\FormGadgets()\y2 = FormWindows()\FormGadgets()\y1 + height - (FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1)
      ;         EndIf
      ;       EndIf
    Next
    
    ForEach FormWindows()\FormMenus()
      If FormWindows()\FormMenus()\icon
        SelectElement(FormWindows()\FormImg(),FormWindows()\FormMenus()\icon - 1)
        FormWindows()\FormMenus()\icon = @FormWindows()\FormImg()
      EndIf
    Next
    
    ForEach FormWindows()\FormStatusbars()
      If FormWindows()\FormStatusbars()\img
        SelectElement(FormWindows()\FormImg(),FormWindows()\FormStatusbars()\img - 1)
        FormWindows()\FormStatusbars()\img = @FormWindows()\FormImg()
      EndIf
    Next
    
    FD_UpdateObjList()
    FD_UpdateScrollbars()
    FD_SelectWindow(currentwindow)
    
    If FormWindows()\current_view = 1
      FD_SelectCode()
    Else
      redraw = 1
    EndIf
  EndIf
EndProcedure

Procedure FD_UpdateCode()
  FD_Open(FormWindows()\current_file,1)
EndProcedure

Procedure.b FD_VersionCheck(FileName.s)
  ; Check the designer statement for compatibility problems.
  ; Returns a #PB_MessageRequester_* value from the message requester. 
  ; (#PB_MessageRequester_Yes if no problems found or preferences prohibit a warning).
  
  Define.i File, Format, TagPosition, VerPosition, DotPosition, FileVersion, Loop, Max, MayBreak, Icon, Warn, Result
  Define VerString$, Message$
  
  ; List of compatibility breaking version numbers.
  ; If any form designer code changes or new features will break backward compatibility with earlier versions, add the version number to this Array.
  Static Dim Breaks(2)
  If Breaks(0) = 0
    Breaks(0) = 610 ; WebViewGadget support.
    Breaks(1) = 621 ; Custom Flags for OpenWindow and other new flags.
  EndIf
  
  If FileSize(FileName) <= 0
    ProcedureReturn #PB_MessageRequester_Yes
  EndIf
  
  ; Extract the version content from the first non blank line of the source file.
  File = OpenFile(#PB_Any, FileName)
  Format = ReadStringFormat(File)
  Repeat 
    VerString$ = ReadString(File, Format)
  Until VerString$ <> #Empty$
  CloseFile(File)
  
  TagPosition = FindString(VerString$, "; Form Designer")
  VerPosition = FindString(VerString$, "- ")
  
  ; Check for problems and warnings.
  If TagPosition And VerPosition
    
    ; Reformat so that it matches the compiler and version constants.
    VerString$ = Mid(VerString$, VerPosition + 2)
    FileVersion = Int(ValD(VerString$) * 100.0)
    
    ; Check for a backward compatibility issue.
    MayBreak = #False
    Max = ArraySize(Breaks())
    For Index = 0 To Max
      If FileVersion < Breaks(Index)
        MayBreak = #True
        Break
      EndIf
    Next Index
    
    If FileVersion = #PB_Compiler_Version
      ; Matching version, no need to prompt.
      Warn = #False
      Result = #PB_MessageRequester_Yes
      
    ElseIf FileVersion > #PB_Compiler_Version 
      ; This is a downgrade.
      
      If (FormVersionWarnings & #FDI_Warn_DowngradeAlways) = 0
        ; Downgrade warnings are off.
        Warn = #False
        Result = #PB_MessageRequester_Yes
        
      Else
        ; Downgrade warnings are on.
        Warn = #True
        Icon = #FLAG_Warning
        Message$ = ReplaceString(ReplaceString(Language("Form", "MessageNewer"), "%newline%",  #LF$), "%s%", VerString$)
        
      EndIf
      
    ElseIf FileVersion < #PB_Compiler_Version 
      ; This is an upgrade.
      
      If FormVersionWarnings & (#FDI_Warn_UpgradeBreaking | #FDI_Warn_UpgradeAlways) = 0
        ; Upgrade warnings are off.
        Warn = #False
        Result = #PB_MessageRequester_Yes
            
      ElseIf (FormVersionWarnings & #FDI_Warn_UpgradeBreaking) = #FDI_Warn_UpgradeBreaking And MayBreak = #False
        ; Non-breaking warnings are off.
        Warn = #False
        Result = #PB_MessageRequester_Yes
        
      ElseIf (FormVersionWarnings & (#FDI_Warn_UpgradeBreaking | #FDI_Warn_UpgradeAlways)) > 0 And MayBreak = #True
        ; Breaking warnings are on and a break is possible.
        Warn = #True
        Icon = #FLAG_Warning
        Message$ = ReplaceString(ReplaceString(Language("Form", "MessageBackward"), "%newline%",  #LF$), "%s%", VerString$)
      
      ElseIf (FormVersionWarnings & #FDI_Warn_UpgradeAlways) = #FDI_Warn_UpgradeAlways
        ; Upgrade warnings are always on.
        Warn = #True
        Icon = #FLAG_Warning
        Message$ = ReplaceString(ReplaceString(Language("Form", "MessageOlder"), "%newline%",  #LF$), "%s%", VerString$)
        
      EndIf
      
    EndIf
    
  ElseIf (FormVersionWarnings & #FDI_Warn_NotRecognized) = #FDI_Warn_NotRecognized
    ; The form designer version line wasn't found, probably not a designer file.
    Warn = #True
    Icon = #FLAG_Warning
    Message$ = ReplaceString(Language("Form", "MessageNotDesign"), "%newline%",  #LF$)
    
  EndIf
  
  If Warn
    Message$ + #LF$ + Language("Misc", "MessageContinue")
    Result = MessageRequester(#ProductName$, Message$, Icon | #PB_MessageRequester_YesNo)
  EndIf
  
  ProcedureReturn Result
  
EndProcedure
