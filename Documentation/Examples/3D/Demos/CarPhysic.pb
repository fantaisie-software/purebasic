;************************************************************************************
;  Bullet Physics - Car demo
;  PB version: 5.11
;  Date: may, 5, 2013
;  Author: kelebrindae
;
;  Rough simulation of a car, using PB's physics engine.
;
;  Controls:
;  - W -> Wireframe view
;  - P -> Display physics bodies
;  - [Return] -> Pause simulation
;  - [Cursor keys] -> Drive the car
;************************************************************************************

; Window size
#SCREENWIDTH = 1000
#SCREENHEIGHT = 500

#LEFTSIDE = -1
#RIGHTSIDE = 1

Enumeration
  #FWDRIVE
  #RWDRIVE
  #FOURWHEELDRIVE
  #TYRELLP34
EndEnumeration


Structure wheel_struct
  support.i ; entity
  wheel.i   ; entity
  supJoint.i    ; joint chassis <> support
  wheelJoint.i  ; joint support <> wheel
  
  wheelRadius.f
  wheelWidth.f
  wheelMass.f
  
  isSteer.b
  isDrive.b
  
EndStructure

Structure car_struct
  chassis.i     ; car's base entity
  body.i ; car's body entity
  bodyJoint.i   ; joint between the two
  
  width.f
  length.f
  height.f
  chassisHeight.f
  mass.f
  
  maxSteer.f
  maxSpeed.f
  accel.f
  
  List wheel.wheel_struct()
EndStructure
Global car.car_struct

Global i.i, wireframe.b, viewBodies.b, simRunning.b = #True, dontQuit.b = #True, eventId.i

Global txBlank.i, txGround.i, txStriped.i
Global mtGround.i, mtRed.i, mtBlue.i, mtCyanSt.i, mtWhiteSt.i

Global dimX.f, dimZ.i, ground.i, jump.i
Global planeMesh.i,cubeMesh.i, wheelMesh.i

Global distance.f ; used for camera movement


EnableExplicit

;************************************************************************************
;-                                 ---- Macros ----
;************************************************************************************

; Computes the square of the distance between coords (x1,y1,z1) and (x2,y2,z2)
Global DIST_X.f,DIST_Y.f,DIST_Z.f
Macro DISTANCE2(x1,y1,z1,x2,y2,z2,result)
  DIST_X = (x1)-(x2)
  DIST_Y = (y1)-(y2)
  DIST_Z = (z1)-(z2)
  result = DIST_X*DIST_X + DIST_Y*DIST_Y + DIST_Z*DIST_Z ; no sqr, it's faster
EndMacro


;************************************************************************************
;-                                 ---- Procedures ----
;************************************************************************************

; Add a wheel to a car
Procedure createWheel(*ptrcar.car_struct,side.i, supportZpos.f, isSteer.b, isDrive.b,
                      radius.f = 0.5, width.f = 0.3, mass.f = 1, resti.f = 0.9, friction.f = 1)
  Protected supportWidth.f = 0.6, supportHeight.f = 0.1, supportLength.f = 0.4
  Protected supportXpos.f, supportYpos.f, wheelXpos.f, wheelMat.i
  
  ; Add the wheel
  AddElement(*ptrcar\wheel())
  
  ; Define its parameters
  *ptrcar\wheel()\wheelRadius = radius
  *ptrcar\wheel()\wheelWidth = width
  *ptrcar\wheel()\wheelMass = mass
  *ptrcar\wheel()\isDrive = isDrive
  *ptrcar\wheel()\isSteer = isSteer
  
  ; Position
  supportXpos = (*ptrcar\width/2) * side
  supportYpos = (*ptrcar\chassisHeight/2) + (supportHeight/2)
  wheelXpos = supportXpos + ((width/2) + (supportWidth/2)) * side
  
  ; Support entity + joint
  *ptrcar\wheel()\support = CreateEntity(#PB_Any,MeshID(cubeMesh),MaterialID(mtRed),EntityX(car\chassis)+supportXpos,EntityY(car\chassis)+supportYpos,EntityZ(car\chassis)+supportZpos)
  ScaleEntity(*ptrcar\wheel()\support,supportWidth,supportHeight,supportLength)
  CreateEntityBody(*ptrcar\wheel()\support,#PB_Entity_BoxBody,1,0,0)
  
  *ptrcar\wheel()\supJoint = HingeJoint(#PB_Any,EntityID(*ptrcar\wheel()\support),-(supportWidth/2) * side,-(supportHeight/2),0, 0,1,0,EntityID(*ptrcar\chassis),((*ptrcar\width/2) - (supportWidth/2)) * side,(*ptrcar\chassisHeight/2),supportZpos, 0,1,0)
  If isSteer = #True
    SetJointAttribute(*ptrcar\wheel()\supJoint,#PB_HingeJoint_LowerLimit,-15)
    SetJointAttribute(*ptrcar\wheel()\supJoint,#PB_HingeJoint_UpperLimit,15)
  Else
    SetJointAttribute(*ptrcar\wheel()\supJoint,#PB_HingeJoint_LowerLimit,0)
    SetJointAttribute(*ptrcar\wheel()\supJoint,#PB_HingeJoint_UpperLimit,0)
  EndIf
  
  ; Wheel entity + joint
  If isDrive = #True
    wheelMat = MaterialID(mtCyanSt)
  Else
    wheelMat = MaterialID(mtWhiteSt)
  EndIf
  
  *ptrcar\wheel()\wheel = CreateEntity(#PB_Any,MeshID(wheelMesh),wheelMat,EntityX(car\chassis)+wheelXpos,EntityY(car\chassis)+supportYpos,EntityZ(car\chassis)+supportZpos)
  ScaleEntity(*ptrcar\wheel()\wheel,*ptrcar\wheel()\wheelRadius,*ptrcar\wheel()\wheelWidth,*ptrcar\wheel()\wheelRadius)
  RotateEntity(*ptrcar\wheel()\wheel,0,0,-90 * side)
  CreateEntityBody(*ptrcar\wheel()\wheel,#PB_Entity_CylinderBody,mass,resti,friction)
  
  *ptrcar\wheel()\wheelJoint = HingeJoint(#PB_Any,EntityID(*ptrcar\wheel()\wheel),0,0,0, 0,side,0, EntityID(*ptrcar\wheel()\support),((*ptrcar\wheel()\wheelWidth/2) + (supportWidth/2)) * side,0,0, 1,0,0)
  
EndProcedure

; Destroy a car
Procedure killCar(*ptrCar.car_struct)
  ForEach *ptrCar\wheel()
    FreeJoint(*ptrCar\wheel()\supJoint)
    FreeJoint(*ptrCar\wheel()\wheelJoint)
    
    FreeEntity(*ptrCar\wheel()\wheel)
    FreeEntity(*ptrCar\wheel()\support)
  Next *ptrCar\wheel()
  ClearList(*ptrCar\wheel())
  
  If IsEntity(*ptrCar\body)
    FreeEntity(*ptrCar\body)
  EndIf
  If IsEntity(*ptrCar\chassis)
    FreeEntity(*ptrCar\chassis)
  EndIf
EndProcedure

; Create a car
Procedure createCar(*ptrCar.car_struct, template.i=#FWDRIVE,
                    width.f = 2,length.f = 4,height.f = 1.5, mass.f = 1.15,
                    maxSteer.f = 15,maxSpeed.f = 40,accel.f = 0.5,
                    wheelRadius.f = 0.5, wheelWidth.f = 0.3, wheelMass.f = 0.85, wheelResti.f = 0.9, wheelFriction.f = 1)
  
  If IsEntity(*ptrCar\chassis)
    killCar(*ptrCar)
  EndIf
  
  *ptrCar\width = width
  *ptrCar\length = length
  *ptrCar\height = height
  *ptrCar\chassisHeight = 0.2 ; this one is fixed
  *ptrCar\mass = mass
  *ptrCar\maxSteer = maxSteer
  *ptrCar\maxSpeed = maxSpeed
  *ptrCar\accel = accel
  
  ; Create the chassis
  *ptrCar\chassis = CreateEntity(#PB_Any,MeshID(cubeMesh),MaterialID(mtBlue),0,2,0)
  ScaleEntity(*ptrCar\chassis,*ptrCar\width,*ptrCar\chassisHeight,*ptrCar\length)
  CreateEntityBody(*ptrCar\chassis,#PB_Entity_BoxBody,*ptrCar\mass,0,1)
  
  ; Create the car's body
  *ptrCar\body = CreateEntity(#PB_Any,MeshID(cubeMesh),MaterialID(mtBlue),0,EntityY(*ptrCar\chassis) + *ptrCar\chassisHeight + *ptrCar\height/2,0,0)
  ScaleEntity(*ptrCar\body,*ptrCar\width-0.1,*ptrCar\height,*ptrCar\length-0.1)
  CreateEntityBody(*ptrCar\body,#PB_Entity_BoxBody,*ptrCar\mass,0,1)
  *ptrCar\bodyJoint = SliderJoint(#PB_Any,EntityID(*ptrCar\chassis),0,*ptrCar\chassisHeight,0,EntityID(*ptrCar\body),0,-*ptrCar\height/2,0)
  SetJointAttribute(*ptrCar\bodyJoint,#PB_SliderJoint_LowerLimit,0)
  SetJointAttribute(*ptrCar\bodyJoint,#PB_SliderJoint_UpperLimit,0)
  
  ; Add the wheels
  Select template
    Case #FWDRIVE
      createWheel(@car,#LEFTSIDE,-(*ptrCar\length/2 - 0.7),#True,#True,wheelRadius,wheelWidth,wheelMass, wheelResti, wheelFriction)
      createWheel(@car,#RIGHTSIDE,-(*ptrCar\length/2 - 0.7),#True,#True,wheelRadius,wheelWidth,wheelMass, wheelResti, wheelFriction)
      createWheel(@car,#LEFTSIDE,(*ptrCar\length/2 - 0.7),#False,#False,wheelRadius,wheelWidth,wheelMass, wheelResti, wheelFriction)
      createWheel(@car,#RIGHTSIDE,(*ptrCar\length/2 - 0.7),#False,#False,wheelRadius,wheelWidth,wheelMass, wheelResti, wheelFriction)
      
    Case #RWDRIVE
      createWheel(@car,#LEFTSIDE,-(*ptrCar\length/2 - 0.7),#True,#False,wheelRadius,wheelWidth,wheelMass, wheelResti, wheelFriction)
      createWheel(@car,#RIGHTSIDE,-(*ptrCar\length/2 - 0.7),#True,#False,wheelRadius,wheelWidth,wheelMass, wheelResti, wheelFriction)
      createWheel(@car,#LEFTSIDE,(*ptrCar\length/2 - 0.7),#False,#True,wheelRadius,wheelWidth,wheelMass, wheelResti, wheelFriction)
      createWheel(@car,#RIGHTSIDE,(*ptrCar\length/2 - 0.7),#False,#True,wheelRadius,wheelWidth,wheelMass, wheelResti, wheelFriction)
      
    Case #FOURWHEELDRIVE
      createWheel(@car,#LEFTSIDE,-(*ptrCar\length/2 - 0.7),#True,#True,wheelRadius,wheelWidth,wheelMass, wheelResti, wheelFriction)
      createWheel(@car,#RIGHTSIDE,-(*ptrCar\length/2 - 0.7),#True,#True,wheelRadius,wheelWidth,wheelMass, wheelResti, wheelFriction)
      createWheel(@car,#LEFTSIDE,(*ptrCar\length/2 - 0.7),#False,#True,wheelRadius,wheelWidth,wheelMass, wheelResti, wheelFriction)
      createWheel(@car,#RIGHTSIDE,(*ptrCar\length/2 - 0.7),#False,#True,wheelRadius,wheelWidth,wheelMass, wheelResti, wheelFriction)
      
    Case #TYRELLP34
      createWheel(@car,#LEFTSIDE,-(*ptrCar\length/2 - 0.4),#True,#False,wheelRadius,wheelWidth,wheelMass, wheelResti, wheelFriction)
      createWheel(@car,#RIGHTSIDE,-(*ptrCar\length/2 - 0.4),#True,#False,wheelRadius,wheelWidth,wheelMass, wheelResti, wheelFriction)
      createWheel(@car,#LEFTSIDE,-(*ptrCar\length/2 - 1.7),#True,#False,wheelRadius,wheelWidth,wheelMass, wheelResti, wheelFriction)
      createWheel(@car,#RIGHTSIDE,-(*ptrCar\length/2 - 1.7),#True,#False,wheelRadius,wheelWidth,wheelMass, wheelResti, wheelFriction)
      createWheel(@car,#LEFTSIDE,(*ptrCar\length/2 - 0.5),#False,#True,wheelRadius,wheelWidth,wheelMass, wheelResti, wheelFriction)
      createWheel(@car,#RIGHTSIDE,(*ptrCar\length/2 - 0.5),#False,#True,wheelRadius,wheelWidth,wheelMass, wheelResti, wheelFriction)
      
  EndSelect
  
EndProcedure


; Window procedures
Global Wmain
Global Frame_0, BT_reset, CB_template, FL_mass, label_mass, FL_height, label_height, FL_steer, label_steer, FL_maxspeed, label_maxSpeed, FL_accel, label_accel, FL_length, label_length, FL_width, label_width, FL_radius, label_radius, FL_wheelwidth, label_wheelWidth, FL_wheelMass, label_wheelMass, FL_friction, label_friction, FL_resti, label_resti
Procedure OpenWmain()
  Wmain = OpenWindow(#PB_Any, 0, 0, #SCREENWIDTH, #SCREENHEIGHT, "Car physics", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  Frame_0 = FrameGadget(#PB_Any, 1, 0, 298, 500, "Parameters")
  BT_reset = ButtonGadget(#PB_Any, 104, 465, 100, 25, "Reset")
  GadgetToolTip(BT_reset, "Reset simulation with new parameters.")
  CB_template = ComboBoxGadget(#PB_Any, 70, 23, 190, 25)
  GadgetToolTip(CB_template, "Predefined vehicles")
  
  FL_length = StringGadget(#PB_Any, 141, 56, 100, 25, "4")
  GadgetToolTip(FL_length, "Length of the vehicle")
  label_length = TextGadget(#PB_Any, 37, 62, 100, 20, "Length:", #PB_Text_Right)
  FL_width = StringGadget(#PB_Any, 141, 86, 100, 25, "2")
  GadgetToolTip(FL_width, "Width of the vehicle")
  label_width = TextGadget(#PB_Any, 37, 92, 100, 20, "Width:", #PB_Text_Right)
  
  FL_height = StringGadget(#PB_Any, 141, 116, 100, 25, "1.5")
  GadgetToolTip(FL_height, "Height of the vehicle's body")
  label_height = TextGadget(#PB_Any, 37, 122, 100, 20, "Height:", #PB_Text_Right)
  FL_mass = StringGadget(#PB_Any, 141, 146, 100, 25, "1.15")
  GadgetToolTip(FL_mass, "Mass of the vehicle")
  label_mass = TextGadget(#PB_Any, 37, 152, 100, 20, "Mass:", #PB_Text_Right)
  
  FL_steer = StringGadget(#PB_Any, 141, 186, 100, 25, "15")
  GadgetToolTip(FL_steer, "Steering angle of the vehicle.")
  label_steer = TextGadget(#PB_Any, 37, 192, 100, 20, "Steering angle:", #PB_Text_Right)
  FL_maxspeed = StringGadget(#PB_Any, 141, 216, 100, 25, "40")
  GadgetToolTip(FL_maxspeed, "Maximum linear speed of the drive wheels")
  label_maxSpeed = TextGadget(#PB_Any, 37, 222, 100, 20, "Max speed:", #PB_Text_Right)
  FL_accel = StringGadget(#PB_Any, 141, 246, 100, 25, "0.2")
  GadgetToolTip(FL_accel, "Acceleration")
  label_accel = TextGadget(#PB_Any, 37, 252, 100, 20, "Acceleration:", #PB_Text_Right)
  
  FL_radius = StringGadget(#PB_Any, 141, 286, 100, 25, "0.5")
  label_radius = TextGadget(#PB_Any, 37, 292, 100, 20, "Wheel radius:", #PB_Text_Right)
  FL_wheelwidth = StringGadget(#PB_Any, 141, 316, 100, 25, "0.3")
  label_wheelWidth = TextGadget(#PB_Any, 37, 322, 100, 20, "Wheel width:", #PB_Text_Right)
  FL_wheelMass = StringGadget(#PB_Any, 141, 346, 100, 25, "0.85")
  label_wheelMass = TextGadget(#PB_Any, 37, 352, 100, 20, "Wheel mass:", #PB_Text_Right)
  FL_friction = StringGadget(#PB_Any, 141, 376, 100, 25, "1")
  label_friction = TextGadget(#PB_Any, 37, 382, 100, 20, "Wheel friction:", #PB_Text_Right)
  FL_resti = StringGadget(#PB_Any, 141, 406, 100, 25, "0.9")
  label_resti = TextGadget(#PB_Any, 37, 412, 100, 20, "Wheel restitution:", #PB_Text_Right)
  
  ; Combo-box initialization
  AddGadgetItem(CB_template,#FWDRIVE,"Front-wheels drive")
  AddGadgetItem(CB_template,#RWDRIVE,"Rear-wheels drive")
  AddGadgetItem(CB_template,#FOURWHEELDRIVE,"4x4 drive")
  AddGadgetItem(CB_template,#TYRELLP34,"Tyrell P34")
  SetGadgetState(CB_template,0)
EndProcedure

Procedure Wmain_Events(event)
  Select event
    Case #PB_Event_CloseWindow
      ProcedureReturn #False
      
    Case #PB_Event_Menu
      Select EventMenu()
      EndSelect
      
    Case #PB_Event_Gadget
      Select EventGadget()
        Case BT_reset ; Create a new car
          createCar(@car,
                    GetGadgetState(CB_template),
                    ValF(GetGadgetText(FL_width)),
                    ValF(GetGadgetText(FL_length)),
                    ValF(GetGadgetText(FL_height)),
                    ValF(GetGadgetText(FL_mass)),
                    ValF(GetGadgetText(FL_steer)),
                    ValF(GetGadgetText(FL_maxspeed)),
                    ValF(GetGadgetText(FL_accel)),
                    ValF(GetGadgetText(FL_radius)),
                    ValF(GetGadgetText(FL_wheelwidth)),
                    ValF(GetGadgetText(FL_wheelMass)),
                    ValF(GetGadgetText(FL_resti)),
                    ValF(GetGadgetText(FL_friction)) )
      EndSelect
  EndSelect
  ProcedureReturn #True
EndProcedure

;************************************************************************************
;-                                 ---- Main program ----
;************************************************************************************

;- Initialization
InitEngine3D()
InitSprite()
InitKeyboard()

;- Window
OpenWmain()
OpenWindowedScreen(WindowID(Wmain), DesktopScaledX(300), DesktopScaledY(0), DesktopScaledX(#SCREENWIDTH-300), DesktopScaledY(#SCREENHEIGHT), 0, 0, 0,#PB_Screen_SmartSynchronization)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Main", #PB_3DArchive_FileSystem)
Parse3DScripts()

;-Textures
txBlank = CreateTexture(#PB_Any,4,4)
StartDrawing(TextureOutput(txBlank))
Box(0, 0, 4,4, $FFFFFF)
StopDrawing()

txStriped = CreateTexture(#PB_Any,256,256)
StartDrawing(TextureOutput(txStriped))
Box(0, 0, 256,256, $FFFFFF)
For i = 0 To 255 Step 32
  Box(i,0,16,256,$777777)
Next i
StopDrawing()

txGround = CreateTexture(#PB_Any,256,256)
StartDrawing(TextureOutput(txGround))
Box(0, 0, 256,256, $007700)
DrawingMode(#PB_2DDrawing_Outlined)
Box(0, 0, 256,256, $00BB00)
StopDrawing()

;-Materials
mtGround= CreateMaterial(#PB_Any,TextureID(txGround))

mtRed = CreateMaterial(#PB_Any,TextureID(txBlank))
SetMaterialColor(mtRed,#PB_Material_AmbientColor,$0000FF)

mtBlue = CreateMaterial(#PB_Any,TextureID(txBlank))
SetMaterialColor(mtBlue,#PB_Material_AmbientColor,$FF0000)

mtCyanSt = CreateMaterial(#PB_Any,TextureID(txStriped))
SetMaterialColor(mtCyanSt,#PB_Material_AmbientColor,$FFFF00)

mtWhiteSt = CreateMaterial(#PB_Any,TextureID(txStriped))


;- Terrain
dimX = 300:dimZ = 300
planeMesh = CreatePlane(#PB_Any,dimX,dimZ,1,1,dimX,dimZ)
ground  = CreateEntity(#PB_Any, MeshID(planeMesh), MaterialID(mtGround))
CreateEntityBody(ground, #PB_Entity_StaticBody,0,0,1)

cubeMesh = CreateCube(#PB_Any,1)
jump = CreateEntity(#PB_Any,MeshID(cubeMesh),MaterialID(mtWhiteSt))
ScaleEntity(jump,8,4,4)
RotateEntity(jump,0,0,-15)
MoveEntity(jump,-10,-1,0, #PB_Absolute)
CreateEntityBody(jump, #PB_Entity_BoxBody,0,0,1)


;- Car
wheelMesh = CreateCylinder(#PB_Any,1,1)
createCar(@car) ; all parameters are set to default values

;- Camera
CreateCamera(0, 0, 0, 100, 100)
MoveCamera(0,0,5,10,#PB_Absolute)
CameraLookAt(0,0,0,0)

;-Light
AmbientColor($333333)
CreateLight(0,$FFFFFF,200,400,200)
WorldShadows(#PB_Shadow_Additive)

;- Main loop
KeyboardMode(#PB_Keyboard_International)
Repeat
  Delay(1)
  
  ; Windows events (reset button)
  eventID = WindowEvent()
  While eventID <> 0 And dontQuit = #True
    dontQuit = Wmain_Events(eventId)
    eventID = WindowEvent()
  Wend
  ExamineKeyboard()
  
  ; Activate wireframe render
  If KeyboardReleased(#PB_Key_W)
    wireframe = 1-wireframe
    If wireframe = #True
      CameraRenderMode(0,#PB_Camera_Wireframe)
    Else
      CameraRenderMode(0,#PB_Camera_Textured)
    EndIf
  EndIf
  ; Activate physics render
  If KeyboardReleased(#PB_Key_P)
    viewBodies = 1-viewBodies
    If viewBodies  = #True
      WorldDebug(#PB_World_DebugBody)
    Else
      WorldDebug(#PB_World_DebugNone)
    EndIf
  EndIf
  ; Start/pause simulation
  If KeyboardReleased(#PB_Key_Return)
    simRunning = 1-simRunning
    EnableWorldPhysics(simRunning)
  EndIf
  
  ; If the car exists, you can control it
  If IsEntity(car\chassis)
    ; Avoid that the car's physics body "goes to sleep" when not moving enough.
    DisableEntityBody(car\chassis,#False)
    
    ;- Steering
    If KeyboardPushed(#PB_Key_Left)
      ForEach car\wheel()
        If car\wheel()\isSteer = #True
          EnableHingeJointAngularMotor(car\wheel()\supJoint, #True, 5, 10)
          SetJointAttribute(car\wheel()\supJoint,#PB_HingeJoint_LowerLimit,-car\maxSteer)
          SetJointAttribute(car\wheel()\supJoint,#PB_HingeJoint_UpperLimit,car\maxSteer)
        EndIf
      Next car\wheel()
    ElseIf KeyboardPushed(#PB_Key_Right)
      ForEach car\wheel()
        If car\wheel()\isSteer = #True
          EnableHingeJointAngularMotor(car\wheel()\supJoint, #True, -5, 10)
          SetJointAttribute(car\wheel()\supJoint,#PB_HingeJoint_LowerLimit,-car\maxSteer)
          SetJointAttribute(car\wheel()\supJoint,#PB_HingeJoint_UpperLimit,car\maxSteer)
        EndIf
      Next car\wheel()
    Else
      ForEach car\wheel()
        If car\wheel()\isSteer = #True
          SetJointAttribute(car\wheel()\supJoint,#PB_HingeJoint_LowerLimit,0)
          SetJointAttribute(car\wheel()\supJoint,#PB_HingeJoint_UpperLimit,0)
        EndIf
      Next car\wheel()
    EndIf
    
    ;- Forward / backward acceleration
    If KeyboardPushed(#PB_Key_Up)
      ForEach car\wheel()
        If car\wheel()\isDrive = #True
          EnableHingeJointAngularMotor(car\wheel()\wheelJoint, #True, -car\maxSpeed, car\accel)
        EndIf
      Next car\wheel()
    ElseIf KeyboardPushed(#PB_Key_Down)
      ForEach car\wheel()
        If car\wheel()\isDrive = #True
          EnableHingeJointAngularMotor(car\wheel()\wheelJoint, #True, car\maxSpeed, car\accel)
        EndIf
      Next car\wheel()
    Else
      ForEach car\wheel()
        If car\wheel()\isDrive = #True
          EnableHingeJointAngularMotor(car\wheel()\wheelJoint, #False, 0,0)
        EndIf
      Next car\wheel()
    EndIf
    
    ;- Camera management
    CameraLookAt(0,EntityX(car\chassis),EntityY(car\chassis),EntityZ(car\chassis))
    DISTANCE2(CameraX(0),CameraY(0),CameraZ(0),EntityX(car\chassis),EntityY(car\chassis),EntityZ(car\chassis),distance)
    If distance > 200
      MoveCamera(0,0,0,-0.2)
      If CameraY(0) < 5.0
        MoveCamera(0,CameraX(0),5,CameraZ(0),#PB_Absolute)
        CameraLookAt(0,EntityX(car\chassis),EntityY(car\chassis),EntityZ(car\chassis))
      EndIf
    EndIf
  EndIf
  
  ; Render
  RenderWorld()
  FlipBuffers()
  
Until KeyboardPushed(#PB_Key_Escape) Or dontQuit = #False

End
; IDE Options = PureBasic 6.12 LTS (Windows - x86)
; CursorPosition = 390
; FirstLine = 363
; Folding = --
; EnableXP
; DPIAware