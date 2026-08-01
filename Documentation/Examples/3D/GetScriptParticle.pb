
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

Define.f KeyX, KeyY, MouseX, MouseY

InitEngine3D()
InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " GetScriptParticle - [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

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
  While WindowEvent():Wend
  
  If ExamineMouse()
    MouseX = -MouseDeltaX() * #CameraSpeed * 0.005
    MouseY = -MouseDeltaY() * #CameraSpeed * 0.005
  EndIf
  
  If ExamineKeyboard()
    KeyX = (KeyboardPushed(#PB_Key_Right)-KeyboardPushed(#PB_Key_Left))*#CameraSpeed
    Keyy = (KeyboardPushed(#PB_Key_Down)-KeyboardPushed(#PB_Key_Up))*#CameraSpeed    
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
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1


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
