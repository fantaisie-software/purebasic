
; ------------------------------------------------------------
;
;   PureBasic - ConvertWorldToLocalPosition
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;



; Button left to draw
; Button right to clear

Declare DrawOnWhiteBoard()

Define.f KeyX, KeyY, MouseX, MouseY
Global Entity.i, P.Vector3

LoadFont(0, "Arial"  ,  16, #PB_Font_Bold)

#CameraSpeed  = 3

Macro InitImage()
  StartDrawing(ImageOutput(0))
  Box(0, 0, 320, 240, 0)
  DrawingMode(#PB_2DDrawing_Outlined)
  Box(0, 0, 320, 240, RGB(255, 255, 255))
  DrawingFont(FontID(0))
  DrawText(5, 20, "left button to draw", RGB(155, 80, 0), 0)
  DrawText(5, 80, "Right button to clear", RGB(155, 80, 0), 0)
  StopDrawing()
EndMacro

InitEngine3D()

InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " ConvertWorldToLocalPosition - Use mouse to draw on mesh    [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/GUI", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/skybox.zip", #PB_3DArchive_Zip)
Parse3DScripts()

CreateMesh(0)
MeshVertex(-1, 0, 1,  1,0,  $ffffff,  0,-1,0)
MeshVertex( 1, 0, 1,  0,0,  $ffffff,  0,-1,0)
MeshVertex( 1, 0,-1,  0,1,  $ffffff,  0,-1,0)
MeshVertex(-1, 0,-1,  1,1,  $ffffff,  0,-1,0)
MeshFace(0, 1, 2)
MeshFace(0, 2, 3)
MeshFace(2, 1, 0)
MeshFace(3, 2, 0)
FinishMesh(1)

CreateImage(0, 320, 240)
InitImage()

CreateTexture(0, 320, 240)

CreateMaterial(0, TextureID(0))
MaterialBlendingMode(0, #PB_Material_Add)
DisableMaterialLighting(0, 1)
MaterialCullingMode(0, 1)
MaterialFilteringMode(0,#PB_Material_Anisotropic)

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
  While WindowEvent():Wend
  
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
    KeyX = (KeyboardPushed(#PB_Key_Right)-KeyboardPushed(#PB_Key_Left))*#CameraSpeed
    Keyy = (KeyboardPushed(#PB_Key_Down)-KeyboardPushed(#PB_Key_Up))*#CameraSpeed    
  EndIf
  RotateEntity(Entity, 0.1, 0.1, 0.1, #PB_Relative|#PB_World)
  
  StartDrawing(TextureOutput(0))
  DrawImage(ImageID(0), 0, 0)
  StopDrawing()
  
  CameraLookAt(0, 30, 40, 50)
  MoveCamera  (0, KeyX, 0, KeyY)
  RenderWorld()
  
  FlipBuffers()
  
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1

Procedure DrawOnWhiteBoard()
  Protected x, y
  Static Mem, Memx, Memy
  StartDrawing(ImageOutput(0))
  If MouseButton(#PB_MouseButton_Left)
    
    ConvertWorldToLocalPosition(EntityID(Entity), PickX(), PickY(), PickZ())
    
    x = (1 - GetX()) * 160
    y = (1 - GetZ()) * 120

    If x>0 And x<320 And y>0 And y<240
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