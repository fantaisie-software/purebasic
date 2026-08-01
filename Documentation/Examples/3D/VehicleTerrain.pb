
; ------------------------------------------------------------
;
;   PureBasic - VehicleTerrain
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
  
  WheelsEngine.i[4]
  WheelsEngineCount.i
  WheelsSteerable.i[4]
  WheelsSteerableCount.i
  
  EngineBrake.f
  EngineForce.f
  Steering.f
  
  SteeringLeft.i
  SteeringRight.i
EndStructure

Global MaxEngineForce.f = 3000.0
Global MaxEngineBrake.f = 100.0

Global SteeringIncrement.f = 0.5
Global SteeringClamp.f = 23

Global WheelRadius.f = 0.5;
Global WheelWidth.f = 0.4 ;

Global SuspensionStiffness.f = 25.0
Global SuspensionDamping.f =  0.4 * 2.0 * Sqr(suspensionStiffness)
Global SuspensionCompression.f =  0.2 * 2.0 * Sqr(suspensionStiffness)
Global MaxSuspensionTravelCm.f = 400.0;
Global FrictionSlip.f = 1000

Global RollInfluence.f = 0.5
Global SuspensionRestLength.f = 0.6
                                   


Global VECTOR3(CameraStart.Vector3, 0, 25, 0)

Global VECTOR3(CarPosition.Vector3, 15, 3, -15)

Global Vehicle.s_Vehicle


#CUBE_HALF_EXTENTS = 1


Declare BuildVehicle(*Vehicle.s_Vehicle)
Declare HandleVehicle()
Declare ControlVehicle(elapsedTime.f)
Declare InitBlendMaps()
Declare.f Interpolation(x1.f, x2.f, percent.f)


InitEngine3D()
  
InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " VehicleTerrain - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models/", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts/", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures/", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures/nvidia", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Main",#PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Terrain",#PB_3DArchive_FileSystem)
Parse3DScripts()

WorldShadows(#PB_Shadow_Modulative, -1, RGB(105, 105, 105))
;WorldDebug(#PB_World_DebugBody)
;- Light
;
light = CreateLight(#PB_Any ,RGB(190, 190, 190), 400, 120, 100,#PB_Light_Directional)
SetLightColor(light, #PB_Light_SpecularColor, RGB(255*0.4, 255*0.4,255*0.4))
LightDirection(light ,0.55, -0.3, -0.75)
AmbientColor(RGB(255*0.2, 255*0.2,255*0.2))

;- Camera
;
CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0,  800, 400, 80, #PB_Absolute)
CameraBackColor(0, RGB(5, 5, 10))


;- Terrain definition
SetupTerrains(LightID(Light), 600, #PB_Terrain_NormalMapping)
; initialize terrain
CreateTerrain(0, 513, 800, 20, 3, "TerrainGroup", "dat")
; set all texture will be use when terrrain will be constructed
AddTerrainTexture(0,  0, 100, "dirt_grayrocky_diffusespecular.jpg",  "dirt_grayrocky_normalheight.jpg")
AddTerrainTexture(0,  1,  30, "grass_green-01_diffusespecular.jpg", "grass_green-01_normalheight.jpg")
AddTerrainTexture(0,  2, 200, "growth_weirdfungus-03_diffusespecular.jpg", "growth_weirdfungus-03_normalheight.jpg")

; Build terrains
Imported = DefineTerrainTile(0, 0, 0, "terrain513.png", 0, 0)
BuildTerrain(0)

If imported = #True
  InitBlendMaps()
  UpdateTerrain(0)
  
  ; If enabled, it will save the terrain as a (big) cache for a faster load next time the program is executed
  ; SaveTerrain(0, #False)
EndIf
; enable shadow terrain
TerrainRenderMode(0, 0)


;Add Physic
CreateTerrainBody(0, 0.1, 0.0)

; SkyBox
;
SkyBox("desert07.jpg")

BuildVehicle(@Vehicle)

Repeat
  While WindowEvent():Wend
  
  ExamineMouse()
  ExamineKeyboard()
  
  
  handleVehicle()
  ControlVehicle(ElapsedTime/20)
  
  CameraFollow(0, EntityID(Vehicle\Chassis),180, TerrainHeight(0,CameraX(0),CameraZ(0))+2.5, 7, 0.08, 0.08)
  
  ElapsedTime = RenderWorld()
  FlipBuffers()
  
Until KeyboardPushed(#PB_Key_Escape)

End


Procedure Clamp(*var.float, min.f, max.f)
  If *var\f < min
    *var\f = min
  ElseIf *var\f > max
    *var\f = max
  EndIf
EndProcedure

Procedure InitBlendMaps()
  minHeight1.f = 70
  fadeDist1.f = 40
  minHeight2.f = 70
  fadeDist2.f = 15
  ty = 0
   tx = 0
      Size = TerrainTileLayerMapSize(0, tx, ty)
      For y = 0 To Size-1
        For x = 0 To Size-1
          Height.f = TerrainTileHeightAtPosition(0, tx, ty, 1, x, y)
          
          val.f = (Height - minHeight1) / fadeDist1
          Clamp(@val, 0, 1)
          SetTerrainTileLayerBlend(0, tx, ty, 1, x, y, val)
          
          val.f = (Height - minHeight2) / fadeDist2
          Clamp(@val, 0, 1)
          SetTerrainTileLayerBlend(0, tx, ty, 2, x, y, val)
        Next
      Next
      UpdateTerrainTileLayerBlend(0, tx, ty, 1)
      UpdateTerrainTileLayerBlend(0, tx, ty, 2)

EndProcedure

Procedure BuildVehicle(*Vehicle.s_Vehicle)
  Protected.VECTOR3 wheelDirectionCS0,wheelAxleCS,connectionPointCS0
  
  With *Vehicle
    ;reset
    For i = 0 To 3
      
      \WheelsEngine[i] = 0
      \WheelsSteerable[i] = 0
    Next
    \WheelsEngineCount = 2
    \WheelsEngine[0] = 0
    \WheelsEngine[1] = 1
    \WheelsEngine[2] = 2
    \WheelsEngine[3] = 3
    
    \WheelsSteerableCount = 2
    \WheelsSteerable[0] = 0
    \WheelsSteerable[1] = 1
    
    \SteeringLeft = #False
    \SteeringRight = #False
    
    \EngineForce = 0
    \Steering = 0
    
    
    ;- >>> create vehicle  <<<<<
    
    connectionHeight.f = 0.7
    
    ChassisMesh = LoadMesh(#PB_Any, "chassis.mesh")
    ChassisEntity = CreateEntity(#PB_Any, MeshID(chassisMesh), #PB_Material_None, 0, 1.0, 0)
    
    \Chassis = CreateVehicle(#PB_Any)
    AddSubEntity(\Chassis, ChassisEntity, #PB_Entity_BoxBody, 0, 0, 0, 0, 1.0, 0.75, 2.1)
    
    EntityRenderMode(\Chassis, #PB_Entity_CastShadow )
    CreateVehicleBody(\Chassis, 700, 0.3, 0.8,suspensionStiffness, suspensionCompression, suspensionDamping, maxSuspensionTravelCm, frictionSlip)
    
    MoveEntity(\Chassis, 0, 15, 0,#PB_Absolute)
        
    wheelAxleCS\x       = -1
    wheelAxleCS\y       = 0
    wheelAxleCS\z       = 0
        
    Wheel = LoadMesh(#PB_Any, "wheel.mesh")
    For i = 0 To 3
      \Wheels[i] = CreateEntity(#PB_Any, MeshID(Wheel), #PB_Material_None,0,0,0, 32)
    Next
    
    isFrontWheel = #True
    
    ;-WheelSteerable and WheelsEngine
    VECTOR3(connectionPointCS0, #CUBE_HALF_EXTENTS-(0.3*WheelWidth), connectionHeight,2*#CUBE_HALF_EXTENTS-WheelRadius)
    AddVehicleWheel(\Chassis, \Wheels[0],
                    connectionPointCS0\x, connectionPointCS0\y,connectionPointCS0\z,
                    wheelAxleCS\x, wheelAxleCS\y,wheelAxleCS\z,
                    SuspensionRestLength,
                    WheelRadius,
                    isFrontWheel,
                    RollInfluence)
    
    ;-WheelSteerable and WheelsEngine
    VECTOR3(connectionPointCS0, -#CUBE_HALF_EXTENTS+(0.3*WheelWidth), connectionHeight, 2*#CUBE_HALF_EXTENTS-WheelRadius)
    AddVehicleWheel(\Chassis, \Wheels[1],
                    connectionPointCS0\x, connectionPointCS0\y,connectionPointCS0\z,
                    wheelAxleCS\x, wheelAxleCS\y,wheelAxleCS\z,
                    SuspensionRestLength,
                    WheelRadius,
                    isFrontWheel,
                    RollInfluence)
    
    isFrontWheel = #False
    
    VECTOR3(connectionPointCS0, -#CUBE_HALF_EXTENTS+(0.3*WheelWidth), connectionHeight, -2*#CUBE_HALF_EXTENTS+WheelRadius);
    AddVehicleWheel(\Chassis, \Wheels[2],
                    connectionPointCS0\x, connectionPointCS0\y,connectionPointCS0\z,
                    wheelAxleCS\x, wheelAxleCS\y,wheelAxleCS\z,
                    SuspensionRestLength,
                    WheelRadius,
                    isFrontWheel,
                    RollInfluence)
    
    
    VECTOR3(connectionPointCS0, #CUBE_HALF_EXTENTS-(0.3*WheelWidth), connectionHeight, -2*#CUBE_HALF_EXTENTS+WheelRadius);
    AddVehicleWheel(\Chassis, \Wheels[3],
                    connectionPointCS0\x, connectionPointCS0\y,connectionPointCS0\z,
                    wheelAxleCS\x, wheelAxleCS\y,wheelAxleCS\z,
                    SuspensionRestLength,
                    WheelRadius,
                    isFrontWheel,
                    RollInfluence)
    
    For i= 0 To 3
      SetVehicleAttribute(\Chassis, #PB_Vehicle_MaxSuspensionForce, 4000, i)
    Next
    
  EndWith
EndProcedure

Procedure HandleVehicle()
  With Vehicle
    
    
    If KeyboardPushed(#PB_Key_Left)
      \SteeringLeft = #True
      \SteeringRight = #False
    ElseIf KeyboardPushed(#PB_Key_Right)
      \SteeringRight = #True
      \SteeringLeft = #False
    Else
      \SteeringRight = #False
      \SteeringLeft = #False
    EndIf
    
    
    If KeyboardPushed(#PB_Key_Down)
      \EngineForce = 0
      \EngineBrake = MaxEngineBrake
    ElseIf KeyboardPushed(#PB_Key_Up)
      \EngineForce = MaxEngineForce
      \EngineBrake = 0
    Else
      \EngineBrake = 0
      \EngineForce = 0
    EndIf
    
  EndWith
EndProcedure

Procedure ControlVehicle(elapsedTime.f)
  With Vehicle
    
    ; apply engine Force on relevant wheels
    For i = \WheelsEngine[0] To \WheelsEngine[0]+\WheelsEngineCount-1
      ApplyVehicleBrake(\Chassis, \WheelsEngine[i], \EngineBrake)
      ApplyVehicleForce(\Chassis, \WheelsEngine[i], \EngineForce)
    Next
        
    If (\SteeringLeft)
      
      \Steering + SteeringIncrement*elapsedTime
      If (\Steering > SteeringClamp)
        \Steering = SteeringClamp
      EndIf
      
    ElseIf (\SteeringRight)
      
      \Steering - SteeringIncrement*elapsedTime
      If (\Steering < -SteeringClamp)
        \Steering = -SteeringClamp
      EndIf
    Else
      \Steering = Interpolation(\Steering, 0, 0.05)
    EndIf
    
    ; apply Steering on relevant wheels
    
    For i = \WheelsSteerable[0] To \WheelsSteerable[0]+ \WheelsSteerableCount-1
      
      If (i < 2)
        ApplyVehicleSteering(\Chassis, \WheelsSteerable[i], \Steering)
      Else
        ApplyVehicleSteering(\Chassis, \WheelsSteerable[i], -\Steering)
      EndIf
    Next
    
  EndWith
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

