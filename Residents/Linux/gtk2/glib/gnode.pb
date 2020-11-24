Enumeration   ; GTraverseFlags
  #G_TRAVERSE_LEAVES = 1<<0
  #G_TRAVERSE_NON_LEAVES = 1<<1
  #G_TRAVERSE_ALL = #G_TRAVERSE_LEAVES|#G_TRAVERSE_NON_LEAVES
  #G_TRAVERSE_MASK = $03
  #G_TRAVERSE_LEAFS = #G_TRAVERSE_LEAVES
  #G_TRAVERSE_NON_LEAFS = #G_TRAVERSE_NON_LEAVES
EndEnumeration

Enumeration   ; GTraverseType
  #G_IN_ORDER
  #G_PRE_ORDER
  #G_POST_ORDER
  #G_LEVEL_ORDER
EndEnumeration

Structure GNode
  data.i    ; gpointer
 *next.GNode
 *prev.GNode
 *parent.GNode
 *children.GNode
EndStructure

