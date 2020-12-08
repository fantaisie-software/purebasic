;
; ------------------------------------------------------------
;
;   PureBasic - ResetMaterial
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;
;Use [F5] 

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

Declare CreateMaterialScript(texture.s)

CreateMaterialScript("r2skin.jpg")

#PB_Engine3D_Entity = 2
#PB_Engine3D_BillboardGroup = 4

If InitEngine3D(#PB_Engine3D_DebugOutput)
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
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
      Screen3DEvents()
      
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
    
    End 
    
  EndIf 
Else
  MessageRequester("Error","Can't initialize engine3D")
EndIf

Procedure CreateMaterialScript(texture.s)
  If CreateFile(0, #PB_Compiler_Home + "examples/3d/Data/Scripts/ResetMaterial.material")
    Restore Material
    Line$ = "material TestReset"
    While Line$<> "END" 
      If FindString(Line$, "MyTextureHere", 1)
        Line$ = ReplaceString(Line$, "MyTextureHere", texture)
      EndIf  
      WriteStringN(0, Line$) 
      Read.s Line$
    Wend
    CloseFile(0)
  Else
    MessageRequester("Information","may not create the file!")
  EndIf
EndProcedure

DataSection
Material: 
Data.s "{"
Data.s "	technique"
Data.s "	{"
Data.s "		pass"
Data.s "		{"
Data.s "			texture_unit"
Data.s "			{"
Data.s "				texture MyTextureHere"
Data.s "			}"
Data.s "		}"
Data.s "	}"
Data.s "}"
Data.s "END"
EndDataSection