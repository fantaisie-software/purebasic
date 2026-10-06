
; ------------------------------------------------------------
;
;   PureBasic - TextureVectorOutput
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
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " TextureVectorOutput - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
Parse3DScripts()

LoadFont(0, "Arial", 40, #PB_Font_Bold)

AmbientColor(RGB(255,255,255))

CreateCube(0, 30)

Procedure cube(i, x.f, y.f, z.f, color)
  CreateTexture(i, 256, 256)

  If StartVectorDrawing(TextureVectorOutput(i))
    ; Transparent background with a rounded, antialiased frame
    VectorSourceColor(RGBA(0, 0, 0, 0))
    FillVectorOutput()

    AddPathBox(8, 8, 240, 240)
    VectorSourceColor(color)
    FillPath(#PB_Path_Preserve)
    VectorSourceColor(RGBA(0, 0, 0, 255))
    StrokePath(8, #PB_Path_RoundCorner)

    ; Gradient circle
    VectorSourceCircularGradient(128, 128, 70)
    VectorSourceGradientColor(RGBA(255, 255, 255, 255), 0.0)
    VectorSourceGradientColor(RGBA(255, 255, 0, 0), 1.0)
    AddPathCircle(128, 128, 70)
    FillPath()

    ; Text
    VectorFont(FontID(0), 40)
    VectorSourceColor(RGBA(0, 0, 0, 255))
    MovePathCursor(128 - VectorTextWidth("PB")/2, 128 - VectorTextHeight("PB")/2)
    DrawVectorText("PB")

    StopVectorDrawing()
  EndIf

  CreateMaterial(i, TextureID(i))
  MaterialBlendingMode(i, #PB_Material_AlphaBlend)
  MaterialCullingMode(i, #PB_Material_NoCulling)
  CreateEntity(i, MeshID(0), MaterialID(i), x, y, z)
EndProcedure

cube(0, -20, 0, 5,  RGBA(255, 0, 0, 127))
cube(1,  20, 0, 5,  RGBA(0, 0, 255, 127))
cube(2, 0, 40, -5,  RGBA(0, 255, 0, 127))

CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0, 0, 10, 150, #PB_Absolute)
CameraLookAt(0, 0, 0, 1)

SkyBox("desert07.jpg")

Repeat
  While WindowEvent():Wend

  If ExamineMouse()
    MouseX = -MouseDeltaX() * #CameraSpeed * 0.05
    MouseY = -MouseDeltaY() * #CameraSpeed * 0.05
  EndIf

  If ExamineKeyboard()
    KeyX = (KeyboardPushed(#PB_Key_Right)-KeyboardPushed(#PB_Key_Left))*#CameraSpeed
    KeyY = (KeyboardPushed(#PB_Key_Down)-KeyboardPushed(#PB_Key_Up))*#CameraSpeed
  EndIf

  For i = 0 To 2
    RotateEntity(i, 1, 1, 2-i, #PB_Relative)
  Next

  RotateCamera(0, MouseY, MouseX, 0, #PB_Relative)
  MoveCamera  (0, KeyX, 0, KeyY)

  RenderWorld()
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape)
