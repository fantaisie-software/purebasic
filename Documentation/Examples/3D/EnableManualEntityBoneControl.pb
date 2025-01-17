
; ------------------------------------------------------------
;
;   PureBasic - EnableManualEntityBoneControl
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#CameraSpeed = 1



Define.f KeyX, KeyY, MouseX, MouseY, RollZ, sens = -1

Dim Bone.s(18)

Macro Text3D(No, Texte, Color, Alignment)
  CreateText3D(No, Texte)
  Text3DColor(No, Color)
  Text3DAlignment(No, Alignment)
EndMacro

InitEngine3D()
InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " EnableManualEntityBoneControl -  [F5]   [PageUp]   [PageDown]  [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/fonts", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/skybox.zip", #PB_3DArchive_Zip)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
Parse3DScripts()

LoadMesh(0, "robot.mesh")


CreateMaterial(0, LoadTexture(0, "r2skin.jpg"))
MaterialShadingMode(0, #PB_Material_Wireframe)

CreateEntity(0, MeshID(0), MaterialID(0))

For i=1 To 18
  Bone$ = "Joint"+Str(i)
  Bone(i) = Bone$
  EnableManualEntityBoneControl(0, Bone$, #True, #True)
  Text3D(i, Str(i), RGBA(255, 0, 0, 255), #PB_Text3D_HorizontallyCentered | #PB_Text3D_VerticallyCentered)
  AttachEntityObject(0, Bone$, Text3DID(i))
  ScaleText3D(i, 4, 4, 0)
Next

RotateEntity(0, 0, -70, 0)

SkyBox("stevecube.jpg")

CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0, 0, 40, 150, #PB_Absolute)

Repeat
  While WindowEvent():Wend
  
  If ExamineMouse()
    MouseX = -MouseDeltaX() * #CameraSpeed * 0.05
    MouseY = -MouseDeltaY() * #CameraSpeed * 0.05
  EndIf
  
  If ExamineKeyboard()
    
    If KeyboardReleased(#PB_Key_F5)
      EnableManualEntityBoneControl(0, Bone(0), #False, #True)
    EndIf
    
    If KeyboardPushed(#PB_Key_Left)
      RotateEntityBone(0, bone(10), 0, -1, 0, #PB_Relative)
    ElseIf KeyboardPushed(#PB_Key_Right)
      RotateEntityBone(0, bone(10), 0, 1, 0, #PB_Relative)
    EndIf
    
    If KeyboardPushed(#PB_Key_Up)
      RotateEntityBone(0, bone(14), 0, 0, 1, #PB_Relative)
      RotateEntityBone(0, bone(17), 0, 0, 1, #PB_Relative)
    ElseIf KeyboardPushed(#PB_Key_Down)
      RotateEntityBone(0, bone(14), 0, 0, -1, #PB_Relative)
      RotateEntityBone(0, bone(17), 0, 0, -1, #PB_Relative)
    EndIf
    
    If KeyboardPushed(#PB_Key_PageUp)
      MoveEntityBone(0, bone(7), 1, 0, 0, #PB_Relative)
    ElseIf KeyboardPushed(#PB_Key_PageDown)
      MoveEntityBone(0, bone(7), -1, 0, 0, #PB_Relative)
    EndIf
  EndIf
  
  RenderWorld()
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1

