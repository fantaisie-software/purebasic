
; ------------------------------------------------------------
;
;   PureBasic - Animation
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;
;Cursor = Move Robot
;Speed animation = PageUp and PageDown



#ANIM_FADE_SPEED = 7.5  ; animation crossfade speed in % of full weight per second

Enumeration 1
  #Idle
  #Walk
EndEnumeration

#NUM_ANIMS = 2 ; number of animations

Define.f KeyX, KeyY, MouseX, MouseY, Angle, Speed = 1.0, TimeSinceLastFrame
Global RobotMove, FadeIn, FadeOut, Anim

Global Dim Anim.s(#NUM_ANIMS)

Declare fadeAnimations(deltaTime.f)
Declare.f CurveAngle(Actuelle.f, Target.f, P.f)
Declare.f WrapPi(Angle.f)

Macro Clamp(num, min, max)
  If num<min
    num=min
  ElseIf num>max
    num=max
  EndIf
EndMacro

InitEngine3D()
InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " Animation -  [PageUp]   [PageDown]  [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Main"            , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures"        , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models"          , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts"         , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
Parse3DScripts()

WorldShadows(#PB_Shadow_Modulative, 0, RGB(180, 180, 255))

;Ground
;
CreateMaterial(0, LoadTexture(0, "Dirt.jpg"))
CreatePlane(0, 1500, 1500, 40, 40, 15, 15)
CreateEntity(0,MeshID(0),MaterialID(0))
EntityRenderMode(0, 0)

;Mesh
;
LoadMesh(1, "robot.mesh")

; Entity
;
CreateEntity(1, MeshID(1), #PB_Material_None, 0, 0, -50)
EntityAnimationBlendMode(1, #PB_EntityAnimation_Average)

; Animation
;
animNames$ = "Idle,Walk"

; populate our animation List
For i = 1 To #NUM_ANIMS
  Anim(i) = StringField(animNames$, i, ",")
  ;EnableEntityAnimation(1, Anim(i), #True, #False)
  Fadein  = #False
  FadeOut = #False
Next

; SkyBox
;
SkyBox("desert07.jpg")

; Camera
;
CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0, 50, 100, 180, #PB_Absolute)
CameraLookAt(0, EntityX(1), EntityY(1) + 40, EntityZ(1))


CreateLight(0, RGB(255, 255, 255), -40, 100, 80)
AmbientColor(RGB(80, 80, 80))

Repeat
  While WindowEvent():Wend
  
  If ExamineMouse()
    MouseX = -MouseDeltaX()/10
    MouseY = -MouseDeltaY()/10
  EndIf
  
  RobotMove = #False
  Angle = EntityYaw(1)
  If ExamineKeyboard()
    
    If KeyboardPushed(#PB_Key_Left)
      MoveEntity(1, -1 * Speed, 0, 0)
      Angle = 180
      RobotMove = #True
      
    ElseIf KeyboardPushed(#PB_Key_Right)
      MoveEntity(1, 1 * Speed, 0, 0)
      Angle = 0
      RobotMove = #True
      
    ElseIf KeyboardPushed(#PB_Key_Up)
      MoveEntity(1, 0, 0, -1 * Speed)
      Angle = 90
      RobotMove = #True
      
    ElseIf KeyboardPushed(#PB_Key_Down)
      MoveEntity(1, 0, 0, 1 * Speed)
      Angle = -90
      RobotMove = #True
    EndIf
    
    If KeyboardPushed(#PB_Key_PageUp) And Speed < 1.0
      Speed + 0.05
    ElseIf KeyboardPushed(#PB_Key_PageDown) And Speed > 0.1
      Speed - 0.05
    EndIf
    
  EndIf
  
  RotateEntity(1, 0, CurveAngle(EntityYaw(1), Angle, 4 * TimeSinceLastFrame), 0)
  
  If RobotMove
    If Anim <> #Walk
      Anim = #Walk
      Fadein  = #Walk
      FadeOut = #Idle
      StartEntityAnimation(1, Anim(Anim), #PB_EntityAnimation_Manual)
    EndIf
  Else
    If Anim <> #Idle
      Anim = #Idle
      Fadein  = #Idle
      FadeOut = #Walk
      StartEntityAnimation(1, Anim(Anim), #PB_EntityAnimation_Manual)
    EndIf
  EndIf
  
  AddEntityAnimationTime(1, Anim(Anim), TimeSinceLastFrame)
  fadeAnimations(TimeSinceLastFrame / 1000.0)
  
  RotateCamera(0, MouseY, MouseX, 0, #PB_Relative)
  
  TimeSinceLastFrame = RenderWorld() * Speed
  
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1


Procedure fadeAnimations(deltaTime.f)
  Protected.f newWeight
  
  If FadeIn
    
    ; slowly fade this animation in Until it has full weight
    newWeight = GetEntityAnimationWeight(1, Anim(FadeIn)) + deltaTime * #ANIM_FADE_SPEED
    Clamp(newWeight, 0, 1)
    SetEntityAnimationWeight(1, Anim(FadeIn), newWeight)
    If newWeight >= 1
      FadeIn = #False
    EndIf
    
  EndIf
  
  If FadeOut
    
    ; slowly fade this animation out Until it has no weight, And then disable it
    newWeight.f = GetEntityAnimationWeight(1, Anim(FadeOut)) - deltaTime * #ANIM_FADE_SPEED
    Clamp(newWeight, 0, 1)
    SetEntityAnimationWeight(1, Anim(FadeOut), newWeight)
    If newWeight <= 0
      StopEntityAnimation(1, Anim(FadeOut))
      FadeOut = #False
    EndIf
  EndIf
  
EndProcedure

Procedure.f WrapPi(Angle.f)
  Angle + 180
  Angle - Round(Angle * 1/360.0, #PB_Round_Down) * 360
  Angle - 180
  ProcedureReturn Angle
EndProcedure

Procedure.f CurveAngle(Actuelle.f, Target.f, P.f)
  Delta.f = WrapPi(Target-Actuelle)
  If P > 1000 : P = 1000 : EndIf
  Valeur.f = Actuelle + (Delta * P / 1000)
  ProcedureReturn WrapPi(Valeur)
EndProcedure
