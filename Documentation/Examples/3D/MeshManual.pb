;
; ------------------------------------------------------------
;
;   PureBasic - Manual Mesh
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#CameraSpeed = 1

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

Define.f KeyX, KeyY, MouseX, MouseY

Define.f x, y, z, nx, ny, nz, u, v
Define.l Co
Define.w t1, t2, t3

If InitEngine3D()
  
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
    
    ; Create a pyramid, manually.. See the DataSection, for more precisions
    ;
    
    Restore Pyramid
    
    CreateMesh(0, #PB_Mesh_TriangleList)
    
    ;Base
    For i = 0 To 3
      Read.f x : Read.f y : Read.f z
      Read.l Co
      Read.f u : Read.f v
      MeshVertexPosition(x, y, z)
      MeshVertexNormal(0, 0, 0)
      MeshVertexColor(Co)
      MeshVertexTextureCoordinate(u, v)
    Next
    
    For i = 0 To 1
      Read.w t1 : Read.w t2 : Read.w t3
      MeshFace(t1, t2, t3)
    Next
    
    ;Side
    For k=0 To 3
      
      AddSubMesh(#PB_Mesh_TriangleList)
      For i = 0 To 2
        Read.f x : Read.f y : Read.f z
        Read.l Co
        Read.f u : Read.f v
        MeshVertexPosition(x, y, z)
        MeshVertexNormal(0, 0, 0) 
        MeshVertexColor(Co)
        MeshVertexTextureCoordinate(u, v)
      Next i
      Read.w t1 : Read.w t2 : Read.w t3
      MeshFace(t1, t2, t3)
      
    Next
    
    FinishMesh(#True)
    NormalizeMesh(0) 
    
    UpdateMeshBoundingBox(0)
    
    CreateMaterial(0, LoadTexture(0, "Geebee2.bmp"))
    SetMaterialColor(0, #PB_Material_AmbientColor, #PB_Material_AmbientColors)
    
    
    CreateEntity(0, MeshID(0), MaterialID(0))
    ScaleEntity(0, 400, 200, 400)
    
    CreateCamera(0, 0, 0, 100, 100)
    MoveCamera(0, 0, 0, 1000, #PB_Absolute)
    
    CreateLight(0, RGB(255,255,255), 300, 600, -100)
    AmbientColor(RGB(80, 80, 80))
    
    Repeat
      Screen3DEvents()
      
      If ExamineMouse()
        MouseX = -MouseDeltaX() * #CameraSpeed * 0.05
        MouseY = -MouseDeltaY() * #CameraSpeed * 0.05
      EndIf
      
      If ExamineKeyboard()
        
        If KeyboardPushed(#PB_Key_Left)
          KeyX = -#CameraSpeed 
        ElseIf KeyboardPushed(#PB_Key_Right)
          KeyX = #CameraSpeed 
        Else
          KeyX = 0
        EndIf
        
        If KeyboardPushed(#PB_Key_Up)
          KeyY = -#CameraSpeed 
        ElseIf KeyboardPushed(#PB_Key_Down)
          KeyY = #CameraSpeed 
        Else
          KeyY = 0
        EndIf
        
      EndIf
      
      RotateEntity(0, 1, 1, 1, #PB_Relative)
      
      RotateCamera(0, MouseY, MouseX, 0, #PB_Relative)
      MoveCamera  (0, KeyX, 0, KeyY)
      
      RenderWorld()
      Screen3DStats()      
      FlipBuffers()
    Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
  EndIf
  
Else
  MessageRequester("Error", "The 3D Engine can't be initialized", 0)
EndIf

End

DataSection
  Pyramid:
  ;Base
  Data.f -0.5,-0.5,0.5  ; position
  Data.l $FF0000        ; color
  Data.f 0,0            ; UVCoordinate
  
  Data.f 0.5,-0.5,0.5   ; position
  Data.l $FF0000        ; color 
  Data.f 0,1            ; UVCoordinate
  
  Data.f 0.5,-0.5,-0.5  ; position
  Data.l $FF0000        ; color
  Data.f 1,1            ; UVCoordinate
  
  Data.f -0.5,-0.5,-0.5 ; position
  Data.l $FF0000        ; color
  Data.f 1,0            ; UVCoordinate
  
  Data.w 2,1,0          ; Face 
  Data.w 0,3,2          ; Face 
  
  ;-Front
  Data.f 0.5,-0.5,0.5   ; position
  Data.l $FFFFFF        ; color
  Data.f 1,0            ; UVCoordinate
  
  Data.f 0.0,0.5,0.0
  Data.l $FFFFFF
  Data.f 0.5,0.5
  
  Data.f -0.5,-0.5,0.5
  Data.l $FFFFFF
  Data.f 0,0
  
  Data.w 0,1,2         ; Face
  
  ;-Back
  Data.f -0.5,-0.5,-0.5
  Data.l $FFFFFF
  Data.f 0,1
  
  Data.f 0.0,0.5,0.0
  Data.l $FFFFFF
  Data.f 0.5,0.5
  
  Data.f 0.5,-0.5,-0.5
  Data.l $FFFFFF
  Data.f 1,1
  
  Data.w 0,1,2
  
  ;-Left
  Data.f -0.5,-0.5,0.5
  Data.l $FFFFFF
  Data.f 0,0
  
  Data.f 0.0,0.5,0.0
  Data.l $FFFFFF
  Data.f 0.5,0.5
  
  Data.f -0.5,-0.5,-0.5
  Data.l $FFFFFF
  Data.f 0,1
  
  Data.w 0,1,2
  
  ;-Right
  Data.f 0.5,-0.5,-0.5
  Data.l $FFFFFF
  Data.f 1,1
  
  Data.f 0.0,0.5,0.0
  Data.l $FFFFFF
  Data.f 0.5,0.5
  
  Data.f 0.5,-0.5,0.5
  Data.l $FFFFFF
  Data.f 1,0
  
  Data.w 0,1,2
  
EndDataSection