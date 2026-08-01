
; ------------------------------------------------------------
;
;   PureBasic - SliderJoint & HingeJoint
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;


Define.f KeyX, KeyY, MouseX, MouseY
Define Direction = 0, Time = ElapsedMilliseconds()

#CameraSpeed = 0.2

Macro DoorClosed()
  (EntityX(1) > -1.07)
EndMacro

InitEngine3D()
InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " SliderJoint & HingeJoint -  [Space]  [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
Parse3DScripts()

; First create materials
;
CreateMaterial(0, LoadTexture(0, "Dirt.jpg"))
CreateMaterial(1, LoadTexture(1, "Wood.jpg"))
GetScriptMaterial(2, "Color/Green")
GetScriptMaterial(3, "Color/Red")

; Meshes
;
CreateCube(0, 1.0)
CreateSphere(1, 0.5)

; Entities
;
CreateEntity(0, MeshID(0), MaterialID(0),  1, 0.1, 0)
ScaleEntity(0, 2, 4, 0.5)
CreateEntity(1, MeshID(0), MaterialID(1), -3, 0.1, 0)
ScaleEntity(1, 2, 4, 0.5)

CreateEntity(3, MeshID(1), MaterialID(3), -1, -1.25, 0.23)

CreateEntity(4, MeshID(0), MaterialID(0),  -2, -2.3, -1.0)
ScaleEntity(4, 8, 0.5, 4)
CreateEntity(5, MeshID(0), MaterialID(1), -2, -2.3, 3)
ScaleEntity(5, 8, 0.5, 4)

; Bodies
;
CreateEntityBody(0, #PB_Entity_StaticBody)
CreateEntityBody(1, #PB_Entity_BoxBody, 1.0)

CreateEntityBody(3, #PB_Entity_SphereBody, 0.5)

CreateEntityBody(4, #PB_Entity_StaticBody)
CreateEntityBody(5, #PB_Entity_BoxBody, 0.1)

; SliderJoint
;
SliderJoint  (0, EntityID(0), -1, 0, 0, EntityID(1), 1, 0, 0)
SetJointAttribute(0, #PB_SliderJoint_LowerLimit, -3)
SetJointAttribute(0, #PB_SliderJoint_UpperLimit,  0)

; HingeJoint
;
HingeJoint(1, EntityID(4), 4, 0.1, 2.01, 1, 0, 0, EntityID(5), 4, 0.1, -2, 1, 0, 0)

; Camera
;
CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0, 10, 6, 19, #PB_Absolute)
CameraLookAt(0, 0, 0, 0)

; Light
CreateLight(0, $FFFFFF, 1560, 900, 500)
AmbientColor($330000)

Repeat
  While WindowEvent():Wend
  
  If ElapsedMilliseconds() - Time > 1500 And Not DoorClosed()
    Direction = 1 - Direction
    Time = ElapsedMilliseconds()
  EndIf
  
  If Direction = 1
    ApplyEntityImpulse(1, 0.3, 0, 0)
  Else
    ApplyEntityImpulse(1, -0.3, 0, 0)
  EndIf
  
  If ExamineMouse()
    MouseX = -MouseDeltaX() * 0.05
    MouseY = -MouseDeltaY() * 0.05
  EndIf
  
  If ExamineKeyboard()
    
    If KeyboardReleased(#PB_Key_Space)
      direction = 0
      DisableEntityBody(1, 0)
      ApplyEntityImpulse(1, -10, 0, 0)
      Time = ElapsedMilliseconds()
      FreeEntity(3)
      CreateEntity(3, MeshID(1), MaterialID(3), -1, 15, 0.23)
      CreateEntityBody(3, #PB_Entity_SphereBody, 0.5)
    EndIf
    
    KeyX = (KeyboardPushed(#PB_Key_Right)-KeyboardPushed(#PB_Key_Left))*#CameraSpeed
    Keyy = (KeyboardPushed(#PB_Key_Down)-KeyboardPushed(#PB_Key_Up))*#CameraSpeed    
    
  EndIf
  
  RotateCamera(0, MouseY, MouseX, 0, #PB_Relative)
  MoveCamera  (0, KeyX, 0, KeyY)
  
  RenderWorld()
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1

