;
; ------------------------------------------------------------
;
;   PureBasic - Facial animation
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;
;Adapted from facial animation (Ogre SDK)
;
;["Title"] = "Facial Animation"
;["Description"] = "A demonstration of the facial animation feature, using pose animation."
;["Help"] = "Use the checkbox to enable/disable manual animation. "
;"When manual animation is enabled, use the sliders to adjust each pose's influence."
;

Enumeration
  #CheckBox
  #FrameExpressions
  #FrameShapes
EndEnumeration

#Mesh = 0
#Entity = 0

Global mPlayAnimation, Track = 4, KeyFrame = 0
Global Animation$ = "Manual"
Define.f TimeSinceLastFrame

Declare SetupContent()
Declare setupControls()
Declare checkBoxToggled()
Declare sliderMoved(Slider)

Structure s_Slider
  index.i
  text.i
  slider.i
EndStructure

Global NewList Expressions.s_Slider()
Global NewList MouthShapes.s_Slider()

If InitEngine3D()
  
  InitSprite()
  InitKeyboard()
  
  OpenWindow(0, 0, 0, 1000, 600, "Facial Animation", #PB_Window_ScreenCentered | #PB_Window_SystemMenu)
  OpenWindowedScreen(WindowID(0), DesktopScaledX(0), DesktopScaledY(0), DesktopScaledX(800), DesktopScaledY(600), 0, 0, 0)
  
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models", #PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts",#PB_3DArchive_FileSystem)
  Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/GUI", #PB_3DArchive_FileSystem)
  Parse3DScripts()

  SetupContent()
  setupControls()
  checkBoxToggled()
  
  Repeat
    
    Repeat
      Event = WindowEvent()
      
      If Event = #PB_Event_CloseWindow  ; If the user has pressed on the close button
        Quit = 1
      ElseIf Event = #PB_Event_Gadget
        Gadget = EventGadget()
        Select Gadget
          Case #CheckBox
            checkBoxToggled()
          Default
            sliderMoved(Gadget)
        EndSelect
      EndIf
      
    Until Event = 0
    
    ExamineKeyboard()
    TimeSinceLastFrame = RenderWorld() / 1000
    
    FlipBuffers()
    
  Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
  
EndIf

End

Procedure SetupContent()
  
  ; setup some basic lighting For our scene
  AmbientColor(RGB(128, 128, 128))
  CreateLight(0, RGB(255, 255, 255), 40, 60, 50)
  CreateLight(1, RGB(255, 255, 255), -120, -80, -50)
  
  ; pre-load the mesh so that we can tweak it With a manual animation
  LoadMesh(#Mesh, "facial.mesh")
  
  ; create a manual animation, create a pose track For it, And create a keyframe in that track
  CreateVertexAnimation(#Mesh, Animation$, 0)
  CreateVertexTrack(#Mesh, Animation$, Track)
  CreateVertexPoseKeyFrame(#Mesh, Animation$, Track, KeyFrame)
  
  ; create pose references For the first 15 poses
  For i = 0 To 14
    AddVertexPoseReference(#Mesh, Animation$, Track, KeyFrame, i, 0)
  Next
  
  ; create a head entity from the mesh
  CreateEntity(#Entity, MeshID(#Mesh), #PB_Material_None, 0, -30, 0)
  
  ; get the animation states
  StartEntityAnimation(#Entity, "Speak")
  
  ; make the camera orbit around the head
  CreateCamera(0, 0, 0, 100, 100)
  MoveCamera(0, 0, 0, 140, #PB_Absolute)
  CameraLookAt(0, EntityX(0), EntityY(0) + 15, EntityZ(0))
  
  mPlayAnimation = #True; by default, the speaking animation is enabled
  
EndProcedure

Procedure setupControls()
  FrameGadget(#FrameExpressions, 810,  50, 170, 140, "Expressions")
  FrameGadget(#FrameShapes     , 810, 210, 170, 320, "Shapes")
  
  ;create sliders To adjust pose influence
  For i = 0 To VertexPoseReferenceCount(#Mesh, animation$, Track, KeyFrame) - 1
    
    poseName$ = MeshPoseName(#Mesh, i)
    
    If FindString(poseName$, "Expression")
      AddElement(Expressions())
      Expressions()\slider = TrackBarGadget(#PB_Any , 870, 80 + i * 25, 100, 20, 0, 10, 1)
      Expressions()\text   = TextGadget(#PB_Any, 820, 80 + i * 25, 50, 20, Mid(poseName$, 12))
      SetGadgetData(Expressions()\slider, i)
    Else
      AddElement(MouthShapes())
      MouthShapes()\slider = TrackBarGadget(#PB_Any, 870, 140 + i * 25, 100, 20, 0, 10, 1)
      MouthShapes()\text   = TextGadget(#PB_Any, 820, 140 + i * 25, 50, 20, Left(poseName$, 1))
      SetGadgetData(MouthShapes()\slider, i)
    EndIf
  Next
  
  ; checkbox To switch between automatic animation And manual animation.
  CheckBoxGadget(#CheckBox, 810, 10, 180, 25, "Manual Animation")
  SetGadgetState(#CheckBox, 1 - mPlayAnimation)
EndProcedure

Procedure checkBoxToggled()
  
  mPlayAnimation = 1 - GetGadgetState(#CheckBox)
  
  ; toggle animation states and frameGadget
  If mPlayAnimation
    StartEntityAnimation(#Entity, "Speak")
    StopEntityAnimation(#Entity, "Manual")
    HideGadget(#FrameExpressions, 1)
    HideGadget(#FrameShapes, 1)
  Else
    StopEntityAnimation(#Entity, "Speak")
    StartEntityAnimation(#Entity, "Manual")
    HideGadget(#FrameExpressions, 0)
    HideGadget(#FrameShapes, 0)
  EndIf
  
  ; toggle expression controls
  ForEach Expressions()
    If mPlayAnimation
      HideGadget(Expressions()\text, 1)
      HideGadget(Expressions()\slider, 1)
    Else
      HideGadget(Expressions()\text, 0)
      HideGadget(Expressions()\slider, 0)
    EndIf
  Next
  
  ; toggle mouth shape controls
  ForEach MouthShapes()
    If mPlayAnimation
      HideGadget(MouthShapes()\text, 1)
      HideGadget(MouthShapes()\slider, 1)
    Else
      HideGadget(MouthShapes()\text, 0)
      HideGadget(MouthShapes()\slider, 0)
    EndIf
  Next
EndProcedure

Procedure sliderMoved(Slider)
  ; update the pose reference controlled by this slider
  UpdateVertexPoseReference(#Mesh, Animation$, Track, KeyFrame, GetGadgetData(Slider), GetGadgetState(Slider) / 10.0)
  
  ; update animation state since we're fudging this manually
  UpdateEntityAnimation(#Entity, Animation$)
EndProcedure