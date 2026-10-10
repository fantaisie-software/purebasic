;
; ------------------------------------------------------------
;
;   PureBasic - Character
;
;   Adapted from the Character demo of the OGRE SDK
;
; ------------------------------------------------------------
;
; A third person character: Sinbad runs, jumps, draws his swords, slices and dances.
; His lower body ("base") and upper body ("top") have their own animations, played together.
;
;   [Up][Down]           Run forward or backward
;   [Left][Right]        Turn, the camera follows behind him
;   [Space]              Jump
;   [Q]                  Draw or sheathe the swords
;   Mouse buttons        Slice vertically (left) or horizontally (right), when the swords are drawn
;   [E]                  Start or stop dancing, when the swords are sheathed
;   Mouse                Turn the camera around Sinbad, the wheel zooms
;   [PageUp][PageDown]   Slow motion
;

#CHAR_HEIGHT     = 5    ; Height of Sinbad's center above the ground
#CAM_HEIGHT      = 2    ; Height of the point the camera looks at (his shoulders), above his center
#RUN_SPEED       = 17   ; In units per second (half of it backward)
#TURN_SPEED      = 180  ; In degrees per second
#ANIM_FADE_SPEED = 7.5  ; How fast an animation fades in or out (full weight per second)
#JUMP_SPEED      = 30   ; Vertical speed given by a jump, in units per second
#GRAVITY         = 90   ; In units per second squared

Enumeration ; Meshes
  #GroundMesh
  #SinbadMesh
  #SwordMesh
EndEnumeration

Enumeration ; Materials
  #GroundMaterial
  #TrailMaterial
EndEnumeration

Enumeration ; Entities
  #Ground
  #Sinbad
  #LeftSword
  #RightSword
EndEnumeration

Enumeration ; Nodes
  #BodyNode    ; Sinbad's position and orientation
  #CameraPivot ; At Sinbad's shoulders, the camera looks at it
EndEnumeration

#Camera     = 0
#SwordTrail = 0 ; Ribbon effect behind the swords

Macro Clamp(Value, Min, Max)
  If Value < Min
    Value = Min
  ElseIf Value > Max
    Value = Max
  EndIf
EndMacro

Global BaseAnim$, TopAnim$ ; Current lower and upper body animations (for example "RunBase" and "SliceVertical"), "" for none
Global NewMap Fading.i()   ; Animations being faded in (+1) or out (-1)
Global Timer.f             ; How long the current special animation (jump, draw swords, slice) has played, in seconds
Global SwordsDrawn         ; #True when the swords are in his hands
Global KeyRun, KeyTurn     ; Wanted by the player: KeyRun is 1 forward, -1 backward. KeyTurn is 1 to the left, -1 to the right.
Global VerticalSpeed.f     ; While jumping

; Camera position around Sinbad, changed with the mouse (OrbitYaw = 0 is behind him)
Global OrbitYaw.f, OrbitPitch.f
Global OrbitDistance.f = 15


;- Animations

; Returns the animation length, in seconds
Procedure.f AnimationLength(Name$)
  ProcedureReturn GetEntityAnimationLength(#Sinbad, Name$) / 1000
EndProcedure

; Starts an animation with no weight, it fades in
Procedure StartAnimation(Name$, Restart)
  Protected Flags = #PB_EntityAnimation_Manual ; Its time is changed with AddEntityAnimationTime()

  If Name$ <> ""
    If Restart = #False
      Flags | #PB_EntityAnimation_Continue
    EndIf
    StartEntityAnimation(#Sinbad, Name$, Flags)
    SetEntityAnimationWeight(#Sinbad, Name$, 0)
    Fading(Name$) = 1
  EndIf
EndProcedure

; The animation fades out, and is stopped when it has no weight anymore
Procedure StopAnimation(Name$)
  If Name$ <> ""
    Fading(Name$) = -1
  EndIf
EndProcedure

Procedure SetBaseAnimation(Name$, Restart = #False)
  StopAnimation(BaseAnim$)
  BaseAnim$ = Name$
  StartAnimation(Name$, Restart)
EndProcedure

Procedure SetTopAnimation(Name$, Restart = #False)
  StopAnimation(TopAnim$)
  TopAnim$ = Name$
  StartAnimation(Name$, Restart)
EndProcedure

; Smooth transitions between the animations
Procedure FadeAnimations(ElapsedTime.f)
  Protected Name$, Weight.f

  ForEach Fading()
    Name$ = MapKey(Fading())
    Weight = GetEntityAnimationWeight(#Sinbad, Name$) + Fading() * #ANIM_FADE_SPEED * ElapsedTime

    If Fading() = 1 And Weight >= 1      ; Fully faded in
      SetEntityAnimationWeight(#Sinbad, Name$, 1)
      DeleteMapElement(Fading())
    ElseIf Fading() = -1 And Weight <= 0 ; Fully faded out
      StopEntityAnimation(#Sinbad, Name$)
      DeleteMapElement(Fading())
    Else
      SetEntityAnimationWeight(#Sinbad, Name$, Weight)
    EndIf
  Next
EndProcedure

; #True if Sinbad only stands or runs (he isn't jumping, slicing...)
Procedure IsFree()
  ProcedureReturn Bool(TopAnim$ = "IdleTop" Or TopAnim$ = "RunTop")
EndProcedure

; After a special upper body animation, back to standing or running
Procedure EndTopAnimation()
  If BaseAnim$ = "IdleBase"
    SetTopAnimation("IdleTop")
  Else
    SetTopAnimation("RunTop")
    SetEntityAnimationTime(#Sinbad, "RunTop", GetEntityAnimationTime(#Sinbad, "RunBase")) ; In step with the legs
  EndIf
EndProcedure

; Moves the swords from the sheaths to the hands, or back
Procedure SwapSwords()
  If SwordsDrawn
    ; Put them back in the sheaths, without their light trails
    HideEffect(#SwordTrail, #True)
    DetachRibbonEffect(#SwordTrail, EntityParentNode(#LeftSword))
    DetachRibbonEffect(#SwordTrail, EntityParentNode(#RightSword))
    DetachEntityObject(#Sinbad, EntityID(#LeftSword))
    DetachEntityObject(#Sinbad, EntityID(#RightSword))
    AttachEntityObject(#Sinbad, "Sheath.L", EntityID(#LeftSword))
    AttachEntityObject(#Sinbad, "Sheath.R", EntityID(#RightSword))

    StopEntityAnimation(#Sinbad, "HandsClosed")
    StartEntityAnimation(#Sinbad, "HandsRelaxed", #PB_EntityAnimation_Manual)
  Else
    ; Put them in the hands, with light trails
    DetachEntityObject(#Sinbad, EntityID(#LeftSword))
    DetachEntityObject(#Sinbad, EntityID(#RightSword))
    AttachEntityObject(#Sinbad, "Handle.L", EntityID(#LeftSword))
    AttachEntityObject(#Sinbad, "Handle.R", EntityID(#RightSword))
    AttachRibbonEffect(#SwordTrail, EntityParentNode(#LeftSword))
    AttachRibbonEffect(#SwordTrail, EntityParentNode(#RightSword))
    HideEffect(#SwordTrail, #False)

    StartEntityAnimation(#Sinbad, "HandsClosed", #PB_EntityAnimation_Manual)
    StopEntityAnimation(#Sinbad, "HandsRelaxed")
  EndIf
EndProcedure

Procedure UpdateAnimations(ElapsedTime.f)
  Protected BaseSpeed.f = 1, TopSpeed.f = 1

  Timer + ElapsedTime

  Select TopAnim$
    Case "DrawSwords"
      If SwordsDrawn
        TopSpeed = -1 ; Played backward to sheathe the swords
      EndIf

      ; Half-way through the animation, the hands reach the handles
      If Timer >= AnimationLength(TopAnim$) / 2 And Timer - ElapsedTime < AnimationLength(TopAnim$) / 2
        SwapSwords()
      EndIf

      If Timer >= AnimationLength(TopAnim$)
        SwordsDrawn = Bool(SwordsDrawn = #False)
        EndTopAnimation()
      EndIf

    Case "SliceVertical", "SliceHorizontal"
      If Timer >= AnimationLength(TopAnim$)
        EndTopAnimation()
      EndIf

      If BaseAnim$ = "IdleBase"
        BaseSpeed = 0 ; Don't sway the hips while slicing
      EndIf
  EndSelect

  Select BaseAnim$
    Case "JumpStart"
      If Timer >= AnimationLength(BaseAnim$) ; Takeoff finished: leave the ground
        SetBaseAnimation("JumpLoop", #True)
        VerticalSpeed = #JUMP_SPEED
      EndIf

    Case "JumpEnd"
      If Timer >= AnimationLength(BaseAnim$) ; Landing finished: stand or run again
        If KeyRun = 0
          SetBaseAnimation("IdleBase")
          SetTopAnimation("IdleTop")
        Else
          SetBaseAnimation("RunBase", #True)
          SetTopAnimation("RunTop", #True)
        EndIf
      EndIf
  EndSelect

  ; Running backward: the run animation is played backward, at half speed
  If KeyRun = -1
    If BaseAnim$ = "RunBase"
      BaseSpeed = -0.5
    EndIf
    If TopAnim$ = "RunTop"
      TopSpeed = -0.5
    EndIf
  EndIf

  If BaseAnim$ <> ""
    AddEntityAnimationTime(#Sinbad, BaseAnim$, ElapsedTime * BaseSpeed * 1000)
  EndIf
  If TopAnim$ <> ""
    AddEntityAnimationTime(#Sinbad, TopAnim$, ElapsedTime * TopSpeed * 1000)
  EndIf

  FadeAnimations(ElapsedTime)
EndProcedure


;- Player input

Procedure HandleKeyboard()
  If KeyboardReleased(#PB_Key_Q) And IsFree()
    ; Draw the swords, or sheathe them (it is the same animation, played backward)
    SetTopAnimation("DrawSwords", #True)
    Timer = 0

  ElseIf KeyboardReleased(#PB_Key_E) And SwordsDrawn = #False
    If IsFree()
      SetBaseAnimation("Dance", #True)
      SetTopAnimation("")
      StopEntityAnimation(#Sinbad, "HandsRelaxed") ; The dance moves the hands too
    ElseIf BaseAnim$ = "Dance"
      SetBaseAnimation("IdleBase")
      SetTopAnimation("IdleTop")
      StartEntityAnimation(#Sinbad, "HandsRelaxed", #PB_EntityAnimation_Manual)
    EndIf
  EndIf

  ; Movement wanted by the player
  KeyRun = 0
  If KeyboardPushed(#PB_Key_Up)
    KeyRun = 1
  ElseIf KeyboardPushed(#PB_Key_Down)
    KeyRun = -1
  EndIf

  KeyTurn = 0
  If KeyboardPushed(#PB_Key_Left)
    KeyTurn = 1
  ElseIf KeyboardPushed(#PB_Key_Right)
    KeyTurn = -1
  EndIf

  If KeyboardPushed(#PB_Key_Space) And IsFree()
    SetBaseAnimation("JumpStart", #True)
    SetTopAnimation("")
    Timer = 0
  EndIf

  ; Start or stop running
  If KeyRun And BaseAnim$ = "IdleBase"
    SetBaseAnimation("RunBase", #True)
    If TopAnim$ = "IdleTop"
      SetTopAnimation("RunTop", #True)
    EndIf
  ElseIf KeyRun = 0 And BaseAnim$ = "RunBase"
    SetBaseAnimation("IdleBase")
    If TopAnim$ = "RunTop"
      SetTopAnimation("IdleTop")
    EndIf
  EndIf
EndProcedure

Procedure HandleMouse()
  ; Turn the camera around Sinbad, and zoom
  OrbitYaw - MouseDeltaX() * 0.3
  OrbitPitch - MouseDeltaY() * 0.3
  Clamp(OrbitPitch, -60, 25)
  OrbitDistance - MouseWheel() * 0.05 * OrbitDistance
  Clamp(OrbitDistance, 8, 25)

  ; Slice, when the swords are drawn
  If SwordsDrawn And IsFree()
    If MouseButton(#PB_MouseButton_Left)
      SetTopAnimation("SliceVertical", #True)
      Timer = 0
    ElseIf MouseButton(#PB_MouseButton_Right)
      SetTopAnimation("SliceHorizontal", #True)
      Timer = 0
    EndIf
  EndIf
EndProcedure


;- Movement and camera

Procedure MoveSinbad(ElapsedTime.f)
  Protected Turn.f, Speed.f

  If BaseAnim$ <> "Dance"
    ; Turn (5 times slower in the air). The camera follows, as it stays behind him.
    If KeyTurn
      Turn = KeyTurn * #TURN_SPEED * ElapsedTime
      If BaseAnim$ = "JumpLoop"
        Turn * 0.2
      EndIf
      RotateNode(#BodyNode, 0, Turn, 0, #PB_Relative)
    EndIf

    ; Run where he looks (+Z, in his own space), or backward at half speed.
    ; The speed follows the run animation weight, to start smoothly.
    If KeyRun
      Speed = #RUN_SPEED * ElapsedTime * GetEntityAnimationWeight(#Sinbad, BaseAnim$)
      If KeyRun = -1
        Speed * -0.5
      EndIf
      MoveNode(#BodyNode, 0, 0, Speed, #PB_Relative | #PB_Local)
    EndIf
  EndIf

  If BaseAnim$ = "JumpLoop"
    ; In the air: move up or down, and apply the gravity
    MoveNode(#BodyNode, 0, VerticalSpeed * ElapsedTime, 0, #PB_Relative | #PB_World)
    VerticalSpeed - #GRAVITY * ElapsedTime

    If NodeY(#BodyNode) <= #CHAR_HEIGHT ; Back on the ground
      MoveNode(#BodyNode, NodeX(#BodyNode), #CHAR_HEIGHT, NodeZ(#BodyNode), #PB_Absolute | #PB_World)
      SetBaseAnimation("JumpEnd", #True)
      Timer = 0
    EndIf
  EndIf
EndProcedure

Procedure FollowSinbad(ElapsedTime.f)
  ; The angle of CameraFollow() is relative to Sinbad, so the camera turns with him. The angle 0 is behind
  ; an object looking along -Z, but Sinbad looks along +Z, so add 180 degrees to stay behind him.
  Protected Angle.f    = 180 + OrbitYaw
  Protected Distance.f = OrbitDistance * Cos(Radian(OrbitPitch))
  Protected Height.f   = NodeY(#CameraPivot) - OrbitDistance * Sin(Radian(OrbitPitch))

  ; Smoothly move the camera to its place, always looking at Sinbad's shoulders
  CameraFollow(#Camera, NodeID(#CameraPivot), Angle, Height, Distance, ElapsedTime * 9, ElapsedTime * 9, #True)
EndProcedure


InitEngine3D()
InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), "Character - [Arrows] Run, turn  [Space] Jump  [Q] Swords  [Mouse] Camera, slice  [E] Dance  [PageUp][PageDown] Slow motion  [Esc] Quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures"        , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models"          , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts"         , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/Sinbad.zip", #PB_3DArchive_Zip)
Parse3DScripts()

WorldShadows(#PB_Shadow_Additive)

;- Ground
CreateMaterial(#GroundMaterial, TextureID(LoadTexture(#PB_Any, "Dirt.jpg")))
CreatePlane(#GroundMesh, 500, 500, 1, 1, 25, 25)
CreateEntity(#Ground, MeshID(#GroundMesh), MaterialID(#GroundMaterial))
EntityRenderMode(#Ground, 0) ; The ground doesn't cast shadows

;- Light, fog and sky
CreateLight(0, RGB(255, 255, 255), -10, 40, 20, #PB_Light_Point)
SetLightColor(0, #PB_Light_SpecularColor, RGB(255, 255, 255))
AmbientColor(RGB(76, 76, 76))
Fog(RGB(255, 255, 204), 1, 0, 25000)
SkyBox("desert07.jpg")

;- Sinbad
CreateNode(#BodyNode, 0, #CHAR_HEIGHT, 0)
LoadMesh(#SinbadMesh, "Sinbad.mesh")
CreateEntity(#Sinbad, MeshID(#SinbadMesh), #PB_Material_None)
AttachNodeObject(#BodyNode, EntityID(#Sinbad))

; The swords, in their sheaths
LoadMesh(#SwordMesh, "Sword.mesh")
CreateEntity(#LeftSword, MeshID(#SwordMesh), #PB_Material_None)
CreateEntity(#RightSword, MeshID(#SwordMesh), #PB_Material_None)
AttachEntityObject(#Sinbad, "Sheath.L", EntityID(#LeftSword))
AttachEntityObject(#Sinbad, "Sheath.R", EntityID(#RightSword))

; Light trails behind the swords (2 chains, one per sword), shown when they are drawn
GetScriptMaterial(#TrailMaterial, "Examples/LightRibbonTrail")
CreateRibbonEffect(#SwordTrail, MaterialID(#TrailMaterial), 2, 80, 20)
For i = 0 To 1
  RibbonEffectColor(#SwordTrail, i, RGBA(204, 204, 0, 255), RGBA(1, 255, 255, 5))
  RibbonEffectWidth(#SwordTrail, i, 0.5, 1)
Next
HideEffect(#SwordTrail, #True)

; The animations are added to each other (Sinbad's animations are made for this)
EntityAnimationBlendMode(#Sinbad, #PB_EntityAnimation_Cumulative)
SetBaseAnimation("IdleBase")
SetTopAnimation("IdleTop")
StartEntityAnimation(#Sinbad, "HandsRelaxed", #PB_EntityAnimation_Manual) ; No sword in the hands

;- Camera
CreateCamera(#Camera, 0, 0, 100, 100)
CameraRange(#Camera, 0.1, 10000) ; Sinbad is quite small, so the camera can be very close
CreateNode(#CameraPivot, 0, #CAM_HEIGHT, 0)
AttachNodeObject(#BodyNode, NodeID(#CameraPivot))
FollowSinbad(1) ; Puts the camera directly at its place

KeyboardMode(#PB_Keyboard_International)

;- Main loop
Define ElapsedTime.f       ; Time of the last frame, in seconds
Define AnimationSpeed.f = 1 ; Less than 1 for a slow motion

Repeat
  While WindowEvent() : Wend

  ExamineMouse()
  HandleMouse()

  ExamineKeyboard()
  HandleKeyboard()
  If KeyboardReleased(#PB_Key_PageUp) And AnimationSpeed < 1
    AnimationSpeed + 0.1
  ElseIf KeyboardReleased(#PB_Key_PageDown) And AnimationSpeed > 0.1
    AnimationSpeed - 0.1
  EndIf

  MoveSinbad(ElapsedTime)
  UpdateAnimations(ElapsedTime)
  FollowSinbad(ElapsedTime)

  ElapsedTime = RenderWorld() / 1000 * AnimationSpeed
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape)
