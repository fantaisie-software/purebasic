; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


;
; Small helper program to create the Version info resource for the IDE on windows
;
; Parameters: <buildtype> <OutputFile>
; buildtype can be "ide", "demo" or "debug"
;
;
OpenConsole()

Procedure.s GetCompilerVersion(Compiler$)
  
  securityattrib.SECURITY_ATTRIBUTES\nLength = SizeOf(SECURITY_ATTRIBUTES)
  securityattrib\bInheritHandle = 1
  securityattrib\lpSecurityDescriptor = 0
  
  *Buffer = AllocateMemory(500)
  
  If *Buffer And CreatePipe_(@hReadPipe, @hWritePipe, @securityattrib, 0)
    info.STARTUPINFO\cb = SizeOf(STARTUPINFO)
    info\dwFlags = #STARTF_USESHOWWINDOW | #STARTF_USESTDHANDLES
    info\hStdOutput = hWritePipe
    
    If CreateProcess_(0, Chr(34)+Compiler$+Chr(34)+" /VERSION", @securityattrib, @securityattrib, 1, #NORMAL_PRIORITY_CLASS, 0, 0, @info, @process.PROCESS_INFORMATION)
      CloseHandle_(hWritePipe)
      
      Repeat
        ; we must read as long as there is data, even when we need only the first line
        result = ReadFile_(hReadPipe, *Buffer, 500, @bytesread, 0)
        If bytesread > 0
          Version$ = StringField(PeekS(*Buffer, bytesread, #PB_Ascii), 1, Chr(13))
        EndIf
      Until result = 0
      
      CloseHandle_(process\hProcess)
      CloseHandle_(process\hThread)
      CloseHandle_(hReadPipe)
      
    EndIf
    
    FreeMemory(*Buffer)
  EndIf
  
  ProcedureReturn Version$
EndProcedure

Procedure.s GetSvnRevision()
  Revision$ = ""
  
  svn = RunProgram("svn.exe", "info . --xml", GetCurrentDirectory(), #PB_Program_Open|#PB_Program_Read|#PB_Program_Hide)
  If svn
    Info$ = ""
    While ProgramRunning(svn)
      Info$ + ReadProgramString(svn) + Chr(13) + Chr(10)
    Wend
    CloseProgram(svn)
    
    ; works in ascii only
    If CatchXML(0, @Info$, Len(Info$)) And XMLStatus(0) = #PB_XML_Success
      *Entry = XMLNodeFromPath(RootXMLNode(0), "/info/entry")
      If *Entry
        Revision$ = GetXMLAttribute(*Entry, "revision")
      EndIf
      FreeXML(0)
    EndIf
  EndIf
  
  If Revision$ = ""
    ProcedureReturn "0" ; fallback for the VersionNumber
  Else
    ProcedureReturn Revision$
  EndIf
EndProcedure


Procedure.s GetGitRevision()
  ;Revision$ = ""
  
  ;git = RunProgram("git.exe", "rev-parse HEAD", GetCurrentDirectory(), #PB_Program_Open|#PB_Program_Read|#PB_Program_Hide|#PB_Program_Ascii)
  ;If git
  ;  Revision$ = ""
  ;  While ProgramRunning(git)
  ;    Revision$ + ReadProgramString(git)
  ;  Wend
  ;  CloseProgram(git)
  ;EndIf
  
  ;If Revision$ = ""
  ;  ProcedureReturn "0" ; fallback for the VersionNumber
  ;Else
  ;  ProcedureReturn Left(Revision$, 8) ; - don't return the full hash
  ;EndIf
  
  ProcedureReturn "0" ; We don't use hash because we need a number for the version in the .RC
EndProcedure

; Input: "PureBasic 4.30 Alpha 3 (Windows - x86)"
;
Procedure.s MakeVersionNumber(VersionString$, SvnRevision$)
  Version$ = StringField(VersionString$, 2, " ")
  Major$   = StringField(Version$, 1, ".")
  Minor$   = StringField(Version$, 2, ".")
  
  ProcedureReturn Major$+","+Minor$+",0,"+SvnRevision$
EndProcedure


BuildType$ = LCase(ProgramParameter())
FileName$ = ProgramParameter()
IconFile$ = ProgramParameter()
ReturnValue = 1

#Q = Chr(34)

If BuildType$ And FileName$
  
  If GetEnvironmentVariable("PB_JAVASCRIPT") = "1" ; SpiderBasic build
    ProductName$ = "SpiderBasic"
    Home$ = GetEnvironmentVariable("SPIDERBASIC_HOME")
    Compiler$ = "sbcompiler.exe"
  Else ; PureBasic build
    ProductName$ = "PureBasic"
    Home$ = GetEnvironmentVariable("PUREBASIC_HOME")
    Compiler$ = "pbcompiler.exe"
  EndIf
  
  If Right(Home$, 1) <> "\"
    Home$ + "\"
  EndIf
  
  Version$ = GetCompilerVersion(Home$ + "Compilers\" + Compiler$)
  Revision$ = GetGitRevision()
  VersionNumber$ = MakeVersionNumber(Version$, Revision$)
  
  If CreateFile(0, FileName$)
    
    ; This icon is added after the one done by the PB compiler
    ; It is used as the icon for PB sourcefiles
    ; (as windows no longer does this automatically because we changed
    ;  the registry stuff a bit in the IDE)
    ;
    ;  FileName$ is a relative directory only!
    ;Icon$ = GetPathPart(GetCurrentDirectory() + FileName$) + "PBSourceFile.ico"
    IconFile$ = ReplaceString(IconFile$, "/", "\")
    IconFile$ = ReplaceString(IconFile$, "\", "\\")
    
    ; a small fix if cygwin is used for the build tools on Windows
    If LCase(Left(IconFile$, 12)) = "\\cygdrive\\"
      IconFile$ = Mid(IconFile$, 13, 1) + ":" + Mid(IconFile$, 14)
    EndIf
    
    ; Sanity check
    If FindString(Version$, " - (c)") = 0
      PrintN("The compiler version string has changed and the parsing will be wrong. Exiting")
      End 1
    EndIf
    
    WriteStringN(0, "2 ICON "+#Q+IconFile$+#Q)
    
    WriteStringN(0, "")
    WriteStringN(0, "1 VERSIONINFO")
    WriteStringN(0, "FILEVERSION "+VersionNumber$)
    WriteStringN(0, "PRODUCTVERSION "+VersionNumber$)
    WriteStringN(0, "FILEOS 0x00000000")  ; unknown os
    WriteStringN(0, "FILETYPE 1")         ; VT_APP
    WriteStringN(0, "{")
    WriteStringN(0, "  BLOCK "+#Q+"StringFileInfo"+#Q)
    WriteStringN(0, "  {")
    WriteStringN(0, "    BLOCK "+#Q+"000004b0"+#Q)
    WriteStringN(0, "    {")
    WriteStringN(0, "      VALUE "+#Q+"CompanyName"     +#Q+", "+#Q+"Fantaisie Software\0"+#Q)
    WriteStringN(0, "      VALUE "+#Q+"ProductName"     +#Q+", "+#Q+ProductName$+"\0"+#Q)
    WriteStringN(0, "      VALUE "+#Q+"ProductVersion"  +#Q+", "+#Q+StringField(Version$, 1, " - (c)")+"\0"+#Q) ; Version is like this: "SpiderBasic 1.00 (Windows - x86) - (c) 2014 Fantaisie Software"
    WriteStringN(0, "      VALUE "+#Q+"FileVersion"     +#Q+", "+#Q+"\0"+#Q)
    WriteStringN(0, "      VALUE "+#Q+"FileDescription" +#Q+", "+#Q+ProductName$+" Development Environment\0"+#Q)
    WriteStringN(0, "      VALUE "+#Q+"InternalName"    +#Q+", "+#Q+ProductName$+"IDE\0"+#Q)
    WriteStringN(0, "      VALUE "+#Q+"OriginalFilename"+#Q+", "+#Q+ProductName$+".exe\0"+#Q)
    WriteStringN(0, "      VALUE "+#Q+"LegalCopyright"  +#Q+", "+#Q+"(c)" + StringField(Version$, 2, " - (c)")+"\0"+#Q) ; Version is like this: "SpiderBasic 1.00 (Windows - x86) - (c) 2014 Fantaisie Software"
    
    Comment$ = "Build Date:  "+FormatDate("%mm/%dd/%yyyy - %hh:%ii:%ss", Date())
    
    If BuildType$ = "demo"
      Comment$ + "  (free version)"
      WriteStringN(0, "      VALUE "+#Q+"SpecialBuild"    +#Q+", "+#Q+"Free Version:  Register your version at http://www."+LCase(ProductName$)+".com\0"+#Q)
    ElseIf BuildType$ = "debug"
      Comment$ + "  (beta version)"
      WriteStringN(0, "      VALUE "+#Q+"SpecialBuild"    +#Q+", "+#Q+"Beta Version:  See http://forums."+LCase(ProductName$)+".com to report bugs.\0"+#Q)
    EndIf
    
    WriteStringN(0, "      VALUE "+#Q+"Comment"         +#Q+", "+#Q+Comment$+"\0"+#Q)
    WriteStringN(0, "    }")
    WriteStringN(0, "  }")
    WriteStringN(0, "  BLOCK "+#Q+"VarFileInfo"+#Q)
    WriteStringN(0, "  {")
    WriteStringN(0, "    VALUE "+#Q+"Translation"+#Q+", 0x0000, 0x4b0")
    WriteStringN(0, "  }")
    WriteStringN(0, "}")
    
    CloseFile(0)
    
    ReturnValue = 0 ; return success
  EndIf
  
EndIf

End ReturnValue