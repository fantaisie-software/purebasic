; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


; Set this to 1 to debug all commiunication with the compiler
; We use the below wrapper macros for compiler communication for this purpose
;
; Use the CompilerRead_NoDebug() macro to read stuff that should not be in the
; debugged output (for example function list, structure list etc)
;
CompilerIf #PB_Compiler_Debugger = 0
  Macro CompilerRead(Mode = #PB_UTF8)
    ReadProgramString(CompilerProgram, Mode)
  EndMacro
  
  Macro CompilerRead_NoDebug(Mode = #PB_UTF8)
    ReadProgramString(CompilerProgram, Mode)
  EndMacro
  
  Macro CompilerWrite(String, Mode = #PB_UTF8)
    WriteProgramStringN(CompilerProgram, String, Mode)
  EndMacro
  
CompilerElse
  Global CompilerRead_FirstNoDebug = 1
  
  Procedure.s CompilerRead(Mode = #PB_UTF8)
    CompilerRead_FirstNoDebug = 1
    Result$ = ReadProgramString(CompilerProgram, Mode)
    Debug "[COMPILER  READ] " + ReplaceString(Result$, Chr(9), "<T>")
    ProcedureReturn Result$
  EndProcedure
  
  Procedure.s CompilerRead_NoDebug(Mode = #PB_UTF8)
    If CompilerRead_FirstNoDebug
      Debug "[COMPILER      ] Skipping display of read data."
    EndIf
    CompilerRead_FirstNoDebug = 0
    ProcedureReturn ReadProgramString(CompilerProgram, Mode)
  EndProcedure
  
  Procedure CompilerWrite(String$, Mode = #PB_UTF8)
    Debug "[COMPILER WRITE] " + ReplaceString(String$, Chr(9), "<T>")
    WriteProgramStringN(CompilerProgram, String$, Mode)
  EndProcedure
CompilerEndIf


Procedure CompilerWriteStringValue(Command$, Value$)
  If Value$
    CompilerWrite(Command$ + #TAB$ + Value$, #PB_UTF8)
  EndIf
EndProcedure


Global Compiler_SubSystem$ = ""
Global CompilerStartup

CompilerIf #SpiderBasic
  Global NewList OpenedWebServers()
CompilerEndIf

CompilerIf #CompileWindows
  #COMPILER_VERSION    = " /VERSION"
  #COMPILER_STANDBY    = " /STANDBY"
  #COMPILER_SUBSYSTEM  = " /SUBSYSTEM "
  #COMPILER_LANGUAGE   = " /LANGUAGE "
  
  CompilerIf #SpiderBasic
    #COMPILER_EXECUTABLE = "Compilers\sbcompiler.exe"
    #COMPILER_UNICODE    = "" ; no special unicode mode for spiderbasic
  CompilerElse
    #COMPILER_EXECUTABLE = "Compilers\pbcompiler.exe"
    #COMPILER_UNICODE    = " /UNICODE" ; still needed to set in older compilers
  CompilerEndIf
  
  #COMPILER_FileFormat = #PB_UTF8
CompilerElse
  CompilerIf #CompileMac And Not #SpiderBasic
    #COMPILER_STANDBY    = " --standby -f -ibp" ; extra flags for osx only
  CompilerElse
    #COMPILER_STANDBY    = " --standby"
  CompilerEndIf
  #COMPILER_VERSION    = " --version"
  #COMPILER_SUBSYSTEM  = " --subsystem "
  #COMPILER_LANGUAGE   = " --language "
  CompilerIf #SpiderBasic
    #COMPILER_EXECUTABLE = "compilers/sbcompiler"
    #COMPILER_UNICODE    = "" ; no special unicode mode for spiderbasic
  CompilerElse
    #COMPILER_EXECUTABLE = "compilers/pbcompiler"
    #COMPILER_UNICODE    = " --unicode" ; still needed to set in older compilers
  CompilerEndIf
  
  #COMPILER_FileFormat = #PB_UTF8
CompilerEndIf


; Windows only parts for handling the resource options
;
CompilerIf #CompileWindows
  
  Procedure.s ReplaceVersionInfo(Value$, *Target.CompileTarget)
    Select OSVersion()
      Case #PB_OS_Windows_NT3_51:         OS$ = "Windows NT3.51"
      Case #PB_OS_Windows_95:             OS$ = "Windows 95"
      Case #PB_OS_Windows_NT_4:           OS$ = "Windows NT4"
      Case #PB_OS_Windows_98:             OS$ = "Windows 98"
      Case #PB_OS_Windows_ME:             OS$ = "Windows ME"
      Case #PB_OS_Windows_2000:           OS$ = "Windows 2000"
      Case #PB_OS_Windows_XP:             OS$ = "Windows XP"
      Case #PB_OS_Windows_Server_2003:    OS$ = "Windows Server 2003"
      Case #PB_OS_Windows_Vista:          OS$ = "Windows Vista"
      Case #PB_OS_Windows_Server_2008:    OS$ = "Windows Server 2008"
      Case #PB_OS_Windows_7:              OS$ = "Windows 7"
      Case #PB_OS_Windows_Server_2008_R2: OS$ = "Windows Server 2008 R2"
      Case #PB_OS_Windows_8:              OS$ = "Windows 8"
      Case #PB_OS_Windows_Server_2012:    OS$ = "Windows Server 2012"
      Case #PB_OS_Windows_8_1:            OS$ = "Windows 8.1"
      Case #PB_OS_Windows_Server_2012_R2: OS$ = "Windows Server 2012 R2"
      Case #PB_OS_Windows_10:             OS$ = "Windows 10"
      Default:                            OS$ = "Windows" ; Don't use _Future here, as if we forget to add a new constant, it will return an empty string
    EndSelect
    
    Value$ = ReplaceString(Value$, "%OS", OS$, 1)
    Value$ = ReplaceString(Value$, "%SOURCE", GetFilePart(*Target\FileName$), 1)
    Value$ = ReplaceString(Value$, "%EXECUTABLE", GetFilePart(*Target\ExecutableName$), 1)
    Value$ = ReplaceString(Value$, "%COMPILECOUNT", Str(*Target\CompileCount))
    Value$ = ReplaceString(Value$, "%BUILDCOUNT", Str(*Target\BuildCount))
    
    ProcedureReturn FormatDate(Value$, Date())
  EndProcedure
  
  Procedure WriteVersionInfoLine(Name$, Value$, *Target.CompileTarget)
    
    If Value$ <> ""
      Value$ = ReplaceVersionInfo(Value$, *Target)
      
      ; We replace \ -> \\ and then we replace all '"' by '\"' to avoid conflict
      ; Note: ASCII only is supported here, no UTF-8
      WriteStringN(#FILE_Resources, "      VALUE "+Chr(34)+Name$+Chr(34)+", "+Chr(34)+ReplaceString(ReplaceString(Value$, "\", "\\"), Chr(34), "\"+Chr(34))+"\0"+Chr(34))
    EndIf
    
  EndProcedure
  
  Procedure.s CreateResourceFile(*Target.CompileTarget)
    Debug *Target\FileName$
    Debug *Target\VersionInfo
    Debug *Target\NbResourceFiles
    Debug "--------"
    
    ; Projects always resolve relative to the project file, not the main sourcefile
    If *Target\IsProject
      BasePath$ = GetPathPart(ProjectFile$)
    Else
      BasePath$ = GetPathPart(*Target\FileName$)
    EndIf
    
    ; check if there is no resource stuff needed
    ;
    If *Target\VersionInfo = 0 And *Target\NbResourceFiles = 0
      ProcedureReturn ""
      
      ; check for only one single file to add
      ;
    ElseIf *Target\VersionInfo = 0 And *Target\NbResourceFiles = 1
      ProcedureReturn ResolveRelativePath(BasePath$, *Target\ResourceFiles$[0])
      
    ElseIf CreateFile(#FILE_Resources, TempPath$ + "PB_Resources.rc", #PB_Unicode) ; Windows accept UTF-16 file format for version, so use it !
      
      WriteStringFormat(#FILE_Resources, #PB_Unicode)
      
      ; define some symbols needed for the VERSION resource statement
      ;
      WriteStringN(#FILE_Resources, "#define VOS_UNKNOWN  0x00000000")
      WriteStringN(#FILE_Resources, "#define VOS_DOS  0x00010000")
      WriteStringN(#FILE_Resources, "#define VOS_OS216  0x00020000")
      WriteStringN(#FILE_Resources, "#define VOS_OS232  0x00030000")
      WriteStringN(#FILE_Resources, "#define VOS_NT  0x00040000")
      WriteStringN(#FILE_Resources, "#define VOS_DOS_WINDOWS16  0x00010001")
      WriteStringN(#FILE_Resources, "#define VOS_DOS_WINDOWS32  0x00010004")
      WriteStringN(#FILE_Resources, "#define VOS_OS216_PM16  0x00020002")
      WriteStringN(#FILE_Resources, "#define VOS_OS232_PM32  0x00030003")
      WriteStringN(#FILE_Resources, "#define VOS_NT_WINDOWS32  0x00040004")
      WriteStringN(#FILE_Resources, "#define VFT_UNKNOWN  0")
      WriteStringN(#FILE_Resources, "#define VFT_APP  1")
      WriteStringN(#FILE_Resources, "#define VFT_DLL  2")
      WriteStringN(#FILE_Resources, "#define VFT_DRV  3")
      WriteStringN(#FILE_Resources, "#define VFT_FONT  4")
      WriteStringN(#FILE_Resources, "#define VFT_VXD  5")
      WriteStringN(#FILE_Resources, "#define VFT_STATIC_LIB  7")
      WriteStringN(#FILE_Resources, "")
      
      ; include additional resource files
      ;
      If *Target\NbResourceFiles > 0
        For i = 0 To *Target\NbResourceFiles-1
          WriteStringN(#FILE_Resources, "#include "+Chr(34)+ResolveRelativePath(BasePath$, *Target\ResourceFiles$[i])+Chr(34))
        Next i
        WriteStringN(#FILE_Resources, "")
      EndIf
      
      ; write the version info if needed
      ;
      If *Target\VersionInfo
        ; the combobox value strings are empty when they are set to the default
        If *Target\VersionField$[15] = ""
          FileOS$ = "VOS_UNKNOWN"
        Else
          FileOS$ = *Target\VersionField$[15]
        EndIf
        If *Target\VersionField$[16] = ""
          FileType$ = "VFT_UNKNOWN"
        Else
          FileType$ = *Target\VersionField$[16]
        EndIf
        If *Target\VersionField$[17] = ""
          Language$ = "0000"
        Else
          Language$ = Left(*Target\VersionField$[17], 4)
        EndIf
        
        ; correct the version fields 1 and 2 if needed ( if wrongly formatted they lead to a resource error)
        Field1$ = ReplaceString(ReplaceVersionInfo(*Target\VersionField$[0], *Target), ".", ",")
        iscorrect = 1
        If CountString(Field1$, ",") <> 3
          iscorrect = 0
        Else
          For i = 1 To Len(Field1$)
            If FindString("1234567890, ", Mid(Field1$, i, 1), 1) = 0
              iscorrect = 0
              Break
            EndIf
          Next i
        EndIf
        If iscorrect = 0
          Field1$ = "0,0,0,0"
        EndIf
        
        Field2$ = ReplaceString(ReplaceVersionInfo(*Target\VersionField$[1], *Target), ".", ",")
        iscorrect = 1
        If CountString(Field2$, ",") <> 3
          iscorrect = 0
        Else
          For i = 1 To Len(Field2$)
            If FindString("1234567890, ", Mid(Field2$, i, 1), 1) = 0
              iscorrect = 0
              Break
            EndIf
          Next i
        EndIf
        If iscorrect = 0
          Field2$ = "0,0,0,0"
        EndIf
        
        WriteStringN(#FILE_Resources, "1 VERSIONINFO")
        WriteStringN(#FILE_Resources, "FILEVERSION " + Field1$)
        WriteStringN(#FILE_Resources, "PRODUCTVERSION " + Field2$)
        WriteStringN(#FILE_Resources, "FILEOS " + FileOS$)
        WriteStringN(#FILE_Resources, "FILETYPE " + FileType$)
        WriteStringN(#FILE_Resources, "{")
        WriteStringN(#FILE_Resources, "  BLOCK "+Chr(34)+"StringFileInfo"+Chr(34))
        WriteStringN(#FILE_Resources, "  {")
        WriteStringN(#FILE_Resources, "    BLOCK "+Chr(34)+Language$+"04b0"+Chr(34))
        WriteStringN(#FILE_Resources, "    {")
        
        WriteVersionInfoLine("CompanyName",      *Target\VersionField$[2], *Target)
        WriteVersionInfoLine("ProductName",      *Target\VersionField$[3], *Target)
        WriteVersionInfoLine("ProductVersion",   *Target\VersionField$[4], *Target)
        WriteVersionInfoLine("FileVersion",      *Target\VersionField$[5], *Target)
        WriteVersionInfoLine("FileDescription",  *Target\VersionField$[6], *Target)
        WriteVersionInfoLine("InternalName",     *Target\VersionField$[7], *Target)
        WriteVersionInfoLine("OriginalFilename", *Target\VersionField$[8], *Target)
        WriteVersionInfoLine("LegalCopyright",   *Target\VersionField$[9], *Target)
        WriteVersionInfoLine("LegalTrademarks",  *Target\VersionField$[10], *Target)
        WriteVersionInfoLine("PrivateBuild",     *Target\VersionField$[11], *Target)
        WriteVersionInfoLine("SpecialBuild",     *Target\VersionField$[12], *Target)
        WriteVersionInfoLine("Email",            *Target\VersionField$[13], *Target)
        WriteVersionInfoLine("Website",          *Target\VersionField$[14], *Target)
        
        For i = 18 To 20
          If *Target\VersionField$[i] <> ""
            WriteVersionInfoLine(*Target\VersionField$[i], *Target\VersionField$[i+3], *Target)
          EndIf
        Next i
        
        WriteStringN(#FILE_Resources, "    }")
        WriteStringN(#FILE_Resources, "  }")
        WriteStringN(#FILE_Resources, "  BLOCK "+Chr(34)+"VarFileInfo"+Chr(34))
        WriteStringN(#FILE_Resources, "  {")
        WriteStringN(#FILE_Resources, "    VALUE "+Chr(34)+"Translation"+Chr(34)+", 0x"+Language$+", 0x4b0")
        WriteStringN(#FILE_Resources, "  }")
        WriteStringN(#FILE_Resources, "}")
      EndIf
      
      CloseFile(#FILE_Resources)
      
      ProcedureReturn TempPath$ + "PB_Resources.rc"
      
    Else
      ProcedureReturn "" ; failure
      
    EndIf
    
  EndProcedure
  
CompilerEndIf


Procedure StartCompiler(*Compiler.Compiler)
  
  ; For the default compiler, we first have to find out these values first
  ;
  If *Compiler = @DefaultCompiler
    *Compiler\Executable$    = PureBasicPath$ + #COMPILER_EXECUTABLE
    *Compiler\VersionString$ = #ProductName$
    *Compiler\VersionNumber  = #PB_Compiler_Version
    
    ; On Unix, if the path has a space, the env variable will contain "\ " instead (shell escaping), so we must remove that
    ; or the RunProgram() will fail
    ;
    CompilerIf #CompileWindows = 0
      *Compiler\Executable$ = ReplaceString(*Compiler\Executable$, "\ ", " ")
    CompilerEndIf
  EndIf
  
  *CurrentCompiler = *Compiler
  CompilerStartup  = 0
  
  Parameters$ = #COMPILER_STANDBY
  
  SubSystem$ = RemoveString(Compiler_SubSystem$, " ")
  index = 1
  While StringField(SubSystem$, index, ",") <> ""
    Parameters$ + #COMPILER_SUBSYSTEM + StringField(SubSystem$, index, ",")
    index + 1
  Wend
  
  CompilerIf #SpiderBasic
    CompilerIf #CompileWindows
      
      Parameters$ + " /JDK " + #DQUOTE$ + ReplaceString(OptionJDK$, "\", "/") + #DQUOTE$
      
    CompilerElseIf #CompileMac
      
      Parameters$ + " -at " + #DQUOTE$ + OptionAppleTeamID$ + #DQUOTE$
      
      ; Needed to have cordova path always set on OS X. Setting the var in the compiler
      ; directory doesn't seems to work.
      ;
      SetEnvironmentVariable("PATH", "/usr/local/bin:" + GetEnvironmentVariable("PATH"))
      
    CompilerEndIf
    
  CompilerElse
    If *Compiler\VersionNumber < 550
      ; Since 5.50 there is only unicode mode (so nothing to set)
      ; Force unicode mode for any older compiler from this IDE to have consistent behavior (there are no settings for this anymore)
      Parameters$ + #COMPILER_UNICODE
    EndIf
  CompilerEndIf
  
  If CurrentLanguage$ <> "English" And *Compiler\VersionNumber >= 430 ; the language switch works on 4.30+ only
    Parameters$ + #COMPILER_LANGUAGE + CurrentLanguage$
  EndIf
  
  CompilerIf #CompileWindows = 0 And #DEBUG = 1 And Not #SpiderBasic
    ; Append the -ds parameter so debug symbols are not cut. This is mainly so
    ; I can properly debug the Debugger library which is compiled into the exe
    Parameters$ + " -ds"
  CompilerEndIf
  
  Debug "[COMPILER START] "+*Compiler\Executable$+" "+Parameters$
  
  ; set the PUREBASIC_HOME for the compiler
  ;
  Home$ = ResolveRelativePath(GetPathPart(*Compiler\Executable$), "../") ; simple trick to get the main dir
  
  CompilerIf #SpiderBasic
    SetEnvironmentVariable("SPIDERBASIC_HOME", Home$)
  CompilerElse
    SetEnvironmentVariable("PUREBASIC_HOME", Home$)
  CompilerEndIf
  
  CompilerProgram = RunProgram(*Compiler\Executable$, Parameters$, "", #PB_Program_Open | #PB_Program_Hide | #PB_Program_Read | #PB_Program_Write | #PB_Program_UTF8)
  
  If CompilerProgram
    
    ; Wait for the compiler version
    Response$ = CompilerRead()
    
    If Left(Response$, 9) = "STARTING" + Chr(9)
      *Compiler\VersionNumber  = Val(LSet(RemoveString(StringField(Response$, 2, Chr(9)), "."), 3, "0"))
      *Compiler\VersionString$ = StringField(Response$, 3, Chr(9))
      
      CompilerStartup  = 1
    Else
      ;
      ; This should only happen with pre 4.10 compilers, but since the IDE is shipped
      ; together with the compiler, we can treat this as a fatal error condition,
      ; as it should not happen in a normal install
      ;
      KillProgram(CompilerProgram)
      CloseProgram(CompilerProgram)
      CompilerProgram = 0
      
      If CommandlineBuild = 0
        MessageRequester(#ProductName$, LanguagePattern("Compiler", "ResponseError", "%product%", #ProductName$), #FLAG_Error)
      Else
        PrintN(LanguagePattern("Compiler", "ResponseError", "%product%", #ProductName$))
        End 1
      EndIf
    EndIf
    
  EndIf
  
EndProcedure


; Set the NoReadyCall to prevent the call to CompilerReady(), as it
; re-highlight all sources.
;
Procedure WaitForCompilerReady(NoReadyCall = 0)
  
  If CompilerProgram And CompilerStartup
    ;
    ; do not lock until the compiler is loaded
    ;
    Timeout.q = ElapsedMilliseconds() + 15000 ; just for safety
    
    While AvailableProgramOutput(CompilerProgram) = 0 And ElapsedMilliseconds() < Timeout
      If CommandlineBuild = 0
        EventLoopCallback()
        DispatchEvent(WaitWindowEvent(50))
      Else
        Delay(50)
      EndIf
    Wend
    
    If ElapsedMilliseconds() < Timeout
      Response$ = CompilerRead()
      
      If Response$ = "READY"
        CompilerStartup = 0
        
        If NoReadyCall = 0 And CommandlineBuild = 0
          CompilerReady()
        EndIf
        CompilerReady = 1  ; set it also if we did not call CompilerReady!
        
      ElseIf Left(Response$, 16) = "ERROR"+Chr(9)+"SUBSYSTEM"+Chr(9)
        Name$ = StringField(Response$, 3, Chr(9))
        
        If CommandlineBuild
          PrintN(Language("Compiler", "SubSystemError")+": "+Name$)
        ElseIf UseProjectBuildWindow And IsWindow(#WINDOW_Build)
          BuildLogEntry(Language("Compiler", "SubSystemError")+": "+Name$)
        Else
          HideCompilerWindow()
          MessageRequester(#ProductName$ + " - Compiler Error", Language("Compiler", "SubSystemError")+": "+Name$, #FLAG_ERROR)
        EndIf
        
        ; No kill here as the compiler terminates itself
        CloseProgram(CompilerProgram)
        CompilerProgram = 0
        CompilerStartup = 0
        
      ElseIf Left(Response$, 6) = "ERROR" + Chr(9)
        Message$ = StringField(Response$, 2, Chr(9))
        If CommandlineBuild
          PrintN("Compiler error!")
          PrintN(Message$)
        Else
          Debugger_AddLog_BySource(*ActiveSource, "[COMPILER] Compiler error!", Date())
          Debugger_AddLog_BySource(*ActiveSource, "[COMPILER] "+Message$, Date())
          
          If UseProjectBuildWindow And IsWindow(#WINDOW_Build)
            BuildLogEntry(Message$)
          Else
            HideCompilerWindow()
            MessageRequester(#ProductName$ + " - Compiler Error", Message$, #FLAG_ERROR)
          EndIf
        EndIf
        
        ; No kill here as the compiler terminates itself
        CloseProgram(CompilerProgram)
        CompilerProgram = 0
        CompilerStartup = 0
      EndIf
    EndIf
    
    If CompilerStartup ; if it is still on, there is something wrong
      KillProgram(CompilerProgram)
      CloseProgram(CompilerProgram)
      CompilerProgram = 0
      CompilerStartup = 0
    EndIf
  EndIf
  
  ProcedureReturn CompilerReady
EndProcedure


Procedure KillCompiler()
  
  If CompilerProgram
    CompilerWrite("END") ; tell the compiler to shut down itself
    
    ; wait for the compiler to shut down itself, else force it
    If WaitProgram(CompilerProgram, 1000) = 0
      KillProgram(CompilerProgram)
    EndIf
    
    CloseProgram(CompilerProgram)
  EndIf
  
  Debug "[COMPILER   END]"
  
  CompilerReady   = 0
  CompilerProgram = 0
  
EndProcedure


; to be called after all sources are closed
; (as this does some cleanup of compiled files as well)
Procedure CompilerCleanup()
  DeleteFile(TempPath$ + "PB_EditorOutput.pb") ; this is ok for vista
  
  CompilerIf #CompileWindows
    DeleteFile(TempPath$ + "PB_Resources.rc")
  CompilerEndIf
  
  CompilerIf #SpiderBasic
    ; Be sure to kill all started servers
    ForEach OpenedWebServers()
      KillProgram(OpenedWebServers())
    Next
  CompilerEndIf
  
  If ExamineDirectory(0, TempPath$, "*")
    Protected CompilerType
    CompilerIf #CompileMac
      CompilerType = #PB_DirectoryEntry_Directory ; a .app is a directory!
    CompilerElse
      CompilerType = #PB_DirectoryEntry_File
    CompilerEndIf
    
    While NextDirectoryEntry(0)
      If DirectoryEntryType(0) = CompilerType
        
        File$ = DirectoryEntryName(0)
        
        CompilerIf #CompileWindows
          If Left(File$, 21) = "PureBasic_Compilation" And Right(File$, 4) = ".exe"
            DeleteFile(TempPath$ + File$)
          EndIf
        CompilerEndIf
        
        CompilerIf #CompileLinux
          If Left(File$, 21) = "purebasic_compilation" And Right(File$, 4) = ".out"
            DeleteFile(TempPath$ + File$)
          EndIf
        CompilerEndIf
        
        CompilerIf #CompileMac
          If Left(File$, 10) = "PureBasic." And Right(File$, 4) = ".app"
            ; a .app is a directory!
            DeleteDirectory(TempPath$ + File$, "*", #PB_FileSystem_Recursive|#PB_FileSystem_Force)
          EndIf
        CompilerEndIf
        
      EndIf
    Wend
    
    FinishDirectory(0)
  EndIf
  
EndProcedure


Procedure RestartCompiler(*Compiler.Compiler, NoReadyCall = 0)
  
  ; Does not check CompilerBusy anymore, as it is called during compilation
  ; to switch unicode mode!
  ;
  KillCompiler()
  
  If CommandlineBuild = 0 And IsMenu(#MENU)
    DisableMenuItem(#MENU, #MENU_StructureViewer, 1)
    DisableMenuItem(#MENU, #MENU_CompileRun, 1)
    DisableMenuItem(#MENU, #MENU_SyntaxCheck, 1)
    DisableMenuItem(#MENU, #MENU_CreateExecutable, 1)
  EndIf
  
  If CommandlineBuild = 0
    DisableToolBarButton(#TOOLBAR, #MENU_CompileRun, 1)
  EndIf
  
  CompilerProgram = 0
  
  StartCompiler(*Compiler)
  WaitForCompilerReady(NoReadyCall)
  
EndProcedure

Procedure ForceDefaultCompiler()
  If *CurrentCompiler <> @DefaultCompiler
    RestartCompiler(@DefaultCompiler, #False)
  EndIf
EndProcedure


Procedure TokenizeCompilerVersion(Version$, *Version.INTEGER, *Beta.INTEGER, *OS.INTEGER, *Processor.INTEGER, *cBackend.INTEGER = 0)
  Version$ = Trim(UCase(Version$))
  
  If StringField(Version$, 1, " ") = UCase(#ProductName$)
    
    ; remove the LTS indicator
    Version$ = ReplaceString(Version$, " LTS ", " ")
    
    *Version\i = Val(LSet(RemoveString(StringField(Version$, 2, " "), "."), 3, "0"))
    
    ; *Beta\i is a bitmask: AlphaVersion | BetaVersion << 8
    ; For Finals, *Beta\i is $FFFF (so higher than all alpha/beta values)
    ;
    If StringField(Version$, 3, " ") = "ALPHA"
      *Beta\i = Val(StringField(Version$, 4, " "))
    ElseIf StringField(Version$, 3, " ") = "BETA"
      *Beta\i = Val(StringField(Version$, 4, " ")) << 8
    Else
      *Beta\i = $FFFF
    EndIf
    
    If FindString(Version$, "WINDOWS", 1)
      *OS\i = #PB_OS_Windows
    ElseIf FindString(Version$, "LINUX", 1)
      *OS\i = #PB_OS_Linux
    ElseIf FindString(Version$, "MACOS", 1)
      *OS\i = #PB_OS_MacOS
    Else
      *OS\i = #PB_OS_AmigaOS  ; unlikely :)
    EndIf
    
    If FindString(Version$, "X86", 1)
      *Processor\i = #PB_Processor_x86
    ElseIf FindString(Version$, "X64", 1)
      *Processor\i = #PB_Processor_x64
    ElseIf FindString(Version$, "POWERPC", 1)
      *Processor\i = #PB_Processor_PowerPC
    ElseIf FindString(Version$, "ARM64", 1)
      *Processor\i = #PB_Processor_Arm64
    Else
      *Processor\i = #PB_Processor_mc68000 ; also unlikely
    EndIf
    
    If *cBackend And FindString(Version$, "C BACKEND") 
      *cBackend\i = 1
    EndIf
    
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure MatchCompilerVersion(Version1$, Version2$, Flags = #MATCH_Exact)
  
  Protected Version1, Beta1, OS1, Processor1, cBackend1
  Protected Version2, Beta2, OS2, Processor2, cBackend2
  
  If TokenizeCompilerVersion(Version1$, @Version1, @Beta1, @OS1, @Processor1, @cBackend1) = #False
    ProcedureReturn #False
  EndIf
  
  If TokenizeCompilerVersion(Version2$, @Version2, @Beta2, @OS2, @Processor2, @cBackend2) = #False
    ProcedureReturn #False
  EndIf
  
  If Flags & #MATCH_OS And OS1 <> OS2
    ProcedureReturn #False
  EndIf
  
  If Flags & #MATCH_Version And Version1 <> Version2
    ProcedureReturn #False
  EndIf
  
  If Flags & #MATCH_VersionUp
    If Version1 > Version2
      ProcedureReturn #False
    EndIf
  EndIf
  
  If Flags & #MATCH_Beta And Beta1 <> Beta2
    ProcedureReturn #False
  EndIf
  
  If Flags & #MATCH_BetaUp And Beta1 > Beta2
    ProcedureReturn #False
  EndIf
  
  If Flags & #MATCH_Processor And Processor1 <> Processor2
    ProcedureReturn #False
  EndIf
  
  If cBackend1 <> cBackend2
    ProcedureReturn #False
  EndIf
    
  ProcedureReturn #True
EndProcedure

Procedure SortCompilers()
  ForEach Compilers()
    If Compilers()\Validated And TokenizeCompilerVersion(Compilers()\VersionString$, @Version, @Beta, @OS, @Processor)
      Compilers()\SortIndex = Processor << 28 | Version << 16 | Beta  ; ignore OS, as all should have the same anyway
    Else
      Compilers()\SortIndex = -1
    EndIf
  Next Compilers()
  
  SortStructuredList(Compilers(), #PB_Sort_Descending, OffsetOf(Compiler\SortIndex), #PB_Long)
EndProcedure

Procedure FindCompiler(Version$)
  
  ; Look for the exact same compiler first
  ;
  If Version$ = DefaultCompiler\VersionString$
    ProcedureReturn @DefaultCompiler
  Else
    ForEach Compilers()
      If Compilers()\Validated And Version$ = Compilers()\VersionString$
        ProcedureReturn @Compilers()
      EndIf
    Next Compilers()
  EndIf
  
  ; Look for an exact match, ignoring OS to have better crossplatform compatibility
  ;
  If MatchCompilerVersion(Version$, DefaultCompiler\VersionString$, #MATCH_Version|#MATCH_Beta|#MATCH_Processor)
    ProcedureReturn @DefaultCompiler
  Else
    ForEach Compilers()
      If Compilers()\Validated And MatchCompilerVersion(Version$, Compilers()\VersionString$, #MATCH_Version|#MATCH_Beta|#MATCH_Processor)
        ProcedureReturn @Compilers()
      EndIf
    Next Compilers()
  EndIf
  
  ; Look for another alpha/beta version now
  ;
  If MatchCompilerVersion(Version$, DefaultCompiler\VersionString$, #MATCH_Version|#MATCH_BetaUp|#MATCH_Processor)
    ProcedureReturn @DefaultCompiler
  Else
    ForEach Compilers()
      If Compilers()\Validated And MatchCompilerVersion(Version$, Compilers()\VersionString$, #MATCH_Version|#MATCH_BetaUp|#MATCH_Processor)
        ProcedureReturn @Compilers()
      EndIf
    Next Compilers()
  EndIf
  
  ; Now look for another higher minor version
  ;
  If MatchCompilerVersion(Version$, DefaultCompiler\VersionString$, #MATCH_VersionUp|#MATCH_Processor)
    ProcedureReturn @DefaultCompiler
  Else
    ForEach Compilers()
      If Compilers()\Validated And MatchCompilerVersion(Version$, Compilers()\VersionString$, #MATCH_VersionUp|#MATCH_Processor)
        ProcedureReturn @Compilers()
      EndIf
    Next Compilers()
  EndIf
  
  ; No match found
  ProcedureReturn 0
EndProcedure


Procedure GetCompilerVersion(Executable$, *Compiler.Compiler)
  *Compiler\Executable$ = Executable$
  *Compiler\Validated   = #False
  Result = #False
  
  Compiler = RunProgram(Executable$, #COMPILER_VERSION, GetPathPart(Executable$), #PB_Program_Hide|#PB_Program_Open|#PB_Program_Read)
  If Compiler
    
    Timeout.q = ElapsedMilliseconds() + 2000
    While ElapsedMilliseconds() < Timeout And AvailableProgramOutput(Compiler) = 0
      Delay(10)
    Wend
    
    If AvailableProgramOutput(Compiler) > 0
      Version$ = ReadProgramString(Compiler)
      
      If Left(Version$, 10) = #ProductName$ + " "
        copy = FindString(Version$, "- (c)", 1) ; cut the copyright statement
        If copy > 0
          Version$ = RTrim(Left(Version$, copy-1))
        EndIf
        
        *Compiler\Executable$    = Executable$
        *Compiler\MD5$           = FileFingerprint(Executable$, #PB_Cipher_MD5)
        *Compiler\VersionString$ = Version$
        *Compiler\VersionNumber  = Val(LSet(RemoveString(StringField(Version$, 2, " "), "."), 3, "0"))
        
        ; 3.94 and 4.00 both know the /VERSION switch, but they do not have the
        ; communication interface, so we cannot accept them
        ;
        If *Compiler\VersionNumber >= 410
          *Compiler\Validated = #True
          Result = #True
        EndIf
        
        ; purge any remaining output (should be nothing more)
        While ProgramRunning(Compiler)
          ReadProgramString(Compiler)
        Wend
        
      Else
        ; probably not a PB compiler, so kill it (we do not know how much output follows)
        KillProgram(Compiler)
      EndIf
    Else
      ; timeout. probably not a PureBasic compiler
      KillProgram(Compiler)
    EndIf
    
    CloseProgram(Compiler)
  EndIf
  
  ProcedureReturn Result
EndProcedure


; ----------------------------------------------------------------------


Procedure Compiler_SetCompiler(*Target.CompileTarget)
  
  ; Find a matching compiler
  ;
  If *Target\CustomCompiler = #False
    *Compiler.Compiler = @DefaultCompiler
  Else
    *Compiler.Compiler = FindCompiler(*Target\CompilerVersion$)
    
    If *Compiler = 0
      If CommandlineBuild
        PrintN(Language("Compiler","CompilerNotFound")+": "+*Target\CompilerVersion$)
      ElseIf UseProjectBuildWindow
        BuildLogEntry(Language("Compiler","CompilerNotFound")+": "+*Target\CompilerVersion$)
      Else
        MessageRequester(#ProductName$, Language("Compiler","CompilerNotFound")+":"+#NewLine+*Target\CompilerVersion$)
      EndIf
      
      ProcedureReturn #False
    EndIf
  EndIf
  
  If *Compiler <> @DefaultCompiler
    If UseProjectBuildWindow And CommandlineBuild = 0
      BuildLogEntry(Language("Compiler","BuildUseCompiler")+": "+*Compiler\VersionString$)
    ElseIf CommandlineBuild And QuietBuild = 0
      Print(Language("Compiler","BuildUseCompiler")+": "+*Compiler\VersionString$)
    EndIf
  EndIf
  
  If *Compiler <> *CurrentCompiler Or CompilerProgram = 0 Or *Target\SubSystem$ <> Compiler_SubSystem$
    Compiler_SubSystem$  = *Target\SubSystem$
    
    If CommandlineBuild = 0
      FlushEvents() ; process all waiting messages
    EndIf
    
    
    ; a compiler restart is required
    RestartCompiler(*Compiler, #True) ; set #true to not call CompilerReady(), as it re-highlights all code!
    
    ; no need to wait for the compiler, as RestartCompiler()
    ; calls WaitForCompilerReady()
    ;
    If CompilerReady ; if 0, restart failed
      
      ; do the needed stuff for CompilerReady() as it is not called here
      If CommandlineBuild = 0
        DisableMenuItem(#MENU, #MENU_StructureViewer, 0)
        DisableMenuItem(#MENU, #MENU_CreateExecutable, 0)
        DisableMenuAndToolbarItem(#MENU_CompileRun, 0)
        DisableMenuAndToolbarItem(#MENU_SyntaxCheck, 0)
      EndIf
      
      ProcedureReturn #True
      
    Else
      HideCompilerWindow()
      
      ; Try to start the compiler again without any subsystem or unicode
      ; (this is for the case where a subsystem cannot be found)
      Compiler_SubSystem$  = ""
      CompilerBusy = 0       ; disable the "compiler is busy" requester
      RestartCompiler(*Compiler, #True) ; set #true to not call CompilerReady(), as it re-highlights all code!
                                        ; do not set Busy flag again as the compilation is aborted
      
      If CompilerReady ; if 0, restart failed
                       ; do the needed stuff for CompilerReady() as it is not called here
        If CommandlineBuild = 0
          DisableMenuItem(#MENU, #MENU_StructureViewer, 0)
          DisableMenuItem(#MENU, #MENU_CreateExecutable, 0)
          DisableMenuAndToolbarItem(#MENU_CompileRun, 0)
          DisableMenuAndToolbarItem(#MENU_SyntaxCheck, 0)
        EndIf
      Else
        
        ; all failed, force the default compiler
        ForceDefaultCompiler()
        
        ; This is fatal also in build mode, as we cannot continue the build without a compiler!
        ; So show this requester in all cases
        ;
        If CommandlineBuild
          PrintN(Language("Compiler","StartError")+": "+*Compiler\VersionString$)
        ElseIf UseProjectBuildWindow
          BuildLogEntry(Language("Compiler","StartError")+": "+*Compiler\VersionString$)
        Else
          MessageRequester(#ProductName$, Language("Compiler","StartError")+": "+*Compiler\VersionString$, #FLAG_Error)
        EndIf
      EndIf
      
      ProcedureReturn #False; abort the compilation in any case (for subsystem problems)
      
    EndIf
    
  EndIf
  
  ProcedureReturn #True ; no change needed, so all ok
EndProcedure

; Handle the error and progress display
;
Procedure Compiler_HandleCompilerResponse(*Target.CompileTarget)
  Protected NewList MacroLines.s()
  
  CompilationAborted = #False ; clear the flag
  WarningCount       = 0
  
  ; handle any PROGRESS messages
  ;
  Repeat
    If CommandlineBuild = 0
      FlushEvents() ; flush at least once the events even if data is waiting
    EndIf
    
    ; wait for data to be ready
    While ProgramRunning(CompilerProgram) And AvailableProgramOutput(CompilerProgram) = 0
      If CommandlineBuild = 0
        While DispatchEvent(WaitWindowEvent(10))
          EventLoopCallback()
        Wend
      Else
        Delay(50)
      EndIf
    Wend
    
    If ProgramRunning(CompilerProgram) = 0
      ; hide the window, so the requester cannot get stuck behind it as it is topmost
      ; the window will be closed by the restart code below.
      If CommandlineBuild
        Message$ = Language("Compiler","CompilerCrash") ; this is a multiline message
        If FindString(Message$, #NewLine, 1)
          Message$ = Left(Message$, FindString(Message$, #NewLine, 1)-1)
        EndIf
        PrintN(Message$)
      ElseIf UseProjectBuildWindow
        Message$ = Language("Compiler","CompilerCrash") ; this is a multiline message
        If FindString(Message$, #NewLine, 1)
          Message$ = Left(Message$, FindString(Message$, #NewLine, 1)-1)
        EndIf
        BuildLogEntry(Message$)
      Else
        HideWindow(#WINDOW_Compiler, #True)
      EndIf
      
      ; Again, this is treated as a fatal error, so even the build mode gets a requester
      If CommandlineBuild = 0
        MessageRequester(#ProductName$, Language("Compiler","CompilerCrash"), #FLAG_Error)
      EndIf
      CompilationAborted = #True ; causes a compiler restart and ensures a proper compilation abort
    EndIf
    
    ; Handle the event that the user aborted the compilation
    ; We can only safely abort a compilation by restarting the compiler, as else
    ; the Compiler-IDE communication is out of sync!
    ;
    If CompilationAborted And CommandlineBuild = 0 ; not possible in commandline mode
      If UseProjectBuildWindow
        BuildLogEntry(Language("Compiler","Aborting"))
      Else
        SetGadgetText(#GADGET_Compiler_Text, Language("Compiler","Aborting"))
        AddCompilerWindowItem(Language("Compiler","Aborting"))
      EndIf
      
      DisableMenuItem(#MENU, #MENU_StructureViewer, 1)
      DisableMenuItem(#MENU, #MENU_CreateExecutable, 1)
      DisableMenuAndToolbarItem(#MENU_CompileRun, 1)
      DisableMenuAndToolbarItem(#MENU_SyntaxCheck, 1)
      
      FlushEvents() ; ensure a proper display
      
      ; do this only if the compiler did not crash!
      ;
      If ProgramRunning(CompilerProgram)
        ; give the compiler a chance to quit itself with proper cleanup
        ; (will only work if compilation finishes in this time anyway)
        ;
        CompilerWrite("END")
        Timeout.q = ElapsedMilliseconds() + 2000
        
        While Timeout.q > ElapsedMilliseconds()
          FlushEvents()
          If WaitProgram(CompilerProgram, 10)
            Break
          EndIf
          
          If AvailableProgramOutput(CompilerProgram) > 0
            ReadProgramString(CompilerProgram) ; we need to read any available input as the compiler will lock else
          EndIf
        Wend
        
        ; Kill it if it is still running (which is probably true, as people will mostly use this if the compiler hangs)
        If ProgramRunning(CompilerProgram)
          KillProgram(CompilerProgram)
        EndIf
      EndIf
      CloseProgram(CompilerProgram)
      
      CompilerProgram = 0
      CompilerReady   = 0
      
      StartCompiler(*CurrentCompiler)
      WaitForCompilerReady(NoReadyCall)
      
      If CompilerReady ; if 0, restart failed
        
        ; do the needed stuff for CompilerReady() as it is not called here
        DisableMenuItem(#MENU, #MENU_StructureViewer, 0)
        DisableMenuItem(#MENU, #MENU_CreateExecutable, 0)
        DisableMenuAndToolbarItem(#MENU_CompileRun, 0)
        DisableMenuAndToolbarItem(#MENU_SyntaxCheck, 0)
      Else
        MessageRequester(#ProductName$, Language("Compiler","RestartError"), #FLAG_Error)
      EndIf
      
      HideCompilerWindow()
      
      ; in build mode, the window stays open, so do not do this
      If UseProjectBuildWindow = 0
        ActivateMainWindow()
      EndIf
      
      ProcedureReturn #False ; compilation aborted
    EndIf
    
    
    Response$ = CompilerRead() ; read compiler response
    
    If Left(Response$, 9) = "PROGRESS"+Chr(9)  ; progress response
      
      Select StringField(Response$, 2, Chr(9))
          
        Case "CREATINGAPP" ; SpiderBasic only
          Purcents = Val(StringField(Response$, 3, Chr(9)))
          
          Log$ = Language("App","Creating") + ": "+ Purcents +" %"
          
          If CommandlineBuild
            If QuietBuild = 0
              PrintN(Log$)
            EndIf
          ElseIf UseProjectBuildWindow
            BuildLogEntry(Log$)
          Else
            If Purcents = 20 ; Only add it once
              AddCompilerWindowItem(Language("App","Creating") + "...")
            EndIf
            
            SetGadgetText(#GADGET_Compiler_Text, Log$)
          EndIf
          
        Case "DOWNLOADINGTEMPLATE" ; SpiderBasic only
          Log$ = Language("App", "DownloadingTemplate")
          
          If CommandlineBuild
            If QuietBuild = 0
              PrintN(Log$)
            EndIf
          ElseIf UseProjectBuildWindow
            BuildLogEntry(Log$)
          Else
            AddCompilerWindowItem(Log$)
            SetGadgetText(#GADGET_Compiler_Text, Log$)
          EndIf
          
        Case "DEPLOYINGAPP" ; SpiderBasic only
          Log$ = Language("App","Deploying")
          
          If CommandlineBuild
            If QuietBuild = 0
              PrintN(Log$)
            EndIf
          ElseIf UseProjectBuildWindow
            BuildLogEntry(Log$)
          Else
            AddCompilerWindowItem(Log$)
            SetGadgetText(#GADGET_Compiler_Text, Log$)
          EndIf
          
        Case "CORDOVALINE" ; SpiderBasic only
          Line$ = Trim(StringField(Response$, 3, Chr(9)))
          
          If Line$
            If CommandlineBuild
              If QuietBuild = 0
                PrintN(Line$)
              EndIf
            ElseIf UseProjectBuildWindow
              BuildLogEntry(Line$)
            Else
              AddCompilerWindowItem(Line$)
            EndIf
          EndIf
          
        Case "LINES"
          Lines = Val(StringField(Response$, 3, Chr(9)))
          
          If UseProjectBuildWindow = 0 And CommandlineBuild = 0
            SetGadgetText(#GADGET_Compiler_Text, Language("Compiler","Compiling") + "  ("+Str(Lines)+" "+Language("Compiler","Lines")+")")
            
            ; do not show the progressbar info if we have no old total value
            If *Target\LastCompiledLines <> 0
              If Lines < *Target\LastCompiledLines
                SetGadgetState(#GADGET_Compiler_Progress, (1000*Lines)/*Target\LastCompiledLines)
              Else
                SetGadgetState(#GADGET_Compiler_Progress, 1000)
              EndIf
            EndIf
          EndIf
          
          ; store the last known value (total lines) for the next compilation
          *Target\LastCompiledLines = Lines
          
        Case "INCLUDES"
          Include$ = StringField(Response$, 3, Chr(9))
          If *Target\FileName$ <> ""
            Include$ = CreateRelativePath(GetPathPart(*Target\FileName$), Include$)
          EndIf
          
          If CommandlineBuild
            If QuietBuild = 0
              PrintN(Language("Compiler","Including")+": "+Include$)
            EndIf
          ElseIf UseProjectBuildWindow
            BuildLogEntry(Language("Compiler","Including")+": "+Include$)
          Else
            AddCompilerWindowItem(Language("Compiler","Including")+": "+Include$)
          EndIf
          
        Case "ASSEMBLING"
          If CommandlineBuild
            If QuietBuild = 0
              PrintN(LanguagePattern("Compiler", "LinesCompiled", "%count%", Str(Lines)))
              PrintN(Language("Compiler","Finishing"))
            EndIf
          ElseIf UseProjectBuildWindow
            BuildLogEntry(LanguagePattern("Compiler", "LinesCompiled", "%count%", Str(Lines)))
            BuildLogEntry(Language("Compiler","Finishing"))
          Else
            AddCompilerWindowItem(Language("Compiler","Finishing"))
            SetGadgetState(#GADGET_Compiler_Progress, 1000)
          EndIf
          
          ; Case "LINKING" ; ignore that one for now
      EndSelect
      
    ElseIf Left(Response$, 8) = "WARNING"+Chr(9)  ; warning message
      File$ = *Target\FileName$
      Line  = Val(StringField(Response$, 2, Chr(9)))
      Message$ = ""
      
      ; Read all warning related information
      ;
      Repeat
        Response$ = CompilerRead()
        
        If Left(Response$, 8) = "MESSAGE"+Chr(9)
          Message$ = Right(Response$, Len(Response$)-8)
          
        ElseIf Left(Response$, 12) = "INCLUDEFILE"+Chr(9)
          File$ = ResolveRelativePath(GetPathPart(*Target\FileName$), StringField(Response$, 2, Chr(9)))
          Line  = Val(StringField(Response$, 3, Chr(9)))
        EndIf
        
      Until Response$ = "OUTPUT" + Chr(9) + "COMPLETE"
      
      If UseProjectBuildWindow Or CommandlineBuild
        ; add message to warning list for the build window
        AddElement(BuildInfo())
        BuildInfo()\IsWarning = #True
        BuildInfo()\File$     = File$
        BuildInfo()\Line      = Line
        
        ; add the log messages (with the warning index attached)
        If Not IsEqualFile(File$, *Target\FileName$)
          If CommandlineBuild
            If QuietBuild = 0
              PrintN(Language("Misc","File")+": "+CreateRelativePath(GetPathPart(*Target\FileName$), File$))
            EndIf
          Else
            BuildLogEntry(Language("Misc","File")+": "+CreateRelativePath(GetPathPart(*Target\FileName$), File$), ListIndex(BuildInfo()))
          EndIf
        EndIf
        
        If CommandlineBuild
          If QuietBuild = 0
            PrintN(Language("Compiler","ErrorLine")+" "+Str(Line)+": "+Language("Compiler","Warning")+": "+Message$)
          EndIf
        Else
          BuildLogEntry(Language("Compiler","ErrorLine")+" "+Str(Line)+": "+Language("Compiler","Warning")+": "+Message$, ListIndex(BuildInfo()))
        EndIf
        
      Else
        ; add message to warning list (for warning window)
        ; (the list is emptied when opening the compiling window)
        AddElement(Warnings())
        Warnings()\File$         = File$
        Warnings()\RelativeFile$ = CreateRelativePath(GetPathPart(*Target\FileName$), File$)
        Warnings()\Line          = Line
        Warnings()\Message$      = Message$
        
        ; add message to log
        If Not IsEqualFile(File$, *Target\FileName$)
          Debugger_AddLog_BySource(*ActiveSource, Language("Compiler","LogCompiler")+" "+Language("Misc","File")+": "+CreateRelativePath(GetPathPart(*Target\FileName$), File$), Date())
        EndIf
        
        Debugger_AddLog_BySource(*ActiveSource, Language("Compiler","LogCompiler")+" "+Language("Compiler","ErrorLine")+" "+Str(Line)+": "+Language("Compiler","Warning")+": "+Message$, Date())
        
      EndIf
      
      WarningCount + 1
      
    Else ; compilation finished
      Break
      
    EndIf
  ForEver
  
  If Response$ = "SUCCESS"
    
    If CommandlineBuild = 0
      HideCompilerWindow()
    EndIf
    
    If WarningCount > 0
      If CommandlineBuild
        If QuietBuild = 0
          PrintN(LanguagePattern("Compiler","WarningTotals", "%warnings%", Str(WarningCount)))
        EndIf
      ElseIf UseProjectBuildWindow
        BuildLogEntry(LanguagePattern("Compiler","WarningTotals", "%warnings%", Str(WarningCount)))
      Else
        Debugger_AddLog_BySource(*ActiveSource, LanguagePattern("Compiler","WarningTotals", "%warnings%", Str(WarningCount)), Date())
        
        ; display the warning window now
        DisplayCompilerWarnings()
      EndIf
    EndIf
    
    ; compilation succeeded
    ProcedureReturn #True
    
  ElseIf Left(Response$, 13) = "ERROR"+Chr(9)+"SYNTAX"+Chr(9) ; syntax error
    
    ErrorLine    = Val(StringField(Response$, 3, Chr(9)))
    IncludeLine  = -1
    
    ; Read all the information from the compiler
    ;
    Repeat
      Response$ = CompilerRead()
      
      If Response$ = "OUTPUT"+Chr(9)+"COMPLETE"
        Break
        
      ElseIf Left(Response$, 8) = "MESSAGE"+Chr(9)
        Message$ = Right(Response$, Len(Response$)-8)
        
      ElseIf Left(Response$, 12) = "INCLUDEFILE"+Chr(9)
        IncludeName$ = StringField(Response$, 2, Chr(9))
        IncludeLine  = Val(StringField(Response$, 3, Chr(9)))
        
        
      ElseIf Left(Response$, 6) = "MACRO"+Chr(9)
        MacroLine  = Val(StringField(Response$, 2, Chr(9)))
        LinesCount = Val(StringField(Response$, 3, Chr(9)))
        IsMacroError = 1
        
        ; get the while macro
        Repeat
          Response$ = CompilerRead()
          
          If Response$ = "OUTPUT"+Chr(9)+"COMPLETE" ; should not happen here actually
            Break 2
            
          ElseIf Response$ = "MACRO"+Chr(9)+"COMPLETE" And ListSize(MacroLines()) = LinesCount; macro finished
            Break
            
          Else
            AddElement(MacroLines())
            MacroLines() = Response$
          EndIf
        ForEver
        
      EndIf
    ForEver
    
    CompilerIf #SpiderBasic
      ; Don't hide the CompilerWindow if an error occurs during the cordova creation so we can look at the logs
      ;
      If CommandlineBuild = 0 And ErrorLine <> -1
        HideCompilerWindow()
      Else
        CompilerBusy = 0 ; Clear the compiler busy flag, so we can close the manually the CompilerWindow
      EndIf
    CompilerElse
      If CommandlineBuild = 0
        HideCompilerWindow()
      EndIf    
    CompilerEndIf
    
    ; Process the information
    ;
    If IncludeName$ = "" ; main file
      If ErrorLine = -1
        Line$ = Message$
      Else
        Line$ = Language("Compiler","ErrorLine")+" "+Str(ErrorLine)+": "+Message$
      EndIf
      
      If *Target\UseMainFile = 0  ; it is this source, so no problem
        ErrorFile$ = *Target\FileName$
        
      Else    ; it is the main file, so switch to it
        ErrorFile$ = ResolveRelativePath(GetPathPart(*Target\FileName$), *Target\MainFile$)
        Line$ = Language("Compiler","ErrorMainFile")+" '"+*Target\MainFile$ +"'"+ #NewLine + Line$
        
      EndIf
      
    Else ; includefile
      If IncludeLine = -1
        Line$ = Message$
      Else
        Line$ = Language("Compiler","ErrorLine")+" "+Str(IncludeLine)+": "+Message$
      EndIf
      
      ; switch to the included file
      If *Target\UseMainFile = 0
        ErrorFile$ = ResolveRelativePath(GetPathPart(*Target\FileName$), IncludeName$)
      Else
        ErrorFile$ = ResolveRelativePath(GetPathPart(ResolveRelativePath(GetPathPart(*Target\FileName$), *Target\MainFile$)), IncludeName$)
      EndIf
      ErrorLine = IncludeLine
      
    EndIf
    
    ; Display info to the user
    ;
    If CommandlineBuild
      
      ; errors are displayed also in quiet mode
      ; Macro errors are not displayed in this mode
      PrintN(Language("Misc", "Error") + ": " + ErrorFile$)
      PrintN(Line$)
      
    ElseIf UseProjectBuildWindow
      ; Project build mode
      ; Add an entry to the info list so the log entries are clickable
      If ErrorFile$ <> "" And ErrorLine <> -1
        AddElement(BuildInfo())
        BuildInfo()\IsWarning = #False
        BuildInfo()\File$     = ErrorFile$
        BuildInfo()\Line      = ErrorLine
        InfoIndex = ListIndex(BuildInfo())
      Else
        InfoIndex = -1
      EndIf
      
      LogLine$ = Line$
      While FindString(LogLine$, #NewLine, 1) <> 0
        pos = FindString(LogLine$, #NewLine, 1)
        Part$ = Left(LogLine$, pos-1)
        LogLine$ = Right(LogLine$, Len(LogLine$)-pos-(Len(#NewLine)-1))
        
        BuildLogEntry(Part$, InfoIndex)
      Wend
      BuildLogEntry(LogLine$, InfoIndex)
      
      ; Macro errors are not displayed in this mode
      
    Else
      ; Normal compile mode
      
      If ErrorFile$
        LoadSourceFile(ErrorFile$) ; will simply switch, if the file is open
      EndIf
      
      If ErrorLine <> -1  ; highlight the error line
        ChangeActiveLine(ErrorLine, -5)
        SetSelection(ErrorLine, 1, ErrorLine, -1)
      EndIf
      
      ; add the error to the log:
      LogLine$ = Line$
      While FindString(LogLine$, #NewLine, 1) <> 0
        pos = FindString(LogLine$, #NewLine, 1)
        Part$ = Left(LogLine$, pos-1)
        LogLine$ = Right(LogLine$, Len(LogLine$)-pos-(Len(#NewLine)-1))
        
        Debugger_AddLog_BySource(*ActiveSource, "[COMPILER] "+Part$, Date())
      Wend
      Debugger_AddLog_BySource(*ActiveSource, "[COMPILER] "+LogLine$, Date())
      
      ; display the macro window
      If IsMacroError
        DisplayMacroError(MacroLine, MacroLines())
      EndIf
      
      ; now the message
      If DisplayErrorWindow
        MessageRequester(#ProductName$, Line$, #FLAG_Error)
      EndIf
      
      If IsWindow(#WINDOW_MacroError)
        SetActiveWindow(#WINDOW_MacroError)
        SetActiveGadget(#GADGET_MacroError_Close)
      Else
        ActivateMainWindow() ; to show selection
      EndIf
    EndIf
    
  ElseIf Left(Response$, 6) = "ERROR"+Chr(9) ; assembler, linker or resource error
    Select StringField(Response$, 2, Chr(9))
      Case "ASSEMBLER": Type$ = "Assembler error"
      Case "LINKER"   : Type$ = "Linker error"
      Case "RESOURCE" : Type$ = "Resource error"
    EndSelect
    
    If CommandlineBuild = 0
      HideCompilerWindow()
    EndIf    
    
    If CommandlineBuild
      PrintN(Type$)
      Repeat
        Response$ = CompilerRead()
        
        If Response$ = "OUTPUT"+Chr(9)+"COMPLETE"
          Break
        Else
          PrintN(Response$)
        EndIf
      ForEver
      
    ElseIf UseProjectBuildWindow
      BuildLogEntry(Type$)
      
      Repeat
        Response$ = CompilerRead()
        
        If Response$ = "OUTPUT"+Chr(9)+"COMPLETE"
          Break
        Else
          BuildLogEntry(Response$)
        EndIf
      ForEver
      
    Else
      Debugger_AddLog_BySource(*ActiveSource, "[COMPILER] "+Type$+"!", Date())
      
      NbLines = 0
      Message$ = ""
      Repeat
        Response$ = CompilerRead()
        
        If Response$ = "OUTPUT"+Chr(9)+"COMPLETE"
          Break
        Else
          NbLines + 1
          If NbLines < 8 ; Max 8 lines or it can be too big to display for the MessageRequester()
            Message$ + Response$ + #NewLine
          EndIf
          
          LastLine$ = Response$
        EndIf
      ForEver
      
      If NbLines > 8
        Message$ + "..." + #NewLine + LastLine$ ; Add the last line if it has been truncated, as it can be useful
      EndIf
      
      MessageRequester(#ProductName$ + " - "+Type$, Message$, #FLAG_ERROR)
      ActivateMainWindow()
    EndIf
    
  EndIf
  
  ProcedureReturn #False
EndProcedure

Procedure.s Compiler_BuildCommandFlags(*Target.CompileTarget, CheckSyntax, CreateExe)
  If *CurrentCompiler\VersionNumber >= 430 Or #SpiderBasic
    Command$ = "COMPILE"+Chr(9)+"PROGRESS"+Chr(9)+"WARNINGS" ; use the progress and warnings flag always
  Else
    Command$ = "COMPILE"+Chr(9)+"PROGRESS"  ; no warning support on older compilers
  EndIf
  
  If *Target\EnableThread  : Command$ + Chr(9) + "THREAD"    : EndIf
  
  If *Target\Optimizer  : Command$ + Chr(9) + "OPTIMIZER" : EndIf

  CompilerIf #SpiderBasic
    
    Select *Target\AppFormat
      Case #AppFormatWeb ; Can be also when using Compile/Run
        If CreateExe
          If *Target\WebAppEnableDebugger
            Command$ + Chr(9) + "DEBUGGER"
          EndIf
        Else
          If (*Target\Debugger | ForceDebugger) & ~ForceNoDebugger ; Handle the special 'Compile with Debugger' and 'Compile without debugger' menus
            Command$ + Chr(9) + "DEBUGGER"
          EndIf
        EndIf
        
        
      Case #AppFormatiOS
        Command$ + Chr(9) + "IOS" ; Tell the compiler we are compiler and android package
        
        If *Target\iOSAppFullScreen : Command$ + Chr(9) + "FULLSCREEN" : EndIf
        If *Target\iOSAppAutoUpload : Command$ + Chr(9) + "DEPLOY" : EndIf
        If *Target\iOSAppEnableDebugger : Command$ + Chr(9) + "DEBUGGER" : EndIf
        If *Target\iOSAppKeepAppDirectory : Command$ + Chr(9) + "KEEPAPPDIR" : EndIf
        
      Case #AppFormatAndroid
        Command$ + Chr(9) + "ANDROID" ; Tell the compiler we are compiler and android package
        
        If *Target\AndroidAppFullScreen : Command$ + Chr(9) + "FULLSCREEN" : EndIf
        If *Target\AndroidAppAutoUpload : Command$ + Chr(9) + "DEPLOY" : EndIf
        If *Target\AndroidAppEnableDebugger : Command$ + Chr(9) + "DEBUGGER" : EndIf
        If *Target\AndroidAppKeepAppDirectory : Command$ + Chr(9) + "KEEPAPPDIR" : EndIf
        If *Target\AndroidAppInsecureFileMode : Command$ + Chr(9) + "INSECUREFILEMODE" : EndIf
        
    EndSelect
    
  CompilerEndIf
  
  If *Target\EnableOnError
    If #CompileWindows Or *CurrentCompiler\VersionNumber >= 430
      ; Windows only before 4.30
      Command$ + Chr(9) + "ONERROR"
    EndIf
  EndIf
  
  CompilerIf #CompileMac | #CompileWindows | #SpiderBasic
    If *Target\DPIAware : Command$ + Chr(9) + "DPIAWARE" : EndIf
  CompilerEndIf
  
  CompilerIf #CompileWindows
    If *Target\EnableXP           : Command$ + Chr(9) + "XPSKIN"  : EndIf
    If *Target\DllProtection      : Command$ + Chr(9) + "DLLPROTECTION" : EndIf
    If *Target\SharedUCRT         : Command$ + Chr(9) + "SHAREDUCRT" : EndIf
    
    If *Target\EnableAdmin
      Command$ + Chr(9) + "ADMINISTRATOR"
    ElseIf *Target\EnableUser ; both at once is impossible
      Command$ + Chr(9) + "USER"
    EndIf
  CompilerEndIf
  
  CompilerIf #CompileLinux
    If *Target\EnableWayland : Command$ + Chr(9) + "WAYLAND" : EndIf
  CompilerEndIf
  
  CompilerIf Not #SpiderBasic
    ; We honor the console flag even for OSX/Linux as it can be useful combined with #PB_Compiler_ExecutableFormat (https://www.purebasic.fr/english/viewtopic.php?t=65478)
    If *Target\ExecutableFormat=1 : Command$ + Chr(9) + "CONSOLE" : EndIf

    If (*Target\Debugger|ForceDebugger)&~ForceNoDebugger
      Command$ + Chr(9) + "DEBUGGER"
      IsDebuggerUsed = 1
      
      If *Target\EnablePurifier
        Command$ + Chr(9) + "PURIFIER"
      EndIf
    Else
      IsDebuggerUsed = 0
    EndIf
  CompilerEndIf
  
  Select *Target\CPU
    Case 1
      Command$ + Chr(9) + "DYNAMICCPU"
    Case 2
      Command$ + Chr(9) + "MMX"
    Case 3
      Command$ + Chr(9) + "3DNOW"
    Case 4
      Command$ + Chr(9) + "SSE"
    Case 5
      Command$ + Chr(9) + "SSE2"
  EndSelect
  
  If CheckSyntax
    Command$ + Chr(9) + "CHECKSYNTAX"
  EndIf
  
  ProcedureReturn Command$
EndProcedure


Procedure Compiler_SetConstants(*Target.CompileTarget, CreateExe)
  
  ; Do the IDE build constants
  ;
  If *Target\UseCreateExe
    If CreateExe
      CompilerWrite("CONSTANT"+Chr(9)+"PB_Editor_CreateExecutable=1")
    Else
      CompilerWrite("CONSTANT"+Chr(9)+"PB_Editor_CreateExecutable=0")
    EndIf
  EndIf
  
  ; Note: the increment for these counts is done after successful compilation only
  ;       (in CompilerWindow.pb, where MainFile etc are handled)
  If *Target\UseCompileCount
    CompilerWrite("CONSTANT"+Chr(9)+"PB_Editor_CompileCount=" + Str(*Target\CompileCount))
  EndIf
  
  If *Target\UseBuildCount
    CompilerWrite("CONSTANT"+Chr(9)+"PB_Editor_BuildCount=" + Str(*Target\BuildCount))
  EndIf
  
  CompilerIf #CompileWindows
    If *Target\VersionInfo
      CompilerWrite("CONSTANT"+Chr(9)+"PB_Editor_FileVersionNumeric="     + ReplaceVersionInfo(*Target\VersionField$[0], *Target), #PB_UTF8)
      CompilerWrite("CONSTANT"+Chr(9)+"PB_Editor_ProductVersionNumeric="  + ReplaceVersionInfo(*Target\VersionField$[1], *Target), #PB_UTF8)
      CompilerWrite("CONSTANT"+Chr(9)+"PB_Editor_CompanyName="            + ReplaceVersionInfo(*Target\VersionField$[2], *Target), #PB_UTF8)
      CompilerWrite("CONSTANT"+Chr(9)+"PB_Editor_ProductName="            + ReplaceVersionInfo(*Target\VersionField$[3], *Target), #PB_UTF8)
      CompilerWrite("CONSTANT"+Chr(9)+"PB_Editor_ProductVersion="         + ReplaceVersionInfo(*Target\VersionField$[4], *Target), #PB_UTF8)
      CompilerWrite("CONSTANT"+Chr(9)+"PB_Editor_FileVersion="            + ReplaceVersionInfo(*Target\VersionField$[5], *Target), #PB_UTF8)
      CompilerWrite("CONSTANT"+Chr(9)+"PB_Editor_FileDescription="        + ReplaceVersionInfo(*Target\VersionField$[6], *Target), #PB_UTF8)
      CompilerWrite("CONSTANT"+Chr(9)+"PB_Editor_InternalName="           + ReplaceVersionInfo(*Target\VersionField$[7], *Target), #PB_UTF8)
      CompilerWrite("CONSTANT"+Chr(9)+"PB_Editor_OriginalFilename="       + ReplaceVersionInfo(*Target\VersionField$[8], *Target), #PB_UTF8)
      CompilerWrite("CONSTANT"+Chr(9)+"PB_Editor_LegalCopyright="         + ReplaceVersionInfo(*Target\VersionField$[9], *Target), #PB_UTF8)
      CompilerWrite("CONSTANT"+Chr(9)+"PB_Editor_LegalTrademarks="        + ReplaceVersionInfo(*Target\VersionField$[10], *Target), #PB_UTF8)
      CompilerWrite("CONSTANT"+Chr(9)+"PB_Editor_PrivateBuild="           + ReplaceVersionInfo(*Target\VersionField$[11], *Target), #PB_UTF8)
      CompilerWrite("CONSTANT"+Chr(9)+"PB_Editor_SpecialBuild="           + ReplaceVersionInfo(*Target\VersionField$[12], *Target), #PB_UTF8)
      CompilerWrite("CONSTANT"+Chr(9)+"PB_Editor_Email="                  + ReplaceVersionInfo(*Target\VersionField$[13], *Target), #PB_UTF8)
      CompilerWrite("CONSTANT"+Chr(9)+"PB_Editor_Website="                + ReplaceVersionInfo(*Target\VersionField$[14], *Target), #PB_UTF8)
    EndIf
  CompilerEndIf
  
  ; Do custom constants. All constants are written in UTF-8 format to preserve complex string value (https://www.purebasic.fr/english/viewtopic.php?f=4&t=63159&sid=0f541e4670f96083c28f005df6f8d2b7)
  ;
  For i = 0 To *Target\NbConstants-1
    If *Target\ConstantEnabled[i]
      Original$ = *Target\Constant$[i]
      Constant$ = ""
      
      ; Replace all $XXX with environment variables
      ;
      *Pointer.Character = @Original$
      While *Pointer\c
        If *Pointer\c = '$'
          *Pointer + SizeOf(Character)
          Name$ = ""
          While *Pointer\c < $FF And ValidCharacters(*Pointer\c)
            Name$ + Chr(*Pointer\c)
            *Pointer + SizeOf(Character)
          Wend
          
          Constant$ + GetEnvironmentVariable(Name$)
        Else
          Constant$ + Chr(*Pointer\c)
          *Pointer  + SizeOf(Character)
        EndIf
      Wend
      
      ; Now cut the # at the start (not expected by the compiler) and any
      ; space before the name or =
      ;
      equal = FindString(Constant$, "=", 1)
      If equal > 0
        Constant$ = Trim(RemoveString(Left(Constant$, equal-1), "#")) + "=" + Trim(LTrim(Right(Constant$, Len(Constant$)-equal)), #DQUOTE$) ; Also remove the "" around, as expected by the compiler (https://www.purebasic.fr/english/viewtopic.php?f=4&t=59430)
        
        CompilerWrite("CONSTANT"+Chr(9)+Constant$, #PB_UTF8)
      EndIf
    EndIf
  Next i
  
EndProcedure

; ---------------------------------------------------------------------

CompilerIf #SpiderBasic
  Procedure.l GetIPByHost(Host$="")
    Result.l=0
    
    If Host$=""
      Host$=Hostname()
    EndIf
    
    SelfLoop=OpenNetworkConnection(Host$,0,#PB_Network_UDP)
    If SelfLoop
      Result=GetClientIP(SelfLoop)
      CloseNetworkConnection(SelfLoop)
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  Procedure.s StringToUTF8String(String$)
    *UTF8 = UTF8(String$)
    UTF8$ = PeekS(*UTF8, #PB_All, #PB_Ascii)
    FreeMemory(*UTF8)
    
    ProcedureReturn UTF8$
  EndProcedure
CompilerEndIf

; ---------------------------------------------------------------------

Procedure Compiler_Run(*Target.CompileTarget, IsFirstRun)
  CompilerIf #CompileLinux
    Shared DetectedGUITerminal$, GUITerminalParameters$ ; for the debugger (shared from LinuxMisc.pb)
  CompilerEndIf
  
  CompilerIf #CompileMac And Not #SpiderBasic
    If *Target\ExecutableFormat = 1 ; Console
      Executable$ = *Target\RunExecutable$
    Else
      Executable$ = *Target\RunExecutable$ + "/Contents/MacOS/" + Left(GetFilePart(*Target\RunExecutable$), Len(GetFilePart(*Target\RunExecutable$))-4)
    EndIf
  CompilerElse
    Executable$ = *Target\RunExecutable$
  CompilerEndIf
  
  ; Check if the executable is still present
  ;
  If FileSize(Executable$) <= 0
    Debug "NOT FOUND "+FileSize(Executable$)
    ; recompile the whole thing, but only if we did not just do so to
    ; avoid a possible endless compilation loop (unlikely)
    If IsFirstRun = #False
      If *Target\IsProject
        CompileRunProject(#False) ; call the CompilerWindow.pb one which does all handling correctly (also the compilecount)
      Else
        CompileRun(#False)
      EndIf
    EndIf
    ProcedureReturn
  EndIf
  
  ; get the current directory for the exe
  ;
  If *Target\CurrentDirectory$ <> "" ; a special one has been selected
    If *Target\IsProject
      Directory$ = ResolveRelativePath(GetPathPart(ProjectFile$), *Target\CurrentDirectory$)
    ElseIf *Target\FileName$ = ""
      Directory$ = ResolveRelativePath(CurrentDirectory$, *Target\CurrentDirectory$)
    Else
      Directory$ = ResolveRelativePath(GetPathPart(*Target\FileName$), *Target\CurrentDirectory$)
    EndIf
  Else
    If *Target\FileName$ = ""
      Directory$ = CurrentDirectory$
    Else
      Directory$ = GetPathPart(*Target\FileName$)
    EndIf
  EndIf
  
  ; Add the Compiler directory to the (library-)path, so the 3D engine and other
  ; libraries can be loaded by the exe
  ;
  NewPath$ = *Target\RunCompilerPath$
  
  CompilerIf #CompileWindows
    PreviousPath$ = GetEnvironmentVariable("PATH")
    If PreviousPath$ ; Only combine if the previous path isn't empty, or it will add the current dir as well (https://www.purebasic.fr/english/viewtopic.php?t=71355)
      NewPath$ + ";" + PreviousPath$
    EndIf
    SetEnvironmentVariable("PATH", NewPath$)
  CompilerEndIf
  
  CompilerIf #CompileLinux
    PreviousPath$ = GetEnvironmentVariable("LD_LIBRARY_PATH")
    If PreviousPath$ ; Only combine if the previous path isn't empty, or it will add the current dir as well (https://www.purebasic.fr/english/viewtopic.php?t=71355)
      NewPath$ + ":" + PreviousPath$
    EndIf
    SetEnvironmentVariable("LD_LIBRARY_PATH", NewPath$)
  CompilerEndIf
  
  CompilerIf #CompileMac
    PreviousPath$ = GetEnvironmentVariable("DYLD_LIBRARY_PATH")
    If PreviousPath$ ; Only combine if the previous path isn't empty, or it will add the current dir as well (https://www.purebasic.fr/english/viewtopic.php?t=71355)
      NewPath$ + ":" + PreviousPath$
    EndIf
    SetEnvironmentVariable("DYLD_LIBRARY_PATH", NewPath$)
  CompilerEndIf
  
  Debug "----"
  Debug "Filename   = " + *ActiveSource\Filename$
  Debug "CurrentDir = " + *ActiveSource\CurrentDirectory$
  Debug "Directory  = " + Directory$
  Debug "----"
  
  CompilerIf #SpiderBasic
    Static NewMap WebLaunchedServers.s()
    Static WebServerPortIndex = 0
    
    RootPath$ = GetPathPart(Executable$)
    If Right(RootPath$, 1) = "\" ; And Mid(RootPath$, 2, 1) <> ":"; mongoose doesn't like path terminated with "\", except for root drive (E:\)
      RootPath$ = Left(RootPath$, Len(RootPath$)-1)
    EndIf
    
    If WebLaunchedServers(RootPath$) = "" Or (*Target\WebServerAddress$ And WebLaunchedServers(RootPath$) <> *Target\WebServerAddress$) ; Not yet launched or the server port has been changed in the target
      
      If *Target\WebServerAddress$
        WebServerAddress$ = *Target\WebServerAddress$
        MongooseAddress$ = WebServerAddress$
        
        ; We need to resolve the hostname, as sbmongoose only access real IP address, not hostname
        ;
        If FindString(WebServerAddress$, ":")
          ServerName$ = StringField(WebServerAddress$, 1, ":")
          
          If Val(ServerName$) = 0 ; Checks if it start with a number <> 0. A name will returns 0
            IP = GetIPByHost(ServerName$) ; works with IP as well
            If IP
              MongooseAddress$ = IPString(IP)
              Port$ = StringField(WebServerAddress$, 2, ":")
              If Port$
                MongooseAddress$ + ":" + Port$
              EndIf
            EndIf
          EndIf
        Else
          MessageRequester("Error", "Invalid server address ("+ WebServerAddress$ + "). It should be specified as 'address:port'", #FLAG_Error)
          Error = #True
        EndIf
        
      Else
        WebServerAddress$ = "127.0.0.1:" + Str(OptionWebServerPort + WebServerPortIndex)
        MongooseAddress$ = WebServerAddress$
      EndIf
      
      ; Check than no server use this adress already (ie: 2 different sources  with the same *Target\WebServerAddress$
      ForEach WebLaunchedServers()
        If WebLaunchedServers() = WebServerAddress$
          MessageRequester("Error", "Invalid server address ("+ WebServerAddress$ + "). This adress is already in use in another spiderbasic source.", #FLAG_Error)
          Error = #True
        EndIf
      Next
      
      If Error = #False
        CompilerIf #CompileWindows
          ; Note: sbmongoose support UNICODE path on Windows, but it needs to be put on the commandline as UTF8
          ;
          RootPath$ = StringToUTF8String(RootPath$)
          PureBasicPath$ = StringToUTF8String(PureBasicPath$)
        CompilerEndIf
        
        Debug "Mongoose address: " + MongooseAddress$
        Debug "Mongoose document_root: " + RootPath$
        Debug "Mongoose spiderbasic_root: " + PureBasicPath$
        
        MongooseProgram = RunProgram(PureBasicPath$ + "compilers/sbmongoose", " -listening_ports " + MongooseAddress$ +
                                                                              " -document_root "+#DQUOTE$+RootPath$+#DQUOTE$ +
                                                                              " -spiderbasic_root "+#DQUOTE$+ReplaceString(PureBasicPath$, "\", "/")+#DQUOTE$, "", #PB_Program_Open | #PB_Program_Hide | #PB_Program_Read | #PB_Program_Ascii)
        ; Ensures mongoose is properly started
        MongooseStarted = #False        
        If ProgramRunning(MongooseProgram)
          Line$ = ReadProgramString(MongooseProgram) ; Blocking call
          If Left(Line$, 33) = "Mongoose web server v.4.2 started"
            MongooseStarted = #True
          EndIf
        EndIf
        
        If MongooseStarted
          AddElement(OpenedWebServers())
          OpenedWebServers() = MongooseProgram
          
          ; Increase the port index for the next program
          WebServerPortIndex+1

          WebLaunchedServers(RootPath$) = WebServerAddress$
        Else
          CloseProgram(MongooseProgram)
          MessageRequester("Error", "Can't start mongoose on address "+WebServerAddress$+" (may be the port '"+Str(OptionWebServerPort + WebServerPortIndex)+"' is in use)", #FLAG_Error)
        EndIf
      EndIf
    EndIf
    
    
    If Error = #False
      
      Url$ = "http://"+WebLaunchedServers(RootPath$)+"/" + GetFilePart(Executable$) + "?t=" + Date()
      
      ; Clear all the remaining 'red' error lines before launching a new app
      ;
      ForEach FileList()
        ClearErrorLines(@FileList()) ; clear the errors in all lines
      Next FileList()
      ChangeCurrentElement(FileList(), *ActiveSource)
    
      If WebViewOpen
        
        ; Setup the debugger. We can only have one in SpiderBasic
        If *WebViewDebugger = 0
          AddElement(RunningDebuggers()) ; Use the RunningDebuggers() list, so every window debugger events will be handled automatically
          *WebViewDebugger = @RunningDebuggers()
        EndIf
        
        ; Run the app in the built-in webview
        ;
        SetWebViewUrl(Url$)
        
      Else
        
        OpenSpiderWebBrowser(Url$)
        
      EndIf
      
    EndIf
    
  CompilerElse
    ; now execute the executable with the selected debugger (if any)
    If *Target\RunDebuggerMode
      
      ; get the correct debugger type
      ;
      If *Target\CustomDebugger
        LocalDebuggerMode = *Target\DebuggerType
      Else
        LocalDebuggerMode = DebuggerMode
      EndIf
      
      ; With the multiple compiler support, we can only use the IDE debugger if
      ; the Version matches (we ignore alpha/beta version), as otherwise the debugger
      ; communication is probably incompatible (use the external debugger then)
      ;
      If LocalDebuggerMode = 1 And *Target\RunCompilerVersion <> DefaultCompiler\VersionNumber
        LocalDebuggerMode = 2 ; standalone
      EndIf
      
      ; get correct gui debugger (may also be needed as fallback for IDE debugger!)
      ;
      CompilerIf #CompileWindows
        If *Target\RunCompilerVersion < 530 ; since 5.30 the main debugger is unicode
          DebuggerExe$ = *Target\RunCompilerPath$+"pbdebuggerunicode.exe"
        Else
          DebuggerExe$ = *Target\RunCompilerPath$+"pbdebugger.exe"
        EndIf
        DebuggerParams$ = ""
      CompilerEndIf
      
      CompilerIf #CompileLinux
        If *Target\RunCompilerVersion < 530 ; since 5.30 the main debugger is unicode
          DebuggerExe$ = *Target\RunCompilerPath$+"pbdebuggerunicode"
        Else
          DebuggerExe$ = *Target\RunCompilerPath$+"pbdebugger"
        EndIf
        
        If *Target\RunExeFormat = 1 And DetectedGUITerminal$ <> ""  ; this is for the standalone debugger
          DebuggerParams$ = GUITerminalParameters$ + #DQUOTE$+DebuggerExe$+#DQUOTE$
          DebuggerExe$ = DetectedGUITerminal$
        Else
          DebuggerParams$ = ""
        EndIf
      CompilerEndIf
      
      CompilerIf #CompileMac
        DebuggerExe$ = *Target\RunCompilerPath$+"pbdebugger.app/Contents/MacOS/pbdebugger"
        
        ;       If LocalDebuggerMode <> 2 And LocalDebuggerMode <> 3 ; OSX-debug
        ;         LocalDebuggerMode = 2 ; there is no integrated debugger on OSX, so ensure that it cannot be called
        ;       EndIf
        
        If *Target\ExecutableFormat = 1 ; this is for the Standalone Debugger
          DebuggerParams$ = "-a Terminal.app " +#DQUOTE$+DebuggerExe$+#DQUOTE$
          DebuggerExe$ = "open"
        Else
          DebuggerParams$ = ""
        EndIf
      CompilerEndIf
      
      Select LocalDebuggerMode
          
        Case 1 ; ide debugger
          
          ; Vista admin tools must run in the standalone debugger
          ;
          CompilerIf #CompileWindows
            If *Target\RunEnableAdmin And OSVersion() >= #PB_OS_Windows_Vista And IsAdmin() = 0 ; Fallback only if we are not admin (https://www.purebasic.fr/english/viewtopic.php?f=4&t=50571&p=385348#p385348)
              ExecuteStandaloneDebugger(*Target, DebuggerExe$, Executable$, Directory$, DebuggerParams$)
              ProcedureReturn
            EndIf
          CompilerEndIf
          
          *OldDebugger.DebuggerData = GetDebuggerForFile(*ActiveSource) ; use the *ActiveSource here (also handles projects properly)
          If *OldDebugger And *OldDebugger\CanDestroy = 0
            If MessageRequester(#ProductName$,Language("Debugger","IsRunning")+#NewLine+Language("Debugger","IsRunning2"), #PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
              ExecuteStandaloneDebugger(*Target, DebuggerExe$, Executable$, Directory$, DebuggerParams$)
            EndIf
          Else
            ; do remove the old debugger, if it had finished executing...
            If *OldDebugger And *OldDebugger\CanDestroy
              Debugger_ForceDestroy(*OldDebugger)
            EndIf
            
            CompilerIf #CompileWindows
              *Debugger.DebuggerData = Debugger_ExecuteProgram(Executable$, *Target\CommandLine$, Directory$)
              
            CompilerElse
              If *Target\RunExeFormat = 1
                DebuggerUseFIFO = 1
                CompilerIf #CompileLinux
                  *Debugger.DebuggerData = Debugger_ExecuteProgram(DetectedGUITerminal$, GUITerminalParameters$ +#DQUOTE$+Executable$+#DQUOTE$+ " " + *Target\CommandLine$, Directory$)
                CompilerElse
                  *Debugger.DebuggerData = Debugger_ExecuteProgram("open", "-a Terminal.app " +#DQUOTE$+Executable$+#DQUOTE$+ " --args " + *Target\CommandLine$, Directory$)
                CompilerEndIf
              Else
                DebuggerUseFIFO = 0
                *Debugger.DebuggerData = Debugger_ExecuteProgram(Executable$, *Target\CommandLine$, Directory$)
              EndIf
            CompilerEndIf
            
            If *Debugger = 0
              MessageRequester(#ProductName$,Language("Debugger","ExecuteError"), #FLAG_Error)
            Else
              ; link the debugger with the source (only if no mainfile was used!)
              If *Target\IsProject
                *Debugger\SourceID        = 0
                *Debugger\TriggerTargetID = *Target\ID
                ProjectDebuggerID         = *Debugger\ID
                
              ElseIf *Target\RunMainFileUsed = 0
                *Debugger\SourceID        = *ActiveSource\ID
                *Debugger\TriggerTargetID = *ActiveSource\ID
                *ActiveSource\DebuggerID  = *Debugger\ID
              Else
                *Debugger\SourceID        = 0
                *Debugger\TriggerTargetID = *ActiveSource\ID
                *ActiveSource\DebuggerID  = 0
              EndIf
              
              *Debugger\FileName$ = *Target\RunSourceFileName$
              ChangeStatus(Language("Debugger","Waiting"), -1)
              Debugger_AddLog(*Debugger, Language("Debugger","Waiting"), Date())
              SetDebuggerMenuStates()
              
              If IsDebuggerTimer = 0 ; Was no debugger before, activate the timer to check incoming commands
                Debug "[Activate debugger timer]"
                AddWindowTimer(#WINDOW_Main, #TIMER_DebuggerProcessing, 20) ; check every 20 ms
                IsDebuggerTimer = 1
              EndIf
              
            EndIf
          EndIf
          
        Case 2 ; standalone debugger
          Debug DebuggerExe$
          ExecuteStandaloneDebugger(*Target, DebuggerExe$, Executable$, Directory$, DebuggerParams$)
          
        Case 3 ; console debugger
          CompilerIf #CompileWindows
            RunProgram(Executable$, *Target\CommandLine$, Directory$)
          CompilerEndIf
          
          CompilerIf #CompileLinux
            RunProgram(DetectedGUITerminal$, GUITerminalParameters$ +#DQUOTE$+Executable$+#DQUOTE$+ " " + *Target\CommandLine$, Directory$)
          CompilerEndIf
          
          CompilerIf #CompileMac
            RunProgram("open", "-a Terminal.app " +#DQUOTE$+Executable$+#DQUOTE$+ " --args " + *Target\CommandLine$, Directory$)
          CompilerEndIf
          
      EndSelect
      
    Else  ; normal execute of the program
      
      CompilerIf #CompileWindows
        RunProgram(Executable$, *Target\CommandLine$, Directory$)
      CompilerEndIf
      
      CompilerIf #CompileLinux
        If *Target\RunExeFormat = 1 And DetectedGUITerminal$ <> ""
          RunProgram(DetectedGUITerminal$, GUITerminalParameters$ +#DQUOTE$+Executable$+#DQUOTE$+ " " + *Target\CommandLine$, Directory$)
        Else
          RunProgram(Executable$, *Target\CommandLine$, Directory$)
        EndIf
      CompilerEndIf
      
      CompilerIf #CompileMac
        ; On OS X, "open" launch automatically the 'Terminal' application, which is just perfect in our case
        If *Target\ExecutableFormat = 1
          RunProgram("open", "-a Terminal.app "+#DQUOTE$+ Executable$ +#DQUOTE$+ " --args " + *Target\CommandLine$, Directory$)
        Else
          RunProgram(Executable$, *Target\CommandLine$, Directory$)
        EndIf
      CompilerEndIf
      
    EndIf
    
  CompilerEndIf
  
  ; Reset the modified PATH environment variable, else we add a new compiler path
  ; every time a program is compiled
  ;
  CompilerIf #CompileWindows
    SetEnvironmentVariable("PATH", PreviousPath$)
  CompilerEndIf
  
  CompilerIf #CompileLinux
    SetEnvironmentVariable("LD_LIBRARY_PATH", PreviousPath$)
  CompilerEndIf
  
  CompilerIf #CompileMac
    SetEnvironmentVariable("DYLD_LIBRARY_PATH", PreviousPath$)
  CompilerEndIf
  
EndProcedure

; Generate a proper temporary filename for the target
;
Procedure.s Compiler_TemporaryFilename(*Target.CompileTarget)
  TargetFileName$ = ""
  
  If *Target\TemporaryExePlace And *Target\FileName$ <> ""
    BasePath$ = GetPathPart(*Target\FileName$)
  Else
    BasePath$ = TempPath$
  EndIf
  
  CompilerIf #SpiderBasic
    For i = 0 To 10000
      If FileSize(BasePath$+"SpiderBasic_Compilation"+Str(i)+".html") = -1
        TargetFileName$ = BasePath$+"SpiderBasic_Compilation"+Str(i)+".html"
        Break
      EndIf
    Next i
    
  CompilerElseIf #CompileWindows
    For i = 0 To 10000
      If FileSize(BasePath$+"PureBasic_Compilation"+Str(i)+".exe") = -1
        TargetFileName$ = BasePath$+"PureBasic_Compilation"+Str(i)+".exe"
        Break
      EndIf
    Next i
    
  CompilerElseIf #CompileLinux
    For i = 0 To 10000
      If FileSize(BasePath$+"purebasic_compilation"+Str(i)+".out") = -1
        TargetFileName$ = BasePath$+"purebasic_compilation"+Str(i)+".out"
        Break
      EndIf
    Next i
    
  CompilerElseIf #CompileMac
    For i = 0 To 10000
      ; this also shows in the menubar of the executed program, so choose a nicer name here :)
      If FileSize(BasePath$+"PureBasic."+Str(i)+".app") = -1
        TargetFileName$ = BasePath$+"PureBasic."+Str(i)
        If *Target\ExecutableFormat = 0 ; Application format
          TargetFileName$ + ".app"
        EndIf
        Break
      EndIf
    Next i
  CompilerEndIf
  
  ProcedureReturn TargetFileName$
EndProcedure

Procedure Compiler_CompileRun(SourceFileName$, *Source.SourceFile, CheckSyntax)
  
  ; Load the correct compiler + unicode mode and subsystem
  ;
  If Compiler_SetCompiler(*Source) = 0
    HideCompilerWindow()
    ActivateMainWindow()
    ProcedureReturn #False
  EndIf
  
  ; Select a proper output filename
  ; Note: we do not let the compiler choose one, as we need the full control
  ;       over the files even if the compiler is restarted.
  ;
  ; Ckean the *ActiveSource here for the MainFile option!
  ; This is for non-project only, so this is ok
  ;
  If *ActiveSource\RunExecutable$
    CompilerIf #SpiderBasic
      DeleteFile(*ActiveSource\RunExecutable$) ; An html file on all plateforms
    CompilerElse
      CompilerIf #CompileMac
        DeleteDirectory(*ActiveSource\RunExecutable$, "*", #PB_FileSystem_Recursive) ; a .app is a directory!
      CompilerElse
        DeleteFile(*ActiveSource\RunExecutable$)
      CompilerEndIf
    CompilerEndIf
    *ActiveSource\RunExecutable$ = ""
  EndIf
  
  TargetFileName$ = Compiler_TemporaryFilename(*Source)
  
  If TargetFileName$ = ""
    HideCompilerWindow()
    ActivateMainWindow()
    ProcedureReturn #False
  EndIf
  
  ; We register for deletion even though it gets automatically deleted on
  ; recompilation/source close. Because if you compile the same code twice
  ; (while the first instance runs, with external debugger), we get two files
  ; with only one in our variable for deletion
  ;
  ; This has a protection against double filenames, so the list does not grow
  ; forever. (as we usually reuse the same name)
  ;
  RegisterDeleteFile(TargetFileName$)
  
  CompilerWrite("SOURCE"+Chr(9)+SourceFileName$, #COMPILER_FileFormat)
  CompilerWrite("TARGET"+Chr(9)+TargetFileName$, #COMPILER_FileFormat)
  
  If *Source\FileName$ <> ""
    CompilerWrite("INCLUDEPATH"+Chr(9)+GetPathPart(*Source\FileName$), #COMPILER_FileFormat)
    
    If *Source\FileName$ <> SourceFileName$
      CompilerWrite("SOURCEALIAS"+Chr(9)+*Source\FileName$, #COMPILER_FileFormat)
    EndIf
  EndIf
  
  If *Source\LinkerOptions$ <> ""
    CompilerWrite("LINKER"+Chr(9)+ResolveRelativePath(GetPathPart(*Source\FileName$), *Source\LinkerOptions$), #COMPILER_FileFormat)
  EndIf
  
  CompilerIf #CompileWindows
    ResourceFile$ = CreateResourceFile(*Source)
    If ResourceFile$
      CompilerWrite("RESOURCE"+Chr(9)+ResourceFile$, #COMPILER_FileFormat)
    EndIf
  CompilerEndIf
  
  CompilerIf Not #SpiderBasic
    CompilerIf #CompileWindows | #CompileMac
      If *Source\UseIcon
        CompilerWrite("ICON"+Chr(9)+ResolveRelativePath(GetPathPart(*Source\FileName$), *Source\IconName$), #COMPILER_FileFormat)
      EndIf
    CompilerEndIf
  CompilerEndIf
  
  CompilerIf #SpiderBasic
    *Source\AppFormat = #AppFormatWeb ; Reset the app format to Web to avoid app creation if we use compile/run after creating an app
    
    CompilerWriteStringValue("APPNAME", *Source\WebAppName$)
    CompilerWriteStringValue("WINDOWTHEME", *Source\WindowTheme$)
    CompilerWriteStringValue("GADGETTHEME", *Source\GadgetTheme$)
    
    If *Source\WebAppIcon$
      CompilerWriteStringValue("ICON", ResolveRelativePath(GetPathPart(*Source\FileName$), *Source\WebAppIcon$))
    EndIf
  CompilerEndIf
  
  Compiler_SetConstants(*Source, #False)
  
  CompilerWrite(Compiler_BuildCommandFlags(*Source, CheckSyntax, #False))
  
  ; Handles the error and progress display
  ; do not use *Source here as it might be the MainFile dummy!
  ; also hides the compiler window when done
  ;
  If Compiler_HandleCompilerResponse(*Source)
    ; set the run information, then simply call the run command from here to reduce code
    *ActiveSource\RunExecutable$     = TargetFileName$
    *ActiveSource\RunExeFormat       = *Source\ExecutableFormat
    *ActiveSource\RunDebuggerMode    = (*Source\Debugger|ForceDebugger)&~ForceNoDebugger
    *ActiveSource\RunEnableAdmin     = *Source\EnableAdmin
    *ActiveSource\RunSourceFileName$ = *Source\FileName$
    *ActiveSource\RunCompilerPath$   = GetPathPart(*CurrentCompiler\Executable$)
    *ActiveSource\RunCompilerVersion = *CurrentCompiler\VersionNumber
    
    If *Source = @CompileFile ; if this is true, the mainfile option is used
      *ActiveSource\RunMainFileUsed = 1
    Else
      *ActiveSource\RunMainFileUsed = 0
    EndIf
    
    ; execute any external tools
    AddTools_ExecutableName$ = TargetFileName$
    AddTools_Execute(#TRIGGER_AfterCompile, *ActiveSource)
    
    If CheckSyntax = #False
      Compiler_Run(*ActiveSource, #True) ; run the file
    Else
      Debugger_AddLog_BySource(*ActiveSource, "[COMPILER] Syntax check finished ("+Str(*ActiveSource\LastCompiledLines)+" lines)", Date())
    EndIf
    
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
  
EndProcedure


; Used for "Create Executable" and project targets
;
Procedure Compiler_BuildTarget(SourceFileName$, TargetFileName$, *Target.CompileTarget, CreateExe, CheckSyntax)
  
  ; Projects always resolve relative to the project file, not the main sourcefile
  If *Target\IsProject
    BasePath$ = GetPathPart(ProjectFile$)
  Else
    BasePath$ = GetPathPart(*Target\FileName$)
  EndIf
  
  ; Load the correct compiler + unicode mode and subsystem
  ;
  If Compiler_SetCompiler(*Target) = 0
    If CommandlineBuild = 0
      HideCompilerWindow()
      
      ; in build mode, the window stays open, so do not do this
      If UseProjectBuildWindow = 0
        ActivateMainWindow()
      EndIf
    EndIf
    
    ProcedureReturn #False
  EndIf
  
  CompilerIf #SpiderBasic
    If CreateExe
      Select *Target\AppFormat
          
        Case #AppFormatWeb
          
          AppName$    = *Target\WebAppName$
          Icon$       = *Target\WebAppIcon$
          AppDebugger = *Target\WebAppEnableDebugger
          
          
          CompilerWriteStringValue("JAVASCRIPTNAME", *Target\JavaScriptFilename$)
          
          If *Target\JavaScriptPath$
            CompilerWrite("JAVASCRIPTLIBRARYPATH"+Chr(9)+*Target\JavaScriptPath$)
          Else
            CompilerWrite("JAVASCRIPTLIBRARYPATH"+Chr(9)+"spiderbasic") ; default is spiderbasic/
          EndIf
          
          If *Target\CopyJavaScriptLibrary
            If *Target\JavaScriptPath$
              CompilerWrite("COPYJAVASCRIPTLIBRARYPATH"+Chr(9)+*Target\JavaScriptPath$)
            Else
              CompilerWrite("COPYJAVASCRIPTLIBRARYPATH"+Chr(9)+"spiderbasic") ; default path is spiderbasic
            EndIf
          EndIf
          
          If *Target\EnableResourceDirectory
            ResourceDirectory$ = *Target\ResourceDirectory$
          EndIf
          
        Case #AppFormatiOS
          
          TargetFileName$ = ResolveRelativePath(BasePath$, TargetFileName$) ; Ensures it's a fullpath
          
          AppName$      = *Target\iOSAppName$
          Icon$         = *Target\iOSAppIcon$
          AppVersion$   = *Target\iOSAppVersion$
          PackageID$    = *Target\iOSAppPackageID$
          StartupImage$ = *Target\iOSAppStartupImage$
          AppDebugger   = *Target\iOSAppEnableDebugger
          
          Select *Target\iOSAppOrientation ; Default case is Any, and we don't need to send it to the compiler
            Case 1
              Orientation$ = "PORTRAIT"
              
            Case 2
              Orientation$ = "LANDSCAPE"
          EndSelect
          
          If *Target\iOSAppEnableResourceDirectory
            ResourceDirectory$ = *Target\iOSAppResourceDirectory$
          EndIf
          
        Case #AppFormatAndroid
          
          TargetFileName$ = ResolveRelativePath(BasePath$, TargetFileName$) ; Ensures it's a fullpath, or APK creation can fail (http://forums.spiderbasic.com/viewtopic.php?f=11&t=892)
          
          AppName$      = *Target\AndroidAppName$
          Icon$         = *Target\AndroidAppIcon$
          AppVersion$   = *Target\AndroidAppVersion$
          PackageID$    = *Target\AndroidAppPackageID$
          StartupImage$ = *Target\AndroidAppStartupImage$
          AppDebugger   = *Target\AndroidAppEnableDebugger
          
          ; Android specific
          CompilerWriteStringValue("IAPKEY", *Target\AndroidAppIAPKey$)
          CompilerWriteStringValue("APPCODE", Str(*Target\AndroidAppCode))
          CompilerWriteStringValue("STARTUPCOLOR", *Target\AndroidAppStartupColor$)
              
          Select *Target\AndroidAppOrientation ; Default case is Any, and we don't need to send it to the compiler
            Case 1
              Orientation$ = "PORTRAIT"
              
            Case 2
              Orientation$ = "LANDSCAPE"
          EndSelect
          
          If *Target\AndroidAppEnableResourceDirectory
            ResourceDirectory$ = *Target\AndroidAppResourceDirectory$
          EndIf
          
      EndSelect
    Else
      AppName$ = *Target\WebAppName$ ; We always use the webapp appname when compile/run the app
      If *Target\WebAppIcon$
        Icon$ = ResolveRelativePath(BasePath$, *Target\WebAppIcon$)
      EndIf
    EndIf
    
    CompilerWriteStringValue("WINDOWTHEME", *Target\WindowTheme$)
    CompilerWriteStringValue("GADGETTHEME", *Target\GadgetTheme$)
    
    CompilerWriteStringValue("APPNAME", AppName$)
    CompilerWriteStringValue("ICON", Icon$)
    CompilerWriteStringValue("APPVERSION", AppVersion$)
    CompilerWriteStringValue("PACKAGEID", PackageID$)
    CompilerWriteStringValue("STARTUPIMAGE", StartupImage$)
    CompilerWriteStringValue("RESOURCEDIRECTORY", ResourceDirectory$)
    CompilerWriteStringValue("ORIENTATION", Orientation$)
    
  CompilerEndIf
  
  CompilerWrite("SOURCE"+Chr(9)+SourceFileName$, #COMPILER_FileFormat)
  CompilerWrite("TARGET"+Chr(9)+TargetFileName$, #COMPILER_FileFormat)
  
  If *Target\FileName$ <> ""
    ; do not use the BasePath$ here. Includes are always relative to the main file, not the project
    CompilerWrite("INCLUDEPATH"+Chr(9)+GetPathPart(*Target\FileName$), #COMPILER_FileFormat)
    
    If *Target\FileName$ <> SourceFileName$
      CompilerWrite("SOURCEALIAS"+Chr(9)+*Target\FileName$, #COMPILER_FileFormat)
    EndIf
  EndIf
  
  If *Target\LinkerOptions$ <> ""
    CompilerWrite("LINKER"+Chr(9)+ResolveRelativePath(BasePath$, *Target\LinkerOptions$), #COMPILER_FileFormat)
  EndIf
  
  CompilerIf #CompileWindows
    ResourceFile$ = CreateResourceFile(*Target)
    If ResourceFile$
      CompilerWrite("RESOURCE"+Chr(9)+ResourceFile$, #COMPILER_FileFormat)
    EndIf
  CompilerEndIf
  
  CompilerIf Not #SpiderBasic
    CompilerIf #CompileWindows | #CompileMac
      If *Target\UseIcon
        CompilerWrite("ICON"+Chr(9)+ResolveRelativePath(BasePath$, *Target\IconName$), #COMPILER_FileFormat)
      EndIf
    CompilerEndIf
  CompilerEndIf
  
  Compiler_SetConstants(*Target, CreateExe)
  
  Command$ = Compiler_BuildCommandFlags(*Target, CheckSyntax, CreateExe)
  
  CompilerIf Not #SpiderBasic
    If CreateExe Or *Target\ExecutableFormat = 2
      Command$ = RemoveString(Command$, Chr(9)+"DEBUGGER") ; ensure the debug flag is not set
    EndIf
  CompilerEndIf
  
  If *Target\ExecutableFormat = 2
    Command$ + Chr(9) + "DLL"
  EndIf
  
  CompilerIf Not #SpiderBasic
    CreateDirectoryRecursive(GetPathPart(TargetFileName$))
  CompilerEndIf
  
  CompilerWrite(Command$)
  
  ; We need the *ActiveSource for HandleCompilerResponse if the mainfile option is set
  If *Target = @CompileSource
    *Target = *ActiveSource
  EndIf
  
  ; Handles the error and progress display
  ; We do not care here if the compilation succeeded
  ;
  If Compiler_HandleCompilerResponse(*Target)
    
    ; Project targets run the tool outside of this function, so do it only for non-project
    ; (need to clean this up somewhen)
    ;
    If *Target\IsProject = 0
      AddTools_ExecutableName$ = TargetFileName$
      AddTools_Execute(#TRIGGER_AfterCreateExe, *Target)
    EndIf
    
    If CheckSyntax
      Debugger_AddLog_BySource(*ActiveSource, "[COMPILER] Syntax check finished ("+Str(*Target\LastCompiledLines)+" lines)", Date())
    EndIf
    
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure
