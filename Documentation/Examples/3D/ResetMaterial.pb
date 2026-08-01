
; ------------------------------------------------------------
;
;   PureBasic - ResetMaterial
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;
;Use [F5]



Declare CreateMaterialScript(texture.s)

CreateMaterialScript("r2skin.jpg")

#PB_Engine3D_Entity = 2

InitEngine3D(#PB_Engine3D_DebugOutput)

InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " ResetMaterial -  [F5]  [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models"  , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts" , #PB_3DArchive_FileSystem)
Parse3DScripts()


;- Material
GetScriptMaterial(0, "TestReset")

;- Mesh
LoadMesh(0, "robot.mesh")

;- Entity
CreateEntity(0, MeshID(0), MaterialID(0), -60, 0, 0)
CreateEntity(1, MeshID(0), MaterialID(0))
CreateEntity(2, MeshID(0), MaterialID(0),  60, 0, 0)

;This one will keep his material
CreateEntity(3, MeshID(0), #PB_Material_None, -60, 0, 60)

; Camera
;
CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0, 150, 90, 150, #PB_Absolute)
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
      CreateMaterialScript("nskingr.jpg") ; Change texture
      ReloadMaterial("TestReset", "ResetMaterial.material", #True)
      GetScriptMaterial(0, "TestReset")
      ResetMaterial(#PB_Engine3D_Entity)
    EndIf
  EndIf
  
  RenderWorld()
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape)


Procedure CreateMaterialScript(Texture$)
  If CreateFile(0, #PB_Compiler_Home + "examples/3d/Data/Scripts/ResetMaterial.material")
    Material$ = "material TestReset" + #LF$ +
                "{" +
                "	 technique" +
                "	 {" +
                "		 pass" +
                "		 {" +
                "			 texture_unit" +
                "			 {" + 
                "				 texture "+ Texture$ + 
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

