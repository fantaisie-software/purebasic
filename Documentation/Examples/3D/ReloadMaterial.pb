
; ------------------------------------------------------------
;
;   PureBasic - ReloadMaterial
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;
;Use [F5]

Declare CreateMaterialScript()

InitEngine3D()

InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " ReloadMaterial -  [F5]  [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models"  , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts" , #PB_3DArchive_FileSystem)
Parse3DScripts()

;- Mesh
LoadMesh(0, "robot.mesh")

;- Entity
CreateEntity(0, MeshID(0), #PB_Material_None)

; Camera
;
CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0, 120, 90, 90, #PB_Absolute)
CameraLookAt(0, 0, 50, 0)
CameraBackColor(0, RGB(0, 0, 30))

;- Light
;
AmbientColor(RGB(75, 75, 75))
CreateLight(0, RGB(255, 255, 255), 0, 500, 0)

Repeat
  While WindowEvent():Wend
  
  If ExamineKeyboard()
    If KeyboardReleased(#PB_Key_F5)
      CreateMaterialScript()
      ReloadMaterial("Test", "ReloadMaterial.material", #True)
      GetScriptMaterial(0, "Test")
      SetEntityMaterial(0, MaterialID(0))
    EndIf
  EndIf
  
  RenderWorld()
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape)


Procedure CreateMaterialScript()
  If CreateFile(0, #PB_Compiler_Home + "examples/3d/Data/Scripts/ReloadMaterial.material")
    Material$ = "material Test" + #LF$ +
                "{" +
                "	 technique" +
                "	 {" +
                "		 pass" +
                "		 {" +
                "			 texture_unit" +
                "			 {" + 
                "				 texture nskingr.jpg" +
                "			 }" +
                "		 }" +
                "	 }" +
                "}"
    
    WriteStringN(0, Material$)
    CloseFile(0)
  Else
    MessageRequester("Information","may not create the file!")
  EndIf
EndProcedure

