; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software and Gaetan DUPONT-PANON. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

Procedure FormUndo()
  PushListPosition(FormWindows())
  ChangeCurrentElement(FormWindows(),currentwindow)
  
  If FormWindows()\undo_pos > -1 And ListSize(FormWindows()\UndoActions())
    SelectElement(FormWindows()\UndoActions(), FormWindows()\undo_pos)
    
    If ListSize(FormWindows()\UndoActions()\ActionGadget())
      If FormWindows()\UndoActions()\type = #Undo_Create
        ForEach FormWindows()\UndoActions()\ActionGadget()
          found = 0
          ForEach FormWindows()\FormGadgets()
            If FormWindows()\FormGadgets()\itemnumber = FormWindows()\UndoActions()\ActionGadget()\itemnumber
              found = 1
              Break
            EndIf
          Next
          If found
            DeleteElement(FormWindows()\FormGadgets())
          EndIf
        Next
        FD_UpdateObjList()
      Else
        If FormWindows()\UndoActions()\type = #Undo_Delete
          num = ListSize(FormWindows()\UndoActions()\ActionGadget())
          FirstElement(FormWindows()\UndoActions()\ActionGadget())
        Else
          num = ListSize(FormWindows()\UndoActions()\ActionGadget())/2
          FirstElement(FormWindows()\UndoActions()\ActionGadget())
        EndIf
        For i = 1 To num
          If FormWindows()\UndoActions()\type = #Undo_Delete
            If FormWindows()\UndoActions()\ActionGadget()\parent
              LastElement(FormWindows()\FormGadgets())
              AddElement(FormWindows()\FormGadgets())
            ElseIf SelectElement(FormWindows()\FormGadgets(),FormWindows()\UndoActions()\ActionGadget()\gadgetpos)
              InsertElement(FormWindows()\FormGadgets())
            Else
              LastElement(FormWindows()\FormGadgets())
              AddElement(FormWindows()\FormGadgets())
            EndIf
          Else
            found = 0
            ForEach FormWindows()\FormGadgets()
              If FormWindows()\FormGadgets()\itemnumber = FormWindows()\UndoActions()\ActionGadget()\itemnumber
                found = 1
                Break
              EndIf
            Next
          EndIf
          CopyList(FormWindows()\UndoActions()\ActionGadget()\Items(),FormWindows()\FormGadgets()\Items())
          CopyList(FormWindows()\UndoActions()\ActionGadget()\Columns(),FormWindows()\FormGadgets()\Columns())
          
          FormWindows()\FormGadgets()\itemnumber = FormWindows()\UndoActions()\ActionGadget()\itemnumber
          FormWindows()\FormGadgets()\x1 = FormWindows()\UndoActions()\ActionGadget()\x1
          FormWindows()\FormGadgets()\x2 = FormWindows()\UndoActions()\ActionGadget()\x2
          FormWindows()\FormGadgets()\y1 = FormWindows()\UndoActions()\ActionGadget()\y1
          FormWindows()\FormGadgets()\y2 = FormWindows()\UndoActions()\ActionGadget()\y2
          
          FormWindows()\FormGadgets()\lock_left = FormWindows()\UndoActions()\ActionGadget()\lock_left
          FormWindows()\FormGadgets()\lock_right = FormWindows()\UndoActions()\ActionGadget()\lock_right
          FormWindows()\FormGadgets()\lock_top=  FormWindows()\UndoActions()\ActionGadget()\lock_top
          FormWindows()\FormGadgets()\lock_bottom = FormWindows()\UndoActions()\ActionGadget()\lock_bottom
          
          FormWindows()\FormGadgets()\caption = FormWindows()\UndoActions()\ActionGadget()\caption
          FormWindows()\FormGadgets()\captionvariable = FormWindows()\UndoActions()\ActionGadget()\captionvariable
          FormWindows()\FormGadgets()\variable = FormWindows()\UndoActions()\ActionGadget()\variable
          
          FormWindows()\FormGadgets()\flags = FormWindows()\UndoActions()\ActionGadget()\flags
          FormWindows()\FormGadgets()\type = FormWindows()\UndoActions()\ActionGadget()\type
          FormWindows()\FormGadgets()\min = FormWindows()\UndoActions()\ActionGadget()\min
          FormWindows()\FormGadgets()\max =  FormWindows()\UndoActions()\ActionGadget()\max
          
          FormWindows()\FormGadgets()\frontcolor = FormWindows()\UndoActions()\ActionGadget()\frontcolor
          FormWindows()\FormGadgets()\backcolor =FormWindows()\UndoActions()\ActionGadget()\backcolor
          FormWindows()\FormGadgets()\gadgetfont = FormWindows()\UndoActions()\ActionGadget()\gadgetfont
          FormWindows()\FormGadgets()\gadgetfontsize = FormWindows()\UndoActions()\ActionGadget()\gadgetfontsize
          FormWindows()\FormGadgets()\gadgetfontflags = FormWindows()\UndoActions()\ActionGadget()\gadgetfontflags
          
          FormWindows()\FormGadgets()\parent = FormWindows()\UndoActions()\ActionGadget()\parent
          FormWindows()\FormGadgets()\parent_item =FormWindows()\UndoActions()\ActionGadget()\parent_item
          
          ; splitter
          FormWindows()\FormGadgets()\gadget1 = FormWindows()\UndoActions()\ActionGadget()\gadget1
          FormWindows()\FormGadgets()\gadget2 = FormWindows()\UndoActions()\ActionGadget()\gadget2
          FormWindows()\FormGadgets()\splitter = FormWindows()\UndoActions()\ActionGadget()\splitter
          
          If FormWindows()\FormGadgets()\type = #Form_Type_Splitter
            PushListPosition(FormWindows()\FormGadgets())
            g_1 = FormWindows()\FormGadgets()\gadget1
            g_2 = FormWindows()\FormGadgets()\gadget2
            inumber = FormWindows()\FormGadgets()\itemnumber
            ForEach FormWindows()\FormGadgets()
              If FormWindows()\FormGadgets()\itemnumber = g_1
                FormWindows()\FormGadgets()\splitter = inumber
              EndIf
              If FormWindows()\FormGadgets()\itemnumber = g_2
                FormWindows()\FormGadgets()\splitter = inumber
              EndIf
            Next
            PopListPosition(FormWindows()\FormGadgets())
          EndIf
          
          FormWindows()\FormGadgets()\pbany = FormWindows()\UndoActions()\ActionGadget()\pbany
          FormWindows()\FormGadgets()\disabled = FormWindows()\UndoActions()\ActionGadget()\disabled
          FormWindows()\FormGadgets()\hidden = FormWindows()\UndoActions()\ActionGadget()\hidden
          FormWindows()\FormGadgets()\state = FormWindows()\UndoActions()\ActionGadget()\state
          
          ; events
          FormWindows()\FormGadgets()\event_proc = FormWindows()\UndoActions()\ActionGadget()\event_proc
          
          ; custom gadgets
          FormWindows()\FormGadgets()\cust_init = FormWindows()\UndoActions()\ActionGadget()\cust_init
          FormWindows()\FormGadgets()\cust_create = FormWindows()\UndoActions()\ActionGadget()\cust_create
          FormWindows()\FormGadgets()\cust_free = FormWindows()\UndoActions()\ActionGadget()\cust_free
          
          ; For scrollarea only
          FormWindows()\FormGadgets()\scrollx = FormWindows()\UndoActions()\ActionGadget()\scrollx
          FormWindows()\FormGadgets()\scrolly = FormWindows()\UndoActions()\ActionGadget()\scrolly
          NextElement(FormWindows()\UndoActions()\ActionGadget())
        Next
      EndIf
      redraw = 1
      ;SelectGadget(FormWindows()\FormGadgets())
      FD_UpdateSplitter()
      FD_UpdateObjList()
    ElseIf ListSize(FormWindows()\UndoActions()\ActionTool1()) Or ListSize(FormWindows()\UndoActions()\ActionTool2())
      CopyList(FormWindows()\UndoActions()\ActionTool1(),FormWindows()\FormToolbars())
      FD_SelectWindow(FormWindows())
      redraw = 1
      
      
    ElseIf ListSize(FormWindows()\UndoActions()\ActionStatus1()) Or ListSize(FormWindows()\UndoActions()\ActionStatus2())
      CopyList(FormWindows()\UndoActions()\ActionStatus1(),FormWindows()\FormStatusbars())
      FD_SelectWindow(FormWindows())
      redraw = 1
      
      
    ElseIf ListSize(FormWindows()\UndoActions()\ActionMenu1()) Or ListSize(FormWindows()\UndoActions()\ActionMenu2())
      CopyList(FormWindows()\UndoActions()\ActionMenu1(),FormWindows()\FormMenus())
      FD_SelectWindow(FormWindows())
      redraw = 1
      
    ElseIf ListSize(FormWindows()\UndoActions()\ActionWindow())
      FirstElement(FormWindows()\UndoActions()\ActionWindow())
      
      FormWindows()\caption = FormWindows()\UndoActions()\ActionWindow()\caption
      FormWindows()\x = FormWindows()\UndoActions()\ActionWindow()\x
      FormWindows()\y = FormWindows()\UndoActions()\ActionWindow()\y
      FormWindows()\width = FormWindows()\UndoActions()\ActionWindow()\width
      FormWindows()\height = FormWindows()\UndoActions()\ActionWindow()\height
      FormWindows()\variable = FormWindows()\UndoActions()\ActionWindow()\variable
      FormWindows()\caption = FormWindows()\UndoActions()\ActionWindow()\caption
      FormWindows()\captionvariable = FormWindows()\UndoActions()\ActionWindow()\captionvariable
      FormWindows()\flags = FormWindows()\UndoActions()\ActionWindow()\flags
      FormWindows()\pbany = FormWindows()\UndoActions()\ActionWindow()\pbany
      FormWindows()\color = FormWindows()\UndoActions()\ActionWindow()\color
      FormWindows()\generateeventloop = FormWindows()\UndoActions()\ActionWindow()\generateeventloop
      FormWindows()\disabled = FormWindows()\UndoActions()\ActionWindow()\disabled
      FormWindows()\hidden = FormWindows()\UndoActions()\ActionWindow()\hidden
      
      FormWindows()\event_file = FormWindows()\UndoActions()\ActionWindow()\event_file
      FormWindows()\event_proc = FormWindows()\UndoActions()\ActionWindow()\event_proc
      redraw = 1
      FD_SelectWindow(FormWindows())
    EndIf
    FormWindows()\undo_pos - 1
  EndIf
  
  PopListPosition(FormWindows())
EndProcedure

Procedure FormRedo()
  PushListPosition(FormWindows())
  ChangeCurrentElement(FormWindows(),currentwindow)
  
  If FormWindows()\undo_pos < (ListSize(FormWindows()\UndoActions())-1) And ListSize(FormWindows()\UndoActions())
    FormWindows()\undo_pos + 1
    SelectElement(FormWindows()\UndoActions(), FormWindows()\undo_pos)
    
    If ListSize(FormWindows()\UndoActions()\ActionGadget())
      If FormWindows()\UndoActions()\type = #Undo_Delete
        ForEach FormWindows()\UndoActions()\ActionGadget()
          found = 0
          ForEach FormWindows()\FormGadgets()
            If FormWindows()\FormGadgets()\itemnumber = FormWindows()\UndoActions()\ActionGadget()\itemnumber
              found = 1
              Break
            EndIf
          Next
          If found
            DeleteElement(FormWindows()\FormGadgets())
          EndIf
        Next
        FD_UpdateObjList()
      Else
        If FormWindows()\UndoActions()\type = #Undo_Create
          FirstElement(FormWindows()\UndoActions()\ActionGadget())
          num = 0
          numend = ListSize(FormWindows()\UndoActions()\ActionGadget()) - 1
        Else
          num = ListSize(FormWindows()\UndoActions()\ActionGadget())/2
          numend = ListSize(FormWindows()\UndoActions()\ActionGadget())
          
          If num > 0
            SelectElement(FormWindows()\UndoActions()\ActionGadget(),num - 1)
          EndIf
        EndIf
        
        For i = num To numend
          If FormWindows()\UndoActions()\type = #Undo_Create
            If SelectElement(FormWindows()\FormGadgets(),FormWindows()\UndoActions()\ActionGadget()\gadgetpos)
              InsertElement(FormWindows()\FormGadgets())
            Else
              LastElement(FormWindows()\FormGadgets())
              AddElement(FormWindows()\FormGadgets())
            EndIf
          Else
            found = 0
            ForEach FormWindows()\FormGadgets()
              If FormWindows()\FormGadgets()\itemnumber = FormWindows()\UndoActions()\ActionGadget()\itemnumber
                found = 1
                Break
              EndIf
            Next
          EndIf
          
          CopyList(FormWindows()\UndoActions()\ActionGadget()\Items(),FormWindows()\FormGadgets()\Items())
          CopyList(FormWindows()\UndoActions()\ActionGadget()\Columns(),FormWindows()\FormGadgets()\Columns())
          
          FormWindows()\FormGadgets()\itemnumber = FormWindows()\UndoActions()\ActionGadget()\itemnumber
          FormWindows()\FormGadgets()\x1 = FormWindows()\UndoActions()\ActionGadget()\x1
          FormWindows()\FormGadgets()\x2 = FormWindows()\UndoActions()\ActionGadget()\x2
          FormWindows()\FormGadgets()\y1 = FormWindows()\UndoActions()\ActionGadget()\y1
          FormWindows()\FormGadgets()\y2 = FormWindows()\UndoActions()\ActionGadget()\y2
          
          FormWindows()\FormGadgets()\lock_left = FormWindows()\UndoActions()\ActionGadget()\lock_left
          FormWindows()\FormGadgets()\lock_right = FormWindows()\UndoActions()\ActionGadget()\lock_right
          FormWindows()\FormGadgets()\lock_top=  FormWindows()\UndoActions()\ActionGadget()\lock_top
          FormWindows()\FormGadgets()\lock_bottom = FormWindows()\UndoActions()\ActionGadget()\lock_bottom
          
          FormWindows()\FormGadgets()\caption = FormWindows()\UndoActions()\ActionGadget()\caption
          FormWindows()\FormGadgets()\captionvariable = FormWindows()\UndoActions()\ActionGadget()\captionvariable
          FormWindows()\FormGadgets()\variable = FormWindows()\UndoActions()\ActionGadget()\variable
          
          FormWindows()\FormGadgets()\flags = FormWindows()\UndoActions()\ActionGadget()\flags
          FormWindows()\FormGadgets()\type = FormWindows()\UndoActions()\ActionGadget()\type
          FormWindows()\FormGadgets()\min = FormWindows()\UndoActions()\ActionGadget()\min
          FormWindows()\FormGadgets()\max=  FormWindows()\UndoActions()\ActionGadget()\max
          
          FormWindows()\FormGadgets()\frontcolor = FormWindows()\UndoActions()\ActionGadget()\frontcolor
          FormWindows()\FormGadgets()\backcolor =FormWindows()\UndoActions()\ActionGadget()\backcolor
          FormWindows()\FormGadgets()\gadgetfont = FormWindows()\UndoActions()\ActionGadget()\gadgetfont
          FormWindows()\FormGadgets()\gadgetfontsize = FormWindows()\UndoActions()\ActionGadget()\gadgetfontsize
          FormWindows()\FormGadgets()\gadgetfontflags = FormWindows()\UndoActions()\ActionGadget()\gadgetfontflags
          
          FormWindows()\FormGadgets()\parent = FormWindows()\UndoActions()\ActionGadget()\parent
          FormWindows()\FormGadgets()\parent_item =FormWindows()\UndoActions()\ActionGadget()\parent_item
          
          ; splitter
          FormWindows()\FormGadgets()\gadget1 = FormWindows()\UndoActions()\ActionGadget()\gadget1
          FormWindows()\FormGadgets()\gadget2 = FormWindows()\UndoActions()\ActionGadget()\gadget2
          FormWindows()\FormGadgets()\splitter = FormWindows()\UndoActions()\ActionGadget()\splitter
          
          If FormWindows()\FormGadgets()\type = #Form_Type_Splitter
            PushListPosition(FormWindows()\FormGadgets())
            g_1 = FormWindows()\FormGadgets()\gadget1
            g_2 = FormWindows()\FormGadgets()\gadget2
            inumber = FormWindows()\FormGadgets()\itemnumber
            ForEach FormWindows()\FormGadgets()
              If FormWindows()\FormGadgets()\itemnumber = g_1
                FormWindows()\FormGadgets()\splitter = inumber
              EndIf
              If FormWindows()\FormGadgets()\itemnumber = g_2
                FormWindows()\FormGadgets()\splitter = inumber
              EndIf
            Next
            PopListPosition(FormWindows()\FormGadgets())
          EndIf
          
          FormWindows()\FormGadgets()\pbany = FormWindows()\UndoActions()\ActionGadget()\pbany
          FormWindows()\FormGadgets()\disabled = FormWindows()\UndoActions()\ActionGadget()\disabled
          FormWindows()\FormGadgets()\hidden = FormWindows()\UndoActions()\ActionGadget()\hidden
          FormWindows()\FormGadgets()\state = FormWindows()\UndoActions()\ActionGadget()\state
          
          ; events
          FormWindows()\FormGadgets()\event_proc = FormWindows()\UndoActions()\ActionGadget()\event_proc
          
          ; custom gadgets
          FormWindows()\FormGadgets()\cust_init = FormWindows()\UndoActions()\ActionGadget()\cust_init
          FormWindows()\FormGadgets()\cust_create = FormWindows()\UndoActions()\ActionGadget()\cust_create
          FormWindows()\FormGadgets()\cust_free = FormWindows()\UndoActions()\ActionGadget()\cust_free
          
          ; For scrollarea only
          FormWindows()\FormGadgets()\scrollx = FormWindows()\UndoActions()\ActionGadget()\scrollx
          FormWindows()\FormGadgets()\scrolly = FormWindows()\UndoActions()\ActionGadget()\scrolly
          NextElement(FormWindows()\UndoActions()\ActionGadget())
        Next
      EndIf
      
      If FormWindows()\UndoActions()\type = #Undo_Create Or FormWindows()\UndoActions()\type = #Undo_Delete
        FD_UpdateObjList()
      EndIf
      
      FD_UpdateSplitter()
      redraw = 1
      
    ElseIf ListSize(FormWindows()\UndoActions()\ActionTool2()) Or ListSize(FormWindows()\UndoActions()\ActionTool1())
      CopyList(FormWindows()\UndoActions()\ActionTool2(),FormWindows()\FormToolbars())
      FD_SelectWindow(FormWindows())
      redraw = 1
      
    ElseIf ListSize(FormWindows()\UndoActions()\ActionStatus1()) Or ListSize(FormWindows()\UndoActions()\ActionStatus2())
      CopyList(FormWindows()\UndoActions()\ActionStatus2(),FormWindows()\FormStatusbars())
      FD_SelectWindow(FormWindows())
      redraw = 1
      
      
    ElseIf ListSize(FormWindows()\UndoActions()\ActionMenu1()) Or ListSize(FormWindows()\UndoActions()\ActionMenu2())
      CopyList(FormWindows()\UndoActions()\ActionMenu2(),FormWindows()\FormMenus())
      FD_SelectWindow(FormWindows())
      redraw = 1
      
    ElseIf ListSize(FormWindows()\UndoActions()\ActionWindow())
      LastElement(FormWindows()\UndoActions()\ActionWindow())
      FormWindows()\caption = FormWindows()\UndoActions()\ActionWindow()\caption
      FormWindows()\x = FormWindows()\UndoActions()\ActionWindow()\x
      FormWindows()\y = FormWindows()\UndoActions()\ActionWindow()\y
      FormWindows()\width = FormWindows()\UndoActions()\ActionWindow()\width
      FormWindows()\height = FormWindows()\UndoActions()\ActionWindow()\height
      FormWindows()\variable = FormWindows()\UndoActions()\ActionWindow()\variable
      FormWindows()\caption = FormWindows()\UndoActions()\ActionWindow()\caption
      FormWindows()\captionvariable = FormWindows()\UndoActions()\ActionWindow()\captionvariable
      FormWindows()\flags = FormWindows()\UndoActions()\ActionWindow()\flags
      FormWindows()\pbany = FormWindows()\UndoActions()\ActionWindow()\pbany
      FormWindows()\color = FormWindows()\UndoActions()\ActionWindow()\color
      FormWindows()\generateeventloop = FormWindows()\UndoActions()\ActionWindow()\generateeventloop
      FormWindows()\disabled = FormWindows()\UndoActions()\ActionWindow()\disabled
      FormWindows()\hidden = FormWindows()\UndoActions()\ActionWindow()\hidden
      
      FormWindows()\event_file = FormWindows()\UndoActions()\ActionWindow()\event_file
      FormWindows()\event_proc = FormWindows()\UndoActions()\ActionWindow()\event_proc
      redraw = 1
      FD_SelectWindow(FormWindows())
    EndIf
  EndIf
  
  PopListPosition(FormWindows())
EndProcedure

Procedure FormAddUndoAction(addaction, window, gadget = -1, type = 0, pos = 0, toolbar = -1, statusbar = -1, menubar = -1)
  PushListPosition(FormWindows())
  ChangeCurrentElement(FormWindows(),window)
  
  ; if something has been undone, then delete these actions before adding a new one
  max = ListSize(FormWindows()\UndoActions()) - 1
  If FormWindows()\undo_pos < max
    element = FormWindows()\undo_pos + 1
    For i = element To max
      If SelectElement(FormWindows()\UndoActions(),element)
        DeleteElement(FormWindows()\UndoActions())
      EndIf
    Next
  EndIf
  
  max = ListSize(FormWindows()\UndoActions())
  
  If max > maxundolevel
    numtodelete = max - maxundolevel
    
    For i = 1 To numtodelete
      FirstElement(FormWindows()\UndoActions())
      DeleteElement(FormWindows()\UndoActions())
    Next
  EndIf
  
  If addaction
    LastElement(FormWindows()\UndoActions())
    AddElement(FormWindows()\UndoActions())
    FormWindows()\UndoActions()\type = type
  Else
    LastElement(FormWindows()\UndoActions())
  EndIf
  
  If gadget > 0
    If pos = 0
      If ListSize(FormWindows()\UndoActions()\ActionGadget())
        LastElement(FormWindows()\UndoActions()\ActionGadget())
      EndIf
    Else
      num = ListSize(FormWindows()\UndoActions()\ActionGadget())/2 - 1
      If num > -1
        SelectElement(FormWindows()\UndoActions()\ActionGadget(),num)
      Else
        If ListSize(FormWindows()\UndoActions()\ActionGadget())
          LastElement(FormWindows()\UndoActions()\ActionGadget())
        EndIf
      EndIf
    EndIf
    
    ChangeCurrentElement(FormWindows()\FormGadgets(),gadget)
    AddElement(FormWindows()\UndoActions()\ActionGadget())
    CopyList(FormWindows()\FormGadgets()\Items(),FormWindows()\UndoActions()\ActionGadget()\Items())
    CopyList(FormWindows()\FormGadgets()\Columns(),FormWindows()\UndoActions()\ActionGadget()\Columns())
    FormWindows()\UndoActions()\ActionGadget()\gadgetid = FormWindows()\FormGadgets()
    FormWindows()\UndoActions()\ActionGadget()\gadgetpos = ListIndex(FormWindows()\FormGadgets())
    
    FormWindows()\UndoActions()\ActionGadget()\itemnumber = FormWindows()\FormGadgets()\itemnumber
    
    FormWindows()\UndoActions()\ActionGadget()\x1 = FormWindows()\FormGadgets()\x1
    FormWindows()\UndoActions()\ActionGadget()\x2 = FormWindows()\FormGadgets()\x2
    FormWindows()\UndoActions()\ActionGadget()\y1 = FormWindows()\FormGadgets()\y1
    FormWindows()\UndoActions()\ActionGadget()\y2 = FormWindows()\FormGadgets()\y2
    
    FormWindows()\UndoActions()\ActionGadget()\lock_left = FormWindows()\FormGadgets()\lock_left
    FormWindows()\UndoActions()\ActionGadget()\lock_right = FormWindows()\FormGadgets()\lock_right
    FormWindows()\UndoActions()\ActionGadget()\lock_top=  FormWindows()\FormGadgets()\lock_top
    FormWindows()\UndoActions()\ActionGadget()\lock_bottom = FormWindows()\FormGadgets()\lock_bottom
    
    FormWindows()\UndoActions()\ActionGadget()\caption = FormWindows()\FormGadgets()\caption
    FormWindows()\UndoActions()\ActionGadget()\captionvariable = FormWindows()\FormGadgets()\captionvariable
    FormWindows()\UndoActions()\ActionGadget()\variable = FormWindows()\FormGadgets()\variable
    
    FormWindows()\UndoActions()\ActionGadget()\flags = FormWindows()\FormGadgets()\flags
    FormWindows()\UndoActions()\ActionGadget()\type = FormWindows()\FormGadgets()\type
    FormWindows()\UndoActions()\ActionGadget()\min = FormWindows()\FormGadgets()\min
    FormWindows()\UndoActions()\ActionGadget()\max=  FormWindows()\FormGadgets()\max
    
    FormWindows()\UndoActions()\ActionGadget()\frontcolor = FormWindows()\FormGadgets()\frontcolor
    FormWindows()\UndoActions()\ActionGadget()\backcolor =FormWindows()\FormGadgets()\backcolor
    FormWindows()\UndoActions()\ActionGadget()\gadgetfont = FormWindows()\FormGadgets()\gadgetfont
    FormWindows()\UndoActions()\ActionGadget()\gadgetfontsize = FormWindows()\FormGadgets()\gadgetfontsize
    FormWindows()\UndoActions()\ActionGadget()\gadgetfontflags = FormWindows()\FormGadgets()\gadgetfontflags
    
    FormWindows()\UndoActions()\ActionGadget()\parent = FormWindows()\FormGadgets()\parent
    FormWindows()\UndoActions()\ActionGadget()\parent_item =FormWindows()\FormGadgets()\parent_item
    
    ; splitter
    FormWindows()\UndoActions()\ActionGadget()\gadget1 = FormWindows()\FormGadgets()\gadget1
    FormWindows()\UndoActions()\ActionGadget()\gadget2 = FormWindows()\FormGadgets()\gadget2
    FormWindows()\UndoActions()\ActionGadget()\splitter = FormWindows()\FormGadgets()\splitter
    
    FormWindows()\UndoActions()\ActionGadget()\pbany = FormWindows()\FormGadgets()\pbany
    FormWindows()\UndoActions()\ActionGadget()\disabled = FormWindows()\FormGadgets()\disabled
    FormWindows()\UndoActions()\ActionGadget()\hidden = FormWindows()\FormGadgets()\hidden
    FormWindows()\UndoActions()\ActionGadget()\state = FormWindows()\FormGadgets()\state
    
    ; events
    FormWindows()\UndoActions()\ActionGadget()\event_proc = FormWindows()\FormGadgets()\event_proc
    
    ; custom gadgets
    FormWindows()\UndoActions()\ActionGadget()\cust_init = FormWindows()\FormGadgets()\cust_init
    FormWindows()\UndoActions()\ActionGadget()\cust_create = FormWindows()\FormGadgets()\cust_create
    FormWindows()\UndoActions()\ActionGadget()\cust_free = FormWindows()\FormGadgets()\cust_free
    
    ; For scrollarea only
    FormWindows()\UndoActions()\ActionGadget()\scrollx = FormWindows()\FormGadgets()\scrollx
    FormWindows()\UndoActions()\ActionGadget()\scrolly = FormWindows()\FormGadgets()\scrolly
    
  ElseIf toolbar > 0 ; toolbar mod
    If pos = 0
      CopyList(FormWindows()\FormToolbars(),FormWindows()\UndoActions()\ActionTool1())
    Else
      CopyList(FormWindows()\FormToolbars(),FormWindows()\UndoActions()\ActionTool2())
    EndIf
    
  ElseIf statusbar > 0 ; statusbar mod
    If pos = 0
      CopyList(FormWindows()\FormStatusbars(),FormWindows()\UndoActions()\ActionStatus1())
    Else
      CopyList(FormWindows()\FormStatusbars(),FormWindows()\UndoActions()\ActionStatus2())
    EndIf
    
  ElseIf menubar > 0 ; menubar mod
    If pos = 0
      CopyList(FormWindows()\FormMenus(),FormWindows()\UndoActions()\ActionMenu1())
    Else
      CopyList(FormWindows()\FormMenus(),FormWindows()\UndoActions()\ActionMenu2())
    EndIf
    
  Else ; window mod
    If ListSize(FormWindows()\UndoActions()\ActionWindow())
      LastElement(FormWindows()\UndoActions()\ActionWindow())
    EndIf
    
    AddElement(FormWindows()\UndoActions()\ActionWindow())
    FormWindows()\UndoActions()\ActionWindow()\caption = FormWindows()\caption
    FormWindows()\UndoActions()\ActionWindow()\x = FormWindows()\x
    FormWindows()\UndoActions()\ActionWindow()\y = FormWindows()\y
    FormWindows()\UndoActions()\ActionWindow()\width = FormWindows()\width
    FormWindows()\UndoActions()\ActionWindow()\height = FormWindows()\height
    FormWindows()\UndoActions()\ActionWindow()\variable = FormWindows()\variable
    FormWindows()\UndoActions()\ActionWindow()\caption = FormWindows()\caption
    FormWindows()\UndoActions()\ActionWindow()\captionvariable = FormWindows()\captionvariable
    FormWindows()\UndoActions()\ActionWindow()\flags = FormWindows()\flags
    FormWindows()\UndoActions()\ActionWindow()\pbany = FormWindows()\pbany
    FormWindows()\UndoActions()\ActionWindow()\color = FormWindows()\color
    FormWindows()\UndoActions()\ActionWindow()\generateeventloop = FormWindows()\generateeventloop
    FormWindows()\UndoActions()\ActionWindow()\disabled = FormWindows()\disabled
    FormWindows()\UndoActions()\ActionWindow()\hidden = FormWindows()\hidden
    
    FormWindows()\UndoActions()\ActionWindow()\event_file = FormWindows()\event_file
    FormWindows()\UndoActions()\ActionWindow()\event_proc = FormWindows()\event_proc
  EndIf
  
  FormWindows()\undo_pos = ListSize(FormWindows()\UndoActions()) - 1
  PopListPosition(FormWindows())
EndProcedure


