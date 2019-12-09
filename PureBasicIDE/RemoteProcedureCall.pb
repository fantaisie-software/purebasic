;--------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
;--------------------------------------------------------------------------------------------


;
; Helper functions for RPC (remote procedure call)
; This is used by the Automation stuff only at the moment
;
; This basically encodes a function and a list of parameters into a single memory block and back.
;

Structure RPC_Parameter
  Type.l ; #PB_Long etc, or -1 for memory buffer
  Size.l
  String$
  StructureUnion
    Long.l
    Quad.l
    Float.f
    Double.d
    *Memory
  EndStructureUnion
EndStructure

Structure RPC_Call
  Function$
  IsResponse.l
  ResponseID.l
  ErrorFlag.l
  NbParameters.l
  Array Parameter.RPC_Parameter(0)
  *Encoded
  EncodedSize.l
EndStructure


Procedure RPC_ClearCall(*Call.RPC_Call)
  If *Call\Encoded
    FreeMemory(*Call\Encoded)
  EndIf
  
  *Call\Function$    = ""
  *Call\ResponseID   = 0
  *Call\NbParameters = 0
  *Call\Encoded      = 0
  *Call\IsResponse   = 0
  
  FreeArray(*Call\Parameter())
EndProcedure

Procedure RPC_InitCall(*Call.RPC_Call, Function$, NbParameters)
  Static LastResponseID = 0
  
  ; clear old encoded data
  ;
  If *Call\Encoded
    FreeMemory(*Call\Encoded)
  EndIf
  *Call\Encoded = 0
  
  LastResponseID + 1
  
  *Call\Function$    = Function$
  *Call\ResponseID   = LastResponseID
  *Call\NbParameters = NbParameters
  *Call\ErrorFlag    = 0
  *Call\IsResponse   = #False
  
  If NbParameters > 0
    Dim *Call\Parameter(NbParameters-1)
  EndIf
EndProcedure

; Re-initialize an existing Call with values for the response:
;  - keeps ResponseID and Function$ the same
;
Procedure RPC_InitResponse(*Call.RPC_Call, NbParameters, ErrorFlag = 0)
  ; clear old encoded data
  ;
  If *Call\Encoded
    FreeMemory(*Call\Encoded)
  EndIf
  *Call\Encoded = 0
  
  *Call\NbParameters = NbParameters
  *Call\ErrorFlag    = ErrorFlag
  *Call\IsResponse   = #True
  
  If NbParameters > 0
    Dim *Call\Parameter(NbParameters-1)
  EndIf
EndProcedure

; The format is:
; Long: TotalSize
; Long: IsResponse
; Long: ResponseID
; Long: ErrorFlag   ; set to non-zero when returning from a call to indicate error
; Long: NbParameters
; Long: FunctionLength (+null)
; UTF: Function$
; Foreach Parameter
;   Byte: Type
;   <data>
; Next
;
Procedure RPC_Encode(*Call.RPC_Call)
  Success = 0
  
  ; Calculate full size
  ;
  NameLength = StringByteLength(*Call\Function$, #PB_UTF8) + 1
  Size = 24 + NameLength
  For i = 0 To *Call\NbParameters-1
    Size + 1 + *Call\Parameter(i)\Size
    If *Call\Parameter(i)\Type = -1 Or *Call\Parameter(i)\Type = #PB_String
      Size + 4
    EndIf
  Next i
  
  ; allocate
  If *Call\Encoded
    FreeMemory(*Call\Encoded)
  EndIf
  
  *Call\Encoded = AllocateMemory(Size)
  If *Call\Encoded
    *Call\EncodedSize = Size
    
    PokeL(*Call\Encoded,    Size)
    PokeL(*Call\Encoded+4,  *Call\IsResponse)
    PokeL(*Call\Encoded+8,  *Call\ResponseID)
    PokeL(*Call\Encoded+12, *Call\ErrorFlag)
    PokeL(*Call\Encoded+16, *Call\NbParameters)
    PokeL(*Call\Encoded+20, NameLength)
    PokeS(*Call\Encoded+24, *Call\Function$, -1, #PB_UTF8)
    
    *Pointer = *Call\Encoded + 24 + NameLength
    For i = 0 To *Call\NbParameters-1
      PokeB(*Pointer, *Call\Parameter(i)\Type)
      *Pointer + 1
      
      Select *Call\Parameter(i)\Type
        Case #PB_Long:
          PokeL(*Pointer, *Call\Parameter(i)\Long)
          *Pointer + 4
          
        Case #PB_Quad
          PokeQ(*Pointer, *Call\Parameter(i)\Quad)
          *Pointer + 8
          
        Case #PB_Float
          PokeF(*Pointer, *Call\Parameter(i)\Float)
          *Pointer + 4
          
        Case #PB_Double
          PokeD(*Pointer, *Call\Parameter(i)\Double)
          *Pointer + 8
          
        Case #PB_String
          PokeL(*Pointer, *Call\Parameter(i)\Size)
          *Pointer + 4
          PokeS(*Pointer, *Call\Parameter(i)\String$, -1, #PB_UTF8)
          *Pointer + *Call\Parameter(i)\Size
          
        Case -1
          PokeL(*Pointer, *Call\Parameter(i)\Size)
          *Pointer + 4
          If *Call\Parameter(i)\Size > 0
            CopyMemory(*Call\Parameter(i)\Memory, *Pointer, *Call\Parameter(i)\Size)
            *Pointer + *Call\Parameter(i)\Size
          EndIf
          
      EndSelect
    Next i
    
    Success = 1
  EndIf
  
  ProcedureReturn Success
EndProcedure

; If CopyBuffer = #true, then the Call gets a copy of the buffer and the buffer can be freed
; If CopyBuffer = #false, then the Call assumes ownership of *Encoded and frees it (must be AllocateMemory() then)
;
Procedure RPC_Decode(*Call.RPC_Call, *Encoded, Size, CopyBuffer = #True)
  RPC_ClearCall(*Call)
  Success = 0
  
  If *Encoded And Size And PeekL(*Encoded) <= Size ; make sure it is all complete
    
    If CopyBuffer
      *Call\Encoded = AllocateMemory(Size)
      If *Call\Encoded
        CopyMemory(*Encoded, *Call\Encoded, Size)
      EndIf
    Else
      *Call\Encoded = *Encoded
    EndIf
    
    If *Call\Encoded
      *Call\IsResponse   = PeekL(*Encoded+4)
      *Call\ResponseID   = PeekL(*Encoded+8)
      *Call\ErrorFlag    = PeekL(*Encoded+12)
      *Call\NbParameters = PeekL(*Encoded+16)
      *Call\Function$    = PeekS(*Encoded+24, -1, #PB_UTF8)
      *Pointer = *Encoded + 24 + PeekL(*Encoded+20)
      
      If *Call\NbParameters > 0
        Dim *Call\Parameter(*Call\NbParameters-1)
        
        For i = 0 To *Call\NbParameters-1
          *Call\Parameter(i)\Type = PeekB(*Pointer):
          *Pointer + 1
          
          Select *Call\Parameter(i)\Type
            Case #PB_Long:
              *Call\Parameter(i)\Size = 4
              *Call\Parameter(i)\Long = PeekL(*Pointer)
              *Pointer + 4
              
            Case #PB_Quad
              *Call\Parameter(i)\Size = 8
              *Call\Parameter(i)\Quad = PeekQ(*Pointer)
              *Pointer + 8
              
            Case #PB_Float
              *Call\Parameter(i)\Size = 4
              *Call\Parameter(i)\Float = PeekF(*Pointer)
              *Pointer + 4
              
            Case #PB_Double
              *Call\Parameter(i)\Size = 8
              *Call\Parameter(i)\Double = PeekD(*Pointer)
              *Pointer + 8
              
            Case #PB_String
              *Call\Parameter(i)\Size = PeekL(*Pointer)
              *Pointer + 4
              *Call\Parameter(i)\String$ = PeekS(*Pointer, -1, #PB_UTF8)
              *Pointer + *Call\Parameter(i)\Size
              
            Case -1
              *Call\Parameter(i)\Size = PeekL(*Pointer)
              *Pointer + 4
              *Call\Parameter(i)\Memory = *Pointer
              *Pointer + *Call\Parameter(i)\Size
              
          EndSelect
        Next i
      EndIf
      
      Success = 1
    EndIf
  EndIf
  
  ProcedureReturn Success
EndProcedure

Procedure RPC_SetLong(*Call.RPC_Call, Index, Value)
  If Index < *Call\NbParameters
    *Call\Parameter(Index)\Type = #PB_Long
    *Call\Parameter(Index)\Size = 4
    *Call\Parameter(Index)\Long = Value
  EndIf
EndProcedure

Procedure RPC_SetQuad(*Call.RPC_Call, Index, Value.q)
  If Index < *Call\NbParameters
    *Call\Parameter(Index)\Type = #PB_Quad
    *Call\Parameter(Index)\Size = 8
    *Call\Parameter(Index)\Quad = Value
  EndIf
EndProcedure

Procedure RPC_SetFloat(*Call.RPC_Call, Index, Value.f)
  If Index < *Call\NbParameters
    *Call\Parameter(Index)\Type  = #PB_Float
    *Call\Parameter(Index)\Size  = 4
    *Call\Parameter(Index)\Float = Value
  EndIf
EndProcedure

Procedure RPC_SetDouble(*Call.RPC_Call, Index, Value.d)
  If Index < *Call\NbParameters
    *Call\Parameter(Index)\Type   = #PB_Double
    *Call\Parameter(Index)\Size   = 8
    *Call\Parameter(Index)\Double = Value
  EndIf
EndProcedure

Procedure RPC_SetString(*Call.RPC_Call, Index, Value$)
  If Index < *Call\NbParameters
    *Call\Parameter(Index)\Type    = #PB_String
    *Call\Parameter(Index)\Size    = StringByteLength(Value$, #PB_UTF8) + 1
    *Call\Parameter(Index)\String$ = Value$
  EndIf
EndProcedure

; Buffer must remain valid until the Call has been encoded
;
Procedure RPC_SetMemory(*Call.RPC_Call, Index, *Buffer, Size)
  If *Buffer = 0
    Size = 0
  EndIf
  
  If Index < *Call\NbParameters
    *Call\Parameter(Index)\Type   = -1
    *Call\Parameter(Index)\Size   = Size
    *Call\Parameter(Index)\Memory = *Buffer
  EndIf
EndProcedure

Procedure RPC_GetLong(*Call.RPC_Call, Index)
  If Index < *Call\NbParameters And *Call\Parameter(Index)\Type = #PB_Long
    ProcedureReturn *Call\Parameter(Index)\Long
  Else
    ProcedureReturn 0
  EndIf
EndProcedure

Procedure.q RPC_GetQuad(*Call.RPC_Call, Index)
  If Index < *Call\NbParameters And *Call\Parameter(Index)\Type = #PB_Quad
    ProcedureReturn *Call\Parameter(Index)\Quad
  Else
    ProcedureReturn 0
  EndIf
EndProcedure

Procedure.f RPC_GetFloat(*Call.RPC_Call, Index)
  If Index < *Call\NbParameters And *Call\Parameter(Index)\Type = #PB_Float
    ProcedureReturn *Call\Parameter(Index)\Float
  Else
    ProcedureReturn 0
  EndIf
EndProcedure

Procedure.d RPC_GetDouble(*Call.RPC_Call, Index)
  If Index < *Call\NbParameters And *Call\Parameter(Index)\Type = #PB_Double
    ProcedureReturn *Call\Parameter(Index)\Double
  Else
    ProcedureReturn 0
  EndIf
EndProcedure

Procedure.s RPC_GetString(*Call.RPC_Call, Index)
  If Index < *Call\NbParameters And *Call\Parameter(Index)\Type = #PB_String
    ProcedureReturn *Call\Parameter(Index)\String$
  Else
    ProcedureReturn ""
  EndIf
EndProcedure

Procedure RPC_GetMemorySize(*Call.RPC_Call, Index)
  If Index < *Call\NbParameters And *Call\Parameter(Index)\Type = -1
    ProcedureReturn *Call\Parameter(Index)\Size
  Else
    ProcedureReturn 0
  EndIf
EndProcedure

; the memory is valid until the call is cleared
;
Procedure RPC_GetMemory(*Call.RPC_Call, Index)
  If Index < *Call\NbParameters And *Call\Parameter(Index)\Type = -1
    ProcedureReturn *Call\Parameter(Index)\Memory
  Else
    ProcedureReturn 0
  EndIf
EndProcedure


CompilerIf #DEBUG
  
  Procedure RPC_DebugCall(*Call.RPC_Call, Info$ = "")
    Prefix$ = "[RPC] "
    
    Debug Prefix$ + "------------------------------------------------------"
    Debug Prefix$ + "RPC Call: " + Info$
    Debug Prefix$ + "------------------------------------------------------"
    Debug Prefix$ + "Function$    = " + *Call\Function$
    Debug Prefix$ + "IsResponse   = " + Str(*Call\IsResponse)
    Debug Prefix$ + "ResponseID   = " + Str(*Call\ResponseID)
    Debug Prefix$ + "ErrorFlag    = " + Str(*Call\ErrorFlag)
    Debug Prefix$ + "NbParameters = " + Str(*Call\NbParameters)
    
    For i = 0 To *Call\NbParameters-1
      Line$ = Prefix$ + "Parameter("+Str(i)+") = "
      
      Select *Call\Parameter(i)\Type
          
        Case #PB_Long
          Line$ + Str(*Call\Parameter(i)\Long) + "  (Long)"
          
        Case #PB_Quad
          Line$ + Str(*Call\Parameter(i)\Quad) + "  (Quad)"
          
        Case #PB_Float
          Line$ + StrF(*Call\Parameter(i)\Float) + "  (Float)"
          
        Case #PB_Double
          Line$ + StrD(*Call\Parameter(i)\Double) + "  (Double)"
          
        Case #PB_String
          Line$ + Chr(34) + *Call\Parameter(i)\String$ + Chr(34) + "  (String)"
          
        Case -1
          Line$ + "<Buffer=" + Hex(*Call\Parameter(i)\Memory) + ", Size="+Str(*Call\Parameter(i)\Size)+">  (Memory)"
          
      EndSelect
      
      Debug Line$
    Next i
    
    Debug Prefix$ + "------------------------------------------------------"
  EndProcedure
  
CompilerEndIf












