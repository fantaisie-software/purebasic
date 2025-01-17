
; ------------------------------------------------------------
;
;   PureBasic - ExamineWorldCollisions
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#CameraSpeed = 1

Define.f KeyX, KeyY, MouseX, MouseY, Speed1, Speed2, TimeSinceLastFrame, d = 0.4

InitEngine3D()
  
InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " ExamineWorldCollisions - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)
    
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Main", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/skybox.zip", #PB_3DArchive_Zip)
Parse3DScripts()

WorldShadows(#PB_Shadow_Additive, 100)

CreateMaterial(0, LoadTexture(0, "Dirt.jpg"))
CreateMaterial(1, LoadTexture(1, "DosCarte.png"))
CreateMaterial(2, LoadTexture(2, "Wood.jpg"))

SphereMesh = CreateSphere(#PB_Any, 0.06)
CubeMesh = CreateCube(#PB_Any, 0.1)

;-Ground
Ground = CreateEntity(#PB_Any, MeshID(CubeMesh), MaterialID(0))
ScaleEntity(Ground, 150, 1, 150)
EntityRenderMode(Ground, 0)
CreateEntityBody(Ground, #PB_Entity_BoxBody, 0, 0, 0.1)

Entity = CreateEntity(#PB_Any, MeshID(SphereMesh), MaterialID(1), 0, 0.2, 0)

CreateEntityBody(Entity, #PB_Entity_SphereBody, 0.5, 0, 0.0)

For i = 0 To 100
  If Random(100)>50
    Ent = CreateEntity(#PB_Any, MeshID(CubeMesh), MaterialID(2), 7.5-Random(15), 0.5, 7.5-Random(15))
    CreateEntityBody(Ent, #PB_Entity_BoxBody, 0.1, 0, 0.3)
  Else
    Ent = CreateEntity(#PB_Any, MeshID(CubeMesh), MaterialID(0), 7.5-Random(15), 0.1, 7.5-Random(15))
    CreateEntityBody(Ent, #PB_Entity_BoxBody, 0, 0, 0.3)
  EndIf
Next

SkyBox("stevecube.jpg")

Camera = CreateCamera(#PB_Any, 0, 0, 100, 100)
CameraRange(Camera, 0.01, 50)

CameraFollow(Camera, EntityID(Entity), 180, EntityY(Entity) + 0.3, 1, 1, 1)

CreateLight(0, RGB(155, 155, 155), 330, 500, 330)
AmbientColor(RGB(100, 100, 100))

Repeat
  While WindowEvent():Wend
  
  If ExamineMouse()
    MouseX = -MouseDeltaX() * #CameraSpeed * 0.1
    MouseY = -MouseDeltaY() * #CameraSpeed * 0.05
  EndIf
  
  If ExamineKeyboard()
    
    If KeyboardPushed(#PB_Key_Up)
      Speed1 = 0.2
    ElseIf KeyboardPushed(#PB_Key_Down)
      Speed1 = -0.2
    Else
      Speed1 * 0.9
    EndIf
    
  EndIf
  
  RotateEntity(Entity, 0, MouseX, 0, #PB_Relative)
  MoveEntity(Entity, 0, 0, Speed1, #PB_Local)
  
  CameraFollow(Camera, EntityID(Entity), 180, EntityY(Entity) + 0.2, 0.7, 0.1, 0.1)
  CameraLookAt(Camera, EntityX(Entity), EntityY(Entity), EntityZ(Entity))
  
  If ExamineWorldCollisions(#True) ; get also contacts
    
    While NextWorldCollision()
      
      If FirstWorldCollisionEntity() <> Ground And SecondWorldCollisionEntity() <> Ground
        
        WorldCollisionContact()
        x.f = GetX()
        y.f = GetY()
        z.f = GetZ()
        
        WorldCollisionNormal()
        xn.f = x + GetX() * d
        yn.f = y + GetY() * d
        zn.f = z + GetZ() * d
        
        CreateLine3D(Total, x, y, z, RGB(0, 255, 0), xn ,yn, zn, RGB(0, 255, 0))
        
        total + 1
        
        If total > 200
          
          For i = 0 To Total-1
            FreeMesh(i)
          Next
          total = 0
        EndIf
        
      EndIf
    Wend
    
  EndIf
  
  TimeSinceLastFrame = RenderWorld(50)
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
