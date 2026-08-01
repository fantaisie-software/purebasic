
; ------------------------------------------------------------
;
;   PureBasic - CreateVehicle
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;


#CameraSpeed = 2

Global.f KeyX, KeyY, MouseX, MouseY, ElapsedTime

Macro VECTOR3(V, a, b, c)
  V\x = a
  V\y = b
  V\z = c
EndMacro

Structure s_Vehicle
  Chassis.i
  Wheels.i[4]
  EngineBrake.f
  EngineForce.f
  Steering.f
  
  SteeringLeft.i
  SteeringRight.i
EndStructure

Global Recul = #False

Global MaxEngineForce.f = 2000.0
Global MaxEngineBrake.f = 150.0

Global SteeringIncrement.f = 0.5
Global SteeringClamp.f = 27

Global WheelRadius.f = 0.5;
Global WheelWidth.f = 0.4 ;

Global SuspensionStiffness.f = 20.0
Global SuspensionDamping.f = 3.3
Global SuspensionCompression.f = 4.4
Global MaxSuspensionTravelCm.f = 500.0;
Global FrictionSlip.f = 20

Global RollInfluence.f = 0.3
Global SuspensionRestLength.f = 0.6;

Global Vehicle.s_Vehicle

#CUBE_HALF_EXTENTS = 1

Declare BuildVehicle(*Vehicle.s_Vehicle)
Declare HandleVehicle()
Declare ControlVehicle(elapsedTime.f)
Declare.f  Interpolation(x1.f, x2.f, percent.f)

InitEngine3D()

InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " CreateVehicle - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Main", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts" , #PB_3DArchive_FileSystem)
Parse3DScripts()

WorldShadows(#PB_Shadow_Modulative, -1, RGB(105, 105, 105))

;- Material
;
CreateMaterial(0, LoadTexture(0, "Wood.jpg"))
GetScriptMaterial(1, "SphereMap/SphereMappedRustySteel")
CreateMaterial(2, LoadTexture(2, "Dirt.jpg"))
ScaleMaterial(2,0.05,0.05)
GetScriptMaterial(3, "Scene/GroundBlend")

;-Ground
;
CreatePlane(0, 500, 500, 5, 5, 5, 5)
CreateEntity(0,MeshID(0),MaterialID(2))
EntityRenderMode(0, 0)
CreateEntityBody(0, #PB_Entity_PlaneBody, 0, 0, 1)

;-Walls
;
CreateCube(1, 1)
CreateEntity(1,MeshID(1),MaterialID(2),0,1, 250)
ScaleEntity(1,500,2,0.5)
CreateEntityBody(1, #PB_Entity_PlaneBody, 0, 0, 1, #PB_Vector_NegativeZ, -1,-1,-1)

CreateEntity(2,MeshID(1),MaterialID(2),0,1, -250)
ScaleEntity(2,500,2,0.5)
CreateEntityBody(2, #PB_Entity_PlaneBody, 0, 0, 1, #PB_Vector_Z, -1,-1,-1)

CreateEntity(3,MeshID(1),MaterialID(2),250,1, 0)
ScaleEntity(3,0.5,2,500)
CreateEntityBody(3, #PB_Entity_PlaneBody, 0, 0, 1, #PB_Vector_NegativeX, -1,-1,-1)

CreateEntity(4,MeshID(1),MaterialID(2),-250,1, 0)
ScaleEntity(4,0.5,2,500)
CreateEntityBody(4, #PB_Entity_PlaneBody, 0, 0, 1, #PB_Vector_X, -1,-1,-1)


CylinderMEsh = CreateCylinder(#PB_Any, 0.5, 2)

For i=-250 To 250 Step 30
  Cylinder = CreateEntity(#PB_Any,MeshID(CylinderMEsh),MaterialID(1), 0, 1, i)
  CreateEntityBody(Cylinder, #PB_Entity_CylinderBody, 0, 0, 1)
Next

;- Light
;
CreateLight(0 ,RGB(190, 190, 190), 400, 120, 100,#PB_Light_Directional)
SetLightColor(0, #PB_Light_SpecularColor, RGB(255*0.4, 255*0.4,255*0.4))
LightDirection(0 ,0.55, -0.3, -0.75)
AmbientColor(RGB(255*0.2, 255*0.2,255*0.2))

;- Camera
;
CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0,  800, 400, 80, #PB_Absolute)

; SkyBox
;
SkyBox("desert07.jpg")

;-
BuildVehicle(@Vehicle)

;-Main
;
Repeat
  While WindowEvent():Wend
  
  ExamineMouse()
  ExamineKeyboard()
  
  HandleVehicle()
  
  ControlVehicle(ElapsedTime/20)
  
  CameraFollow(0, EntityID(Vehicle\Chassis),180, 3.5, 10, 0.1, 0.1)
  
  ElapsedTime = RenderWorld()
  
  FlipBuffers()
  
Until KeyboardPushed(#PB_Key_Escape)


Procedure Clamp(*var.float, min.f, max.f)
  If *var\f < min
    *var\f = min
  ElseIf *var\f > max
    *var\f = max
  EndIf
EndProcedure

Procedure BuildVehicle(*Vehicle.s_Vehicle)
  Protected.VECTOR3 connectionPointCS0; wheelDirectionCS0,wheelAxleCS,
  
  With *Vehicle
    
    \SteeringLeft = #False
    \SteeringRight = #False
    
    \EngineForce = 0
    \Steering = 0
    
    
    ;- >>> create vehicle  <<<<<
    
    connectionHeight.f = 0.6
    
    ChassisMesh = CreateCube(#PB_Any, 2)
    
    ChassisEntity = CreateEntity(#PB_Any, MeshID(chassisMesh), MaterialID(3), 0, 1, 0)
    ScaleEntity(ChassisEntity, 0.8, 0.7, 2)
    \Chassis = CreateVehicle(#PB_Any)
    AddSubEntity(\Chassis, ChassisEntity, #PB_Entity_BoxBody)
    
    EntityRenderMode(\Chassis, #PB_Entity_CastShadow)
    CreateVehicleBody(\Chassis, 700, 0.3, 0.8,suspensionStiffness, suspensionCompression, suspensionDamping, maxSuspensionTravelCm, frictionSlip)
    
    MoveEntity(\Chassis, 0, 3, 0,#PB_Absolute)
    
    SetEntityAttribute(\Chassis, #PB_Entity_LinearDamping, 0.2)
    SetEntityAttribute(\Chassis, #PB_Entity_AngularDamping, 0.2)
    
    Wheel = CreateSphere(#PB_Any, WheelRadius)
    For i = 0 To 3
      \Wheels[i] = CreateEntity(#PB_Any, MeshID(Wheel), #PB_Material_None)
      ScaleEntity(\Wheels[i], WheelWidth,1,1)
    Next
    
    ;-WheelSteerable and WheelsEngine
    VECTOR3(connectionPointCS0, #CUBE_HALF_EXTENTS-(0.2*WheelWidth), connectionHeight,2*#CUBE_HALF_EXTENTS-WheelRadius)
    AddVehicleWheel(\Chassis, \Wheels[0],
                    connectionPointCS0\x, connectionPointCS0\y,connectionPointCS0\z,
                    -1, 0,0, SuspensionRestLength, WheelRadius, #True, RollInfluence)
    
    
    VECTOR3(connectionPointCS0, -#CUBE_HALF_EXTENTS+(0.2*WheelWidth), connectionHeight, 2*#CUBE_HALF_EXTENTS-WheelRadius)
    AddVehicleWheel(\Chassis, \Wheels[1],
                    connectionPointCS0\x, connectionPointCS0\y,connectionPointCS0\z,
                    -1, 0,0, SuspensionRestLength, WheelRadius, #True, RollInfluence)
    
    
    VECTOR3(connectionPointCS0, -#CUBE_HALF_EXTENTS+(0.2*WheelWidth), connectionHeight, -2*#CUBE_HALF_EXTENTS+WheelRadius);
    AddVehicleWheel(\Chassis, \Wheels[2],
                    connectionPointCS0\x, connectionPointCS0\y,connectionPointCS0\z,
                    -1, 0,0, SuspensionRestLength, WheelRadius, #False, RollInfluence)
    
    
    VECTOR3(connectionPointCS0, #CUBE_HALF_EXTENTS-(0.2*WheelWidth), connectionHeight, -2*#CUBE_HALF_EXTENTS+WheelRadius);
    AddVehicleWheel(\Chassis, \Wheels[3],
                    connectionPointCS0\x, connectionPointCS0\y,connectionPointCS0\z,
                    -1, 0,0, SuspensionRestLength, WheelRadius, #False, RollInfluence)
    
    
  EndWith
EndProcedure

Procedure HandleVehicle()
  
  If KeyboardPushed(#PB_Key_Left)
    Vehicle\SteeringLeft = #True
    Vehicle\SteeringRight = #False
    
  ElseIf KeyboardPushed(#PB_Key_Right)
    Vehicle\SteeringRight = #True
    Vehicle\SteeringLeft = #False
  Else
    Vehicle\SteeringRight = #False
    Vehicle\SteeringLeft = #False
  EndIf
  
  If KeyboardPushed(#PB_Key_Down)
    If GetEntityAttribute(Vehicle\Chassis, #PB_Entity_LinearVelocity)< 0.4
      Recul = #True
    EndIf
    If Recul
      Vehicle\EngineForce = -MaxEngineForce
      Vehicle\EngineBrake = 0
    Else
      Vehicle\EngineForce = 0
      Vehicle\EngineBrake = MaxEngineBrake
    EndIf
  ElseIf KeyboardPushed(#PB_Key_Up)
    Vehicle\EngineForce = MaxEngineForce
    Vehicle\EngineBrake = 0
  Else
    Vehicle\EngineBrake = MaxEngineForce/ 100
    Vehicle\EngineForce = 0
    Recul = #False
  EndIf
  
  
EndProcedure

Procedure ControlVehicle(elapsedTime.f)
  
  ; apply engine Force on relevant wheels
  For i = 0 To 1
    ApplyVehicleBrake(Vehicle\Chassis, i, Vehicle\EngineBrake)
    ApplyVehicleForce(Vehicle\Chassis, i, Vehicle\EngineForce)
  Next
  
  
  If (Vehicle\SteeringLeft)
    
    Vehicle\Steering + SteeringIncrement*elapsedTime
    If (Vehicle\Steering > SteeringClamp)
      Vehicle\Steering = SteeringClamp
    EndIf
    
  ElseIf (Vehicle\SteeringRight)
    
    Vehicle\Steering - SteeringIncrement*elapsedTime
    If (Vehicle\Steering < -SteeringClamp)
      Vehicle\Steering = -SteeringClamp
    EndIf
    
  Else
    Vehicle\Steering = Interpolation(Vehicle\Steering, 0, 0.05)
    
  EndIf
  
  ; apply Steering on relevant wheels
  
  For i = 0 To 1
    ApplyVehicleSteering(Vehicle\Chassis, i, Vehicle\Steering)
  Next
  
EndProcedure

Procedure.f Interpolation(x1.f, x2.f, percent.f)
  If percent<0
    percent=0
  EndIf
  If percent>1
    percent=1
  EndIf
  ProcedureReturn x1 + percent * (x2 - x1)
  
EndProcedure


