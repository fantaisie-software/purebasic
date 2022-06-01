;
; ------------------------------------------------------------
;
;   PureBasic - MDI example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

; As MDIGadget is a Windows only gadget, it won't run on Linux or OS X
;
CompilerIf #PB_Compiler_OS <> #PB_OS_Windows
  CompilerError "MDIGadget() is only supported on Windows"
CompilerEndIf


Structure MDIWindow
  ; info about the loaded image
  Image.i
  ImageWidth.l
  ImageHeight.l
  ImageGifAnimated.l
  
  ; Our MDI Window
  Window.i
  
  ; gadget numbers
  ScrollAreaGadget.i
  ImageGadget.i
EndStructure

Global NewList MDIWindow.MDIWindow()

#WINDOW = 0
#TOOLBAR = 0
#MENU = 0

;#MDI_Base = 1
#GADGET_MDI = 0

Enumeration
  #MENU_Open
  #MENU_Close
  #MENU_CloseAll
  #MENU_Quit
  
  #MENU_TileVertically
  #MENU_TileHorizontally
  #MENU_Cascade
  #MENU_Arrange
  #MENU_Previous
  #MENU_Next
  
  #MENU_FirstMDI
EndEnumeration

UseGIFImageDecoder()
UseJPEGImageDecoder()
UsePNGImageDecoder()
UseTGAImageDecoder()
UseTIFFImageDecoder()


Procedure SelectMDIWindow(Window)
  
  ForEach MDIWindow()
    If MDIWindow()\Window = Window
      ProcedureReturn 1
    EndIf
  Next
  
EndProcedure



#WindowFlags = #PB_Window_ScreenCentered|#PB_Window_SystemMenu|#PB_Window_MinimizeGadget|#PB_Window_MaximizeGadget|#PB_Window_SizeGadget

If OpenWindow(#WINDOW, 0, 0, 800, 600, "MDI ImageViewer", #WindowFlags)
  If CreateMenu(#MENU, WindowID(#WINDOW))
    MenuTitle("File")
    MenuItem(#MENU_Open, "Open")
    MenuItem(#MENU_Close, "Close")
    MenuItem(#MENU_CloseAll, "Close All")
    MenuBar()
    MenuItem(#MENU_QUit, "Quit")
    MenuTitle("Windows")
    MenuItem(#MENU_TileVertically, "Tile vertically")
    MenuItem(#MENU_TileHorizontally, "Tile horizontally")
    MenuItem(#MENU_Cascade, "Cascade")
    MenuItem(#MENU_Previous, "Previous")
    MenuItem(#MENU_Next, "Next")
    
    ; MDI subwindows will get added here
  EndIf
  
  If CreateToolBar(#TOOLBAR, WindowID(#WINDOW))
    ToolBarImageButton(#MENU_Open, LoadImage(0, #PB_Compiler_Home + "examples/sources/Data/ToolBar/Open.png"))
    ToolBarImageButton(#MENU_Close, LoadImage(0, #PB_Compiler_Home + "examples/sources/Data/ToolBar/Delete.png"))
    ToolBarSeparator()
    ToolBarImageButton(#MENU_Previous, LoadImage(0, #PB_Compiler_Home + "examples/sources/Data/ToolBar/Undo.png"))
    ToolBarImageButton(#MENU_Next, LoadImage(0, #PB_Compiler_Home + "examples/sources/Data/ToolBar/Redo.png"))
  EndIf
  
  MDIGadget(#GADGET_MDI, 0, 0, 0, 0, 1, #MENU_FirstMDI, #PB_MDI_AutoSize)
  
  
  Quit = 0
  Repeat
    Event = WaitWindowEvent()
    Window = EventWindow()
    
    Select Event
      Case #PB_Event_CloseWindow
        
        
        If Window = #WINDOW ; Out main window is closed, just quit
          Quit = 1
          
        Else ; It's one of our MDI children
          
          If SelectMDIWindow(Window) ; Check if it's one of our MDI window
            RemoveWindowTimer(MDIWindow()\Window,MDIWindow()\Window)
            CloseWindow(Window)
            FreeImage(MDIWindow()\Image)
            DeleteElement(MDIWindow())
          EndIf
          
        EndIf
        
      Case #PB_Event_ActivateWindow
        
        Window = EventWindow()
        
        If SelectMDIWindow(Window) ; Check if it's one of our MDI window
          If MDIWindow()\ImageGifAnimated = #True
            
            IsGif=#True
          Else
            IsGif=#False
          EndIf
        EndIf
        
      Case #PB_Event_Timer ; Let's animate a Gif
        IsGif=#True
        If IsGif=#True And EventTimer() = MDIWindow()\Window; And ImageFrameCount(MDIWindow()\Image) <> 1
          
          
          SetImageFrame(MDIWindow()\Image, Frame)
          RemoveWindowTimer(MDIWindow()\Window, MDIWindow()\Window)
          AddWindowTimer(MDIWindow()\Window, MDIWindow()\Window, GetImageFrameDelay(MDIWindow()\Image))
          
          Frame+1
          If Frame >= ImageFrameCount(MDIWindow()\Image) : Frame = 0 : EndIf
          SetGadgetState(MDIWindow()\ImageGadget, ImageID(MDIWindow()\Image))
        EndIf
        
        
      Case #PB_Event_Menu
        Select EventMenu()
          Case #MENU_Open
            FileName$ = OpenFileRequester("Open Image", DefautFile$, "Image Files (*.bmp,*.jpg,*.tiff,*.png,*.tga,*.gif)|*.bmp;*.jpg;*.tiff;*.png;*.tga;*.gif|All Files (*.*)|*.*", 0, #PB_Requester_MultiSelection)
            While FileName$
              DefaultFile$ = FileName$
              
              Image = LoadImage(#PB_Any, FileName$)
              If Image
                
                LastElement(MDIWindow())
                AddElement(MDIWindow())
                
                Item = ListIndex(MDIWindow())
                
                MDIWindow()\Image       = Image
                MDIWIndow()\ImageWidth  = ImageWidth(Image)
                MDIWindow()\ImageHeight = ImageHeight(Image)
                
                
                
                MDIWindow()\Window = AddGadgetItem(#GADGET_MDI, -1, FileName$)
                
                Width  = WindowWidth (MDIWindow()\Window)
                Height = WindowHeight(MDIWindow()\Window)
                
                MDIWindow()\ScrollAreaGadget = ScrollAreaGadget(#PB_Any, 0, 0, Width, Height, MDIWindow()\ImageWidth, MDIWindow()\ImageHeight, 10)
                MDIWindow()\ImageGadget = ImageGadget(#PB_Any, 0, 0, MDIWindow()\ImageWidth, MDIWindow()\ImageHeight, ImageID(Image))
                If UCase(GetExtensionPart(Filename$)) = "GIF"  And ImageFrameCount(MDIWindow()\Image) <> 1
                  MDIWindow()\ImageGifAnimated = #True
                  AddWindowTimer(MDIWindow()\Window, MDIWindow()\Window, 1)
                EndIf
                CloseGadgetList()
                
              Else
                MessageRequester("Image Viewer","Could not load image: "+FileName$)
              EndIf
              
              FileName$ = NextSelectedFileName()
            Wend
            
          Case #MENU_Close
            Window = GetGadgetState(#GADGET_MDI)
            If Window <> -1
              SelectMDIWindow(Window)
              RemoveWindowTimer(MDIWindow()\Window, MDIWindow()\Window)
              CloseWindow(Window)
              FreeImage(MDIWindow()\Image)
              DeleteElement(MDIWindow())
            EndIf
            
          Case #MENU_CloseAll
            
            ForEach MDIWindow()
              RemoveWindowTimer(MDIWindow()\Window, MDIWindow()\Window)
              CloseWindow(MDIWindow()\Window)
              FreeImage(MDIWindow()\Image)
            Next
            ClearList(MDIWindow())
            
          Case #MENU_Quit
            Quit = 1
            
          Case #MENU_TileVertically
            SetGadgetState(#GADGET_MDI, #PB_MDI_TileVertically)
            
          Case #MENU_TileHorizontally
            SetGadgetState(#GADGET_MDI, #PB_MDI_TileHorizontally)
            
          Case #MENU_Cascade
            SetGadgetState(#GADGET_MDI, #PB_MDI_Cascade)
            
          Case #MENU_Arrange
            SetGadgetState(#GADGET_MDI, #PB_MDI_Arrange)
            
          Case #MENU_Previous
            SetGadgetState(#GADGET_MDI, #PB_MDI_Previous)
            
          Case #MENU_Next
            SetGadgetState(#GADGET_MDI, #PB_MDI_Next)
            
        EndSelect
        
        
      Case #PB_Event_SizeWindow
        
        Window = EventWindow()
        
        If SelectMDIWindow(Window)
          ResizeGadget(MDIWindow()\ScrollAreaGadget, 0, 0, WindowWidth(Window), WindowHeight(Window))
        EndIf
        
    EndSelect
    
  Until Quit = 1
EndIf
