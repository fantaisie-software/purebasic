
; ------------------------------------------------------------
;
;   PureBasic - CreateLine3D
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#CameraSpeed = 1

Define.f KeyX, KeyY, MouseX, MouseY

InitEngine3D()
InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " CreateLine3D - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models"  , #PB_3DArchive_FileSystem)

LoadMesh(10, "axes.mesh")
CreateMaterial(0, LoadTexture(0, "axes.png"))
CreateEntity(0, MeshID(10), MaterialID(0))
ScaleEntity(0, 0.1, 0.1 ,0.1)

; Line3D
;
CreateLine3D(0, 0, 0, 0, RGB(255,   0,   0), 10,  0,  0, RGB(255,   0,   0))  ; Axis X
CreateLine3D(1, 0, 0, 0, RGB(  0, 255,   0),  0, 10,  0, RGB(  0, 255,   0))  ; Axis Y
CreateLine3D(2, 0, 0, 0, RGB(  0,   0, 255),  0,  0, 10, RGB(  0,   0, 255))  ; Axis Z

; Camera
;
CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0, 5, 5, 5, #PB_Absolute)
CameraLookAt(0, 0, 0, 0)

Repeat
  While WindowEvent():Wend
  
  If ExamineMouse()
    MouseX = -MouseDeltaX() * #CameraSpeed * 0.05
    MouseY = -MouseDeltaY() * #CameraSpeed * 0.05
  EndIf
  
  If ExamineKeyboard()    
    KeyX = (KeyboardPushed(#PB_Key_Right)-KeyboardPushed(#PB_Key_Left))*#CameraSpeed
    Keyy = (KeyboardPushed(#PB_Key_Down)-KeyboardPushed(#PB_Key_Up))*#CameraSpeed    
  EndIf
  
  RotateCamera(0, MouseY, MouseX, 0, #PB_Relative)
  MoveCamera  (0, KeyX, 0, KeyY)
  
  RenderWorld()
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1

