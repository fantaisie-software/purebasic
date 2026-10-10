
; ------------------------------------------------------------
;
;   PureBasic - Gadget 3D
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

Enumeration ; ScreenWindow
  #MainWindow
  #SecondWindow
EndEnumeration


Enumeration ; ScreenGadget
  #EventLabel
  #ProgressBar
  #ComboBox
  #Panel
  #ListView
  #Image
  #Image2
  #ScrollArea
  #ScrollBar
  #String
  #TrackBar
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

UseJPEGImageDecoder()

ExamineDesktops():dx=DesktopWidth(0)*0.8:dy=DesktopHeight(0)*0.8

OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " Gadget 3D -  [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)
InitScreenGadgets()

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Packs/desert.zip", #PB_3DArchive_Zip)

SkyBox("desert07.jpg")

CreateCamera(0, 0, 0, 100, 100)  ; Front camera
MoveCamera(0, 0, 0, 100, #PB_Absolute)

OpenScreenWindow(#MainWindow, 50, 20, 300, 410, "Hello in 3D !")

Top = 40 ; The gadget coordinates include the window title bar
TextScreenGadget(#EventLabel, 10, Top, 280, 25, "Last event: none") : Top + 30

;- ProgressBar
TextScreenGadget(#PB_Any, 10, Top, 100, 25, "Progress bar: ")
ProgressBarScreenGadget(#ProgressBar, 110, Top, 150, 25, 0, 100) : Top + 30
SetScreenGadgetState(#ProgressBar, 30)
ScreenGadgetToolTip(#ProgressBar, "I'm a progress bar")

;- ComboBox
TextScreenGadget(#PB_Any, 10, Top, 100, 25, "Combo box: ")
ComboBoxScreenGadget(#ComboBox, 110, Top, 150, 25) : Top + 30
ScreenGadgetToolTip(#ComboBox, "Combobox tooltip !")
AddScreenGadgetItem(#ComboBox, -1, "Item 1")
AddScreenGadgetItem(#ComboBox, -1, "Item 2")
AddScreenGadgetItem(#ComboBox, -1, "Item 3")
AddScreenGadgetItem(#ComboBox, -1, "Item 4")

;- ScrollBar
TextScreenGadget(#PB_Any, 10, Top, 100, 25, "Scroll bar: ")
ScrollBarScreenGadget(#ScrollBar, 110, Top+3, 150, 20, 0, 100, 20) : Top + 30
SetScreenGadgetState(#ScrollBar, 30)

;- String
TextScreenGadget(#PB_Any, 10, Top, 100, 25, "String: ")
StringScreenGadget(#String, 110, Top, 150, 25, "Modify me") : Top + 30
ScreenGadgetToolTip(#String, "I'm a string gadget")

;- CheckBox
TextScreenGadget(#PB_Any, 10, Top, 100, 25, "Check box: ")
CheckBoxScreenGadget(#CheckBox, 110, Top, 150, 25, "Enable something") : Top + 30
ScreenGadgetToolTip(#CheckBox, "I'm a checkbox !")
SetScreenGadgetState(#CheckBox, 1)

;- TrackBar
TextScreenGadget(#PB_Any, 10, Top, 100, 25, "Track bar: ")
TrackBarScreenGadget(#TrackBar, 110, Top, 150, 25, 0, 10) : Top + 30
ScreenGadgetToolTip(#TrackBar, "I'm a track bar !")

;- Options
TextScreenGadget(#PB_Any, 10, Top, 100, 25, "Options: ")
OptionScreenGadget(#Option1, 110, Top, 150, 25, "Choice 1") : Top + 30
OptionScreenGadget(#Option2, 110, Top, 150, 25, "Choice 2") : Top + 30
OptionScreenGadget(#Option3, 110, Top, 150, 25, "Choice 3") : Top + 30
ScreenGadgetToolTip(#Option1, "I'm option 1 !")
SetScreenGadgetState(#Option2, 1)

;- Button
TextScreenGadget(#PB_Any, 10, Top, 100, 25, "Button: ")
ButtonScreenGadget(#Button, 110, Top, 150, 25, "Click me !") : Top + 30
ScreenGadgetToolTip(#Button, "I'm a button !")


OpenScreenWindow(#SecondWindow, 400, 150, 400, 430, "More gadgets")

PanelScreenGadget(#Panel, 10, 40, 380, 350)
AddScreenGadgetItem(#Panel, -1, "First")
ListViewScreenGadget(#ListView, 10, 10, 200, 200)
For k = 0 To 20
  AddScreenGadgetItem(#ListView, -1, "Item "+Str(k))
Next

AddScreenGadgetItem(#Panel, -1, "Second")
ContainerScreenGadget(#Container, 0, 0, 360, 300)
ScreenGadgetToolTip(#Container, "Container tooltip !")

LoadImage(0, #PB_Compiler_Home + "examples/3d/Data/Textures/clouds.jpg")
ImageScreenGadget(#Image, 10, 10, 128, 128, ImageID(0))

ScrollAreaScreenGadget(#ScrollArea, 10, 150, 120, 120, 256, 256, 30)
ScreenGadgetToolTip(#ScrollArea, "Scroll area tooltip !")
ImageScreenGadget(#Image2, 10, 10, 256, 256, ImageID(0))
CloseScreenGadgetList()

CloseScreenGadgetList()

AddScreenGadgetItem(#Panel, -1, "Third")
EditorScreenGadget(#Editor, 10, 10, 300, 200)
SetScreenGadgetText(#Editor, "Multi" + #LF$ + "Line" + #LF$ + "Editor !")

CloseScreenGadgetList()

Repeat
  While WindowEvent():Wend

  ExamineKeyboard()
  ExamineMouse()

  ; Handle the screen GUI events. There is at most one event per frame, so no inner event loop is needed
  ;
  If ScreenWindowEvent() = #PB_Event_Gadget
    Gadget = EventScreenGadget()
    SetScreenGadgetText(#EventLabel, "Last event: gadget " + Str(Gadget) + ", state " + Str(GetScreenGadgetState(Gadget)))
  EndIf

  RenderWorld()
  RenderScreenGadgets()

  FlipBuffers()
Until KeyboardPushed(#PB_Key_Escape)

