
; ------------------------------------------------------------
;
;   PureBasic - Pitch - Yaw
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#CameraSpeed = 2



Define.f KeyX, KeyY, MouseX, MouseY

InitEngine3D()

InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " Pitch - Yaw - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
Parse3DScripts()

; First create materials
;

GrassMaterial = CreateMaterial(#PB_Any, TextureID(LoadTexture(#PB_Any,"grass1.png")))
SetMaterialAttribute(GrassMaterial, #PB_Material_AlphaReject,128)
SetMaterialAttribute(GrassMaterial, #PB_Material_TAM,#PB_Material_ClampTAM)
DirtMaterial = CreateMaterial(#PB_Any, TextureID(LoadTexture(#PB_Any,"Dirt.jpg")))


; Then create the billboard group and use the previous material
;
;-Billboard

Billboard = CreateBillboardGroup(#PB_Any, MaterialID(GrassMaterial), 50, 50)
For i = 0 To 4000
  AddBillboard(Billboard, Random(2000)-1000, 25-Random(8), Random(2000) - 1000)
Next i

; create ground
MeshPlane = CreatePlane(#PB_Any, 2000, 2000, 40, 40, 4, 4)
CreateEntity(#PB_Any, MeshID(MeshPlane), MaterialID(DirtMaterial))

; Add house
MeshHouse = LoadMesh(#PB_Any, "tudorhouse.mesh")
House = CreateEntity(#PB_Any, MeshID(MeshHouse), #PB_Material_None, 0, 280, 0)
ScaleEntity(House, 0.5, 0.5, 0.5)

; SkyBox
SkyBox("desert07.jpg")

; create camera
Camera = CreateCamera(#PB_Any, 0, 0, 100, 100)

; light
light=CreateLight(#PB_Any,$ffffff,10000,10000,10000)

;Create Node
NodePitch = CreateNode(#PB_Any)
NodeYaw = CreateNode(#PB_Any,200, 70, 900)
AttachNodeObject(NodePitch, CameraID(camera))
AttachNodeObject(NodeYaw, NodeID(NodePitch))

Repeat
  While WindowEvent():Wend
  
  If ExamineMouse()
    MouseX = -MouseDeltaX() * #CameraSpeed * 0.05
    MouseY = -MouseDeltaY() * #CameraSpeed * 0.05
  EndIf
  
  If ExamineKeyboard()
    
    If KeyboardPushed(#PB_Key_Left)
      KeyX = -#CameraSpeed
    ElseIf KeyboardPushed(#PB_Key_Right)
      KeyX = #CameraSpeed
    Else
      KeyX * 0.85
    EndIf
    
    If KeyboardPushed(#PB_Key_Up)
      KeyY = -#CameraSpeed
    ElseIf KeyboardPushed(#PB_Key_Down)
      KeyY = #CameraSpeed
    Else
      KeyY * 0.9
    EndIf
    
  EndIf
  
  Pitch(NodeID(NodePitch), MouseY, #PB_Local | #PB_Relative)
  Yaw  (NodeID(NodeYaw)  , MouseX, #PB_World | #PB_Relative)
  
  MoveNode(NodeYaw, KeyX, 0, KeyY, #PB_Local | #PB_Relative)
  
  RenderWorld()
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1

