;
; ------------------------------------------------------------
;
;   PureBasic - Conversion Unicode/Utf8/Ascii strings
;
;    (c) 2018 - Fantaisie Software
;
; ------------------------------------------------------------
;


; By default, strings are coded in unicode (since PureBasic 5.50)

MyString_U.s = "Hélé" ; unicode by default

; Let's display an unicode-string
Debug "UNICODE"
Size = StringByteLength(MyString_U)           ; Size = 8 bytes
Debug MyString_U                              ; Hélé
Debug PeekS(@MyString_U, Size)                ; Hélé
ShowMemoryViewer(@MyString_U, Size)           ; 48 00 E9 00 6C 00 E9 00     H.é.l.é.

Debug "----- Hit F7 To Continue -----"
Debug ""

CallDebugger


; Conversion Unicode -> ascii
; ===========================
Debug "Unicode -> ascii"
*MyString_ASCII = Ascii(MyString_U)           ; A buffer filled with the string coded in ascii
Size = MemorySize(*MyString_ASCII)            ; Size = 5 bytes
Debug PeekS(*MyString_ASCII, -1, #PB_Ascii)   ; Hélé
Debug PeekS(*MyString_ASCII, -1)              ; ..
ShowMemoryViewer(*MyString_ASCII, Size)       ; 48 E9 6C E9 00         Hélé.

Debug "----- Hit F7 To Continue -----"
Debug ""

CallDebugger


; Conversion Unicode -> utf8
; ==========================
Debug "Unicode -> utf8"
*MyString_UTF8 = UTF8(MyString_U)              ; A buffer filled with the string coded in utf8
Size = SizeOf(*MyString_UTF8)                  ; Size = 8 bytes
Debug PeekS(*MyString_UTF8, -1 , #PB_UTF8)     ; Hélé
Debug PeekS(*MyString_UTF8, -1)                ; ?? (some weird characters)
ShowMemoryViewer(*MyString_UTF8, Size)         ; 48 C3 A9 6C C3 A9 00 00         HÃ©lÃ©..

Debug "----- Hit F7 To Continue -----"
Debug ""

CallDebugger


; Conversion Ascii -> unicode      (Sometimes, functions from some api (dll, so, ...) or some datas from a COM transaction send ascii strings)
; ============================
Debug "Ascii -> unicode"
MyString_U = PeekS(*MyString_ASCII, SizeOf(*MyString_ASCII), #PB_Ascii) ; Translate ascii to unicode
Size = StringByteLength(MyString_U)
Debug MyString_U                               ; Hélé
Debug PeekS(@MyString_U, Size, #PB_Unicode)    ; Hélé
ShowMemoryViewer(@MyString_U, Size)            ; 48 00 E9 00 6C 00 E9 00           H.é.l.é.

Debug "----- Hit F7 To Continue -----"
Debug ""

CallDebugger

; Conversion Utf8 -> unicode
; ============================
Debug "Utf8 -> unicode"
MyString_U = PeekS(*MyString_UTF8, SizeOf(*MyString_UTF8), #PB_UTF8) ; Translate utf8 to unicode
Size = StringByteLength(MyString_U)
Debug MyString_U                                ; Hélé
Debug PeekS(@MyString_U, Size, #PB_Unicode)     ; Hélé
ShowMemoryViewer(@MyString_U, Size)             ; 48 00 E9 00 6C 00 E9 00           H.é.l.é.

Debug "----- Hit F7 To Continue -----"
Debug ""

CallDebugger

; Not very usefull but if you want converting:
; Ascii ->  utf8   ; Do  a double conversion: Ascii -> unicode -> utf8
; Utf8  ->  ascii  ; Do  a double conversion: Utf8  -> unicode -> ascii





; If you need an ascii-string, the buffer provided by the function ascii() or the pseudotype p-ascii
; are usually sufficient.
; However, if you need a variable (unicode) nested with an ascii-string so do that:

Procedure$ ToAscii (MyString_U.s)
  ;      Debug  Len(MyString_U)
  Protected out$ = Space(Len(MyString_U))
  PokeS(@out$, MyString_U, -1, #PB_Ascii)
  ProcedureReturn out$
EndProcedure

; Back to unicode
Procedure$ FromAscii (MyString_U.s)
  ProcedureReturn PeekS(@MyString_U, -1, #PB_Ascii)
EndProcedure

Debug "ToAscii"
UnicodeASCII$=ToAscii("Hélé")         ; A variable (unicode) filled with an ascii-string
Debug UnicodeASCII$                   ; ..
size = StringByteLength(UnicodeASCII$)
Debug size                            ; 4

ShowMemoryViewer(@UnicodeASCII$,size)


Debug "----- Hit F7 To Continue -----"
Debug ""

CallDebugger

Debug "FromAscii"
Text.s =  FromAscii(UnicodeASCII$)   ; A variable (unicode) filled with an unicode string came from an ascii string
Debug text                           ; Hélé
size = StringByteLength(text)
Debug size                           ;8

ShowMemoryViewer(@text,size)

Debug ""
Debug "END"