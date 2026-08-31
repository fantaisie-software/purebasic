; ------------------------------------------------------------
;
;   PureBasic - ScreenGadget with custom skin
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------

#skin = 1 ; Choose skin here: 1, 2, or 3


UseJPEGImageDecoder()

Procedure.f POM(v.f)
  ProcedureReturn (Random(v * 1000) - v * 500) / 500
EndProcedure

Procedure defcadre(frame, l, c1, c2, c3, dec.f = 1, mini = 0)
  CompilerIf #PB_Compiler_OS <> #PB_OS_Windows
    dec * 0.5
  CompilerEndIf
  
  Protected n = CreateImage( - 1, l * 2, l * 2, 32, 0)
  StartVectorDrawing(ImageVectorOutput(n))
  AddPathCircle(l, l, l - 0)
  VectorSourceCircularGradient(l, l, l, - l * dec, - l * dec)
  VectorSourceGradientColor(c1, 0.0)
  VectorSourceGradientColor(c2, 0.6)
  
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    VectorSourceGradientColor(c3, 0.9)
    
    ; This line doesn't work on OSX and MacOS, it makes the whole UI transparent
    VectorSourceGradientColor(c3 & $ffffff, 1)
  CompilerElse
    VectorSourceGradientColor(c3, 1)
  CompilerEndIf
  
  FillPath()
  If mini:AddPathCircle(l, l, l * 0.4):VectorSourceColor(mini):FillPath():EndIf
  StopVectorDrawing()
  ScreenGadgetSkin(frame, n, 1)
EndProcedure

Procedure texture(im, dx, dy, num, n, alpha, stroke = 0, colormode = 0, param.f = 0)
  Protected s.s, i, j, k, col
  CreateImage(im, dx, dy, 32, 0 )
  StartVectorDrawing(ImageVectorOutput(im))
  For k = 1 To n
    Select colormode
      Case 0:col = Random($ffffff)
      Case 1:col = Random($ff) * $010101
      Case 2:col = ($ff) * $010101
    EndSelect
    col | alpha << 24
    Select num
      Case 0:AddPathCircle(Random(dx), Random(dy), param * dx)
      Case 1:MovePathCursor(Random(dx), Random(dy)):AddPathLine(pom(dx), pom(dy), #PB_Path_Relative)
      Case 2:MovePathCursor(Random(dx), Random(dy)):AddPathLine(dx / 2, pom(dx * 0.02), #PB_Path_Relative)
    EndSelect
    s = PathSegments():ResetPath()
    For j =  - 1 To 1:For i =  - 1 To 1:MovePathCursor(j * dy, i * dx):AddPathSegments(s, #PB_Path_Relative):Next:Next
    VectorSourceColor(col)
    If stroke:StrokePath(stroke):Else:FillPath():EndIf
  Next
  StopVectorDrawing()
EndProcedure

Procedure SelectSkin(skin)
  Protected d, n, rf.f = 100 / DesktopScaledX(100)
  
  defcadre(#PB_ScreenGadget_FrameProgressBar0, 8, $ffffffff, $aa777777, $aa333333,  - 1)
  defcadre(#PB_ScreenGadget_FrameProgressBar1, 8, $ffffffff, $dd0044ff, $dd002288)
  defcadre(#PB_ScreenGadget_FrameSplitter, 8, $ffffffff, $88ffffff, $44000000)
  Select skin
    Case 1
      SetScreenGadgetFont(#PB_Default, LoadFont(0, "arial", 11*rf))
      texture(1, 128, 128, 2, 100, 24, 1, 1)
      defcadre(#PB_ScreenGadget_FrameWindow , 8, $ffffffff, $ee336666, $ff223333)
      defcadre(#PB_ScreenGadget_FrameRaised , 8, $ffffffff, $bb0099cc, $bb003344)
      defcadre(#PB_ScreenGadget_FrameSunken , 8, $ffffffff, $44559999, $cc224444,  - 1)
      defcadre(#PB_ScreenGadget_FrameString , 8, $ffffffff, $dd337777, $dd224444,  - 1, $ffffffff)
      defcadre(#PB_ScreenGadget_FrameScroll , 4, $ffffffff, $dd003344, $dd003344,  - 1)
      defcadre(#PB_ScreenGadget_FrameScrollIn , 4, $ffffffff, $ff88cc44, $ff003344)
      defcadre(#PB_ScreenGadget_FrameTrackBar , 8, $ffffffff, $aa337777, $aa224444,  - 1, $bb000000)
      defcadre(#PB_ScreenGadget_FramePanel , 8, $ffffffff, $aaaadddd, $aa667777)
    Case 2
      SetScreenGadgetFont(#PB_Default, LoadFont(0, "comic Sans MS", 10*rf))
      texture(1, 128, 128, 1, 300, 64, 1, 2)
      defcadre(#PB_ScreenGadget_FrameWindow , 16, $88884444, $ff884444, $ffff8888, 0)
      defcadre(#PB_ScreenGadget_FrameRaised , 16, $bb448844, $bb448844, $ff88ff88, 0)
      defcadre(#PB_ScreenGadget_FrameSunken , 16, $444444ff, $884444ff, $ff4444ff, 0)
      defcadre(#PB_ScreenGadget_FrameString , 8, $bb884444, $bbbb4444, $bbff8888, 0, $bbffffff)
      defcadre(#PB_ScreenGadget_FrameScroll , 8, $bb666644, $ddbbbb88, $ffbbbb88, 0)
      defcadre(#PB_ScreenGadget_FrameScrollIn , 8 , $886666ff, $bb8888ff, $ff8888ff, 0)
      defcadre(#PB_ScreenGadget_FrameTrackBar , 8, $bb884444, $bbbb4444, $bbff8888, 0, $bb000000)
      defcadre(#PB_ScreenGadget_FramePanel , 8, $88884444, $ff884444, $ffff8888, 0)
    Default
      SetScreenGadgetFont(#PB_Default, LoadFont(0, "ink free", 12*rf, #PB_Font_Bold))
      texture(1, 128, 128, 0, 200, 25, 2, 2, 0.2)
      defcadre(#PB_ScreenGadget_FrameWindow , 4, $ffffffff, $dd668866, $dd446644)
      defcadre(#PB_ScreenGadget_FrameRaised , 4, $ffffffff, $bb4444ff, $bb4444aa)
      defcadre(#PB_ScreenGadget_FrameSunken , 4, $ffffffff, $bb888888, $bb444444,  - 1)
      defcadre(#PB_ScreenGadget_FrameString , 4, $ffffffff, $aa337777, $aa224444,  - 1, $ffffffff)
      defcadre(#PB_ScreenGadget_FrameScroll , 4, $ffffffff, $ddaa4444, $ddaa4444,  - 1)
      defcadre(#PB_ScreenGadget_FrameScrollIn , 4, $ffffffff, $bbcccccc, $bbcccccc)
      defcadre(#PB_ScreenGadget_FrameTrackBar , 4, $ffffffff, $aa337777, $aa224444,  - 1, $bb000000)
      defcadre(#PB_ScreenGadget_FramePanel , 4, $ffffffff, $aa99bb99, $aa446644)
  EndSelect
  ScreenGadgetSkin(#PB_ScreenGadget_TextureWindow, 1)
  
EndProcedure


Define ag.f, gadget, i, j, t.s, w2h, w2d, quit, debs, debi, delta, fading, zoom, dx, dy, rot

InitSprite():SpriteQuality(#PB_Sprite_BilinearFiltering)
InitKeyboard():InitMouse():joynb = InitJoystick()
ExamineDesktops():dx             = DesktopWidth(0) * 0.8:dy = DesktopHeight(0) * 0.8
OpenWindow(0, 0, 0, DesktopUnscaledX(dx), DesktopUnscaledY(dy), "[Escape] to quit", #PB_Window_BorderLess | #PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)

InitScreenGadgets()

SelectSkin(#skin)

texture(0, 256, 256, 0, 50, 64, 0, 0, 0.2)    ;image

LoadSprite(0, #PB_Compiler_Home + "examples/3d/Data/Textures/MRAMOR6X6.jpg", #PB_Sprite_AlphaBlending)
ZoomSprite(0, ScreenWidth() + 200, ScreenWidth() + 200)


;===============================================================
OpenScreenWindow(1, 10 , 50 , 300, 530, "Window 1", 0) : ScreenWindowAnimation(1, 3, 1000, 1, 0,  - 1, 0,  - 90)
ButtonScreenGadget(11, 100, 50, 160, 32, "Enable / Disable W2", 0)
CheckBoxScreenGadget(3, 10, 165, 100, 20, "Fading", 0)
CheckBoxScreenGadget(4, 10, 205, 100, 20, "Zoom", 0)
ComboBoxScreenGadget(5, 140, 160, 140, 32, 0):AddScreenGadgetItem(5,  - 1, "X-Left"):AddScreenGadgetItem(5,  - 1, "X-Center"):AddScreenGadgetItem(5,  - 1, "X-Right"):SetScreenGadgetState(5, 2)
ComboBoxScreenGadget(6, 140, 200, 140, 32, 0):AddScreenGadgetItem(6,  - 1, "Y-Up"):AddScreenGadgetItem(6,  - 1, "Y-center"):AddScreenGadgetItem(6,  - 1, "Y-Down"):SetScreenGadgetState(6, 1)
TextScreenGadget(8, 10, 240, 100, 24, "Rotation", 0):TrackBarScreenGadget(7, 140, 240, 140, 24,  - 3, 3, 1):SetScreenGadgetState(7, 1)
TextScreenGadget(9, 10, 270, 120, 24, "Test animation", 0):ButtonScreenGadget(10, 140, 270, 140, 32, "Show / Hide W2", 0)
EditorScreenGadget(12, 10, 320, 280, 200, #PB_Editor_WordWrap | #PB_Editor_ReadOnly)


;===============================================================
OpenScreenWindow(2, 420, 10, 550, 700, "Window 2", 0):ScreenWindowAnimation(2, 3, 1000, 0, 0, 1, 0, 90)

PanelScreenGadget(70, 10, 40, 530, 360)
;----------------------------------------
AddScreenGadgetItem(70,  - 1, "panel-1")
ImageScreenGadget(20, 260, 40, 256, 256, ImageID(0), 0)
ButtonImageScreenGadget(21, 30, 40, 80, 80, ImageID(0), 0)
ButtonImageScreenGadget(22, 140, 40, 80, 80, ImageID(0), 0)
TextScreenGadget(24, 20, 0, 100, 32, "TextGadget", #PB_Text_Right)
ComboBoxScreenGadget(25, 20, 130, 150, 32, 0):For i = 0 To 9:AddScreenGadgetItem(25,  - 1, "Combobox it " + i):Next:SetScreenGadgetState(25, 5)
OptionScreenGadget(26, 8, 180, 150, 20, "OptionGadget 1")
OptionScreenGadget(27, 8, 200, 150, 20, "OptionGadget 2"):SetScreenGadgetState(27, 1)
OptionScreenGadget(28, 8, 220, 150, 20, "OptionGadget 3")
CheckBoxScreenGadget(29, 8, 260, 150, 20, "CheckBoxGadget", 0)
;----------------------------------------
AddScreenGadgetItem(70,  - 1, "Splitter")
ImageScreenGadget(60, 0, 0, 4, 4, ImageID(0), 0)
ListViewScreenGadget(61, 220, 450, 150, 200, 0):For i = 0 To 25:AddScreenGadgetItem(61,  - 1, "item number " + i + " wwwwwwww "):Next:SetScreenGadgetState(61, 3)
SplitterScreenGadget(62, 20, 20, 490, 260, 61, 60, #PB_Splitter_Vertical):SetScreenGadgetState(62, 250)
;----------------------------------------
AddScreenGadgetItem(70,  - 1, "ScrollArea")
ScrollAreaScreenGadget(50, 20, 20, 400, 220, 410, 250, 10, 0)
For j = 0 To 3:For i = 0 To 3:ButtonScreenGadget(81 + j * 4 + i, i * 100 + 10, j * 60 + 10, 90, 30, "SA bt " + j + "-" + i, 0):Next:Next
CloseScreenGadgetList()
;----------------------------------------
CloseScreenGadgetList()
;===============================================================

ScrollBarScreenGadget(32, 20, 450, 140, 20, 0, 100, 30, 0)
ScrollBarScreenGadget(33, 20, 550, 20, 140, 0, 100, 30, #PB_ScrollBar_Vertical)
TrackBarScreenGadget(34, 20, 480, 140, 24,  - 5, 5, 0)
TrackBarScreenGadget(35, 60, 550, 24, 140,  - 10, 10, #PB_TrackBar_Vertical):SetScreenGadgetState(35, 0)
ProgressBarScreenGadget(36, 20, 520, 140, 20, 0, 1000, 0)
ProgressBarScreenGadget(37, 100, 550, 20, 140, 0, 1000, #PB_ProgressBar_Vertical)

StringScreenGadget(40, 180, 460, 250, 34, "blablabla blabla bla", 0)
EditorScreenGadget(41, 180, 500, 250, 180, #PB_Editor_WordWrap * 0):RandomSeed(2):For i = 1 To 100:t + "bla" + Mid("  " + #LF$, Random(5) + 1, 1):Next:SetScreenGadgetText(41, t)
CloseScreenGadgetList()

quit = ButtonScreenGadget( - 1, 10, 10, 50, 32, "Quit", 0)
;===============================================================


Repeat
  While WindowEvent():Wend
  ExamineMouse()
  ExamineKeyboard()
  
  ;back
  anglei.f + 0.01
  color = RGB((Sin(anglei) + 1) / 2 * 255, (Sin(anglei + 2) + 1) / 2 * 255, (Sin(anglei + 4) + 1) / 2 * 255)
  ClearScreen(color)
  DisplayTransparentSprite(0, (Cos(anglei) - 1) * 100, (Sin(anglei * 1.2) - 1) * 100, 128)
  
  If ScreenWindowEvent() = #PB_Event_Gadget
    gadget = EventScreenGadget()
    Select gadget
      Case quit:End
      Case 3, 4, 5, 6, 7
        fading = GetScreenGadgetState(3)
        zoom   = GetScreenGadgetState(4)
        dx     = GetScreenGadgetState(5) - 1
        dy     = GetScreenGadgetState(6) - 1
        rot    = GetScreenGadgetState(7) * 90
        ScreenWindowAnimation(2, 3, 1000, fading, zoom, dx, dy, rot)
      Case 10:w2h = 1 - w2h:HideScreenWindow(2, w2h)
      Case 11:w2d = 1 - w2d:DisableScreenWindow(2, w2d)
    EndSelect
    SetScreenGadgetText(12, "gadget: " + gadget + "    S_eventType: " + ScreenEventType() + #LF$ + "State: " + GetScreenGadgetState(gadget) + #LF$ + "Text: " + GetScreenGadgetText(gadget))
  EndIf
  If IsScreenGadget(36) And IsScreenGadget(37)
    ag + 0.01:SetScreenGadgetState(36, (1 + Sin(ag)) * 500):SetScreenGadgetState(37, (1 + Cos(ag)) * 500)
  EndIf
  
  RenderScreenGadgets()
  FlipBuffers()
Until KeyboardReleased(#PB_Key_Escape) Or MouseButton(#PB_MouseButton_Middle)