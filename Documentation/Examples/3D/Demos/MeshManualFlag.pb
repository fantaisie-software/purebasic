;
; ------------------------------------------------------------
;
;   PureBasic - Mesh Manual - Flag 
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
; 
;

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

#CameraSpeed = 1
#NbX=30
#NbZ=30 

Global.f AngleVague, WaveFrequency, WavePeriodX, WavePeriodZ, WaveAmplitude
WaveFrequency=3  ;=waves/second
WavePeriodX  =9  ;=1/Wave length
WavePeriodZ  =11 ;=1/Wave length
WaveAmplitude=3

Define.f KeyX, KeyY, MouseX, MouseY

Declare UpdateMatrix()
Declare CreateMatrix()

If InitEngine3D()
  
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/skybox.zip", #PB_3DArchive_Zip)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
  Parse3DScripts()
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
    
    ;-Material  
    GetScriptMaterial(1, "Scene/GroundBlend")
    MaterialCullingMode(1, 1)
    
    ;-Mesh
    CreateMatrix()
    
    ;-Camera
    CreateCamera(0, 0, 0, 100, 100)
    MoveCamera(0,0,50,80, #PB_Absolute)
    CameraLookAt(0, 0, 0, 0)
    CameraBackColor(0, RGB(90, 0, 0))
    
    ;-Light
    CreateLight(0, RGB(255, 255, 255), 20, 150, 120)
    AmbientColor(RGB(90, 90, 90))
    
    ;- Skybox
    SkyBox("stevecube.jpg")
    
    Repeat
      Screen3DEvents()
      
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
      
      If ExamineMouse()
        MouseX = -(MouseDeltaX()/10)
        MouseY = -(MouseDeltaY()/10)
      EndIf
      MoveCamera  (0, KeyX, 0, KeyY)
      RotateCamera(0,  MouseY, MouseX, 0, #PB_Relative)  
      
      ; Waves
      UpdateMatrix()
      AngleVague = AngleVague+WaveFrequency
            
      RenderWorld()
      
      FlipBuffers()
    Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
  EndIf
  
Else
  MessageRequester("Error", "The 3D Engine can't be initialized", 0)
EndIf

End

;-Procedures
Procedure DrawMatrix()
  Protected.l a, b, Nb
  Protected.w P1, P2, P3, P4
  
  For b=0 To #Nbz
    For a=0 To #NbX
      ;les coordonnées de vertex
      y.f=Sin(Radian((AngleVague+a*WavePeriodX+b*WavePeriodZ)))*WaveAmplitude 
      MeshVertexPosition(a - #NbX/2, y, b - #Nbz/2) 
      MeshVertexNormal(0,1,0) 
      MeshVertexTextureCoordinate(a/#NbX, b/#Nbz)
    Next a
  Next b
    
  Nb=#NbX+1
  For b=0 To #NbZ-1
    For a=0 To #NbX-1
      P1=a+(b*Nb)
      P2=P1+1
      P3=a+(b+1)*Nb
      P4=P3+1
  
      MeshFace(P3, P2, P1)
      MeshFace(P2, P3, P4)
    Next
  Next
EndProcedure  

Procedure CreateMatrix()
  
  CreateMesh(0, #PB_Mesh_TriangleList, #PB_Mesh_Dynamic)
  DrawMatrix()
  FinishMesh(#False)
  SetMeshMaterial(0, MaterialID(1))
  
  CreateNode(0)
  AttachNodeObject(0, MeshID(0))
  ScaleNode(0, 2, 2, 2)
EndProcedure

Procedure UpdateMatrix()
  UpdateMesh(0, 0)
  DrawMatrix()
  FinishMesh(#False)
EndProcedure