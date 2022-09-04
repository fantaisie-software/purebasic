; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

;- Build project from the commandline
;

Global NewList CommandlineTargetNames.s()
Global CommandLineProjectFile$ = ""
Global CommandLineBuildReadOnly

Procedure CommandlineProjectBuild()
  NewList *Targets.CompileTarget()
  NewList Summary.s()
  
  If LoadProject(CommandLineProjectFile$) ; error messages handled inside
    
    ; determine which targets to build
    ;
    If ListSize(CommandlineTargetNames()) = 0
      
      ; no targets given, build those that have "build all" option set
      ForEach ProjectTargets()
        If ProjectTargets()\IsEnabled
          AddElement(*Targets())
          *Targets() = @ProjectTargets()
        EndIf
      Next ProjectTargets()
      
      ; if still empty, use default target (one always exists, ensured by LoadProject)
      If ListSize(*Targets()) = 0
        AddElement(*Targets())
        *Targets() = *DefaultTarget
      EndIf
      
    Else
      
      ; compare names
      ForEach ProjectTargets()
        ForEach CommandlineTargetNames()
          If ProjectTargets()\Name$ = CommandlineTargetNames() ; case sensitive
            AddElement(*Targets())
            *Targets() = @ProjectTargets()
            DeleteElement(CommandlineTargetNames()) ; mark this one as found
            Break
          EndIf
        Next CommandlineTargetNames()
      Next ProjectTargets()
      
      ; print message for not found targets
      ForEach CommandlineTargetNames()
        PrintN(Language("Compiler", "TargetNotFound") + ": "+ CommandlineTargetNames())
      Next CommandlineTargetNames()
      
      If ListSize(*Targets()) = 0
        PrintN(Language("Compiler", "NoTargets"))
        ProcedureReturn
      EndIf
      
    EndIf
    
    
    ; need to wait for the default compiler to be ready
    ; as there is no check for it unless the compiler needs to be switched later
    If WaitForCompilerReady()
      
      ; build each target
      ClearList(BuildInfo())
      OldWarningCount = 0
      SuccessCount = 0
      FailCount = 0
      
      ForEach *Targets()
        If QuietBuild = 0
          PrintN(RSet("", 78, "-"))
          PrintN("  " + LanguagePattern("Compiler","BuildStart", "%target%", *Targets()\Name$))
          PrintN(RSet("", 78, "-"))
        EndIf
        
        Result$ = BuildProjectTarget(*Targets(), 0, #True, #False)
        
        ; count the emitted warnings during this compile
        WarningCount = 0
        ForEach BuildInfo()
          If BuildInfo()\IsWarning
            WarningCount + 1
          EndIf
        Next BuildInfo()
        
        If Result$ <> "" And WarningCount = OldWarningCount And QuietBuild = 0
          ; Failures are logged as errors and warnings give a "success with warnings" line, so add a line for success here too
          ; do this before executing the tools for a consistent log output
          PrintN(Language("Compiler","BuildSuccess"))
        EndIf
        
        ; Update the target's build counts and execute any tools
        If Result$ <> ""
          If *Targets()\UseCompileCount      ; this increases both compile+build count
            *Targets()\CompileCount + 1
          EndIf
          
          If *Targets()\UseBuildCount
            *Targets()\BuildCount + 1
          EndIf
          
          AddTools_ExecutableName$ = Result$
          AddTools_Execute(#TRIGGER_AfterCreateExe, *Targets())
        Else
          ; add an error message in quiet mode to correctly identify the target
          If QuietBuild
            PrintN("-- " + LanguagePattern("Compiler", "TargetBuildError", "%target%", *Targets()\Name$))
          EndIf
        EndIf
        
        AddElement(Summary())
        Summary() = "  " + LSet(*Targets()\Name$, 58)
        
        If Result$ = ""
          Summary() + "[ " + Language("Compiler","StatusError") + " ]"
          FailCount + 1
        ElseIf WarningCount > OldWarningCount
          Summary() + "[ " + LanguagePattern("Compiler","StatusWarning", "%count%", Str(WarningCount - OldWarningCount)) + " ]"
          SuccessCount + 1 ; this is a success too
        Else
          Summary() + "[ " + Language("Compiler","StatusOk") + " ]"
          SuccessCount + 1
        EndIf
        
        OldWarningCount = WarningCount
        If QuietBuild = 0
          PrintN("")
        EndIf
      Next *Targets()
      
      ; display stats
      If QuietBuild = 0
        PrintN(RSet("", 78, "-"))
        PrintN("")
        ForEach Summary()
          PrintN(Summary())
        Next Summary()
        PrintN("")
        
        If SuccessCount > 0
          PrintN("  " + LanguagePattern("Compiler", "BuildStatsNoError", "%count%", Str(SuccessCount)))
        EndIf
        If FailCount > 0
          PrintN("  " + LanguagePattern("Compiler", "BuildStatsError", "%count%", Str(FailCount)))
        EndIf
        If WarningCount > 0
          PrintN("  " + LanguagePattern("Compiler", "BuildStatsWarning", "%count%", Str(WarningCount)))
        EndIf
        If CompilationAborted
          PrintN("  " + Language("Compiler","BuildStatsAborted"))
        EndIf
        
        PrintN("")
      EndIf
      
      ; save project to update build counters if needed (show no errors on failure)
      If CommandLineBuildReadOnly = #False
        SaveProject(#False)
      EndIf
      
      If FailCount = 0
        CommandlineBuildSuccess = #True
      EndIf
      
    EndIf
    
  EndIf
  
EndProcedure

Procedure CommandlineVersion()
  OpenConsole()
  Version$ = #ProductName$+" IDE " + #BUILDINFO_Version
  Version$ + " [" + #BUILDINFO_Branch + "; " + #BUILDINFO_Revision + "; " + FormatDate("%dd-%mm-%yyyy]", #PB_Compiler_Date)
  Version$ + FormatDate(" - (c) %yyyy Fantaisie Software", #PB_Compiler_Date)
  PrintN(Version$)
  CloseConsole()
EndProcedure

Procedure CommandlineHelp()
  OpenConsole()
  
  CompilerIf #CompileWindows
    CompilerIf #SpiderBasic
      PrintN("Usage: spiderbasic [options] files...")
    CompilerElse
      PrintN("Usage: purebasic [options] files...")
    CompilerEndIf
    PrintN("")
    PrintN("Options:")
    PrintN("  /VERSION      Display version information and quit")
    PrintN("  /HELP or /?   Display commandline help")
    PrintN("")
    PrintN("Launching the IDE:")
    PrintN("  /P <file>      Specify a file for the IDE preferences")
    PrintN("  /T <file>      Specify a file for code templates")
    PrintN("  /A <file>      Specify a file for the tools settings")
    PrintN("  /H <file>      Specify a file for the session history database")
    PrintN("  /S <path>      Specify the initial path for source files")
    PrintN("  /E <path>      Specify the initial path for the explorer tool")
    PrintN("  /L <line>      Set the cursor to the given line")
    PrintN("  /NOEXT         Do not associate the PB extensions")
    PrintN("  /PORTABLE      Place all settings in the program folder")
    PrintN("")
    PrintN("Building Projects:")
    PrintN("  /BUILD <file>  Specify the project file to build")
    PrintN("  /TARGET <name> Specify a target to build")
    PrintN("  /QUIET         Only show errors during the build")
    PrintN("  /READONLY      Do not update the project file after the build")
    PrintN("")
  CompilerElse
    CompilerIf #SpiderBasic
      PrintN("Usage: spiderbasic [options] files...")
    CompilerElse
      PrintN("Usage: purebasic [options] files...")
    CompilerEndIf
    PrintN("")
    PrintN("Options:")
    PrintN("  -v or --version             Display version information and quit")
    PrintN("  -h or --help                Display commandline help")
    PrintN("")
    PrintN("Launching the IDE:")
    PrintN("  -p or --preferences <file>  Specify a file for the IDE preferences")
    PrintN("  -t or --templates <file>    Specify a file for code templates")
    PrintN("  -a or --tools <file>        Specify a file for the tools settings")
    PrintN("  -H or --history <file>      Specify a file for the session history database")
    PrintN("  -s or --sourcepath <path>   Specify the initial path for source files")
    PrintN("  -e or --explorerpath <path> Specify the initial path for the explorer tool")
    PrintN("  -l or --line <line>         Set the cursor to the given line")
    PrintN("")
    PrintN("Building Projects:")
    PrintN("  -b or --build <file>        Specify the project file to build")
    PrintN("  -T or --target <name>       Specify a target to build")
    PrintN("  -q or --quiet               Only show errors during the build")
    PrintN("  -r or --readonly            Do not update the project file after the build")
    PrintN("")
  CompilerEndIf
  
  CloseConsole()
EndProcedure


;- Parse commandline

; Parse commandline before anything else is initialized.
; this allows us to change the used settings with the commandline.
;
; Commandline arguments:
;
; ALL OS:
; -p <PreferenceFile>  or --preferences <PreferenceFile>
; -t <TemplatesFile>   or --templates <TemplatesFile>
; -a <ToolsFile>       or --tools <ToolsFile>
; -H <HistoryFile>     or --history <HistoryFile>
; -s <SourcePath>      or --sourcepath <SourcePath>
; -e <ExplorerPath>    or --explorerpath <Explorerpath>
; -l <Sourceline>      or --line <SourceLine>
; -b <ProjectFile>     or --build <ProjectFile>
; -T <target>          or --target <target>
; -q                   or --quiet
; -r                   or --readonly
; -h                   or --help
; -v                   or --version
;
;
; WINDOWS ONLY:
; /P <PreferenceFile>
; /T <TemplatesFile>
; /A <ToolsFile>
; /H <HistoryFile>
; /S <SourcePath>
; /E <ExplorerPath>
; /L <SourceLine> -> sets the 'current line' to the given number for the last open file. (requested in german forum)
; /NOEXT     disables the creation of the file extensions
; /PORTABLE  all prefs files are within the PB dir + /NOEXT for USB sticks etc
; /BUILD <project>
; /TARGET <target>
; /QUIET
; /READONLY
; /? or /HELP
; /VERSION

; We need the current directory to resolve the relative filenames...
;


; Returns true if editor should continue start up
;
Procedure ParseCommandline()
  CompilerIf #CompileWindows
    Shared DontCreateExtensions ; to tell the startup code not to modify the registry
  CompilerEndIf
  
  ; need the current directory to resolve names
  CurrentDirectory$ = GetCurrentDirectory()
  If Right(CurrentDirectory$, 1) <> #Separator
    CurrentDirectory$ + #Separator
  EndIf
  
  InitialSourceLine = -1 ; for the -l option
  
  ParameterCount = CountProgramParameters()
  For ParameterIndex = 0 To ParameterCount-1
    Parameter$  = ProgramParameter(ParameterIndex)
    
    ; alternative commandline arguments
    ;
    Select UCase(Parameter$)
        
        CompilerIf #CompileWindows ; these are windows only
        Case "/P": Parameter$ = "-p"
        Case "/T": Parameter$ = "-t"
        Case "/A": Parameter$ = "-a"
        Case "/H": Parameter$ = "-H"
        Case "/S": Parameter$ = "-s"
        Case "/E": Parameter$ = "-e"
        Case "/L": Parameter$ = "-l"
        Case "/BUILD"   : Parameter$ = "-b"
        Case "/TARGET"  : Parameter$ = "-T"
        Case "/QUIET"   : Parameter$ = "-q"
        Case "/READONLY": Parameter$ = "-r"
        Case "/HELP"    : Parameter$ = "-h"
        Case "/?"       : Parameter$ = "-h"
        Case "/VERSION" : Parameter$ = "-v"
        Case "/NOEXT"   : Parameter$ = "/NOEXT"    ; ensure uppercase
        Case "/PORTABLE": Parameter$ = "/PORTABLE" ; ensure uppercase
        Case "/LOCAL"   : Parameter$ = "/LOCAL"
        CompilerEndIf
        
      Case "--PREFERENCES": Parameter$ = "-p"
      Case "--TEMPLATES":   Parameter$ = "-t"
      Case "--TOOLS":       Parameter$ = "-a"
      Case "--HISTORY":     Parameter$ = "-H"
      Case "--SOURCEPATH":  Parameter$ = "-s"
      Case "--EXPLORERPATH":Parameter$ = "-e"
      Case "--LINE":        Parameter$ = "-l"
      Case "--BUILD":       Parameter$ = "-b"
      Case "--TARGET":      Parameter$ = "-T"
      Case "--QUIET":       Parameter$ = "-q"
      Case "--READONLY":    Parameter$ = "-r"
      Case "--HELP":        Parameter$ = "-h"
      Case "--VERSION":     Parameter$ = "-v"
        
    EndSelect
    
    Select Parameter$
        
      Case "-h"
        CommandlineHelp()
        End
        
      Case "-v"
        CommandlineVersion()
        End
        
      Case "-p"
        ParameterIndex + 1
        PreferencesFile$ = ResolveRelativePath(CurrentDirectory$, ProgramParameter(ParameterIndex))
        
      Case "-t"
        ParameterIndex + 1
        TemplatesFile$   = ResolveRelativePath(CurrentDirectory$, ProgramParameter(ParameterIndex))
        
      Case "-a"
        ParameterIndex + 1
        AddToolsFile$    = ResolveRelativePath(CurrentDirectory$, ProgramParameter(ParameterIndex))
        
      Case "-H"
        ParameterIndex + 1
        HistoryDatabaseFile$ = ResolveRelativePath(CurrentDirectory$, ProgramParameter(ParameterIndex))
        
      Case "-s"
        ParameterIndex + 1
        SourcePath$ = ResolveRelativePath(CurrentDirectory$, ProgramParameter(ParameterIndex))
        If Right(SourcePath$, 1) <> #Separator
          SourcePath$ + #Separator
        EndIf
        SourcePathSet = 1
        
      Case "-e"
        ParameterIndex + 1
        ExplorerPath$ = ResolveRelativePath(CurrentDirectory$, ProgramParameter(ParameterIndex))
        If Right(ExplorerPath$, 1) <> #Separator
          ExplorerPath$ + #Separator
        EndIf
        
      Case "-l"
        ParameterIndex + 1
        InitialSourceLine = Val(ProgramParameter(ParameterIndex))
        
      Case "-q"
        QuietBuild = #True
        
      Case "-r"
        CommandLineBuildReadOnly = #True
        
      Case "-b"
        CommandlineBuild = #True
        ParameterIndex + 1
        CommandLineProjectFile$ = ResolveRelativePath(CurrentDirectory$, ProgramParameter(ParameterIndex))
        
      Case "-T"
        ParameterIndex + 1
        AddElement(CommandlineTargetNames())
        CommandlineTargetNames() = Trim(ProgramParameter(ParameterIndex))
        
        CompilerIf #CompileWindows
        Case "/NOEXT"
          DontCreateExtensions = 1
          
        Case "/LOCAL"
          Directory$ = GetPathPart(ProgramFilename())
          PreferencesFile$ = Directory$ + #PreferenceFileName$
          TemplatesFile$   = Directory$ + "Templates.prefs"
          AddToolsFile$    = Directory$ + "Tools.prefs"
          HistoryDatabaseFile$ = Directory$ + "History.db"
          UpdateCheckFile$ = Directory$+ "UpdateCheck.xml"
          
        Case "/PORTABLE"
          DontCreateExtensions = 1  ; implies /NOEXT as well
          
          Directory$ = GetPathPart(ProgramFilename())
          PreferencesFile$ = Directory$ + #PreferenceFileName$
          TemplatesFile$   = Directory$ + "Templates.prefs"
          AddToolsFile$    = Directory$ + "Tools.prefs"
          HistoryDatabaseFile$ = Directory$ + "History.db"
          UpdateCheckFile$ = Directory$+ "UpdateCheck.xml"
          
        CompilerEndIf
        
      Case "" ; filter out the empty string
        
      Default ; parameter is interpreted as a filename or wildcard for filenames
        If FindString(Parameter$, "*", 1) = 0 And FindString(Parameter$, "?", 1) = 0
          AddElement(OpenFilesCommandline())
          OpenFilesCommandline() = ResolveRelativePath(CurrentDirectory$, Parameter$)
          
        Else
          Path$ = ResolveRelativePath(CurrentDirectory$, GetPathPart(Parameter$))
          If Right(Path$, 1) <> #Separator: Path$ + #Separator: EndIf
          If ExamineDirectory(0, Path$, GetFilePart(Parameter$))
            While NextDirectoryEntry(0)
              If DirectoryEntryType(0) = 1
                AddElement(OpenFilesCommandline())
                OpenFilesCommandline() = Path$ + DirectoryEntryName(0)
              EndIf
            Wend
            
            FinishDirectory(0)
          EndIf
          
        EndIf
        
    EndSelect
    
  Next ParameterIndex
  
  If UpdateCheckFile$ = ""
    UpdateCheckFile$ = PureBasicConfigPath() + "UpdateCheck.xml" ; Warning PureBasicConfigPath() create the directory if not exists, so don't call it if we use the /PORTABLE or /LOCAL flag
  EndIf
  
EndProcedure

