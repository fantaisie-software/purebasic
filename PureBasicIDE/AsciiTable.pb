; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


Structure AsciiTableStructure Extends ToolsPanelEntry
  AsciiTableMode.l
EndStructure


Procedure AsciiTable_CreateFunction(*Entry.AsciiTableStructure)
  
  ListIconGadget(#GADGET_AsciiTable, 0, 0, 50, 0, "Char", 50, #PB_ListIcon_GridLines|#PB_ListIcon_FullRowSelect|#PB_ListIcon_AlwaysShowSelection)
  AddGadgetColumn(#GADGET_AsciiTable, 1, "Ascii", 50)
  AddGadgetColumn(#GADGET_AsciiTable, 2, "Hex", 50)
  AddGadgetColumn(#GADGET_AsciiTable, 3, "Html", 80)
  
  If *Entry\IsSeparateWindow = 0 Or NoIndependentToolsColors = 0
    ToolsPanel_ApplyColors(#GADGET_AsciiTable)
  EndIf
  
  ButtonGadget(#GADGET_Ascii_InsertChar, 0, 0, 0, 0, "Char", #PB_Button_Toggle)
  ButtonGadget(#GADGET_Ascii_InsertAscii, 0, 0, 0, 0, "Ascii", #PB_Button_Toggle)
  ButtonGadget(#GADGET_Ascii_InsertHex, 0, 0, 0, 0, "Hex", #PB_Button_Toggle)
  ButtonGadget(#GADGET_Ascii_InsertHtml, 0, 0, 0, 0, "Html", #PB_Button_Toggle)
  SetGadgetState(#GADGET_Ascii_InsertChar+*Entry\AsciiTableMode, 1)
  
  Restore AsciiTable_SpecialChars
  For i = 0 To 32
    Read.s Char$
    AddGadgetItem(#GADGET_AsciiTable, -1, Char$+Chr(10)+Str(i)+Chr(10)+"$"+Hex(i))
  Next i
  
  For i = 33 To 255
    AddGadgetItem(#GADGET_AsciiTable, -1, Chr(i)+Chr(10)+Str(i)+Chr(10)+"$"+Hex(i))
  Next i
  
  Restore AsciiTable_Html
  For i = 32 To 63
    Read.s Html$
    If Html$ = "": Html$ = "&#"+Str(i)+";": EndIf
    SetGadgetItemText(#GADGET_AsciiTable, i, Html$, 3)
  Next i
  
  For i = 63 To 159
    Html$ = "&#"+Str(i)+";"
    SetGadgetItemText(#GADGET_AsciiTable, i, Html$, 3)
  Next i
  
  For i = 160 To 255
    Read.s Html$
    SetGadgetItemText(#GADGET_AsciiTable, i, Html$, 3)
  Next i
  
EndProcedure

Procedure AsciiTable_ResizeHandler(*Entry.AsciiTableStructure, PanelWidth, PanelHeight)
  
  Height = GetRequiredHeight(#GADGET_Ascii_InsertChar)
  If *Entry\IsSeparateWindow
    PanelWidth-10
    ResizeGadget(#GADGET_AsciiTable, 5, 5, PanelWidth, PanelHeight-15-Height)
    ResizeGadget(#GADGET_Ascii_InsertChar, 5, PanelHeight-5-Height, PanelWidth/4, Height)
    ResizeGadget(#GADGET_Ascii_InsertAscii, 5+PanelWidth/4, PanelHeight-5-Height, PanelWidth/4, Height)
    ResizeGadget(#GADGET_Ascii_InsertHex, 5+PanelWidth/2, PanelHeight-5-Height, PanelWidth/4, Height)
    ResizeGadget(#GADGET_Ascii_InsertHtml, 5+PanelWidth/4*3, PanelHeight-5-Height, PanelWidth/4, Height)
  Else
    ResizeGadget(#GADGET_AsciiTable, 0, 0, PanelWidth, PanelHeight-5-Height)
    ResizeGadget(#GADGET_Ascii_InsertChar, 0, PanelHeight-Height, PanelWidth/4, Height)
    ResizeGadget(#GADGET_Ascii_InsertAscii, PanelWidth/4, PanelHeight-Height, PanelWidth/4, Height)
    ResizeGadget(#GADGET_Ascii_InsertHex, PanelWidth/2, PanelHeight-Height, PanelWidth/4, Height)
    ResizeGadget(#GADGET_Ascii_InsertHtml, PanelWidth/4*3, PanelHeight-Height, PanelWidth/4, Height)
  EndIf
  
EndProcedure



Procedure AsciiTable_EventHandler(*Entry.AsciiTableStructure, EventGadgetID)
  
  Select EventGadgetID
      
    Case #GADGET_Ascii_InsertChar
      If *Entry\AsciiTableMode = 0
        SetGadgetState(#GADGET_Ascii_InsertChar, 1)
      Else
        SetGadgetState(#GADGET_Ascii_InsertChar+*Entry\AsciiTableMode, 0)
        *Entry\AsciiTableMode = 0
      EndIf
      
    Case #GADGET_Ascii_InsertAscii
      If *Entry\AsciiTableMode = 1
        SetGadgetState(#GADGET_Ascii_InsertAscii, 1)
      Else
        SetGadgetState(#GADGET_Ascii_InsertChar+*Entry\AsciiTableMode, 0)
        *Entry\AsciiTableMode = 1
      EndIf
      
    Case #GADGET_Ascii_InsertHex
      If *Entry\AsciiTableMode = 2
        SetGadgetState(#GADGET_Ascii_InsertHex, 1)
      Else
        SetGadgetState(#GADGET_Ascii_InsertChar+*Entry\AsciiTableMode, 0)
        *Entry\AsciiTableMode = 2
      EndIf
      
    Case #GADGET_Ascii_InsertHtml
      If *Entry\AsciiTableMode = 3
        SetGadgetState(#GADGET_Ascii_InsertHtml, 1)
      Else
        SetGadgetState(#GADGET_Ascii_InsertChar+*Entry\AsciiTableMode, 0)
        *Entry\AsciiTableMode = 3
      EndIf
      
    Case #GADGET_AsciiTable
      state = GetGadgetState(#GADGET_AsciiTable)
      If state <> -1
        If EventType() = #PB_EventType_LeftDoubleClick
          If *ActiveSource <> *ProjectInfo
            InsertCodeString(GetGadgetItemText(#GADGET_AsciiTable, state, *Entry\AsciiTableMode))
          EndIf
          
        ElseIf EventType() = #PB_EventType_DragStart
          DragText(GetGadgetItemText(#GADGET_AsciiTable, state, *Entry\AsciiTableMode), #PB_Drag_Copy)
          
        EndIf
      EndIf
      
  EndSelect
  
EndProcedure


Procedure AsciiTable_PreferenceLoad(*Entry.AsciiTableStructure)
  
  PreferenceGroup("AsciiTable")
  *Entry\AsciiTableMode = ReadPreferenceLong("Mode", 0)
  
EndProcedure


Procedure AsciiTable_PreferenceSave(*Entry.AsciiTableStructure)
  
  PreferenceComment("")
  PreferenceGroup("AsciiTable")
  WritePreferenceLong("Mode", *Entry\AsciiTableMode)
  
EndProcedure


;- Initialisation code
; This will make this Tool available to the editor
;
AsciiTable_VT.ToolsPanelFunctions

AsciiTable_VT\CreateFunction   = @AsciiTable_CreateFunction()
AsciiTable_VT\ResizeHandler    = @AsciiTable_ResizeHandler()
AsciiTable_VT\EventHandler     = @AsciiTable_EventHandler()
AsciiTable_VT\PreferenceLoad   = @AsciiTable_PreferenceLoad()
AsciiTable_VT\PreferenceSave   = @AsciiTable_PreferenceSave()

AddElement(AvailablePanelTools())

AvailablePanelTools()\FunctionsVT          = @AsciiTable_VT
AvailablePanelTools()\NeedPreferences      = 1
AvailablePanelTools()\NeedConfiguration    = 0
AvailablePanelTools()\NeedDestroyFunction  = 0
AvailablePanelTools()\ToolID$              = "AsciiTable"
AvailablePanelTools()\PanelTitle$          = "AsciiTable"
AvailablePanelTools()\ToolName$            = "AsciiTable"



DataSection
  
  AsciiTable_SpecialChars:  ; char 0 - 32
  Data$ "NUL", "SOH", "STX", "ETX", "EOT", "ENQ", "ACK", "BEL"
  Data$ "BS" , "TAB", "LF" , "VT" , "FF" , "CR" , "SO" , "SI"
  Data$ "DLE", "DC1", "DC2", "DC3", "DC4", "NAK", "SYN", "ETB"
  Data$ "CAN", "EM" , "SUB", "ESC", "FS" , "GS" , "RS" , "US"
  Data$ "Space"
  
  AsciiTable_Html: ; chars 32-63 and 160-255
  Data$ "", "", "&quot;", "", "", "", "&amp;", "", "", "", "", "", "", "", "", ""
  Data$ "", "", "", "", "", "", "", "", "", "", "", "", "&lt;", "", "&gt;", ""
  Data$ "&nbsp;", "&iexcl;", "&cent;", "&pound;", "&curren;", "&yen;", "&brvbar;", "&sect;", "&uml;", "&copy;", "&ordf;", "&laquo;", "&not;", "&shy;", "&reg;", "&macr;"
  Data$ "&deg;", "&plusmn;", "&sup2;", "&sup3;", "&acute;", "&micro;", "&para;", "&middot;", "&cedil;", "&sup1;", "&ordm;", "&raquo;", "&frac14;", "&frac12;", "&frac34;", "&iquest;"
  Data$ "&Agrave;", "&Aacute;", "&Acirc;", "&Atilde;", "&Auml;", "&Aring;", "&AElig;", "&Ccedil;", "&Egrave;", "&Eacute;", "&Ecirc;", "&Euml;", "&Igrave;", "&Iacute;", "&Icirc;", "&Iuml;"
  Data$ "&ETH;", "&Ntilde;", "&Ograve;", "&Oacute;", "&Ocirc;", "&Otilde;", "&Ouml;", "&times;", "&Oslash;", "&Ugrave;", "&Uacute;", "&Ucirc;", "&Uuml;", "&Yacute;", "&THORN;", "&szlig;"
  Data$ "&agrave;", "&aacute;", "&acirc;", "&atilde;", "&auml;", "&aring;", "&aelig;", "&ccedil;", "&egrave;", "&eacute;", "&ecirc;", "&euml;", "&igrave;", "&iacute;", "&icirc;", "&iuml"
  Data$ "&eth;", "&ntilde;", "&ograve;", "&oacute;", "&ocirc;", "&otilde;", "&ouml;", "&divide;", "&oslash;", "&ugrave;", "&uacute;", "&ucirc;", "&uuml;", "&yacute;", "&thorn;", "&yuml;"
  
EndDataSection
