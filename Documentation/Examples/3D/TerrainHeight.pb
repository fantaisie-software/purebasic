
; ------------------------------------------------------------
;
;   PureBasic - Terrain : Terrain Height change
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

; Use left button to select an area, then use PageUp or PageDown to change terrain's height
; Use [F5] to init BlendMaps



#CameraSpeed = 1
#TerrainMiniX = 0
#TerrainMiniY = 0
#TerrainMaxiX = 0
#TerrainMaxiY = 0

#NbSommet = 36

Define.f KeyX, KeyY, MouseX, MouseY, TimeSinceLastFrame
Define Selected

Declare InitBlendMaps()
Declare Clamp(*var.float, min.f, max.f)
Declare DisplayPolygon(Px.f, Py.f, Pz.f, Rayon.f)
Declare DoTerrainModify(tx, ty, wx.f, wy.f, wz.f, mBrushSizeTerrainSpace.f, height.f)

InitEngine3D()

InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), "RealTime Terrain Change - [MouseClick] [F5] [PageUp]/[PageDown] [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures/", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures/nvidia", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/GUI", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Main",#PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Terrain",#PB_3DArchive_FileSystem)
Parse3DScripts()

;- Light
;

light = CreateLight(#PB_Any ,RGB(185, 185, 185), 4000, 1200, 1000, #PB_Light_Directional)
SetLightColor(light, #PB_Light_SpecularColor, RGB(255*0.4, 255*0.4,255*0.4))
LightDirection(light ,0.55, -0.3, -0.75)
AmbientColor(RGB(5, 5,5))

;- Camera
;
CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0,  0, 500, -50, #PB_Absolute)
CameraRange(0, 1, 0)

;----------------------------------
; terrain definition
SetupTerrains(LightID(Light), 3000, #PB_Terrain_NormalMapping)
; initialize terrain
CreateTerrain(0, 513, 12000, 600, 3, "TerrainHeight", "dat")
; set all texture will be use when terrrain will be constructed
AddTerrainTexture(0,  0, 100, "dirt_grayrocky_diffusespecular.jpg",  "dirt_grayrocky_normalheight.jpg")
AddTerrainTexture(0,  1,  30, "grass_green-01_diffusespecular.jpg", "grass_green-01_normalheight.jpg")
AddTerrainTexture(0,  2, 200, "growth_weirdfungus-03_diffusespecular.jpg", "growth_weirdfungus-03_normalheight.jpg")

;- define terrains
For ty = #TerrainMiniY To #TerrainMaxiY
  For tx = #TerrainMiniX To #TerrainMaxiX
    Imported = DefineTerrainTile(0, tx, ty, "terrain513.png", ty % 2, tx % 2)
  Next
Next
BuildTerrain(0)

If Imported = #True
  InitBlendMaps()
  UpdateTerrain(0)
  
  ; If enabled, it will save the terrain as a (big) cache for a faster load next time the program is executed
  ; SaveTerrain(0, #False)
EndIf

; SkyBox
;
SkyBox("desert07.jpg")

ShowGUI(128, 1)

Repeat
  
  While WindowEvent():Wend
  
  If ExamineMouse()
    MouseX = -(MouseDeltaX()/10)
    MouseY = -(MouseDeltaY()/10)
    InputEvent3D(MouseX(), MouseY(), MouseButton(#PB_MouseButton_Left), "F", 0)
    
    TerrainMousePick(0, CameraID(0), MouseX(),  MouseY())
    
    If MouseButton(#PB_MouseButton_Left)
      ShowGUI(128, 1)
      DisplayPolygon(PickX(), PickY(), PickZ(), 50)
      Selected = #True
    Else
      ShowGUI(128, 0)
      MoveCamera  (0, KeyX, 0, KeyY)
      DisplayPolygon(PickX(), PickY(), PickZ(), 0)
      Selected = #False
      If CameraY(0) < TerrainHeight(0, CameraX(0), CameraZ(0)) + 10
        MoveCamera(0, CameraX(0), TerrainHeight(0, CameraX(0), CameraZ(0)) + 10, CameraZ(0), #PB_Absolute)
      EndIf
      RotateCamera(0,  MouseY, MouseX, 0, #PB_Relative)
      
    EndIf
    
  EndIf
  
  If ExamineKeyboard()
    If KeyboardReleased(#PB_Key_F5)
      InitBlendMaps()
    EndIf
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
    
    Modify = 0
    If KeyboardPushed(#PB_Key_PageUp)
      Modify = 1
    ElseIf  KeyboardPushed(#PB_Key_PageDown)
      Modify = -1
    EndIf
  EndIf
  
  If Modify And Selected
      
    For ty = #TerrainMiniY To #TerrainMaxiY
      For tx = #TerrainMiniX To #TerrainMaxiX
        DoTerrainModify(tx, ty, PickX(), PickY(), PickZ(), 0.02, TimeSinceLastFrame * Modify)
      Next
    Next
    UpdateTerrain(0)
  EndIf
  
  TimeSinceLastFrame = RenderWorld() * 0.2 / 1000
  FlipBuffers()
  
Until KeyboardPushed(#PB_Key_Escape)

End


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

Procedure Clamp(*var.float, min.f, max.f)
  If *var\f < min
    *var\f = min
  ElseIf *var\f > max
    *var\f = max
  EndIf
EndProcedure

Procedure.f Min(a.f, b.f)
  If a < b
    ProcedureReturn a
  Else
    ProcedureReturn b
  EndIf
EndProcedure

Procedure.f Max(a.f, b.f)
  If a > b
    ProcedureReturn a
  Else
    ProcedureReturn b
  EndIf
EndProcedure

Procedure DoTerrainModify(tx, ty, wx.f, wy.f, wz.f, mBrushSizeTerrainSpace.f, TimeElapsed.f)
  terrainSize.f = TerrainTileSize(0, tx, ty) - 1
  Pointx.f = TerrainTilePointX(0, tx, ty, wx, wy, wz)
  Pointy.f = TerrainTilePointY(0, tx, ty, wx, wy, wz)
  
  startx = (Pointx - mBrushSizeTerrainSpace) * terrainSize
  starty = (Pointy - mBrushSizeTerrainSpace) * terrainSize
  endx   = (Pointx + mBrushSizeTerrainSpace) * terrainSize
  endy   = (Pointy + mBrushSizeTerrainSpace) * terrainSize
  startx = Max(startx, 0)
  starty = Max(starty, 0)
  endx   = Min(endx, terrainSize)
  endy   = Min(endy, terrainSize)
  
  For y = starty To endy
    For x = startx To endx
      
      tsXdist.f = (x / terrainSize) - Pointx
      tsYdist.f = (y / terrainSize) - Pointy
      
      weight.f = Min(1.0,	Sqr(tsYdist * tsYdist + tsXdist * tsXdist) / (0.5 * mBrushSizeTerrainSpace))
      weight = 1.0 - (weight * weight)
      addedHeight.f = weight * 250.0 * TimeElapsed
      
      newheight.f = GetTerrainTileHeightAtPoint(0, tx, ty, x, y) + addedHeight
      SetTerrainTileHeightAtPoint(0, tx, ty, x, y, newheight)
      
    Next x
  Next y
EndProcedure

Procedure DisplayPolygon(Px.f, Py.f, Pz.f, Rayon.f)
  Define.l i, Color = RGB(255, 255, 0)
  Define.f Angle, Sx, Sy, Sz, Sx1, Sy1, Sz1, Py1, Delta = 2
  
  For i = 0 To #NbSommet-2
    Sx = Cos(Angle) * Rayon
    Sz = Sin(Angle) * Rayon
    Angle + 2.0 * #PI / #NbSommet
    Sx1 = Cos(Angle) * Rayon
    Sz1 = Sin(Angle) * Rayon
    Py = TerrainHeight(0, Px + Sx, Pz + Sz) + Delta
    Py1 = TerrainHeight(0, Px + Sx1, Pz + Sz1) + Delta
    CreateLine3D(i, Px + Sx, Py, Pz + Sz, Color, Px + Sx1, Py1, Pz + Sz1, Color)
  Next i
  Py = TerrainHeight(0, Px + Cos(0) * Rayon, Pz + Sin(0) * Rayon) + Delta
  CreateLine3D(i, Px + Sx1, Py1, Pz + Sz1, Color, Px + Cos(0) * Rayon, Py, Pz + Sin(0) * Rayon, Color)
EndProcedure
