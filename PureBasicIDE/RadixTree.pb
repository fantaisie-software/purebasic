; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

;
; Simple implementation of a compact prefix tree (radix tree) to store values ordered by a key
; with fast lookup of all values matching a specific key prefix.
;
; Only "insert" and "free" are implemented because that is all we need for our purposes.
; Deleting individual keys is not implemented for now.
;
; All keys are handled Case insensitive.
;

CompilerIf Not Defined(RadixNode, #PB_Structure) ; For local testing. Defined in Common.pb too
  Structure RadixNode
    Chars$            ; Incoming prefix for this node (stored in uppercase)
    *Child.RadixNode  ; First child node (if any)
    *Next.RadixNode   ; Next sibling node in same parent (single linked list, sorted by prefix)
    *Value            ; Stored value or null
  EndStructure
  
  Structure RadixTree
    *Node   ; First child of the root node (other children are under Child\Next). Null for an empty tree
  EndStructure
  
  #CharSize = 2
CompilerEndIf

Procedure Radix_FreeNode(*Node.RadixNode)

    While *Node
    *Next = *Node\Next
    
    Radix_FreeNode(*Node\Child)
    FreeStructure(*Node)
    
    *Node = *Next
  Wend
  
EndProcedure

Procedure RadixFree(*Tree.RadixTree)
  
  Radix_FreeNode(*Tree\Node)
  *Tree\Node = #Null
  
EndProcedure

; Returns RadixNode or null
;
Procedure RadixFindPrefix(*Tree.RadixTree, Prefix$, ExactMatchOnly = #False)
  
  ; The algorithm below expects at least one character to be searched for
  If Prefix$ = ""
    ProcedureReturn #Null
  EndIf
  
  ; Use LCase() instead of UCase() to be compatiable to internal PB case insensitive compare (https://www.purebasic.fr/english/viewtopic.php?p=615646)
  PrefixL$ = LCase(Prefix$)
  *PrefixCursor.Character = @PrefixL$
  
  *Node.RadixNode = *Tree\Node
  While *Node
    *NodeCursor.Character = @*Node\Chars$
    
    ; Trie-invariant: Each child starts with a unique character so we only need to look at that
    ;
    If *PrefixCursor\c = *NodeCursor\c
      ; Node matches first char. Match further characters in the node
      *NodeCursor + #CharSize
      *PrefixCursor + #CharSize
      While *NodeCursor\c And *PrefixCursor\c And *NodeCursor\c = *PrefixCursor\c
        *NodeCursor + #CharSize
        *PrefixCursor + #CharSize
      Wend
      
      If *PrefixCursor\c = 0
        ; prefix fully matched the node
        If ExactMatchOnly And *NodeCursor\c <> 0
          ProcedureReturn #Null
        Else
          ProcedureReturn *Node
        EndIf

      ElseIf *NodeCursor\c = 0
        ; all characters consumed. continue searching child nodes
        *Node = *Node\Child
      Else
        ; difference in part of the node. no match
        ProcedureReturn #Null
      EndIf
      
    ElseIf *NodeCursor\c < *PrefixCursor\c
      ; Look at next node on same level
      *Node = *Node\Next
      
    Else
      ; No more matches possible since nodes are sorted
      ProcedureReturn #Null
      
    EndIf
  Wend
  
  ; Reached the end of child-node list without a match but unmatched prefix chars remain
  ProcedureReturn #Null
EndProcedure

Procedure RadixLookupValue(*Tree.RadixTree, Name$)
  *Result.RadixNode = RadixFindPrefix(*Tree, Name$, #True)
  If *Result
    ProcedureReturn *Result\Value
  Else
    ProcedureReturn #Null
  EndIf
EndProcedure

; Fills values of first and last match for the prefix
; This is useful if the underlying data is sorted too and the tree stores indexes rather than pointers
;
Procedure RadixFindRange(*Tree.RadixTree, Prefix$, *First.INTEGER, *Last.INTEGER)
  *First\i = #Null
  *Last\i = #Null
  
  *Result.RadixNode = RadixFindPrefix(*Tree, Prefix$, #False)
  If *Result
    
    ; All leaf nodes have non-empty values but nodes in the tree might too (if they match a full word)
    ; So the first non-empty node must be on the path of each first child node of *Result or *Result itself
    *FirstNode.RadixNode = *Result
    While *FirstNode
      If *FirstNode\Value
        *First\i = *FirstNode\Value
        Break
      EndIf
      *FirstNode = *FirstNode\Child
    Wend
    
    *Last\i = *First\i ; in case only *Result matched
    
    ; Similarily the last non-empty node that matches must be on the path of each last child node
    ; Not on the first level though because the *Result\Next pointers here point to nodes unrelated to the match
    *LastNode.RadixNode = *Result\Child
    While *LastNode
      ; skip to last child
      While *LastNode\Next <> #Null
        *LastNode = *LastNode\Next
      Wend
      
      If *LastNode\Value
        *Last\i = *LastNode\Value
        ; no Break. Any children are sorted AFTER this node so keep looking
      EndIf
      
      *LastNode = *LastNode\Child
    Wend
    
    If *First\i
      ProcedureReturn #True
    EndIf
  EndIf
  
  ProcedureReturn #False
EndProcedure

; Helper function
Procedure Radix_EnumerateNodes(*Node.RadixNode, List *Values())
  
  While *Node
    If *Node\Value
      AddElement(*Values())
      *Values() = *Node\Value
    EndIf
    
    Radix_EnumerateNodes(*Node\Child, *Values())
    *Node = *Node\Next
  Wend
  
EndProcedure


Procedure RadixEnumerateAll(*Tree.RadixTree, List *Values())
  
  ClearList(*Values())
  Radix_EnumerateNodes(*Tree\Node, *Values())

EndProcedure


Procedure RadixEnumeratePrefix(*Tree.RadixTree, Name$, List *Values())
  
  ClearList(*Values())
  *Result.RadixNode = RadixFindPrefix(*Tree, Name$, #False)
  If *Result
    ; Do not look at the \Next nodes from the current node as we only want the current node and anything below it
    If *Result\Value
      AddElement(*Values())
      *Values() = *Result\Value
    EndIf
    
    Radix_EnumerateNodes(*Result\Child, *Values())
  EndIf
  
EndProcedure

; Helper function
Procedure Radix_AllocNode(*PrefixCursor.Character, *Value)
  *Node.RadixNode = AllocateStructure(RadixNode)
  *Node\Chars$ = PeekS(*PrefixCursor)
  *Node\Value = *Value
  ProcedureReturn *Node
EndProcedure


Procedure RadixInsert(*Tree.RadixTree, Name$, *Value)
  
  If *Value = 0
    ProcedureReturn
  EndIf
  
  ; Use LCase() instead of UCase() to be compatiable to internal PB case insensitive compare (https://www.purebasic.fr/english/viewtopic.php?p=615646)
  PrefixL$ = LCase(Name$)
  *PrefixCursor.Character = @PrefixL$
  
  If *Tree\Node = #Null
    
    ; Tree is empty so far
    *Tree\Node = Radix_AllocNode(*PrefixCursor, *Value)
    
  Else
    
    ; Similar to the algorithm in RadixFindPrefix()
    *Node.RadixNode = *Tree\Node
    *Parent.RadixNode = #Null
    *Previous.RadixNode = #Null
    
    While *Node
      *NodeCursor.Character = @*Node\Chars$
      
      If *PrefixCursor\c = *NodeCursor\c
        *NodeCursor + #CharSize
        *PrefixCursor + #CharSize
        While *NodeCursor\c And *PrefixCursor\c And *NodeCursor\c = *PrefixCursor\c
          *NodeCursor + #CharSize
          *PrefixCursor + #CharSize
        Wend
        
        If *PrefixCursor\c = 0 And *NodeCursor\c = 0
          ; exact match. do not add duplicates
          If *Node\Value = 0
            *Node\Value = *Value
          EndIf
          ProcedureReturn
          
        ElseIf *NodeCursor\c = 0
          ; all characters consumed.
          If *Node\Child
            ; continue searching child nodes
            *Parent = *Node
            *Previous = #Null
            *Node = *Node\Child
          Else
            ; Add a child node
            *Node\Child = Radix_AllocNode(*PrefixCursor, *Value)
            ProcedureReturn
          EndIf
          
        ElseIf *PrefixCursor\c = 0
          ; Need to split the node to add the value (same prefix as the existing node)
          *SplitNode.RadixNode = Radix_AllocNode(*NodeCursor, *Node\Value)
          *SplitNode\Child = *Node\Child
          *Node\Chars$ = Left(*Node\Chars$, Len(*Node\Chars$)-Len(*SplitNode\Chars$))
          *Node\Value = *Value
          *Node\Child = *SplitNode
          ProcedureReturn
          
        Else
          ; Need to split the node and add a separate sub-node because prefix and node chars differ
          NodeChar.c = *NodeCursor\c ; save this as we re-alloc the string
          *SplitNode.RadixNode = Radix_AllocNode(*NodeCursor, *Node\Value)
          *SplitNode\Child = *Node\Child
          *NewNode.RadixNode = Radix_AllocNode(*PrefixCursor, *Value)
          *Node\Chars$ = Left(*Node\Chars$, Len(*Node\Chars$)-Len(*SplitNode\Chars$)) ; invalidates *NodeCursor !
          *Node\Value = #Null
          If NodeChar < *PrefixCursor\c
            *Node\Child = *SplitNode
            *SplitNode\Next = *NewNode
          Else
            *Node\Child = *NewNode
            *NewNode\Next = *SplitNode
          EndIf
          ProcedureReturn
          
        EndIf
        
      ElseIf *NodeCursor\c < *PrefixCursor\c
        ; Look at next node on same level
        *Previous = *Node
        *Node = *Node\Next
        
      Else
        ; No more matches possible since nodes are sorted. Add a new node before this one
        *NewNode.RadixNode = Radix_AllocNode(*PrefixCursor, *Value)
        *NewNode\Next = *Node
        If *Previous
          *Previous\Next = *NewNode
        ElseIf *Parent
          *Parent\Child = *NewNode
        Else
          *Tree\Node = *NewNode
        EndIf
        ProcedureReturn
        
      EndIf
    Wend
    
    ; Reached end of the node list. Add a new one here
    ; There must be a *Previous node as the no-child case is handled above already
    *NewNode = Radix_AllocNode(*PrefixCursor, *Value)
    *Previous\Next = *NewNode
    
  EndIf

EndProcedure


;- ------ Debugging and Testing ------

CompilerIf #False
  
  Procedure DebugRadixGraph_Recursive(*Node.RadixNode, Spaces$, Parent$, *Selected.RadixNode, InSelection)
    
    While *Node
      NodeName$ = "n" + Hex(*Node)
      
      If *Node\Value
        Label$ = PeekS(*Node\Value)
      Else
        Label$ = ""
      EndIf
      
      If *Node = *Selected
        Debug Spaces$ + NodeName$ + ~" [label=\"" + Label$ + ~"\", color=\"red\"]"
      ElseIf InSelection
        Debug Spaces$ + NodeName$ + ~" [label=\"" + Label$ + ~"\", color=\"green\"]"
      Else
        Debug Spaces$ + NodeName$ + ~" [label=\"" + Label$ + ~"\"]"
      EndIf
      
      Debug Spaces$ + Parent$ + " -> " + NodeName$ + ~" [label=\"" + *Node\Chars$ +  ~"\"]"
      
      If *Node = *Selected
        DebugRadixGraph_Recursive(*Node\Child, Spaces$ + "  ", NodeName$, *Selected, #True)
      Else
        DebugRadixGraph_Recursive(*Node\Child, Spaces$ + "  ", NodeName$, *Selected, InSelection)
      EndIf
      
      *Node = *Node\Next
    Wend
    
  EndProcedure
  
  ; Go here to visualize the graph: https://dreampuf.github.io/GraphvizOnline
  Procedure DebugRadixGraph(*Tree.RadixTree, *Selected.RadixNode = #Null)
    
    Debug "digraph G {"
    Debug ~"  root [label=\"\"]"
    DebugRadixGraph_Recursive(*Tree\Node, "  ", "root", *Selected, #False)
    Debug "}"
  
  EndProcedure
  
  XIncludeFile "ConstantsData.pbi"
  
  NewList Names.s()
  Restore BasicFunctionConstants
  Repeat
    Read$ x$
    If x$ = ""
      Break
    EndIf
    AddElement(Names())
    Names() = StringField(x$, 1, ",")
  ForEver
  
  ; Test random insertions
  RandomSeed(123)
  RandomizeList(Names())
  
  Define Tree.RadixTree
  
  ; Insert all function names
;   ForEach Names()
;     RadixInsert(Tree, Names(), PeekI(@Names())) ; store the actual name as the node value
;   Next Names()
  
  ; Insert just a few names
  ResetList(Names())
  For i = 1 To 25
    NextElement(Names())
    RadixInsert(Tree, Names(), PeekI(@Names()))
  Next i
  
  ; Test lookup/enumeration
  NewList *Found()
  ;RadixEnumerateAll(Tree, *Found())
  RadixEnumeratePrefix(Tree, "de", *Found())
  ForEach *Found()
    Debug PeekS(*Found())
  Next
  
  RadixFindRange(Tree, "de", @*First, @*Last)
  Debug "First: " + PeekS(*First) + "  Last: " + PeekS(*Last)
  
  ; Visualize the graph
  ;DebugRadixGraph(Tree, RadixFindPrefix(Tree, "de"))
  
  
CompilerEndIf
