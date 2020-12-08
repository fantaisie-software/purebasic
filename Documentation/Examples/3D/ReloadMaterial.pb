;
; ------------------------------------------------------------
;
;   PureBasic - ReloadMaterial
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;
;Use [F5] 

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

Declare CreateMaterialScript()

If InitEngine3D()
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
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
      Screen3DEvents()
      
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
    
    End 
    
  EndIf 
Else
  MessageRequester("Error","Can't initialize engine3D")
EndIf

Procedure CreateMaterialScript()
  If CreateFile(0, #PB_Compiler_Home + "examples/3d/Data/Scripts/ReloadMaterial.material")
    Restore Material
    Line$ = "material Test"
    While Line$<> "END" 
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
Data.s "				texture nskingr.jpg"
Data.s "			}"
Data.s "		}"
Data.s "	}"
Data.s "}"
Data.s "END"
EndDataSection