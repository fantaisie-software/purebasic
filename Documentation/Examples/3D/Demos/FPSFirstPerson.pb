;
; ------------------------------------------------------------
;
;   PureBasic - FPS First Person
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
; WaterWorld files come from the software Deled
; http://www.delgine.com, Thanks For this great editor 3D.


Procedure.f clamp(V.f, i.f, s.f)
    If V < i :v=i:EndIf
    If V > s :v=s:EndIf
    ProcedureReturn V
EndProcedure

Dim Barrel.Vector3(2)
Barrel(0)\x =  0 : Barrel(0)\y =  0 : Barrel(0)\z = 0
Barrel(1)\x = 60 : Barrel(1)\y =  0 : Barrel(1)\z = 0
Barrel(2)\x = 30 : Barrel(2)\y = 70 : Barrel(2)\z = 0

UsePNGImageDecoder()

InitEngine3D()
InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), "FPS First Person - [Arrows]  [Space]  [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)


;- AddArchive
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures"            , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models"              , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts"             , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/waterworld.zip", #PB_3DArchive_Zip)
Parse3DScripts()

;- Material
CreateMaterial(0, LoadTexture(0, "r2skin.jpg"))
GetScriptMaterial(3, "Color/Red")
CreateMaterial(4, LoadTexture(4, "RustyBarrel.png"))

;- Aim
LoadSprite(0, #PB_Compiler_Home + "examples/3d/Data/Textures/viseur-jeux.png", #PB_Sprite_AlphaBlending)
ZoomSprite(0, ScreenHeight()/16, ScreenHeight()/16)

;- Bullet
CreateSphere(3,10)

;- Robot Body
LoadMesh   (0, "robot.mesh")
CreateEntity(0, MeshID(0), #PB_Material_None, -400, 300, -100)
HideEntity(0, 1)

;- Ground
LoadMesh(2, "waterworld.mesh")
CreateEntity(2, MeshID(2), #PB_Material_None)


;- Barrel
LoadMesh(4, "Barrel.mesh")
Restore Barrel
For i = 1 To 3
  Read.f x.f
  Read.f y.f
  Read.f z.f
  For j=0 To 2
    Barrel = CreateEntity(#PB_Any, MeshID(4), MaterialID(4), x+Barrel(j)\x, y+Barrel(j)\y, z+Barrel(j)\z)
    ScaleEntity(Barrel, 8, 10, 8)
    CreateEntityBody(Barrel, #PB_Entity_CylinderBody, 5, 0, 0.5)
  Next
Next

;- Camera
CreateCamera(0, 0, 0, 100, 100)

;- Light
CreateLight(0, RGB(255, 255, 255), 200, 100, 200, #PB_Light_Point)

;- Fog
;Fog(RGB(127, 127, 127), 128, 10, 2000)

;- Water
CreateShaderMaterial(8,#PB_Material_WaterShader)
MaterialShaderTexture(8,LoadTexture(8,"waternormal.png"),0,0,0)
SetMaterialColor(8,2,$66332200)
SetMaterialColor(8,4,$ffaa8866)
MaterialShininess(8,64)
ScaleMaterial(8,20,20)
MaterialFilteringMode(8,#PB_Material_Anisotropic,4)
MaterialBlendingMode(8,#PB_Material_AlphaBlend)
CreatePlane(8,4000,4000,16,16,1,1)
CreateEntity(-1,MeshID(8),MaterialID(8),0,-250,0)


#Gravity = 500
WorldGravity(-#Gravity)
;Body
CreateEntityBody(0, #PB_Entity_ConvexHullBody, 0.45,0,0)
CreateEntityBody(2, #PB_Entity_StaticBody)

CreateNode(0):AttachEntityObject(0,"",NodeID(0))
AttachNodeObject(0,CameraID(0))

Procedure EntityOnGround(entity)
  ;CreateLine3D(100,EntityX(entity),  EntityY(entity)+50, EntityZ(entity),$ffffff, EntityX(entity), EntityY(entity)-10,  EntityZ(entity),$ff)
  ;Debug ""+EntityX(entity)+"   "+  EntityY(entity)+"   "+ EntityZ(entity)
  ProcedureReturn RayCollide(EntityX(entity),  EntityY(entity)+50, EntityZ(entity), EntityX(entity), EntityY(entity)-30,  EntityZ(entity))
EndProcedure

#PlayerSpeed = 300 ; units per second
#ShootSpeed  = 1600 ; units per second
#ShootMass   = 0.3
Procedure main()
  Protected.Vector3 Dir, Start, Target, Hand
  Protected.f Length, FlightTime, fov
  Protected.f anglex, angleY
  Static Jump.f, MemJump.i, Rot.Vector3, Trans.Vector3, Clic
  
Repeat
  While WindowEvent():Wend      
  ;Robot\elapsedTime = Engine3DStatus(#PB_Engine3D_CurrentFPS)
  
  ExamineKeyboard()
  ExamineMouse()
  
  If MouseButton(#PB_MouseButton_Left)
    If Clic = 0
      Clic = 1
      ; Point under the aim: cast a ray from the camera (past the robot) through the screen center
      PointPick(0, ScreenWidth() / 2, ScreenHeight() / 2)
      Dir\x = PickX() : Dir\y = PickY() : Dir\z = PickZ()
      Start\x = CameraX(0) + Dir\x * (distance + 30)
      Start\y = CameraY(0) + Dir\y * (distance + 30)
      Start\z = CameraZ(0) + Dir\z * (distance + 30)
      If RayCollide(Start\x, Start\y, Start\z, Start\x + Dir\x * 5000, Start\y + Dir\y * 5000, Start\z + Dir\z * 5000) >= 0
        Target\x = PickX() : Target\y = PickY() : Target\z = PickZ()
      Else
        Target\x = Start\x + Dir\x * 5000 : Target\y = Start\y + Dir\y * 5000 : Target\z = Start\z + Dir\z * 5000
      EndIf

      ; Fire from the hand toward that point, aiming a bit higher to compensate the gravity drop
      Hand\x = EntityBoneX(0,"Joint18") : Hand\y = EntityBoneY(0,"Joint18") : Hand\z = EntityBoneZ(0,"Joint18")
      Dir\x = Target\x - Hand\x : Dir\y = Target\y - Hand\y : Dir\z = Target\z - Hand\z
      Length = Sqr(Dir\x * Dir\x + Dir\y * Dir\y + Dir\z * Dir\z)
      If Length > 0
        Dir\x / Length : Dir\y / Length : Dir\z / Length
        FlightTime = Length / #ShootSpeed
        Shoot = CreateEntity(#PB_Any, MeshID(3), MaterialID(3), Hand\x + Dir\x * 20, Hand\y + Dir\y * 20, Hand\z + Dir\z * 20)
        CreateEntityBody(Shoot, #PB_Entity_SphereBody, #ShootMass)
        ApplyEntityImpulse(Shoot, Dir\x * #ShootSpeed * #ShootMass, (Dir\y * #ShootSpeed + 0.5 * #Gravity * FlightTime) * #ShootMass, Dir\z * #ShootSpeed * #ShootMass)
      EndIf
    EndIf
  Else
    Clic = 0
  EndIf
  
  fov=clamp(fov+MouseButton(#PB_MouseButton_Right)*-4+2,20,50)
  CameraFOV(0,fov)
  
  distance=clamp(distance-MouseWheel()*10,0,100)
  MoveCamera(0,-distance+10,70,0,#PB_Absolute|#PB_Parent)
  
  angley=clamp(angleY -MouseDeltaY() *0.1,-80,80)
  angleX -MouseDeltaX() *0.1
  RotateCamera(0,  angley,-90,0,#PB_Absolute)
  RotateEntity(0,  0,angleX,0,#PB_Absolute)
  
  OnGround=EntityOnGround(0)
  
  ; MoveEntity() sets the body velocity, so keep the vertical one computed by the physics (gravity, slopes)
  vity = GetEntityAttribute(0, #PB_Entity_LinearVelocityY)
  If OnGround>=0
    vitx = (KeyboardPushed(#PB_Key_Right)-KeyboardPushed(#PB_Key_Left))*#PlayerSpeed/2
    vitz = (KeyboardPushed(#PB_Key_Down)-KeyboardPushed(#PB_Key_Up))*#PlayerSpeed
    If KeyboardPushed(#PB_Key_Space):vity = 300:EndIf
  EndIf
  
  MoveEntity(0, -vitz, vity, vitx, #PB_Relative|#PB_Local)

  If (vitx Or vitz) And onground>=0
    If EntityAnimationStatus(0, "Walk") = #PB_EntityAnimation_Stopped:StartEntityAnimation(0, "Walk", #PB_EntityAnimation_Manual):EndIf
    AddEntityAnimationTime(0, "Walk", TimeSinceLastFrame)
  Else
    StopEntityAnimation(0, "Walk")
  EndIf
    
  TimeSinceLastFrame=RenderWorld()
  DisplayTransparentSprite(0, (ScreenWidth()-SpriteWidth(0))/2, (ScreenHeight()-SpriteHeight(0))/2)
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
EndProcedure

main()

DataSection
  Barrel:
  Data.f -885, 300, 158
  Data.f -800, 60, -1580
  Data.f -710, 60, -1270
EndDataSection
