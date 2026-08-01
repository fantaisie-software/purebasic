
; ------------------------------------------------------------
;
;   PureBasic - Gadget 3D
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

Define.f KeyX, KeyY, MouseX, MouseY

Enumeration ; Window3D
  #MainWindow
  #SecondWindow
EndEnumeration


Enumeration ; Gadget3D
  #ActiveWindowLabel
  #CloseButton
  #ProgressBar
  #ComboBox
  #Panel
  #ListView
  #Image
  #Image2
  #ScrollArea
  #ScrollBar
  #String
  #Spin
  #Container
  #CheckBox
  #Editor
  #Option1
  #Option2
  #Option3
  #Button
EndEnumeration

InitEngine3D()
InitSprite()
InitKeyboard()
InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8

OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " Gadget 3D -  [Back]   [Return]   [Delete]  [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/GUI", #PB_3DArchive_FileSystem)
Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)

SkyBox("desert07.jpg")

CreateCamera(0, 0, 0, 100, 100)  ; Front camera
MoveCamera(0, 0, 0, 100, #PB_Absolute)

r.d = DesktopResolutionX()

OpenWindow3D(#MainWindow, 50*r, 20*r, 300*r, 400*r, "Hello in 3D !", #PB_Window3D_SizeGadget)

Top = 10
TextGadget3D(#ActiveWindowLabel, 10*r, Top*r, 250*r, 25*r, "Active window: ") : Top + 30

;- ProgressBar
TextGadget3D(#PB_Any, 10*r, Top*r, 100*r, 25*r, "Progress bar: ")
ProgressBarGadget3D(#ProgressBar, 110*r, Top*r, 150*r, 25*r, 0*r, 100*r) : Top + 30
SetGadgetState3D(#ProgressBar, 30)
GadgetToolTip3D(#ProgressBar, "I'm a progress bar")

;- ComboBox
TextGadget3D(#PB_Any, 10*r, Top*r, 100*r, 25*r, "Combo box: ")
ComboBoxGadget3D(#ComboBox, 110*r, Top*r, 150*r, 25*r) : Top + 30
GadgetToolTip3D(#ComboBox, "Combobox tooltip !")
AddGadgetItem3D(#ComboBox, -1, "Item 1")
AddGadgetItem3D(#ComboBox, -1, "Item 2")
AddGadgetItem3D(#ComboBox, -1, "Item 3")
AddGadgetItem3D(#ComboBox, -1, "Item 4")

;- ScrollBar
TextGadget3D(#PB_Any, 10*r, Top*r, 100*r, 25*r, "Scroll bar: ")
ScrollBarGadget3D(#ScrollBar, 110*r, (Top+7)*r, 150*r, 10*r, 0, 100, 20) : Top + 30
SetGadgetState3D(#ScrollBar, 30)

;- String
TextGadget3D(#PB_Any, 10*r, Top*r, 100*r, 25*r, "String: ")
StringGadget3D(#String, 110*r, Top*r, 150*r, 25*r, "Modify me") : Top + 30
GadgetToolTip3D(#String, "I'm a string gadget")

;- CheckBox
TextGadget3D(#PB_Any, 10*r, Top*r, 100*r, 25*r, "Check box: ")
CheckBoxGadget3D(#CheckBox, 110*r, Top*r, 150*r, 25*r, "Enable something") : Top + 30
GadgetToolTip3D(#CheckBox, "I'm a checkbox !")
SetGadgetState3D(#CheckBox, 1)

;- Spinner
TextGadget3D(#PB_Any, 10*r, Top*r, 100*r, 25*r, "Spinner: ")
SpinGadget3D(#Spin, 110*r, Top*r, 150*r, 25*r, 0, 100) : Top + 30
GadgetToolTip3D(#Spin, "I'm a spinner !")

;- Options
TextGadget3D(#PB_Any, 10*r, Top*r, 100*r, 25*r, "Options: ")
OptionGadget3D(#Option1, 110*r, Top*r, 150*r, 25*r, "Choice 1") : Top + 30
OptionGadget3D(#Option2, 110*r, Top*r, 150*r, 25*r, "Choice 2") : Top + 30
OptionGadget3D(#Option3, 110*r, Top*r, 150*r, 25*r, "Choice 3") : Top + 30
GadgetToolTip3D(#Option1, "I'm option 1 !")
SetGadgetState3D(#Option2, 1)

;- Button
TextGadget3D(#PB_Any, 10*r, Top*r, 100*r, 25*r, "Button: ")
ButtonGadget3D(#Button, 110*r, Top*r, 150*r, 25*r, "Click me !") : Top + 30
GadgetToolTip3D(#Button, "I'm a button !")


OpenWindow3D(#SecondWindow, 400*r, 150*r, 400*r, 400*r, "More gadgets", #PB_Window3D_SizeGadget)

PanelGadget3D(#Panel, 10*r, 10*r, 370*r, 350*r)
GadgetToolTip3D(#Panel, "Panel tooltip !")
AddGadgetItem3D(#Panel, -1, "First")
ListViewGadget3D(#ListView, 10*r, 10*r, 200*r, 200*r, #PB_ListView3D_Multiselect)
For k = 0 To 20
  AddGadgetItem3D(#ListView, -1, "Item "+Str(k))
Next

AddGadgetItem3D(#Panel, -1, "Second")
ContainerGadget3D(#Container, 0*r, 0*r, 400*r, 400*r)
GadgetToolTip3D(#Container, "Container tooltip !")

LoadTexture(0, "clouds.jpg")
ImageGadget3D(#Image, 10*r, 10*r, 128*r, 128*r, TextureID(0))

ScrollAreaGadget3D(#ScrollArea, 10*r, 150*r, 100*r, 100*r, 256, 256, 30)
GadgetToolTip3D(#ScrollArea, "Scroll area tooltip !")
ImageGadget3D(#Image2, 10*r, 10*r, 256*r, 256*r, TextureID(0))
CloseGadgetList3D()

CloseGadgetList3D()

AddGadgetItem3D(#Panel, -1, "Third")
EditorGadget3D(#Editor, 10*r, 10*r, 300*r, 200*r)
SetGadgetText3D(#Editor, "Multi" + #LF$ + "Line" + #LF$ + "Editor !")

CloseGadgetList3D()

Repeat
  While WindowEvent():Wend
  
  If ExamineKeyboard() And ExamineMouse()
    Input$ = KeyboardInkey()
    
    SpecialKey = 0
    If     KeyboardPushed(#PB_Key_Back)   :  SpecialKey = #PB_Key_Back
    ElseIf KeyboardPushed(#PB_Key_Return) : SpecialKey = #PB_Key_Return
    ElseIf KeyboardPushed(#PB_Key_Left)   : SpecialKey = #PB_Key_Left
    ElseIf KeyboardPushed(#PB_Key_Right)  : SpecialKey = #PB_Key_Right
    ElseIf KeyboardPushed(#PB_Key_Up)     : SpecialKey = #PB_Key_Up
    ElseIf KeyboardPushed(#PB_Key_Down)   : SpecialKey = #PB_Key_Down
    ElseIf KeyboardPushed(#PB_Key_Delete) : SpecialKey = #PB_Key_Delete
    EndIf
    
    InputEvent3D(MouseX(), MouseY(), MouseButton(#PB_MouseButton_Left), Input$, SpecialKey)
  EndIf
  
  ; Handle the GUI 3D events, it's similar to regular GUI events
  ;
  Repeat
    Event = WindowEvent3D()
    
    SetGadgetText3D(#ActiveWindowLabel, "Active #Window3D: "+Str(GetActiveWindow3D()))
    
    Select Event
      Case #PB_Event3D_Gadget
        If EventGadget3D() = #CloseButton
          CloseWindow3D(#MainWindow)
        EndIf
        
    EndSelect
  Until Event = 0
  
  RenderWorld()
  
  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1

