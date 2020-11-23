;
; ------------------------------------------------------------
;
;   PureBasic - Gadget 3D
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

Define.f KeyX, KeyY, MouseX, MouseY

Enumeration ; Window3D
  #MainWindow
  #SecondWindow
EndEnumeration


Enumeration ; Gadget3D
  #ActiveWindowLabel
  #CloseButton
  #ProgressBar
  #ComboBox
  #Panel
  #ListView
  #Image
  #Image2
  #ScrollArea
  #ScrollBar
  #String
  #Spin
  #Container
  #CheckBox
  #Editor
  #Option1
  #Option2
  #Option3
  #Button
EndEnumeration

If InitEngine3D()

  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/GUI", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
    
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
    
    SkyBox("desert07.jpg")
		
		CreateCamera(0, 0, 0, 100, 100)  ; Front camera
    MoveCamera(0, 0, 0, 100, #PB_Absolute)
    
    OpenWindow3D(#MainWindow, 50, 20, 280, 400, "Hello in 3D !", #PB_Window3D_SizeGadget)
		
    Top = 10
    TextGadget3D(#ActiveWindowLabel, 10, Top, 250, 25, "Active window: ") : Top + 30
    
    ;- ProgressBar
    TextGadget3D(#PB_Any, 10, Top, 100, 25, "Progress bar: ")
    ProgressBarGadget3D(#ProgressBar, 110, Top, 150, 25, 0, 100) : Top + 30
    SetGadgetState3D(#ProgressBar, 30)
    GadgetToolTip3D(#ProgressBar, "I'm a progress bar")
    
    ;- ComboBox
    TextGadget3D(#PB_Any, 10, Top, 100, 25, "Combo box: ")
    ComboBoxGadget3D(#ComboBox, 110, Top, 150, 25) : Top + 30
    GadgetToolTip3D(#ComboBox, "Combobox tooltip !")
    AddGadgetItem3D(#ComboBox, -1, "Item 1")
    AddGadgetItem3D(#ComboBox, -1, "Item 2")
    AddGadgetItem3D(#ComboBox, -1, "Item 3")
    AddGadgetItem3D(#ComboBox, -1, "Item 4")
    
     ;- ScrollBar
    TextGadget3D(#PB_Any, 10, Top, 100, 25, "Scroll bar: ")
    ScrollBarGadget3D(#ScrollBar, 110, Top+7, 150, 10, 0, 100, 20) : Top + 30
    SetGadgetState3D(#ScrollBar, 30)
        
    ;- String
    TextGadget3D(#PB_Any, 10, Top, 100, 25, "String: ")
    StringGadget3D(#String, 110, Top, 150, 25, "Modify me") : Top + 30
    GadgetToolTip3D(#String, "I'm a string gadget")
    
    ;- CheckBox
    TextGadget3D(#PB_Any, 10, Top, 100, 25, "Check box: ")
    CheckBoxGadget3D(#CheckBox, 110, Top, 150, 25, "Enable something") : Top + 30
    GadgetToolTip3D(#CheckBox, "I'm a checkbox !")
    SetGadgetState3D(#CheckBox, 1)
    
    ;- Spinner
    TextGadget3D(#PB_Any, 10, Top, 100, 25, "Spinner: ")
    SpinGadget3D(#Spin, 110, Top, 150, 25, 0, 100) : Top + 30
    GadgetToolTip3D(#Spin, "I'm a spinner !")
    
    ;- Options
    TextGadget3D(#PB_Any, 10, Top, 100, 25, "Options: ")
    OptionGadget3D(#Option1, 110, Top, 150, 25, "Choice 1") : Top + 30
    OptionGadget3D(#Option2, 110, Top, 150, 25, "Choice 2") : Top + 30
    OptionGadget3D(#Option3, 110, Top, 150, 25, "Choice 3") : Top + 30
    GadgetToolTip3D(#Option1, "I'm option 1 !")
    SetGadgetState3D(#Option2, 1)
    
    ;- Button
    TextGadget3D(#PB_Any, 10, Top, 100, 25, "Button: ")
    ButtonGadget3D(#Button, 110, Top, 150, 25, "Click me !") : Top + 30
    GadgetToolTip3D(#Button, "I'm a button !")
        
    
    OpenWindow3D(#SecondWindow, 400, 150, 400, 400, "More gadgets", #PB_Window3D_SizeGadget)
    
    PanelGadget3D(#Panel, 10, 10, 370, 350)
      GadgetToolTip3D(#Panel, "Panel tooltip !")
      AddGadgetItem3D(#Panel, -1, "First")
        ListViewGadget3D(#ListView, 10, 10, 200, 200, #PB_ListView3D_Multiselect) 
          For k = 0 To 20
            AddGadgetItem3D(#ListView, -1, "Item "+Str(k))
          Next
          
      AddGadgetItem3D(#Panel, -1, "Second")
        ContainerGadget3D(#Container, 0, 0, 400, 400)
          GadgetToolTip3D(#Container, "Container tooltip !")
      
          LoadTexture(0, "clouds.jpg")
          ImageGadget3D(#Image, 10, 10, 128, 128, TextureID(0))
      
          ScrollAreaGadget3D(#ScrollArea, 10, 150, 100, 100, 256, 256, 30)
          GadgetToolTip3D(#ScrollArea, "Scroll area tooltip !")
            ImageGadget3D(#Image2, 10, 10, 256, 256, TextureID(0))
          CloseGadgetList3D()
        
        CloseGadgetList3D()
    
      AddGadgetItem3D(#Panel, -1, "Third")
        EditorGadget3D(#Editor, 10, 10, 300, 200)
        SetGadgetText3D(#Editor, "Multi" + #LF$ + "Line" + #LF$ + "Editor !")
      
    CloseGadgetList3D()
    
    Repeat
      Screen3DEvents()
      
      If ExamineKeyboard() And ExamineMouse()
        Input$ = KeyboardInkey()
        
        SpecialKey = 0
        If     KeyboardPushed(#PB_Key_Back)   :  SpecialKey = #PB_Key_Back
        ElseIf KeyboardPushed(#PB_Key_Return) : SpecialKey = #PB_Key_Return
        ElseIf KeyboardPushed(#PB_Key_Left)   : SpecialKey = #PB_Key_Left
        ElseIf KeyboardPushed(#PB_Key_Right)  : SpecialKey = #PB_Key_Right
        ElseIf KeyboardPushed(#PB_Key_Up)     : SpecialKey = #PB_Key_Up
        ElseIf KeyboardPushed(#PB_Key_Down)   : SpecialKey = #PB_Key_Down
        ElseIf KeyboardPushed(#PB_Key_Delete) : SpecialKey = #PB_Key_Delete
        EndIf
        
        InputEvent3D(MouseX(), MouseY(), MouseButton(#PB_MouseButton_Left), Input$, SpecialKey)
      EndIf
      
      ; Handle the GUI 3D events, it's similar to regular GUI events
      ;
      Repeat
      	Event = WindowEvent3D()
      	
      	SetGadgetText3D(#ActiveWindowLabel, "Active #Window3D: "+Str(GetActiveWindow3D()))
      	
      	Select Event
      		Case #PB_Event3D_Gadget
      		  If EventGadget3D() = #CloseButton
      		    CloseWindow3D(#MainWindow)
      		  EndIf
      			
      	EndSelect
      Until Event = 0
      
      RenderWorld()
      
      FlipBuffers()
    Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
  EndIf
    
Else
  MessageRequester("Error", "The 3D Engine can't be initialized",0)
EndIf
