  ;
  ; ------------------------------------------------------------
  ;
  ;   PureBasic - UTF8-String example file
  ;
  ;    (c) 2018 - Fantaisie Software
  ;
  ; ------------------------------------------------------------
  ;

  ; This example show how to guess if a raw string is an UTF8-String


  Procedure seems_utf8(*StrMem, iLen.i)
    ;Return #True (1) if a string in memory (buffer) is an UTF8-String, #False (0) otherwise
    
    ; Some var needed
    Protected iCnt.i
    Protected aCharVal.a
    Protected iNext.i
    Protected iCnt2.i
    Protected iUtf8Detected.i = #False
    
    ; get length, For utf8 this means bytes and not characters
    ; we need to check each byte in the string
    
    For iCnt=0 To iLen-1
      
      ; get the byte code 0-255 of the i-th byte
      
      aCharVal = PeekA(*StrMem+iCnt)
      
      ;       Debug "Cnt >"+iCnt+"< CharVal >"+aCharVal+"< - >"+Right("00000000"+Bin(aCharVal, #PB_Ascii),8)+"< Char>"+Chr(aCharVal)+"<"
      
      ; # utf8 characters can take 1-6 bytes, how much
      ; # exactly is decoded in the first character If
      ; # it has a character code >= 128 (highest bit set).
      ; # For all <= 127 the ASCII is the same As UTF8.
      ; # The number of bytes per character is stored in
      ; # the highest bits of the first byte of the UTF8
      ; # character. The bit pattern that must be matched
      ; # For the different length are shown As comment.
      ; #
      ; # So $n will hold the number of additonal characters
      
      If (aCharVal < $80) : iNext = 0 ; # 0bbbbbbb
      ElseIf ((aCharVal & $E0) = $C0) : iNext=1; # 110bbbbb
      ElseIf ((aCharVal & $F0) = $E0) : iNext=2; # 1110bbbb
      ElseIf ((aCharVal & $F8) = $F0) : iNext=3; # 11110bbb
      ElseIf ((aCharVal & $FC) = $F8) : iNext=4; # 111110bb
      ElseIf ((aCharVal & $FE) = $FC) : iNext=5; # 1111110b
      Else
        ;          Debug "error >"+iCnt+"< iLen >"+iLen+"< "
        
        ProcedureReturn #False; # Does not match any model
      EndIf
      
      ; # the code now checks the following additional bytes
      ; # First in the If checks that the byte is really inside the
      ; # string And running over the string End.
      ; # The second just check that the highest two bits of all
      ; # additonal bytes are always 1 And 0 (hexadecimal 0x80)
      ; # which is a requirement For all additional UTF-8 bytes
      If iNext>0
        ;          Debug "Next >"+iNext+"<"
        iUtf8Detected=#True
        For iCnt2=1 To iNext ;# n bytes matching 10bbbbbb follow ?
          If iCnt+iCnt2>iLen Or (PeekA(*StrMem+iCnt+iCnt2) & $C0)<>$80
            ;                Debug "false iCnt >"+iCnt+"< iCnt2>"+iCnt2+"< iLen >"+iLen+"< iNext >"+iNext+"< CHAR >"+PeekA(*StrMem+iCnt)
            
            ProcedureReturn #False
          EndIf
        Next
        iCnt+iCnt2-1
      EndIf
      
    Next
    
    ProcedureReturn iUtf8Detected
    
  EndProcedure
  
  unicode.s="Hélé" ; Since PB 5.5, all strings are created in unicode by default
  
  *Mem0=AllocateMemory(4)
  PokeS(*Mem0,"Hélé",4, #PB_UTF8) ; Fills a buffer with an UTF8-String
  
  *Mem1 = Ascii("Hélé") ; Fills a buffer with an ASCII-String
  *Mem2 = UTF8("Hélé")  ; Fills a buffer With an UTF8-String
  
  
  Debug seems_utf8(@"Hélé", 4)  ; displays #false because it's an unicode-string
  Debug seems_utf8(@unicode, 4) ; displays #false because it's an unicode-string
  Debug seems_utf8(*Mem0, 4)    ; displays #true because it's an UTF8-string
  Debug seems_utf8(*Mem1, 4)    ; displays #false because it's an ASCII-string
  Debug seems_utf8(*Mem2, 4)    ; displays #true because it's an UTF8-string
  
  PokeS(*Mem0,"Hele", 4, #PB_UTF8) ; Fills a buffer with an UTF8-String
  Debug seems_utf8(*Mem0, 4)       ; displays #false because the buffer is filled with ascii characters only (0 to $80=127)
                                     ; then it's not possible to discriminate an ascii-string of an utf8-string
  
  PokeS(*Mem0,"Hé Hele", 7, #PB_UTF8) ; Fills a buffer with an UTF8-String
  Debug seems_utf8(*Mem0, 7)          ; displays #true because because it's an UTF8-string
    