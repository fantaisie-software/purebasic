;
; ------------------------------------------------------------
;
;   PureBasic - ResizeCamera
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#CameraSpeed = 1

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

Define.f KeyX, KeyY, MouseX, MouseY
Define.f x=25,y=0,s=1,ps=0.2,px=0.2,py=0.2

If InitEngine3D()

  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
    
    AmbientColor(RGB(200, 200, 200))  
 
    CreateMaterial(0, LoadTexture(0, "r2skin.jpg"))
    CreateEntity(0, LoadMesh(0, "robot.mesh"), MaterialID(0))
    StartEntityAnimation(0, "Walk")
    
    CreateCamera(0, 0, 0, 100, 100)  ; Front camera
    MoveCamera(0, 0, 20, 250, #PB_Absolute)
    CameraBackColor(0, RGB(55, 0, 0))
    
    CreateCamera(1, x, y, s, s) ; Back camera
    MoveCamera(1, 0, 50, 200, #PB_Absolute)
    CameraBackColor(1, RGB(0, 0, 50))

    
    CameraRenderMode(1, #PB_Camera_Wireframe)  ; Wireframe for this camera
  
    Repeat
      Screen3DEvents()
      ExamineKeyboard()
     
      RotateEntity(0, 0, 0.3, 0, #PB_Relative)
      
      x + px
      If x<=0  Or x>=(100-s)
      	ps=-ps
      	px = -px
      EndIf	
      
      y + py
      If y<=0  Or y>=(100-s)
      	ps=-ps
      	py = -py
      EndIf	
      
			s	+ ps
      If s<=1 Or s>=100
      	ps = -ps
      EndIf	
      
      ResizeCamera(1,x,y,s,s)

      RenderWorld()
      Screen3DStats()
      FlipBuffers()
    Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
  EndIf
    
Else
  MessageRequester("Error", "The 3D Engine can't be initialized",0)
EndIf
  
End
