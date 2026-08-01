;
; ------------------------------------------------------------
;
;   PureBasic - Animation Entity
;
;   Adapted from Character demo (Ogre SDK)
;
; ------------------------------------------------------------
;

;Description = A demo showing 3rd-person character control
;
;Use the cursor keys To move Sinbad, And the space bar To jump.
;Use mouse To look around And mouse wheel To zoom.
;Press [Q] To take out Or put back Sinbad's swords.
;With the swords equipped, you can left click To slice vertically Or right click To slice horizontally.
;When the swords are Not equipped, press [E] To start/stop a silly dance routine.

; [PgUp]&[Pgdown] = Speed animation

#PB_Shadow_TextureModulative = 5

#NUM_ANIMS       = 13   ; number of animations the character has
#CHAR_HEIGHT     = 5    ; height of character's center of mass above ground
#CAM_HEIGHT      = 2    ; height of camera above character's center of mass
#RUN_SPEED       = 17   ; character running speed in units per second
#TURN_SPEED      = 500.0; character turning in degrees per second
#ANIM_FADE_SPEED = 7.5  ; animation crossfade speed in % of full weight per second
#JUMP_ACCEL      = 30.0 ; character jump acceleration in upward units per squared second
#GRAVITY         = 90.0 ; gravity in downward units per squared second

; all the animations our character has, And a null ID
; some of these affect separate body parts And will be blended together
Enumeration
  #ANIM_IDLE_BASE
  #ANIM_IDLE_TOP
  #ANIM_RUN_BASE
  #ANIM_RUN_TOP
  #ANIM_HANDS_CLOSED
  #ANIM_HANDS_RELAXED
  #ANIM_DRAW_SWORDS
  #ANIM_SLICE_VERTICAL
  #ANIM_SLICE_HORIZONTAL
  #ANIM_DANCE
  #ANIM_JUMP_START
  #ANIM_JUMP_LOOP
  #ANIM_JUMP_END
  #ANIM_NONE
EndEnumeration

Macro Clamp(num, min, max)
  If num<min
    num=min
  ElseIf num>max
    num=max
  EndIf
EndMacro

Structure s_Key
  Up.i
  Down.i
  Left.i
  Right.i
  Sword.i
  Dance.i
  Jump.i
EndStructure

Structure s_Entity
  Key.s_Key
  Camera.i
  BodyNode.i
  Direction.i
  CameraPivot.i
  CameraPitch.i
  CameraGoal.i
  CameraNode.i
  PivotPitch.f
  BodyEnt.i
  Sword1.i
  Sword2.i
  SwordTrail.i
  SwordTrail2.i
  Anims.s[#NUM_ANIMS]              ; master animation list
  BaseAnimID.i                     ; current base (full- or lower-body) animation
  TopAnimID.i                      ; current top (upper-body) animation
  FadingIn.i[#NUM_ANIMS]           ; which animations are fading in
  FadingOut.i[#NUM_ANIMS]          ; which animations are fading out
  SwordsDrawn.i
  KeyDirection.Vector3             ; player's local intended direction
  GoalDirection.Vector3            ; actual intended direction in world-space
  VerticalVelocity.f               ; for jumping
  Timer.f                          ; general timer to see how long animations have been playing
EndStructure

Macro Vector3_ZERO(V)
  V\x = 0
  V\y = 0
  V\z = 0
EndMacro

Macro LengthVector3(V)
  (V\x * V\x + V\y * V\y + V\z * V\z)
EndMacro

Macro GetNodePosition(Position, Node)
  Position\x = NodeX(Node)
  Position\y = NodeY(Node)
  Position\z = NodeZ(Node)
EndMacro

Macro SubVector3(V, V1, V2)
  V\x = V1\x - V2\x
  V\y = V1\y - V2\y
  V\z = V1\z - V2\z
EndMacro

;-Declare
Declare injectKeyDown()
Declare injectKeyUp()
Declare injectMouseMove()
Declare injectMouseDown()
Declare setupBody()
Declare setupCamera()
Declare setupAnimations()
Declare fadeAnimations(deltaTime.f)
Declare updateBody(deltaTime.f)
Declare updateAnimations(deltaTime.f)
Declare updateCamera(deltatime.f)
Declare updateCameraGoal(deltaYaw.f, deltaPitch.f, deltaZoom.f)
Declare setBaseAnimation(id.i, reset.i = #False)
Declare setTopAnimation(id.i, reset.i = #False)

Define.f KeyX, KeyY, MouseX, MouseY, deltaTime, Ralenti = 1.0, TimeSinceLastFrame
Global Sinbad.s_Entity

InitEngine3D()
InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), "Animation Entity [PageUp]   [PageDown] [E]   [Q]   [Space]  [Esc] Quit  ",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Main"        , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures"        , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models"          , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts"          , #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/Sinbad.zip", #PB_3DArchive_Zip)
Parse3DScripts()

; WorldShadows(#PB_Shadow_Additive)

;-Ground
;
CreateMaterial(0, LoadTexture(0, "Dirt.jpg"))
CreatePlane(0, 500, 500, 1, 1, 25, 25)
CreateEntity(0,MeshID(0),MaterialID(0))
EntityRenderMode(0, 0)
GetScriptMaterial(1, "Examples/LightRibbonTrail")

;- Light
CreateLight(0, RGB(255, 255, 255), -10, 40, 20, #PB_Light_Point)
SetLightColor(0, #PB_Light_SpecularColor, RGB(255, 255, 255))

AmbientColor(RGB(255*0.3, 255*0.3, 255*0.3))

;- Skybox
Fog(RGB(255,255,255*0.8), 1, 0, 25000)
SkyBox("desert07.jpg")

setupBody()
setupCamera()
setupAnimations()

KeyboardMode(#PB_Keyboard_International)

;->> Main Loop
Repeat
  
  While WindowEvent():Wend
  
  If ExamineMouse()
    injectMouseMove()
    injectMouseDown()
  EndIf
  
  
  If ExamineKeyboard()
    injectKeyDown()
    injectKeyUp()
    
    If KeyboardReleased(#PB_Key_PageUp) And Ralenti < 1.0
      Ralenti + 0.1
    ElseIf KeyboardReleased(#PB_Key_PageDown) And Ralenti > 0.1
      Ralenti - 0.1
    EndIf
    
  EndIf
  
  deltaTime = TimeSinceLastFrame * Ralenti / 1000.0
  updateBody(deltaTime)
  updateAnimations(deltaTime)
  updateCamera(deltaTime)
  
  TimeSinceLastFrame = RenderWorld()
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1

End

Procedure.f Distance(*V1.Vector3, *V2.Vector3)
  Protected V.Vector3
  V\x = *V2\x - *V1\x
  V\y = *V2\y - *V1\y
  V\z = *V2\z - *V1\z
  ProcedureReturn Sqr((V\x * V\x) + (V\y * V\y) + (V\z * V\z))
EndProcedure

Procedure injectKeyDown()
  With Sinbad
    If KeyboardReleased(\Key\Sword) And (\TopAnimID = #ANIM_IDLE_TOP Or \TopAnimID = #ANIM_RUN_TOP)
      
      ;take swords out (Or put them back, since it's the same animation but reversed)
      setTopAnimation(#ANIM_DRAW_SWORDS, #True)
      \Timer = 0;
      
    ElseIf KeyboardReleased(\Key\Dance) And \SwordsDrawn=0
      
      If (\TopAnimID = #ANIM_IDLE_TOP Or \TopAnimID = #ANIM_RUN_TOP)
        
        ; start dancing
        setBaseAnimation(#ANIM_DANCE, #True)
        setTopAnimation(#ANIM_NONE);
                                   ; disable hand animation because the dance controls hands
        StopEntityAnimation(\BodyEnt, \Anims[#ANIM_HANDS_RELAXED])
        
      ElseIf (\BaseAnimID = #ANIM_DANCE)
        
        ; stop dancing
        setBaseAnimation(#ANIM_IDLE_BASE)
        setTopAnimation(#ANIM_IDLE_TOP)
        ; re-enable hand animation
        StartEntityAnimation(\BodyEnt, \Anims[#ANIM_HANDS_RELAXED], #PB_EntityAnimation_Manual)
      EndIf
      
      
      ; keep track of the player's intended direction
    Else
      
      If KeyboardPushed(#PB_Key_Up)
        \KeyDirection\z = -1
      ElseIf KeyboardPushed(#PB_Key_Down)
        \KeyDirection\z = 1
      Else
        \KeyDirection\z = 0
      EndIf
      
      If KeyboardPushed(#PB_Key_Left)
        \KeyDirection\x = -1
      ElseIf KeyboardPushed(#PB_Key_Right)
        \KeyDirection\x = 1
      Else
        \KeyDirection\x = 0
      EndIf
    EndIf
    
    
    If KeyboardPushed(\Key\Jump) And (\TopAnimID = #ANIM_IDLE_TOP Or \TopAnimID = #ANIM_RUN_TOP)
      
      ;/ jump If on ground
      setBaseAnimation(#ANIM_JUMP_START, #True)
      setTopAnimation(#ANIM_NONE)
      \Timer = 0;
    EndIf
    
    If LengthVector3(\KeyDirection) And \BaseAnimID = #ANIM_IDLE_BASE
      
      ; start running If Not already moving And the player wants To move
      setBaseAnimation(#ANIM_RUN_BASE, #True)
      If (\TopAnimID = #ANIM_IDLE_TOP)
        setTopAnimation(#ANIM_RUN_TOP, #True)
      EndIf
    EndIf
  EndWith
  
EndProcedure

Procedure injectKeyUp()
  With Sinbad
    If LengthVector3(\KeyDirection)=0 And \BaseAnimID = #ANIM_RUN_BASE
      
      ; stop running If already moving And the player doesn't want to move
      setBaseAnimation(#ANIM_IDLE_BASE)
      If (\TopAnimID = #ANIM_RUN_TOP)
        setTopAnimation(#ANIM_IDLE_TOP)
      EndIf
    EndIf
  EndWith
EndProcedure

Procedure injectMouseMove()
  ; update camera goal based on mouse movement
  updateCameraGoal(-0.005 * MouseDeltaX(), -0.005 * MouseDeltaY(), -0.05 * MouseWheel())
EndProcedure

Procedure injectMouseDown()
  With sinbad
    If \SwordsDrawn And (\TopAnimID = #ANIM_IDLE_TOP Or \TopAnimID = #ANIM_RUN_TOP)
      
      ; If swords are out, And character's not doing something weird, then SLICE!
      If MouseButton(#PB_MouseButton_Left)
        setTopAnimation(#ANIM_SLICE_VERTICAL, #True)
      ElseIf MouseButton(#PB_MouseButton_Right)
        setTopAnimation(#ANIM_SLICE_HORIZONTAL, #True)
      EndIf
      \Timer = 0
    EndIf
  EndWith
EndProcedure

Procedure setupBody()
  With Sinbad
    \Key\Down        = #PB_Key_Down
    \Key\Left        = #PB_Key_Left
    \Key\Right       = #PB_Key_Right
    \Key\Up          = #PB_Key_Up
    \Key\Sword       = #PB_Key_Q
    \Key\Dance       = #PB_Key_E
    \Key\Jump        = #PB_Key_Space
    
    ; create main model
    \BodyNode = CreateNode(#PB_Any, 0, #CHAR_HEIGHT, 0)
    \Direction = CreateNode(#PB_Any, 0, 0, 1)
    \BodyEnt = CreateEntity(#PB_Any, MeshID(LoadMesh(#PB_Any, "Sinbad.mesh")), #PB_Material_None)
    
    AttachNodeObject(\BodyNode, EntityID(\BodyEnt))
    AttachNodeObject(\BodyNode, NodeID(\Direction))
    ; create swords And attach To sheath
    Sword = LoadMesh(#PB_Any, "Sword.mesh")
    \Sword1 = CreateEntity(#PB_Any, MeshID(Sword), #PB_Material_None)
    \Sword2 = CreateEntity(#PB_Any, MeshID(Sword), #PB_Material_None)
    AttachEntityObject(\BodyEnt, "Sheath.L", EntityID(\Sword1))
    AttachEntityObject(\BodyEnt, "Sheath.R", EntityID(\Sword2))
    
    ;create a couple of ribbon trails For the swords, just For fun
    \SwordTrail = CreateRibbonEffect(#PB_Any, MaterialID(1), 2, 80, 20)
    
    For i = 0 To 1
      RibbonEffectColor(\SwordTrail, i, RGBA(255*0.8, 255*0.8, 0, 255), RGBA(1, 255, 255, 5))
      RibbonEffectWidth(\SwordTrail, i, 0.5, 1)
    Next
    HideEffect(\SwordTrail, #False)
    
    Vector3_ZERO(\KeyDirection)
    \VerticalVelocity = 0
  EndWith
EndProcedure

Procedure setupAnimations()
  With Sinbad
    ; this is very important due To the nature of the exported animations
    EntityAnimationBlendMode(\BodyEnt, #PB_EntityAnimation_Cumulative)
    
    animNames$ = "IdleBase,IdleTop,RunBase,RunTop,HandsClosed,HandsRelaxed,DrawSwords,SliceVertical,SliceHorizontal,Dance,JumpStart,JumpLoop,JumpEnd"
    
    ; populate our animation List
    For i = 0 To #NUM_ANIMS-1
      \Anims[i] = StringField(animNames$, i+1, ",")
      \FadingIn[i] = #False
      \FadingOut[i] = #False
    Next
    
    ; start off in the idle state (top And bottom together)
    setBaseAnimation(#ANIM_IDLE_BASE)
    setTopAnimation(#ANIM_IDLE_TOP)
    
    ; relax the hands since we're not holding anything
    StartEntityAnimation(\BodyEnt, \Anims[#ANIM_HANDS_RELAXED], #PB_EntityAnimation_Manual)
    
    \SwordsDrawn = #False
  EndWith
EndProcedure

Procedure setupCamera()
  With Sinbad
    
    \Camera = CreateCamera(#PB_Any, 0, 0, 100, 100)
    ; our model is quite small, so reduce the clipping planes
    CameraRange(\Camera, 0.1, 10000)
    ;CameraBackColor(\Camera, RGB(255, 255, 255*0.8))
    
    ; create a pivot at roughly the character's shoulder
    \CameraPivot = CreateNode(#PB_Any)
    \CameraPitch = CreateNode(#PB_Any)
    ; this is where the camera should be soon, And it spins around the pivot
    \CameraGoal = CreateNode(#PB_Any, 0, 0, 15)
    AttachNodeObject(\CameraPivot, NodeID(\CameraPitch))
    AttachNodeObject(\CameraPitch, NodeID(\CameraGoal))
    ; this is where the camera actually is
    \CameraNode = CreateNode(#PB_Any)
    MoveNode(\CameraNode, NodeX(\CameraPivot) + NodeX(\CameraGoal), NodeY(\CameraPivot) + NodeY(\CameraGoal), NodeZ(\CameraPivot) + NodeZ(\CameraGoal), #PB_Absolute)
    
    NodeFixedYawAxis(\CameraPivot, #True)
    NodeFixedYawAxis(\CameraGoal , #True)
    NodeFixedYawAxis(\CameraNode , #True)
    
    AttachNodeObject(\CameraNode, CameraID(\Camera))
    
    \PivotPitch = 0
  EndWith
EndProcedure

Procedure Normalize(*V.Vector3)
  Define.f magSq, oneOverMag
  
  magSq = *V\x * *V\x + *V\y * *V\y + *V\z * *V\z
  If magsq > 0
    oneOverMag = 1.0 / Sqr(magSq)
    *V\x * oneOverMag
    *V\y * oneOverMag
    *V\z * oneOverMag
  EndIf
  
EndProcedure

Procedure.f WrapPi(Angle.f)
  Angle + 180
  Angle - Round(Angle * 1/360.0, #PB_Round_Down) * 360
  Angle - 180
  ProcedureReturn Angle
EndProcedure

Procedure.f CurveAngle( Actuelle.f , Cible.f , P.f )
  Delta.f = WrapPi(Cible-Actuelle)
  If P > 1000 : P = 1000 : EndIf
  Valeur.f = Actuelle + ( Delta * P / 1000 )
  ProcedureReturn WrapPi(Valeur)
EndProcedure

Procedure updateBody(deltaTime.f)
  Protected.Vector3 pos, Dir, PosMain, PosDir
  Protected.f yawToGoal, yawAtSpeed
  
  With sinbad
    Vector3_ZERO(\GoalDirection);  we will calculate this
    
    If (LengthVector3(\KeyDirection) And \BaseAnimID <> #ANIM_DANCE)
      
      ;calculate actually goal direction in world based on player's key directions
      If \KeyDirection\z = 1 ; Backward (and possibly left/right)
        yawToGoal = CameraYaw(\Camera) + \KeyDirection\x * 45 ; Handle left/right as well
        
      ElseIf \KeyDirection\z = -1 ; Forward (and possibly left/right)
        yawToGoal = CameraYaw(\Camera) + 180 - \KeyDirection\x * 45 ; Forward Right
        
      ElseIf \KeyDirection\x = 1 ; Straight Right
        yawToGoal = CameraYaw(\Camera) + 90
        
      ElseIf \KeyDirection\x = -1 ; Straight Left
        yawToGoal = CameraYaw(\Camera) -90
      EndIf
      
      yawToGoal = WrapPi(yawToGoal)
      
      ; calculate how much the character has To turn To face goal direction
      ; reduce "turnability" If we're in midair
      If (\BaseAnimID = #ANIM_JUMP_LOOP)
        yawAtSpeed * 0.2
      EndIf
      
      RotateNode(\BodyNode, 0, CurveAngle(NodeYaw(\BodyNode), yawToGoal, 2000 * deltaTime), 0)
      
      ; move in current body direction (Not the goal direction)
      GetNodePosition(PosMain, \BodyNode)
      GetNodePosition(PosDir, \Direction)
      SubVector3(Dir, PosDir, PosMain)
      Dir\x * deltaTime * #RUN_SPEED * GetEntityAnimationWeight(\BodyEnt, \Anims[\BaseAnimID])
      Dir\y * deltaTime * #RUN_SPEED * GetEntityAnimationWeight(\BodyEnt, \Anims[\BaseAnimID])
      Dir\z * deltaTime * #RUN_SPEED * GetEntityAnimationWeight(\BodyEnt, \Anims[\BaseAnimID])
      MoveNode(\BodyNode, Dir\x, dir\y, Dir\z,#PB_Relative|#PB_World)
    EndIf
    
    If \BaseAnimID = #ANIM_JUMP_LOOP
      
      ; If we're jumping, add a vertical offset too, and apply gravity
      MoveNode(\BodyNode, 0, \VerticalVelocity * deltaTime, 0,#PB_Relative|#PB_World)
      \VerticalVelocity - #GRAVITY * deltaTime
      GetNodePosition(pos, \BodyNode)
      If pos\y <= #CHAR_HEIGHT
        
        ; If we've hit the ground, change to landing state
        pos\y = #CHAR_HEIGHT;
        MoveNode(\BodyNode, pos\x, pos\y, pos\z, #PB_Absolute|#PB_World)
        setBaseAnimation(#ANIM_JUMP_END, #True)
        \Timer = 0;
      EndIf
    EndIf
  EndWith
EndProcedure

Procedure updateAnimations(deltaTime.f)
  With sinbad
    baseAnimSpeed.f = 1
    topAnimSpeed.f = 1
    
    \Timer + deltaTime
    
    If \TopAnimID = #ANIM_DRAW_SWORDS
      
      ; flip the draw swords animation If we need To put it back
      If \SwordsDrawn
        topAnimSpeed = -1
      Else
        topAnimSpeed = 1
      EndIf
      
      ; half-way through the animation is when the hand grasps the handles...
      If (\Timer >= GetEntityAnimationLength(\BodyEnt, \Anims[\TopAnimID]) / 2000.0) And (\Timer - deltaTime < GetEntityAnimationLength(\BodyEnt, \Anims[\TopAnimID]) / 2000.0)
        
        ; so transfer the swords from the sheaths To the hands
        DetachEntityObject(\BodyEnt, EntityID(\Sword1))
        DetachEntityObject(\BodyEnt, EntityID(\Sword2))
        If \SwordsDrawn
          AttachEntityObject(\BodyEnt, "Sheath.L", EntityID(\Sword1))
          AttachEntityObject(\BodyEnt, "Sheath.R", EntityID(\Sword2))
          ; change the hand state To grab Or let go
          StopEntityAnimation(\BodyEnt, \Anims[#ANIM_HANDS_CLOSED])
          StartEntityAnimation(\BodyEnt, \Anims[#ANIM_HANDS_RELAXED], #PB_EntityAnimation_Manual)
        Else
          AttachEntityObject(\BodyEnt, "Handle.L", EntityID(\Sword1))
          AttachEntityObject(\BodyEnt, "Handle.R", EntityID(\Sword2))
          StartEntityAnimation(\BodyEnt, \Anims[#ANIM_HANDS_CLOSED], #PB_EntityAnimation_Manual)
          StopEntityAnimation(\BodyEnt, \Anims[#ANIM_HANDS_RELAXED])
        EndIf
      EndIf
      
      ;toggle sword trails
      If \SwordsDrawn
        
        HideEffect(\SwordTrail, #True)
        DetachRibbonEffect(\SwordTrail, EntityParentNode(\Sword1))
        DetachRibbonEffect(\SwordTrail, EntityParentNode(\Sword2))
        
      Else
        
        HideEffect(\SwordTrail, #False)
        AttachRibbonEffect(\SwordTrail, EntityParentNode(\Sword1))
        AttachRibbonEffect(\SwordTrail, EntityParentNode(\Sword2))
        
      EndIf
      
      If \Timer >= GetEntityAnimationLength(\BodyEnt, \Anims[\TopAnimID]) / 1000
        
        ; animation is finished, so Return To what we were doing before
        If \BaseAnimID = #ANIM_IDLE_BASE
          setTopAnimation(#ANIM_IDLE_TOP)
        Else
          setTopAnimation(#ANIM_RUN_TOP)
          SetEntityAnimationTime(\BodyEnt, \Anims[#ANIM_RUN_TOP], GetEntityAnimationTime(\BodyEnt, \Anims[#ANIM_RUN_BASE]))
        EndIf
        \SwordsDrawn = 1 - \SwordsDrawn
      EndIf
      
    ElseIf \TopAnimID = #ANIM_SLICE_VERTICAL Or \TopAnimID = #ANIM_SLICE_HORIZONTAL
      
      If \Timer >= GetEntityAnimationLength(\BodyEnt, \Anims[\TopAnimID]) / 1000
        
        ; animation is finished, so Return To what we were doing before
        If \BaseAnimID = #ANIM_IDLE_BASE
          setTopAnimation(#ANIM_IDLE_TOP)
        Else
          
          setTopAnimation(#ANIM_RUN_TOP)
          SetEntityAnimationTime(\BodyEnt, \Anims[#ANIM_RUN_TOP], GetEntityAnimationTime(\BodyEnt, \Anims[#ANIM_RUN_BASE]))
        EndIf
      EndIf
      
      ; don't sway hips from side to side when slicing. that's just embarrasing.
      If \BaseAnimID = #ANIM_IDLE_BASE
        baseAnimSpeed = 0
      EndIf
      
    ElseIf \BaseAnimID = #ANIM_JUMP_START
      
      If \Timer >= GetEntityAnimationLength(\BodyEnt, \Anims[\BaseAnimID]) / 1000
        ; takeoff animation finished, so time To leave the ground!
        setBaseAnimation(#ANIM_JUMP_LOOP, #True)
        ; apply a jump acceleration To the character
        \VerticalVelocity = #JUMP_ACCEL;
      EndIf
      
    ElseIf \BaseAnimID = #ANIM_JUMP_END
      
      If \Timer >= GetEntityAnimationLength(\BodyEnt, \Anims[\BaseAnimID]) / 1000
        
        ; safely landed, so go back To running Or idling
        If LengthVector3(\KeyDirection) = 0
          
          setBaseAnimation(#ANIM_IDLE_BASE)
          setTopAnimation(#ANIM_IDLE_TOP)
          
        Else
          setBaseAnimation(#ANIM_RUN_BASE, #True)
          setTopAnimation(#ANIM_RUN_TOP, #True)
        EndIf
      EndIf
    EndIf
    
    ; increment the current base And top animation times
    If \BaseAnimID <> #ANIM_NONE
      AddEntityAnimationTime(\BodyEnt, \Anims[\BaseAnimID], deltaTime * baseAnimSpeed * 1000)
    EndIf
    If \TopAnimID <> #ANIM_NONE
      AddEntityAnimationTime(\BodyEnt, \Anims[\TopAnimID], deltaTime * topAnimSpeed * 1000)
    EndIf
    
    ; apply smooth transitioning between our animations
    fadeAnimations(deltaTime)
  EndWith
EndProcedure

Procedure fadeAnimations(deltaTime.f)
  Protected.f newWeight
  With Sinbad
    For i = 0 To #NUM_ANIMS-1
      
      If \FadingIn[i]
        
        ; slowly fade this animation in Until it has full weight
        newWeight = GetEntityAnimationWeight(\BodyEnt, \Anims[i]) + deltaTime * #ANIM_FADE_SPEED
        Clamp(newWeight, 0, 1)
        SetEntityAnimationWeight(\BodyEnt, \Anims[i], newWeight)
        If newWeight >= 1
          \FadingIn[i] = #False
        EndIf
        
      ElseIf \FadingOut[i]
        
        ; slowly fade this animation out Until it has no weight, And then disable it
        newWeight.f = GetEntityAnimationWeight(\BodyEnt, \Anims[i]) - deltaTime * #ANIM_FADE_SPEED
        Clamp(newWeight, 0, 1)
        SetEntityAnimationWeight(\BodyEnt, \Anims[i], newWeight)
        If newWeight <= 0
          StopEntityAnimation(\BodyEnt, \Anims[i])
          \FadingOut[i] = #False
        EndIf
      EndIf
    Next
  EndWith
EndProcedure

Procedure updateCamera(deltaTime.f)
  Protected.Vector3 goalOffset, mCameraGoalPos, mCameraNodePos
  With Sinbad
    ; place the camera pivot roughly at the character's shoulder
    MoveNode(\CameraPivot, NodeX(\BodyNode), NodeY(\BodyNode) + #CAM_HEIGHT, NodeZ(\BodyNode), #PB_Absolute)
    ;; move the camera smoothly To the goal
    GetNodePosition(mCameraGoalPos, \CameraGoal)
    GetNodePosition(mCameraNodePos, \CameraNode)
    SubVector3(goalOffset, mCameraGoalPos, mCameraNodePos)
    MoveNode(\CameraNode, goalOffset\x * deltaTime * 9.0, goalOffset\y * deltaTime * 9.0, goalOffset\z * deltaTime * 9.0,#PB_Relative)
    ; always look at the pivot
    CameraLookAt(\Camera, NodeX(\CameraPivot), NodeY(\CameraPivot), NodeZ(\CameraPivot))
  EndWith
EndProcedure

Procedure updateCameraGoal(deltaYaw.f, deltaPitch.f, deltaZoom.f)
  Protected.f dist, distChange
  Protected.Vector3 V1, V2
  
  With Sinbad
    RotateNode(\CameraPivot, 0, Degree(deltaYaw), 0, #PB_Relative)
    
    ; bound the pitch
    If (\PivotPitch + Degree(deltaPitch) < 25 And deltaPitch > 0) Or (\PivotPitch + Degree(deltaPitch) > -60 And deltaPitch < 0)
      RotateNode(\CameraPitch, Degree(deltaPitch), 0, 0, #PB_Relative)
      \PivotPitch + Degree(deltaPitch)
    EndIf
    
    GetNodePosition(V1, \CameraPivot)
    GetNodePosition(V2, \CameraGoal)
    dist = Distance(V1, V2)
    distChange = deltaZoom * dist
    ; bound the zoom
    If (dist + distChange > 8 And distChange < 0) Or	(dist + distChange < 25 And distChange > 0)
      
      MoveNode(\CameraGoal, 0, 0, distChange)
    EndIf
  EndWith
EndProcedure

Procedure setBaseAnimation(id.i, reset.i = #False)
  With Sinbad
    If \BaseAnimID >= 0 And \BaseAnimID < #NUM_ANIMS
      
      ; If we have an old animation, fade it out
      \FadingIn[\BaseAnimID] = #False
      \FadingOut[\BaseAnimID] = #True
    EndIf
    
    \BaseAnimID = id
    
    If id <> #ANIM_NONE
      
      ; If we have a new animation, enable it And fade it in
      Flags = #PB_EntityAnimation_Manual
      If reset = #False
        Flags | #PB_EntityAnimation_Continue
      EndIf
      StartEntityAnimation(\BodyEnt, \Anims[id], Flags)
      SetEntityAnimationWeight(\BodyEnt, \Anims[id], 0)
      \FadingOut[id] = #False
      \FadingIn[id] = #True
    EndIf
  EndWith
EndProcedure

Procedure setTopAnimation(id.i, reset.i = #False)
  With Sinbad
    If \TopAnimID >= 0 And \TopAnimID < #NUM_ANIMS
      
      ; If we have an old animation, fade it out
      \FadingIn [\TopAnimID] = #False
      \FadingOut[\TopAnimID] = #True
    EndIf
    
    \TopAnimID = id
    
    If id <> #ANIM_NONE
      
      ; If we have a new animation, enable it And fade it in
      Flags = #PB_EntityAnimation_Manual
      If reset = #False
        Flags | #PB_EntityAnimation_Continue
      EndIf
      
      StartEntityAnimation(\BodyEnt, \Anims[id], Flags)
      SetEntityAnimationWeight(\BodyEnt, \Anims[id], 0)
      \FadingOut[id] = #False
      \FadingIn [id] = #True
    EndIf
  EndWith
EndProcedure
