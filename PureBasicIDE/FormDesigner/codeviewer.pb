; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software and Gaetan DUPONT-PANON. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


Procedure.s FD_SelectCode(contentonly = 0, testcode = 0)
  If Not contentonly
    ;     HideGadget(#Form_ContDraw,1)
    ;     DisableGadget(#Form_ContDraw,1)
    ;     HideGadget(#Form_ContCode,0)
    ;     DisableGadget(#Form_ContCode,0)
    ;     TE_ClearGadgetItems(code_gadget)
  EndIf
  
  CleanImageList()
  
  firstwindow = 1
  NewList ContainerLevel.i()
  NewList Procs.s()
  NewList Img.FormImg()
  NewList Fonts.fontlist()
  NewList MenuVars.twostring()
  
  windowvar.s = "" : gadgetvar.s = "" : imgvar.s = ""
  windowenum.s = "" : gadgetenum.s = "" : imgenum.s = ""
  menuenum.s = ""
  cust_gadget_init.s = ""
  imagecount.i = 0
  toolbarcount = 0
  statusbarcount = 0
  fontcount = 0
  scintilla = 0
  codegenresize = 0
  
  If FormWindows()\pbany
    If windowvar <> ""
      windowvar + ", "
    EndIf
    
    windowvar + FormWindows()\variable
  Else
    windowenum + "  #" + FormWindows()\variable + #Endline
  EndIf
  
  ForEach FormWindows()\FormMenus()
    If FormWindows()\FormMenus()\id <> ""
      menuenum + "  " + FormWindows()\FormMenus()\id + #Endline
      AddElement(MenuVars())
      MenuVars()\a = FormWindows()\FormMenus()\id
      MenuVars()\b = FormWindows()\FormMenus()\event
    EndIf
  Next
  
  ForEach FormWindows()\FormGadgets()
    If FormWindows()\FormGadgets()\type = #Form_Type_Scintilla
      scintilla = 1
    EndIf
    
    If FormWindows()\FormGadgets()\pbany
      If gadgetvar <> ""
        gadgetvar + ", "
      EndIf
      
      gadgetvar + FormWindows()\FormGadgets()\variable
    Else
      gadgetenum + "  #" + FormWindows()\FormGadgets()\variable + #Endline
    EndIf
    
    If FormWindows()\FormGadgets()\cust_init <> ""
      cust_gadget_init + "; " + Str(ListIndex(FormWindows()\FormGadgets())) + " Custom gadget initialisation (do Not remove this line)" + #Endline + FormWindows()\FormGadgets()\cust_init + #Endline
    EndIf
    
    If FormWindows()\FormGadgets()\gadgetfont <> ""
      found = 0
      ForEach Fonts()
        If Fonts()\flags = FormWindows()\FormGadgets()\gadgetfontflags And Fonts()\name = FormWindows()\FormGadgets()\gadgetfont And Fonts()\size = FormWindows()\FormGadgets()\gadgetfontsize
          found = 1
          Break
        EndIf
      Next
      
      If Not found
        AddElement(Fonts())
        Fonts()\flags = FormWindows()\FormGadgets()\gadgetfontflags
        Fonts()\name = FormWindows()\FormGadgets()\gadgetfont
        Fonts()\size = FormWindows()\FormGadgets()\gadgetfontsize
        Fonts()\id = "#Font_" + FormWindows()\variable + "_" + Str(fontcount)
        fontcount + 1
      EndIf
    EndIf
  Next
  
  ForEach FormWindows()\FormToolbars()
    If FormWindows()\FormToolbars()\id <> ""
      searchduplicate = 0
      ForEach FormWindows()\FormMenus()
        If FormWindows()\FormToolbars()\id = FormWindows()\FormMenus()\id
          searchduplicate = 1
          
          If FormWindows()\FormToolbars()\event <> ""
            ForEach MenuVars()
              If MenuVars()\a = FormWindows()\FormToolbars()\id
                If MenuVars()\b = ""
                  MenuVars()\b = FormWindows()\FormToolbars()\event
                EndIf
                
                Break
              EndIf
            Next
          EndIf
          
          Break
        EndIf
      Next
      
      If Not searchduplicate And Not FormWindows()\FormToolbars()\separator
        menuenum + "  " + FormWindows()\FormToolbars()\id + #Endline
        LastElement(MenuVars())
        AddElement(MenuVars())
        MenuVars()\a = FormWindows()\FormToolbars()\id
        MenuVars()\b = FormWindows()\FormToolbars()\event
      EndIf
    EndIf
  Next
  
  ForEach FormWindows()\FormImg()
    AddElement(Img())
    Img()\img = FormWindows()\FormImg()\img
    
    If FormWindows()\FormImg()\pbany
      Img()\id = "Img_" + FormWindows()\variable + "_" + Str(ListIndex(FormWindows()\FormImg()))
      
      If imgvar <> ""
        imgvar + ", "
      EndIf
      
      imgvar + Img()\id
    Else
      Img()\id = "#Img_" + FormWindows()\variable + "_" + Str(ListIndex(FormWindows()\FormImg()))
      imgenum + "  " + Img()\id + #Endline
    EndIf
    
    Img()\inline = FormWindows()\FormImg()\inline
    Img()\pbany = FormWindows()\FormImg()\pbany
  Next
  
  MajorVersion = #PB_Compiler_Version/100
  MinorVersion = #PB_Compiler_Version - MajorVersion*100
  
  content.s = "; Form Designer for PureBasic - " + MajorVersion + "." +RSet(Str(MinorVersion), 2, "0") + #Endline +
              "; Warning: this file uses a strict syntax, if you edit it, make sure to respect the Form Designer limitation or it won't be opened again." + #Endline +
              #Endline +
              ";" + #Endline +
              "; This code is automatically generated by the Form Designer." + #Endline +
              "; Manual modification is possible to adjust existing commands, but anything else will be dropped when the code is compiled." + #Endline +
              "; Event procedures need to be put in another source file." + #Endline +
              ";" + #Endline + #Endline
  
  If windowvar <> ""
    content + "Global "+windowvar + #Endline
    content + "" + #Endline
  EndIf
  If gadgetvar <> ""
    content + "Global "+gadgetvar + #Endline
    content + "" + #Endline
  EndIf
  If imgvar <> ""
    content + "Global "+imgvar + #Endline
    content + "" + #Endline
  EndIf
  If windowenum <> ""
    content + "Enumeration FormWindow" + #Endline
    content + windowenum
    content + "EndEnumeration" + #Endline
    content + "" + #Endline
  EndIf
  If gadgetenum <> ""
    content + "Enumeration FormGadget" + #Endline
    content + gadgetenum
    content + "EndEnumeration" + #Endline
    content + "" + #Endline
  EndIf
  If menuenum <> ""
    content + "Enumeration FormMenu" + #Endline
    content + menuenum
    content + "EndEnumeration" + #Endline
    content + "" + #Endline
  EndIf
  If imgenum <> ""
    content + "Enumeration FormImage" + #Endline
    content + imgenum
    content + "EndEnumeration" + #Endline
    content + "" + #Endline
  EndIf
  
  num = CountString(cust_gadget_init,#Endline)
  If num
    For i = 1 To num
      content + StringField(cust_gadget_init,i,#Endline) + #Endline
    Next
    content + "" + #Endline
  EndIf
  
  If ListSize(Img())
    ;check if image decoder is required
    jpgdecoder.b = 0 : pngdecoder.b = 0 : tgadecoder.b = 0 : tiffdecoder.b = 0
    ForEach Img()
      img.s = LCase(Img()\img)
      If Not jpgdecoder And (FindString(img,"jpg") Or FindString(img,"jpeg"))
        jpgdecoder = 1
      EndIf
      If Not pngdecoder And (FindString(img,"png"))
        pngdecoder = 1
      EndIf
      If Not tgadecoder And (FindString(img,"tga"))
        tgadecoder = 1
      EndIf
      If Not tiffdecoder And (FindString(img,"tiff"))
        tiffdecoder = 1
      EndIf
    Next
    
    If jpgdecoder
      content + "UseJPEGImageDecoder()" + #Endline
    EndIf
    If pngdecoder
      content + "UsePNGImageDecoder()" + #Endline
    EndIf
    If tgadecoder
      content + "UseJTAImageDecoder()" + #Endline
    EndIf
    If tiffdecoder
      content + "UseTIFFImageDecoder()" + #Endline
    EndIf
    
    If jpgdecoder Or pngdecoder Or tgadecoder Or tiffdecoder
      content + "" + #Endline
    EndIf
    
    ; load images
    ForEach Img()
      If Img()\pbany
        If Img()\inline
          image_id.s = Img()\id
          
          If Left(image_id, 1) = "#"
            image_id = Right(image_id, Len(image_id) - 1)
          EndIf
          
          content +  Img()\id + " = CatchImage(#PB_Any,?" + image_id + ")" + #Endline
        Else
          content +  Img()\id + " = LoadImage(#PB_Any,"+Chr(34)+Img()\img+Chr(34)+")" + #Endline
        EndIf
      Else
        If Img()\inline
          image_id.s = Img()\id
          
          If Left(image_id, 1) = "#"
            image_id = Right(image_id, Len(image_id) - 1)
          EndIf
          
          content +  "CatchImage("+Img()\id+",?" + image_id + ")" + #Endline
        Else
          content + "LoadImage("+Img()\id+","+Chr(34)+Img()\img+Chr(34)+")" + #Endline
        EndIf
      EndIf
      
    Next
    content +"" + #Endline
  EndIf
  
  If ListSize(Fonts())
    ; enumeration of font ID
    content +"Enumeration FormFont" + #Endline
    ForEach Fonts()
      content +"  "+Fonts()\id + #Endline
    Next
    content +"EndEnumeration" + #Endline
    content +"" + #Endline
    
    ; load fonts
    ForEach Fonts()
      flags.s = ""
      If Fonts()\flags & FlagValue("#PB_Font_Bold")
        flags + "#PB_Font_Bold"
      EndIf
      If Fonts()\flags & FlagValue("#PB_Font_Italic")
        If flags <> ""
          flags + " | "
        EndIf
        flags + "#PB_Font_Italic"
      EndIf
      If Fonts()\flags & FlagValue("#PB_Font_StrikeOut")
        If flags <> ""
          flags + " | "
        EndIf
        flags + "#PB_Font_StrikeOut"
      EndIf
      If Fonts()\flags & FlagValue("#PB_Font_Underline")
        If flags <> ""
          flags + " | "
        EndIf
        flags + "#PB_Font_Underline"
      EndIf
      If flags <> ""
        flags = ", " + flags
      EndIf
      
      content + "LoadFont("+Fonts()\id+","+Chr(34)+Fonts()\name+Chr(34)+", "+Str(Fonts()\size)+flags+")" + #Endline
    Next
    content +"" + #Endline
  EndIf
  
  
  ForEach FormWindows()\FormGadgets()
    ; only declare callbacks for scintilla if user press run so that form can still be tested.
    If FormWindows()\FormGadgets()\type = #Form_Type_Scintilla And testcode
      If FormWindows()\FormGadgets()\caption <> "" And FormWindows()\FormGadgets()\caption <> "0"
        content +"ProcedureDLL "+Left(FormWindows()\FormGadgets()\caption,Len(FormWindows()\FormGadgets()\caption)-1)+"Gadget, *scinotify.SCNotification)" + #Endline
        content +"  " + #Endline
        content +"EndProcedure" + #Endline
        content +"" + #Endline
      EndIf
    EndIf
  Next
  
  ForEach FormWindows()\FormGadgets()
    If FormWindows()\FormGadgets()\lock_bottom Or FormWindows()\FormGadgets()\lock_right
      codegenresize = 1
      Break
    EndIf
  Next
  
  If codegenresize
    content + "Declare ResizeGadgets" + FormWindows()\variable + "()" + #Endline + #Endline
  EndIf
  
  
  ; Declare all event procedures
  ; The map is used to easily remove duplicates, when a procedure is used for several gadgets.
  
  ; Menus
  
  NewMap FormProcedures.s()
  ForEach MenuVars()
    If MenuVars()\b <> ""
      procedurestring.s = "Declare " + MenuVars()\b + "(Event)" + #Endline
      FormProcedures(procedurestring) = procedurestring
    EndIf
  Next
  
  ForEach FormProcedures()
    content + FormProcedures()
  Next
  ClearMap(FormProcedures())
  
  
  ; Gadgets
  ForEach FormWindows()\FormGadgets()
    If FormWindows()\FormGadgets()\event_proc
      procedurestring.s = "Declare " + FormWindows()\FormGadgets()\event_proc + "(EventType)" + #Endline
      FormProcedures(procedurestring) = procedurestring
    EndIf
  Next
  
  ForEach FormProcedures()
    content + FormProcedures()
  Next
  ClearMap(FormProcedures())
  
  ; Window
  If FormWindows()\event_proc
    procedurestring.s = "Declare " + FormWindows()\event_proc + "(Event, Window)" + #Endline
    FormProcedures(procedurestring) = procedurestring
  EndIf
  
  ForEach FormProcedures()
    content + FormProcedures()
  Next
  ClearMap(FormProcedures())
  
  content + #Endline
  
  If FormWindows()\pbany
    winid.s = FormWindows()\variable
  Else
    winid.s = "#"+FormWindows()\variable
  EndIf
  
  
  ForEach ObjList()
    If ObjList()\window = @FormWindows()
      
      ForEach ContainerLevel()
        If ObjList()\level <= ContainerLevel()
          content + "  CloseGadgetList()" + #Endline
          DeleteElement(ContainerLevel())
        EndIf
      Next
      
      If ObjList()\gadget
        codepaddingy.s = ""
        codepaddingheight.s = ""
        If ObjList()\level <= 1
          ; add correct padding to gadget coordinates, only if they are in the window gadget list
          codepaddingy.s = ""
          If ListSize(FormWindows()\FormMenus())
            ;codepaddingy + "MenuHeight()"
            codepaddingheight + " - MenuHeight()"
          EndIf
          If ListSize(FormWindows()\FormToolbars())
            If FormSkin = #PB_OS_Windows
              If codepaddingy <> ""
                codepaddingy + " + "
              EndIf
              codepaddingy + "ToolBarHeight("+Str(toolbarcount - 1)+")"
              codepaddingheight + " - ToolBarHeight("+Str(toolbarcount - 1)+")"
            EndIf
          EndIf
          If ListSize(FormWindows()\FormStatusbars())
            codepaddingheight + " - StatusBarHeight("+Str(statusbarcount - 1)+")"
          EndIf
          If codepaddingy <> ""
            codepaddingy + " + "
          EndIf
          
        EndIf
        
        ChangeCurrentElement(FormWindows()\FormGadgets(),ObjList()\gadget)
        
        If FormWindows()\FormGadgets()\type = #Form_Type_Custom
          line.s = "  "+FormWindows()\FormGadgets()\cust_create
          
          If FormWindows()\FormGadgets()\pbany
            line = ReplaceString(line,"%id%",FormWindows()\FormGadgets()\variable)
          Else
            line = ReplaceString(line,"%id%","#"+FormWindows()\FormGadgets()\variable)
          EndIf
          
          line = ReplaceString(line,"%x%",Str(DesktopUnscaledX(FormWindows()\FormGadgets()\x1)))
          line = ReplaceString(line,"%y%",codepaddingy + Str(DesktopUnscaledY(FormWindows()\FormGadgets()\y1)))
          line = ReplaceString(line,"%w%",Str(DesktopUnscaledX(FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1)))
          line = ReplaceString(line,"%h%",Str(DesktopUnscaledY(FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1)))
          
          If FormWindows()\FormGadgets()\pbany
            line = ReplaceString(line,"%hwnd%",FormWindows()\FormGadgets()\variable)
          Else
            line = ReplaceString(line,"%hwnd%","#"+FormWindows()\FormGadgets()\variable)
          EndIf
          
          If FormWindows()\FormGadgets()\captionvariable
            line = ReplaceString(line,"%txt%",FormWindows()\FormGadgets()\caption)
          Else
            line = ReplaceString(line,"%txt%",Chr(34)+FormWindows()\FormGadgets()\caption+Chr(34))
          EndIf
          
          content + "  ; "+Str(ListIndex(FormWindows()\FormGadgets())) + " Custom gadget creation (do not remove this line) " + FormWindows()\FormGadgets()\cust_create + #Endline + line + #Endline
        Else
          If ObjList()\gadget_item > -1
            Debug ObjList()\name
            line.s = "  AddGadgetItem("
            
            SelectElement(FormWindows()\FormGadgets()\Items(),ObjList()\gadget_item)
            
            If FormWindows()\FormGadgets()\pbany
              line + FormWindows()\FormGadgets()\variable
            Else
              line + "#" + FormWindows()\FormGadgets()\variable
            EndIf
            
            If FormWindows()\FormGadgets()\type <> #Form_Type_Panel
              itemstring.s = ReplaceString(ObjList()\name,"|",Chr(34) + " + Chr(10) + " + Chr(34))
            Else
              itemstring.s = ObjList()\name
            EndIf
            
            line + ", -1, "+Chr(34)+itemstring+Chr(34)
            
            If FormWindows()\FormGadgets()\Items()\level > 0
              line + ", 0, " + Str(FormWindows()\FormGadgets()\Items()\level)
            EndIf
            
            line + ")"
            content + line + #Endline
          Else
            If FormWindows()\FormGadgets()\type = #Form_Type_Container Or FormWindows()\FormGadgets()\type = #Form_Type_Panel Or FormWindows()\FormGadgets()\type = #Form_Type_ScrollArea
              AddElement(ContainerLevel())
              ContainerLevel() = ObjList()\level
            ElseIf FormWindows()\FormGadgets()\type = #Form_Type_Frame3D
              If FormWindows()\FormGadgets()\flags & #PB_Frame_Container
                AddElement(ContainerLevel())
                ContainerLevel() = ObjList()\level
              EndIf
            EndIf
            
            
            If FormWindows()\FormGadgets()\pbany
              line.s = FormWindows()\FormGadgets()\variable + " = "
            Else
              line.s = ""
            EndIf
            
            Select FormWindows()\FormGadgets()\type ;{ procedure name
              Case #Form_Type_Button
                line + "ButtonGadget("
              Case #Form_Type_ButtonImg
                line + "ButtonImageGadget("
              Case #Form_Type_StringGadget
                line + "StringGadget("
              Case #Form_Type_Checkbox
                line + "CheckBoxGadget("
              Case #Form_Type_Text
                line + "TextGadget("
              Case #Form_Type_Option
                line + "OptionGadget("
              Case #Form_Type_TreeGadget
                line + "TreeGadget("
              Case #Form_Type_ListView
                line + "ListViewGadget("
              Case #Form_Type_ListIcon
                line + "ListIconGadget("
              Case #Form_Type_Combo
                line + "ComboBoxGadget("
              Case #Form_Type_Spin
                line + "SpinGadget("
              Case #Form_Type_Trackbar
                line + "TrackBarGadget("
              Case #Form_Type_ProgressBar
                line + "ProgressBarGadget("
              Case #Form_Type_Img
                line + "ImageGadget("
              Case #Form_Type_IP
                line + "IPAddressGadget("
              Case #Form_Type_Scrollbar
                line + "ScrollBarGadget("
              Case #Form_Type_HyperLink
                line + "HyperLinkGadget("
              Case #Form_Type_Editor
                line + "EditorGadget("
              Case #Form_Type_ExplorerTree
                line + "ExplorerTreeGadget("
              Case #Form_Type_ExplorerList
                line + "ExplorerListGadget("
              Case #Form_Type_ExplorerCombo
                line + "ExplorerComboGadget("
              Case #Form_Type_Date
                line + "DateGadget("
              Case #Form_Type_Calendar
                line + "CalendarGadget("
              Case #Form_Type_Scintilla
                line + "ScintillaGadget("
              Case #Form_Type_Splitter
                line + "SplitterGadget("
              Case #Form_Type_Frame3D
                line + "FrameGadget("
              Case #Form_Type_ScrollArea
                line + "ScrollAreaGadget("
              Case #Form_Type_Web
                line + "WebGadget("
              Case #Form_Type_WebView
                line + "WebViewGadget("
              Case #Form_Type_Container
                line + "ContainerGadget("
              Case #Form_Type_Panel
                line + "PanelGadget("
              Case #Form_Type_Canvas
                line + "CanvasGadget("
              Case #Form_Type_OpenGL
                line + "OpenGLGadget("
                ;}
            EndSelect
            
            If FormWindows()\FormGadgets()\pbany
              variable.s = "#PB_Any"
            Else
              variable.s = "#" + FormWindows()\FormGadgets()\variable
            EndIf
            
            line.s + variable + ", "
            linevars.s = ""
            
            If FormWindows()\pbany
              winvar.s = FormWindows()\variable
            Else
              winvar.s = "#" + FormWindows()\variable
            EndIf
            
            ; x
            If FormWindows()\FormGadgets()\lock_left ;{
              linevars + Str(DesktopUnscaledX(FormWindows()\FormGadgets()\x1))+", "
            Else
              If FormWindows()\FormGadgets()\parent
                PushListPosition(FormWindows()\FormGadgets())
                FD_FindParent(FormWindows()\FormGadgets()\parent)
                
                If FormWindows()\FormGadgets()\pbany
                  gadgetvar.s = FormWindows()\FormGadgets()\variable
                Else
                  gadgetvar.s = "#" + FormWindows()\FormGadgets()\variable
                EndIf
                
                If FormWindows()\FormGadgets()\type = #Form_Type_Panel
                  linevars + "GetGadgetAttribute("+gadgetvar+",#PB_Panel_ItemWidth) - "
                Else
                  linevars + "GadgetWidth("+gadgetvar+") - "
                EndIf
                tempvalue = FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1
                PopListPosition(FormWindows()\FormGadgets())
                
                linevars + Str(DesktopUnscaledX(tempvalue - FormWindows()\FormGadgets()\x1)) + ", "
              Else
                linevars + "FormWindowWidth - " + Str(DesktopUnscaledX(FormWindows()\width - FormWindows()\FormGadgets()\x1))+", "
              EndIf
            EndIf ;}
            
            ; y
            If FormWindows()\FormGadgets()\lock_top ;{
              linevars + codepaddingy + Str(FormWindows()\FormGadgets()\y1)+", "
            Else
              If FormWindows()\FormGadgets()\parent
                PushListPosition(FormWindows()\FormGadgets())
                FD_FindParent(FormWindows()\FormGadgets()\parent)
                
                If FormWindows()\FormGadgets()\pbany
                  gadgetvar.s = FormWindows()\FormGadgets()\variable
                Else
                  gadgetvar.s = "#" + FormWindows()\FormGadgets()\variable
                EndIf
                
                If FormWindows()\FormGadgets()\type = #Form_Type_Panel
                  linevars + codepaddingy + "GetGadgetAttribute("+gadgetvar+",#PB_Panel_ItemHeight) - "
                Else
                  linevars + codepaddingy + "GadgetHeight("+gadgetvar+") - "
                EndIf
                
                tempvalue = FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1
                
                If FormWindows()\FormGadgets()\type = #Form_Type_Panel
                  tempvalue - Panel_Height
                EndIf
                PopListPosition(FormWindows()\FormGadgets())
                
                linevars + Str(tempvalue - FormWindows()\FormGadgets()\y1) + ", "
              Else
                linevars + codepaddingy + "FormWindowHeight - " + Str(FormWindows()\height - FormWindows()\FormGadgets()\y1)+", "
              EndIf
            EndIf ;}
            
            ; width
            If FormWindows()\FormGadgets()\lock_right And FormWindows()\FormGadgets()\lock_left ;{
              If FormWindows()\FormGadgets()\parent
                PushListPosition(FormWindows()\FormGadgets())
                FD_FindParent(FormWindows()\FormGadgets()\parent)
                
                If FormWindows()\FormGadgets()\pbany
                  gadgetvar.s = FormWindows()\FormGadgets()\variable
                Else
                  gadgetvar.s = "#" + FormWindows()\FormGadgets()\variable
                EndIf
                
                If FormWindows()\FormGadgets()\type = #Form_Type_Panel
                  linevars + "GetGadgetAttribute("+gadgetvar+",#PB_Panel_ItemWidth) - "
                Else
                  linevars + "GadgetWidth("+gadgetvar+") - "
                EndIf
                tempvalue = FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1
                PopListPosition(FormWindows()\FormGadgets())
                
                linevars + Str(DesktopUnscaledX(tempvalue - (FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1))) + ", "
              Else
                linevars + "FormWindowWidth - " + Str(DesktopUnscaledX(FormWindows()\width - (FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1)))+", "
              EndIf
            Else
              linevars + Str(DesktopUnscaledX(FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1))+", "
            EndIf ;}
            
            ; height
            If FormWindows()\FormGadgets()\lock_top And FormWindows()\FormGadgets()\lock_bottom ;{
              If FormWindows()\FormGadgets()\parent
                PushListPosition(FormWindows()\FormGadgets())
                FD_FindParent(FormWindows()\FormGadgets()\parent)
                
                If FormWindows()\FormGadgets()\pbany
                  gadgetvar.s = FormWindows()\FormGadgets()\variable
                Else
                  gadgetvar.s = "#" + FormWindows()\FormGadgets()\variable
                EndIf
                
                If FormWindows()\FormGadgets()\type = #Form_Type_Panel
                  linevars + "GetGadgetAttribute("+gadgetvar+",#PB_Panel_ItemHeight) - "
                Else
                  linevars + "GadgetHeight("+gadgetvar+") - "
                EndIf
                tempvalue = FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1
                
                If FormWindows()\FormGadgets()\type = #Form_Type_Panel
                  tempvalue - Panel_Height
                EndIf
                
                PopListPosition(FormWindows()\FormGadgets())
                
                linevars + Str(tempvalue - (FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1))
              Else
                ;- Change height menu and toolbar calc
                value = FormWindows()\height - (FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1)
                If FormSkin = #PB_OS_Windows

                  value - bottompaddingsb - toptoolpadding
                  If ListSize(FormWindows()\FormMenus())
                    value - P_Menu
                  EndIf
                ElseIf FormSkin = #PB_OS_Linux
                  value - bottompaddingsb
                  If ListSize(FormWindows()\FormMenus())
                    value - P_Menu
                  EndIf
                Else
                  value - bottompaddingsb
                EndIf
                
                If codepaddingheight <> ""
                  linevars + "FormWindowHeight" + codepaddingheight + " - " + Str(value)
                Else
                  linevars + "FormWindowHeight - " + Str(value)
                EndIf
                
              EndIf
            Else
              linevars + Str(FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1)
            EndIf ;}
            
            line + Str(DesktopUnscaledX(FormWindows()\FormGadgets()\x1)) + ", " + codepaddingy + Str(DesktopUnscaledY(FormWindows()\FormGadgets()\y1)) + ", " + Str(DesktopUnscaledX(FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1)) + ", " + Str(DesktopUnscaledY(FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1))
            
            If (FormWindows()\FormGadgets()\lock_right And FormWindows()\FormGadgets()\lock_left) Or
               (FormWindows()\FormGadgets()\lock_top And FormWindows()\FormGadgets()\lock_bottom) Or
               (Not FormWindows()\FormGadgets()\lock_top And FormWindows()\FormGadgets()\lock_bottom) Or
               (FormWindows()\FormGadgets()\lock_right And Not FormWindows()\FormGadgets()\lock_left)
              
              If FormWindows()\FormGadgets()\pbany
                contentsize.s + "  ResizeGadget(" + FormWindows()\FormGadgets()\variable + ", " + linevars + ")" + #Endline
              Else
                contentsize.s + "  ResizeGadget(#" + FormWindows()\FormGadgets()\variable + ", " + linevars + ")" + #Endline
              EndIf
            EndIf
            
            
            flags.s = ""
            ForEach Gadgets()
              If Gadgets()\type = FormWindows()\FormGadgets()\type
                ForEach Gadgets()\Flags()
                  If FormWindows()\FormGadgets()\flags & Gadgets()\Flags()\ivalue
                    If flags <> ""
                      flags + " | "
                    EndIf
                    flags + Gadgets()\Flags()\name
                  EndIf
                Next
              EndIf
            Next
            If flags
              flags = ", "+flags
            EndIf
            
            ; add caption for the gadgets who requires it.
            Select FormWindows()\FormGadgets()\type ;{
              Case #Form_Type_Web, #Form_Type_Frame3D, #Form_Type_ExplorerCombo, #Form_Type_ExplorerList, #Form_Type_ExplorerTree, #Form_Type_HyperLink, #Form_Type_Button, #Form_Type_StringGadget, #Form_Type_Checkbox, #Form_Type_Text, #Form_Type_Option, #Form_Type_Date
                If FormWindows()\FormGadgets()\captionvariable
                  If FormWindows()\FormGadgets()\caption = ""
                    line + ", "+Chr(34)+Chr(34)
                  Else
                    line + ", "+FormWindows()\FormGadgets()\caption
                  EndIf
                Else
                  line + ", "+Chr(34)+FormWindows()\FormGadgets()\caption+Chr(34)
                EndIf
            EndSelect ;}
            
            ; additional parameters (min, max...)
            Select FormWindows()\FormGadgets()\type ;{
              Case #Form_Type_Date                  ;{
                If flags <> ""
                  line + ", 0"
                EndIf
                ;}
                
              Case #Form_Type_ButtonImg ;{
                img_id.s = ""
                If FormWindows()\FormGadgets()\image
                  ChangeCurrentElement(FormWindows()\FormImg(),FormWindows()\FormGadgets()\image)
                  ForEach Img()
                    If Img()\img = FormWindows()\FormImg()\img
                      img_id = Img()\id
                      Break
                    EndIf
                  Next
                EndIf
                
                If img_id <> ""
                  line + ", ImageID("+img_id+")"
                Else
                  line + ", 0"
                EndIf
                
                ;}
              Case #Form_Type_ListIcon ;{
                If ListSize(FormWindows()\FormGadgets()\Columns())
                  FirstElement(FormWindows()\FormGadgets()\Columns())
                  line + ", " + Chr(34) + FormWindows()\FormGadgets()\Columns()\name + Chr(34) + ", " + Str(FormWindows()\FormGadgets()\Columns()\width)
                Else
                  line + ", " + Chr(34) + Chr(34) + ", 100"
                EndIf
                
                ;}
              Case #Form_Type_Spin ;{
                line + ", "+ Str(FormWindows()\FormGadgets()\min) +", " + Str(FormWindows()\FormGadgets()\max)
                ;}
              Case #Form_Type_Trackbar ;{
                line + ", "+ Str(FormWindows()\FormGadgets()\min) +", " + Str(FormWindows()\FormGadgets()\max)
                ;}
              Case #Form_Type_ProgressBar ;{
                line + ", "+ Str(FormWindows()\FormGadgets()\min) +", " + Str(FormWindows()\FormGadgets()\max)
                ;}
              Case #Form_Type_Img ;{
                img_id.s = ""
                If FormWindows()\FormGadgets()\image
                  ChangeCurrentElement(FormWindows()\FormImg(),FormWindows()\FormGadgets()\image)
                  ForEach Img()
                    If Img()\img = FormWindows()\FormImg()\img
                      img_id = Img()\id
                      Break
                    EndIf
                  Next
                EndIf
                
                If img_id <> ""
                  line + ", ImageID("+img_id+")"
                Else
                  line + ", 0"
                EndIf
                
                ;}
              Case #Form_Type_Scrollbar ;{
                line + ", "+ Str(FormWindows()\FormGadgets()\min) +", " + Str(FormWindows()\FormGadgets()\max) + ", 0"
                ;}
              Case #Form_Type_HyperLink ;{
                line + ", 0"
                ;}
              Case #Form_Type_Scintilla ;{
                If FormWindows()\FormGadgets()\caption <> "" And FormWindows()\FormGadgets()\caption <> "0"
                  line + ", @"+FormWindows()\FormGadgets()\caption ; caption is in fact the callback
                Else
                  line + ", 0"
                EndIf
                
                ;}
              Case #Form_Type_Splitter ;{
                gadget1 = FormWindows()\FormGadgets()\gadget1
                gadget2 = FormWindows()\FormGadgets()\gadget2
                PushListPosition(FormWindows()\FormGadgets())
                
                ForEach FormWindows()\FormGadgets()
                  If FormWindows()\FormGadgets()\itemnumber = gadget1
                    var1.s = FormWindows()\FormGadgets()\variable
                    If Not FormWindows()\FormGadgets()\pbany
                      var1 = "#" + var1
                    EndIf
                  EndIf
                  If FormWindows()\FormGadgets()\itemnumber = gadget2
                    var2.s = FormWindows()\FormGadgets()\variable
                    If Not FormWindows()\FormGadgets()\pbany
                      var2 = "#" + var2
                    EndIf
                  EndIf
                Next
                
                PopListPosition(FormWindows()\FormGadgets())
                line + ", " + var1 + ", " + var2
                ;}
              Case #Form_Type_ScrollArea ;{
                line + ", "+ Str(FormWindows()\FormGadgets()\min) +", " + Str(FormWindows()\FormGadgets()\max) + ", 1"
                ;}
              Case #Form_Type_Calendar ;{
                line + ", 0"
                ;}
            EndSelect ;}
            
            line + flags + ")"
            content + "  "+line + #Endline
            
            If FormWindows()\FormGadgets()\pbany
              variable.s = FormWindows()\FormGadgets()\variable
            Else
              variable.s = "#" + FormWindows()\FormGadgets()\variable
            EndIf
            
            If FormWindows()\FormGadgets()\hidden
              content + "  HideGadget("+variable+", 1)" + #Endline
            EndIf
            
            If FormWindows()\FormGadgets()\tooltip <> ""
              If FormWindows()\FormGadgets()\tooltipvariable
                tooltip.s = FormWindows()\FormGadgets()\tooltip
              Else
                tooltip.s = Chr(34) + FormWindows()\FormGadgets()\tooltip + Chr(34)
              EndIf
              
              content + "  GadgetToolTip(" + variable + ", " + tooltip + ")" + #Endline
            EndIf
            
            ForEach FormWindows()\FormGadgets()\Columns()
              If ListIndex(FormWindows()\FormGadgets()\Columns()) = 0
                Continue
              EndIf
              content + "  AddGadgetColumn(" + variable + ", " + Str(ListIndex(FormWindows()\FormGadgets()\Columns())) + ", " + Chr(34) + FormWindows()\FormGadgets()\Columns()\name + Chr(34) + ", " + Str(FormWindows()\FormGadgets()\Columns()\width) + ")" + #Endline
            Next
            
            If FormWindows()\FormGadgets()\state
              Select FormWindows()\FormGadgets()\type
                Case #Form_Type_Checkbox
                  content + "  SetGadgetState("+variable+", #PB_Checkbox_Checked)" + #Endline
                Case #Form_Type_Option
                  content + "  SetGadgetState("+variable+", 1)" + #Endline
                Case #Form_Type_Splitter
                  content + "  SetGadgetState("+variable+", "+Str(FormWindows()\FormGadgets()\state)+")" + #Endline
              EndSelect
            EndIf
            
            If FormWindows()\FormGadgets()\frontcolor > -1
              content + "  SetGadgetColor("+variable+", #PB_Gadget_FrontColor,RGB("+Str(Red(FormWindows()\FormGadgets()\frontcolor))+","+Str(Green(FormWindows()\FormGadgets()\frontcolor))+","+Str(Blue(FormWindows()\FormGadgets()\frontcolor))+"))" + #Endline
            EndIf
            If FormWindows()\FormGadgets()\backcolor > -1
              content + "  SetGadgetColor("+variable+", #PB_Gadget_BackColor,RGB("+Str(Red(FormWindows()\FormGadgets()\backcolor))+","+Str(Green(FormWindows()\FormGadgets()\backcolor))+","+Str(Blue(FormWindows()\FormGadgets()\backcolor))+"))" + #Endline
            EndIf
            If FormWindows()\FormGadgets()\gadgetfont <> ""
              ForEach Fonts()
                If Fonts()\flags = FormWindows()\FormGadgets()\gadgetfontflags And Fonts()\name = FormWindows()\FormGadgets()\gadgetfont And Fonts()\size = FormWindows()\FormGadgets()\gadgetfontsize
                  Break
                EndIf
              Next
              content + "  SetGadgetFont("+variable+", FontID("+Fonts()\id+"))" + #Endline
            EndIf
            
            
            If FormWindows()\FormGadgets()\disabled
              content + "  DisableGadget("+variable+", 1)" + #Endline
            EndIf
          EndIf
        EndIf
      Else
        If Not firstwindow
          content +"EndProcedure" + #Endline
          content +"" + #Endline
        Else
          firstwindow = 0
        EndIf
        
        If FormWindows()\x = -65535
          winx.s = "#PB_Ignore"
        Else
          winx.s = Str(DesktopUnscaledX(FormWindows()\x))
        EndIf
        
        If FormWindows()\y = -65535
          winy.s = "#PB_Ignore"
        Else
          winy.s = Str(DesktopUnscaledY(FormWindows()\y))
        EndIf
        
        content +"Procedure Open"+FormWindows()\variable+"(x = " + winx + ", y = " + winy + ", width = " + Str(DesktopUnscaledX(FormWindows()\width)) + ", height = " + Str(DesktopUnscaledY(FormWindows()\height)) + ")" + #Endline
        
        AddElement(Procs())
        Procs() = "Open"+FormWindows()\variable+"()"
        
        flags.s = ""
        ForEach Gadgets()
          If Gadgets()\type = #Form_Type_Window
            ForEach Gadgets()\Flags()
              If FormWindows()\flags & Gadgets()\Flags()\ivalue
                If flags <> ""
                  flags + " | "
                EndIf
                flags + Gadgets()\Flags()\name
              EndIf
            Next
            ForEach FormWindows()\FormCustomFlags()
                If flags <> ""
                  flags + " | "
                EndIf
                flags + FormWindows()\FormCustomFlags()
            Next
          EndIf
        Next
        
        If flags
          flags = ", "+flags
        EndIf
        
        
        If FormWindows()\pbany
          variable.s = FormWindows()\variable
          
          line.s = "  "+FormWindows()\variable+" = OpenWindow(#PB_Any, x, y, width, height, "
          
          If FormWindows()\captionvariable
            If FormWindows()\caption = ""
              line + Chr(34)+Chr(34)
            Else
              line + FormWindows()\caption
            EndIf
          Else
            line + Chr(34)+FormWindows()\caption+Chr(34)
          EndIf
          
        Else
          variable.s = "#"+FormWindows()\variable
          line.s = "  OpenWindow("+variable+", x, y, width, height, "
          
          If FormWindows()\captionvariable
            line + FormWindows()\caption
          Else
            line + Chr(34)+FormWindows()\caption+Chr(34)
          EndIf
        EndIf
        
        line + flags
        
        ; Add parent
        If FormWindows()\parent
          If flags = ""
            line + ", 0, "
          Else
            line + ", "
          EndIf
          
          If Asc(FormWindows()\parent) <> '=' 
            line + "WindowID(" + FormWindows()\parent + ")"
          Else
            line + LTrim(FormWindows()\parent, "=") 
          EndIf
          
        EndIf
        
        line +  ")"
        content + line + #Endline
        
        
        If FormWindows()\hidden
          content + "  HideWindow("+variable+", 1)" + #Endline
        EndIf
        
        If FormWindows()\disabled
          content + "  DisableWindow("+variable+", 1)" + #Endline
        EndIf
        
        If FormWindows()\color > -1
          content + "  SetWindowColor("+variable+", RGB("+Str(Red(FormWindows()\color))+","+Str(Green(FormWindows()\color))+","+Str(Blue(FormWindows()\color))+"))" + #Endline
        EndIf
        
        
        addemptyline = 0
        ForEach FormWindows()\FormMenus()
          If FormWindows()\FormMenus()\shortcut <> ""
            addemptyline = 1
            
            If FindString(FormWindows()\FormMenus()\shortcut,"+")
              mod.s = Trim(StringField(FormWindows()\FormMenus()\shortcut,1,"+"))
              
              Select LCase(mod) ; Use LCase() so it works with CTRL, Ctrl, etc. https://www.purebasic.fr/english/viewtopic.php?f=4&t=71127
                Case "cmd"
                  mod = "Command"
                Case "ctrl"
                  mod = "Control"
                Case "strg"
                  mod = "Control"
              EndSelect
              
              shortcut.s = Trim(StringField(FormWindows()\FormMenus()\shortcut,2,"+"))
              content + "  AddKeyboardShortcut("+ winid + ", #PB_Shortcut_" + mod + " | #PB_Shortcut_" + shortcut + ", " + FormWindows()\FormMenus()\id + ")" + #Endline
            Else
              content + "  AddKeyboardShortcut("+ winid + ", #PB_Shortcut_" + FormWindows()\FormMenus()\shortcut + ", " + FormWindows()\FormMenus()\id + ")" + #Endline
            EndIf
          EndIf
        Next
        
        If addemptyline
          content + #Endline
        EndIf
        
        If ListSize(FormWindows()\FormToolbars())
          content + "  CreateToolbar("+Str(toolbarcount)+", WindowID("+variable+"))" + #Endline
          toolbarcount + 1
          
          ForEach FormWindows()\FormToolbars()
            If FormWindows()\FormToolbars()\separator
              content + "  ToolBarSeparator()" + #Endline
            Else
              img_id.s = ""
              If FormWindows()\FormToolbars()\img
                ChangeCurrentElement(FormWindows()\FormImg(),FormWindows()\FormToolbars()\img)
                ForEach Img()
                  If Img()\img = FormWindows()\FormImg()\img
                    img_id = Img()\id
                    Break
                  EndIf
                Next
              EndIf
              
              line.s = "  ToolBarImageButton("+FormWindows()\FormToolbars()\id+",ImageID("+img_id+")"
              
              If FormWindows()\FormToolbars()\toggle
                line + ", #PB_ToolBar_Toggle"
              EndIf
              
              line + ")"
              content + line + #Endline
              
              If FormWindows()\FormToolbars()\tooltip <> ""
                content + "  ToolBarToolTip("+Str(toolbarcount - 1)+", "+FormWindows()\FormToolbars()\id+", "+Chr(34)+FormWindows()\FormToolbars()\tooltip+Chr(34) + ")" + #Endline
              EndIf
              
              
            EndIf
          Next
        EndIf
        
        If ListSize(FormWindows()\FormStatusbars())
          content + "  CreateStatusBar("+Str(statusbarcount)+", WindowID("+variable+"))" + #Endline
          
          ForEach FormWindows()\FormStatusbars()
            If FormWindows()\FormStatusbars()\width = -1
              content + "  AddStatusBarField(#PB_Ignore)" + #Endline
            Else
              content + "  AddStatusBarField("+Str(FormWindows()\FormStatusbars()\width)+")" + #Endline
            EndIf
            
            flags.s = ""
            If FormWindows()\FormStatusbars()\flags & FlagValue("#PB_StatusBar_BorderLess")
              flags.s + "#PB_StatusBar_BorderLess"
            EndIf
            If FormWindows()\FormStatusbars()\flags & FlagValue("#PB_StatusBar_Center")
              If flags <> ""
                flags + " | "
              EndIf
              flags.s + "#PB_StatusBar_Center"
            EndIf
            If FormWindows()\FormStatusbars()\flags & FlagValue("#PB_StatusBar_Raised")
              If flags <> ""
                flags + " | "
              EndIf
              flags.s + "#PB_StatusBar_Raised"
            EndIf
            If FormWindows()\FormStatusbars()\flags & FlagValue("#PB_StatusBar_Right")
              If flags <> ""
                flags + " | "
              EndIf
              flags.s + "#PB_StatusBar_Right"
            EndIf
            If flags <> ""
              flags = ", " + flags
            EndIf
            
            If FormWindows()\FormStatusbars()\text <> ""
              content + "  StatusBarText("+Str(statusbarcount)+", "+Str(ListIndex(FormWindows()\FormStatusbars()))+", "+Chr(34)+FormWindows()\FormStatusbars()\text+Chr(34)+flags+")" + #Endline
            ElseIf FormWindows()\FormStatusbars()\img
              ChangeCurrentElement(FormWindows()\FormImg(),FormWindows()\FormStatusbars()\img)
              ForEach Img()
                If Img()\img = FormWindows()\FormImg()\img
                  img_id = Img()\id
                  Break
                EndIf
              Next
              
              content + "  StatusBarImage("+Str(statusbarcount)+", "+Str(ListIndex(FormWindows()\FormStatusbars()))+", ImageID("+img_id+")"+flags+")" + #Endline
            ElseIf FormWindows()\FormStatusbars()\progressbar > 0
              content + "  StatusBarProgress("+Str(statusbarcount)+", "+Str(ListIndex(FormWindows()\FormStatusbars()))+", 0"+flags+")" + #Endline
            EndIf
          Next
          statusbarcount + 1
        EndIf
        
        If ListSize(FormWindows()\FormMenus())
          found = 0
          ForEach FormWindows()\FormMenus()
            If FormWindows()\FormMenus()\icon
              found = 1
              Break
            EndIf
          Next
          
          If found
            content + "  CreateImageMenu("+Str(menucount)+", WindowID("+variable+"))" + #Endline
          Else
            content + "  CreateMenu("+Str(menucount)+", WindowID("+variable+"))" + #Endline
          EndIf
          
          menucount + 1
          level = 1
          ForEach FormWindows()\FormMenus()
            If FormWindows()\FormMenus()\separator
              content + "  MenuBar()" + #Endline
            Else
              Select FormWindows()\FormMenus()\level
                Case 0
                  For finishlevel = level To 2 Step -1
                    content + "  CloseSubMenu()" + #Endline
                  Next
                  
                  content + "  MenuTitle("+Chr(34)+FormWindows()\FormMenus()\item+Chr(34)+")" + #Endline
                  level = FormWindows()\FormMenus()\level
                  
                Default
                  thislevel = FormWindows()\FormMenus()\level
                  PushListPosition(FormWindows()\FormMenus())
                  next_item = 0
                  If NextElement(FormWindows()\FormMenus())
                    If FormWindows()\FormMenus()\level > thislevel And FormWindows()\FormMenus()\level<>5
                      next_item = 1
                    EndIf
                  EndIf
                  PopListPosition(FormWindows()\FormMenus())
                  
                  If next_item
                    content + "  OpenSubMenu("+Chr(34)+FormWindows()\FormMenus()\item+Chr(34)+")" + #Endline
                  Else
                    If FormWindows()\FormMenus()\level < level
                      content + "  CloseSubMenu()" + #Endline
                      content + "  MenuItem("+FormWindows()\FormMenus()\id+", "+Chr(34)+FormWindows()\FormMenus()\item+Chr(34)
                    Else
                      content + "  MenuItem("+FormWindows()\FormMenus()\id+", "+Chr(34)+FormWindows()\FormMenus()\item+Chr(34)
                    EndIf
                    
                    If FormWindows()\FormMenus()\shortcut <> ""
                      content + " + Chr(9) + " + Chr(34) + FormWindows()\FormMenus()\shortcut + Chr(34)
                    EndIf
                    
                    
                    img_id.s = ""
                    If FormWindows()\FormMenus()\icon
                      ChangeCurrentElement(FormWindows()\FormImg(),FormWindows()\FormMenus()\icon)
                      ForEach Img()
                        If Img()\img = FormWindows()\FormImg()\img
                          img_id = Img()\id
                          Break
                        EndIf
                      Next
                    EndIf
                    
                    If img_id <> ""
                      content + ", ImageID("+img_id+")"
                    EndIf
                    
                    content + ")" + #Endline
                  EndIf
                  level = FormWindows()\FormMenus()\level
              EndSelect
            EndIf
          Next
          
          For finishlevel = level To 2 Step -1
            content + "  CloseSubMenu()" + #Endline
          Next
          
        EndIf
        
      EndIf
    EndIf
  Next
  
  ForEach ContainerLevel()
    content + "  CloseGadgetList()" + #Endline
    DeleteElement(ContainerLevel())
  Next
  
  content +"EndProcedure" + #Endline + #Endline
  
  If codegenresize
    content + "Procedure ResizeGadgets" + FormWindows()\variable + "()" + #Endline
    content + "  Protected FormWindowWidth, FormWindowHeight" + #Endline
    If FormWindows()\pbany
      variable.s = FormWindows()\variable
    Else
      variable.s = "#"+FormWindows()\variable
    EndIf
    content + "  FormWindowWidth = WindowWidth(" + variable + ")" + #Endline
    content + "  FormWindowHeight = WindowHeight(" + variable + ")" + #Endline
    
    content + contentsize + "EndProcedure" + #Endline + #Endline
  EndIf
  
  ; Events procedure
  If (FormWindows()\generateeventloop And FormEventProcedure) Or testcode
    content + "Procedure " + FormWindows()\variable + "_Events(event)" + #Endline
    content + "  Select event" + #Endline
    
    If codegenresize
      content + "    Case #PB_Event_SizeWindow" + #Endline
      content + "      ResizeGadgets" + FormWindows()\variable + "()" + #Endline
    EndIf
    
    content + "    Case #PB_Event_CloseWindow" + #Endline
    content + "      ProcedureReturn #False" + #Endline + #Endline
    
    content + "    Case #PB_Event_Menu" + #Endline
    content + "      Select EventMenu()" + #Endline
    
    ForEach MenuVars()
      content + "        Case " + MenuVars()\a + #Endline
      
      If MenuVars()\b <> ""
        content + "          " + MenuVars()\b + "(EventMenu())" + #Endline
      EndIf
      
    Next
    
    content + "      EndSelect" + #Endline + #Endline
    
    content + "    Case #PB_Event_Gadget" + #Endline
    content + "      Select EventGadget()" + #Endline
    
    ForEach FormWindows()\FormGadgets()
      If FormWindows()\FormGadgets()\event_proc
        If FormWindows()\FormGadgets()\pbany
          var.s = FormWindows()\FormGadgets()\variable
        Else
          var.s = "#"+FormWindows()\FormGadgets()\variable
        EndIf
        
        content + "        Case " + var + #Endline
        content + "          " + FormWindows()\FormGadgets()\event_proc + "(EventType())"
        content + "          " + #Endline
      EndIf
    Next
    
    content +"      EndSelect" + #Endline
    
    If FormWindows()\event_proc
      If FormWindows()\pbany
        var.s = FormWindows()\variable
      Else
        var.s = "#"+FormWindows()\variable
      EndIf
      
      content +"    Default" + #Endline
      content +"      " + FormWindows()\event_proc + "(event,"+var+")" + #Endline
    EndIf
    content +"  EndSelect" + #Endline
    content +"  ProcedureReturn #True" + #Endline
    content + "EndProcedure" + #Endline
    content + "" + #Endline
  EndIf
  
  If testcode
    
    ; Declare all event procedures
    ;
    ; Menus
    ForEach MenuVars()
      If MenuVars()\b <> ""
        content + "Procedure " + MenuVars()\b + "(Event) : EndProcedure" + #Endline
      EndIf
    Next
    
    ; Gadgets
    ForEach FormWindows()\FormGadgets()
      If FormWindows()\FormGadgets()\event_proc
        content + "Procedure " + FormWindows()\FormGadgets()\event_proc + "(EventType) : EndProcedure" + #Endline
      EndIf
    Next
    
    ; Window
    If FormWindows()\event_proc
      content +"Procedure " + FormWindows()\event_proc + "(Event, Window) : EndProcedure" + #Endline
    EndIf
    
  EndIf
  
  
  If testcode
    content + "Open"+FormWindows()\variable+"()" + #Endline + #Endline
    content + "Repeat" + #Endline + "  event = WaitWindowEvent()" + #Endline
    content + "Until " + FormWindows()\variable + "_Events(event) = #False" + #Endline + #Endline + "End"
  EndIf
  
  inline = 0
  ForEach Img()
    If Img()\inline
      content + #Endline + #Endline + "DataSection" + #Endline
      inline = 1
      Break
    EndIf
  Next
  
  ForEach Img()
    If Img()\inline
      image_id.s = Img()\id
      
      If Left(image_id, 1) = "#"
        image_id = Right(image_id, Len(image_id) - 1)
      EndIf
      
      
      content +"  " + image_id + ": : IncludeBinary "+Chr(34)+Img()\img+Chr(34) + #Endline
    EndIf
  Next
  
  If inline
    content +"EndDataSection" + #Endline
  EndIf
  
  If Not contentonly
    num = CountString(content,#Endline)
    For i = 1 To num
      ;TE_AddGadgetItem(code_gadget,-1,StringField(content,i,#Endline))
    Next
    
    ;     TE_RemoveGadgetItem(code_gadget,0)
    ;     num = TE_CountGadgetItems(code_gadget) - 1
    
  EndIf
  
  If contentonly
    ProcedureReturn content
  Else
    ProcedureReturn ""
  EndIf
  
EndProcedure
