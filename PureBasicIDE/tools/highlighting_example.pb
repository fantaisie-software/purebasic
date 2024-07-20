; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------



; ==================================================

; Required procedures. They need not do anything

; dummy structure
Structure ProjectTarget
  EnableASM.l
EndStructure

Structure SourceFile
  Target.ProjectTarget
EndStructure

#FILE_LoadFunctions = 0
#FILE_LoadAPI = 1
#DEFAULT_FunctionFile       = ""
#DEFAULT_ApiFile            = ""

Procedure AddTools_Execute(Trigger, *Source.SourceFile)
EndProcedure

Procedure ChangeStatus(Message$)
EndProcedure

Procedure.s GenerateQuickHelpText(Word$)
EndProcedure

XIncludeFile "..\HighlightingEngine.pb"


; ==================================================

Procedure HighlightCallback(*StringStart.BYTE, Length, *Color, IsBold, TextChanged)
  
  If IsBold
    WriteString("<B>")
  EndIf
  
  If *Color <> 0
    WriteString(PeekS(*Color))
  EndIf
  
  
  WriteString(PeekS(*StringStart, Length))
  
  
  If *Color <> 0
    WriteString("</FONT>")
  EndIf
  
  If IsBold
    WriteString("</B>")
  EndIf
  
EndProcedure

; The color values are represented by pointers, because on linux they
; are GtkColor structures.

*ASMKeywordColor    = 0
*BackgroundColor    = 0
*BasicKeywordColor  = @"<FONT COLOR=#009999>"
*CommentColor       = @"<FONT COLOR=#006666>"
*ConstantColor      = 0
*LabelColor         = 0
*NormalTextColor    = 0
*NumberColor        = 0
*OperatorColor      = 0
*PointerColor       = 0
*PureKeywordColor   = @"<FONT COLOR=#009999>"
*SeparatorColor     = 0
*StringColor        = 0
*StructureColor     = 0
*LineNumberColor    = 0
*LineNumberBackColor= 0
*MarkerColor        = 0
*ModuleColor        = 0

EnableColoring = 1        ; set the highlighting options to on.
EnableCaseCorrection = 1
EnableKeywordBolding = 1


InitSyntaxCheckArrays()
InitSyntaxHighlighting()


File$ = OpenFileRequester("Choose File: ", "C:\", "PB Files|*.pb|All Files|*,*", 0)
If ReadFile(0, File$)
  Size = Lof()
  *Buffer = AllocateMemory(Size)
  
  If *Buffer
    ReadData(*Buffer, Size)
    
    If CreateFile(1, File$+".html")
      WriteString("<html><body bgcolor=#FFFFDF><pre>")
      
      HighlightingEngine(*Buffer, Size, 0, @HighlightCallback(), 0) ; 3rd and 5th parameter MUST be 0 if not called from IDE
      
      WriteString("</pre></body></html>")
      
      CloseFile(1)
    EndIf
    
    FreeMemory(*Buffer)
  EndIf
  
  CloseFile(0)
EndIf


