;
; ------------------------------------------------------------
;
;   PureBasic - ConvertWorldToLocalPosition
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

; Button left to draw
; Button right to clear 

Structure Vector3
  x.f
  y.f
  z.f
EndStructure

Declare DrawOnWhiteBoard()

Define.f KeyX, KeyY, MouseX, MouseY
Global Entity.i, P.Vector3

LoadFont(0, "Arial"  ,  8, #PB_Font_Bold)

#CameraSpeed  = 3

Macro InitImage()
  StartDrawing(ImageOutput(0))
  Box(0, 0, 160, 120, 0)
  DrawingMode(#PB_2DDrawing_Outlined)
  Box(0, 0, 160, 120, RGB(255, 255, 255))
  DrawingFont(FontID(0))
  DrawText(5, 10, "left button to draw", RGB(155, 80, 0), 0)
  DrawText(5, 40, "Right button to clear", RGB(155, 80, 0), 0)
  StopDrawing()
EndMacro

If InitEngine3D()
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/GUI", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/skybox.zip", #PB_3DArchive_Zip)
  Parse3DScripts()
  
  If Screen3DRequester()
    
    CreateMesh(0)
    MeshVertexPosition(-1, 0,  1)
    MeshVertexNormal(0,-1,0)
    MeshVertexTextureCoordinate(1,0)
    MeshVertexPosition( 1, 0, 1)
    MeshVertexNormal(0,-1,0)
    MeshVertexTextureCoordinate(0,0)
    MeshVertexPosition( 1, 0, -1)
    MeshVertexNormal(0,-1,0)
    MeshVertexTextureCoordinate(0,1)
    MeshVertexPosition(-1, 0, -1)
    MeshVertexNormal(0,-1,0)
    MeshVertexTextureCoordinate(1,1)
    MeshFace(0, 1, 2)
    MeshFace(0, 2, 3)
    MeshFace(2, 1, 0)
    MeshFace(3, 2, 0)
    FinishMesh(1)
    
    CreateImage(0, 160, 120)
    InitImage()
    
    CreateTexture(0, 160, 120)
    
    CreateMaterial(0, TextureID(0))
    MaterialBlendingMode(0, #PB_Material_Add)
    DisableMaterialLighting(0, 1)
    MaterialCullingMode(0, 1)
    
    Entity = CreateEntity(#PB_Any, MeshID(0), MaterialID(0), 30, 40, 50)
    ScaleEntity(Entity, 80, 1, 60)
    
    CreateLight(0, RGB(0,0,255), 100.0, 0, 0)
    
    CreateCamera(0, 0, 0, 100, 100)
    MoveCamera(0, 10, 350, -150, #PB_Absolute)
    CameraLookAt(0, 30, 40, 50)
    CameraBackColor(0, RGB(0, 0, 90))
    
    ShowGUI(128, 1) ; Display the GUI, semi-transparent and display the mouse cursor
    
    SkyBox("stevecube.jpg")
    
    MouseLocate(CameraViewWidth(0)/2, CameraViewHeight(0)/2)
    
    Repeat
      Screen3DEvents()
      
      If ExamineMouse()
        InputEvent3D(MouseX(), MouseY(), MouseButton(#PB_MouseButton_Left))
        MouseX = -MouseDeltaX() * #CameraSpeed * 0.05
        MouseY = -MouseDeltaY() * #CameraSpeed * 0.05
        
        ; Test Mouse
        
        If MouseRayCast(0, MouseX(), MouseY(), -1) = Entity
          DrawOnWhiteBoard()
        EndIf
      EndIf   
      
      If ExamineKeyboard()
        
        If KeyboardPushed(#PB_Key_Left)
          KeyX = -#CameraSpeed
        ElseIf KeyboardPushed(#PB_Key_Right)
          KeyX = #CameraSpeed
        Else
          KeyX = 0
        EndIf
        
        If KeyboardPushed(#PB_Key_Up)
          KeyY = -#CameraSpeed
        ElseIf KeyboardPushed(#PB_Key_Down)
          KeyY = #CameraSpeed
        Else
          KeyY = 0
        EndIf
        
      EndIf
      
      RotateEntity(Entity, 0.1, 0.1, 0.1, #PB_Relative)
      
      StartDrawing(TextureOutput(0))
      DrawImage(ImageID(0), 0, 0)
      StopDrawing()
      
      CameraLookAt(0, 30, 40, 50)
      MoveCamera  (0, KeyX, 0, KeyY)
      RenderWorld()
      
      FlipBuffers()
      
    Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
  EndIf
  
Else
  MessageRequester("Error", "The 3D Engine can't be initialized", 0)
EndIf
End


Procedure DrawOnWhiteBoard()
  Protected x, y
  Static Mem, Memx, Memy
  StartDrawing(ImageOutput(0))
  If MouseButton(#PB_MouseButton_Left)
    
    ConvertWorldToLocalPosition(EntityID(Entity), PickX(), PickY(), PickZ()) 
    
    x = (1 - GetX()) * 80 
    y = (1 - GetZ()) * 60 
    
    If x>0 And x<160 And y>0 And y<120
      If mem = 0
        Memx = x
        Memy = y
        mem = 1
      EndIf
      LineXY(memx, memy, x, y, $FF)
      
      Memx = x
      Memy = y
    EndIf  
  ElseIf MouseButton(#PB_MouseButton_Right)
    StopDrawing()
    InitImage()
  Else
    mem = 0
  EndIf
  StopDrawing()
EndProcedure        