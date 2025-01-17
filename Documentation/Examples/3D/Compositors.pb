
; ------------------------------------------------------------
;
;   PureBasic - Compositor
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#CameraSpeed =0.5

Define.f KeyX, KeyY, MouseX, MouseY

InitEngine3D()

InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), "Compositor - [F1]Radial Blur - [F2] Bloom - [F3] Glass - [F4] Embossed - [F5] Sharpen Edges - [F6] Posterize - [F7] Laplace - [F8] Tiling     - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Compositors", #PB_3DArchive_FileSystem)
Parse3DScripts()

CreateTorus(0,10,0.8,64,64)
For i=0 To 100
  CreateMaterial(i,(0),Random($ffffff))
  MaterialShininess(i,64,$ffffff)
  CreateEntity(i,MeshID(0),MaterialID(i),Random(100)-50,Random(100)-50,Random(100)-50):RotateEntity(i,Random(360),Random(360),Random(360))
Next

SkyBox("desert07.jpg")

CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0,100,0,0)
CameraLookAt(0, 0, 0, 0)

CreateLight(0,$ffffff,20000,10000,10000)

CreateCompositorEffect(0,0,"Radial Blur")

Repeat
  While WindowEvent():Wend  
  ExamineMouse()
  ExamineKeyboard()    
  MouseX = -MouseDeltaX() * 0.05
  MouseY = -MouseDeltaY() * 0.05
  
  KeyX = (KeyboardPushed(#PB_Key_Right)-KeyboardPushed(#PB_Key_Left))*#CameraSpeed
  Keyy = (KeyboardPushed(#PB_Key_Down)-KeyboardPushed(#PB_Key_Up)-MouseWheel()*10)*#CameraSpeed 
  
  If KeyboardReleased(#PB_Key_F1):CreateCompositorEffect(0,0,"Radial Blur"):EndIf
  If KeyboardReleased(#PB_Key_F2):CreateCompositorEffect(0,0,"Bloom"):EndIf
  If KeyboardReleased(#PB_Key_F3):CreateCompositorEffect(0,0,"Glass"):EndIf
  If KeyboardReleased(#PB_Key_F4):CreateCompositorEffect(0,0,"Embossed"):EndIf
  If KeyboardReleased(#PB_Key_F5):CreateCompositorEffect(0,0,"Sharpen Edges"):EndIf
  If KeyboardReleased(#PB_Key_F6):CreateCompositorEffect(0,0,"Posterize"):EndIf
  If KeyboardReleased(#PB_Key_F7):CreateCompositorEffect(0,0,"Laplace"):EndIf
  If KeyboardReleased(#PB_Key_F8):CreateCompositorEffect(0,0,"Tiling"):EndIf
  
  RotateCamera(0, MouseY, MouseX, 0, #PB_Relative)
  MoveCamera  (0, KeyX, 0, KeyY)
  
  For i=0 To 100
    RotateEntity(i,0.1,0.2,0.3,#PB_Relative)
  Next
  
  RenderWorld()
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1

