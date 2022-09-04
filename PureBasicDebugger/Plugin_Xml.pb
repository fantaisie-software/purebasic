; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------



; LibraryViewer Plugin for viewing an XML tree.
; The lib simply sends the exported markup, so we can use the Xml lib here to
; display it.
;

; data that needs to be stored
;
Structure Plugin_Xml
  ; Xml Object
  XmlID.l
  
  ; Gadgets
  Tree.l
  Panel.l
  Splitter.l
  Info.l
  Attributes.l
  Text.l
EndStructure

; count children and grandchildren
Procedure Xml_RecursiveCount(Node)
  Count = 0 ; do not count this node!
  Node  = ChildXMLNode(Node)
  While Node
    Count + Xml_RecursiveCount(Node) + 1
    Node = NextXMLNode(Node)
  Wend
  ProcedureReturn Count
EndProcedure

Procedure Xml_RecursiveAdd(Node, Gadget, Sublevel)
  NewIndex = CountGadgetItems(Gadget)
  
  Select XMLNodeType(Node)
    Case #PB_XML_Comment
      AddGadgetItem(Gadget, NewIndex, "#comment", 0, Sublevel)
      SetGadgetItemData(Gadget, NewIndex, Node) ; store the node pointer here
      
    Case #PB_XML_CData
      AddGadgetItem(Gadget, NewIndex, "#cdata", 0, Sublevel)
      SetGadgetItemData(Gadget, NewIndex, Node) ; store the node pointer here
      
    Case #PB_XML_DTD
      AddGadgetItem(Gadget, NewIndex, "#dtd", 0, Sublevel)
      SetGadgetItemData(Gadget, NewIndex, Node) ; store the node pointer here
      
    Case #PB_XML_Instruction
      AddGadgetItem(Gadget, NewIndex, "#instruction: "+GetXMLNodeName(Node), 0, Sublevel)
      SetGadgetItemData(Gadget, NewIndex, Node) ; store the node pointer here
      
    Case #PB_XML_Normal
      Text$ = GetXMLNodeName(Node)
      
      If ExamineXMLAttributes(Node)
        While NextXMLAttribute(Node)
          If LCase(XMLAttributeName(Node)) = "id"
            Text$ + "  (" + XMLAttributeName(Node) + "=" + XMLAttributeValue(Node) + ")"
            Break
          EndIf
        Wend
      EndIf
      
      AddGadgetItem(Gadget, NewIndex, Text$, 0, Sublevel)
      SetGadgetItemData(Gadget, NewIndex, Node) ; store the node pointer here
      
      Child = ChildXMLNode(Node)
      While Child
        Xml_RecursiveAdd(Child, Gadget, Sublevel+1)
        Child = NextXMLNode(Child)
      Wend
      
      ; do after adding the children
      SetGadgetItemState(Gadget, NewIndex, #PB_Tree_Expanded)
      
  EndSelect
  
EndProcedure


Procedure Plugin_Xml_DisplayObject(WindowID, *Buffer, Size)
  *Object.Plugin_Xml = 0
  
  XmlID = CatchXML(#PB_Any, *Buffer, Size)
  If XmlID
    *Object = AllocateMemory(SizeOf(Plugin_Xml))
    If *Object
      *Object\XmlID = XmlID
      
      ; no usegadgetlist, as we are within the normal program with an open gadgetlist
      *Object\Tree = TreeGadget(#PB_Any, 0, 0, 0, 0, #PB_Tree_AlwaysShowSelection)
      *Object\Panel = PanelGadget(#PB_Any, 0, 0, 0, 0)
      
      AddGadgetItem(*Object\Panel, -1, "Information")
      *Object\Info = EditorGadget(#PB_Any, 0, 0, 0, 0, #PB_Editor_ReadOnly)
      
      AddGadgetItem(*Object\Panel, -1, "Attributes")
      *Object\Attributes = ListIconGadget(#PB_Any, 0, 0, 0, 0, "Attribute", 100, #PB_ListIcon_GridLines|#PB_ListIcon_FullRowSelect)
      AddGadgetColumn(*Object\Attributes, 1, "Value", 300)
      
      AddGadgetItem(*Object\Panel, -1, "Text")
      *Object\Text = EditorGadget(#PB_Any, 0, 0, 0, 0, #PB_Editor_ReadOnly)
      
      CloseGadgetList()
      
      *Object\Splitter = SplitterGadget(#PB_Any, 0, 0, 0, 0, *Object\Tree, *Object\Panel, #PB_Splitter_Separator)
      
      ; fill the tree with data
      ; We do not add the root node itself, as it is not user-created anyway
      Node = ChildXMLNode(RootXMLNode(XmlID))
      While Node
        Xml_RecursiveAdd(Node, *Object\Tree, 0)
        Node = NextXMLNode(Node)
      Wend
      
    Else
      FreeXML(XmlID)
    EndIf
  EndIf
  
  ProcedureReturn *Object
EndProcedure



Procedure Plugin_Xml_RemoveObject(*Object.Plugin_Xml)
  ; gadgets are freed automatically as the container gets destroyed.
  FreeXML(*Object\XmlID)
  FreeMemory(*Object)
EndProcedure



Procedure Plugin_Xml_SetObjectSize(*Object.Plugin_Xml, Width, Height)
  ResizeGadget(*Object\Splitter, 5, 5, Width-10, Height-10)
  
  Width  = GetGadgetAttribute(*Object\Panel, #PB_Panel_ItemWidth)
  Height = GetGadgetAttribute(*Object\Panel, #PB_Panel_ItemHeight)
  
  ResizeGadget(*Object\Info, 0, 0, Width, Height)
  ResizeGadget(*Object\Attributes, 0, 0, Width, Height)
  ResizeGadget(*Object\Text, 0, 0, Width, Height)
  
  CompilerIf #CompileWindows
    SendMessage_(GadgetID(*Object\Attributes), #LVM_SETCOLUMNWIDTH, 1, #LVSCW_AUTOSIZE_USEHEADER)
  CompilerEndIf
EndProcedure



Procedure Plugin_Xml_ProcessEvents(*Object.Plugin_Xml, EventGadget.l, EventType.l)
  If EventGadget = *Object\Tree And EventType = #PB_EventType_Change
    ClearGadgetItems(*Object\Attributes)
    
    index = GetGadgetState(*Object\Tree)
    If index = -1
      SetGadgetText(*Object\Text, "")
      SetGadgetText(*Object\Info, "")
      
    Else
      Node = GetGadgetItemData(*Object\Tree, index) ; stored the node there
      SetGadgetText(*Object\Text, GetXMLNodeText(Node))
      
      ; set attributes
      If XMLNodeType(Node) = #PB_XML_Normal
        If ExamineXMLAttributes(Node)
          While NextXMLAttribute(Node)
            AddGadgetItem(*Object\Attributes, -1, XMLAttributeName(Node)+Chr(10)+XMLAttributeValue(Node))
          Wend
        EndIf
      EndIf
      
      ; build info text
      Select XMLNodeType(Node)
        Case #PB_XML_Comment
          Info$ = "Node type: Comment"
          
        Case #PB_XML_CData
          Info$ = "Node type: CData section"
          
        Case #PB_XML_DTD
          Info$ = "Node type: DTD tag"
          
        Case #PB_XML_Instruction
          Info$ = "Node type: Processing instruction" + #NewLine
          Info$ + "Node name: " + GetXMLNodeName(Node)
          
        Case #PB_XML_Normal
          Info$ = "Node type: Normal node" + #NewLine + #NewLine
          Info$ + "Node name: " + GetXMLNodeName(Node)+ #NewLine
          Info$ + "Offset in parent: " + Str(GetXMLNodeOffset(Node)) + #NewLine
          Info$ + "Attributes: " + Str(CountGadgetItems(*Object\Attributes)) + #NewLine
          Info$ + "Direct children: " + Str(XMLChildCount(Node)) + #NewLine
          Info$ + "All children: " + Str(Xml_RecursiveCount(Node))
          
      EndSelect
      
      SetGadgetText(*Object\Info, Info$)
      
    EndIf
    
  ElseIf EventGadget = *Object\Splitter
    Width  = GetGadgetAttribute(*Object\Panel, #PB_Panel_ItemWidth)
    Height = GetGadgetAttribute(*Object\Panel, #PB_Panel_ItemHeight)
    
    ResizeGadget(*Object\Info, 0, 0, Width, Height)
    ResizeGadget(*Object\Attributes, 0, 0, Width, Height)
    ResizeGadget(*Object\Text, 0, 0, Width, Height)
    
    CompilerIf #CompileWindows
      SendMessage_(GadgetID(*Object\Attributes), #LVM_SETCOLUMNWIDTH, 1, #LVSCW_AUTOSIZE_USEHEADER)
    CompilerEndIf
  EndIf
EndProcedure


; Register with LibraryViewer
;
AddElement(LibraryPlugins())
LibraryPlugins()\LibraryID$      = "PB_LIBRARY_Xml"
LibraryPlugins()\DisplayObject   = @Plugin_Xml_DisplayObject()
LibraryPlugins()\RemoveObject    = @Plugin_Xml_RemoveObject()
LibraryPlugins()\SetObjectSize   = @Plugin_Xml_SetObjectSize()
LibraryPlugins()\ProcessEvents   = @Plugin_Xml_ProcessEvents()
