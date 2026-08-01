
; ------------------------------------------------------------
;
;   PureBasic - Skeleton
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

InitEngine3D():InitSprite():InitKeyboard():InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), "Billboard -  [F12]   [Pad1]   [Pad4]  [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

CreateCamera(0, 0, 0, 100, 100):MoveCamera(0,0,2,8):CameraLookAt(0,0,2,0):CameraBackColor(0,$446666)
CreateLight(0,$ffffff, -1000, 1000, 0)
AmbientColor($444444)

CreateMaterial(0,0,$ff)
MaterialShininess(0,64,$ffffff)
MaterialCullingMode(0,#PB_Material_NoCulling)

Define ns=4     ; section number (joint)
Define lgs=2    ; section lenght
Define r.f=0.2  ; section radius
Define ni=8 ,nj=16, w.f,ai.f ; for mesh description

; ----------- mesh creation
Dim t.MeshVertex((nj+1)*(ns)-1,ni)
For s=0 To ns-1
  For j=0 To nj
    For i=0 To ni
      With t(s*(nj+1)+j,i) 
        ai=i/ni*2*#PI
        \x=-Cos(ai)*r
        \z=Sin(ai)*r
        \y=(0.0+s+j/nj)*lgs
        \u=i/4
        \v=j/16
        \Color=$ffffff
        \NormalX=\x
        \Normaly=0
        \Normalz=\z
      EndWith 
    Next
  Next
Next
CreateDataMesh(0,t())

; ----------- skeleton/joints creation
Define joint.s,pjoint.s
CreateSphere(100,0.05)
CreateMaterial(100,0,$ffffff)

CreateSkeleton(0)
For s=0 To ns
  pjoint=joint
  joint="joint"+s
  CreateBone(0,joint,pjoint,0,lgs*s,0,0,0,0,0,0)
  CreateEntity(100+s,MeshID(100),MaterialID(100))
Next

; ----------- Vertex Bone Assignment
For s=0 To ns
  For j=0 To nj
    For i=0 To ni
      vi=(s*(nj+1)+j)*(ni+1)+i
      v.f=s+j/nj-0.5:If v<0:v=0:EndIf
      w=Mod(v,1)
      bi=Int(v)
      VertexBoneAssignment(0,0,vi,bi+0,1-w)
      VertexBoneAssignment(0,0,vi,bi+1,w)
    Next
  Next
Next
FinishBoneAssignment(0,0)

CreateEntity(0,MeshID(0),MaterialID(0))

For s=0 To ns
  EnableManualEntityBoneControl(0, "joint"+s, #True, #True)
Next

Define.f MouseX,Mousey,depx,depz,dist,rotx,Wireframe.b=1,angle.f


Repeat
  While WindowEvent():Wend
  ExamineKeyboard()
  ExamineMouse()
  
  depx=(-Bool(KeyboardPushed(#PB_Key_Left))+Bool(KeyboardPushed(#PB_Key_Right)))*0.1
  depz=(-Bool(KeyboardPushed(#PB_Key_Down))+Bool(KeyboardPushed(#PB_Key_Up   )))*0.1+MouseWheel()
  If KeyboardReleased(#PB_Key_F12):Wireframe=1-Wireframe:EndIf:If Wireframe:MaterialShadingMode(0, #PB_Material_Wireframe):Else:MaterialShadingMode(0,#PB_Material_Solid):EndIf
  MouseX = -MouseDeltaX() *  0.05
  MouseY = -MouseDeltaY() *  0.05
  RotateCamera(0, MouseY, MouseX, 0, #PB_Relative)
  dist+(depz-dist)*0.05:MoveCamera  (0, depX, 0, -dist)
  
  angle+0.01
  
  rotx+(-Bool(KeyboardPushed(#PB_Key_Pad1))+Bool(KeyboardPushed(#PB_Key_Pad4)))
  For s=0 To ns
    joint="joint"+s
    rotx=Sin(angle+s*0.0002)*90
    If s & 1:sens=1:Else:sens=-1:EndIf
    RotateEntityBone(0, joint, 0,0,sens*rotx, #PB_Absolute)
    MoveEntity(100+s,EntityBoneX(0,joint),EntityBoneY(0,joint),EntityBoneZ(0,joint),#PB_Absolute)
  Next
  
  RenderWorld()
  FlipBuffers()    
Until KeyboardReleased(#PB_Key_Escape) Or MouseButton(3)

