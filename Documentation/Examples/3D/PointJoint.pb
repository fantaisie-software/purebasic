
; ------------------------------------------------------------
;
;   PureBasic - PointJoint
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
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " PointJoint -  [Space]  [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/skybox.zip", #PB_3DArchive_Zip)

; First create materials
;
CreateMaterial(0, LoadTexture(0, "Wood.jpg"))
CreateMaterial(1, LoadTexture(1, "Dirt.jpg"))

; Meshes
;
CreateCube(0, 1.0)
CreateSphere(1, 0.66)

; Entities
;
CreateEntity(0, MeshID(0), MaterialID(0), 2,  0, 0)
CreateEntity(1, MeshID(0), MaterialID(0), 2, -3, 0)
CreateEntity(2, MeshID(1), MaterialID(0), 2, -6, 0)
;
CreateEntity(3, MeshID(0), MaterialID(1), 5,  4, 0)
ScaleEntity (3, 10, 1, 10)

; Bodies
;
CreateEntityBody(0, #PB_Entity_BoxBody   , 1.0)
CreateEntityBody(1, #PB_Entity_BoxBody   , 1.0)
CreateEntityBody(2, #PB_Entity_SphereBody, 1.0)
CreateEntityBody(3, #PB_Entity_StaticBody)

; PointJoint
;
PointJoint(0, EntityID(3), -5, -1, 0, EntityID(0), 0, 1, 0)
PointJoint(1, EntityID(0),  0, -1, 0, EntityID(1), 0, 1, 0)
PointJoint(2, EntityID(1),  0, -1, 0, EntityID(2), 0, 1, 0)

For i=0 To 2
  SetJointAttribute(i, #PB_PointJoint_Tau, 10)
Next

ApplyEntityImpulse(0,  10, 0, 0)


; Camera
;
CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0, 0, 2, 25, #PB_Absolute)

Repeat
  While WindowEvent():Wend
  
  If ExamineMouse()
    MouseX = -MouseDeltaX() * #CameraSpeed * 0.05
    MouseY = -MouseDeltaY() * #CameraSpeed * 0.05
  EndIf
  
  If ExamineKeyboard()
    
    If KeyboardPushed(#PB_Key_Space)
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

