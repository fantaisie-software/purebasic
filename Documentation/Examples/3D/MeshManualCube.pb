;
; ------------------------------------------------------------
;
;   PureBasic - Manual Mesh
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#CameraSpeed = 3
#SQRT13 = 0.57735026

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

Define.f KeyX, KeyY, MouseX, MouseY

If InitEngine3D()
  
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
    
    ; Create a cube manually
    ; 
    
    ; Define all the vertices and their attributes
    CreateMesh(0)
    MeshVertexPosition(-100, 100, -100)
    MeshVertexNormal(-#SQRT13,#SQRT13,-#SQRT13)
    MeshVertexColor(RGB(255, 0, 0))
    
    MeshVertexPosition(100, 100, -100)
    MeshVertexNormal(#SQRT13,#SQRT13,-#SQRT13)
    MeshVertexColor(RGB(255, 0, 0))
    
    MeshVertexPosition(100, -100, -100)
    MeshVertexNormal(#SQRT13,-#SQRT13,-#SQRT13)
    MeshVertexColor(RGB(255, 0, 0))
    
    MeshVertexPosition(-100, -100, -100)
    MeshVertexNormal(-#SQRT13,-#SQRT13,-#SQRT13)
    MeshVertexColor(RGB(255, 0, 255))
    
    MeshVertexPosition(-100, 100, 100)
    MeshVertexNormal(-#SQRT13,#SQRT13,#SQRT13)
    MeshVertexColor(RGB(255, 0, 0))
    
    MeshVertexPosition(100, 100, 100)
    MeshVertexNormal(#SQRT13,#SQRT13,#SQRT13)
    MeshVertexColor(RGB(255, 0, 255))
    
    MeshVertexPosition(100, -100, 100)
    MeshVertexNormal(#SQRT13,-#SQRT13,#SQRT13)
    MeshVertexColor(RGB(255, 0, 0))
    
    MeshVertexPosition(-100, -100, 100)
    MeshVertexNormal(-#SQRT13,-#SQRT13,#SQRT13)
    MeshVertexColor(RGB(255, 0, 0))
    
    ; Define all the faces, based on the vertex index
    ;
    MeshFace(0, 2, 3)
    MeshFace(0, 1, 2)
    MeshFace(1, 6, 2)
    MeshFace(1, 5, 6)
    MeshFace(4, 6, 5)
    MeshFace(4, 7, 6)
    MeshFace(0, 7, 4)
    MeshFace(0, 3, 7)
    MeshFace(0, 5, 1)
    MeshFace(0, 4, 5)
    MeshFace(2, 7, 3)
    MeshFace(2, 6, 7)
    
    FinishMesh(1)
    
    CreateMaterial(0, LoadTexture(0, "clouds.jpg"))
    SetMaterialColor(0, #PB_Material_AmbientColor, #PB_Material_AmbientColors)
    
    
    CreateEntity(0, MeshID(0), MaterialID(0))
    
    CreateCamera(0, 0, 0, 100, 100)
    MoveCamera(0, 0, 0, 1000, #PB_Absolute)
    
    
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