;--------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
;--------------------------------------------------------------------------------------------


CompilerIf #PB_Compiler_Unicode = 0
  
  ; We could use PeekS(Memory, -1, #PB_Ascii) for both code, but it will have a performance hit
  ;
  Macro PeekAscii(Memory)
    PeekS(Memory)
  EndMacro
  
  Macro PeekUnicode(Memory)
    PeekS(Memory, -1, #PB_Unicode)
  EndMacro
  
  Macro PeekAsciiLength(Memory, Length)
    PeekS(Memory, Length)
  EndMacro
  
  Macro PokeAscii(Memory, Text)
    PokeS(Memory, Text)
  EndMacro
  
  Macro PokeUnicode(Memory, Text)
    PokeS(Memory, Text, -1, #PB_Unicode)
  EndMacro
  
  Macro ReadAsciiString(File)
    ReadString(File)
  EndMacro
  
  Macro MemoryAsciiLength(Memory)
    MemoryStringLength(Memory)
  EndMacro
  
  Macro ToAscii(String)
    @String
  EndMacro
  
CompilerElse
  
  ; not really a macro, but this is a macro in non-unicode mode, that's why it is here
  Procedure ToAscii(String$)
    Static *Buffer
    
    If *Buffer
      FreeMemory(*Buffer)
    EndIf
    
    *Buffer = AllocateMemory(StringByteLength(String$, #PB_Ascii) + 1)
    PokeS(*Buffer, String$, -1, #PB_Ascii)
    ProcedureReturn *Buffer
  EndProcedure
  
  Procedure ToUTF8(String$)
    Static *Buffer
    
    If *Buffer
      FreeMemory(*Buffer)
    EndIf
    
    *Buffer = AllocateMemory(StringByteLength(String$, #PB_UTF8) + 1)
    PokeS(*Buffer, String$, -1, #PB_UTF8)
    ProcedureReturn *Buffer
  EndProcedure
  
  Macro PeekAscii(Memory)
    PeekS(Memory, -1, #PB_Ascii)
  EndMacro
  
  Macro PeekUnicode(Memory)
    PeekS(Memory)
  EndMacro
  
  Macro PeekAsciiLength(Memory, Length)
    PeekS(Memory, Length, #PB_Ascii)
  EndMacro
  
  Macro PokeAscii(Memory, Text)
    PokeS(Memory, Text, -1, #PB_Ascii)
  EndMacro
  
  Macro PokeUnicode(Memory, Text)
    PokeS(Memory, Text)
  EndMacro
  
  Macro ReadAsciiString(File)
    ReadString(File, #PB_Ascii)
  EndMacro
  
  Macro MemoryAsciiLength(Memory)
    MemoryStringLength(Memory, #PB_Ascii)
  EndMacro
  
CompilerEndIf

; this is the only way to have it work in all cases, including unicode on PPC (no quad!)
Macro AsciiConst(a, b, c, d)
  ((a) << 24 | (b) << 16 | (c) << 8 | (d))
EndMacro

Macro AsciiConst3(a, b, c)
  ((a) << 16 | (b) << 8 | (c))
EndMacro

Macro MemoryStringLengthBytes(Memory)
  (MemoryStringLength(Memory)*#CharSize)
EndMacro

; If we interpret a UTF8 string as Ascii, we get the size in bytes which is perfect
Macro MemoryUTF8LengthBytes(Memory)
  MemoryStringLength(Memory, #PB_Ascii)
EndMacro


; This is for debugging mostly
Macro DebugPointer(Ptr)
  RSet(Hex(Ptr, #PB_Integer), SizeOf(INTEGER)*2, "0")
EndMacro