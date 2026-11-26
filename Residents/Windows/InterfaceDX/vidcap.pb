
; IKsTopologyInfo interface definition
;
Interface IKsTopologyInfo Extends IUnknown
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
Interface ISelector Extends IUnknown
  get_NumSources(a.l)
  get_SourceNodeId(a.l)
  put_SourceNodeId(a.l)
EndInterface

; IKsNodeControl interface definition
;
Interface IKsNodeControl Extends IUnknown
  put_NodeId(a.l)
  put_KsControl(a.l)
EndInterface
