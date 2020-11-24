
; IKsTopologyInfo interface definition
;
Interface IKsTopologyInfo
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  get_NumCategories(a.l)
  get_Category(a.l, b.l)
  get_NumConnections(a.l)
  get_ConnectionInfo(a.l, b.l)
  get_NodeName(a.l, b.l, c.l, d.l)
  get_NumNodes(a.l)
  get_NodeType(a.l, b.l)
  CreateNodeInstance(a.l, b.l, c.l)
EndInterface

; ISelector interface definition
;
Interface ISelector
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  get_NumSources(a.l)
  get_SourceNodeId(a.l)
  put_SourceNodeId(a.l)
EndInterface

; IKsNodeControl interface definition
;
Interface IKsNodeControl
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  put_NodeId(a.l)
  put_KsControl(a.l)
EndInterface
