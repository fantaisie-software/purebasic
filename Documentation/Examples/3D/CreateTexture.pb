
; ------------------------------------------------------------
;
;   PureBasic - CreateTexture
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#CameraSpeed = 1



Define.f KeyX, KeyY, MouseX, MouseY

LoadFont(0, "Arial", 32, #PB_Font_Bold)

InitEngine3D()
InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " CreateTexture - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)

AmbientColor(RGB(255,255,255))

; Texture
;
CreateTexture(0, 256, 256)
StartDrawing(TextureOutput(0))
Box(0, 0, 256, 256, RGB(90, 40, 0))
Box(6, 6, 244, 244, RGB(190, 140, 0))
DrawingMode(#PB_2DDrawing_Transparent)
DrawingFont(FontID(0))
DrawText(10, 110, "PureBasic", RGB(90, 40, 90))
StopDrawing()

CreateMaterial(0, TextureID(0))

; Cube
;
CreateCube(0, 30)
CreateEntity(0, MeshID(0), MaterialID(0))


CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0, 0, 0, 100, #PB_Absolute)

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
  
  
  RotateEntity(0, 0, 1, 0, #PB_Relative)
  
  RotateCamera(0, MouseY, MouseX, 0, #PB_Relative)
  MoveCamera  (0, KeyX, 0, KeyY)
  
  RenderWorld()
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1

