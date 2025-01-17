
; ------------------------------------------------------------
;
;   PureBasic - sliderJoint
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;


Define.f KeyX, KeyY, MouseX, MouseY
#CameraSpeed = 0.2

InitEngine3D()
InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " sliderJoint -  [PageUp]   [PageDown]  [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Parse3DScripts()

; First create materials
;
CreateMaterial(0, LoadTexture(0, "Dirt.jpg"))
CreateMaterial(1, LoadTexture(1, "Wood.jpg"))
CreateMaterial(2, 0,$00ff00):MaterialShininess(2,64,$ffffff)
CreateMaterial(3, 0,$0000ff):MaterialShininess(3,64,$ffffff)

; Meshes
;
CreateCube(0, 1.0)
CreateSphere(1, 0.5)

; Entities
;
CreateEntity(0, MeshID(0), MaterialID(0),  1, 0, 0)
ScaleEntity(0, 2, 4, 0.5)
CreateEntity(1, MeshID(0), MaterialID(1), -3, 0, 0)
ScaleEntity(1, 2, 4, 0.5)

CreateEntity(2, MeshID(0), MaterialID(1), -1, -2.1, 0)
ScaleEntity(2, 10, 0.1, 4)

CreateEntity(3, MeshID(1), MaterialID(3), -1, 1, 0.23)

; Bodies
;
CreateEntityBody(0, #PB_Entity_StaticBody)
CreateEntityBody(1, #PB_Entity_BoxBody, 1.0)
CreateEntityBody(2, #PB_Entity_StaticBody)
CreateEntityBody(3, #PB_Entity_SphereBody, 0.5)

; SliderJoint
;
SliderJoint(0, EntityID(0), -1, 0, 0, EntityID(1), 1, 0, 0)
SetJointAttribute(0, #PB_SliderJoint_LowerLimit, -3)
SetJointAttribute(0, #PB_SliderJoint_UpperLimit,  0)

; Camera
;
CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0, -1, 8, 5, #PB_Absolute)
CameraLookAt(0, -1, 0, 0)

; Light
CreateLight(0, $FFFFFF, 1560, 900, 500)
AmbientColor($330000)

Repeat
  While WindowEvent():Wend
  
  If ExamineMouse()
    MouseX = -MouseDeltaX() * 0.05
    MouseY = -MouseDeltaY() * 0.05
  EndIf
  
  If ExamineKeyboard()
    
    If KeyboardPushed(#PB_Key_PageUp)
      ApplyEntityImpulse(1, 0.1, 0, 0)
    ElseIf KeyboardPushed(#PB_Key_PageDown)
      ApplyEntityImpulse(1, -0.1, 0, 0)
    EndIf
    
    KeyX = (KeyboardPushed(#PB_Key_Right)-KeyboardPushed(#PB_Key_Left))*#CameraSpeed
    Keyy = (KeyboardPushed(#PB_Key_Down)-KeyboardPushed(#PB_Key_Up))*#CameraSpeed    
    
  EndIf
  
  RotateCamera(0, MouseY, MouseX, 0, #PB_Relative)
  MoveCamera  (0, KeyX, 0, KeyY)
  
  RenderWorld()
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1

