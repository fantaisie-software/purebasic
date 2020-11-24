﻿;
; ------------------------------------------------------------
;
;   PureBasic - RayCollide CollisionFilter
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#CameraSpeed = 1
#Speed = 60

#COL_Sphere   	= 1 << 6
#COL_Box      		= 1 << 7
#COL_Cylinder 	= 1 << 8
#COL_Ground   	= 1 << 9
#COL_Ray   			= 1 << 10

#SphereCollidesWith   = #COL_Ray | #COL_Ground | #COL_Box    | #COL_Cylinder
#BoxCollidesWith      	= #COL_Ray | #COL_Ground | #COL_Sphere | #COL_Cylinder
#CylinderCollidesWith 	= #COL_Ray | #COL_Ground | #COL_Sphere | #COL_Box
#GroundCollidesWith   = #COL_Ray | #COL_Sphere | #COL_Box    | #COL_Cylinder
#RayCollidesWith   		= #COL_Sphere | #COL_Cylinder ; Ray dont collide with Box !

Enumeration
  #MainWindow
  #Editor
EndEnumeration

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

Define.f KeyX, KeyY, MouseX, MouseY, RatioX, RatioY, d = 200
Define.f x1,y1,z1,x2,y2,z2

Define.i Shoot

If InitEngine3D()
  
  InitSprite()
  InitKeyboard()
  InitMouse()

  If Screen3DRequester()
    
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/GUI", #PB_3DArchive_FileSystem)
    Parse3DScripts()
   
    ;- Materials
    GetScriptMaterial(0, "Color/Blue")
    GetScriptMaterial(1, "Color/Green")
    GetScriptMaterial(2, "Color/Red")
    GetScriptMaterial(3, "Color/Yellow")
    CreateMaterial(4, LoadTexture(0, "Dirt.jpg"))
    
    ;- Meshes
    CreateCube(0, 2)
    CreateSphere(1, 1)
    CreateCylinder(2, 1, 4)
    
    ;- Entities
    CreateEntity(0, MeshID(0), MaterialID(0),  4,  1.0, 0)
    CreateEntity(1, MeshID(1), MaterialID(1), -4,  0.5, 0)
    CreateEntity(2, MeshID(2), MaterialID(2),  0, -1.0, 0)
    CreateEntity(4, MeshID(0), MaterialID(4),  0, -4.0, 0)
    ScaleEntity(4, 5, 0.5, 5)
    
    ;- Body
    CreateEntityBody(0, #PB_Entity_BoxBody, 1)
    CreateEntityBody(1, #PB_Entity_SphereBody, 1)
    CreateEntityBody(2, #PB_Entity_CylinderBody, 1)
    CreateEntityBody(4, #PB_Entity_BoxBody, 0)
    
    ;-Filter
    SetEntityCollisionFilter(0, #COL_Box     , #BoxCollidesWith)
    SetEntityCollisionFilter(1, #COL_Sphere  , #SphereCollidesWith)
    SetEntityCollisionFilter(2, #COL_Cylinder, #CylinderCollidesWith)
    SetEntityCollisionFilter(4, #COL_Ground  , #GroundCollidesWith)
    
    ;- Camera
    CreateCamera(0, 0, 0, 100, 100)
    MoveCamera(0, -1, 8, 25, #PB_Absolute)
    CameraLookAt(0, -1, 0, 0)
    
    ;- Light
    CreateLight(0, $FFFFFF, 1560, 900, 500)
    AmbientColor($330000)
    
    ;- GUI
    RatioX = CameraViewWidth(0) / 1920
    RatioY = CameraViewHeight(0) / 1080
    OpenWindow3D(#MainWindow, 0, 0, 550 * RatioX, 110 * RatioY, "RayCollide CollisionFilter")
    StringGadget3D(#Editor, 10 * RatioX, 20 * RatioY, 470 * RatioX, 40 * RatioY, "Clic somewhere", #PB_String3D_ReadOnly)
    
    ShowGUI(128, 1) ; Display the GUI, semi-transparent and display the mouse cursor
    
    Repeat
      Screen3DEvents()
      
      Repeat
        Event3D = WindowEvent3D()
      Until Event3D = 0
      
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
          KeyX = 0
        EndIf
        
        If KeyboardPushed(#PB_Key_Up)
          KeyY = -#CameraSpeed
        ElseIf KeyboardPushed(#PB_Key_Down)
          KeyY = #CameraSpeed
        Else
          KeyY = 0
        EndIf
        
        If KeyboardReleased(#PB_Key_F3)
          ;-Check RayCollide with cylinder
          x1 = 0
          y1 = -2
          z1 = -4
          x2 = 0
          y2 = -2
          z2 = 4
          CreateLine3D(3, x1,y1,z1,RGB(255,0,0),x2,y2,z2,RGB(255,0,0))
        ElseIf KeyboardReleased(#PB_Key_F4)
          ;-Check RayCollide with box
          x1 = 4
          y1 = -2
          z1 = -4
          x2 = 4
          y2 = -2
          z2 = 4
          CreateLine3D(3, x1,y1,z1,RGB(255,0,0),x2,y2,z2,RGB(255,0,0))
        EndIf
        
        
      EndIf
      
      Entity = RayCollide(x1,y1,z1,x2,y2,z2, #COL_Ray, #RayCollidesWith)
      If Entity = -1
        Text$ = "Nothing"
      Else
        Text$ = "Entity = " + Str(Entity)
      EndIf
      
      SetGadgetText3D(#Editor, Text$)
      
      RotateCamera(0, MouseY, MouseX, 0, #PB_Relative)
      MoveCamera  (0, KeyX, 0, KeyY)
      
      RenderWorld()
      Screen3DStats()
      FlipBuffers()
    Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
  EndIf
  
Else
  MessageRequester("Error", "The 3D Engine can't be initialized",0)
EndIf

End