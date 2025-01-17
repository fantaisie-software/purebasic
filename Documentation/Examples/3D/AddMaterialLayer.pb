
; ------------------------------------------------------------
;
;   PureBasic - AddMaterialLayer
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;


#CameraSpeed = 1

Define.f KeyX, KeyY, MouseX, MouseY

Font = LoadFont(#PB_Any, "Arial", 12, #PB_Font_Bold)

InitEngine3D()

InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), "AddMaterialLayer - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)

;- Mesh
Mesh = LoadMesh(#PB_Any, "robot.mesh")

;- Texture
Texture = CreateTexture(#PB_Any, 512, 512)
If StartDrawing(TextureOutput(Texture))
  Box(0, 0, 512, 512, RGB(0, 0, 0))
  DrawingFont(FontID(Font))
  DrawText(70, 210, "PureBasic", RGB(255, 255, 105))
  StopDrawing()
EndIf

;- Material
Material = CreateMaterial(#PB_Any, TextureID(LoadTexture(#PB_Any, "r2skin.jpg")))
AddMaterialLayer(Material, TextureID(Texture), #PB_Material_Add)

;- Entity
Entity = CreateEntity(#PB_Any, MeshID(Mesh), MaterialID(Material))
StartEntityAnimation(Entity, "Walk")
RotateEntity(Entity, 0, -90, 0)

;- Camera
Camera = CreateCamera(#PB_Any, 0, 0, 100, 100)
MoveCamera(Camera, 0, 70, 90, #PB_Absolute)

Repeat
  While WindowEvent():Wend
  
  If ExamineMouse()
    MouseX = -MouseDeltaX() * #CameraSpeed * 0.05
    MouseY = -MouseDeltaY() * #CameraSpeed * 0.05
  EndIf
  
  If ExamineKeyboard()    
    KeyX = (KeyboardPushed(#PB_Key_Right)-KeyboardPushed(#PB_Key_Left))*#CameraSpeed
    Keyy = (KeyboardPushed(#PB_Key_Down)-KeyboardPushed(#PB_Key_Up))*#CameraSpeed    
  EndIf
  
  RotateCamera(Camera, MouseY, MouseX, 0, #PB_Relative)
  MoveCamera  (Camera, KeyX, 0, KeyY)
  
  RenderWorld()
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1