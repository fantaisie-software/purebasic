;
; ------------------------------------------------------------
;
;   PureBasic - Xml
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

EnableExplicit


ProcedureC StartElementHandler(*UserData, *Name, *Args)
  Protected *Depth.INTEGER = *UserData
  Protected *Arg.INTEGER = *Args
  Protected Indent$ = Space(6 * *Depth\i), AttName$, AttValue$
  
  Debug Indent$ + "Start: " + PeekS(*Name)
  
  ; Attribute values are an array of pointers with alternating name and value entries
  ; Terminated by null pointer
  While *arg\i <> 0
    AttName$ = PeekS(*arg\i)
    *arg + SizeOf(Integer)
    AttValue$ = PeekS(*arg\i)
    *arg + SizeOf(Integer)
    Debug Indent$ + "             " + AttName$ + "=" + AttValue$
  Wend
  
  *Depth\i + 1
EndProcedure

ProcedureC EndElementHandler(*UserData, *Name)
  Protected *Depth.INTEGER = *UserData
  *Depth\i - 1
  Debug Space(6 * *Depth\i) + "End: " + PeekS(*Name)
EndProcedure



If ReadFile(0, #PB_Compiler_Home + "examples/sources/Data/ui.xml")
  
  ; initialize parser
  Define Parser = pb_XML_ParserCreate_(0)
  Define Depth  = 0
  pb_XML_SetUserData_(Parser, @Depth)
  pb_XML_SetStartElementHandler_(Parser, @StartElementHandler())
  pb_XML_SetEndElementHandler_(Parser, @EndElementHandler())
  
  ; block size for streaming. this is very small as an example. Use something larger like 1Mb here for real files!
  Define BufferSize = 20, BytesRead
  Define *Buffer = AllocateMemory(BufferSize)
  
  While Not Eof(0)
    Define BytesRead = ReadData(0, *Buffer, BufferSize)
    If BytesRead > 0
      If pb_XML_Parse_(Parser, *Buffer, BytesRead, #False) = #XML_STATUS_ERROR
        ; parser error (message is in ascii)
        Debug "Parser Error (Line " + Str(pb_XML_GetCurrentLineNumber_(Parser)) + "): " + PeekS(pb_XML_ErrorString_(pb_XML_GetErrorCode_(Parser)), -1, #PB_Ascii)
        Break
      EndIf
    EndIf
  Wend
  
  ; important: finish the parsing process
  pb_XML_Parse_(Parser, *Buffer, 0, #True)
  pb_XML_ParserFree_(Parser)
  
  FreeMemory(*Buffer)
  
  CloseFile(0)
Else
  Debug "Cannot open file"
EndIf
