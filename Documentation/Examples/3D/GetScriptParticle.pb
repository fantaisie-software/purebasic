;
; ------------------------------------------------------------
;
;   PureBasic - GetScriptParticle
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#CameraSpeed = 10
#MAX = 20

IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"

Define.f KeyX, KeyY, MouseX, MouseY

If InitEngine3D()
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  If Screen3DRequester()

    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures"            , #PB_3DArchive_FileSystem)
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Models"              , #PB_3DArchive_FileSystem)
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Scripts"             , #PB_3DArchive_FileSystem)
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Particles"           , #PB_3DArchive_FileSystem)
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/OPE/material_scripts", #PB_3DArchive_FileSystem)
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/OPE/textures"        , #PB_3DArchive_FileSystem)
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/OPE/particle_scripts", #PB_3DArchive_FileSystem)
    Parse3DScripts()
    
    KeyboardMode(#PB_Keyboard_International)  
    
    ; Particles
    ;
    Restore Particles
    For i = 0 To #MAX
      Read.s Particle$
      GetScriptParticleEmitter(i, Particle$)
      HideParticleEmitter(i, 1)
    Next 
    
    ; Camera
    ;
    CreateCamera(0, 0, 0, 100, 100)
    MoveCamera(0, 0, 0, 100, #PB_Absolute)
    
    Repeat
      Screen3DEvents()
      
      If ExamineMouse()
        MouseX = -MouseDeltaX() * #CameraSpeed * 0.005
        MouseY = -MouseDeltaY() * #CameraSpeed * 0.005
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
      
      If ElapsedMilliseconds() - Time > 2500 
        Time = ElapsedMilliseconds()
        HideParticleEmitter(Particle, 1)
        Particle + 1
        If Particle > #MAX
          Particle = 0
        EndIf
        HideParticleEmitter(Particle, 0)
      EndIf
      
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
  Particles:
  Data.s "Examples/Smoke"
  Data.s "Examples/GreenyNimbus"
  Data.s "Examples/PurpleFountain"
  Data.s "Examples/Rain"
  Data.s "Examples/JetEngine1"
  Data.s "Examples/Aureola"
  Data.s "Examples/JetEngine2"
  Data.s "Examples/Swarm"
  Data.s "Examples/Snow"
  Data.s "Examples/Fireworks"
  Data.s "PEExamples/blast"
  Data.s "PEExamples/blast2"
  Data.s "PEExamples/erruption"
  Data.s "PEExamples/pentagram"
  Data.s "PEExamples/flow"
  Data.s "PEExamples/flame"
  Data.s "PEExamples/floatyGreeny"
  Data.s "PEExamples/ringOfFire"
  Data.s "PEExamples/space"
  Data.s "PEExamples/bounce"
  Data.s "PEExamples/point_rendering"
  
EndDataSection