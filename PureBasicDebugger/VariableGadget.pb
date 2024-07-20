; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


; describes one entry in the gadget
;
Structure VariableGadget_Entry
  Kind.b      ; 0=normal, or #TYPE_ARRAY, #TYPE_LINKEDLIST or #TYPE_MAP
  Type.b      ; type (normal debugger type value)
  Node.w      ; 0=no node, 1=node (closed), 2=node (open)
  Sublevel.w  ; structure sublevel
  Parent.l    ; index of parent item (-1 if none), needed for sorting
  Name$       ; variable name (as displayed in the gadget)
  Value$      ; variable value (as displayed in the gadget)
  Extra$      ; info in the extra column(s)
EndStructure

; Sort order of types in the gadget
; We cannot use the debugger types directly as they have a different numerical order
Enumeration
  #SORTTYPE_Unknown
  #SORTTYPE_Byte
  #SORTTYPE_Ascii
  #SORTTYPE_Character
  #SORTTYPE_Unicode
  #SORTTYPE_Word
  #SORTTYPE_Long
  #SORTTYPE_Integer
  #SORTTYPE_Quad
  #SORTTYPE_Pointer
  #SORTTYPE_Float
  #SORTTYPE_Double
  #SORTTYPE_String
  #SORTTYPE_FixedString
  #SORTTYPE_Structure
EndEnumeration

; a dummy structure with an empty array, to make access
; to the Entry list (which is a memory area) easy.
;
Structure VariableGadget_ItemList
  item.VariableGadget_Entry[0]
EndStructure

; SetGadgetData() stores the VariableGadget pointer
; SetGadgetItemData() contains the real index in the Entry array (this never needs to be changed)

; structure representing one gadget
;
Structure VariableGadget
  Gadget.i       ; purebasic #Gadget (can be #PB_Any)
  ExtraColumns.l ; number of extra columns in the gadget
  ItemCount.l    ; number of items
  Items.i        ; memory area for the items
  CustomData.i   ; free to be used by the caller
  IsLocked.l     ; if locked, no events get processed to not mess things up (FlushEvents() may be called while adding items to the gadget!)
  CurrentParent.l; current parent item while adding items
  CurrentSublevel.l ; current sublevel while adding
  
  SortColumn.l    ; -1 if none
  SortDirection.l ; 1 or -1
  IndexSort.l     ; true if the main level should be sorted by index rather than name
  
  CompilerIf #CompileLinuxGtk
    TreeModel.i ; While the gadget is locked, store the model here
  CompilerEndIf
EndStructure

Global NewList VariableGadget_List.VariableGadget() ; currently created gadgets

Global Dim VariableGadget_Icons(#TYPE_MAX) ; icons for the variable types
Global VariableGadget_NodeOpen, VariableGadget_NodeClose

; internal function to catch the 12x12 images and put them in the right size
; (ie 16x16 on windows)
;
UsePNGImageDecoder()
Procedure VariableGadget_CatchIcon(*Address)
  
  CompilerIf #CompileMac
    ; TODO: implement DrawImage() on MacOS
    result = CatchImage(#PB_Any, *Address)
  CompilerElse
    realImage = CatchImage(#PB_Any, *Address)
    result = CreateImage(#PB_Any, #DEFAULT_ListIconImageSize, #DEFAULT_ListIconImageSize)
    
    If result And realImage And StartDrawing(ImageOutput(result))
      Box(0, 0, #DEFAULT_ListIconImageSize, #DEFAULT_ListIconImageSize, $FFFFFF)
      DrawImage(ImageID(realImage), #DEFAULT_ListIconImageOffset, #DEFAULT_ListIconImageOffset)
      StopDrawing()
    EndIf
  CompilerEndIf
  
  ProcedureReturn result
EndProcedure



; Get the #SORTTYPE_xxx value for the given debugger type
; No List/Array types allowed (these are not displayed in the gadget anyway)
;
Procedure VariableGadget_SortType(type)
  If IS_POINTER(type)
    ProcedureReturn #SORTTYPE_Pointer
  Else
    Select type & #TYPEMASK
      Case #TYPE_BYTE:        ProcedureReturn #SORTTYPE_Byte
      Case #TYPE_ASCII:       ProcedureReturn #SORTTYPE_Ascii
      Case #TYPE_CHARACTER:   ProcedureReturn #SORTTYPE_Character
      Case #TYPE_UNICODE:     ProcedureReturn #SORTTYPE_Unicode
      Case #TYPE_WORD:        ProcedureReturn #SORTTYPE_Word
      Case #TYPE_LONG:        ProcedureReturn #SORTTYPE_Long
      Case #TYPE_INTEGER:     ProcedureReturn #SORTTYPE_Integer
      Case #TYPE_QUAD:        ProcedureReturn #SORTTYPE_Quad
      Case #TYPE_FLOAT:       ProcedureReturn #SORTTYPE_Float
      Case #TYPE_DOUBLE:      ProcedureReturn #SORTTYPE_Double
      Case #TYPE_STRING:      ProcedureReturn #SORTTYPE_String
      Case #TYPE_FIXEDSTRING: ProcedureReturn #SORTTYPE_FixedString
      Case #TYPE_STRUCTURE:   ProcedureReturn #SORTTYPE_Structure
      Default:                ProcedureReturn #SORTTYPE_Unknown
    EndSelect
  EndIf
EndProcedure

; Compare two items in the gadget (for sorting, returns >0, 0, <0)
;
; Note:
;   Array, List, Map are only possible inside structures (where they always sort by order),
;   So we do not have to take care of these in the compare proc
;
Procedure VariableGadget_Compare(*Gadget.VariableGadget, index1, index2)
  *items.VariableGadget_ItemList = *Gadget\Items
  *entry1.VariableGadget_Entry   = @*items\item[index1]
  *entry2.VariableGadget_Entry   = @*items\item[index2]
  
  If *entry1\Parent = -1 And *entry2\Parent = -1
    ; both are toplevel items, so compare them
    ; since we only compare toplevel items, there are no spaces at the names
    
    ; Get the result for the name compare always, as it is a fallback below
    ;
    If *Gadget\IndexSort
      NameResult = (index1 - index2) * *Gadget\SortDirection ; compare indexes instead of names for the main level
    Else
      ; ignore the * in front of names
      *Name1 = @*entry1\Name$
      If PeekC(*Name1) = '*'
        *Name1 + SizeOf(Character)
      EndIf
      
      *Name2 = @*entry2\Name$
      If PeekC(*Name2) = '*'
        *Name2 + SizeOf(Character)
      EndIf
      
      NameResult =  CompareMemoryString(*Name1, *Name2, #PB_String_NoCase) * *Gadget\SortDirection ; PB is case insensitive
    EndIf
    
    If *Gadget\SortColumn = *Gadget\ExtraColumns ; Name column
      ProcedureReturn NameResult
      
    ElseIf *Gadget\SortColumn = *Gadget\ExtraColumns+1 ; value column
                                                       ; Spechial thing for the Watchlist. List all out of scope values at the end
      If *entry1\Value$ = "---"
        If *entry2\Value$ <> "---"
          ProcedureReturn 1
        EndIf
      ElseIf *entry2\Value$ = "---"
        ProcedureReturn -1
      EndIf
      
      ; sort first by type, then by value
      Type1 = VariableGadget_SortType(*entry1\Type)
      Type2 = VariableGadget_SortType(*entry2\Type)
      
      If Type1 <> Type2
        ProcedureReturn (Type1 - Type2) * *Gadget\SortDirection
        
      ElseIf Type1 = #SORTTYPE_Structure ; structure. compare structure types
        Struct1$ = StringField(*entry1\Name$, 2, ".")
        Struct2$ = StringField(*entry2\Name$, 2, ".")
        Result = CompareMemoryString(@Struct1$, @Struct2$, #PB_String_NoCase) * *Gadget\SortDirection
        If Result = 0
          ProcedureReturn NameResult
        Else
          ProcedureReturn Result
        EndIf
        
      ElseIf *entry1\Value$ = *entry2\Value$ Or Type1 = #SORTTYPE_Unknown ; equal values, use name then
        ProcedureReturn NameResult
        
      ElseIf Type1 <= #SORTTYPE_Pointer ; integer types
        If VariableIsHex
          Quad1.q = Val("$" + *entry1\Value$)
          Quad2.q = Val("$" + *entry2\Value$)
        Else
          Quad1.q = Val(*entry1\Value$)
          Quad2.q = Val(*entry2\Value$)
        EndIf
        
        ; cannot just do "ProcedureReturn Quad1-Quad2" as that could exceed the returnvalue size on x86
        If Quad1 = Quad2
          ProcedureReturn 0
        ElseIf Quad1 < Quad2
          ProcedureReturn (-1) * *Gadget\SortDirection
        Else
          ProcedureReturn *Gadget\SortDirection
        EndIf
        
      ElseIf Type1 <= #SORTTYPE_Double  ; float types
        Double1.d = ValD(*entry1\Value$)
        Double2.d = ValD(*entry2\Value$)
        
        If Double1 = Double2
          ProcedureReturn 0
        ElseIf Double1 < Double2
          ProcedureReturn (-1) * *Gadget\SortDirection
        Else
          ProcedureReturn *Gadget\SortDirection
        EndIf
        
      Else ; string types
        ProcedureReturn CompareMemoryString(@*entry1\Value$, @*entry2\Value$) * *Gadget\SortDirection ; use case sensitive here
        
      EndIf
      
    Else  ; any of the extra columns
      Extra1$ = StringField(*entry1\Extra$, *Gadget\SortColumn+1, Chr(10))
      Extra2$ = StringField(*entry2\Extra$, *Gadget\SortColumn+1, Chr(10))
      
      Result = CompareMemoryString(@Extra1$, @Extra2$, #PB_String_NoCase)
      If Result = #PB_String_Equal
        ProcedureReturn NameResult
      Else
        ProcedureReturn Result * *Gadget\SortDirection
      EndIf
    EndIf
    
  Else
    ; at least one is not a toplevel one
    ; find the index of the toplevel item for both items
    topindex1 = index1
    While *items\item[topindex1]\Parent <> -1
      topindex1 = *items\item[topindex1]\Parent
    Wend
    
    topindex2 = index2
    While *items\item[topindex2]\Parent <> -1
      topindex2 = *items\item[topindex2]\Parent
    Wend
    
    If topindex1 = topindex2
      ; both are in the same toplevel node, so just compare by index to keep the
      ; structures correct (do not apply sort direction)
      ; this also applies if one entry is the direct parent of the other
      ProcedureReturn index1 - index2
      
    Else
      ; both are in different toplevel nodes. compare these
      ProcedureReturn VariableGadget_Compare(*Gadget, topindex1, topindex2)
    EndIf
  EndIf
  
  ProcedureReturn Result
EndProcedure

; Platform specific sort implementation stuff
;
CompilerIf #CompileWindows
  Structure ListIconData ; LPARAM data structure for ListIconGadget
    UserData.i
  EndStructure
  
  Procedure VariableGadget_SortProc(*data1.ListIconData, *data2.ListIconData, *Gadget.VariableGadget)
    If *data1 = 0 Or *data2 = 0
      ProcedureReturn 0 ; this may not happen, as we use SetGadgetItemData() to set all index values
    Else
      ProcedureReturn VariableGadget_Compare(*Gadget, *data1\UserData, *data2\UserData)
    EndIf
  EndProcedure
  
  Procedure VariableGadget_ParentCallback(Window, Message, wParam, lParam)
    Callback = GetProp_(Window, "Variable_Callback")
    
    If Message = #WM_NCDESTROY
      ; remove our prop, this is the last message, so no problem
      RemoveProp_(Window, "Variable_Callback")
      
    ElseIf Message = #WM_NOTIFY
      *nmv.NM_LISTVIEW = lParam
      If *nmv\hdr\code = #LVN_COLUMNCLICK
        
        ; find the right gadget (if it is a variablegadget at all)
        ForEach VariableGadget_List()
          If *nmv\hdr\hwndFrom = GadgetID(VariableGadget_List()\Gadget)
            
            ; set new column/direction
            If VariableGadget_List()\SortColumn = *nmv\iSubItem
              VariableGadget_List()\SortDirection * -1
            Else
              VariableGadget_List()\SortColumn    = *nmv\iSubItem
              VariableGadget_List()\SortDirection = 1
            EndIf
            
            ; sort
            SendMessage_(*nmv\hdr\hwndFrom, #LVM_SORTITEMS, @VariableGadget_List(), @VariableGadget_SortProc())
            SetSortArrow(VariableGadget_List()\Gadget, VariableGadget_List()\SortColumn, VariableGadget_List()\SortDirection)
            
            ProcedureReturn 0
          EndIf
        Next VariableGadget_List()
      EndIf
      
    EndIf
    
    If Callback
      ProcedureReturn CallWindowProc_(Callback, Window, Message, wParam, lParam)
    Else
      ProcedureReturn DefWindowProc_(Window, Message, wParam, lParam)
    EndIf
  EndProcedure
CompilerEndIf

CompilerIf 0;#CompileMac
  Global ItemCompareUPP
  
  ;
  ; Problem with this implementation:
  ;   The sorting itself works well here, but structured items do not work, as we cannot ensure that they are always sorted top-down
  ;   as on Windows. The reason is that we have no control over the SortDirection. OSX just asks us to order the items, but the direction
  ;   is handled by the DataBrowser. There is no re-sort when simply reversing items in the list, as OSX caches the sort information.
  ;   Because of this, we cannot swap structure items if the sort order changes to remain top-down. So in the end, when sorting
  ;   bottom-up, structures get reversed in the view.
  ;
  ;   The only solution to this is to have real containers in the DataBrowser which means customly implement the whole gadget for the IDE. :(
  ;
  
  #kDataBrowserOrderIncreasing = 1
  #kDataBrowserOrderDecreasing = 2
  
  #kDataBrowserListViewSortableColumn = 1 << (16 + 2)
  
  ; To get the PB GadgetID from the ControlRef
  ImportC ""
    PB_Gadget_GetProperty(Gadget, Property)
  EndImport
  
  #ID_Property = 'ID'
  
  ; Must return true if itemOne < itemTwo, and false if itemOne >= itemTwo
  ;
  ProcedureC VariableGadget_ItemCompareCallback(Gadget, itemOne, itemTwo, sortProperty)
    GadgetID = PB_Gadget_GetProperty(Gadget, #ID_Property)
    
    *Gadget.VariableGadget = GetGadgetData(GadgetID)
    RealIndex1 = GetGadgetItemData(GadgetID, itemOne-1)  ; The itemID values are the index+1 on OSX
    RealIndex2 = GetGadgetItemData(GadgetID, itemTwo-1)
    
    ; Find out the ColumnIndex which is being sorted
    ; Note: There is a separate image column, as the VAriableGadget always includes images
    SortColumn = -1
    For i = 1 To *Gadget\ExtraColumns+2
      If GetDataBrowserTableViewColumnProperty_(Gadget, i, @ColumnProperty) = #noErr
        If ColumnProperty = sortProperty
          SortColumn = i-1
          Break
        EndIf
      EndIf
    Next i
    
    
    ; Update the Column+Direction in the structure so the compare function knows them, and a future
    ; VariableGadget_Sort() uses the correct data
    ;
    SortDirection = #kDataBrowserOrderIncreasing ; fallback
                                                 ;GetDataBrowserSortOrder_(Gadget, @SortDirection)
    
    *Gadget\SortColumn = SortColumn
    If SortDirection = #kDataBrowserOrderIncreasing
      *Gadget\SortDirection = 1
    Else
      *Gadget\SortDirection = -1
    EndIf
    
    ; Note: The callback always should not take the direction into account (the Gadget does that),
    ;   so in case of decreasing sort, we must reverse the result to get the correct output.
    ;   We cannot just have SortDirection fixed at 1, as structures are treated specially (always by index),
    ;   so they come out wrong if the compare function is not aware of the true direction
    ;
    If SortColumn = -1
      ProcedureReturn #False ; return >= (should never happen)
      
    ElseIf (VariableGadget_Compare(*Gadget, RealIndex1, RealIndex2) * *Gadget\SortDirection) < 0
      ProcedureReturn #True ;  <
      
    Else
      ProcedureReturn #False ; >=
      
    EndIf
    
  EndProcedure
  
CompilerEndIf

; Sort the entire gadget with the given settings
; Does nothing if SortColumn=-1, so this can be called after all changes
;
Procedure VariableGadget_Sort(Gadget)
  *Gadget.VariableGadget = GetGadgetData(Gadget)
  
  CompilerIf #CompileWindows
    If *Gadget\SortColumn <> -1
      SendMessage_(GadgetID(Gadget), #LVM_SORTITEMS, *Gadget, @VariableGadget_SortProc())
    EndIf
    
    SetSortArrow(Gadget, *Gadget\SortColumn, *Gadget\SortDirection)
  CompilerEndIf
  
  CompilerIf #CompileMac
    ; Even though OSX takes care of most of the sorting stuff itself (column arrow etc), we still must
    ; re-initiate a sort after we made changes, because the PB ListIconGadget always adds items at the end
    ; and only maps the internal linkedlist through the data callback, so a single AddGadgetItem() in the middle
    ; messes up the cached sort data that OSX seems to be keeping
    ;
    ;     If *Gadget\SortColumn <> -1
    ;       ; +1, as the VariableGadget always has an image column!
    ;       If GetDataBrowserTableViewColumnProperty_(GadgetID(Gadget), *Gadget\SortColumn+1, @SortColumnID) = #noErr
    ;         SetDataBrowserSortProperty_(GadgetID(Gadget), SortColumnID)
    ;         If *Gadget\SortDirection > 0
    ;           SetDataBrowserSortOrder_(GadgetID(Gadget), #kDataBrowserOrderIncreasing)
    ;         Else
    ;           SetDataBrowserSortOrder_(GadgetID(Gadget), #kDataBrowserOrderDecreasing)
    ;         EndIf
    ;       EndIf
    ;     EndIf
  CompilerEndIf
EndProcedure



; creates a new gadget
; returns the result of ListIconGadget()
; so you can use the result with ResizeGadget(), HideGadget(), etc, but also
; with the VariableGadget_...() functions
Procedure VariableGadget_Create(Gadget, x, y, Width, Height, ExtraColumn$, DefaultSort, IndexSort)
  Static IsInitialized
  
  If IsInitialized = 0
    VariableGadget_Icons(#TYPE_BYTE)       = VariableGadget_CatchIcon(?VariableGadget_Byte)
    VariableGadget_Icons(#TYPE_WORD)       = VariableGadget_CatchIcon(?VariableGadget_Word)
    VariableGadget_Icons(#TYPE_LONG)       = VariableGadget_CatchIcon(?VariableGadget_Long)
    VariableGadget_Icons(#TYPE_STRUCTURE)  = VariableGadget_CatchIcon(?VariableGadget_Struct)
    VariableGadget_Icons(#TYPE_STRING)     = VariableGadget_CatchIcon(?VariableGadget_String)
    VariableGadget_Icons(#TYPE_FLOAT)      = VariableGadget_CatchIcon(?VariableGadget_Float)
    VariableGadget_Icons(#TYPE_FIXEDSTRING)= VariableGadget_CatchIcon(?VariableGadget_Fixed)
    VariableGadget_Icons(#TYPE_CHARACTER)  = VariableGadget_CatchIcon(?VariableGadget_Char)
    VariableGadget_Icons(#TYPE_DOUBLE)     = VariableGadget_CatchIcon(?VariableGadget_Double)
    VariableGadget_Icons(#TYPE_QUAD)       = VariableGadget_CatchIcon(?VariableGadget_Quad)
    VariableGadget_Icons(#TYPE_INTEGER)    = VariableGadget_CatchIcon(?VariableGadget_Integer)
    VariableGadget_Icons(#TYPE_ASCII)      = VariableGadget_CatchIcon(?VariableGadget_Ascii)
    VariableGadget_Icons(#TYPE_UNICODE)    = VariableGadget_CatchIcon(?VariableGadget_Unicode)
    
    
    VariableGadget_NodeOpen  = VariableGadget_CatchIcon(?VariableGadget_NodeOpen)
    VariableGadget_NodeClose = VariableGadget_CatchIcon(?VariableGadget_NodeClose)
    IsInitialized = 1
  EndIf
  
  If AddElement(VariableGadget_List())
    
    If ExtraColumn$ <> ""
      Result = ListIconGadget(Gadget, x, y, Width, Height, StringField(ExtraColumn$, 1, Chr(10)), 100, #PB_ListIcon_GridLines|#PB_ListIcon_FullRowSelect)
      If Gadget = #PB_Any
        VariableGadget_List()\Gadget = Result
      Else
        VariableGadget_List()\Gadget = Gadget
      EndIf
      
      ExtraColumns = 1
      While StringField(ExtraColumn$, ExtraColumns+1, Chr(10)) <> ""
        AddGadgetColumn(VariableGadget_List()\Gadget, ExtraColumns, StringField(ExtraColumn$, ExtraColumns+1, Chr(10)), 100)
        ExtraColumns + 1
      Wend
      
      AddGadgetColumn(VariableGadget_List()\Gadget, ExtraColumns, Language("Debugger","Name"), 200)
      AddGadgetColumn(VariableGadget_List()\Gadget, ExtraColumns+1, Language("Debugger","Value"), 800)
      VariableGadget_List()\ExtraColumns = ExtraColumns
    Else
      Result = ListIconGadget(Gadget, x, y, Width, Height, Language("Debugger","Name"), 200, #PB_ListIcon_GridLines|#PB_ListIcon_FullRowSelect)
      If Gadget = #PB_Any
        VariableGadget_List()\Gadget = Result
      Else
        VariableGadget_List()\Gadget = Gadget
      EndIf
      
      AddGadgetColumn(VariableGadget_List()\Gadget, 1, Language("Debugger","Value"), 800)
      VariableGadget_List()\ExtraColumns = 0
    EndIf
    
    VariableGadget_List()\IndexSort = IndexSort
    If DefaultSort
      VariableGadget_List()\SortColumn = VariableGadget_List()\ExtraColumns
      VariableGadget_List()\SortDirection = 1
    Else
      VariableGadget_List()\SortColumn = -1
    EndIf
    
    ; Setup Header click monitoring for the sort
    ;
    CompilerIf #CompileWindows
      Parent = GetParent_(GadgetID(VariableGadget_List()\Gadget))
      If GetProp_(Parent, "Variable_Callback") = 0 ; no monitoring callback yet
        SetProp_(Parent, @"Variable_Callback", SetWindowLongPtr_(Parent, #GWL_WNDPROC, @VariableGadget_ParentCallback()))
      EndIf
    CompilerEndIf
    
    ; Setup the sort callback for OSX
    ;
    CompilerIf #CompileMac
      ;       If ItemCompareUPP = 0
      ;         ItemCompareUPP = NewDataBrowserItemCompareUPP_(@VariableGadget_ItemCompareCallback())
      ;       EndIf
      ;
      ;       If ItemCompareUPP
      ;         ; add our sort callback to the listicon's callbacks
      ;         Callbacks.DataBrowserCallbacks\version = #kDataBrowserLatestCallbacks ; in MacExtensions.pb
      ;
      ;         If GetDataBrowserCallbacks_(GadgetID(VariableGadget_List()\Gadget), @Callbacks) = #noErr
      ;           Callbacks\itemCompareCallback = ItemCompareUPP
      ;           SetDataBrowserCallbacks_(GadgetID(VariableGadget_List()\Gadget), @Callbacks)
      ;         EndIf
      ;
      ;         ; set all columns to sortable
      ;         For i = 0 To VariableGadget_List()\ExtraColumns+1 ; the ImageColumn is only present after the first AddGadgetItem
      ;           If GetDataBrowserTableViewColumnProperty_(GadgetID(VariableGadget_List()\Gadget), i, @ColumnProperty) = #noErr
      ;             If GetDataBrowserPropertyFlags_(GadgetID(VariableGadget_List()\Gadget), ColumnProperty, @PropertyFlags) = #noErr
      ;               PropertyFlags | #kDataBrowserListViewSortableColumn
      ;               SetDataBrowserPropertyFlags_(GadgetID(VariableGadget_List()\Gadget), ColumnProperty, PropertyFlags)
      ;             EndIf
      ;           EndIf
      ;         Next i
      ;       EndIf
    CompilerEndIf
    
    SetGadgetData(VariableGadget_List()\Gadget, @VariableGadget_List())
    ProcedureReturn Result
  Else
    ProcedureReturn 0
  EndIf
  
EndProcedure

; use this instead of "FreeGadget()" so that the item list is properly freed
;
Procedure VariableGadget_Free(Gadget)
  
  *VariableGadget.VariableGadget = GetGadgetData(Gadget)
  ChangeCurrentElement(VariableGadget_List(), *VariableGadget)
  
  If VariableGadget_List()\Items
    *items.VariableGadget_ItemList = VariableGadget_List()\Items
    For i = 0 To VariableGadget_List()\ItemCount-1
      FreePBString(@*items\item[i]\Name$)
      FreePBString(@*items\item[i]\Value$)
      FreePBString(@*items\item[i]\Extra$)
    Next i
    
    FreeMemory(VariableGadget_List()\Items)
  EndIf
  
  FreeGadget(Gadget)
  DeleteElement(VariableGadget_List())
  
EndProcedure

; Lock variablegadget display updates (to speed up inserting)
; You MUST NOT call SetGadgetState() on the gadget while it is locked! (Linux thing)
;
; This also locks the processing of VariableGadget_Event(), so there is no accidental
; expand done while not all items are added to the gadget.
;
Procedure VariableGadget_Lock(Gadget)
  *VariableGadget.VariableGadget = GetGadgetData(Gadget)
  *VariableGadget\IsLocked = #True
  
  CompilerIf #CompileWindows
    SendMessage_(GadgetID(Gadget), #WM_SETREDRAW, #False, 0)
  CompilerEndIf
  
  CompilerIf #CompileLinuxGtk
    *VariableGadget.VariableGadget = GetGadgetData(Gadget)
    *VariableGadget\TreeModel = gtk_tree_view_get_model_(GadgetID(Gadget))
    g_object_ref_(*VariableGadget\TreeModel) ; must be ref'ed or it is destroyed
    gtk_tree_view_set_model_(GadgetID(Gadget), #Null) ; disconnect the model for a faster update
  CompilerEndIf
EndProcedure

Procedure VariableGadget_Unlock(Gadget)
  *VariableGadget.VariableGadget = GetGadgetData(Gadget)
  *VariableGadget\IsLocked = #False
  
  CompilerIf #CompileWindows
    SendMessage_(GadgetID(Gadget), #WM_SETREDRAW, #True, 0)
    InvalidateRect_(GadgetID(Gadget), #Null, #True);
  CompilerEndIf
  
  CompilerIf #CompileLinuxGtk
    *VariableGadget.VariableGadget = GetGadgetData(Gadget)
    gtk_tree_view_set_model_(GadgetID(Gadget), *VariableGadget\TreeModel) ; reconnect the model
    g_object_unref_(*VariableGadget\TreeModel)                            ; release reference
  CompilerEndIf
EndProcedure

; Get the Chr(10) separated text for an item in the VariableGadget
; (handles Array, List, Map stuff)
;
Procedure.s VariableGadget_EntryText(*VariableGadget.VariableGadget, realindex)
  *items.VariableGadget_ItemList = *VariableGadget\Items
  
  Text$ = *items\item[realindex]\Extra$ + *items\item[realindex]\Name$
  
  Select *items\item[realindex]\Kind
      
    Case #TYPE_ARRAY
      ; For Arrays, we include the dimensions (in Value$)
      ; directly on the name because it just looks better
      Text$ + "(" + *items\item[realindex]\Value$ + ")"
      
    Case #TYPE_LINKEDLIST, #TYPE_MAP
      ; For List, Map we set the info in the Value column, but add the ()
      Text$ + "()" + Chr(10) + *items\item[realindex]\Value$
      
    Default
      ; Normal item
      Text$ + Chr(10) + *items\item[realindex]\Value$
      
  EndSelect
  
  ProcedureReturn Text$
EndProcedure

; you MUST call this for every event you receive for the gadget
;
Procedure VariableGadget_Event(Gadget)
  DoSort = 0
  
  If EventType() = #PB_EventType_LeftDoubleClick
    index = GetGadgetState(Gadget)
    
    If index <> -1
      
      *VariableGadget.VariableGadget = GetGadgetData(Gadget)
      ChangeCurrentElement(VariableGadget_List(), *VariableGadget)
      
      If VariableGadget_List()\IsLocked = #False And VariableGadget_List()\Items
        *items.VariableGadget_ItemList = VariableGadget_List()\Items
        
        realindex = GetGadgetItemData(Gadget, index)
        indexbefore = index
        
        VariableGadget_Lock(Gadget)
        
        If *items\item[realindex]\Node = 1
          RemoveGadgetItem(Gadget, index) ; re-add this item to change the image
          AddGadgetItem(Gadget, index, VariableGadget_EntryText(*VariableGadget, realindex), ImageID(VariableGadget_NodeClose))
          SetGadgetItemData(Gadget, index, realindex)
          
          *items\item[realindex]\Node = 2
          sublevel = *items\item[realindex]\Sublevel
          index + 1
          realindex + 1
          
          While realindex < VariableGadget_List()\ItemCount And *items\item[realindex]\sublevel > sublevel
            If *items\item[realindex]\Node = 1
              AddGadgetItem(Gadget, index, VariableGadget_EntryText(*VariableGadget, realindex), ImageID(VariableGadget_NodeOpen))
              SetGadgetItemData(Gadget, index, realindex)
              index + 1
              
              ; skip node contents
              sublevel2 = *items\item[realindex]\Sublevel
              realindex + 1
              While  realindex < VariableGadget_List()\ItemCount And *items\item[realindex]\sublevel > sublevel2
                realindex + 1
              Wend
            Else
              If *items\item[realindex]\Node = 2
                Image = VariableGadget_NodeClose
              Else
                Image = VariableGadget_Icons(*items\item[realindex]\Type & #TYPEMASK)
              EndIf
              AddGadgetItem(Gadget, index, VariableGadget_EntryText(*VariableGadget, realindex), ImageID(Image))
              SetGadgetItemData(Gadget, index, realindex)
              index + 1
              realindex + 1
            EndIf
          Wend
          
          DoSort = 1
          
          
        ElseIf *items\item[realindex]\Node = 2
          RemoveGadgetItem(Gadget, index) ; re-add this item to change the image
          AddGadgetItem(Gadget, index, VariableGadget_EntryText(*VariableGadget, realindex), ImageID(VariableGadget_NodeOpen))
          SetGadgetItemData(Gadget, index, realindex)
          
          *items\item[realindex]\Node = 1
          sublevel = *items\item[realindex]\Sublevel
          index + 1
          realindex + 1
          
          While realindex < VariableGadget_List()\ItemCount And *items\item[realindex]\sublevel > sublevel
            If *items\item[realindex]\Node = 1
              RemoveGadgetItem(Gadget, index)
              
              ; skip node contents (because they are not visible in the gadget)
              sublevel2 = *items\item[realindex]\Sublevel
              realindex + 1
              While  realindex < VariableGadget_List()\ItemCount And *items\item[realindex]\sublevel > sublevel2
                realindex + 1
              Wend
            Else
              RemoveGadgetItem(Gadget, index)
              realindex + 1
            EndIf
          Wend
          
        EndIf
        
        VariableGadget_Unlock(Gadget)
        
        SetGadgetState(Gadget, indexbefore)
        
        If DoSort
          ; must be after the SetGadgetState, as the index is wrong else!
          VariableGadget_Sort(Gadget)
        EndIf
        
      EndIf
      
      
    EndIf
    
  EndIf
  
EndProcedure

; this must be called before adding any items to the gadget
; to allocate the space for them
; (it also clears the old gadget item list)
; VariableGadget_Allocate(Gadget, 0) will just clear the gadget
;
Procedure VariableGadget_Allocate(Gadget, NbItems)
  
  *VariableGadget.VariableGadget = GetGadgetData(Gadget)
  ChangeCurrentElement(VariableGadget_List(), *VariableGadget)
  
  ; free the old variable list
  ;
  If VariableGadget_List()\Items
    *items.VariableGadget_ItemList = VariableGadget_List()\Items
    For i = 0 To VariableGadget_List()\ItemCount-1
      FreePBString(@*items\item[i]\Name$)
      FreePBString(@*items\item[i]\Value$)
      FreePBString(@*items\item[i]\Extra$)
    Next i
    
    FreeMemory(VariableGadget_List()\Items)
    VariableGadget_List()\Items = 0
  EndIf
  
  ; set the current count to 0, and reset parent index
  ;
  VariableGadget_List()\ItemCount       = 0
  VariableGadget_List()\CurrentParent   = -1
  VariableGadget_List()\CurrentSublevel = 0
  
  ; allocate new space for the items
  ;
  If NbItems > 0
    VariableGadget_List()\Items = AllocateMemory(NbItems * SizeOf(VariableGadget_Entry))
  EndIf
  
  ClearGadgetItems(Gadget) ; clear the items in the gadget
  
  
EndProcedure

; call this function to expand all primary nodes an collapse all others
; (used for array display for example)
;
Procedure VariableGadget_Expand(Gadget)
  
  *VariableGadget.VariableGadget = GetGadgetData(Gadget)
  ChangeCurrentElement(VariableGadget_List(), *VariableGadget)
  
  If VariableGadget_List()\Items
    ClearGadgetItems(Gadget)
    Index = 0
    
    *items.VariableGadget_ItemList = VariableGadget_List()\Items
    For i = 0 To VariableGadget_List()\ItemCount-1
      
      If *items\item[i]\sublevel < 2 ; display all items of sublevel 0 and 1
        
        If *items\item[i]\Node <> 0 And *items\item[i]\sublevel = 0
          Image = VariableGadget_NodeClose
          *items\item[i]\Node = 2
        ElseIf *items\item[i]\Node <> 0
          Image = VariableGadget_NodeOpen
          *items\item[i]\Node = 1
        Else
          Image = VariableGadget_Icons(*items\item[i]\Type & #TYPEMASK)
        EndIf
        
        AddGadgetItem(Gadget, Index, VariableGadget_EntryText(*VariableGadget, i), ImageID(Image))
        SetGadgetItemData(Gadget, Index, i)
        Index + 1
      Else
        If *items\item[i]\Node <> 0 ; a node -> set to collapsed
          *items\item[i]\Node = 1
        EndIf
        
      EndIf
      
    Next i
    
  EndIf
  
  
EndProcedure

; this sets the gadget to be used in the following _Add / _Set calls
; this is to speed up the list modification
;
Procedure VariableGadget_Use(Gadget)
  Shared *VariableGadget_Used.VariableGadget
  *VariableGadget_Used = GetGadgetData(Gadget)
EndProcedure

; add a variable To the gadget
; if *Value is a 0-pointer, the value field will be left empty
;

Procedure VariableGadget_Add(Type, DynamicType, Sublevel, Extra$, Name$, ModuleName$, *Value, Is64bit)
  Shared *VariableGadget_Used.VariableGadget
  
  ; prefix the module name
  If ModuleName$ <> ""
    Name$ = ModuleName$ + "::" + Name$
  EndIf
  
  If IS_ARRAY(Type) Or IS_LINKEDLIST(Type) Or IS_MAP(Type)
    Kind = Type
    Type = DynamicType
  Else
    Kind = 0
  EndIf
  
  Type & #IGNORE_PARAM ; remove the "direct param" flag if it is set
  
  index = *VariableGadget_Used\ItemCount
  *items.VariableGadget_ItemList = *VariableGadget_Used\Items
  
  ; add the separating chr(10) to the extra text
  If *VariableGadget_Used\ExtraColumns > 0
    If Extra$ = ""
      Extra$ = RSet("", *VariableGadget_Used\ExtraColumns, Chr(10))
    Else
      Extra$ + Chr(10)
    EndIf
  EndIf
  
  If *items
    ; find the current parent, if we ended a previous node
    While *VariableGadget_Used\CurrentSublevel > Sublevel And *VariableGadget_Used\CurrentParent <> -1
      *VariableGadget_Used\CurrentParent = *items\item[*VariableGadget_Used\CurrentParent]\Parent
      *VariableGadget_Used\CurrentSublevel - 1
    Wend
    *VariableGadget_Used\CurrentSublevel = Sublevel
    
    *items\item[index]\Kind     = Kind
    *items\item[index]\Type     = Type
    *items\item[index]\Node     = 0
    *items\item[index]\SubLevel = SubLevel
    *items\item[index]\Parent   = *VariableGadget_Used\CurrentParent
    *items\item[index]\Name$    = Name$
    *items\item[index]\Extra$   = Extra$
    *items\item[index]\Value$   = ""
    
    If IS_ARRAY(Kind)
      If *Value
        *items\item[index]\Value$ = PeekAscii(*Value) ; array dimensions
      Else
        *items\item[index]\Value$ = ""
      EndIf
      
    ElseIf IS_LINKEDLIST(Kind)
      If *Value
        If Is64bit
          If PeekQ(*Value) = -1
            Size$ = "-"
          Else
            Size$ = Str(PeekQ(*Value))
          EndIf
          If PeekQ(*Value+8) = -1
            Current$ = "-"
          Else
            Current$ = Str(PeekQ(*Value+8))
          EndIf
        Else
          If PeekL(*Value) = -1
            Size$ = "-"
          Else
            Size$ = Str(PeekL(*Value))
          EndIf
          If PeekL(*Value+4) = -1
            Current$ = "-"
          Else
            Current$ = Str(PeekL(*Value+4))
          EndIf
        EndIf
        *items\item[index]\Value$ = Language("Debugger","Size") + ": " + Size$ + "   " + Language("Debugger","Current") + ": " + Current$
      Else
        *items\item[index]\Value$ = ""
      EndIf
      
    ElseIf IS_MAP(Kind)
      If *Value
        *items\item[index]\Value$ = Language("Debugger", "Size")+": "
        If Is64bit
          If PeekQ(*Value) = -1
            *items\item[index]\Value$ + "-"
          Else
            *items\item[index]\Value$ +  Str(PeekQ(*Value))
          EndIf
          *Value + 8
        Else
          If PeekL(*Value) = -1
            *items\item[index]\Value$ +  "-"
          Else
            *items\item[index]\Value$ +  Str(PeekL(*Value))
          EndIf
          *Value + 4
        EndIf
        *items\item[index]\Value$ + "   " + Language("Debugger","Current")+": "
        If PeekB(*Value) ; IsCurrent
          *items\item[index]\Value$ + Chr(34)+PeekS(*Value+1)+Chr(34) ; in external debugger format
        Else
          *items\item[index]\Value$ + "-"
        EndIf
      Else
        *items\item[index]\Value$ = ""
      EndIf
      
    ElseIf IS_POINTER(Type)
      *items\item[index]\Name$ = "*" + *items\item[index]\Name$
      If *Value
        If Is64bit And VariableIsHex
          *items\item[index]\Value$ = Hex(PeekQ(*Value), #PB_Quad)
        ElseIf Is64bit
          *items\item[index]\Value$ = Str(PeekQ(*Value))
        ElseIf VariableIsHex
          *items\item[index]\Value$ = Hex(PeekL(*Value), #PB_Long)
        Else
          *items\item[index]\Value$ = Str(PeekL(*Value))
        EndIf
      EndIf
      
    Else ; not a pointer
      If Type = #TYPE_STRUCTURE ; structure, not a pointer
        *items\item[index]\Node = 1
        *VariableGadget_Used\CurrentParent = index ; this is the new parent
        
      ElseIf *Value
        Select Type & #TYPEMASK
          Case #TYPE_BYTE
            If VariableIsHex
              *items\item[index]\Value$ = Hex(PeekB(*Value), #PB_Byte)
            Else
              *items\item[index]\Value$ = Str(PeekB(*Value))
            EndIf
            
          Case #TYPE_ASCII
            If VariableIsHex
              *items\item[index]\Value$ = Hex(PeekB(*Value) & $FF) ; todo
            Else
              *items\item[index]\Value$ = Str(PeekB(*Value) & $FF)
            EndIf
            
          Case #TYPE_UNICODE
            If VariableIsHex
              *items\item[index]\Value$ = Hex(PeekW(*Value) & $FFFF) ; todo
            Else
              *items\item[index]\Value$ = Str(PeekW(*Value) & $FFFF)
            EndIf
            
          Case #TYPE_WORD
            If VariableIsHex
              *items\item[index]\Value$ = Hex(PeekW(*Value), #PB_Word)
            Else
              *items\item[index]\Value$ = Str(PeekW(*Value))
            EndIf
            
          Case #TYPE_LONG, #TYPE_CHARACTER ; chars are passed as longs
            If VariableIsHex
              *items\item[index]\Value$ = Hex(PeekL(*Value), #PB_Long)
            Else
              *items\item[index]\Value$ = Str(PeekL(*Value))
            EndIf
            
          Case #TYPE_STRING, #TYPE_FIXEDSTRING
            *items\item[index]\Value$ = Chr(34) + PeekS(*Value) + Chr(34)
            
          Case #TYPE_FLOAT
            *items\item[index]\Value$ = StrF_Debug(PeekF(*Value))
            
          Case #TYPE_DOUBLE
            *items\item[index]\Value$ = StrD_Debug(PeekD(*Value))
            
          Case #TYPE_QUAD
            If VariableIsHex
              *items\item[index]\Value$ = Hex(PeekQ(*Value), #PB_Quad)
            Else
              *items\item[index]\Value$ = Str(PeekQ(*Value))
            EndIf
            
          Case #TYPE_INTEGER
            If Is64bit And VariableIsHex
              *items\item[index]\Value$ = Hex(PeekQ(*Value), #PB_Quad)
            ElseIf Is64bit
              *items\item[index]\Value$ = Str(PeekQ(*Value))
            ElseIf VariableIsHex
              *items\item[index]\Value$ = Hex(PeekL(*Value), #PB_Long)
            Else
              *items\item[index]\Value$ = Str(PeekL(*Value))
            EndIf
            
        EndSelect
      EndIf
    EndIf
    
    If Sublevel = 0 ; only the main level is visible when adding!
      If *items\item[index]\Node = 1
        Image = VariableGadget_NodeOpen
      Else
        Image = VariableGadget_Icons(Type & #TYPEMASK)
      EndIf
      
      gadgetindex = CountGadgetItems(*VariableGadget_Used\Gadget)
      AddGadgetItem(*VariableGadget_Used\Gadget, gadgetindex, VariableGadget_EntryText(*VariableGadget_Used, index), ImageID(Image))
      SetGadgetItemData(*VariableGadget_Used\Gadget, gadgetindex, index)
    EndIf
    
    *items\item[index]\Name$ = Space(SubLevel * 3) + *items\item[index]\Name$
    
    *VariableGadget_Used\ItemCount + 1
  EndIf
  
EndProcedure

; After a number of VariableGadget_Set() with AutoSync=#False, call this
; to update the entire gadget content. (Use this when updating the whole list anyway)
;
Procedure VariableGadget_SyncAll()
  Shared *VariableGadget_Used.VariableGadget
  
  *items.VariableGadget_ItemList = *VariableGadget_Used\Items
  If *items
    Gadget = *VariableGadget_Used\Gadget
    Last   = CountGadgetItems(Gadget) - 1
    
    For i = 0 To Last
      index = GetGadgetItemData(Gadget, i)
      If *items\item[index]\Kind = #TYPE_ARRAY
        ; special handling for array type
        SetGadgetItemText(Gadget, i, *items\item[index]\Name$ + "(" + *items\item[index]\Value$ + ")", *VariableGadget_Used\ExtraColumns)
      Else
        SetGadgetItemText(Gadget, i, *items\item[index]\Value$, *VariableGadget_Used\ExtraColumns+1)
      EndIf
    Next i
  EndIf
EndProcedure

; Called internally: Sync only a single item to the gadget display
;
; NOTE: This is slow for gadgets with a large number of items, that's why
;   only the watchlist actually uses it. (The VariableViewer does SyncAll())
;
Procedure VariableGadget_SyncItem(ListIndex)
  Shared *VariableGadget_Used.VariableGadget
  
  *items.VariableGadget_ItemList = *VariableGadget_Used\Items
  If *items
    Gadget = *VariableGadget_Used\Gadget
    Last   = CountGadgetItems(Gadget) - 1
    
    For i = 0 To Last
      index = GetGadgetItemData(Gadget, i)
      If index = ListIndex ; found the item
        If *items\item[index]\Kind = #TYPE_ARRAY
          ; special handling for array type
          SetGadgetItemText(Gadget, i, *items\item[index]\Name$ + "(" + *items\item[index]\Value$ + ")", *VariableGadget_Used\ExtraColumns)
        Else
          SetGadgetItemText(Gadget, i, *items\item[index]\Value$, *VariableGadget_Used\ExtraColumns+1)
        EndIf
        Break
      EndIf
    Next i
  EndIf
EndProcedure

; set the value for the given variable
; (a 0-pointer for *Value empties the field)
;
; AutoSync: If true, directly update the gadget display, if false
;   this has to be done manually with SyncAll() or SyncItem()
;
Procedure VariableGadget_Set(index, *Value, Is64bit, AutoSync)
  Shared *VariableGadget_Used.VariableGadget
  
  *items.VariableGadget_ItemList = *VariableGadget_Used\Items
  If *items And index < *VariableGadget_Used\ItemCount And *Value
    Type = *items\item[index]\Type
    
    If IS_ARRAY(*items\item[index]\Kind)
      *items\item[index]\Value$ = PeekAscii(*Value) ; dimensions
      
    ElseIf IS_LINKEDLIST(*items\item[index]\Kind)
      If Is64bit
        If PeekQ(*Value) = -1
          Size$ = "-"
        Else
          Size$ = Str(PeekQ(*Value))
        EndIf
        If PeekQ(*Value+8) = -1
          Current$ = "-"
        Else
          Current$ = Str(PeekQ(*Value+8))
        EndIf
      Else
        If PeekL(*Value) = -1
          Size$ = "-"
        Else
          Size$ = Str(PeekL(*Value))
        EndIf
        If PeekL(*Value+4) = -1
          Current$ = "-"
        Else
          Current$ = Str(PeekL(*Value+4))
        EndIf
      EndIf
      *items\item[index]\Value$ = Language("Debugger","Size") + ": " + Size$ + "   " + Language("Debugger","Current") + ": " + Current$
      
    ElseIf IS_MAP(*items\item[index]\Kind)
      *items\item[index]\Value$ = Language("Debugger", "Size")+": "
      If Is64bit
        If PeekQ(*Value) = -1
          *items\item[index]\Value$ + "-"
        Else
          *items\item[index]\Value$ +  Str(PeekQ(*Value))
        EndIf
        *Value + 8
      Else
        If PeekL(*Value) = -1
          *items\item[index]\Value$ +  "-"
        Else
          *items\item[index]\Value$ +  Str(PeekL(*Value))
        EndIf
        *Value + 4
      EndIf
      *items\item[index]\Value$ + "   " + Language("Debugger","Current")+": "
      If PeekB(*Value) ; IsCurrent
        *items\item[index]\Value$ + Chr(34)+PeekS(*Value+1)+Chr(34) ; in external debugger format
      Else
        *items\item[index]\Value$ + "-"
      EndIf
      
    ElseIf IS_POINTER(Type)
      If Is64bit And VariableIsHex
        *items\item[index]\Value$ = Hex(PeekQ(*Value), #PB_Quad)
      ElseIf Is64bit
        *items\item[index]\Value$ = Str(PeekQ(*Value))
      ElseIf VariableIsHex
        *items\item[index]\Value$ = Hex(PeekL(*Value), #PB_Long)
      Else
        *items\item[index]\Value$ = Str(PeekL(*Value))
      EndIf
      
    Else
      Select Type & #TYPEMASK
        Case #TYPE_BYTE
          If VariableIsHex
            *items\item[index]\Value$ = Hex(PeekB(*Value), #PB_Byte)
          Else
            *items\item[index]\Value$ = Str(PeekB(*Value))
          EndIf
          
        Case #TYPE_ASCII
          If VariableIsHex
            *items\item[index]\Value$ = Hex(PeekB(*Value) & $FF)
          Else
            *items\item[index]\Value$ = Str(PeekB(*Value) & $FF)
          EndIf
          
        Case #TYPE_UNICODE
          If VariableIsHex
            *items\item[index]\Value$ = Hex(PeekW(*Value) & $FFFF)
          Else
            *items\item[index]\Value$ = Str(PeekW(*Value) & $FFFF)
          EndIf
          
        Case #TYPE_WORD
          If VariableIsHex
            *items\item[index]\Value$ = Hex(PeekW(*Value), #PB_Word)
          Else
            *items\item[index]\Value$ = Str(PeekW(*Value))
          EndIf
          
        Case #TYPE_LONG, #TYPE_CHARACTER ; chars are passed as longs
          If VariableIsHex
            *items\item[index]\Value$ = Hex(PeekL(*Value), #PB_Long)
          Else
            *items\item[index]\Value$ = Str(PeekL(*Value))
          EndIf
          
        Case #TYPE_STRING, #TYPE_FIXEDSTRING
          *items\item[index]\Value$ = Chr(34) + PeekS(*Value) + Chr(34)
          
        Case #TYPE_FLOAT
          *items\item[index]\Value$ = StrF_Debug(PeekF(*Value))
          
        Case #TYPE_DOUBLE
          *items\item[index]\Value$ = StrD_Debug(PeekD(*Value))
          
        Case #TYPE_QUAD
          If VariableIsHex
            *items\item[index]\Value$ = Hex(PeekQ(*Value), #PB_Quad)
          Else
            *items\item[index]\Value$ = Str(PeekQ(*Value))
          EndIf
          
        Case #TYPE_INTEGER
          If Is64bit And VariableIsHex
            *items\item[index]\Value$ = Hex(PeekQ(*Value), #PB_Quad)
          ElseIf Is64bit
            *items\item[index]\Value$ = Str(PeekQ(*Value))
          ElseIf VariableIsHex
            *items\item[index]\Value$ = Hex(PeekL(*Value), #PB_Long)
          Else
            *items\item[index]\Value$ = Str(PeekL(*Value))
          EndIf
          
      EndSelect
    EndIf
    
    ; update the text if the item is visible
    ;
    If AutoSync
      VariableGadget_SyncItem(index)
    EndIf
    
  EndIf
  
EndProcedure

; set the "Value" field of the given variable to the given string
; used to not existing variables (ie out of scope for watchlist)
;
; AutoSync: If true, directly update the gadget display, if false
;   this has to be done manually with SyncAll() or SyncItem()
;
Procedure VariableGadget_SetString(index, String$, AutoSync)
  Shared *VariableGadget_Used.VariableGadget
  
  *items.VariableGadget_ItemList = *VariableGadget_Used\Items
  If *items And index < *VariableGadget_Used\ItemCount
    *items\item[index]\Value$ = String$
    
    If AutoSync
      VariableGadget_SyncItem(index)
    EndIf
  EndIf
  
EndProcedure

; get the real index in the data list from the gadget index
;
Procedure VariableGadget_GadgetIndexToReal(Gadget, index)
  If index = -1
    ProcedureReturn -1
  Else
    ProcedureReturn GetGadgetItemData(Gadget, index)
  EndIf
EndProcedure

; returns the index of the current selected item in the full list
;
Procedure VariableGadget_GetState(Gadget)
  index = GetGadgetState(Gadget)
  If index = -1
    ProcedureReturn -1
  Else
    ProcedureReturn GetGadgetItemData(Gadget, index)
  EndIf
EndProcedure

; countgadgetitems on th virtual item list
;
Procedure VariableGadget_GetCount(Gadget)
  
  *VariableGadget.VariableGadget = GetGadgetData(Gadget)
  ProcedureReturn *VariableGadget\ItemCount
  
EndProcedure





DataSection
  
  VariableGadget_Byte:      : IncludeBinary #DEFAULT_DebuggerSource + "Data" + #Separator + "byte.png"
  VariableGadget_Word:      : IncludeBinary #DEFAULT_DebuggerSource + "Data" + #Separator + "word.png"
  VariableGadget_Long:      : IncludeBinary #DEFAULT_DebuggerSource + "Data" + #Separator + "long.png"
  VariableGadget_Struct:    : IncludeBinary #DEFAULT_DebuggerSource + "Data" + #Separator + "struct.png"
  VariableGadget_String:    : IncludeBinary #DEFAULT_DebuggerSource + "Data" + #Separator + "string.png"
  VariableGadget_Float:     : IncludeBinary #DEFAULT_DebuggerSource + "Data" + #Separator + "float.png"
  VariableGadget_NodeOpen:  : IncludeBinary #DEFAULT_DebuggerSource + "Data" + #Separator + "struct1.png"
  VariableGadget_NodeClose: : IncludeBinary #DEFAULT_DebuggerSource + "Data" + #Separator + "struct2.png"
  VariableGadget_Char:      : IncludeBinary #DEFAULT_DebuggerSource + "Data" + #Separator + "char.png"
  VariableGadget_Fixed:     : IncludeBinary #DEFAULT_DebuggerSource + "Data" + #Separator + "fixed.png"
  VariableGadget_Double:    : IncludeBinary #DEFAULT_DebuggerSource + "Data" + #Separator + "double.png"
  VariableGadget_Quad:      : IncludeBinary #DEFAULT_DebuggerSource + "Data" + #Separator + "quad.png"
  VariableGadget_Integer:   : IncludeBinary #DEFAULT_DebuggerSource + "Data" + #Separator + "integer.png"
  VariableGadget_Ascii:     : IncludeBinary #DEFAULT_DebuggerSource + "Data" + #Separator + "ascii.png"
  VariableGadget_Unicode:   : IncludeBinary #DEFAULT_DebuggerSource + "Data" + #Separator + "unicode.png"
  
EndDataSection