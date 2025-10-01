;
; ------------------------------------------------------------
;
;   PureBasic - Drag & Drop
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#Window = 0

Enumeration    ; Images
  #ImageSource
  #ImageTarget
EndEnumeration

Enumeration    ; Gadgets
  #SourceText
  #SourceImage
  #SourceFiles
  #SourcePrivate
  #TargetText
  #TargetImage
  #TargetFiles
  #TargetPrivate1
  #TargetPrivate2
EndEnumeration

; #PB_EventType_DragStart event must be handled in a binded callback on MacOS
;
Procedure DragStartEvent()
  If EventType() = #PB_EventType_DragStart

    ExamineDraggedItems()
        
    Select EventGadget()
        
      Case #SourceText
        If NextDraggedItem()
          Text$ = GetGadgetItemText(#SourceText, DraggedItemIndex())
          DragText(Text$)
        EndIf
        
      Case #SourceImage
        DragImage(ImageID(#ImageSource))
        
      Case #SourceFiles
        Files$ = ""
        While NextDraggedItem()
          Files$ + GetGadgetText(#SourceFiles) + GetGadgetItemText(#SourceFiles, DraggedItemIndex()) + Chr(10)
        Wend
        DragFiles(Files$)
        
        ; "Private" Drags only work within the program, everything else
        ; also works with other applications (Explorer, Word, etc)
        ;
      Case #SourcePrivate
        If NextDraggedItem()
          If DraggedItemIndex() = 0
            DragPrivate(1)
          Else
            DragPrivate(2)
          EndIf
        EndIf
        
    EndSelect
    
    ; Drop event on the target gadgets, receive the dropped data
    ;
  EndIf
EndProcedure


If OpenWindow(#Window, 0, 0, 760, 310, "Drag & Drop", #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
  
  ; Create some images for the image demonstration
  ;
  CreateImage(#ImageSource, DesktopScaledX(136), DesktopScaledY(136))
  If StartDrawing(ImageOutput(#ImageSource))
    Box(0, 0, ImageWidth(0), ImageHeight(0), $FFFFFF)
    DrawingMode(#PB_2DDrawing_NativeText)
    DrawText(5, 5, "Drag this image", $000000, $FFFFFF)
    For i = DesktopScaledX(45) To 1 Step -1
      Circle(DesktopScaledX(70), DesktopScaledY(80), i, Random($FFFFFF))
    Next i
    
    StopDrawing()
  EndIf
  
  CreateImage(#ImageTarget, DesktopScaledX(136), DesktopScaledY(136))
  If StartDrawing(ImageOutput(#ImageTarget))
    Box(0, 0, ImageWidth(0), ImageHeight(0), $FFFFFF)
    DrawingMode(#PB_2DDrawing_NativeText)
    DrawText(5, 5, "Drop images here", $000000, $FFFFFF)
    StopDrawing()
  EndIf
  
  
  ; Create and fill the source gadgets
  ;
  ListIconGadget(#SourceText,       10, 10, 140, 140, "Drag Text here", 130)
  ImageGadget(#SourceImage,        160, 10, 140, 140, ImageID(#ImageSource), #PB_Image_Border)
  ExplorerListGadget(#SourceFiles, 310, 10, 290, 140, GetHomeDirectory(), #PB_Explorer_MultiSelect)
  ListIconGadget(#SourcePrivate,   610, 10, 140, 140, "Drag private stuff here", 260)

  AddGadgetItem(#SourceText, -1, "hello world")
  AddGadgetItem(#SourceText, -1, "The quick brown fox jumped over the lazy dog")
  AddGadgetItem(#SourceText, -1, "abcdefg")
  AddGadgetItem(#SourceText, -1, "123456789")
  
  AddGadgetItem(#SourcePrivate, -1, "Private type 1")
  AddGadgetItem(#SourcePrivate, -1, "Private type 2")
  
  
  ; Create the target gadgets
  ;
  ListIconGadget(#TargetText,  10, 160, 140, 140, "Drop Text here", 130)
  ImageGadget(#TargetImage,    160, 160, 140, 140, ImageID(#ImageTarget), #PB_Image_Border)
  ListIconGadget(#TargetFiles, 310, 160, 140, 140, "Drop Files here", 130)
  ListIconGadget(#TargetPrivate1, 460, 160, 140, 140, "Drop Private Type 1 here", 130)
  ListIconGadget(#TargetPrivate2, 610, 160, 140, 140, "Drop Private Type 2 here", 130)
  
  
  ; Now enable the dropping on the target gadgets
  ;
  EnableGadgetDrop(#TargetText,     #PB_Drop_Text,    #PB_Drag_Copy)
  EnableGadgetDrop(#TargetImage,    #PB_Drop_Image,   #PB_Drag_Copy)
  EnableGadgetDrop(#TargetFiles,    #PB_Drop_Files,   #PB_Drag_Copy)
  EnableGadgetDrop(#TargetPrivate1, #PB_Drop_Private, #PB_Drag_Link, 1)
  EnableGadgetDrop(#TargetPrivate2, #PB_Drop_Private, #PB_Drag_Copy | #PB_Drag_Link | #PB_Drag_Move, 2)
  
  ; Binding for #PB_EventType_DragStart
  BindEvent(#PB_Event_Gadget, @DragStartEvent())
  
  Repeat
    Event = WaitWindowEvent()
    
    If Event = #PB_Event_GadgetDrop
      Select EventGadget()
          
        Case #TargetText
          AddGadgetItem(#TargetText, -1, EventDropText())
          
        Case #TargetImage
          If EventDropImage(#ImageTarget)
            SetGadgetState(#TargetImage, ImageID(#ImageTarget))
          EndIf
          
        Case #TargetFiles
          Files$ = EventDropFiles()
          Count  = CountString(Files$, Chr(10)) + 1
          For i = 1 To Count
            AddGadgetItem(#TargetFiles, -1, StringField(Files$, i, Chr(10)))
          Next i
          
        Case #TargetPrivate1
          AddGadgetItem(#TargetPrivate1, -1, "Private type 1 dropped")
          
        Case #TargetPrivate2
          AddGadgetItem(#TargetPrivate2, -1, "Private type 2 dropped")
          
      EndSelect
      
    EndIf
    
  Until Event = #PB_Event_CloseWindow
EndIf

End