
; ------------------------------------------------------------
;
;   PureBasic - LightAttenuation
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
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " LightAttenuation - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Main", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts",#PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
Parse3DScripts()

KeyboardMode(#PB_Keyboard_International)

WorldShadows(#PB_Shadow_Modulative, -1, RGB(128,128,128))

;Materials
;
CreateMaterial(1, LoadTexture(1, "Wood.jpg")):MaterialShininess(1,64,$ffffff)
CreateMaterial(2, LoadTexture(2, "Dirt.jpg"))
CreateMaterial(3, LoadTexture(3, "flare.png")):MaterialBlendingMode(3,#PB_Material_Add):DisableMaterialLighting(3,1)

; Ground
;
CreatePlane(0, 64,64,64,64, 15, 15)
CreateEntity(0, MeshID(0), MaterialID(2))

; Meshes
;
CreateCube(1, 4)
CreateSphere(2, 2, 32,32)
CreateCapsule(3, 1.5, 3,32,32,1)
CreateTorus(4, 2, 1,32,32)

; Entities
;
For i=-2 To 2
  For j=-2 To 2
    num+1
    CreateEntity(num, MeshID(Random(3)+1), MaterialID(1), i*8,2,j*8)
    RotateEntity(num,Random(360),Random(360),Random(360))
  Next
Next

; Camera
;
CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0, 5, 15, -25, #PB_Absolute)
CameraLookAt(0, 0, 0, 0)

; Light
;
CreateLight(0, RGB(255,255,255))
LightAttenuation(0, 100, 1.0)

;- Billboard group
;
CreateBillboardGroup(0, MaterialID(3), 10, 10)
AddBillboard(0, 0, 0, 0)

AmbientColor(RGB(0, 0, 0))

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
  
  MoveCamera  (0, KeyX, 0, KeyY)
  RotateCamera(0,  MouseY, MouseX, 0, #PB_Relative)
  
  a.f+0.01
  MoveLight(0,          -16*Cos(a), 8, -16*Sin(a),#PB_Absolute)
  MoveBillboardGroup(0, -16*Cos(a), 8, -16*Sin(a),#PB_Absolute)
  
  RenderWorld()
  FlipBuffers()
  
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
