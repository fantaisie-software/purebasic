
; ------------------------------------------------------------
;
;   PureBasic - Terrain : Create 9 terrains in one TerrainGroup
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#CameraSpeed = 2
#TerrainMiniX = 0
#TerrainMiniY = 0
#TerrainMaxiX = 0
#TerrainMaxiY = 0

Define.f KeyX, KeyY, MouseX, MouseY
Declare InitBlendMaps()

InitEngine3D()

InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), "Terrain - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures/", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures/nvidia", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Main",#PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Terrain",#PB_3DArchive_FileSystem)
Parse3DScripts()


;- Light
;
light = CreateLight(#PB_Any ,RGB(190, 190, 190), 4000, 1200, 1000,#PB_Light_Directional)
SetLightColor(light, #PB_Light_SpecularColor, RGB(255*0.4, 255*0.4,255*0.4))
LightDirection(light ,0.55, -0.3, -0.75)
AmbientColor(RGB(255*0.2, 255*0.2,255*0.2))

;- Camera
;
CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0,  800, 400, 80, #PB_Absolute)
CameraBackColor(0, RGB(5, 5, 10))


;- Terrain definition
SetupTerrains(LightID(Light), 3000, #PB_Terrain_NormalMapping)
; initialize terrain
CreateTerrain(0, 513, 12000, 600, 3, "TerrainGroup", "dat")
; set all texture will be use when terrrain will be constructed
AddTerrainTexture(0,  0, 100, "dirt_grayrocky_diffusespecular.jpg",  "dirt_grayrocky_normalheight.jpg")
AddTerrainTexture(0,  1,  30, "grass_green-01_diffusespecular.jpg", "grass_green-01_normalheight.jpg")
AddTerrainTexture(0,  2, 200, "growth_weirdfungus-03_diffusespecular.jpg", "growth_weirdfungus-03_normalheight.jpg")

; Build terrains
For ty = #TerrainMiniY To #TerrainMaxiY
  For tx = #TerrainMiniX To #TerrainMaxiX
    Imported = DefineTerrainTile(0, tx, ty, "terrain513.png", ty % 2, tx % 2)
  Next
Next
BuildTerrain(0)

If imported = #True
  InitBlendMaps()
  UpdateTerrain(0)
  
  ; If enabled, it will save the terrain as a (big) cache for a faster load next time the program is executed
  ; SaveTerrain(0, #False)
EndIf

; SkyBox
;
SkyBox("desert07.jpg")

Repeat
  While WindowEvent():Wend
  
  If ExamineKeyboard()
    
    KeyX = (KeyboardPushed(#PB_Key_Right)-KeyboardPushed(#PB_Key_Left))*#CameraSpeed
    Keyy = (KeyboardPushed(#PB_Key_Down)-KeyboardPushed(#PB_Key_Up)-MouseWheel()*50)*#CameraSpeed
    
  EndIf
  
  If ExamineMouse()
    MouseX = -MouseDeltaX() * #CameraSpeed * 0.05
    MouseY = -MouseDeltaY() * #CameraSpeed * 0.05
  EndIf
  MoveCamera(0, CameraX(0), TerrainHeight(0, CameraX(0), CameraZ(0)) + 20, CameraZ(0), #PB_Absolute)
  MoveCamera  (0, KeyX, 0, KeyY)
  RotateCamera(0,  MouseY, MouseX, 0, #PB_Relative)
  
  RenderWorld()
  FlipBuffers()
  
Until KeyboardPushed(#PB_Key_Escape)


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
EndProcedure

