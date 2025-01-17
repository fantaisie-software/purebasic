
; ------------------------------------------------------------
;
;   PureBasic - Static Geometry
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;



Define.f KeyX, KeyY, MouseX, MouseY
Define nx.f, nz.f, Boost.f = 10, Yaw.f, Pitch.f

InitEngine3D()
InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " Static Geometry - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Main", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts",#PB_3DArchive_FileSystem)
Parse3DScripts()

WorldShadows(#PB_Shadow_Additive)

AmbientColor(0)

; node for Light and Billboard (Sun)
CreateNode(0, 0, 3000, 0)

;Create light
CreateLight(0, RGB(90, 105, 132), 0, 3000, 0)
AttachNodeObject(0, LightID(0))

; Create flare
GetScriptMaterial(0, "Scene/burst")
CreateBillboardGroup(0, MaterialID(0), 2048, 2048)
AddBillboard(0, 0, 3000, 0)
AttachNodeObject(0, BillboardGroupID(0))

; Static geometry
;

; Create Entity
CreateCube(0, 1)
CreateEntity(0, MeshID(0), #PB_Material_None)

; Create Static geometry
CreateStaticGeometry(0, 1000, 1000, 1000, #True)

For z = -10 To 10
  For x = -10 To 10
    AddStaticGeometryEntity(0, EntityID(0), x * 1000, 0, z * 1000, 1000,  10, 1000, 0, 0, 0)
    Height.f = 200 + Random(800)
    AddStaticGeometryEntity(0, EntityID(0), x * 1000, Height/2, z * 1000,  200, Height, 200, 0, Random(360), 0)
  Next
Next

; Build the static geometry
BuildStaticGeometry(0)

FreeEntity(0)

; Camera
;
CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0, 2000, 2000, 2000, #PB_Absolute)
CameraLookAt(0, 0, 0, 0)
CameraFOV   (0, 90)
CameraBackColor(0, RGB(90, 105, 132))

Repeat
  While WindowEvent():Wend
  
  If ExamineMouse()
    Yaw   = -MouseDeltaX() * 0.05
    Pitch = -MouseDeltaY() * 0.05
  EndIf
  
  If ExamineKeyboard()
    
    If KeyboardPushed(#PB_Key_Up)
      MoveCamera(0,  0, 0, -2 * Boost)
    ElseIf KeyboardPushed(#PB_Key_Down)
      MoveCamera(0,  0, 0,  2 * Boost)
    EndIf
    
    If KeyboardPushed(#PB_Key_Left)
      MoveCamera(0, -2 * Boost, 0, 0)
    ElseIf KeyboardPushed(#PB_Key_Right)
      MoveCamera(0,  2 * Boost, 0, 0)
    EndIf
    
  EndIf
  
  ; Sun
  nx = 10000 * Cos(ElapsedMilliseconds() / 2500)
  nz = 10000 * Sin(ElapsedMilliseconds() / 2500)
  MoveNode(0, nx, 3000, nz, #PB_Absolute)
  
  RotateCamera(0, Pitch, Yaw, 0, #PB_Relative)
  
  RenderWorld()
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1

