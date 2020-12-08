;
; ------------------------------------------------------------
;
;   PureBasic - Orientation
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#CameraSpeed = 1

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

Structure Vector3
  x.f
  y.f
  z.f
EndStructure

Structure Quaternion
  x.f
  y.f
  z.f
  w.f
EndStructure 

Declare ConvertLocalToWorld(*N.Vector3, *P.Vector3, *Orientation.Quaternion, *Position.Vector3)

Define.f KeyX, KeyY, MouseX, MouseY, RollZ, sens = -1
Define Pos.Vector3, Orientation.Quaternion
Define.Vector3 Resultat, C1, C2 

C1\x = -25 : C1\y = -25 : C1\z = -25
C2\x =  25 : C2\y =  25 : C2\z =  25

If InitEngine3D()
  
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/skybox.zip", #PB_3DArchive_Zip)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts", #PB_3DArchive_FileSystem)
  Parse3DScripts()
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()
    
    CreateCube(0, 50)
    CreateSphere(1, 5)
    
    CreateMaterial(0, LoadTexture(0, "Dirt.jpg"))
    CreateMaterial(1, LoadTexture(1, "Wood.jpg"))
    
    CreateEntity(0, MeshID(0), MaterialID(0))  
    CreateEntity(1, MeshID(1), MaterialID(1))  
    CreateEntity(2, MeshID(1), MaterialID(1))

    SkyBox("stevecube.jpg")
    
    CreateCamera(0, 0, 0, 100, 100)
    MoveCamera(0, 90, 80, 150, #PB_Absolute)
        
    Repeat
      Screen3DEvents()
      
      If ExamineMouse()
        MouseX = -MouseDeltaX() * #CameraSpeed * 0.05
        MouseY = -MouseDeltaY() * #CameraSpeed * 0.05
      EndIf
      
      If ExamineKeyboard()
        
      EndIf
      
      RotateEntity(0, 0, 0.4, 0, #PB_Relative)
      MoveEntity(0, 0, 0, -1, #PB_Local)
      
      Pos\x = EntityX(0) : Pos\y = EntityY(0) :Pos\z = EntityZ(0)  
      
      FetchOrientation(EntityID(0))
      Orientation\x = GetX()
      Orientation\y = GetY()
      Orientation\z = GetZ()
      Orientation\w = GetW()
  
      ConvertLocalToWorld(@Resultat, @C1, @Orientation, @Pos)
      MoveEntity(1, Resultat\x, Resultat\y, Resultat\z, #PB_Absolute)
      ConvertLocalToWorld(@Resultat, @C2, @Orientation, @Pos)
      MoveEntity(2, Resultat\x, Resultat\y, Resultat\z, #PB_Absolute)
      
      CameraLookAt(0, Pos\x, Pos\y, Pos\z)
      RenderWorld()

      FlipBuffers()
    Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
  EndIf
  
Else
  MessageRequester("Error", "The 3D Engine can't be initialized",0)
EndIf

End 

Macro CROSS_PRODUCT(N, V1, V2)
  N\x = ((V1\y * V2\z) - (V1\z * V2\y))
  N\y = ((V1\z * V2\x) - (V1\x * V2\z))
  N\z = ((V1\x * V2\y) - (V1\y * V2\x))
EndMacro

Procedure QuaternionVector3(*R.Vector3, *Q.Quaternion, *P.Vector3) 
  ; nVidia SDK implementation
  Protected.Vector3 uv, uuv 
  CROSS_PRODUCT(uv, *Q, *P)
  CROSS_PRODUCT(uuv, *Q, uv)
  uv\x * (2.0 * *Q\w) : uv\y * (2.0 * *Q\w) : uv\z * (2.0 * *Q\w)
  uuv\x * 2.0 : uuv\y * 2.0 : uuv\z * 2.0  
  *R\x = *P\x + uv\x + uuv\x 
  *R\y = *P\y + uv\y + uuv\y 
  *R\z = *P\z + uv\z + uuv\z 
EndProcedure

Procedure ConvertLocalToWorld(*N.Vector3, *P.Vector3, *Orientation.Quaternion, *Position.Vector3)
  Protected.Vector3 R
  QuaternionVector3(@R, *Orientation, *P)
  *N\x = R\x + *Position\x
  *N\y = R\y + *Position\y
  *N\z = R\z + *Position\z
EndProcedure