;
; ------------------------------------------------------------
;
;   PureBasic - Clipboard example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

; Paste text to the clipboard..
SetClipboardText("PureBasic pasted text example.")

; Display the contents of the clipboard...
MessageRequester("Info", "Text in the clipboard"+#LF$+"'"+GetClipboardText()+"'", 0)

; Now paste an image...

If LoadImage(0, OpenFileRequester("Load a picture","","Bitmap (*.bmp)|*.bmp",0))
  If SetClipboardImage(0)

    MessageRequester("Info", "Image correctly pasted to the clipboard."+Chr(10)+"Open 'Paint' to test it !", 0)
  EndIf
EndIf