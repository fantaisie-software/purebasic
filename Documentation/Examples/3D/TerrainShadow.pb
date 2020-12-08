;
; ------------------------------------------------------------
;
;   PureBasic - Terrain : Shadow
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

#CameraSpeed = 2
#TerrainMiniX = 0
#TerrainMiniY = 0
#TerrainMaxiX = 0
#TerrainMaxiY = 0
Define.f KeyX, KeyY, MouseX, MouseY

Procedure Clamp(*var.float, min.f, max.f)
  If *var\f < min
    *var\f = min
  ElseIf *var\f > max
    *var\f = max
  EndIf
EndProcedure

; OpenGL needs to have CG enabled to work (Linux and OS X have OpenGL by default)
;
CompilerIf #PB_Compiler_OS <> #PB_OS_Windows Or Subsystem("OpenGL")
  Flags = #PB_Engine3D_EnableCG
CompilerEndIf

If InitEngine3D(Flags)
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures/"       , #PB_3DArchive_FileSystem)
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures/nvidia" , #PB_3DArchive_FileSystem)
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts"         , #PB_3DArchive_FileSystem)
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/GUI"           , #PB_3DArchive_FileSystem)
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
    Parse3DScripts()
    
    WorldShadows(#PB_Shadow_Modulative, #PB_Default, RGB(105, 105, 105))
    
    ;- Light 
    ;
    light = CreateLight(#PB_Any ,RGB(255, 255, 255), 4000, 1200, 1000,#PB_Light_Directional)
    SetLightColor(light, #PB_Light_SpecularColor, RGB(255*0.4, 255*0.4,255*0.4)) 
    LightDirection(light ,0.55, -0.3, -0.75) 
    AmbientColor(RGB(255*0.2, 255*0.2,255*0.2))
        
    ;- Camera 
    ;
    CreateCamera(0, 0, 0, 100, 100)
    MoveCamera(0,  800, 400, 80, #PB_Absolute)
    CameraBackColor(0, RGB(5, 5, 10))
    
    
    ;----------------------------------
    ; terrain definition
    SetupTerrains(LightID(Light), 3000, #PB_Terrain_NormalMapping)
    ; initialize terrain 
    CreateTerrain(0, 513, 12000, 600, 4, "TerrainShadow", "dat")
    ; set all texture will be use when terrrain will be constructed 
    AddTerrainTexture(0,  0, 100, "dirt_grayrocky_diffusespecular.jpg",  "dirt_grayrocky_normalheight.jpg")
    AddTerrainTexture(0,  1,  30, "grass_green-01_diffusespecular.jpg", "grass_green-01_normalheight.jpg")
    AddTerrainTexture(0,  2, 200, "growth_weirdfungus-03_diffusespecular.jpg", "growth_weirdfungus-03_normalheight.jpg")
    
    ; construct terrains
    For ty = #TerrainMiniY To #TerrainMaxiY
      For tx = #TerrainMiniX To #TerrainMaxiX
        DefineTerrainTile(0, tx, ty, "terrain513.png", ty % 2, tx % 2)  
      Next
    Next  
    BuildTerrain(0)  
    
    ;InitBlendMaps
    minHeight1.f = 70
    fadeDist1.f = 40
    minHeight2.f = 70
    fadeDist2.f = 15    
    For ty = #TerrainMiniY To #TerrainMaxiY
      For tx = #TerrainMiniX To #TerrainMaxiX
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
      Next
    Next  
    
    ; enable shadow terrain
    TerrainRenderMode(0, 0)
        
    ; create sphere for test
    CreateSphere(1, 20.0, 50, 50)
    Global ball =CreateEntity(#PB_Any, MeshID(1), #Null)
    MoveEntity(ball, 300,60,0, #PB_Absolute)
    EntityRenderMode(ball, #PB_Entity_CastShadow)
    
    ; SkyBox
    ;
    SkyBox("desert07.jpg")
    
    ShowGUI(128, 1) ; Display the GUI, semi-transparent and display the mouse cursor
    
    Repeat
      Screen3DEvents()
      
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
        
      EndIf
      
      If ExamineMouse()
        MouseX = -MouseDeltaX() * #CameraSpeed * 0.05
        MouseY = -MouseDeltaY() * #CameraSpeed * 0.05
        
        InputEvent3D(MouseX(), MouseY(), MouseButton(#PB_MouseButton_Left))
        
        If MouseButton(#PB_MouseButton_Left)
          TerrainMousePick(0,  CameraID(0), MouseX(),  MouseY())
          MoveEntity(ball, PickX(), PickY()+20, PickZ(), #PB_Absolute)
        EndIf
        
      EndIf
      ;CameraLocate(0, CameraX(0), PBO_GetTerrainHeight(0, CameraX(0), CameraZ(0)) + 20, CameraZ(0))
      MoveCamera  (0, KeyX, 0, KeyY)
      RotateCamera(0,  MouseY, MouseX, 0, #PB_Relative)  
      
      RenderWorld()
      FlipBuffers()
      
    Until KeyboardPushed(#PB_Key_Escape)   
    
    End 
    
  EndIf 
Else
  CompilerIf #PB_Compiler_OS <> #PB_OS_Windows Or Subsystem("OpenGL")
    ;
    ; Terrain on Linux/OSX and Windows with OpenGL needs CG toolkit from nvidia
    ; It can be freely downloaded and installed from this site: https://developer.nvidia.com/cg-toolkit-download
    ;
    MessageRequester("Error","Can't initialize engine3D (Please ensures than CG Toolkit from nvidia is correcly installed)")
  CompilerElse
    MessageRequester("Error","Can't initialize engine3D")
  CompilerEndIf
EndIf 
