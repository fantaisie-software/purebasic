
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

InitEngine3D()
InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " CreateTexture - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
Parse3DScripts()

KeyboardMode(#PB_Keyboard_International)

AmbientColor(RGB(255,255,255))

; Mesh
;
CreateCube(0, 30)

; Texture
;
  Procedure cube(i,  x.f,y.f,z.f, color)
  CreateTexture(i, 256, 256)
  StartDrawing(TextureOutput(i))
  DrawingMode(#PB_2DDrawing_AllChannels | #PB_2DDrawing_AlphaBlend)
  Box(0, 0, 256, 256, RGBA(0, 0, 0, 255))
  Box(4, 4, 248, 248, color)
  Circle(127, 127, 50, RGBA(0, 0, 0, 0))
  StopDrawing()
  CreateMaterial(i, TextureID(i))
  MaterialBlendingMode(i, #PB_Material_AlphaBlend)
  MaterialCullingMode(i,#PB_Material_NoCulling)
  CreateEntity(i, MeshID(0), MaterialID(i), x, y, z)
EndProcedure

cube(0, -20, 0, 5,  RGBA(255, 0, 0, 127))
cube(1,  20, 0, 5,  RGBA(0, 0, 255, 127))  
cube(2, 0, 40, -5,  RGBA(0, 255, 0, 127))

CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0, 0, 10, 150, #PB_Absolute)
CameraLookAt(0, 0, 0, 1)

; SkyBox
;
SkyBox("desert07.jpg")

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
  
  For i = 0 To 2
    RotateEntity(i, 1, 1, 2-i, #PB_Relative)
  Next
  
  RotateCamera(0, MouseY, MouseX, 0, #PB_Relative)
  MoveCamera  (0, KeyX, 0, KeyY)
  
  RenderWorld()
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1

