
; ------------------------------------------------------------
;
;   PureBasic - CheckObjectVisibility
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#CameraSpeed = 0.4

#MainWindow = 0

Enumeration
  #Text1
  #Text2
  #Text3
EndEnumeration

Define.f KeyX, KeyY, MouseX, MouseY, RatioX, RatioY, SpeedRotate

Declare IsOnScreen(Editor, object.s , objectID)

InitEngine3D()
InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " CheckObjectVisibility -  [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)
InitScreenGadgets()


Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
;Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/GUI", #PB_3DArchive_FileSystem)
Parse3DScripts()

; First create materials
;
CreateMaterial(0, LoadTexture(0, "Dirt.jpg"))
GetScriptMaterial(1, "Color/Blue")
GetScriptMaterial(2, "Color/Green")
GetScriptMaterial(3, "Color/Red")

; Meshes
;
CreatePlane(0, 500, 500, 10, 10, 20, 20)
CreateCube(1, 4)
CreateSphere(2, 4)
CreateCylinder(3, 4, 8)

; Entities
;
CreateEntity(0, MeshID(0), MaterialID(0))
CreateEntity(1, MeshID(1), MaterialID(1),   0, 4,  150)
CreateEntity(2, MeshID(2), MaterialID(2), 150, 4,    0)
CreateEntity(3, MeshID(3), MaterialID(3),   0, 4, -150)

; Camera
;
CreateCamera(0, 0, 0, 100, 100)
CameraBackColor(0, RGB(30, 50, 70))
MoveCamera(0, -1, 10, 15, #PB_Absolute)
CameraLookAt(0, 100, 0, 0)

; Light
;
CreateLight(0, RGB(255, 255, 255), 1560, 900, 500)
AmbientColor(RGB(30, 30, 30))

;GUI
;
OpenScreenWindow(#MainWindow, 8,8, 250, 160, "Who Is on Screen ?")
TextScreenGadget(#Text1, 10 ,  20 , 430 , 40 , "")
TextScreenGadget(#Text2, 10 ,  60 , 430 , 40 , "")
TextScreenGadget(#Text3, 10 , 100 , 430 , 40 , "")

ScreenMouseVisible(0)

Repeat
  While WindowEvent():Wend
    
  If ExamineMouse()
    MouseX = -MouseDeltaX() * #CameraSpeed * 0.5
    MouseY = -MouseDeltaY() * #CameraSpeed * 0.5
  EndIf
  
  If ExamineKeyboard()
    KeyX = (KeyboardPushed(#PB_Key_Right)-KeyboardPushed(#PB_Key_Left))*#CameraSpeed
    Keyy = (KeyboardPushed(#PB_Key_Down)-KeyboardPushed(#PB_Key_Up)-MouseWheel()*10)*#CameraSpeed        
  EndIf
  
  IsOnScreen(#Text1, "Cube", EntityID(1))
  IsOnScreen(#Text2, "Sphere", EntityID(2))
  IsOnScreen(#Text3, "Cylinder", EntityID(3))
  
  RotateCamera(0, MouseY, MouseX, 0, #PB_Relative)
  MoveCamera  (0, KeyX, 0, KeyY)
  
  RenderWorld()
  RenderScreenGadgets()
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1

Procedure IsOnScreen(Editor, object.s , objectID)
  If CheckObjectVisibility(0, objectID)
    SetScreenGadgetText(Editor, object + " is on screen")
  Else
    SetScreenGadgetText(Editor, object + " is not on screen")
  EndIf
EndProcedure
