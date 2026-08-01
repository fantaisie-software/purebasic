
; ------------------------------------------------------------
;
;   PureBasic - WorldDebug
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#CameraSpeed = 0.4
#Speed = 60

Enumeration
  #MainWindow
  #Editor
EndEnumeration

Define.f KeyX, KeyY, MouseX, MouseY, RatioX, RatioY
Define DebugBody

InitEngine3D()

InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " WorldDebug -  [F2] Debug Entity     [F3] Debug Body    [F4] Debug none   [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
Parse3DScripts()

;- Materials
GetScriptMaterial(0, "Color/Blue")
GetScriptMaterial(1, "Color/Green")
GetScriptMaterial(2, "Color/Red")
GetScriptMaterial(3, "Color/Yellow")
CreateMaterial(4, LoadTexture(0, "Dirt.jpg"))

;- Meshes
CreateCube(0, 2)
CreateSphere(1, 1)
LoadMesh(2, "PureBasic.mesh")

;- Entities
CreateEntity(0, MeshID(0), MaterialID(0),  4, 1.0, 0)
CreateEntity(1, MeshID(1), MaterialID(1), -4, 0.5, 0)
CreateEntity(2, MeshID(2), MaterialID(2),  0, -2.3, 0)
CreateEntity(4, MeshID(0), MaterialID(4), 0, -4, 0)
ScaleEntity(2, 0.1, 0.1, 0.1)
ScaleEntity(4, 5, 0.5, 5)

;- Body
CreateEntityBody(0, #PB_Entity_BoxBody, 1)
CreateEntityBody(1, #PB_Entity_SphereBody, 1)
CreateEntityBody(2, #PB_Entity_StaticBody)
CreateEntityBody(4, #PB_Entity_StaticBody)

;- Camera
Camera = CreateCamera(#PB_Any, 0, 0, 100, 100)
MoveCamera(Camera, -1, 8, 25, #PB_Absolute)
CameraLookAt(Camera, -1, 0, 0)

;- Light
CreateLight(#PB_Any, RGB(255, 255, 255), 1560, 900, 500)

Repeat
  While WindowEvent():Wend
    
  If ExamineMouse()
    MouseX = -MouseDeltaX() * #CameraSpeed * 0.05
    MouseY = -MouseDeltaY() * #CameraSpeed * 0.05
    
    InputEvent3D(MouseX(), MouseY(), MouseButton(#PB_MouseButton_Left))
    
  EndIf
  
  If ExamineKeyboard()
    
    If KeyboardPushed(#PB_Key_F2)
      WorldDebug(#PB_World_DebugEntity)
    ElseIf KeyboardPushed(#PB_Key_F3)
      WorldDebug(#PB_World_DebugBody)
    ElseIf KeyboardPushed(#PB_Key_F4)
      WorldDebug(#PB_World_DebugNone)
    EndIf
        
    KeyX = (KeyboardPushed(#PB_Key_Right)-KeyboardPushed(#PB_Key_Left))*#CameraSpeed
    Keyy = (KeyboardPushed(#PB_Key_Down)-KeyboardPushed(#PB_Key_Up))*#CameraSpeed    
    
  EndIf
  
  CameraLookAt(Camera, 0, 0, 0)
  MoveCamera  (Camera, KeyX, 0, KeyY)
  
  RenderWorld()
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1

