
; ------------------------------------------------------------
;
;   PureBasic - SkyBox
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;
; Thanks to Steve 'Sinbad' Streeting for the nice SkyBox !
;
; Use [F2]/[F3] to change SkyBox's texture
; Use [F4] to disable SkyBox

#CameraSpeed = 1

Define.f KeyX, KeyY, MouseX, MouseY, RatioX, RatioY

InitEngine3D()
InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " SkyBox -  [F2]/[F3] change SkyBox    [F4]disable SkyBox    [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/skybox.zip", #PB_3DArchive_Zip)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
Parse3DScripts()

;-Material
CreateMaterial(0, LoadTexture(0, "r2skin.jpg"))

;-Entity
CreateEntity(0, LoadMesh(0, "robot.mesh"), MaterialID(0))

;-Camera
CreateCamera(0,0,0,100,100)
MoveCamera(0,0,0,100, #PB_Absolute)
CameraBackColor(0, RGB(19, 34, 49))

SkyBox("desert07.jpg")

ShowGUI(155, 0)

Repeat
  While WindowEvent():Wend      
  If ExamineMouse()
    MouseX = -MouseDeltaX() * #CameraSpeed * 0.05
    MouseY = -MouseDeltaY() * #CameraSpeed * 0.05
  EndIf
  
  If ExamineKeyboard()
    
    If KeyboardReleased(#PB_Key_F2):SkyBox("stevecube.jpg"):EndIf
    If KeyboardReleased(#PB_Key_F3):SkyBox("desert07.jpg"):EndIf
    If KeyboardReleased(#PB_Key_F4):SkyBox(""):EndIf
    
    KeyX = (KeyboardPushed(#PB_Key_Right)-KeyboardPushed(#PB_Key_Left))*#CameraSpeed
    Keyy = (KeyboardPushed(#PB_Key_Down)-KeyboardPushed(#PB_Key_Up))*#CameraSpeed
    
  EndIf
  
  RotateCamera(0, MouseY, MouseX, 0, #PB_Relative)
  MoveCamera  (0, KeyX, 0, KeyY)
  
  RenderWorld()
  
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1

