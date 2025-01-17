
; ------------------------------------------------------------
;
;   PureBasic - Node
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;



#CameraSpeed = 1
#NBNode      = 3
#NbBranche   = 7

Define.l i, j
Define.f KeyX, KeyY, MouseX, MouseY

Dim entity(#NbBranche, #NBNode)
Dim Node(#NbBranche, #NBNode)


InitEngine3D()
InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " Node - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data"                 , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures"        , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/skybox.zip", #PB_3DArchive_Zip)

CreateMaterial(0, LoadTexture(0, "Dirt.jpg"))

CreateSphere(0, 1)

d=3

For j = 0 To #NbBranche
  
  Node(j, 0) = CreateNode(#PB_Any, 0, 0, 0)
  Entity(j, 0) = CreateEntity(#PB_Any, MeshID(0), MaterialID(0))
  ScaleEntity(Entity(j, 0), 1, 1, 2)
  AttachNodeObject(Node(j, 0), EntityID(Entity(j, 0)))
  MoveEntity(entity(j, 0), 0, 0, d)
  
  For i = 1 To #NBNode
    Node(j, i) = CreateNode(#PB_Any,0,0,0)
    MoveNode(Node(j, i), 0, 0, d)
    AttachNodeObject(Node(j, i - 1), NodeID(Node(j, i)))
    entity(j, i) = CreateEntity(#PB_Any, MeshID(0), MaterialID(0))
    ScaleEntity(Entity(j, i), 1, 1, 2)
    AttachNodeObject(Node(j, i), EntityID(Entity(j, i)))
    MoveEntity(entity(j, i), 0, 0, d)
  Next
  
Next

;-Camera
CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0, 0, 30, 30, #PB_Absolute)
CameraLookAt(0,NodeX(Node(0, 0)), NodeY(Node(0, 0)), NodeZ(Node(0, 0)))

;-Skybox
SkyBox("stevecube.jpg")

;-Light
CreateLight(0, RGB(255, 255, 255), 0, 500, 100)
AmbientColor(RGB(85, 85, 85))


Repeat
  
  While WindowEvent():Wend
  
  If  ExamineMouse()
    
    For j = 0 To #NbBranche
      RotateNode(Node(j, 0), (45-(MouseY()/8)), 360.0/(#NbBranche+1) * j + (MouseX()/2),0, #PB_Absolute)
      For i = 1 To #NBNode
        RotateNode(Node(j, i), 45-(MouseY()/8), 0, 0, #PB_Absolute)
      Next
    Next
    
  EndIf
  
  If ExamineKeyboard()
    
    If KeyboardPushed(#PB_Key_Up)
      MoveCamera(0, 0, 0, -#CameraSpeed)
    ElseIf KeyboardPushed(#PB_Key_Down)
      MoveCamera(0, 0, 0, #CameraSpeed)
    EndIf
    
    If KeyboardPushed(#PB_Key_Left)
      MoveCamera(0, #CameraSpeed, 0, 0)
    ElseIf KeyboardPushed(#PB_Key_Right)
      MoveCamera(0, -#CameraSpeed, 0, 0)
    EndIf
    
  EndIf
  
  RenderWorld()
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1

