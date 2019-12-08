; === Copyright Notice ===
;
;
;                   PureBasic source code file
;
;
; This file is part of the PureBasic Software package. It may not
; be distributed or published in source code or binary form without
; the expressed permission by Fantaisie Software.
;
; By contributing modifications or additions to this file, you grant
; Fantaisie Software the rights to use, modify and distribute your
; work in the PureBasic package.
;
;
; Copyright (C) 2000-2010 Fantaisie Software - all rights reserved
;
;


XIncludeFile "DialogManager.pb"
XIncludeFile "test_small.pb"

Window.DialogWindow = OpenDialog(?TestDialog, 0, 0)

Repeat
  Event = WaitWindowEvent()
Until Event = #PB_Event_CloseWindow

End
