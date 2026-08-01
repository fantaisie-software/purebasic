
; ------------------------------------------------------------
;
;   PureBasic - VisibilityMask
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;



Define.f KeyX, KeyY, MouseX, MouseY, SpriteX, SpriteY

LoadFont(0, "Verdana", 24, #PB_Font_Bold)

#Mask1 = 1 << 0
#Mask2 = 1 << 1
#Mask3 = 1 << 2

Macro CreateTexture2(No, Color, Texte)
  CreateTexture(No, 256, 256)
  StartDrawing(TextureOutput(No))
  Box(0, 0, 256, 256, Color)
  DrawingMode(#PB_2DDrawing_Transparent)
  DrawingFont(FontID(0))
  DrawText(30, 128, Texte, RGB(255, 255, 255))
  StopDrawing()
EndMacro

InitEngine3D()
InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " VisibilityMask - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Main", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
Parse3DScripts()

WorldShadows(#PB_Shadow_Modulative)

;-Ground
CreateMaterial(0, LoadTexture(0, "Dirt.jpg"))
CreatePlane(0, 1500, 1500, 40, 40, 15, 15)
CreateEntity(0,MeshID(0),MaterialID(0)); Always visible (visibility mask = $FFFF FFFF)
EntityRenderMode(0, 0)

;-Mesh
CreateCube(1, 100)

;-Material
GetScriptMaterial(1, "Color/Blue")
GetScriptMaterial(2, "Color/Green")
GetScriptMaterial(3, "Color/Red")

;-Entity
CreateEntity(1, MeshID(1), MaterialID(1), -100, 50, 0, -1, #Mask1) ; Visible by camera 0
CreateEntity(2, MeshID(1), MaterialID(2),    0, 50, 0, -1, #Mask2) ; Visible by camera 1
CreateEntity(3, MeshID(1), MaterialID(3),  100, 50, 0, -1, #Mask3) ; Visible by camera 2

;-BillBoard
CreateTexture2(11, RGB(  0,   0, 255), "Player 1")
CreateMaterial(11, TextureID(11))
CreateTexture2(12, RGB(  0, 255,   0), "Player 2")
CreateMaterial(12, TextureID(12))
CreateTexture2(13, RGB(255,   0,   0), "Player 3")
CreateMaterial(13, TextureID(13))
CreateBillboardGroup(1, MaterialID(11), 100, 100, 0, 0, 0, #Mask1, #PB_Billboard_Point)
AddBillboard(1, -100, 180, 0)
CreateBillboardGroup(2, MaterialID(12), 100, 100, 0, 0, 0, #Mask2, #PB_Billboard_Point)
AddBillboard(2,    0, 180, 0)
CreateBillboardGroup(3, MaterialID(13), 100, 100, 0, 0, 0, #Mask3, #PB_Billboard_Point)
AddBillboard(3,  100, 180, 0)

;- Camera
CreateCamera(0,  0,  0, 50, 50, #Mask1) ; Entity 1 visible
MoveCamera(0, 0, 120, 500, #PB_Absolute)

CreateCamera(1, 50,  0, 50, 50, #Mask2); Entity 2 visible
MoveCamera(1, 0, 120, 500, #PB_Absolute)

CreateCamera(2,  0, 50, 50, 50, #Mask3); Entity 3 visible
MoveCamera(2, 0, 120, 500, #PB_Absolute)

CreateCamera(3, 50, 50, 50, 50, #Mask1 | #Mask3) ; entities 1 & 3 visibles
MoveCamera(3, 0, 120, 500, #PB_Absolute)

;- Light
CreateLight(0, RGB(255, 255, 255), -40, 300, 80)
AmbientColor(RGB(80, 80, 80))

;- SkyBox
SkyBox("desert07.jpg")

Repeat
  While WindowEvent():Wend
  
  ExamineMouse()
  
  ExamineKeyboard()
  
  RenderWorld()
  FlipBuffers()
  
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1

