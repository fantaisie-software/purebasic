;|-------------------------------------------------------------------------------------------------
;|
;|  Title            : TabBarGadget
;|  Version          : 'kenmo-mods' fork based off v1.5 Beta 2a
;|  Copyright        : UnionBytes
;|                     (Martin Guttmann alias STARGÅTE)
;|  PureBasic        : 5.20+
;|  String Format    : Ascii, Unicode
;|  Operating System : Windows, Linux, MacOS
;|  Processor        : x86, x64
;|
;|-------------------------------------------------------------------------------------------------
;|
;|  Description      : Gadget for displaying and using tabs like in the browser
;|
;|  Forum Topic      : http://www.purebasic.fr/german/viewtopic.php?f=8&t=24788
;|                     http://www.purebasic.fr/english/viewtopic.php?f=12&t=47588
;|  Website          : http://www.unionbytes.de/includes/tabbargadget/
;|
;|  Documentation    : http://help.unionbytes.de/tbg/
;|
;|-------------------------------------------------------------------------------------------------




CompilerIf #PB_Compiler_IsMainFile
  EnableExplicit
CompilerEndIf




;|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
;-  1. Constants / Konstanten
;|__________________________________________________________________________________________________



; Attribute für das TabBarGadget
Enumeration
  #TabBarGadget_None                 = 0<<0
  #TabBarGadget_CloseButton          = 1<<0
  #TabBarGadget_NewTab               = 1<<1
  #TabBarGadget_TextCutting          = 1<<2
  #TabBarGadget_MirroredTabs         = 1<<3
  #TabBarGadget_Vertical             = 1<<4
  #TabBarGadget_NoTabMoving          = 1<<5
  #TabBarGadget_MultiLine            = 1<<6
  #TabBarGadget_BottomLine           = 1<<7
  #TabBarGadget_PopupButton          = 1<<8
  #TabBarGadget_Editable             = 1<<9
  #TabBarGadget_MultiSelect          = 1<<10
  #TabBarGadget_CheckBox             = 1<<11
  #TabBarGadget_SelectedCloseButton  = 1<<12
  #TabBarGadget_ReverseOrdering      = 1<<13
  #TabBarGadget_ImageSize            = 1<<23
  #TabBarGadget_TabTextAlignment     = 1<<24
  #TabBarGadget_ScrollPosition       = 1<<25
  #TabBarGadget_NormalTabLength      = 1<<26 ; für Später
  #TabBarGadget_MaxTabLength         = 1<<27
  #TabBarGadget_MinTabLength         = 1<<28
  #TabBarGadget_TabRounding          = 1<<29
EndEnumeration

; Global attributes for all TabBarGadgets
Enumeration
  #TabBarGadgetGlobal_WheelDirection   = 1 << 0
  #TabBarGadgetGlobal_WheelAction      = 1 << 1
  #TabBarGadgetGlobal_DrawDisabled     = 1 << 2
  #TabBarGadgetGlobal_MiddleClickClose = 1 << 3
  #TabBarGadgetGlobal_DoubleClickNew   = 1 << 4
  #TabBarGadgetGlobal_TabBarColor      = 1 << 5
  #TabBarGadgetGlobal_BorderColor      = 1 << 6
  #TabBarGadgetGlobal_FaceColor        = 1 << 7
  #TabBarGadgetGlobal_TextColor        = 1 << 8
EndEnumeration

; Ereignisse von TabBarGadgetEvent
Enumeration #PB_EventType_FirstCustomValue
  #TabBarGadget_EventType_Pushed
  #TabBarGadget_EventType_Updated      ; Das Gadget hat sich aktualisiert (intern)
  #TabBarGadget_EventType_Change       ; Der aktive Tab wurde geändert
  #TabBarGadget_EventType_Resize       ; Die größe der Leiste hat sich geändert
  #TabBarGadget_EventType_NewItem      ; ein neuer Tab wird angefordert
  #TabBarGadget_EventType_CloseItem    ; ein Tab soll geschlossen werden
  #TabBarGadget_EventType_SwapItem     ; der aktive Tab wurde verschoben
  #TabBarGadget_EventType_EditItem     ; der Text einer Karte wurde geändert
  #TabBarGadget_EventType_CheckBox     ; der Status der Checkbox hat sich geändert
  #TabBarGadget_EventType_PopupButton  ; der Popup-Button wurde gedrückt
EndEnumeration




; Positionskonstanten für "Item"-Befehle
Enumeration
  #TabBarGadgetItem_None        = -1
  #TabBarGadgetItem_NewTab      = -2
  #TabBarGadgetItem_Selected    = -3
  #TabBarGadgetItem_Event       = -4
EndEnumeration

; Status-Konstanten
Enumeration
  #TabBarGadget_Disabled        = 1<<0
  #TabBarGadget_Selected        = 1<<1
  #TabBarGadget_Checked         = 1<<2
EndEnumeration

; Status-Konstanten
Enumeration
  #TabBarGadgetUpdate_Directly  = 0
  #TabBarGadgetUpdate_PostEvent = 1
EndEnumeration

; MouseWheel actions
Enumeration
  #TabBarGadgetWheelAction_None   = 0
  #TabBarGadgetWheelAction_Scroll = 1
  #TabBarGadgetWheelAction_Change = 2
EndEnumeration

#TabBarGadget_DefaultHeight     = 1

; Default colors
#TabBarGadgetColor_TabBarDefault = $D0D0D0
#TabBarGadgetColor_BorderDefault = $808080
#TabBarGadgetColor_FaceDefault   = $D0D0D0
#TabBarGadgetColor_TextDefault   = $000000


; Interne Konstanten
#TabBarGadget_PreviousArrow   = 1<<30
#TabBarGadget_NextArrow       = 1<<31
#TabBarGadgetItem_DisableFace = -1
#TabBarGadgetItem_NormalFace  = 0
#TabBarGadgetItem_HoverFace   = 1
#TabBarGadgetItem_ActiveFace  = 2
#TabBarGadgetItem_MoveFace    = 3

; Compile switch for extra safety - could affect callback performance!
CompilerIf Not Defined(TabBarGadget_EnableCallbackGadgetCheck, #PB_Constant)
  #TabBarGadget_EnableCallbackGadgetCheck = #False
CompilerEndIf

; Compile switch to use WinAPI for drawing clearer text
CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  CompilerIf Not Defined(TabBarGadget_EnableWinAPIText, #PB_Constant)
    #TabBarGadget_EnableWinAPIText = #True
  CompilerEndIf
CompilerElse
  #TabBarGadget_EnableWinAPIText = #False
CompilerEndIf



;|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
;-  2. Structures / Strukturen
;|__________________________________________________________________________________________________



; Sortierter Eintrag für die Textkürzung
Structure TabBarGadgetSortedItem
  *Item.TabBarGadgetItem  ; Registerkarte
  Characters.i            ; Anzahl der Buchstaben
EndStructure

; Aktuelle Parameter eine Kartenzeile
Structure TabBarGadgetRow
  Length.i  ; Aktuelle Länge einer Zeile
  Items.i   ; Aktuelle Anzahl der Tabs
EndStructure

; Farben für einen Eintrag
Structure TabBarGadgetItemColor
  Text.i        ; Textfarbe
  Background.i  ; Hintergrundfarbe
EndStructure

; Lage und Größe einer Registerkarte
Structure TabBarGadgetItemLayout
  X.i         ; X-Position
  Y.i         ; Y-Position
  Width.i     ; (innere) Breite
  Height.i    ; (innere) Höhe
  PaddingX.i  ; Vergrößerung (z.B. bei aktiver Registerkarte)
  PaddingY.i  ;
  CrossX.i    ; Position des Schließen-X
  CrossY.i    ;
  TextX.i     ; Textposition
  TextY.i     ;
  CheckX.i    ; Checkbox-Position
  CheckY.i    ;
  ImageX.i    ; Icon-Position
  ImageY.i    ;
EndStructure

; Registerkarte
Structure TabBarGadgetItem
  Text.s                                  ; Text
  ShortText.s                             ; verkürzter Text
  Color.TabBarGadgetItemColor             ; Farbattribute
  Image.i                                 ; Bild (Kopie vom Original)
  DrawedImage.i                           ; Bild (Kopie ggf. rotiert)
  DataValue.i                             ; Benutzer-Daten-Wert
  Attributes.i                            ; Attribute
  Disabled.i                              ; Deaktiviert
  Selected.i                              ; Aktuell ausgewählt
  Checked.i                               ; Abgehakt
  ToolTip.s                               ; ToolTop
  Length.i                                ; Länge in Pixel (TEMP)
  Row.i                                   ; Zeile (TEMP)
  Position.i                              ; Position (TEMP)
  Visible.i                               ; Sichtbar und wird gezeichnet (TEMP)
  Face.i                                  ; Aussehen (TEMP)
  Layout.TabBarGadgetItemLayout           ; Layout der Karte (TEMP)
  *PreviousSelectedItem.TabBarGadgetItem  ; Zuvor ausgewählter Tab
EndStructure

; Tooltips
Structure TabBarGadgetToolTip
  *Current                         ; Aktuelle ToolTip-Adresse
  *Old                             ; Alte ToolTip-Adresse
  ItemText.s                       ; Text für die Registerkarte
  NewText.s                        ; Text für die "Neu"-Registerkarte
  CloseText.s                      ; Text für den Schließen-Button
EndStructure

; Editierte Karte
Structure TabBarGadgetEditor
  *Item.TabBarGadgetItem  ; Zu Bearbeitende Karte
  OldText.s               ; Alter Text vor dem Bearbeiten
  Cursor.i                ; Cursor-Position
  Selection.i             ; Textmarkierungslänge
  Selectable.i            ; Ob die Mausbewegung zu einer Textmarkierung führt
EndStructure

; Layout der Leiste
Structure TabBarGadgetLayout
  PreviousButtonX.i  ; Position des "zurück" Navigationspfeil
  PreviousButtonY.i
  NextButtonX.i  ; Position des "vor" Navigationspfeil
  NextButtonY.i
  PopupButtonX.i ; Position des Popup-Pfeils
  PopupButtonY.i
  ButtonWidth.i  ; Größe der Buttons
  ButtonHeight.i
  ButtonSize.i
EndStructure

; Registerkartenleiste
Structure TabBarGadget
  Number.i                          ; #Nummer
  Window.i                          ; Fenster-Nummer
  FontID.i                          ; Schrift
  DataValue.i                       ; Benutzer-Daten-Wert
  Attributes.i                      ; Attribute
  List    Item.TabBarGadgetItem()   ; Registerkarten
  NewTabItem.TabBarGadgetItem       ; "Neu"-Registerkarte
  *SelectedItem.TabBarGadgetItem    ; ausgewählte Registerkarte
  *MoveItem.TabBarGadgetItem        ; bewegte Registerkarte
  *HoverItem.TabBarGadgetItem       ; hervorgehobene Registerkarte
  HoverClose.i                      ; Schließenbutton hervorgehoben
  HoverCheck.i                      ; Checkbox hervorgehoben
  HoverArrow.i                      ; Navigationbutton hervorgehoben
  *ReadyToMoveItem.TabBarGadgetItem ; Registerkarte die bereit ist bewegt zu werden
  *LockedItem.TabBarGadgetItem      ; Registerkarte angeschlagen wurde (für Klicks)
  LockedClose.i                     ; Schließenbutton angeschlagen
  LockedCheck.i                     ; Schließenbutton angeschlagen
  LockedArrow.i                     ; Navigationsbutton angeschlagen
  SaveMouseX.i                      ; gespeicherte Mausposition
  SaveMouseY.i                      ; gespeicherte Mausposition
  MouseX.i                          ; X-Mausposition
  MouseY.i                          ; Y-Mausposition
  Event.i                           ; letztes Ereignis
  EventTab.i                        ; Registerkartenposition auf der das letzte Ereignis war
  Shift.i                           ; Verschiebung der Leiste
  LastShift.i                       ; Maximale sinnvolle Verschiebung
  FocusingSelectedTab.i             ; muss die ausgewählte Registerkarte fokussiert werden
  MaxLength.i                       ; maximal nutzbare Länge für Karten
  Length.i                          ; Länge aller sichtbaren Karten
  Radius.i                          ; Radius der Kartenrundung
  MinTabLength.i                    ; minimale Länge einer Karte
  MaxTabLength.i                    ; maximale Länge einer Karte
  NormalTabLength.i                 ; normale Länge einer Karte
  TabTextAlignment.i                ; Textausrichtung
  ToolTip.TabBarGadgetToolTip       ; ToolTip
  TabSize.i                         ; Größer einer Registerkarte
  Rows.i                            ; Anzahl der Zeilen
  Resized.i                         ; Das Gadget muss vergrößert werden
  Editor.TabBarGadgetEditor         ; Editor für eine Karte
  Layout.TabBarGadgetLayout         ; Layout der Leiste
  UpdatePosted.i                    ; Nach einem PostEvent #True
  CompilerIf #TabBarGadget_EnableWinAPIText
    DrawingID.i                     ; Drawing handle for API text drawing
    PrevFont.i                      ; Store previous font handle to restore
    DrawRect.RECT                   ; Allocate a RECT struct for WinAPI
  CompilerEndIf
EndStructure

; Timer für das kontinuierliche Scrollen
Structure TabBarGadget_Timer
  *TabBarGadget.TabBarGadget  ; TabBarGadget-ID
  Type.i                      ; Modus (Scrollen)
  Mutex.i                     ; Mutex zur Sicherung
EndStructure

; Include für das Registerkartenleisten-Gadget
Structure TabBarGadgetInclude
  TabBarColor.i                   ; Hintergrundfarbe des Gadgets
  FaceColor.i                     ; Hintergrundfarbe einer Karte
  HoverColorPlus.i                ; Farbänderung für den Hover-Effekt
  ActivColorPlus.i                ; Farbänderung für aktuell ausgewählte Karten
  BorderColor.i                   ; Rahmenfarbe
  TextColor.i                     ; Textfarbe
  PaddingX.i                      ; Innenabstand (Text zu Rahmen)
  PaddingY.i                      ; Innenabstand (Text zu Rahmen)
  Margin.i                        ; Außenabstand (Rahmen zu Gadget-Rand)
  ImageSpace.i                    ; Freiraum zwischen Bild und Text
  CloseButtonSize.i               ; Größe des Schließenkreuzes
  CheckBoxSize.i
  ImageSize.i
  ArrowSize.i                     ; Größe des Navigationspfeils
  ArrowWidth.i                    ;
  ArrowHeight.i                   ;
  Radius.i                        ; Radius der Abrundung der Karte
  MinTabLength.i                  ; Mimimale Länge einer Karte
  MaxTabLength.i                  ; Maximale Länge einer Karte
  TabTextAlignment.i
  VerticalTextBugFix.f
  NormalTabLength.i               ; [für später]
  FadeOut.i                       ; Länge der Farbausblendung bei einer Navigation
  WheelDirection.i                ; Scrollrichtung bei Mausradbewegung
  WheelAction.i                   ; Action for MouseWheel events
  RowDirection.i                  ; Reihenfolge der Zeilen
  EnableDoubleClickForNewTab.i    ; Doppelklick ins "Leere" erzeigt ein Ereignis
  EnableMiddleClickForCloseTab.i  ; Mittelklick auf eine Karte erzeigt ein Ereignis
  Timer.TabBarGadget_Timer        ; Timer für das kontinuierliche Scrollen
  DefaultFontID.i                 ; System default font ID
  DrawDisabled.i                  ; Disable redraw for batch tab changes
EndStructure





;|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
;-  3. Initializations / Initialisierungen
;|__________________________________________________________________________________________________



Global TabBarGadgetInclude.TabBarGadgetInclude
Declare TabBarGadget_Timer(Null.i)

; Diese Werte können sowohl im Include, als auch im Hauptcode später über TabBarGadgetInclude\Feld geändert werden.
With TabBarGadgetInclude
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      \TabBarColor   = $FF<<24 | GetSysColor_(#COLOR_BTNFACE)
      \BorderColor   = $FF<<24 | GetSysColor_(#COLOR_3DSHADOW)
      \FaceColor     = $FF<<24 | GetSysColor_(#COLOR_BTNFACE)
      \TextColor     = $FF<<24 | GetSysColor_(#COLOR_BTNTEXT)
    CompilerDefault
      \TabBarColor   = $FF<<24 | #TabBarGadgetColor_TabBarDefault
      \BorderColor   = $FF<<24 | #TabBarGadgetColor_BorderDefault
      \FaceColor     = $FF<<24 | #TabBarGadgetColor_FaceDefault
      \TextColor     = $FF<<24 | #TabBarGadgetColor_TextDefault
  CompilerEndSelect
  \HoverColorPlus               = $FF101010
  \ActivColorPlus               = $FF101010
  \PaddingX                     = DesktopScaledX(6)  ; Space from tab border to text
  \PaddingY                     = DesktopScaledX(5)  ; Space from tab border to text
  \Margin                       = 4                  ; Space from tab to border
  \ImageSpace                   = DesktopScaledX(3)  ; Space from image zu text
  \ImageSize                    = DesktopScaledX(16)
  \CloseButtonSize              = DesktopScaledX(13) ; Size of the close cross
  \CheckBoxSize                 = DesktopScaledX(10)
  \ArrowSize                    = DesktopScaledX(5)  ; Size of the Arrow in the button in navigation
  \ArrowWidth                   = DesktopScaledX(12) ; Width of the Arrow-Button in navigation
  \ArrowHeight                  = DesktopScaledY(18) ; Height of the Arrow-Button in navigation
  \Radius                       = DesktopScaledX(3)  ; Radius of the edge of the tab
  \TabTextAlignment             = -1
  \VerticalTextBugFix           = 1.05
  \MinTabLength                 = 0
  \MaxTabLength                 = 10000
  \NormalTabLength              = 150
  \FadeOut                      = 32 ; Length of fade out to the navi
  \WheelDirection               = -1
  \WheelAction                  = #TabBarGadgetWheelAction_Scroll
  \RowDirection                 = 1 ; not used
  \EnableDoubleClickForNewTab   = #True
  \EnableMiddleClickForCloseTab = #True
  \Timer\Mutex                  = CreateMutex()
  CompilerIf #PB_Compiler_Thread
    CreateThread(@TabBarGadget_Timer(), #Null)
  CompilerEndIf
EndWith






;|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
;-  4. Procedures & Macros / Prozeduren & Makros
;|__________________________________________________________________________________________________



;-  4.1 Private procedures for internal calculations ! Not for use !
;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

; StartDrawing() wrapper which saves handle for WinAPI drawing
Procedure.i TabBarGadget_StartDrawing(*TabBarGadget.TabBarGadget)
  CompilerIf #TabBarGadget_EnableWinAPIText
    With *TabBarGadget
      \DrawingID = StartDrawing(CanvasOutput(*TabBarGadget\Number))
      If \DrawingID
        \PrevFont = SelectObject_(\DrawingID, \FontID)
        \DrawRect\right  = OutputWidth()
        \DrawRect\bottom = OutputHeight()
        SetBkMode_(\DrawingID, #TRANSPARENT)
      EndIf
      ProcedureReturn \DrawingID
    EndWith
  CompilerElse
    ProcedureReturn StartDrawing(CanvasOutput(*TabBarGadget\Number))
  CompilerEndIf
EndProcedure

; StopDrawing() wrapper which clears handle for WinAPI drawing
Procedure.i TabBarGadget_StopDrawing(*TabBarGadget.TabBarGadget)
  CompilerIf #TabBarGadget_EnableWinAPIText
    With *TabBarGadget
      If (\DrawingID)
        SelectObject_(\DrawingID, \PrevFont)
        \DrawingID = #Null
      EndIf
    EndWith
  CompilerEndIf
  StopDrawing()
EndProcedure

; DrawText() wrapper which uses Windows API if enabled
Procedure TabBarGadget_DrawText(*TabBarGadget.TabBarGadget, x.i, y.i, Text.s, Color.i)
  CompilerIf #TabBarGadget_EnableWinAPIText
    With *TabBarGadget
      \DrawRect\left = x
      \DrawRect\top  = y
      SetTextColor_(\DrawingID, Color & $00FFFFFF)
      DrawText_(\DrawingID, @Text, -1, @\DrawRect, #DT_NOPREFIX | #DT_SINGLELINE)
    EndWith
  CompilerElse
    DrawText(x, y, Text, Color)
  CompilerEndIf
EndProcedure


; Gitb die Adresse (ID) der Registerkarte zurück.
;   Position kann eine Konstante, Position oder ID sein.
Procedure.i TabBarGadget_ItemID(*TabBarGadget.TabBarGadget, Position.i) ; Code OK
  
  With *TabBarGadget
    
    Select Position
      Case #TabBarGadgetItem_Event
        ProcedureReturn TabBarGadget_ItemID(*TabBarGadget, \EventTab)
      Case #TabBarGadgetItem_Selected
        If \SelectedItem
          ChangeCurrentElement(\Item(), \SelectedItem)
          ProcedureReturn @\Item()
        Else
          ProcedureReturn #Null
        EndIf
      Case #TabBarGadgetItem_NewTab
        ProcedureReturn @\NewTabItem
      Case #TabBarGadgetItem_None
        ProcedureReturn #Null
      Default
        If Position >= 0 And Position < ListSize(\Item())
          ProcedureReturn SelectElement(\Item(), Position)
        ElseIf Position >= ListSize(\Item())
          ForEach \Item()
            If @\Item() = Position
              ProcedureReturn @\Item()
            EndIf
          Next
        EndIf
    EndSelect
    
  EndWith
  
EndProcedure



; Gibt die Ressourcen einer Registerkarte wieder frei.
Procedure TabBarGadget_ClearItem(*TabBarGadget.TabBarGadget, *Item.TabBarGadgetItem) ; Code OK
  
  If *Item\Image
    FreeImage(*Item\Image)
  EndIf
  If *Item\DrawedImage
    FreeImage(*Item\DrawedImage)
  EndIf
  
EndProcedure



; Wählt die angegebene Karte aus und aktualisiert die Select-Hierarchie
Procedure TabBarGadget_SelectItem(*TabBarGadget.TabBarGadget, *Item.TabBarGadgetItem) ; Code OK
  
  If *TabBarGadget\Attributes & #TabBarGadget_MultiSelect = #False
    ForEach *TabBarGadget\Item()
      *TabBarGadget\Item()\Selected = #False
    Next
  EndIf
  If *Item
    *Item\Selected = #True
    If *Item <> *TabBarGadget\SelectedItem
      *Item\PreviousSelectedItem = *TabBarGadget\SelectedItem
    EndIf
    *TabBarGadget\FocusingSelectedTab = #True
  EndIf
  *TabBarGadget\SelectedItem = *Item
  
EndProcedure



; Wählt die angegebene Karte ab und aktualisiert die Select-Hierarchie
Procedure TabBarGadget_UnselectItem(*TabBarGadget.TabBarGadget, *Item.TabBarGadgetItem) ; Code OK
  
  *Item\Selected = #False
  ForEach *TabBarGadget\Item()
    If *TabBarGadget\Item()\PreviousSelectedItem = *Item
      If *Item\PreviousSelectedItem <> *TabBarGadget\Item()
        *TabBarGadget\Item()\PreviousSelectedItem = *Item\PreviousSelectedItem
      Else
        *TabBarGadget\Item()\PreviousSelectedItem = #Null
      EndIf
    EndIf
  Next
  If *TabBarGadget\SelectedItem = *Item ; Auswahl muss geändert werden
    *TabBarGadget\SelectedItem = *Item\PreviousSelectedItem
    If *TabBarGadget\SelectedItem
      *TabBarGadget\SelectedItem\Selected = #True
    EndIf
  EndIf
  
EndProcedure



; Entfernt die Registerkarte und aktualisiert die Select-Hierarchie
Procedure TabBarGadget_RemoveItem(*TabBarGadget.TabBarGadget, *Item.TabBarGadgetItem) ; Code OK
  
  If *Item = #Null
    ProcedureReturn
  EndIf
  
  With *TabBarGadget
    If (\HoverItem = *Item)
      \HoverItem = #Null
    EndIf
    If (\HoverCheck = *Item)
      \HoverCheck = #Null
    EndIf
    If (\HoverClose = *Item)
      \HoverClose = #Null
    EndIf
    If (\LockedItem = *Item)
      \LockedItem = #Null
    EndIf
    If (\LockedCheck = *Item)
      \LockedCheck = #Null
    EndIf
    If (\LockedClose = *Item)
      \LockedClose = #Null
    EndIf
    If (\MoveItem = *Item)
      \MoveItem = #Null
    EndIf
    If (\ReadyToMoveItem = *Item)
      \ReadyToMoveItem = #Null
    EndIf
  EndWith
  
  TabBarGadget_ClearItem(*TabBarGadget, *Item)
  If *TabBarGadget\SelectedItem
    TabBarGadget_UnselectItem(*TabBarGadget, *Item)
    If *TabBarGadget\SelectedItem = #Null
      ChangeCurrentElement(*TabBarGadget\Item(), *Item)
      If NextElement(*TabBarGadget\Item())
        TabBarGadget_SelectItem(*TabBarGadget.TabBarGadget, *TabBarGadget\Item())
      ElseIf PreviousElement(*TabBarGadget\Item())
        TabBarGadget_SelectItem(*TabBarGadget.TabBarGadget, *TabBarGadget\Item())
      EndIf
    EndIf
  Else
    TabBarGadget_UnselectItem(*TabBarGadget, *Item)
  EndIf
  
  ChangeCurrentElement(*TabBarGadget\Item(), *Item)
  DeleteElement(*TabBarGadget\Item())
  
EndProcedure



; Gibt #True zurück, wenn die Maus innerhalb des Rechtecks ist.
;   Width und Height können auch negativ sein.
Procedure.i TabBarGadget_MouseIn(*TabBarGadget.TabBarGadget, X.i, Y.i, Width.i, Height.i) ; Code OK
  
  With *TabBarGadget
    
    If Width  < 0 : X + Width  : Width  * -1 : EndIf
    If Height < 0 : Y + Height : Height * -1 : EndIf
    If \MouseX >= X And \MouseX < X+Width And \MouseY >= Y And \MouseY < Y+Height
      ProcedureReturn #True
    EndIf
    
  EndWith
  
EndProcedure



; Farbaddition
Procedure.i TabBarGadget_ColorPlus(Color.i, Plus.i) ; Code OK
  
  If Color&$FF + Plus&$FF < $FF
    Color + Plus&$FF
  Else
    Color | $FF
  EndIf
  If Color&$FF00 + Plus&$FF00 < $FF00
    Color + Plus&$FF00
  Else
    Color | $FF00
  EndIf
  If Color&$FF0000 + Plus&$FF0000 < $FF0000
    Color + Plus&$FF0000
  Else
    Color | $FF0000
  EndIf
  
  ProcedureReturn Color
  
EndProcedure



; Farbsubtraktion
Procedure.i TabBarGadget_ColorMinus(Color.i, Minus.i) ; Code OK
  
  If Color&$FF - Minus&$FF > 0
    Color - Minus&$FF
  Else
    Color & $FFFFFF00
  EndIf
  If Color&$FF00 - Minus&$FF00 > 0
    Color - Minus&$FF00
  Else
    Color & $FFFF00FF
  EndIf
  If Color&$FF0000 - Minus&$FF0000 > 0
    Color - Minus&$FF0000
  Else
    Color & $FF00FFFF
  EndIf
  
  ProcedureReturn Color
  
EndProcedure



; Zeichnet ein (Schließen-)Kreuz
Procedure TabBarGadget_DrawCross(X.i, Y.i, Size.i, Color.i) ; Code OK
  
  Protected Alpha.i = Alpha(Color)/4
  
  Line(X  , Y+1     , Size-1,  Size-1, Color&$FFFFFF|Alpha<<24)
  Line(X+1, Y       , Size-1,  Size-1, Color&$FFFFFF|Alpha<<24)
  Line(X  , Y+Size-2, Size-1, -Size+1, Color&$FFFFFF|Alpha<<24)
  Line(X+1, Y+Size-1, Size-1, -Size+1, Color&$FFFFFF|Alpha<<24)
  Line(X  , Y       , Size  ,  Size  , Color)
  Line(X  , Y+Size-1, Size  , -Size  , Color)
  
EndProcedure



; Zeichnet einen Button
Procedure TabBarGadget_DrawButton(X.i, Y.i, Width.i, Height.i, Type.i, Color, Vertical.i=#False) ; Code OK
  
  If Type
    DrawingMode(#PB_2DDrawing_Transparent|#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Gradient)
    ResetGradientColors()
    If Type = 1
      GradientColor(0.0, TabBarGadget_ColorPlus(Color, $404040))
      GradientColor(0.5, Color)
      GradientColor(1.0, TabBarGadget_ColorMinus(Color, $404040))
    ElseIf Type = -1
      GradientColor(1.0, TabBarGadget_ColorPlus(Color, $404040))
      GradientColor(0.5, Color)
      GradientColor(0.0, TabBarGadget_ColorMinus(Color, $404040))
    EndIf
    If Vertical
      LinearGradient(X, Y, X+Width-1, Y)
      RoundBox(X, Y, Width, Height, 3, 3)
      DrawingMode(#PB_2DDrawing_Outlined|#PB_2DDrawing_AlphaBlend)
      RoundBox(X, Y, Width, Height, 3, 3, TabBarGadgetInclude\BorderColor&$FFFFFF|$80<<24)
    Else
      LinearGradient(X, Y, X, Y+Height-1)
      RoundBox(X, Y, Width, Height, 3, 3)
      DrawingMode(#PB_2DDrawing_Outlined|#PB_2DDrawing_AlphaBlend)
      RoundBox(X, Y, Width, Height, 3, 3, TabBarGadgetInclude\BorderColor&$FFFFFF|$80<<24)
    EndIf
    DrawingMode(#PB_2DDrawing_Transparent|#PB_2DDrawing_AlphaBlend)
  EndIf
  
EndProcedure



; Zeichnet einen Pfeil
Procedure TabBarGadget_DrawArrow(X.i, Y.i, Type.i, Color.i, Attributes.i=#Null) ; Code OK
  
  Protected Index.i, Alpha.i = Alpha(Color)/4
  
  With TabBarGadgetInclude
    If Attributes & #TabBarGadget_Vertical
      If Attributes & #TabBarGadget_MirroredTabs
        Select Type
          Case #TabBarGadget_PopupButton
            X - \ArrowSize/2-1
            For Index = 1 To \ArrowSize
              Line(X+Index, Y-Index, 1, Index*2, Color)
            Next
            LineXY(X, Y-1, X+\ArrowSize, Y-1-\ArrowSize, Color&$FFFFFF|Alpha<<24)
            LineXY(X, Y, X+\ArrowSize, Y+\ArrowSize, Color&$FFFFFF|Alpha<<24)
        EndSelect
      Else
        Select Type
          Case #TabBarGadget_PopupButton
            X + \ArrowSize/2
            For Index = 1 To \ArrowSize
              Line(X-Index, Y-Index, 1, Index*2, Color)
            Next
            LineXY(X, Y-1, X-\ArrowSize, Y-1-\ArrowSize, Color&$FFFFFF|Alpha<<24)
            LineXY(X, Y, X-\ArrowSize, Y+\ArrowSize, Color&$FFFFFF|Alpha<<24)
        EndSelect
      EndIf
      If Attributes & #TabBarGadget_MirroredTabs XOr Attributes & #TabBarGadget_ReverseOrdering
        Select Type
          Case #TabBarGadget_PreviousArrow
            Y - \ArrowSize/2-1
            For Index = 1 To \ArrowSize
              Line(X-Index, Y+Index, Index*2, 1, Color)
            Next
            LineXY(X-1, Y, X-1-\ArrowSize, Y+\ArrowSize, Color&$FFFFFF|Alpha<<24)
            LineXY(X, Y, X+\ArrowSize, Y+\ArrowSize, Color&$FFFFFF|Alpha<<24)
          Case #TabBarGadget_NextArrow
            Y + \ArrowSize/2
            For Index = 1 To \ArrowSize
              Line(X-Index, Y-Index, Index*2, 1, Color)
            Next
            LineXY(X-1, Y, X-1-\ArrowSize, Y-\ArrowSize, Color&$FFFFFF|Alpha<<24)
            LineXY(X, Y, X+\ArrowSize, Y-\ArrowSize, Color&$FFFFFF|Alpha<<24)
        EndSelect
      Else
        Select Type
          Case #TabBarGadget_PreviousArrow
            Y + \ArrowSize/2
            For Index = 1 To \ArrowSize
              Line(X-Index, Y-Index, Index*2, 1, Color)
            Next
            LineXY(X-1, Y, X-1-\ArrowSize, Y-\ArrowSize, Color&$FFFFFF|Alpha<<24)
            LineXY(X, Y, X+\ArrowSize, Y-\ArrowSize, Color&$FFFFFF|Alpha<<24)
          Case #TabBarGadget_NextArrow
            Y - \ArrowSize/2-1
            For Index = 1 To \ArrowSize
              Line(X-Index, Y+Index, Index*2, 1, Color)
            Next
            LineXY(X-1, Y, X-1-\ArrowSize, Y+\ArrowSize, Color&$FFFFFF|Alpha<<24)
            LineXY(X, Y, X+\ArrowSize, Y+\ArrowSize, Color&$FFFFFF|Alpha<<24)
        EndSelect
      EndIf
    Else
      Select Type
        Case #TabBarGadget_PopupButton
          Y + \ArrowSize/2
          For Index = 1 To \ArrowSize
            Line(X-Index, Y-Index, Index*2, 1, Color)
          Next
          LineXY(X-1, Y, X-1-\ArrowSize, Y-\ArrowSize, Color&$FFFFFF|Alpha<<24)
          LineXY(X, Y, X+\ArrowSize, Y-\ArrowSize, Color&$FFFFFF|Alpha<<24)
      EndSelect
      If Attributes & #TabBarGadget_ReverseOrdering
        Select Type
          Case #TabBarGadget_PreviousArrow
            X + \ArrowSize/2
            For Index = 1 To \ArrowSize
              Line(X-Index, Y-Index, 1, Index*2, Color)
            Next
            LineXY(X, Y-1, X-\ArrowSize, Y-1-\ArrowSize, Color&$FFFFFF|Alpha<<24)
            LineXY(X, Y, X-\ArrowSize, Y+\ArrowSize, Color&$FFFFFF|Alpha<<24)
          Case #TabBarGadget_NextArrow
            X - \ArrowSize/2-1
            For Index = 1 To \ArrowSize
              Line(X+Index, Y-Index, 1, Index*2, Color)
            Next
            LineXY(X, Y-1, X+\ArrowSize, Y-1-\ArrowSize, Color&$FFFFFF|Alpha<<24)
            LineXY(X, Y, X+\ArrowSize, Y+\ArrowSize, Color&$FFFFFF|Alpha<<24)
        EndSelect
      Else
        Select Type
          Case #TabBarGadget_PreviousArrow
            X - \ArrowSize/2-1
            For Index = 1 To \ArrowSize
              Line(X+Index, Y-Index, 1, Index*2, Color)
            Next
            LineXY(X, Y-1, X+\ArrowSize, Y-1-\ArrowSize, Color&$FFFFFF|Alpha<<24)
            LineXY(X, Y, X+\ArrowSize, Y+\ArrowSize, Color&$FFFFFF|Alpha<<24)
          Case #TabBarGadget_NextArrow
            X + \ArrowSize/2
            For Index = 1 To \ArrowSize
              Line(X-Index, Y-Index, 1, Index*2, Color)
            Next
            LineXY(X, Y-1, X-\ArrowSize, Y-1-\ArrowSize, Color&$FFFFFF|Alpha<<24)
            LineXY(X, Y, X-\ArrowSize, Y+\ArrowSize, Color&$FFFFFF|Alpha<<24)
        EndSelect
      EndIf
    EndIf
  EndWith
  
EndProcedure



; Gibt die Länge der Registerkate zurück.
Procedure.i TabBarGadget_ItemLength(*TabBarGadget.TabBarGadget, *Item.TabBarGadgetItem) ; Code OK
  
  Protected TextLength.i = TextWidth(*Item\ShortText)
  Protected Length.i = 2 * TabBarGadgetInclude\PaddingX
  Protected Characters.i, VerticalTextBugFix.f = 1.0
  
  If *TabBarGadget\Attributes & #TabBarGadget_Vertical
    TextLength * TabBarGadgetInclude\VerticalTextBugFix ; 5% länger, wegen Ungenaugikeit von TextWidth bei Rotation
    VerticalTextBugFix = TabBarGadgetInclude\VerticalTextBugFix
  EndIf
  If *Item\Attributes & #TabBarGadget_CloseButton Or (*Item\Attributes & #TabBarGadget_SelectedCloseButton And *Item\Selected)
    Length + TabBarGadgetInclude\CloseButtonSize-4 + TabBarGadgetInclude\ImageSpace
  EndIf
  If *Item\Attributes & #TabBarGadget_CheckBox
    Length + TabBarGadgetInclude\CheckBoxSize + TabBarGadgetInclude\ImageSpace
  EndIf
  If *Item\Image
    If *TabBarGadget\Attributes & #TabBarGadget_Vertical
      Length + ImageHeight(*Item\Image)
    Else
      Length + ImageWidth(*Item\Image)
    EndIf
    If *Item\ShortText
      Length + TabBarGadgetInclude\ImageSpace
    EndIf
  ElseIf *Item = *TabBarGadget\NewTabItem And *Item\Text = ""
    Length + 16
  EndIf
  If *Item <> *TabBarGadget\NewTabItem
    If TextLength+Length < *TabBarGadget\MinTabLength
      Length = *TabBarGadget\MinTabLength-TextLength
    EndIf
    If TextLength+Length > *TabBarGadget\MaxTabLength
      Characters = Len(*Item\Text)
      Repeat
        Characters - 1
        TextLength = TextWidth(Left(*Item\Text, Characters)+"..")*VerticalTextBugFix
      Until Characters = 1 Or TextLength+Length <= *TabBarGadget\MaxTabLength
      *Item\ShortText = Left(*Item\Text, Characters) + ".."
    EndIf
  EndIf
  
  ProcedureReturn TextLength + Length
  
EndProcedure



; Gibt den maximal zur verfügungstehenden Platz für Registerkarten zurück.
Procedure.i TabBarGadget_MaxLength(*TabBarGadget.TabBarGadget, WithNewTab.i=#True) ; Code OK
  
  Protected Length.i
  
  With *TabBarGadget
    If \Attributes & #TabBarGadget_Vertical
      Length = OutputHeight() - TabBarGadgetInclude\Margin*2
    Else
      Length = OutputWidth()  - TabBarGadgetInclude\Margin*2
    EndIf
    If \Attributes & #TabBarGadget_NewTab And WithNewTab
      Length - *TabBarGadget\NewTabItem\Length + 1
    EndIf
    If \Attributes & #TabBarGadget_PreviousArrow
      Length - TabBarGadgetInclude\ArrowWidth
    EndIf
    If \Attributes & #TabBarGadget_NextArrow
      Length - TabBarGadgetInclude\ArrowWidth
      If \Attributes & #TabBarGadget_NewTab
        Length - TabBarGadgetInclude\Margin
      EndIf
    EndIf
    If \Attributes & #TabBarGadget_PopupButton
      Length - TabBarGadgetInclude\ArrowHeight
    EndIf
  EndWith
  
  ProcedureReturn Length
  
EndProcedure



; Führt eine Textkürzung durch, bis alle Karte in die Leiste passen.
Procedure.i TabBarGadget_TextCutting(*TabBarGadget.TabBarGadget) ; Code OK
  
  Protected NewList SortedItem.TabBarGadgetSortedItem()
  Protected *SortedItem.TabBarGadgetSortedItem
  Protected MaxLength.i = 1, Length.i
  
  With *TabBarGadget
    
    ; Der Textlänge nach (groß -> klein) sortierte Einträge anlegen.
    ForEach \Item()
      \Item()\ShortText      = \Item()\Text
      \Item()\Length         = TabBarGadget_ItemLength(*TabBarGadget, @\Item())
      If *TabBarGadget\Editor\Item <> \Item()
        LastElement(SortedItem())
        *SortedItem            = AddElement(SortedItem())
        *SortedItem\Item       = @\Item()
        *SortedItem\Characters = Len(\Item()\Text)
        While PreviousElement(SortedItem()) And *SortedItem\Item\Length > SortedItem()\Item\Length
          SwapElements(SortedItem(), @SortedItem(), *SortedItem)
          ChangeCurrentElement(SortedItem(), *SortedItem)
        Wend
      EndIf
      MaxLength + \Item()\Length - 1
    Next
    
    ; Textkürzung durchführen, bis alle Karte in die maximale Breite passen.
    While MaxLength > \MaxLength And FirstElement(SortedItem())
      *SortedItem = @SortedItem()
      If *SortedItem\Characters > 3 And *SortedItem\Item\Length > \MinTabLength
        *SortedItem\Characters - 1
        *SortedItem\Item\ShortText = Left(*SortedItem\Item\Text, *SortedItem\Characters)+".."
        Length = TabBarGadget_ItemLength(*TabBarGadget, *SortedItem\Item)
        MaxLength - (*SortedItem\Item\Length-Length)
        *SortedItem\Item\Length = Length
        While NextElement(SortedItem()) And *SortedItem\Item\Length < SortedItem()\Item\Length
          SwapElements(SortedItem(), @SortedItem(), *SortedItem)
          ChangeCurrentElement(SortedItem(), *SortedItem)
        Wend
      Else
        DeleteElement(SortedItem())
      EndIf
    Wend
    
  EndWith
  
  ProcedureReturn MaxLength
  
EndProcedure



; Rotiert das Image abhängig von der Leistenausrichtung
Procedure TabBarGadget_RotateImage(*TabBarGadget.TabBarGadget, *Item.TabBarGadgetItem) ; Code OK
  
  Protected LastX.i = ImageWidth(*Item\Image)-1
  Protected LastY.i = ImageHeight(*Item\Image)-1
  Protected Dim Pixel.l(LastX, LastY)
  Protected Y.i, X.i, RotatedImage.i
  
  If *Item\DrawedImage
    FreeImage(*Item\DrawedImage)
  EndIf
  
  If *TabBarGadget\Attributes & #TabBarGadget_Vertical
    If StartDrawing(ImageOutput(*Item\Image))
      DrawingMode(#PB_2DDrawing_AllChannels)
      For Y = 0 To LastY
        For X = 0 To LastX
          Pixel(X, Y) = Point(X, Y)
        Next
      Next
      StopDrawing()
    EndIf
    CompilerIf #PB_Compiler_Version >= 520
      *Item\DrawedImage = CreateImage(#PB_Any, TabBarGadgetInclude\ImageSize, TabBarGadgetInclude\ImageSize, 32, #PB_Image_Transparent)
    CompilerElse
      *Item\DrawedImage = CreateImage(#PB_Any, TabBarGadgetInclude\ImageSize, TabBarGadgetInclude\ImageSize, 32|#PB_Image_Transparent)
    CompilerEndIf
    If StartDrawing(ImageOutput(*Item\DrawedImage))
      DrawingMode(#PB_2DDrawing_AllChannels)
      If *TabBarGadget\Attributes & #TabBarGadget_MirroredTabs
        For Y = 0 To LastY
          For X = 0 To LastX
            Plot(LastY-Y, X, Pixel(X, Y))
          Next
        Next
      Else
        For Y = 0 To LastY
          For X = 0 To LastX
            Plot(Y, LastX-X, Pixel(X, Y))
          Next
        Next
      EndIf
      StopDrawing()
    EndIf
  Else
    *Item\DrawedImage = CopyImage(*Item\Image, #PB_Any)
  EndIf
  
EndProcedure



; (Er-)setz ein neues Icon für die Karte
Procedure TabBarGadget_ReplaceImage(*TabBarGadget.TabBarGadget, *Item.TabBarGadgetItem, NewImageID.i=#Null) ; Code OK
  
  If *Item\Image
    FreeImage(*Item\Image)
    *Item\Image = #Null
  EndIf
  If *Item\DrawedImage
    FreeImage(*Item\DrawedImage)
    *Item\DrawedImage = #Null
  EndIf
  If NewImageID
    CompilerIf #PB_Compiler_Version >= 520
      *Item\Image = CreateImage(#PB_Any, TabBarGadgetInclude\ImageSize, TabBarGadgetInclude\ImageSize, 32, #PB_Image_Transparent)
    CompilerElse
      *Item\Image = CreateImage(#PB_Any, TabBarGadgetInclude\ImageSize, TabBarGadgetInclude\ImageSize, 32|#PB_Image_Transparent)
    CompilerEndIf
    If StartDrawing(ImageOutput(*Item\Image))
      DrawingMode(#PB_2DDrawing_AlphaBlend)
      DrawImage(NewImageID, 0, 0, TabBarGadgetInclude\ImageSize, TabBarGadgetInclude\ImageSize)
      StopDrawing()
    EndIf
    TabBarGadget_RotateImage(*TabBarGadget, *Item)
  EndIf
  
EndProcedure



; Berechnet das Layout einer Karte
Procedure TabBarGadget_ItemLayout(*TabBarGadget.TabBarGadget, *Item.TabBarGadgetItem)
  
  Protected TextAreaLength.i = *Item\Length - 2 * TabBarGadgetInclude\PaddingX
  Protected NextSelected.i, PreviousSelected.i
  
  PushListPosition(*TabBarGadget\Item())
  If *Item\Selected
    ChangeCurrentElement(*TabBarGadget\Item(), *Item)
    If NextElement(*TabBarGadget\Item()) And *TabBarGadget\Item()\Selected
      NextSelected = #True
    EndIf
    ChangeCurrentElement(*TabBarGadget\Item(), *Item)
    If PreviousElement(*TabBarGadget\Item()) And *TabBarGadget\Item()\Selected
      PreviousSelected = #True
    EndIf
  EndIf
  PopListPosition(*TabBarGadget\Item())
  
  With TabBarGadgetInclude
    
    If *Item\Attributes & #TabBarGadget_CloseButton Or (*Item\Attributes & #TabBarGadget_SelectedCloseButton And *Item\Selected)
      TextAreaLength - (TabBarGadgetInclude\CloseButtonSize-4 + TabBarGadgetInclude\ImageSpace)
    EndIf
    If *Item\Attributes & #TabBarGadget_CheckBox
      TextAreaLength - (TabBarGadgetInclude\CheckBoxSize + TabBarGadgetInclude\ImageSpace)
    EndIf
    If *Item\Image
      If *TabBarGadget\Attributes & #TabBarGadget_Vertical
        TextAreaLength - (ImageHeight(*Item\Image)+TabBarGadgetInclude\ImageSpace)
      Else
        TextAreaLength - (ImageWidth(*Item\Image)+TabBarGadgetInclude\ImageSpace)
      EndIf
    EndIf
    
    If *TabBarGadget\Attributes & #TabBarGadget_Vertical
      *Item\Layout\Height = *Item\Length
      *Item\Layout\Width  = *TabBarGadget\TabSize + 1
      If *TabBarGadget\Attributes & #TabBarGadget_MirroredTabs
        *Item\Layout\X      = *TabBarGadget\TabSize * *Item\Row; - 1
      Else
        *Item\Layout\X      = OutputWidth() - *TabBarGadget\TabSize * (*Item\Row+1)
      EndIf
      If *TabBarGadget\Attributes & #TabBarGadget_ReverseOrdering XOr *TabBarGadget\Attributes & #TabBarGadget_MirroredTabs
        *Item\Layout\Y    = *Item\Position
      Else
        *Item\Layout\Y    = OutputHeight() - *Item\Position - *Item\Length
      EndIf
      If *Item\Selected
        *Item\Layout\Width  + \Margin
        If *TabBarGadget\Attributes & #TabBarGadget_MirroredTabs = 0
          *Item\Layout\X    - \Margin
        EndIf
      EndIf
      *Item\Layout\PaddingX = \PaddingY
      *Item\Layout\PaddingY = \PaddingX
      *Item\Layout\CrossX = *Item\Layout\X + (*Item\Layout\Width-\CloseButtonSize)/2
      *Item\Layout\CheckX = *Item\Layout\X + (*Item\Layout\Width-\CheckBoxSize)/2
      If *TabBarGadget\Attributes & #TabBarGadget_MirroredTabs
        *Item\Layout\TextX  = *Item\Layout\X + (*Item\Layout\Width+TextHeight("|"))/2
      Else
        *Item\Layout\TextX  = *Item\Layout\X + (*Item\Layout\Width-TextHeight("|"))/2
      EndIf
      If *TabBarGadget\Attributes & #TabBarGadget_MirroredTabs XOr *TabBarGadget\Attributes & #TabBarGadget_ReverseOrdering
        *Item\Layout\CrossY = *Item\Layout\Y + *Item\Layout\Height - (\CloseButtonSize-3) - *Item\Layout\PaddingY
        *Item\Layout\TextY = *Item\Layout\Y + *Item\Layout\PaddingY + (TextAreaLength-TextWidth(*Item\ShortText)*\VerticalTextBugFix) * (*TabBarGadget\TabTextAlignment+1)/2
        If *Item\Image
          *Item\Layout\ImageX = *Item\Layout\X + (*Item\Layout\Width-ImageWidth(*Item\Image))/2
          *Item\Layout\ImageY = *Item\Layout\Y + *Item\Layout\PaddingY
          *Item\Layout\TextY + ImageHeight(*Item\Image) + \ImageSpace
        EndIf
        If *Item\Attributes & #TabBarGadget_CheckBox
          *Item\Layout\TextY + \CheckBoxSize + \ImageSpace
        EndIf
        *Item\Layout\CheckY = *Item\Layout\TextY-\CheckBoxSize-\ImageSpace ;-hier
        If *TabBarGadget\Attributes & #TabBarGadget_ReverseOrdering : *Item\Layout\TextY + TextWidth(*Item\ShortText)*\VerticalTextBugFix : EndIf
      Else
        *Item\Layout\CrossY = *Item\Layout\Y + (-3) + *Item\Layout\PaddingY
        *Item\Layout\TextY = *Item\Layout\Y + *Item\Layout\Height - *Item\Layout\PaddingY - (TextAreaLength-TextWidth(*Item\ShortText)*\VerticalTextBugFix) * (*TabBarGadget\TabTextAlignment+1)/2
        If *Item\Image
          *Item\Layout\ImageX = *Item\Layout\X + (*Item\Layout\Width-ImageWidth(*Item\Image))/2
          *Item\Layout\ImageY = *Item\Layout\Y + *Item\Layout\Height-ImageHeight(*Item\Image) - *Item\Layout\PaddingY
          *Item\Layout\TextY - ImageHeight(*Item\Image) - \ImageSpace
        EndIf
        If *Item\Attributes & #TabBarGadget_CheckBox
          *Item\Layout\TextY - \CheckBoxSize - \ImageSpace
        EndIf
        *Item\Layout\CheckY = *Item\Layout\TextY+\ImageSpace
        If *TabBarGadget\Attributes & #TabBarGadget_ReverseOrdering : *Item\Layout\TextY - TextWidth(*Item\ShortText)*\VerticalTextBugFix : EndIf
      EndIf
      If *Item\Selected
        If *TabBarGadget\Attributes & #TabBarGadget_MirroredTabs XOr *TabBarGadget\Attributes & #TabBarGadget_ReverseOrdering
          If PreviousSelected = #False
            *Item\Layout\Y - \Margin/2
            *Item\Layout\Height + \Margin/2
          EndIf
          If NextSelected = #False
            *Item\Layout\Height + \Margin/2
          EndIf
        Else
          If NextSelected = #False
            *Item\Layout\Y - \Margin/2
            *Item\Layout\Height + \Margin/2
          EndIf
          If PreviousSelected = #False
            *Item\Layout\Height + \Margin/2
          EndIf
        EndIf
      EndIf
    Else
      *Item\Layout\Width  = *Item\Length
      *Item\Layout\Height = *TabBarGadget\TabSize + 1
      If *TabBarGadget\Attributes & #TabBarGadget_ReverseOrdering
        *Item\Layout\X      = OutputWidth() - *Item\Position - *Item\Length
      Else
        *Item\Layout\X      = *Item\Position
      EndIf
      If *TabBarGadget\Attributes & #TabBarGadget_MirroredTabs
        *Item\Layout\Y      = *TabBarGadget\TabSize * *Item\Row; - 1
      Else
        *Item\Layout\Y      = OutputHeight() - *TabBarGadget\TabSize * (*Item\Row+1)
      EndIf
      If *Item\Selected
        *Item\Layout\Height + \Margin
        If *TabBarGadget\Attributes & #TabBarGadget_MirroredTabs = 0
          *Item\Layout\Y    - \Margin
        EndIf
      EndIf
      *Item\Layout\PaddingX = \PaddingX
      *Item\Layout\PaddingY = \PaddingY
      *Item\Layout\CrossY = *Item\Layout\Y + (*Item\Layout\Height-\CloseButtonSize)/2
      *Item\Layout\CheckY = *Item\Layout\Y + (*Item\Layout\Height-\CheckBoxSize)/2
      *Item\Layout\TextY  = *Item\Layout\Y + (*Item\Layout\Height-TextHeight("|"))/2
      If *TabBarGadget\Attributes & #TabBarGadget_ReverseOrdering
        *Item\Layout\CrossX = *Item\Layout\X + (-3) + *Item\Layout\PaddingX
        *Item\Layout\TextX = *Item\Layout\X + *Item\Layout\Width-TextWidth(*Item\ShortText) - *Item\Layout\PaddingX - (TextAreaLength-TextWidth(*Item\ShortText)) * (*TabBarGadget\TabTextAlignment+1)/2
        If *Item\Image
          *Item\Layout\ImageX = *Item\Layout\X + *Item\Layout\Width-ImageWidth(*Item\Image) - *Item\Layout\PaddingX
          *Item\Layout\ImageY = *Item\Layout\Y + (*Item\Layout\Height-ImageHeight(*Item\Image))/2
          *Item\Layout\TextX - ImageWidth(*Item\Image) - \ImageSpace
        EndIf
        If *Item\Attributes & #TabBarGadget_CheckBox
          *Item\Layout\TextX - \CheckBoxSize - \ImageSpace
        EndIf
        *Item\Layout\CheckX = *Item\Layout\TextX + TextWidth(*Item\ShortText) + \ImageSpace
      Else
        *Item\Layout\CrossX = *Item\Layout\X + *Item\Layout\Width - (\CloseButtonSize-3) - *Item\Layout\PaddingX
        *Item\Layout\TextX = *Item\Layout\X + *Item\Layout\PaddingX + (TextAreaLength-TextWidth(*Item\ShortText)) * (*TabBarGadget\TabTextAlignment+1)/2
        If *Item\Image
          *Item\Layout\ImageX = *Item\Layout\X + *Item\Layout\PaddingX
          *Item\Layout\ImageY = *Item\Layout\Y + (*Item\Layout\Height-ImageHeight(*Item\Image))/2
          *Item\Layout\TextX + ImageWidth(*Item\Image) + \ImageSpace
        EndIf
        If *Item\Attributes & #TabBarGadget_CheckBox
          *Item\Layout\TextX + \CheckBoxSize + \ImageSpace
        EndIf
        *Item\Layout\CheckX = *Item\Layout\TextX - \CheckBoxSize - \ImageSpace
      EndIf
      If *Item\Selected
        If *TabBarGadget\Attributes & #TabBarGadget_ReverseOrdering
          If NextSelected = #False
            *Item\Layout\X - \Margin/2
            *Item\Layout\Width + \Margin/2
          EndIf
          If PreviousSelected = #False
            *Item\Layout\Width + \Margin/2
          EndIf
        Else
          If PreviousSelected = #False
            *Item\Layout\X - \Margin/2
            *Item\Layout\Width + \Margin/2
          EndIf
          If NextSelected = #False
            *Item\Layout\Width + \Margin/2
          EndIf
        EndIf
      EndIf
    EndIf
    
  EndWith
  
EndProcedure



; Berechnet das Layout
Procedure TabBarGadget_Layout(*TabBarGadget.TabBarGadget)
  
  Protected Shift.i
  
  With TabBarGadgetInclude
    
    If *TabBarGadget\Attributes & #TabBarGadget_MirroredTabs
      Shift = -TabBarGadgetInclude\Margin
    Else
      Shift = TabBarGadgetInclude\Margin
    EndIf
    
    If *TabBarGadget\Attributes & #TabBarGadget_Vertical
      *TabBarGadget\Layout\ButtonHeight = \ArrowWidth
      *TabBarGadget\Layout\ButtonWidth  = \ArrowHeight
      *TabBarGadget\Layout\ButtonSize   = \ArrowHeight
      If *TabBarGadget\Attributes & #TabBarGadget_MirroredTabs XOr *TabBarGadget\Attributes & #TabBarGadget_ReverseOrdering
        If *TabBarGadget\Attributes & #TabBarGadget_PopupButton
          *TabBarGadget\Layout\PopupButtonX = (OutputWidth()+Shift) / 2
          *TabBarGadget\Layout\PopupButtonY = OutputHeight() - *TabBarGadget\Layout\ButtonSize / 2
        EndIf
        If *TabBarGadget\Attributes & #TabBarGadget_PreviousArrow
          *TabBarGadget\Layout\PreviousButtonX = (OutputWidth()+Shift) / 2
          *TabBarGadget\Layout\PreviousButtonY = *TabBarGadget\Layout\ButtonHeight / 2
        EndIf
        If *TabBarGadget\Attributes & #TabBarGadget_NextArrow
          *TabBarGadget\Layout\NextButtonX = (OutputWidth()+Shift) / 2
          *TabBarGadget\Layout\NextButtonY = OutputHeight() - *TabBarGadget\Layout\ButtonHeight / 2
          If *TabBarGadget\Attributes & #TabBarGadget_NewTab
            *TabBarGadget\Layout\NextButtonY - *TabBarGadget\NewTabItem\Length-TabBarGadgetInclude\Margin
          EndIf
          If *TabBarGadget\Attributes & #TabBarGadget_PopupButton
            *TabBarGadget\Layout\NextButtonY - *TabBarGadget\Layout\ButtonSize
          EndIf
        EndIf
      Else
        If *TabBarGadget\Attributes & #TabBarGadget_PopupButton
          *TabBarGadget\Layout\PopupButtonX = (OutputWidth()+Shift) / 2
          *TabBarGadget\Layout\PopupButtonY = *TabBarGadget\Layout\ButtonSize / 2
        EndIf
        If *TabBarGadget\Attributes & #TabBarGadget_PreviousArrow
          *TabBarGadget\Layout\PreviousButtonX = (OutputWidth()+Shift) / 2
          *TabBarGadget\Layout\PreviousButtonY = OutputHeight() - *TabBarGadget\Layout\ButtonHeight / 2
        EndIf
        If *TabBarGadget\Attributes & #TabBarGadget_NextArrow
          *TabBarGadget\Layout\NextButtonX = (OutputWidth()+Shift) / 2
          *TabBarGadget\Layout\NextButtonY = *TabBarGadget\Layout\ButtonHeight / 2
          If *TabBarGadget\Attributes & #TabBarGadget_NewTab
            *TabBarGadget\Layout\NextButtonY + *TabBarGadget\NewTabItem\Length+TabBarGadgetInclude\Margin
          EndIf
          If *TabBarGadget\Attributes & #TabBarGadget_PopupButton
            *TabBarGadget\Layout\NextButtonY + *TabBarGadget\Layout\ButtonSize
          EndIf
        EndIf
      EndIf
    Else
      *TabBarGadget\Layout\ButtonHeight = \ArrowHeight
      *TabBarGadget\Layout\ButtonWidth  = \ArrowWidth
      *TabBarGadget\Layout\ButtonSize   = \ArrowHeight
      If *TabBarGadget\Attributes & #TabBarGadget_ReverseOrdering
        If *TabBarGadget\Attributes & #TabBarGadget_PopupButton
          *TabBarGadget\Layout\PopupButtonX = *TabBarGadget\Layout\ButtonSize / 2
          *TabBarGadget\Layout\PopupButtonY = (OutputHeight()+Shift) / 2
        EndIf
        If *TabBarGadget\Attributes & #TabBarGadget_PreviousArrow
          *TabBarGadget\Layout\PreviousButtonX = OutputWidth() - *TabBarGadget\Layout\ButtonWidth / 2
          *TabBarGadget\Layout\PreviousButtonY = (OutputHeight()+Shift) / 2
        EndIf
        If *TabBarGadget\Attributes & #TabBarGadget_NextArrow
          *TabBarGadget\Layout\NextButtonX = *TabBarGadget\Layout\ButtonWidth / 2
          *TabBarGadget\Layout\NextButtonY = (OutputHeight()+Shift) / 2
          If *TabBarGadget\Attributes & #TabBarGadget_NewTab
            *TabBarGadget\Layout\NextButtonX + *TabBarGadget\NewTabItem\Length+TabBarGadgetInclude\Margin
          EndIf
          If *TabBarGadget\Attributes & #TabBarGadget_PopupButton
            *TabBarGadget\Layout\NextButtonX + *TabBarGadget\Layout\ButtonSize
          EndIf
        EndIf
      Else
        If *TabBarGadget\Attributes & #TabBarGadget_PopupButton
          *TabBarGadget\Layout\PopupButtonX = OutputWidth() - *TabBarGadget\Layout\ButtonSize / 2
          *TabBarGadget\Layout\PopupButtonY = (OutputHeight()+Shift) / 2
        EndIf
        If *TabBarGadget\Attributes & #TabBarGadget_PreviousArrow
          *TabBarGadget\Layout\PreviousButtonX = *TabBarGadget\Layout\ButtonWidth / 2
          *TabBarGadget\Layout\PreviousButtonY = (OutputHeight()+Shift) / 2
        EndIf
        If *TabBarGadget\Attributes & #TabBarGadget_NextArrow
          *TabBarGadget\Layout\NextButtonX = OutputWidth() - *TabBarGadget\Layout\ButtonWidth / 2
          *TabBarGadget\Layout\NextButtonY = (OutputHeight()+Shift) / 2
          If *TabBarGadget\Attributes & #TabBarGadget_NewTab
            *TabBarGadget\Layout\NextButtonX - *TabBarGadget\NewTabItem\Length-TabBarGadgetInclude\Margin
          EndIf
          If *TabBarGadget\Attributes & #TabBarGadget_PopupButton
            *TabBarGadget\Layout\NextButtonX - *TabBarGadget\Layout\ButtonSize
          EndIf
        EndIf
      EndIf
      
    EndIf
    
  EndWith
  
EndProcedure



; Zeichnet eine Karte
Procedure TabBarGadget_DrawItem(*TabBarGadget.TabBarGadget, *Item.TabBarGadgetItem)
  
  Protected X.i, Y.i, LayoutX.i, LayoutY.i, LayoutWidth.i, LayoutHeight.i, Padding.i
  Protected Color.i, Width.i, Height.i, Text.s, Len.i, Angle.i
  
  With TabBarGadgetInclude
    
    ; Orientierung der Registerkarte
    If *TabBarGadget\Attributes & #TabBarGadget_Vertical
      If *TabBarGadget\Attributes & #TabBarGadget_MirroredTabs
        LayoutX = -*TabBarGadget\Radius-1
      EndIf
      LayoutWidth = *TabBarGadget\Radius
    Else
      If *TabBarGadget\Attributes & #TabBarGadget_MirroredTabs
        LayoutY = -*TabBarGadget\Radius-1
      EndIf
      LayoutHeight = *TabBarGadget\Radius
    EndIf
    
    ; Aussehen
    ResetGradientColors()
    If *TabBarGadget\Attributes & #TabBarGadget_Vertical
      If *TabBarGadget\Attributes & #TabBarGadget_MirroredTabs
        LinearGradient(*Item\Layout\X+*Item\Layout\Width-1, 0, *Item\Layout\X, 0)
      Else
        LinearGradient(*Item\Layout\X, 0, *Item\Layout\X+*Item\Layout\Width-1, 0)
      EndIf
    Else
      If #False ;*TabBarGadget\Attributes & #TabBarGadget_MirroredTabs
        LinearGradient(0, *Item\Layout\Y+*Item\Layout\Height-1, 0, *Item\Layout\Y)
      Else
        LinearGradient(0, *Item\Layout\Y, 0, *Item\Layout\Y+*Item\Layout\Height-1)
      EndIf
    EndIf
    Select *Item\Face
      Case #TabBarGadgetItem_MoveFace
        Color = TabBarGadget_ColorPlus(*Item\Color\Background, \ActivColorPlus)
        GradientColor(0.0, TabBarGadget_ColorPlus(Color, $FF101010)&$FFFFFF|$C0<<24)
        GradientColor(0.5, Color&$FFFFFF|$C0<<24)
        GradientColor(1.0, TabBarGadget_ColorMinus(Color, $FF101010)&$FFFFFF|$C0<<24)
      Case #TabBarGadgetItem_DisableFace
        GradientColor(0.0, TabBarGadget_ColorPlus(*Item\Color\Background, $FF202020)&$FFFFFF|$80<<24)
        GradientColor(0.5, *Item\Color\Background&$FFFFFF|$80<<24)
        GradientColor(0.6, TabBarGadget_ColorMinus(*Item\Color\Background, $FF101010)&$FFFFFF|$80<<24)
        GradientColor(1.0, TabBarGadget_ColorMinus(*Item\Color\Background, $FF303030)&$FFFFFF|$80<<24)
      Case #TabBarGadgetItem_NormalFace
        GradientColor(0.0, TabBarGadget_ColorPlus(*Item\Color\Background, $FF202020))
        GradientColor(0.5, *Item\Color\Background)
        GradientColor(0.6, TabBarGadget_ColorMinus(*Item\Color\Background, $FF101010))
        GradientColor(1.0, TabBarGadget_ColorMinus(*Item\Color\Background, $FF303030))
      Case #TabBarGadgetItem_HoverFace
        Color = TabBarGadget_ColorPlus(*Item\Color\Background, \HoverColorPlus)
        GradientColor(0.0, TabBarGadget_ColorPlus(Color, $FF202020))
        GradientColor(0.5, Color)
        GradientColor(0.6, TabBarGadget_ColorMinus(Color, $FF101010))
        GradientColor(1.0, TabBarGadget_ColorMinus(Color, $FF303030))
      Case #TabBarGadgetItem_ActiveFace
        Color = TabBarGadget_ColorPlus(*Item\Color\Background, \ActivColorPlus)
        GradientColor(0.0, TabBarGadget_ColorPlus(Color, $FF101010))
        GradientColor(0.5, Color)
        GradientColor(1.0, TabBarGadget_ColorMinus(Color, $FF101010))
    EndSelect
    
    ;     ; andere ausgewählte Nachbarn
    ;     If *Item <> *TabBarGadget\NewTabItem And *Item\Selected
    ;       PushListPosition(*TabBarGadget\Item())
    ;       ChangeCurrentElement(*TabBarGadget\Item(), *Item)
    ;       If NextElement(*TabBarGadget\Item()) And *TabBarGadget\Item()\Selected
    ;         LayoutWidth - \Margin/2
    ;       EndIf
    ;       ChangeCurrentElement(*TabBarGadget\Item(), *Item)
    ;       If PreviousElement(*TabBarGadget\Item()) And *TabBarGadget\Item()\Selected
    ;         LayoutX     + \Margin/2
    ;         LayoutWidth - \Margin/2
    ;       EndIf
    ;       PopListPosition(*TabBarGadget\Item())
    ;     EndIf
    
    ; Registerkarte zeichnen
    DrawingMode(#PB_2DDrawing_Transparent|#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Gradient)
    RoundBox(*Item\Layout\X+LayoutX, *Item\Layout\Y+LayoutY, *Item\Layout\Width+LayoutWidth, *Item\Layout\Height+LayoutHeight, *TabBarGadget\Radius, *TabBarGadget\Radius)
    DrawingMode(#PB_2DDrawing_Transparent|#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
    If *Item\Disabled
      RoundBox(*Item\Layout\X+LayoutX, *Item\Layout\Y+LayoutY, *Item\Layout\Width+LayoutWidth, *Item\Layout\Height+LayoutHeight, *TabBarGadget\Radius, *TabBarGadget\Radius, \BorderColor&$FFFFFF|$80<<24)
    Else
      RoundBox(*Item\Layout\X+LayoutX, *Item\Layout\Y+LayoutY, *Item\Layout\Width+LayoutWidth, *Item\Layout\Height+LayoutHeight, *TabBarGadget\Radius, *TabBarGadget\Radius, \BorderColor)
    EndIf
    DrawingMode(#PB_2DDrawing_Transparent|#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_NativeText)
    
    If *TabBarGadget\Attributes & #TabBarGadget_Vertical
      Angle = 90 + 180*Bool(*TabBarGadget\Attributes&#TabBarGadget_MirroredTabs)
      If *Item\Image
        If *Item\DrawedImage = #Null
          *Item\DrawedImage = TabBarGadget_RotateImage(*Item\Image, Angle)
        EndIf
        If *Item\Disabled
          DrawAlphaImage(ImageID(*Item\DrawedImage), *Item\Layout\ImageX, *Item\Layout\ImageY, $40)
        Else
          DrawAlphaImage(ImageID(*Item\DrawedImage), *Item\Layout\ImageX, *Item\Layout\ImageY, $FF)
        EndIf
      EndIf
      If *Item\Disabled
        DrawRotatedText(*Item\Layout\TextX, *Item\Layout\TextY, *Item\ShortText, Angle, *Item\Color\Text&$FFFFFF|$40<<24)
      Else
        DrawRotatedText(*Item\Layout\TextX, *Item\Layout\TextY, *Item\ShortText, Angle, *Item\Color\Text)
      EndIf
    Else
      If *Item\Image
        If *Item\Disabled
          DrawAlphaImage(ImageID(*Item\Image), *Item\Layout\ImageX, *Item\Layout\ImageY, $40)
        Else
          DrawAlphaImage(ImageID(*Item\Image), *Item\Layout\ImageX, *Item\Layout\ImageY, $FF)
        EndIf
      EndIf
      If *Item\Disabled
        DrawText(*Item\Layout\TextX, *Item\Layout\TextY, *Item\ShortText, *Item\Color\Text&$FFFFFF|$40<<24)
      Else
        TabBarGadget_DrawText(*TabBarGadget, *Item\Layout\TextX, *Item\Layout\TextY, *Item\ShortText, *Item\Color\Text)
        If *TabBarGadget\Editor\Item = *Item
          DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_XOr)
          If *TabBarGadget\Editor\Selection < 0
            LayoutX = TextWidth(Left(*Item\Text, *TabBarGadget\Editor\Cursor+*TabBarGadget\Editor\Selection))-1
            LayoutWidth = TextWidth(Left(*Item\Text, *TabBarGadget\Editor\Cursor)) - LayoutX
            Box(*Item\Layout\TextX+LayoutX, *Item\Layout\TextY, LayoutWidth, TextHeight("|"))
          Else
            LayoutX = TextWidth(Left(*Item\Text, *TabBarGadget\Editor\Cursor))-1
            LayoutWidth = TextWidth(Left(*Item\Text, *TabBarGadget\Editor\Cursor+*TabBarGadget\Editor\Selection)) - LayoutX
            Box(*Item\Layout\TextX+LayoutX, *Item\Layout\TextY, LayoutWidth, TextHeight("|"))
          EndIf
          DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
        EndIf
      EndIf
    EndIf
    
    ; CheckBox
    If *Item\Attributes & #TabBarGadget_CheckBox
      DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
      If *TabBarGadget\HoverItem = *Item And *TabBarGadget\HoverCheck
        RoundBox(*Item\Layout\CheckX, *Item\Layout\CheckY, \CheckBoxSize, \CheckBoxSize, 2, 2, *Item\Color\Text)
      ElseIf *Item\Disabled
        RoundBox(*Item\Layout\CheckX, *Item\Layout\CheckY, \CheckBoxSize, \CheckBoxSize, 2, 2, \BorderColor&$FFFFFF|$40<<24)
      Else
        RoundBox(*Item\Layout\CheckX, *Item\Layout\CheckY, \CheckBoxSize, \CheckBoxSize, 2, 2, \BorderColor)
      EndIf
      If *Item\Checked
        DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Gradient)
        LinearGradient(*Item\Layout\CheckX+2, *Item\Layout\CheckY+2, *Item\Layout\CheckX+\CheckBoxSize-2, *Item\Layout\CheckY+\CheckBoxSize-2)
        ResetGradientColors()
        If *Item\Disabled
          GradientColor(0, *Item\Color\Text&$FFFFFF|$20000000)
          GradientColor(0.5, *Item\Color\Text&$FFFFFF|$30000000)
          GradientColor(1, *Item\Color\Text&$FFFFFF|$20000000)
        Else
          GradientColor(0, *Item\Color\Text&$FFFFFF|$80000000)
          GradientColor(0.5, *Item\Color\Text&$FFFFFF|$C0000000)
          GradientColor(1, *Item\Color\Text&$FFFFFF|$80000000)
        EndIf
        Box(*Item\Layout\CheckX+2, *Item\Layout\CheckY+2, \CheckBoxSize-4, \CheckBoxSize-4)
      EndIf
      DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
    EndIf
    
    ; Schließen-Schaltfläche
    If *Item\Attributes & #TabBarGadget_CloseButton Or (*Item\Attributes & #TabBarGadget_SelectedCloseButton And *Item\Selected)
      If *TabBarGadget\HoverItem = *Item And *TabBarGadget\HoverClose
        If *TabBarGadget\LockedClose And *TabBarGadget\LockedItem = *Item
          TabBarGadget_DrawButton(*Item\Layout\CrossX, *Item\Layout\CrossY, \CloseButtonSize, \CloseButtonSize, -1, *Item\Color\Background, *TabBarGadget\Attributes & #TabBarGadget_Vertical)
        Else
          TabBarGadget_DrawButton(*Item\Layout\CrossX, *Item\Layout\CrossY, \CloseButtonSize, \CloseButtonSize, 1, *Item\Color\Background, *TabBarGadget\Attributes & #TabBarGadget_Vertical)
        EndIf
      EndIf
      If *Item\Disabled
        TabBarGadget_DrawCross(*Item\Layout\CrossX+DesktopScaledX(3), *Item\Layout\CrossY+DesktopScaledY(3), \CloseButtonSize-DesktopScaledX(6), *Item\Color\Text&$FFFFFF|$40<<24)
      Else
        TabBarGadget_DrawCross(*Item\Layout\CrossX+DesktopScaledX(3), *Item\Layout\CrossY+DesktopScaledY(3), \CloseButtonSize-DesktopScaledX(6), *Item\Color\Text)
      EndIf
    EndIf
    
  EndWith
  
EndProcedure



; Verwaltet die Ereignisse beim Editieren einer Karte
Procedure TabBarGadget_Examine_Editor(*TabBarGadget.TabBarGadget)
  
  Protected MinDistance.i, Distance.i, Index.i
  
  With *TabBarGadget
    
    If \Editor\Item
      
      If TabBarGadget_MouseIn(*TabBarGadget, \Editor\Item\Layout\X, \Editor\Item\Layout\Y,  \Editor\Item\Layout\Width, \Editor\Item\Layout\Height)
        SetGadgetAttribute(\Number, #PB_Canvas_Cursor, #PB_Cursor_IBeam)
      Else
        SetGadgetAttribute(\Number, #PB_Canvas_Cursor, #PB_Cursor_Default)
      EndIf
      
      Select EventType()
        Case #PB_EventType_LeftDoubleClick
          If \Editor\Item = \HoverItem
            \Editor\Cursor = 0
            \Editor\Selection = Len(\Editor\Item\Text)
            \Editor\Selectable = #False
          EndIf
        Case #PB_EventType_LeftButtonDown
          If \Editor\Item = \HoverItem
            \Editor\Cursor = 0
            \Editor\Selection = 0
            \Editor\Selectable = #True
            MinDistance = $FFFF
            For Index = Len(\Editor\Item\Text) To 0 Step -1
              Distance = Abs(\Editor\Item\Layout\TextX+TextWidth(Left(\Editor\Item\Text, Index))-\MouseX)
              If Distance < MinDistance
                \Editor\Cursor = Index
                MinDistance = Distance
              EndIf
            Next
          Else
            If \Editor\OldText <> \Editor\Item\Text
              ChangeCurrentElement(\Item(), \Editor\Item)
              PostEvent(#PB_Event_Gadget, \Window, \Number, #TabBarGadget_EventType_EditItem, ListIndex(\Item()))
            EndIf
            \Editor\Item = #Null
            ProcedureReturn #Null
          EndIf
        Case #PB_EventType_MouseMove
          If \Editor\Item = \HoverItem And \Editor\Selectable
            \Editor\Selection = 0
            MinDistance = $FFFF
            For Index = Len(\Editor\Item\Text) To 0 Step -1
              Distance = Abs(\Editor\Item\Layout\TextX+TextWidth(Left(\Editor\Item\Text, Index))-\MouseX)
              If Distance < MinDistance
                \Editor\Selection = Index-\Editor\Cursor
                MinDistance = Distance
              EndIf
            Next
          EndIf
        Case #PB_EventType_LeftButtonUp
          \Editor\Selectable = #False
        Case #PB_EventType_Input
          If \Editor\Selection > 0
            \Editor\Item\Text = Left(\Editor\Item\Text, \Editor\Cursor) + Mid(\Editor\Item\Text, \Editor\Cursor+\Editor\Selection+1)
            \Editor\Selection = 0
          ElseIf \Editor\Selection < 0
            \Editor\Item\Text = Left(\Editor\Item\Text, \Editor\Cursor+\Editor\Selection) + Mid(\Editor\Item\Text, \Editor\Cursor+1)
            \Editor\Cursor + \Editor\Selection
            \Editor\Selection = 0
          EndIf
          \Editor\Item\Text = Left(\Editor\Item\Text, \Editor\Cursor) + Chr(GetGadgetAttribute(\Number, #PB_Canvas_Input)) + Mid(\Editor\Item\Text, \Editor\Cursor+1)
          \Editor\Item\ShortText = \Editor\Item\Text
          \Editor\Cursor + 1
        Case #PB_EventType_KeyDown
          Select GetGadgetAttribute(\Number, #PB_Canvas_Key)
            Case #PB_Shortcut_Return
              If \Editor\OldText <> \Editor\Item\Text
                ChangeCurrentElement(\Item(), \Editor\Item)
                PostEvent(#PB_Event_Gadget, \Window, \Number, #TabBarGadget_EventType_EditItem, ListIndex(\Item()))
              EndIf
              \Editor\Item = #Null
              ProcedureReturn #Null
            Case #PB_Shortcut_Escape
              \Editor\Item\Text = \Editor\OldText
              \Editor\Item\ShortText = \Editor\Item\Text
              \Editor\Item = #Null
              ProcedureReturn #Null
            Case #PB_Shortcut_Left
              If GetGadgetAttribute(\Number, #PB_Canvas_Modifiers) & #PB_Canvas_Shift
                If \Editor\Cursor+\Editor\Selection > 0
                  \Editor\Selection - 1
                EndIf
              Else
                \Editor\Selection = 0
                If \Editor\Cursor > 0
                  \Editor\Cursor - 1
                EndIf
              EndIf
            Case #PB_Shortcut_Right
              If GetGadgetAttribute(\Number, #PB_Canvas_Modifiers) & #PB_Canvas_Shift
                If \Editor\Cursor+\Editor\Selection < Len(\Editor\Item\Text)
                  \Editor\Selection + 1
                EndIf
              Else
                \Editor\Selection = 0
                If \Editor\Cursor < Len(\Editor\Item\Text)
                  \Editor\Cursor + 1
                EndIf
              EndIf
            Case #PB_Shortcut_Home
              \Editor\Cursor = 0
            Case #PB_Shortcut_End
              \Editor\Cursor = Len(\Editor\Item\Text)
            Case #PB_Shortcut_Back
              If \Editor\Selection > 0
                \Editor\Item\Text = Left(\Editor\Item\Text, \Editor\Cursor) + Mid(\Editor\Item\Text, \Editor\Cursor+\Editor\Selection+1)
                \Editor\Selection = 0
              ElseIf \Editor\Selection < 0
                \Editor\Item\Text = Left(\Editor\Item\Text, \Editor\Cursor+\Editor\Selection) + Mid(\Editor\Item\Text, \Editor\Cursor+1)
                \Editor\Cursor + \Editor\Selection
                \Editor\Selection = 0
              ElseIf \Editor\Cursor > 0
                \Editor\Item\Text = Left(\Editor\Item\Text, \Editor\Cursor-1) + Mid(\Editor\Item\Text, \Editor\Cursor+1)
                \Editor\Cursor - 1
              EndIf
            Case #PB_Shortcut_Delete
              If \Editor\Selection > 0
                \Editor\Item\Text = Left(\Editor\Item\Text, \Editor\Cursor) + Mid(\Editor\Item\Text, \Editor\Cursor+\Editor\Selection+1)
                \Editor\Selection = 0
              ElseIf \Editor\Selection < 0
                \Editor\Item\Text = Left(\Editor\Item\Text, \Editor\Cursor+\Editor\Selection) + Mid(\Editor\Item\Text, \Editor\Cursor+1)
                \Editor\Cursor + \Editor\Selection
                \Editor\Selection = 0
              ElseIf \Editor\Cursor < Len(\Editor\Item\Text)
                \Editor\Item\Text = Left(\Editor\Item\Text, \Editor\Cursor) + Mid(\Editor\Item\Text, \Editor\Cursor+2)
              EndIf
            Case #PB_Shortcut_C
              If GetGadgetAttribute(\Number, #PB_Canvas_Modifiers) & #PB_Canvas_Control
                If \Editor\Selection > 0
                  SetClipboardText(Mid(\Editor\Item\Text, \Editor\Cursor+1, \Editor\Selection))
                ElseIf \Editor\Selection < 0
                  SetClipboardText(Mid(\Editor\Item\Text, \Editor\Cursor+\Editor\Selection+1, -\Editor\Selection))
                EndIf
              EndIf
            Case #PB_Shortcut_V
              If GetGadgetAttribute(\Number, #PB_Canvas_Modifiers) & #PB_Canvas_Control
                If \Editor\Selection > 0
                  \Editor\Item\Text = Left(\Editor\Item\Text, \Editor\Cursor) + Mid(\Editor\Item\Text, \Editor\Cursor+\Editor\Selection+1)
                  \Editor\Selection = 0
                ElseIf \Editor\Selection < 0
                  \Editor\Item\Text = Left(\Editor\Item\Text, \Editor\Cursor+\Editor\Selection) + Mid(\Editor\Item\Text, \Editor\Cursor+1)
                  \Editor\Cursor + \Editor\Selection
                  \Editor\Selection = 0
                EndIf
                \Editor\Item\Text = Left(\Editor\Item\Text, \Editor\Cursor) + GetClipboardText() + Mid(\Editor\Item\Text, \Editor\Cursor+1)
                \Editor\Item\ShortText = \Editor\Item\Text
                \Editor\Cursor + Len(GetClipboardText())
              EndIf
          EndSelect
          \Editor\Item\ShortText = \Editor\Item\Text
        Case #PB_EventType_LostFocus
          If \Editor\OldText <> \Editor\Item\Text
            ChangeCurrentElement(\Item(), \Editor\Item)
            PostEvent(#PB_Event_Gadget, \Window, \Number, #TabBarGadget_EventType_EditItem, ListIndex(\Item()))
          EndIf
          \Editor\Item = #Null
      EndSelect
      
    Else
      
      SetGadgetAttribute(\Number, #PB_Canvas_Cursor, #PB_Cursor_Default)
      
    EndIf
    
  EndWith
  
EndProcedure



; Ermittelt das Aussehen und die Lage der Tabs
Procedure TabBarGadget_Examine(*TabBarGadget.TabBarGadget)
  
  Protected MinLength.i, X.i, Y.i, Shift.i, MousePosition.i, Row.i
  Protected Index.i, Distance.i, MinDistance.i
  
  With *TabBarGadget
    
    ; Initialisierung
    \ToolTip\Current = #Null
    \MouseX      = GetGadgetAttribute(\Number, #PB_Canvas_MouseX)
    \MouseY      = GetGadgetAttribute(\Number, #PB_Canvas_MouseY)
    \Event       = #Null
    \EventTab    = #TabBarGadgetItem_None
    \HoverItem   = #Null
    \HoverClose  = #False
    \HoverCheck  = #False
    \HoverArrow  = #Null
    DrawingFont(\FontID)
    
    ; Hover bei Registerkarten
    If \MoveItem = #Null
      
      ForEach \Item()
        If \Item()\Visible And TabBarGadget_MouseIn(*TabBarGadget, \Item()\Layout\X, \Item()\Layout\Y,  \Item()\Layout\Width-1, \Item()\Layout\Height-1)
          \HoverItem = \Item()
        EndIf
      Next
      If \Attributes & #TabBarGadget_NewTab And TabBarGadget_MouseIn(*TabBarGadget, \NewTabItem\Layout\X, \NewTabItem\Layout\Y, \NewTabItem\Layout\Width-1, \NewTabItem\Layout\Height-1)
        \HoverItem = \NewTabItem
      EndIf
      
    EndIf
    
    ; Navigation
    If \Attributes & (#TabBarGadget_PreviousArrow|#TabBarGadget_NextArrow)
      
      ; MouseWheel Scroll Action
      If EventType() = #PB_EventType_MouseWheel
        If TabBarGadgetInclude\WheelAction = #TabBarGadgetWheelAction_Scroll
          \Shift + TabBarGadgetInclude\WheelDirection * GetGadgetAttribute(\Number, #PB_Canvas_WheelDelta)
          If \Shift < 0
            \Shift = 0
          ElseIf \Shift > \LastShift
            \Shift = \LastShift
          EndIf
        EndIf
      EndIf
      
      LockMutex(TabBarGadgetInclude\Timer\Mutex)
      TabBarGadgetInclude\Timer\Type = #Null
      If \Attributes & #TabBarGadget_PreviousArrow
        If TabBarGadget_MouseIn(*TabBarGadget, \Layout\PreviousButtonX-\Layout\ButtonWidth/2, \Layout\PreviousButtonY-\Layout\ButtonHeight/2, \Layout\ButtonWidth, \Layout\ButtonHeight)
          \HoverArrow = #TabBarGadget_PreviousArrow
          \HoverItem = #Null
          TabBarGadgetInclude\Timer\Type = #TabBarGadget_PreviousArrow
          Select EventType()
            Case #PB_EventType_LeftButtonDown
              \LockedArrow = #TabBarGadget_PreviousArrow
              TabBarGadgetInclude\Timer\TabBarGadget = *TabBarGadget
            Case #PB_EventType_LeftButtonUp
              If \LockedArrow = \HoverArrow And \Shift > 0
                \Shift - 1
              EndIf
          EndSelect
        EndIf
      EndIf
      If \Attributes & #TabBarGadget_NextArrow
        If TabBarGadget_MouseIn(*TabBarGadget, \Layout\NextButtonX-\Layout\ButtonWidth/2, \Layout\NextButtonY-\Layout\ButtonHeight/2, \Layout\ButtonWidth, \Layout\ButtonHeight)
          \HoverArrow = #TabBarGadget_NextArrow
          \HoverItem = #Null
          TabBarGadgetInclude\Timer\Type = #TabBarGadget_NextArrow
          Select EventType()
            Case #PB_EventType_LeftButtonDown
              \LockedArrow = #TabBarGadget_NextArrow
              TabBarGadgetInclude\Timer\TabBarGadget = *TabBarGadget
            Case #PB_EventType_LeftButtonUp
              If \LockedArrow = \HoverArrow And \Shift < \LastShift
                \Shift + 1
              EndIf
          EndSelect
        EndIf
      EndIf
      UnlockMutex(TabBarGadgetInclude\Timer\Mutex)
      
    EndIf
    
    ; MouseWheel Change Action
    If EventType() = #PB_EventType_MouseWheel
      If TabBarGadgetInclude\WheelAction = #TabBarGadgetWheelAction_Change
        If TabBarGadget_ItemID(*TabBarGadget, #TabBarGadgetItem_Selected)
          Index = ListIndex(\Item()) + TabBarGadgetInclude\WheelDirection * Sign(GetGadgetAttribute(\Number, #PB_Canvas_WheelDelta))
          If (Index >= 0) And (Index < ListSize(\Item()))
            TabBarGadget_SelectItem(*TabBarGadget, TabBarGadget_ItemID(*TabBarGadget, Index))
            \EventTab = Index
            PostEvent(#PB_Event_Gadget, \Window, \Number, #TabBarGadget_EventType_Change, \EventTab)
          EndIf
        EndIf
      EndIf
    EndIf
    
    ; Popup-Button
    If \Attributes & #TabBarGadget_PopupButton
      If TabBarGadget_MouseIn(*TabBarGadget, \Layout\PopupButtonX-\Layout\ButtonSize/2, \Layout\PopupButtonY-\Layout\ButtonSize/2, \Layout\ButtonSize, \Layout\ButtonSize)
        \HoverArrow = #TabBarGadget_PopupButton
        \HoverItem = #Null
        Select EventType()
          Case #PB_EventType_LeftButtonDown
            \LockedArrow = #TabBarGadget_PopupButton
          Case #PB_EventType_LeftButtonUp
            If \LockedArrow = \HoverArrow
              PostEvent(#PB_Event_Gadget, \Window, \Number, #TabBarGadget_EventType_PopupButton, -1)
            EndIf
        EndSelect
      EndIf
    EndIf
    
    ; Registerkarten
    If \HoverItem
      
      ; Tooltip aktualisieren & Schließenbutton & Checkbox
      If \HoverItem\ToolTip
        \ToolTip\Current = @\HoverItem\ToolTip
      Else
        \ToolTip\Current = @\HoverItem\Text
      EndIf
      If ( \HoverItem\Attributes & #TabBarGadget_CloseButton Or (\HoverItem\Attributes & #TabBarGadget_SelectedCloseButton And \HoverItem\Selected) ) And \Editor\Item <> \HoverItem
        If TabBarGadget_MouseIn(*TabBarGadget, \HoverItem\Layout\CrossX, \HoverItem\Layout\CrossY, TabBarGadgetInclude\CloseButtonSize, TabBarGadgetInclude\CloseButtonSize)
          \HoverClose = \HoverItem
          \ToolTip\Current = @\ToolTip\CloseText
          Select EventType()
            Case #PB_EventType_LeftButtonDown
              \LockedClose = \HoverItem
            Case #PB_EventType_LeftButtonUp
              If \LockedClose = \HoverClose
                ChangeCurrentElement(\Item(), \LockedClose)
                \EventTab = ListIndex(\Item())
                PostEvent(#PB_Event_Gadget, \Window, \Number, #TabBarGadget_EventType_CloseItem, \EventTab)
              EndIf
          EndSelect
        EndIf
      EndIf
      If \HoverItem\Attributes & #TabBarGadget_CheckBox And \HoverItem\Disabled = #False And \Editor\Item <> \HoverItem
        If TabBarGadget_MouseIn(*TabBarGadget, \HoverItem\Layout\CheckX, \HoverItem\Layout\CheckY, TabBarGadgetInclude\CheckBoxSize, TabBarGadgetInclude\CheckBoxSize)
          \HoverCheck = \HoverItem
          Select EventType()
            Case #PB_EventType_LeftButtonDown
              \LockedCheck = \HoverItem
            Case #PB_EventType_LeftButtonUp
              If \LockedCheck = \HoverCheck
                ChangeCurrentElement(\Item(), \LockedCheck)
                \EventTab = ListIndex(\Item())
                PostEvent(#PB_Event_Gadget, \Window, \Number, #TabBarGadget_EventType_CheckBox, \EventTab)
                \HoverItem\Checked = 1 - \HoverItem\Checked
              EndIf
          EndSelect
        EndIf
      EndIf
      
      ; Ereignisverwaltung
      If \HoverItem = \NewTabItem
        \EventTab = #TabBarGadgetItem_NewTab
        \ToolTip\Current = @\ToolTip\NewText
      Else
        ChangeCurrentElement(\Item(), \HoverItem)
        \EventTab = ListIndex(\Item())
      EndIf
      Select EventType()
        Case #PB_EventType_LeftButtonDown
          \LockedItem = \HoverItem
          If \LockedItem = \NewTabItem
            PostEvent(#PB_Event_Gadget, \Window, \Number, #TabBarGadget_EventType_NewItem, \EventTab)
          ElseIf \LockedClose = #False And \LockedCheck = #False
            If \HoverItem\Disabled = #False
              If \Attributes & #TabBarGadget_MultiSelect And GetGadgetAttribute(\Number, #PB_Canvas_Modifiers) & #PB_Canvas_Control
                If \HoverItem\Selected
                  TabBarGadget_UnselectItem(*TabBarGadget, \HoverItem)
                Else
                  TabBarGadget_SelectItem(*TabBarGadget, \HoverItem)
                EndIf
                PostEvent(#PB_Event_Gadget, \Window, \Number, #TabBarGadget_EventType_Change, \EventTab)
              Else
                ForEach \Item()
                  \Item()\Selected = #False
                Next
                If \SelectedItem <> \HoverItem
                  PostEvent(#PB_Event_Gadget, \Window, \Number, #TabBarGadget_EventType_Change, \EventTab)
                EndIf
                TabBarGadget_SelectItem(*TabBarGadget, \HoverItem)
              EndIf
            EndIf
            If Not \Attributes & #TabBarGadget_NoTabMoving And \Editor\Item = #Null
              \ReadyToMoveItem = \HoverItem
              \SaveMouseX = \MouseX
              \SaveMouseY = \MouseY
            EndIf
          EndIf
        Case #PB_EventType_MiddleButtonDown
          \LockedItem = \HoverItem
        Case #PB_EventType_MiddleButtonUp
          If TabBarGadgetInclude\EnableMiddleClickForCloseTab And \LockedItem = \HoverItem And \LockedItem <> \NewTabItem And \LockedItem <> \Editor\Item
            PostEvent(#PB_Event_Gadget, \Window, \Number, #TabBarGadget_EventType_CloseItem, \EventTab)
            \MoveItem        = #Null
            \ReadyToMoveItem = #Null
          EndIf
          \LockedItem = #Null
        Case #PB_EventType_MouseMove
          If \ReadyToMoveItem
            If Abs(\SaveMouseX-\MouseX) > 4 Or Abs(\SaveMouseY-\MouseY) > 4
              \MoveItem = \ReadyToMoveItem
              If \Attributes & (#TabBarGadget_NextArrow|#TabBarGadget_PreviousArrow)
                LockMutex(TabBarGadgetInclude\Timer\Mutex)
                TabBarGadgetInclude\Timer\TabBarGadget = *TabBarGadget
                UnlockMutex(TabBarGadgetInclude\Timer\Mutex)
              EndIf
            EndIf
          EndIf
        Case #PB_EventType_LeftDoubleClick
          If \Attributes & #TabBarGadget_Editable And \HoverItem\Disabled = #False
            \Editor\Item    = \HoverItem
            \Editor\OldText = \Editor\Item\Text
          EndIf
      EndSelect
      
    EndIf
    
    ; Editor
    TabBarGadget_Examine_Editor(*TabBarGadget)
    
    ; Sonstiges
    Select EventType()
      Case #PB_EventType_LeftButtonUp
        \LockedClose     = #False
        \LockedCheck     = #False
        \MoveItem        = #Null
        \ReadyToMoveItem = #Null
        \LockedArrow     = #Null
        LockMutex(TabBarGadgetInclude\Timer\Mutex)
        TabBarGadgetInclude\Timer\TabBarGadget = #Null
        UnlockMutex(TabBarGadgetInclude\Timer\Mutex)
      Case #PB_EventType_MouseLeave
        \HoverItem       = #Null
      Case #PB_EventType_LeftDoubleClick
        If TabBarGadgetInclude\EnableDoubleClickForNewTab And \HoverArrow = #Null And \HoverItem = #Null
          PostEvent(#PB_Event_Gadget, \Window, \Number, #TabBarGadget_EventType_NewItem, \EventTab)
        EndIf
    EndSelect
    If (\Shift <= 0 And \HoverArrow = #TabBarGadget_PreviousArrow) Or (\Shift >= \LastShift And \HoverArrow = #TabBarGadget_NextArrow)
      \HoverArrow = #False
    EndIf
    
    ; Registerkartenverschiebung: Verschiebungspartner suchen und tauschen
    If \MoveItem
      \EventTab = \MoveItem
      If \Attributes & #TabBarGadget_Vertical
        If \Attributes & #TabBarGadget_MultiLine
          If \Attributes & #TabBarGadget_MirroredTabs
            Row = Int((\MouseX-TabBarGadgetInclude\Margin)/\TabSize)
          Else
            Row = Int(\Rows-(\MouseX-TabBarGadgetInclude\Margin)/\TabSize)
          EndIf
          If Row < 0 : Row = 0 : ElseIf Row >= \Rows : Row = \Rows-1 : EndIf
          MousePosition = Row*\MaxLength + \MouseY
        Else
          MousePosition = \MouseY
        EndIf
        If Not (\Attributes & #TabBarGadget_MirroredTabs XOr \Attributes & #TabBarGadget_ReverseOrdering)
          MousePosition = OutputHeight() - MousePosition
        EndIf
      Else
        If \Attributes & #TabBarGadget_MultiLine
          If \Attributes & #TabBarGadget_MirroredTabs
            Row = Int((\MouseY-TabBarGadgetInclude\Margin)/\TabSize)
          Else
            Row = Int(\Rows-(\MouseY-TabBarGadgetInclude\Margin)/\TabSize)
          EndIf
          If Row < 0 : Row = 0 : ElseIf Row >= \Rows : Row = \Rows-1 : EndIf
          MousePosition = Row*\MaxLength + \MouseX
        Else
          MousePosition = \MouseX
        EndIf
        If \Attributes & #TabBarGadget_ReverseOrdering
          MousePosition = OutputWidth() - MousePosition
        EndIf
      EndIf
      If Not \Event
        ChangeCurrentElement(\Item(), \MoveItem)
        While NextElement(\Item())
          If MousePosition > \Item()\Position + \MaxLength*\Item()\Row
            SwapElements(\Item(), @\Item(), \MoveItem)
            \Item()\Position = \MoveItem\Position
            \MoveItem\Position = \Item()\Position + \Item()\Length
            \Event = #TabBarGadget_EventType_SwapItem
            PushListPosition(\Item())
            ChangeCurrentElement(\Item(), \MoveItem)
            \EventTab = ListIndex(\Item())
            PopListPosition(\Item())
          EndIf
        Wend
      EndIf
      If Not \Event
        ChangeCurrentElement(\Item(), \MoveItem)
        While PreviousElement(\Item()) And ListIndex(\Item()) >= \Shift-1
          If \MoveItem\Length < \Item()\Length
            MinLength = \MoveItem\Length
          Else
            MinLength = \Item()\Length
          EndIf
          If MousePosition < \Item()\Position + \MaxLength*\Item()\Row + MinLength
            SwapElements(\Item(), @\Item(), \MoveItem)
            \MoveItem\Position = \Item()\Position
            \Item()\Position = \MoveItem\Position + \MoveItem\Length
            \Event = #TabBarGadget_EventType_SwapItem
            PushListPosition(\Item())
            ChangeCurrentElement(\Item(), \MoveItem)
            \EventTab = ListIndex(\Item())
            PopListPosition(\Item())
          EndIf
        Wend
      EndIf
      If \Event = #TabBarGadget_EventType_SwapItem
        PostEvent(#PB_Event_Gadget, \Window, \Number, #TabBarGadget_EventType_SwapItem, \EventTab)
      EndIf
    EndIf
    
    ; ToolTip aktualisieren
    If \ToolTip\Current <> \ToolTip\Old
      If \ToolTip\Current = #Null
        GadgetToolTip(\Number, "")
      ElseIf \ToolTip\Current = @\ToolTip\NewText Or \ToolTip\Current =  @\ToolTip\CloseText
        GadgetToolTip(\Number, PeekS(\ToolTip\Current))
      ElseIf \HoverItem And \ToolTip\Current = @\HoverItem\ToolTip
        GadgetToolTip(\Number, PeekS(\ToolTip\Current))
      Else
        GadgetToolTip(\Number, ReplaceString(\ToolTip\ItemText, "%ITEM", PeekS(\ToolTip\Current)))
      EndIf
      \ToolTip\Old = \ToolTip\Current
    EndIf
    
  EndWith
  
EndProcedure



; Ermittelt das Aussehen und die Lage der Tabs
Procedure TabBarGadget_Update(*TabBarGadget.TabBarGadget)
  
  Protected FocusingSelectedTab.i
  Protected ShowLength.i, X.i
  Protected OldAttributes.i
  Protected Difference.f, Factor.f, Position.i, Length.i, MaxWidth.i, MousePosition.i
  Protected *Item.TabBarGadgetItem, Row.i, Rows.i=1
  Protected *Current, *Last, AddLength.i, RowCount.i
  Protected Dim Row.TabBarGadgetRow(0)
  
  With *TabBarGadget
    
    ; Vorbereitung
    DrawingFont(\FontID)
    \Attributes & ~(#TabBarGadget_PreviousArrow|#TabBarGadget_NextArrow) ; erstmal keine Navigation
    If \TabSize = 0
      If \Attributes & #TabBarGadget_Vertical
        If GadgetWidth(\Number) > 1
          \TabSize = OutputWidth() - TabBarGadgetInclude\Margin
        Else
          \TabSize = TextHeight("|") + TabBarGadgetInclude\PaddingY*2
        EndIf
      Else
        If GadgetHeight(\Number) > 1
          \TabSize = OutputHeight() - TabBarGadgetInclude\Margin
        Else
          \TabSize = TextHeight("|") + TabBarGadgetInclude\PaddingY*2
        EndIf
      EndIf
    EndIf
    If \Attributes & #TabBarGadget_NewTab
      \NewTabItem\Length = TabBarGadget_ItemLength(*TabBarGadget, \NewTabItem)
      \NewTabItem\Row = 0
    EndIf
    
    ; Mehrzeilige Registerkartenleiste
    If \Attributes & #TabBarGadget_MultiLine
      
      \MaxLength = TabBarGadget_MaxLength(*TabBarGadget)
      \Length    = \MaxLength
      \Shift     = 0
      
      ; Breiten ermitteln
      Length = 1
      ForEach \Item()
        \Item()\Row = 0
        \Item()\Length  = TabBarGadget_ItemLength(*TabBarGadget, \Item())
        \Item()\Visible = #True
        Length - 1 + \Item()\Length
      Next
      
      ; Mehrere Zeilen einrichten
      If Length > \MaxLength
        Row = 0
        Row(Row)\Length = 1
        ForEach \Item()
          If NextElement(\Item())
            PreviousElement(\Item())
            MaxWidth = TabBarGadget_MaxLength(*TabBarGadget, #False)
          Else
            LastElement(\Item())
            MaxWidth = TabBarGadget_MaxLength(*TabBarGadget)
          EndIf
          If Row(Row)\Length-1+\Item()\Length > MaxWidth And Row(Row)\Items > 0
            Row + 1
            ReDim Row(Row)
            Row(Row)\Length = 1
          EndIf
          Row(Row)\Length - 1 + \Item()\Length
          Row(Row)\Items + 1
          \Item()\Row = Row
        Next
      Else
        Row(Row)\Length = Length
      EndIf
      Rows = Row+1
      
      ; Verbreitern
      If Rows > 1
        MaxWidth = TabBarGadget_MaxLength(*TabBarGadget, #False)
        ForEach \Item()
          AddLength = (MaxWidth-Row(\Item()\Row)\Length)/Row(\Item()\Row)\Items
          If \Item()\Row <> Rows-1 Or AddLength < 0
            \Item()\Length + AddLength
            Row(\Item()\Row)\Length + AddLength
            Row(\Item()\Row)\Items - 1
          EndIf
        Next
      EndIf
      
      ; Positionen errechnen
      Length = TabBarGadgetInclude\Margin
      Row = 0
      ForEach \Item()
        If Row <> \Item()\Row
          Row + 1
          Length = TabBarGadgetInclude\Margin
        EndIf
        \Item()\Position = Length
        Length + \Item()\Length - 1
      Next
      If Row(Rows-1)\Length > TabBarGadget_MaxLength(*TabBarGadget) And LastElement(\Item())
        \Item()\Length = TabBarGadget_MaxLength(*TabBarGadget, #False)
        Rows + 1
        \NewTabItem\Row = Rows-1
        \NewTabItem\Position = TabBarGadgetInclude\Margin
      Else
        \NewTabItem\Row = Rows-1
        \NewTabItem\Position = TabBarGadgetInclude\Margin+Row(\NewTabItem\Row)\Length - 1
      EndIf
      
      ; Einzeilige Registerkartenleiste
    Else
      
      \MaxLength = TabBarGadget_MaxLength(*TabBarGadget)
      
      ; ggf. Textkürzung
      If \Attributes & #TabBarGadget_TextCutting
        \Length = TabBarGadget_TextCutting(*TabBarGadget)
        If \Length <= \MaxLength
          \Shift = 0
        EndIf
      EndIf
      
      ; Breiten ermitteln
      \Length = 1
      ForEach \Item()
        \Item()\Length = TabBarGadget_ItemLength(*TabBarGadget, \Item())
        \Item()\Row    = 0
        \Length + \Item()\Length-1
      Next
      
      ; Navigation nötig ?
      If \Length > \MaxLength
        \Attributes | (#TabBarGadget_PreviousArrow | #TabBarGadget_NextArrow)
        \MaxLength = TabBarGadget_MaxLength(*TabBarGadget)
      Else
        ;\Shift = 0
      EndIf
      
      ; LastShift ermitteln
      If LastElement(\Item())
        \LastShift = ListIndex(\Item())
        ShowLength = \Item()\Length
        While PreviousElement(\Item())
          If ShowLength + \Item()\Length - 1 > \MaxLength - Bool(ListIndex(\Item())>0)*TabBarGadgetInclude\FadeOut
            Break
          Else
            ShowLength + \Item()\Length - 1
            \LastShift - 1
          EndIf
        Wend
      Else
        \LastShift = 0
      EndIf
      
      ; ggf. aktuell ausgewählte Registerkarte in den sichtbaren Bereich bringen
      If \FocusingSelectedTab And \SelectedItem
        ChangeCurrentElement(\Item(), \SelectedItem)
        If ListIndex(\Item()) <= \Shift
          \Shift = ListIndex(\Item())
        Else
          While \Shift < \LastShift And SelectElement(\Item(), \Shift)
            ShowLength = \Item()\Length
            If \Item() = \SelectedItem
              Break
            EndIf
            While NextElement(\Item())
              If ShowLength + \Item()\Length - 1 > \MaxLength - (Bool(\Shift>0)+Bool(\Shift<\LastShift))*TabBarGadgetInclude\FadeOut
                \Shift + 1
                Break
              ElseIf \Item() = \SelectedItem
                Break 2
              EndIf
              ShowLength + \Item()\Length - 1
            Wend
          Wend
        EndIf
        \FocusingSelectedTab = #False
      EndIf
      
      If \Shift > \LastShift
        \Shift = \LastShift
      EndIf
      \MaxLength - (Bool(\Shift>0)+Bool(\Shift<\LastShift))*TabBarGadgetInclude\FadeOut
      
      ; Position der Tabs
      
      ; vorherige Registerkarte
      If \Attributes & #TabBarGadget_PreviousArrow
        If \Shift > 0
          ForEach \Item()
            \Item()\Position = -$FFFF
            \Item()\Visible  = #False
            If ListIndex(\Item()) >= \Shift-1 : Break : EndIf
          Next
          Position = TabBarGadgetInclude\ArrowWidth + TabBarGadgetInclude\Margin + TabBarGadgetInclude\FadeOut
          SelectElement(\Item(), \Shift-1)
          \Item()\Position = Position - \Item()\Length + 1
          \Item()\Visible  = #True
        Else
          Position = TabBarGadgetInclude\ArrowWidth + TabBarGadgetInclude\Margin
        EndIf
      Else
        Position = TabBarGadgetInclude\Margin
      EndIf
      
      ; sichtbare Registerkarten
      \Length = 0
      If SelectElement(\Item(), \Shift)
        Repeat
          \Item()\Position = Position + \Length
          \Item()\Visible  = #True
          If \Length + \Item()\Length - 1 > \MaxLength
            Break
          EndIf
          \Length + \Item()\Length - 1
        Until Not NextElement(\Item())
      EndIf
      
      ; nächste Registerkarte
      If \Attributes & #TabBarGadget_NextArrow And ListIndex(\Item()) <> -1
        If ListIndex(\Item()) <> ListSize(\Item())-1
          \Item()\Position = Position + \Length
          \Length + \Item()\Length - 1
          \Item()\Visible  = #True
          If NextElement(\Item())
            \Item()\Position = Position + \Length
            \Item()\Visible  = #True
          EndIf
        EndIf
        If \Attributes & #TabBarGadget_NewTab
          If \Attributes & #TabBarGadget_Vertical
            \NewTabItem\Position = OutputHeight()-\NewTabItem\Length-TabBarGadgetInclude\Margin/2
          Else
            \NewTabItem\Position = OutputWidth()-\NewTabItem\Length-TabBarGadgetInclude\Margin/2
          EndIf
          If \Attributes & #TabBarGadget_PopupButton
            \NewTabItem\Position - TabBarGadgetInclude\ArrowHeight
          EndIf
        EndIf
        While NextElement(\Item())
          \Item()\Position = $FFFF
          \Item()\Visible  = #False
        Wend
      Else
        If \Attributes & #TabBarGadget_NewTab
          \NewTabItem\Position = Position + \Length
        EndIf
      EndIf
      
      Row(0)\Length = Position - TabBarGadgetInclude\Margin+\Length+1
      
    EndIf
    
    ; Größenänderung des Gadgets
    If Rows <> \Rows And (EventType() >= #PB_EventType_FirstCustomValue Or GetGadgetAttribute(\Number, #PB_Canvas_Buttons) & #PB_Canvas_LeftButton = #False)
      TabBarGadget_StopDrawing(*TabBarGadget)
      If \Attributes & #TabBarGadget_Vertical
        ResizeGadget(\Number, #PB_Ignore, #PB_Ignore, DesktopUnscaledX(Rows*\TabSize+TabBarGadgetInclude\Margin), #PB_Ignore)
      Else
        ResizeGadget(\Number, #PB_Ignore, #PB_Ignore, #PB_Ignore, DesktopUnscaledY(Rows*\TabSize+TabBarGadgetInclude\Margin))
      EndIf
      PostEvent(#PB_Event_Gadget, \Window, \Number, #TabBarGadget_EventType_Resize, -1)
      TabBarGadget_StartDrawing(*TabBarGadget)
      DrawingFont(\FontID)
      \Resized = #True
      \Rows = Rows
    EndIf
    
    ; Animation der bewegten Registerkarte
    If \MoveItem
      If \Attributes & #TabBarGadget_Vertical
        If \Attributes & #TabBarGadget_MirroredTabs XOr \Attributes & #TabBarGadget_ReverseOrdering
          MousePosition = \MouseY
        Else
          MousePosition = OutputHeight()-\MouseY-1
        EndIf
      Else
        If \Attributes & #TabBarGadget_ReverseOrdering
          MousePosition = OutputWidth()-\MouseX-1
        Else
          MousePosition = \MouseX
        EndIf
      EndIf
      Difference = Abs(\MoveItem\Position-(MousePosition-\MoveItem\Length/2))
      If Difference > 24
        Position = MousePosition - \MoveItem\Length/2
      Else
        Factor = Pow(Difference/24, 2)
        Position = \MoveItem\Position*(1-Factor) + (MousePosition-\MoveItem\Length/2)*Factor
      EndIf
      If \Attributes & #TabBarGadget_PreviousArrow = #Null
        If Position < TabBarGadgetInclude\Margin
          Position = TabBarGadgetInclude\Margin
        EndIf
      ElseIf \Shift <= 0 And Position < TabBarGadgetInclude\Margin + TabBarGadgetInclude\ArrowWidth
        Position = TabBarGadgetInclude\Margin + TabBarGadgetInclude\ArrowWidth
      EndIf
      If (\Attributes & #TabBarGadget_NextArrow = #Null Or \Shift >= \LastShift) And Position + \MoveItem\Length + 1 - TabBarGadgetInclude\Margin > Row(\MoveItem\Row)\Length - 1
        Position = Row(\MoveItem\Row)\Length + TabBarGadgetInclude\Margin - \MoveItem\Length
      EndIf
      \MoveItem\Position = Position
    EndIf
    
    ; Aussehen
    ForEach \Item()
      If \Item()\Disabled
        \Item()\Face = #TabBarGadgetItem_DisableFace
      ElseIf \Item() = \MoveItem
        \Item()\Face = #TabBarGadgetItem_MoveFace
      ElseIf \Item() = \SelectedItem Or \Item()\Selected
        \Item()\Face = #TabBarGadgetItem_ActiveFace
      ElseIf \Item() = \HoverItem
        \Item()\Face = #TabBarGadgetItem_HoverFace
      Else
        \Item()\Face = #TabBarGadgetItem_NormalFace
      EndIf
      TabBarGadget_ItemLayout(*TabBarGadget, \Item())
    Next
    If \NewTabItem = \HoverItem
      \NewTabItem\Face = #TabBarGadgetItem_HoverFace
    Else
      \NewTabItem\Face = #TabBarGadgetItem_NormalFace
    EndIf
    TabBarGadget_ItemLayout(*TabBarGadget, \NewTabItem)
    TabBarGadget_Layout(*TabBarGadget)
    
    *TabBarGadget\UpdatePosted = #False
    
  EndWith
  
EndProcedure



; Zeichnet das gesamte TabBarGadget
Procedure TabBarGadget_Draw(*TabBarGadget.TabBarGadget)
  
  If TabBarGadgetInclude\DrawDisabled
    ProcedureReturn
  EndIf
  
  Protected X.i, Y.i, Size.i, SelectedItemDrawed.i, MoveItemDrawed.i, Row.i, *LastItem
  
  With *TabBarGadget
    ; Initialisierung
    DrawingFont(\FontID)
    DrawingMode(#PB_2DDrawing_AllChannels)
    Box(0, 0, OutputWidth(), OutputHeight(), TabBarGadgetInclude\TabBarColor)
    DrawingMode(#PB_2DDrawing_AlphaBlend)
    
    ; Sichtbare Registerkarten
    *LastItem = LastElement(\Item())
    For Row = \Rows-1 To 0 Step -1
      If *LastItem
        PushListPosition(\Item())
        While \Item()\Row >= Row
          If \Item()\Visible And \Item()\Selected = #False And \Item() <> \MoveItem
            TabBarGadget_DrawItem(*TabBarGadget, \Item())
          EndIf
          If Not PreviousElement(\Item())
            Break
          EndIf
        Wend
      EndIf
      ; ggf. "Neu"-Registerkarte (wenn keine Navigation)
      If \NewTabItem\Row = Row And \Attributes & #TabBarGadget_NewTab And \Attributes & #TabBarGadget_NextArrow = #Null
        TabBarGadget_DrawItem(*TabBarGadget, \NewTabItem)
      EndIf
      ; ggf. Unterlinien
      If Row = 0 And \Attributes & #TabBarGadget_BottomLine
        If \Attributes & #TabBarGadget_Vertical
          If \Attributes & #TabBarGadget_MirroredTabs
            Line(0, 0, 1, OutputHeight(), TabBarGadgetInclude\BorderColor)
          Else
            Line(OutputWidth()-1, 0, 1, OutputHeight(), TabBarGadgetInclude\BorderColor)
          EndIf
        Else
          If \Attributes & #TabBarGadget_MirroredTabs
            Line(0, 0, OutputWidth(), 1, TabBarGadgetInclude\BorderColor)
          Else
            Line(0, OutputHeight()-1, OutputWidth(), 1, TabBarGadgetInclude\BorderColor)
          EndIf
        EndIf
      EndIf
      ; ggf. aktive Registerkarte
      If *LastItem
        PopListPosition(\Item())
        While \Item()\Row >= Row
          If \Item()\Visible And \Item()\Selected = #True And \Item() <> \MoveItem
            TabBarGadget_DrawItem(*TabBarGadget, \Item())
          EndIf
          If Not PreviousElement(\Item())
            Break
          EndIf
        Wend
      EndIf
      ; ggf. bewegte Registerkarte
      If \MoveItem And \MoveItem\Row = Row
        TabBarGadget_DrawItem(*TabBarGadget, \MoveItem)
      EndIf
    Next
    
    ; Navigationsausblendung
    DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Gradient)
    ResetGradientColors()
    GradientColor(0.0, TabBarGadgetInclude\TabBarColor&$FFFFFF)
    GradientColor(0.5, TabBarGadgetInclude\TabBarColor&$FFFFFF|$A0<<24)
    GradientColor(1.0, TabBarGadgetInclude\TabBarColor&$FFFFFF|$FF<<24)
    Size = TabBarGadgetInclude\Margin + TabBarGadgetInclude\ArrowWidth + TabBarGadgetInclude\FadeOut
    If \Attributes & #TabBarGadget_PreviousArrow And \Shift
      If \Attributes & #TabBarGadget_Vertical
        If \Attributes & #TabBarGadget_MirroredTabs XOr \Attributes & #TabBarGadget_ReverseOrdering
          LinearGradient(0, Size, 0, Size-TabBarGadgetInclude\FadeOut)
          Box(0, 0, OutputWidth(), Size)
        Else
          LinearGradient(0, OutputHeight()-Size, 0, OutputHeight()-Size+TabBarGadgetInclude\FadeOut)
          Box(0, OutputHeight()-Size, OutputWidth(), Size)
        EndIf
      Else
        If \Attributes & #TabBarGadget_ReverseOrdering
          LinearGradient(OutputWidth()-Size, 0, OutputWidth()-Size+TabBarGadgetInclude\FadeOut, 0)
          Box(OutputWidth()-Size, 0, Size, OutputHeight())
        Else
          LinearGradient(Size, 0, Size-TabBarGadgetInclude\FadeOut, 0)
          Box(0, 0, Size, OutputHeight())
        EndIf
      EndIf
    EndIf
    If \Attributes & #TabBarGadget_NextArrow And \Shift < \LastShift
      If \Attributes & #TabBarGadget_NewTab
        Size + \NewTabItem\Length+TabBarGadgetInclude\Margin
      EndIf
      If \Attributes & #TabBarGadget_PopupButton
        Size + TabBarGadgetInclude\ArrowHeight
      EndIf
      If \Attributes & #TabBarGadget_Vertical
        If \Attributes & #TabBarGadget_MirroredTabs XOr \Attributes & #TabBarGadget_ReverseOrdering
          LinearGradient(0, OutputHeight()-Size, 0, OutputHeight()-Size+TabBarGadgetInclude\FadeOut)
          Box(0, OutputHeight()-Size, OutputWidth(), Size)
        Else
          LinearGradient(0, Size, 0, Size-TabBarGadgetInclude\FadeOut)
          Box(0, 0, OutputWidth(), Size)
        EndIf
      Else
        If \Attributes & #TabBarGadget_ReverseOrdering
          LinearGradient(Size, 0, Size-TabBarGadgetInclude\FadeOut, 0)
          Box(0, 0, Size, OutputHeight())
        Else
          LinearGradient(OutputWidth()-Size, 0, OutputWidth()-Size+TabBarGadgetInclude\FadeOut, 0)
          Box(OutputWidth()-Size, 0, Size, OutputHeight())
        EndIf
      EndIf
    EndIf
    
    ; Navigation
    DrawingMode(#PB_2DDrawing_AlphaBlend)
    If \Attributes & #TabBarGadget_PreviousArrow
      If \HoverArrow = #TabBarGadget_PreviousArrow
        If \HoverArrow = \LockedArrow
          TabBarGadget_DrawButton(\Layout\PreviousButtonX-\Layout\ButtonWidth/2, \Layout\PreviousButtonY-\Layout\ButtonHeight/2, \Layout\ButtonWidth, \Layout\ButtonHeight, -1, TabBarGadgetInclude\FaceColor, *TabBarGadget\Attributes & #TabBarGadget_Vertical)
        Else
          TabBarGadget_DrawButton(\Layout\PreviousButtonX-\Layout\ButtonWidth/2, \Layout\PreviousButtonY-\Layout\ButtonHeight/2, \Layout\ButtonWidth, \Layout\ButtonHeight, 1, TabBarGadgetInclude\FaceColor, *TabBarGadget\Attributes & #TabBarGadget_Vertical)
        EndIf
        TabBarGadget_DrawArrow(\Layout\PreviousButtonX, \Layout\PreviousButtonY, #TabBarGadget_PreviousArrow, TabBarGadgetInclude\TextColor, *TabBarGadget\Attributes)
      ElseIf \Shift > 0
        TabBarGadget_DrawArrow(\Layout\PreviousButtonX, \Layout\PreviousButtonY, #TabBarGadget_PreviousArrow, TabBarGadgetInclude\TextColor&$FFFFFF|$80<<24, *TabBarGadget\Attributes)
      Else
        TabBarGadget_DrawArrow(\Layout\PreviousButtonX, \Layout\PreviousButtonY, #TabBarGadget_PreviousArrow, TabBarGadgetInclude\TextColor&$FFFFFF|$20<<24, *TabBarGadget\Attributes)
      EndIf
    EndIf
    If \Attributes & #TabBarGadget_NextArrow
      If \HoverArrow = #TabBarGadget_NextArrow
        If \HoverArrow = \LockedArrow
          TabBarGadget_DrawButton(\Layout\NextButtonX-\Layout\ButtonWidth/2, \Layout\NextButtonY-\Layout\ButtonHeight/2, \Layout\ButtonWidth, \Layout\ButtonHeight, -1, TabBarGadgetInclude\FaceColor, *TabBarGadget\Attributes & #TabBarGadget_Vertical)
        Else
          TabBarGadget_DrawButton(\Layout\NextButtonX-\Layout\ButtonWidth/2, \Layout\NextButtonY-\Layout\ButtonHeight/2, \Layout\ButtonWidth, \Layout\ButtonHeight, 1, TabBarGadgetInclude\FaceColor, *TabBarGadget\Attributes & #TabBarGadget_Vertical)
        EndIf
        TabBarGadget_DrawArrow(\Layout\NextButtonX, \Layout\NextButtonY, #TabBarGadget_NextArrow, TabBarGadgetInclude\TextColor, *TabBarGadget\Attributes)
      ElseIf \Shift < \LastShift
        TabBarGadget_DrawArrow(\Layout\NextButtonX, \Layout\NextButtonY, #TabBarGadget_NextArrow, TabBarGadgetInclude\TextColor&$FFFFFF|$80<<24, *TabBarGadget\Attributes)
      Else
        TabBarGadget_DrawArrow(\Layout\NextButtonX, \Layout\NextButtonY, #TabBarGadget_NextArrow, TabBarGadgetInclude\TextColor&$FFFFFF|$20<<24, *TabBarGadget\Attributes)
      EndIf
    EndIf
    
    ; "Neu"-Registerkarten (wenn Navigation)
    If \Attributes & #TabBarGadget_NewTab And \Attributes & #TabBarGadget_NextArrow
      TabBarGadget_DrawItem(*TabBarGadget, \NewTabItem)
    EndIf
    
    ; Popup-Button
    If \Attributes & #TabBarGadget_PopupButton
      If \HoverArrow = #TabBarGadget_PopupButton
        If \HoverArrow = \LockedArrow
          TabBarGadget_DrawButton(\Layout\PopupButtonX-\Layout\ButtonSize/2, \Layout\PopupButtonY-\Layout\ButtonSize/2, \Layout\ButtonSize, \Layout\ButtonSize, -1, TabBarGadgetInclude\FaceColor, *TabBarGadget\Attributes & #TabBarGadget_Vertical)
        Else
          TabBarGadget_DrawButton(\Layout\PopupButtonX-\Layout\ButtonSize/2, \Layout\PopupButtonY-\Layout\ButtonSize/2, \Layout\ButtonSize, \Layout\ButtonSize, 1, TabBarGadgetInclude\FaceColor, *TabBarGadget\Attributes & #TabBarGadget_Vertical)
        EndIf
        TabBarGadget_DrawArrow(\Layout\PopupButtonX, \Layout\PopupButtonY, #TabBarGadget_PopupButton, TabBarGadgetInclude\TextColor, *TabBarGadget\Attributes)
      Else
        TabBarGadget_DrawArrow(\Layout\PopupButtonX, \Layout\PopupButtonY, #TabBarGadget_PopupButton, TabBarGadgetInclude\TextColor&$FFFFFF|$80<<24, *TabBarGadget\Attributes)
      EndIf
    EndIf
    
  EndWith
  
EndProcedure



; Dauerschleife für das automatische Scrollen in der Navigation
Procedure TabBarGadget_Timer(Null.i) ; Code OK
  
  With TabBarGadgetInclude\Timer
    Repeat
      If \TabBarGadget
        Delay(250)
        Repeat
          LockMutex(\Mutex)
          If \TabBarGadget
            CompilerIf (#PB_Compiler_OS <> #PB_OS_MacOS) Or (#PB_Compiler_Version >= 560)
              PostEvent(#PB_Event_Gadget, \TabBarGadget\Window, \TabBarGadget\Number, #TabBarGadget_EventType_Pushed, \Type)
            CompilerEndIf
            UnlockMutex(\Mutex)
          Else
            UnlockMutex(\Mutex)
            Break
          EndIf
          Delay(150)
        ForEver
      Else
        Delay(50)
      EndIf
    ForEver
  EndWith
  
EndProcedure



; Sendet ein Ereignis, um die Registerkarte zu aktualisieren.
Procedure TabBarGadget_PostUpdate(*TabBarGadget.TabBarGadget) ; Code OK
  
  If *TabBarGadget\UpdatePosted = #False
    *TabBarGadget\UpdatePosted = #True
    PostEvent(#PB_Event_Gadget, *TabBarGadget\Window, *TabBarGadget\Number, #TabBarGadget_EventType_Updated, -1)
  EndIf
  
EndProcedure



; Callback für BindGadgetEvent()
Procedure TabBarGadget_Callback() ; Code OK
  
  CompilerIf (#TabBarGadget_EnableCallbackGadgetCheck)
    If Not IsGadget(EventGadget())
      ProcedureReturn
    EndIf
  CompilerEndIf
  
  Protected *TabBarGadget.TabBarGadget = GetGadgetData(EventGadget())
  If *TabBarGadget = #Null
    ProcedureReturn
  EndIf
  
  If EventType() >= #PB_EventType_FirstCustomValue
    *TabBarGadget\EventTab = EventData()
    Select EventType()
      Case #TabBarGadget_EventType_Pushed
        Select EventData()
          Case #TabBarGadget_PreviousArrow
            If *TabBarGadget\Shift > 0
              *TabBarGadget\Shift - 1
            EndIf
          Case #TabBarGadget_NextArrow
            If *TabBarGadget\Shift < *TabBarGadget\LastShift
              *TabBarGadget\Shift + 1
            EndIf
        EndSelect
        If TabBarGadget_StartDrawing(*TabBarGadget)
          TabBarGadget_Update(*TabBarGadget)
          TabBarGadget_Draw(*TabBarGadget)
          TabBarGadget_StopDrawing(*TabBarGadget)
        EndIf
      Case #TabBarGadget_EventType_Updated
        If TabBarGadget_StartDrawing(*TabBarGadget)
          TabBarGadget_Update(*TabBarGadget)
          TabBarGadget_Draw(*TabBarGadget)
          TabBarGadget_StopDrawing(*TabBarGadget)
        Else
          *TabBarGadget\UpdatePosted = #False
        EndIf
    EndSelect
  Else
    If TabBarGadget_StartDrawing(*TabBarGadget)
      TabBarGadget_Examine(*TabBarGadget)
      TabBarGadget_Update(*TabBarGadget)
      TabBarGadget_Draw(*TabBarGadget)
      TabBarGadget_StopDrawing(*TabBarGadget)
    EndIf
  EndIf
  
EndProcedure





;-  4.2 Procedures for the TabBarGadget
;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯



; Führt eine Aktualisierung (Neuzeichnung) des Gadgets durch.
Procedure UpdateTabBarGadget(Gadget.i) ; Code OK, Hilfe OK
  
  Protected *TabBarGadget.TabBarGadget = GetGadgetData(Gadget)
  
  If TabBarGadget_StartDrawing(*TabBarGadget)
    TabBarGadget_Update(*TabBarGadget)
    TabBarGadget_Draw(*TabBarGadget)
    TabBarGadget_StopDrawing(*TabBarGadget)
  EndIf
  
EndProcedure



; Gibt das angegebene TabBarGadget wieder frei.
Procedure FreeTabBarGadget(Gadget.i) ; Code OK, Hilfe OK
  
  If Not IsGadget(Gadget)
    ProcedureReturn
  EndIf
  
  Protected *TabBarGadget.TabBarGadget = GetGadgetData(Gadget)
  SetGadgetData(Gadget, #Null)
  
  UnbindGadgetEvent(*TabBarGadget\Number, @TabBarGadget_Callback())
  FreeGadget(Gadget)
  ForEach *TabBarGadget\Item()
    TabBarGadget_ClearItem(*TabBarGadget, *TabBarGadget\Item())
  Next
  ClearStructure(*TabBarGadget, TabBarGadget)
  FreeMemory(*TabBarGadget)
  
EndProcedure



; Erstellt ein neus TabBarGadget.
Procedure.i TabBarGadget(Gadget.i, X.i, Y.i, Width.i, Height.i, Attributes.i, Window.i) ; Code OK
  
  Protected *TabBarGadget.TabBarGadget = AllocateMemory(SizeOf(TabBarGadget))
  Protected Result.i, OldGadgetList.i, DummyGadget.i
  
  InitializeStructure(*TabBarGadget, TabBarGadget)
  OldGadgetList = UseGadgetList(WindowID(Window))
  Result = CanvasGadget(Gadget, X, Y, Width, Height, #PB_Canvas_Keyboard)
  UseGadgetList(OldGadgetList)
  If Gadget = #PB_Any
    Gadget = Result
  EndIf
  SetGadgetData(Gadget, *TabBarGadget)
  
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      TabBarGadgetInclude\DefaultFontID = GetGadgetFont(#PB_Default)
    CompilerCase #PB_OS_Linux
      TabBarGadgetInclude\DefaultFontID = GetGadgetFont(#PB_Default)
    CompilerDefault
      DummyGadget = TextGadget(#PB_Any, 0, 0, 10, 10, "Dummy")
      TabBarGadgetInclude\DefaultFontID = GetGadgetFont(DummyGadget)
      FreeGadget(DummyGadget)
  CompilerEndSelect
  
  With *TabBarGadget
    \Attributes                  = Attributes
    \Number                      = Gadget
    \Window                      = Window
    \NewTabItem\Color\Text       = TabBarGadgetInclude\TextColor
    \NewTabItem\Color\Background = TabBarGadgetInclude\FaceColor
    \Radius                      = TabBarGadgetInclude\Radius
    \MinTabLength                = TabBarGadgetInclude\MinTabLength
    \MaxTabLength                = TabBarGadgetInclude\MaxTabLength
    \NormalTabLength             = TabBarGadgetInclude\NormalTabLength
    \TabTextAlignment            = TabBarGadgetInclude\TabTextAlignment
    \FontID                      = TabBarGadgetInclude\DefaultFontID
    \EventTab                    = #TabBarGadgetItem_None
  EndWith
  
  BindGadgetEvent(Gadget, @TabBarGadget_Callback())
  ;BindEvent(#PB_Event_Gadget, @TabBarGadget_Callback(), #PB_All, Gadget, #PB_All) ; Aktuelle nicht benutzbar
  UpdateTabBarGadget(Gadget)
  
  ProcedureReturn Result
  
EndProcedure



; Fügt eine Registerkarte an die angegebenen Position ein.
Procedure.i AddTabBarGadgetItem(Gadget.i, Position.i, Text.s, ImageID.i=#Null, DataValue.i=#Null) ; Code OK, Hilfe OK
  
  Protected *TabBarGadget.TabBarGadget = GetGadgetData(Gadget)
  Protected *Item.TabBarGadgetItem
  
  If Position = #TabBarGadgetItem_NewTab
    *TabBarGadget\Attributes | #TabBarGadget_NewTab
    *Item = @*TabBarGadget\NewTabItem
  ElseIf TabBarGadget_ItemID(*TabBarGadget, Position)
    *Item = InsertElement(*TabBarGadget\Item())
  Else
    LastElement(*TabBarGadget\Item())
    *Item = AddElement(*TabBarGadget\Item())
    Position = ListIndex(*TabBarGadget\Item())
  EndIf
  
  With *Item
    \Text             = Text
    \ShortText        = Text
    TabBarGadget_ReplaceImage(*TabBarGadget, *Item, ImageID)
    \DataValue        = DataValue
    \Color\Text       = TabBarGadgetInclude\TextColor
    \Color\Background = TabBarGadgetInclude\FaceColor
    If *Item <> @*TabBarGadget\NewTabItem
      \Attributes       = *TabBarGadget\Attributes
    EndIf
  EndWith
  
  TabBarGadget_PostUpdate(*TabBarGadget)
  
  ProcedureReturn Position
  
EndProcedure



; Gibt die einmalige ID der angegebenen Registerkarte zurück.
Procedure.i TabBarGadgetItemID(Gadget.i, Position.i) ; Code OK, Hilfe OK
  
  Protected *TabBarGadget.TabBarGadget = GetGadgetData(Gadget)
  
  ProcedureReturn TabBarGadget_ItemID(*TabBarGadget, Position)
  
EndProcedure



; Entfernt die Registerkarte mit der angegebenen Position.
Procedure RemoveTabBarGadgetItem(Gadget.i, Position.i) ; Code OK, Hilfe OK
  
  Protected *TabBarGadget.TabBarGadget = GetGadgetData(Gadget)
  
  If Position = #TabBarGadgetItem_NewTab
    *TabBarGadget\Attributes & ~#TabBarGadget_NewTab
  ElseIf TabBarGadget_ItemID(*TabBarGadget, Position)
    TabBarGadget_RemoveItem(*TabBarGadget, *TabBarGadget\Item())
  EndIf
  
  TabBarGadget_PostUpdate(*TabBarGadget)
  
EndProcedure



; Entfernt alle Registerkarten aus der Leiste.
Procedure ClearTabBarGadgetItems(Gadget.i) ; Code OK, Hilfe OK
  
  Protected *TabBarGadget.TabBarGadget = GetGadgetData(Gadget)
  
  ForEach *TabBarGadget\Item()
    TabBarGadget_ClearItem(*TabBarGadget, *TabBarGadget\Item())
  Next
  ClearList(*TabBarGadget\Item())
  *TabBarGadget\SelectedItem = #Null
  
  TabBarGadget_PostUpdate(*TabBarGadget)
  
EndProcedure



; Gibt die Anzahl der Registerkarten zurück.
Procedure.i CountTabBarGadgetItems(Gadget.i) ; Code OK, Hilfe OK
  
  Protected *TabBarGadget.TabBarGadget = GetGadgetData(Gadget)
  
  ProcedureReturn ListSize(*TabBarGadget\Item())
  
EndProcedure





;-  4.3 Set- & Get-Prozeduren
;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯



; Setz einen ToolTip für die Registerkartenleiste (für die Registerkarten, die "Neu"-Registerkarte und den Schließenbutton)
Procedure TabBarGadgetToolTip(Gadget.i, ItemText.s="", NewText.s="", CloseText.s="") ; Code OK, Hilfe OK
  
  Protected *TabBarGadget.TabBarGadget = GetGadgetData(Gadget)
  
  *TabBarGadget\ToolTip\ItemText  = ItemText
  *TabBarGadget\ToolTip\NewText   = NewText
  *TabBarGadget\ToolTip\CloseText = CloseText
  
EndProcedure



; Setz einen ToolTip für die Registerkarte.
Procedure TabBarGadgetItemToolTip(Gadget.i, Tab.i, Text.s) ; Code OK, Hilfe OK
  
  Protected *Item.TabBarGadgetItem = TabBarGadgetItemID(Gadget, Tab)
  
  If *Item
    *Item\ToolTip = Text
  EndIf
  
EndProcedure



; Ändert den Wert eines Attributs der Registerkartenleiste.
Procedure SetTabBarGadgetAttribute(Gadget.i, Attribute.i, Value.i, Overwrite.i=#True) ; Code OK, Hilfe OK
  
  Protected *TabBarGadget.TabBarGadget = GetGadgetData(Gadget)
  
  Select Attribute
    Case #TabBarGadget_CloseButton, #TabBarGadget_SelectedCloseButton, #TabBarGadget_NewTab, #TabBarGadget_NoTabMoving, #TabBarGadget_BottomLine,
         #TabBarGadget_MultiLine, #TabBarGadget_PopupButton, #TabBarGadget_Editable, #TabBarGadget_CheckBox, #TabBarGadget_ReverseOrdering
      If Value
        *TabBarGadget\Attributes | Attribute
        If Overwrite
          ForEach *TabBarGadget\Item()
            *TabBarGadget\Item()\Attributes | Attribute
          Next
        EndIf
      Else
        *TabBarGadget\Attributes & ~Attribute
        If Overwrite
          ForEach *TabBarGadget\Item()
            *TabBarGadget\Item()\Attributes & ~Attribute
          Next
        EndIf
      EndIf
    Case #TabBarGadget_MultiSelect
      If Value
        *TabBarGadget\Attributes | Attribute
      Else
        *TabBarGadget\Attributes & ~Attribute
        ForEach *TabBarGadget\Item()
          *TabBarGadget\Item()\Selected = #False
        Next
        If *TabBarGadget\SelectedItem
          *TabBarGadget\SelectedItem\Selected = #True
        EndIf
      EndIf
    Case #TabBarGadget_TextCutting
      If Value
        *TabBarGadget\Attributes | Attribute
      Else
        ForEach *TabBarGadget\Item()
          *TabBarGadget\Item()\ShortText = *TabBarGadget\Item()\Text
        Next
        *TabBarGadget\Attributes & ~Attribute
      EndIf
    Case #TabBarGadget_MirroredTabs, #TabBarGadget_Vertical
      *TabBarGadget\Rows = 0
      If Value
        *TabBarGadget\Attributes | Attribute
      Else
        *TabBarGadget\Attributes & ~Attribute
      EndIf
      ForEach *TabBarGadget\Item()
        If *TabBarGadget\Item()\Image
          TabBarGadget_RotateImage(*TabBarGadget, *TabBarGadget\Item())
        EndIf
      Next
      If *TabBarGadget\NewTabItem\Image
        TabBarGadget_RotateImage(*TabBarGadget, *TabBarGadget\NewTabItem)
      EndIf
    Case #TabBarGadget_TabRounding
      *TabBarGadget\Radius = Value
    Case #TabBarGadget_MinTabLength
      *TabBarGadget\MinTabLength = Value
    Case #TabBarGadget_TabTextAlignment
      *TabBarGadget\TabTextAlignment = Value
    Case #TabBarGadget_MaxTabLength
      ForEach *TabBarGadget\Item()
        *TabBarGadget\Item()\ShortText = *TabBarGadget\Item()\Text
      Next
      *TabBarGadget\MaxTabLength = Value
    Case #TabBarGadget_ScrollPosition
      If Value < 0
        *TabBarGadget\Shift = 0
      ElseIf Value > *TabBarGadget\LastShift
        *TabBarGadget\Shift = *TabBarGadget\LastShift
      Else
        *TabBarGadget\Shift = Value
      EndIf
  EndSelect
  
  TabBarGadget_PostUpdate(*TabBarGadget)
  
EndProcedure



; Gibt den Wert eines Attributs der Registerkartenleiste zurück.
Procedure.i GetTabBarGadgetAttribute(Gadget.i, Attribute.i) ; Code OK, Hilfe OK
  
  Protected *TabBarGadget.TabBarGadget = GetGadgetData(Gadget)
  
  Select Attribute
    Case #TabBarGadget_CloseButton, #TabBarGadget_SelectedCloseButton, #TabBarGadget_NewTab, #TabBarGadget_MirroredTabs, #TabBarGadget_TextCutting,
         #TabBarGadget_NoTabMoving, #TabBarGadget_BottomLine, #TabBarGadget_MultiLine, #TabBarGadget_PopupButton, #TabBarGadget_Editable,
         #TabBarGadget_MultiSelect, #TabBarGadget_Vertical, #TabBarGadget_CheckBox, #TabBarGadget_ReverseOrdering
      If *TabBarGadget\Attributes & Attribute
        ProcedureReturn #True
      Else
        ProcedureReturn #False
      EndIf
    Case #TabBarGadget_TabRounding
      ProcedureReturn *TabBarGadget\Radius
    Case #TabBarGadget_MinTabLength
      ProcedureReturn *TabBarGadget\MinTabLength
    Case #TabBarGadget_MaxTabLength
      ProcedureReturn *TabBarGadget\MaxTabLength
    Case #TabBarGadget_ScrollPosition
      ProcedureReturn *TabBarGadget\Shift
    Case #TabBarGadget_TabTextAlignment
      ProcedureReturn *TabBarGadget\TabTextAlignment
  EndSelect
  
EndProcedure



; Ändert den Daten-Wert der Registerkartenleiste.
Procedure SetTabBarGadgetData(Gadget.i, DataValue.i) ; Code OK, Hilfe OK
  
  Protected *TabBarGadget.TabBarGadget = GetGadgetData(Gadget)
  
  *TabBarGadget\DataValue = DataValue
  
EndProcedure



; Gibt den Daten-Wert der Registerkartenleiste zurück.
Procedure.i GetTabBarGadgetData(Gadget.i) ; Code OK, Hilfe OK
  
  Protected *TabBarGadget.TabBarGadget = GetGadgetData(Gadget)
  
  ProcedureReturn *TabBarGadget\DataValue
  
EndProcedure



; Ändert die zu nutzende Schrift.
Procedure SetTabBarGadgetFont(Gadget.i, FontID.i) ; Code OK, Hilfe OK
  
  Protected *TabBarGadget.TabBarGadget = GetGadgetData(Gadget)
  
  If FontID = #PB_Default
    *TabBarGadget\FontID = TabBarGadgetInclude\DefaultFontID
  Else
    *TabBarGadget\FontID = FontID
  EndIf
  
  ; Reset to 0 to force a new size calculation
  *TabBarGadget\TabSize = 0
  
  TabBarGadget_PostUpdate(*TabBarGadget)
  
EndProcedure



; Ändert den Status der Registerkartenleiste.
Procedure SetTabBarGadgetState(Gadget.i, State.i) ; Code OK, Hilfe OK
  
  Protected *TabBarGadget.TabBarGadget = GetGadgetData(Gadget)
  Protected *Item.TabBarGadgetItem
  
  ForEach *TabBarGadget\Item()
    *TabBarGadget\Item()\Selected = #False
  Next
  Select State
    Case #TabBarGadgetItem_None, #TabBarGadgetItem_NewTab
      *TabBarGadget\SelectedItem = #Null
    Case #TabBarGadgetItem_Selected
    Default
      *Item = TabBarGadget_ItemID(*TabBarGadget, State)
      If *Item
        TabBarGadget_SelectItem(*TabBarGadget, *Item)
      EndIf
  EndSelect
  
  TabBarGadget_PostUpdate(*TabBarGadget)
  
EndProcedure



; Gibt den Status der Registerkartenleiste zurück.
Procedure.i GetTabBarGadgetState(Gadget.i) ; Code OK, Hilfe OK
  
  Protected *TabBarGadget.TabBarGadget = GetGadgetData(Gadget)
  
  If *TabBarGadget\SelectedItem
    ChangeCurrentElement(*TabBarGadget\Item(), *TabBarGadget\SelectedItem)
    ProcedureReturn ListIndex(*TabBarGadget\Item())
  EndIf
  
  ProcedureReturn #TabBarGadgetItem_None
  
EndProcedure



; Wechselt zur der Registerkarte mit dem angegebenen Text
Procedure SetTabBarGadgetText(Gadget.i, Text.s) ; Code OK
  
  Protected *TabBarGadget.TabBarGadget = GetGadgetData(Gadget)
  
  *TabBarGadget\SelectedItem = #Null
  ForEach *TabBarGadget\Item()
    If *TabBarGadget\Item()\Text = Text
      SetTabBarGadgetState(Gadget, @*TabBarGadget\Item())
      Break
    EndIf
  Next
  
EndProcedure



; Gibt den Text der aktuell ausgewählten Registerkarte zurück.
Procedure.s GetTabBarGadgetText(Gadget.i) ; Code OK, Hilfe OK
  
  Protected *TabBarGadget.TabBarGadget = GetGadgetData(Gadget)
  
  If *TabBarGadget\SelectedItem
    ProcedureReturn *TabBarGadget\SelectedItem\Text
  EndIf
  
EndProcedure



; Set attributes global to all TabBarGadgets
Procedure SetTabBarGadgetGlobalAttribute(Attribute.i, Value.i)
  
  Select Attribute
    Case #TabBarGadgetGlobal_WheelDirection
      If Value > 0
        TabBarGadgetInclude\WheelDirection = 1
      Else
        TabBarGadgetInclude\WheelDirection = -1
      EndIf
    Case #TabBarGadgetGlobal_WheelAction
      TabBarGadgetInclude\WheelAction = Value
    Case #TabBarGadgetGlobal_DrawDisabled
      If Value
        TabBarGadgetInclude\DrawDisabled = #True
      Else
        TabBarGadgetInclude\DrawDisabled = #False
      EndIf
    Case #TabBarGadgetGlobal_MiddleClickClose
      If Value
        TabBarGadgetInclude\EnableMiddleClickForCloseTab = #True
      Else
        TabBarGadgetInclude\EnableMiddleClickForCloseTab = #False
      EndIf
    Case #TabBarGadgetGlobal_DoubleClickNew
      If Value
        TabBarGadgetInclude\EnableDoubleClickForNewTab = #True
      Else
        TabBarGadgetInclude\EnableDoubleClickForNewTab = #False
      EndIf
    Case #TabBarGadgetGlobal_TabBarColor
      If Value = #PB_Default
        CompilerIf #PB_Compiler_OS = #PB_OS_Windows
          TabBarGadgetInclude\TabBarColor = GetSysColor_(#COLOR_BTNFACE)
        CompilerElse
          TabBarGadgetInclude\TabBarColor = #TabBarGadgetColor_TabBarDefault
        CompilerEndIf
      Else
        TabBarGadgetInclude\TabBarColor = Value
      EndIf
      TabBarGadgetInclude\TabBarColor | ($FF << 24)
    Case #TabBarGadgetGlobal_BorderColor
      If Value = #PB_Default
        CompilerIf #PB_Compiler_OS = #PB_OS_Windows
          TabBarGadgetInclude\BorderColor = GetSysColor_(#COLOR_3DSHADOW)
        CompilerElse
          TabBarGadgetInclude\BorderColor = #TabBarGadgetColor_BorderDefault
        CompilerEndIf
      Else
        TabBarGadgetInclude\BorderColor = Value
      EndIf
      TabBarGadgetInclude\BorderColor | ($FF << 24)
    Case #TabBarGadgetGlobal_FaceColor
      If Value = #PB_Default
        CompilerIf #PB_Compiler_OS = #PB_OS_Windows
          TabBarGadgetInclude\FaceColor = GetSysColor_(#COLOR_BTNFACE)
        CompilerElse
          TabBarGadgetInclude\FaceColor = #TabBarGadgetColor_FaceDefault
        CompilerEndIf
      Else
        TabBarGadgetInclude\FaceColor = Value
      EndIf
      TabBarGadgetInclude\FaceColor | ($FF << 24)
    Case #TabBarGadgetGlobal_TextColor
      If Value = #PB_Default
        CompilerIf #PB_Compiler_OS = #PB_OS_Windows
          TabBarGadgetInclude\TextColor = GetSysColor_(#COLOR_BTNTEXT)
        CompilerElse
          TabBarGadgetInclude\TextColor = #TabBarGadgetColor_TextDefault
        CompilerEndIf
      Else
        TabBarGadgetInclude\TextColor = Value
      EndIf
      TabBarGadgetInclude\TextColor | ($FF << 24)
  EndSelect
  
EndProcedure

; Get attributes global to all TabBarGadgets
Procedure GetTabBarGadgetGlobalAttribute(Attribute.i)
  
  Select Attribute
    Case #TabBarGadgetGlobal_WheelDirection
      ProcedureReturn TabBarGadgetInclude\WheelDirection
    Case #TabBarGadgetGlobal_WheelAction
      ProcedureReturn TabBarGadgetInclude\WheelAction
    Case #TabBarGadgetGlobal_DrawDisabled
      ProcedureReturn TabBarGadgetInclude\DrawDisabled
    Case #TabBarGadgetGlobal_MiddleClickClose
      ProcedureReturn TabBarGadgetInclude\EnableMiddleClickForCloseTab
    Case #TabBarGadgetGlobal_DoubleClickNew
      ProcedureReturn TabBarGadgetInclude\EnableDoubleClickForNewTab
    Case #TabBarGadgetGlobal_TabBarColor
      ProcedureReturn TabBarGadgetInclude\TabBarColor & $FFFFFF
    Case #TabBarGadgetGlobal_BorderColor
      ProcedureReturn TabBarGadgetInclude\BorderColor & $FFFFFF
    Case #TabBarGadgetGlobal_FaceColor
      ProcedureReturn TabBarGadgetInclude\FaceColor & $FFFFFF
    Case #TabBarGadgetGlobal_TextColor
      ProcedureReturn TabBarGadgetInclude\TextColor & $FFFFFF
  EndSelect
  
EndProcedure



; Ändert die Attribute der angegebenen Registerkarte.
Procedure SetTabBarGadgetItemAttribute(Gadget.i, Tab.i, Attribute.i, Value.i)
  
  Protected *TabBarGadget.TabBarGadget = GetGadgetData(Gadget)
  Protected *Item.TabBarGadgetItem = TabBarGadget_ItemID(*TabBarGadget, Tab)
  
  If *Item And *Item <> *TabBarGadget\NewTabItem
    Select Attribute
      Case #TabBarGadget_CloseButton, #TabBarGadget_SelectedCloseButton, #TabBarGadget_CheckBox
        If Value
          *Item\Attributes | Attribute
        Else
          *Item\Attributes & ~Attribute
        EndIf
    EndSelect
    TabBarGadget_PostUpdate(*TabBarGadget)
  EndIf
  
EndProcedure



; Gibt den Status der angegebenen Registerkarte zurück.
Procedure.i GetTabBarGadgetItemAttribute(Gadget.i, Tab.i, Attribute.i)
  
  Protected *Item.TabBarGadgetItem = TabBarGadgetItemID(Gadget, Tab)
  Protected State.i
  
  If *Item
    Select Attribute
      Case #TabBarGadget_CloseButton, #TabBarGadget_SelectedCloseButton, #TabBarGadget_CheckBox
        If *Item\Attributes & Attribute
          ProcedureReturn #True
        Else
          ProcedureReturn #False
        EndIf
    EndSelect
  EndIf
  
EndProcedure



; Ändert den Datenwert der angegebenen Registerkarte.
Procedure SetTabBarGadgetItemData(Gadget.i, Tab.i, DataValue.i) ; Code OK, Hilfe OK
  
  Protected *Item.TabBarGadgetItem = TabBarGadgetItemID(Gadget, Tab)
  
  If *Item
    *Item\DataValue = DataValue
  EndIf
  
EndProcedure



; Gibt den Datenwert der angegebenen Registerkarte zurück.
Procedure.i GetTabBarGadgetItemData(Gadget.i, Tab.i) ; Code OK, Hilfe OK
  
  Protected *Item.TabBarGadgetItem = TabBarGadgetItemID(Gadget, Tab)
  
  If *Item
    ProcedureReturn *Item\DataValue
  EndIf
  
EndProcedure



; Ändert die Farbe der angegebenen Registerkarte.
Procedure SetTabBarGadgetItemColor(Gadget.i, Tab.i, Type.i, Color.i) ; Code OK, Hilfe OK
  
  Protected *Item.TabBarGadgetItem = TabBarGadgetItemID(Gadget, Tab)
  
  If *Item
    Select Type
      Case #PB_Gadget_FrontColor
        If Color = #PB_Default
          Color = TabBarGadgetInclude\TextColor
        EndIf
        *Item\Color\Text = Color | $FF<<24
      Case #PB_Gadget_BackColor
        If Color = #PB_Default
          Color = TabBarGadgetInclude\FaceColor
        EndIf
        *Item\Color\Background = Color | $FF<<24
    EndSelect
    TabBarGadget_PostUpdate(GetGadgetData(Gadget))
  EndIf
  
EndProcedure



; Gibt die Farbe der angegebenen Registerkarte zurück.
Procedure.i GetTabBarGadgetItemColor(Gadget.i, Tab.i, Type.i) ; Code OK, Hilfe OK
  
  Protected *Item.TabBarGadgetItem = TabBarGadgetItemID(Gadget, Tab)
  
  If *Item
    Select Type
      Case #PB_Gadget_FrontColor
        ProcedureReturn *Item\Color\Text & $FFFFFF
      Case #PB_Gadget_BackColor
        ProcedureReturn *Item\Color\Background & $FFFFFF
    EndSelect
  EndIf
  
EndProcedure



; Ändert das Icon der angegebenen Registerkarte.
Procedure SetTabBarGadgetItemImage(Gadget.i, Tab.i, ImageID.i) ; Code OK, Hilfe OK
  
  Protected *TabBarGadget.TabBarGadget = GetGadgetData(Gadget)
  Protected *Item.TabBarGadgetItem = TabBarGadget_ItemID(*TabBarGadget, Tab)
  
  If *Item
    TabBarGadget_ReplaceImage(*TabBarGadget, *Item, ImageID)
    TabBarGadget_PostUpdate(*TabBarGadget)
  EndIf
  
EndProcedure



; Ändert die Position der angegebenen Registerkarte (die Registerkarte wird also verschoben).
Procedure SetTabBarGadgetItemPosition(Gadget.i, Tab.i, Position.i) ; Code OK, Hilfe OK
  
  Protected *TabBarGadget.TabBarGadget = GetGadgetData(Gadget)
  Protected *NewItem.TabBarGadgetItem = TabBarGadget_ItemID(*TabBarGadget, Position)
  Protected *Item.TabBarGadgetItem = TabBarGadget_ItemID(*TabBarGadget, Tab)
  
  If *Item And *Item <> *TabBarGadget\NewTabItem
    If *NewItem And *NewItem <> *TabBarGadget\NewTabItem
      If Position > Tab
        MoveElement(*TabBarGadget\Item(), #PB_List_After, *NewItem)
      Else
        MoveElement(*TabBarGadget\Item(), #PB_List_Before, *NewItem)
      EndIf
    Else
      MoveElement(*TabBarGadget\Item(), #PB_List_Last)
    EndIf
    TabBarGadget_PostUpdate(*TabBarGadget)
  EndIf
  
EndProcedure



; Gibt die Position der angegebenen Registerkarte zurück.
Procedure GetTabBarGadgetItemPosition(Gadget.i, Tab.i) ; Code OK, Hilfe OK
  
  Protected *TabBarGadget.TabBarGadget = GetGadgetData(Gadget)
  
  With *TabBarGadget
    
    Select Tab
      Case #TabBarGadgetItem_Event
        ProcedureReturn \EventTab
      Case #TabBarGadgetItem_Selected
        If \SelectedItem
          ChangeCurrentElement(\Item(), \SelectedItem)
          ProcedureReturn ListIndex(\Item())
        Else
          ProcedureReturn #TabBarGadgetItem_None
        EndIf
      Case #TabBarGadgetItem_NewTab, #TabBarGadgetItem_None
        ProcedureReturn Tab
      Default
        If Tab >= 0 And Tab < ListSize(\Item())
          ProcedureReturn Tab
        ElseIf Tab >= ListSize(\Item())
          ForEach \Item()
            If @\Item() = Tab
              ProcedureReturn ListIndex(\Item())
            EndIf
          Next
          ProcedureReturn #TabBarGadgetItem_None
        EndIf
    EndSelect
    
  EndWith
  
EndProcedure



; Ändert den Status der angegebenen Registerkarte.
Procedure SetTabBarGadgetItemState(Gadget.i, Tab.i, State.i, Mask.i=#TabBarGadget_Disabled|#TabBarGadget_Selected|#TabBarGadget_Checked) ; Code OK, Hilfe OK
  
  Protected *TabBarGadget.TabBarGadget = GetGadgetData(Gadget)
  Protected *Item.TabBarGadgetItem = TabBarGadget_ItemID(*TabBarGadget, Tab)
  
  If *Item And *Item <> *TabBarGadget\NewTabItem
    If Mask & #TabBarGadget_Disabled
      *Item\Disabled = Bool(State&#TabBarGadget_Disabled)
    EndIf
    If Mask & #TabBarGadget_Checked
      *Item\Checked = Bool(State&#TabBarGadget_Checked)
    EndIf
    If Mask & #TabBarGadget_Selected
      If State & #TabBarGadget_Selected
        TabBarGadget_SelectItem(*TabBarGadget, *Item)
      Else
        TabBarGadget_UnselectItem(*TabBarGadget, *Item)
      EndIf
    EndIf
    TabBarGadget_PostUpdate(*TabBarGadget)
  EndIf
  
EndProcedure



; Gibt den Status der angegebenen Registerkarte zurück.
Procedure.i GetTabBarGadgetItemState(Gadget.i, Tab.i) ; Code OK, Hilfe OK
  
  Protected *Item.TabBarGadgetItem = TabBarGadgetItemID(Gadget, Tab)
  
  If *Item
    ProcedureReturn (*Item\Disabled*#TabBarGadget_Disabled) | (*Item\Selected*#TabBarGadget_Selected) | (*Item\Checked*#TabBarGadget_Checked)
  EndIf
  
EndProcedure



; Ändert den Text der angegebenen Registerkarte.
Procedure SetTabBarGadgetItemText(Gadget.i, Tab.i, Text.s) ; Code OK, Hilfe OK
  
  Protected *Item.TabBarGadgetItem = TabBarGadgetItemID(Gadget, Tab)
  
  If *Item
    *Item\Text      = Text
    *Item\ShortText = Text
    TabBarGadget_PostUpdate(GetGadgetData(Gadget))
  EndIf
  
EndProcedure



; Gibt den Text der angegebenen Registerkarte zurück.
Procedure.s GetTabBarGadgetItemText(Gadget.i, Tab.i) ; Code OK, Hilfe OK
  
  Protected *Item.TabBarGadgetItem = TabBarGadgetItemID(Gadget, Tab)
  
  If *Item
    ProcedureReturn *Item\Text
  EndIf
  
EndProcedure



