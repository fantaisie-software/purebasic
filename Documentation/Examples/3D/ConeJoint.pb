
; ------------------------------------------------------------
;
;   PureBasic - ConeTwistJoint
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

Define.f KeyX, KeyY, MouseX, MouseY
#CameraSpeed = 1

InitEngine3D()
InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " ConeTwistJoint -  [Space]   [F]  [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models"  , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts" , #PB_3DArchive_FileSystem)
Parse3DScripts()

; First create materials
;
CreateMaterial(0, LoadTexture(0, "Dirt.jpg"))
CreateMaterial(1, LoadTexture(1, "Wood.jpg"))

; Meshes
;
CreateCylinder(0, 0.5, 1)

; Entities
;
CreateEntity(0, MeshID(0), MaterialID(0), 0,  0, 0)
ScaleEntity(0, 1, 0.5, 1)
CreateEntity(1, MeshID(0), MaterialID(1), 0, -4, 0)
ScaleEntity(1, 1, 3, 1)
CreateEntity(2, MeshID(0), MaterialID(1), 0, -8, 0)
ScaleEntity(2, 1, 3, 1)
; Bodies
;
CreateEntityBody(0, #PB_Entity_StaticBody)
CreateEntityBody(1, #PB_Entity_BoxBody, 1.0)
CreateEntityBody(2, #PB_Entity_BoxBody, 1.0)

; ConeTwistJoint
;
ConeTwistJoint(0, EntityID(0), 0, -1, 0, EntityID(1), 0, 1, 0)
SetJointAttribute(0, #PB_ConeTwistJoint_SwingSpan, 0)
SetJointAttribute(0, #PB_ConeTwistJoint_SwingSpan2, 0)
SetJointAttribute(0, #PB_ConeTwistJoint_TwistSpan, 1)
ConeTwistJoint(1, EntityID(1), 0, -2, 0, EntityID(2), 0, 2, 0)
SetJointAttribute(1, #PB_ConeTwistJoint_SwingSpan, 1)
SetJointAttribute(1, #PB_ConeTwistJoint_SwingSpan2, 1)
SetJointAttribute(1, #PB_ConeTwistJoint_TwistSpan, 1)

ApplyEntityImpulse(1, 0, 0, 1)

; Camera
;
CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0, 0, 4, 22, #PB_Absolute)
CameraLookAt(0, 0, 0, 0)

Repeat
  While WindowEvent():Wend
  
  If ExamineMouse()
    MouseX = -MouseDeltaX() * #CameraSpeed * 0.05
    MouseY = -MouseDeltaY() * #CameraSpeed * 0.05
  EndIf
  
  If ExamineKeyboard()
    
    If KeyboardPushed(#PB_Key_Space)
      ApplyEntityImpulse(1,  2, 0, 2)
      ApplyEntityImpulse(2,  2, 0, 2)
    EndIf
    
    If KeyboardReleased(#PB_Key_F)
      FreeJoint(1)
    EndIf
    
    KeyX = (KeyboardPushed(#PB_Key_Right)-KeyboardPushed(#PB_Key_Left))*#CameraSpeed
    Keyy = (KeyboardPushed(#PB_Key_Down)-KeyboardPushed(#PB_Key_Up))*#CameraSpeed    
    
  EndIf
  
  RotateCamera(0, MouseY, MouseX, 0, #PB_Relative)
  MoveCamera  (0, KeyX, 0, KeyY)
  
  RenderWorld()
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1

