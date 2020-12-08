;
; ------------------------------------------------------------
;
;   PureBasic - Window 3D
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;
  
#MainWindow = 0
#CloseButton = 0

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

Define.f KeyX, KeyY, MouseX, MouseY

If InitEngine3D()
  
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/GUI", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)

    
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
    
    SkyBox("desert07.jpg")

    CreateCamera(0, 0, 0, 100, 100)  ; Front camera
    MoveCamera(0,0,100,100, #PB_Absolute)
    
    
    OpenWindow3D(#MainWindow, 100, 100, 300, 100, "Hello in 3D !")
		
			ButtonGadget3D(#CloseButton, 150, 40, 120, 25, "Quit")
			
  	ShowGUI(128, 1) ; Display the GUI, semi-transparent and display the mouse cursor
    		
    Repeat
      Screen3DEvents()

      If ExamineKeyboard() And ExamineMouse()
        Input$ = KeyboardInkey()
        
        InputEvent3D(MouseX(), MouseY(), MouseButton(#PB_MouseButton_Left), Input$, 0)
      EndIf
      
      ; Handle the GUI 3D events, it's similar to regular GUI events
      ;
      Repeat
      	Event = WindowEvent3D()
      	
      	Select Event
      		Case #PB_Event3D_CloseWindow
      		  If EventWindow3D() = #MainWindow
      		    CloseWindow3D(#MainWindow)
      		  EndIf
      		  
      		Case #PB_Event3D_Gadget
      		  If EventGadget3D() = #CloseButton
      		    Quit = 1
      		  EndIf
      			
      	EndSelect
     	Until Event = 0
     	
      RenderWorld()
      
      FlipBuffers()
    Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
  EndIf
    
Else
  MessageRequester("Error", "The 3D Engine can't be initialized", 0)
EndIf