;
; ------------------------------------------------------------
;
;   PureBasic - Dialog example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#Xml = 0
#Dialog = 0

; This callback is directly set in the xml
;
Runtime Procedure EnableAlphaBlendingEvent()
  Debug "Enable alpha blending checkbox modified !"
EndProcedure


If LoadXML(#Xml, #PB_Compiler_Home + "examples/sources/Data/ui.xml") And XMLStatus(#Xml) = #PB_XML_Success
  CreateDialog(#Dialog)
 
  If OpenXMLDialog(#Dialog, #Xml, "hello", 200, 200)
    
    OneInstanceCheckbox = DialogGadget(#Dialog, "OneInstanceCheckbox")
    SetGadgetText(OneInstanceCheckbox, "Instance text changed")
    
    Repeat
      Event = WaitWindowEvent()
    Until Event = #PB_Event_CloseWindow
    
  Else
    Debug "Dialog creation error: " + DialogError(#Dialog)
  EndIf
  
Else
  Debug "XML error on line " + XMLErrorLine(#Xml) + ": " + XMLError(#Xml)
EndIf
