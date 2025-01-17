
; ------------------------------------------------------------
;
;   PureBasic - GenericJoint
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;



#Speed = 50

Define.f KeyX, KeyY, ex,ey

InitEngine3D()

InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), "GenericJoint - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Main", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
Parse3DScripts()

CreateSprite(1, 200, 120, #PB_Sprite_AlphaBlending)
LoadFont(1, "Arial", 16, #PB_Font_Bold)

;====================== Materials/textures ========================

CreateMaterial(0, LoadTexture(0,"Wood.jpg"))
GetScriptMaterial(1, "Examples/SphereMappedRustySteel")
GetScriptMaterial(2, "Color/Red")
GetScriptMaterial(3, "Color/Green")
CreateMaterial(4, LoadTexture(4, "Dirt.jpg"))
CreateMaterial(10, LoadTexture(10, "ground_diffuse.png")) : ScaleMaterial(10,1/8,1/8)
GetScriptMaterial(11, "Color/Yellow")

;- Aim
CreateSprite(0,256,256,#PB_Sprite_AlphaBlending )
StartDrawing(SpriteOutput(0))
DrawingMode(#PB_2DDrawing_AllChannels)
Box(0, 0, 256, 256, $0)
Circle(128, 128, 102, $ffffffff)
Circle(128, 128, 100, $77aaaaaa)
LineXY(128, 0, 128, 255, $ffffffff)
LineXY(0, 128, 255, 128, $ffffffff)
StopDrawing()

;====================== Meshes/Entities/bodies/joints ========================

; Ground
;
CreateCube(10, 2)
CreateEntity(10, MeshID(10), MaterialID(10),  0, -4.0, 0) : ScaleEntity(10, 20, 0.2, 20)
CreateEntityBody(10, #PB_Entity_StaticBody , 0,0.5,0.5)

; Shoot ball
;
CreateSphere(11, 1)

; plane - elastic y rotation
;
CreateCube(0, 2)
CreateEntity(0, MeshID(0), MaterialID(0),  8,  1.0, 0) : ScaleEntity(0, 4, 1, 0.2)
CreateEntityBody(0, #PB_Entity_BoxBody, 1, 0.5, 0.5)

GenericJoint(1,EntityID(10),8,2,0,EntityID(0), 0, 0, 0)
SetJointAttribute(1, #PB_Joint_EnableSpring, #True, 4)
SetJointAttribute(1, #PB_Joint_Stiffness, 500, 4)
SetJointAttribute(1, #PB_Joint_Damping, 0.01, 4)

; Punching ball: elastic x and z rotation
;
CreateSphere(1, 3)
CreateEntity(1, MeshID(1), MaterialID(1), -8,  0.5, 0)
CreateEntityBody(1, #PB_Entity_SphereBody, 0.4, 0.5, 0.5)

GenericJoint(0,EntityID(10), -6, 0, 0,EntityID(1), 0, -6, 0)
SetJointAttribute(0, #PB_Joint_EnableSpring, #True, 3)
SetJointAttribute(0, #PB_Joint_Stiffness, 1000, 3)
SetJointAttribute(0, #PB_Joint_Damping, 0.005, 3)
SetJointAttribute(0, #PB_Joint_EnableSpring, #True, 5)
SetJointAttribute(0, #PB_Joint_Stiffness, 1000, 5)
SetJointAttribute(0, #PB_Joint_Damping, 0.005, 5)

; red target - elastic z translation
;
CreateSphere(2, 2)
CreateEntity(2, MeshID(2), MaterialID(2),  0,  0.0, 0) : ScaleEntity(2, 1, 1, 0.3)
CreateEntityBody(2, #PB_Entity_ConvexHullBody, 1, 0.5, 0.5)

GenericJoint(2,EntityID(10), 16, 2, 0,EntityID(2), 0, -2, 0)
SetJointAttribute(2, #PB_Joint_EnableSpring, #True, 2)
SetJointAttribute(2, #PB_Joint_Stiffness, 5, 2)
SetJointAttribute(2, #PB_Joint_Damping, 0.5, 2)

; green target - elastic x translation and z rotation
;
CreateSphere(3, 2)
CreateEntity(3, MeshID(2), MaterialID(3),  0,  0.0, -8) : ScaleEntity(3, 0.3, 1, 1)
CreateEntityBody(3, #PB_Entity_ConvexHullBody, 1,0.5,0.5)

GenericJoint(3,EntityID(10), 0, 4, -8, EntityID(3), 0, 0, 0)
SetJointAttribute(3, #PB_Joint_EnableSpring, #True, 0)
SetJointAttribute(3, #PB_Joint_Stiffness, 1, 0)
SetJointAttribute(3, #PB_Joint_Damping, 0.5, 0)
SetJointAttribute(3, #PB_Joint_NoLimit, 0, 5)

; turnstile - free x rotation
;
CreateCube(4, 4)
CreateEntity(4, MeshID(4), MaterialID(4),  -12,  0.0, 0) : ScaleEntity(4, 1, 1, 0.2)
CreateEntityBody(4, #PB_Entity_BoxBody, 1, 0.5, 0.5)

GenericJoint(4,EntityID(10), -16, 4, 0,EntityID(4), 0, 0, 0)
SetJointAttribute(4, #PB_Joint_NoLimit, 0, 3)

; Camera
;
CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0, -1, 8, 25, #PB_Absolute)
CameraLookAt(0, -1, 0, 0)

; Light
;
CreateLight(0, $ffffff, 500, 1000, 500)
AmbientColor($777777)

WorldShadows(#PB_Shadow_Additive)

MouseLocate(dx/2, dy/2)

Repeat
  While WindowEvent():Wend      
  ExamineMouse()
  ExamineKeyboard()
  
  If MouseButton(#PB_MouseButton_Left)
    If Clic = 0
      If PointPick(0, MouseX(), MouseY())
        Clic = 1
        Shoot = CreateEntity(#PB_Any, MeshID(11), MaterialID(11), CameraX(0), CameraY(0), CameraZ(0))
        CreateEntityBody(Shoot, #PB_Entity_SphereBody, 1,0.5,0.5)
        ApplyEntityImpulse(Shoot, PickX() * #Speed, PickY() * #Speed, PickZ() * #Speed)
      EndIf
    EndIf
  Else
    Clic = 0
  EndIf
  
  keyy = -(Bool(KeyboardPushed(#PB_Key_Up)<>0)-Bool(KeyboardPushed(#PB_Key_Down)<>0))-MouseWheel()*5
  keyx = -(Bool(KeyboardPushed(#PB_Key_Left)<>0)-Bool(KeyboardPushed(#PB_Key_Right)<>0))
  
  MoveCamera  (0, KeyX, 0, KeyY)
  CameraLookAt(0, 0, 0, 0)
  
  RenderWorld()
  DisplayTransparentSprite(0,  MouseX()-SpriteWidth(0)/2,  MouseY()-SpriteHeight(0)/2)
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
