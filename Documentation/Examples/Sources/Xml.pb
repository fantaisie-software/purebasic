;
; ------------------------------------------------------------
;
;   PureBasic - Xml
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#Window     = 0
#TreeGadget = 0
#XML        = 0

; This procedure fills our TreeGadget, by adding the current node
; and then exploring all childnodes by recursively calling itself.
;
Procedure FillTree(*CurrentNode, CurrentSublevel)

  ; Ignore anything except normal nodes. See the manual for
  ; XMLNodeType() for an explanation of the other node types.
  ;
  If XMLNodeType(*CurrentNode) = #PB_XML_Normal
  
    ; Add this node to the tree. Add name and attributes
    ;
    Text$ = GetXMLNodeName(*CurrentNode) + ": "
        
    If ExamineXMLAttributes(*CurrentNode)
      While NextXMLAttribute(*CurrentNode)
        Text$ + " Attribute:" + XMLAttributeName(*CurrentNode) + "=" + Chr(34) + XMLAttributeValue(*CurrentNode) + Chr(34) + " "
      Wend
    EndIf
    
    Text$+ " " + GetXMLNodeText(*CurrentNode)
    
    AddGadgetItem(#TreeGadget, -1, Text$, 0, CurrentSublevel)
        
        
    ; Now get the first child node (if any)
    ;
    *ChildNode = ChildXMLNode(*CurrentNode)
    
    ; Loop through all available child nodes and call this procedure again
    ;
    While *ChildNode <> 0
      FillTree(*ChildNode, CurrentSublevel + 1)
      *ChildNode = NextXMLNode(*ChildNode)
    Wend
  
  EndIf

EndProcedure

FileName$ = OpenFileRequester("Choose XML file...", "", "XML files (*.xml)|*.xml|All files (*.*)|*.*", 0)
If FileName$ <> ""

  If LoadXML(#XML, FileName$)

    ; Note:
    ;   The LoadXML() succeed if the file could be read. This does not mean that
    ;   there was no error in the XML though. To check this, XMLStatus() can be
    ;   used.
    ;
    ; Display an error message if there was a markup error
    ;
    If XMLStatus(#XML) <> #PB_XML_Success
      Message$ = "Error in the XML file:" + Chr(13)
      Message$ + "Message: " + XMLError(#XML) + Chr(13)
      Message$ + "Line: " + Str(XMLErrorLine(#XML)) + "   Character: " + Str(XMLErrorPosition(#XML))
      MessageRequester("Error", Message$)
    EndIf
    
    ; Note:
    ;   Even if there was an error in the XML, all nodes before the error position
    ;   are still accessible, so open the window and show the tree anyway.
    ;
    If OpenWindow(#Window, 0, 0, 500, 500, "XML Example", #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
      TreeGadget(#TreeGadget, 10, 10, 480, 480)
      
      ; Get the main XML node, and call the FillTree() procedure with it
      ;
      *MainNode = MainXMLNode(#XML)
      If *MainNode
        FillTree(*MainNode, 0)
      EndIf
      
      ; Expand all nodes for a nicer view
      ;
      For i = 0 To CountGadgetItems(#TreeGadget) - 1
        SetGadgetItemState(#TreeGadget, i, #PB_Tree_Expanded)
      Next i
      
      ; Wait for the window close event.
      ;
      Repeat
        Event = WaitWindowEvent()
      Until Event = #PB_Event_CloseWindow
    EndIf
        
  Else
    MessageRequester("Error", "The file cannot be opened.")
  EndIf

EndIf
