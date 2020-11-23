;
; ------------------------------------------------------------
;
;   PureBasic - SetMeshMaterial
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

If InitEngine3D()
  
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
          
    MaterialFilteringMode(#PB_Default, #PB_Material_Anisotropic, 8)
    
    ;- Material
    CreateMaterial(0, LoadTexture(0, "ValetCoeur.jpg"))
    SetMaterialColor(0, #PB_Material_SelfIlluminationColor, RGB(255, 255, 255))
    CreateMaterial(1, LoadTexture(1, "DosCarte.png"))
    
    ;- Create a mesh manually
    
    ; Define all the vertices and their attributes
    
    CreateMesh(0)
    
    ; Recto
    MeshVertexPosition(-0.5,0,-0.5)
    MeshVertexTextureCoordinate(0,0)
    MeshVertexPosition(0.5,0,-0.5)
    MeshVertexTextureCoordinate(0,1)
    MeshVertexPosition(0.5,0,0.5)
    MeshVertexTextureCoordinate(1,1)
    MeshVertexPosition(-0.5,0,0.5)
    MeshVertexTextureCoordinate(1,0)
    
    ; Define all the faces, based on the vertex index
    MeshFace(2,1,0)
    MeshFace(0,3,2)
    
    ; Verso
    AddSubMesh()
    MeshVertexPosition(-0.5,0,-0.5)
    MeshVertexTextureCoordinate(0,0)
    MeshVertexPosition(0.5,0,-0.5)
    MeshVertexTextureCoordinate(0,1)
    MeshVertexPosition(0.5,0,0.5)
    MeshVertexTextureCoordinate(1,1)
    MeshVertexPosition(-0.5,0,0.5)
    MeshVertexTextureCoordinate(1,0)
    
    MeshFace(0,1,2)
    MeshFace(2,3,0)
    
    FinishMesh(#True)
    NormalizeMesh(0) 
    
    UpdateMeshBoundingBox(0)
    
    SetMeshMaterial(0, MaterialID(0), 0)
    SetMeshMaterial(0, MaterialID(1), 1)
    
    ;-Entity
    CreateEntity(0, MeshID(0), #PB_Material_None)
    ScaleEntity(0, 300, 1, 200)
    
    ;-Camera
    CreateCamera(0, 0, 0, 100, 100)
    MoveCamera(0, 0, 0, 500, #PB_Absolute)
    CameraBackColor(0, RGB(80, 20, 20))
    
    Repeat
      Screen3DEvents()
      
      ExamineMouse()
      
      ExamineKeyboard()
      
      RotateEntity(0, 1.1, 0.3, 1.0, #PB_Relative)
      
      RenderWorld()
      
      FlipBuffers()
    Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
  EndIf
  
Else
  MessageRequester("Error", "The 3D Engine can't be initialized", 0)
EndIf

End