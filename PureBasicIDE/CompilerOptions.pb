; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


Procedure DisableOptionGadgets()
  
  If Options_IsProjectMode
    UseMainFile = #False ; do disable any of these options
  Else
    UseMainFile = GetGadgetState(#GADGET_Option_UseMainFile)
    DisableGadget(#GADGET_Option_MainFile,       1-UseMainFile)
    DisableGadget(#GADGET_Option_SelectMainFile, 1-UseMainFile)
  EndIf
  
  For Gadget = #GADGET_Option_UseCompiler To #GADGET_Option_ConstantLine
    DisableGadget(Gadget, UseMainFile)
  Next Gadget
  
  If UseMainFile = 0
    CompilerIf Not #SpiderBasic
      UseIcon = GetGadgetState(#GADGET_Option_UseIcon)
      DisableGadget(#GADGET_Option_IconName,   1-UseIcon)
      DisableGadget(#GADGET_Option_SelectIcon, 1-UseIcon)
    CompilerEndIf
    
    DisableGadget(#GADGET_Option_SelectCompiler, 1-GetGadgetState(#GADGET_Option_UseCompiler))
    DisableGadget(#GADGET_Option_CompileCount, 1-GetGadgetState(#GADGET_Option_UseCompileCount))
    DisableGadget(#GADGET_Option_BuildCount,   1-GetGadgetState(#GADGET_Option_UseBuildCount))
  EndIf
  
  CompilerIf Not #SpiderBasic
    
    CustomDebugger = GetGadgetState(#GADGET_Option_SelectDebugger)
    DisableGadget(#GADGET_Option_DebuggerMode, 1-CustomDebugger)
    
    If (CustomDebugger And GetGadgetState(#GADGET_Option_DebuggerMode) = 2) Or (CustomDebugger = 0 And DebuggerMode = 3)
      DisableGadget(#GADGET_Option_SelectWarning, 1)
      DisableGadget(#GADGET_Option_WarningMode, 1)
    Else
      DisableGadget(#GADGET_Option_SelectWarning, 0)
      DisableGadget(#GADGET_Option_WarningMode, 1-GetGadgetState(#GADGET_Option_SelectWarning))
    EndIf
    
  CompilerEndIf
  
  ; disable / enable the resource options
  CompilerIf #CompileWindows And Not #SpiderBasic
    DisableGadget(#GADGET_Option_IncludeVersion, UseMainFile)
    
    UseVersion = GetGadgetState(#GADGET_Option_IncludeVersion)
    For i = 0 To 23
      DisableGadget(#GADGET_Option_VersionValue0+i, (1-UseVersion)|UseMainFile)
    Next i
    
    DisableGadget(#GADGET_Option_ResourceList, UseMainFile)
    DisableGadget(#GADGET_Option_ResourceAdd, UseMainFile)
    DisableGadget(#GADGET_Option_ResourceRemove, UseMainFile)
    DisableGadget(#GADGET_Option_ResourceClear, UseMainFile)
    DisableGadget(#GADGET_Option_ResourceFile, UseMainFile)
    DisableGadget(#GADGET_Option_ResourceSelectFile, UseMainFile)
    
  CompilerEndIf
  
  ; always disable unsupported options on linux / mac
  
  CompilerIf #CompileLinux And Not #SpiderBasic ; Icon is supported only on windows
    DisableGadget(#GADGET_Option_UseIcon, 1)
    DisableGadget(#GADGET_Option_IconName, 1)
    DisableGadget(#GADGET_Option_SelectIcon, 1)
    DisableGadget(#GADGET_Option_DPIAware, 1)
  CompilerEndIf
  
  CompilerIf #CompileLinux | #CompileMac And Not #SpiderBasic ; this stuff is Windows only
    DisableGadget(#GADGET_Option_EnableXP, 1)
    DisableGadget(#GADGET_Option_EnableAdmin, 1)
    DisableGadget(#GADGET_Option_EnableUser, 1)
    DisableGadget(#GADGET_Option_DllProtection, 1)
    DisableGadget(#GADGET_Option_SharedUCRT, 1)
  CompilerEndIf
  
  CompilerIf Not #CompileLinux And Not #SpiderBasic ; this stuff is Linux only
    DisableGadget(#GADGET_Option_EnableWayland, 1)
  CompilerEndIf
  
EndProcedure

; get the list of enabled tools as it is stored in the structure/ide options
; (in uppercase, spaces replaced by '_', separated by comma)
;
Procedure.s CompilerWindow_EnabledToolsList()
  Result$ = ""
  
  For i = 0 To CountGadgetItems(#GADGET_Option_ToolsList)-1
    If GetGadgetItemState(#GADGET_Option_ToolsList, i) & #PB_ListIcon_Checked
      Result$ + ReplaceString(UCase(Trim(GetGadgetItemText(#GADGET_Option_ToolsList, i, 0))), " ", "_") + ","
    EndIf
  Next i
  
  If Len(Result$) > 0
    ProcedureReturn Left(Result$, Len(Result$)-1) ; cut last ","
  Else
    ProcedureReturn ""
  EndIf
EndProcedure


Procedure SetTargetOptions(*Target.CompileTarget)
  SetGadgetText(#GADGET_Option_MainFile, *Target\MainFile$)
  If Options_IsProjectMode
    SetGadgetText(#GADGET_Option_OutputFile, *Target\OutputFile$)
  Else
    SetGadgetState(#GADGET_Option_UseMainFile, *Target\UseMainFile)
  EndIf
  
  SetGadgetState(#GADGET_Option_UseCompiler, *Target\CustomCompiler)
  
  If *Target\CustomCompiler = #False
    SetGadgetState(#GADGET_Option_SelectCompiler, 0) ; that's the default compiler
  Else
    ; find a matching compiler
    *Compiler.Compiler = FindCompiler(*Target\CompilerVersion$)
    
    If *Compiler = 0
      MessageRequester(#ProductName$, Language("Compiler","CompilerNotFound")+":"+#NewLine+*Target\CompilerVersion$, #FLAG_Warning)
      SetGadgetState(#GADGET_Option_SelectCompiler, 0)
    ElseIf *Compiler = @DefaultCompiler
      SetGadgetState(#GADGET_Option_SelectCompiler, 0)
    Else
      ; one of them must match, as FindCompiler() returned something
      last = CountGadgetItems(#GADGET_Option_SelectCompiler)
      For index = 1 To last
        If GetGadgetItemData(#GADGET_Option_SelectCompiler, index) = *Compiler
          SetGadgetState(#GADGET_Option_SelectCompiler, index)
          Break
        EndIf
      Next index
    EndIf
  EndIf
  
  SetGadgetText(#GADGET_Option_SubSystem,   *Target\SubSystem$)
  
  SetGadgetState(#GADGET_Option_Debugger , *Target\Debugger)
  SetGadgetState(#GADGET_Option_Optimizer, *Target\Optimizer)
  SetGadgetState(#GADGET_Option_DPIAware     , *Target\DPIAware)

  CompilerIf #SpiderBasic
    SetGadgetText(#GADGET_Option_SelectWindowTheme, *Target\WindowTheme$)
    SetGadgetText(#GADGET_Option_SelectGadgetTheme, *Target\GadgetTheme$)
    SetGadgetText(#GADGET_Option_WebServerAddress, *Target\WebServerAddress$)
    
  CompilerElse
    SetGadgetText(#GADGET_Option_IconName,    *Target\IconName$)
    SetGadgetState(#GADGET_Option_UseIcon      , *Target\UseIcon)
    SetGadgetText(#GADGET_Option_CommandLine, *Target\CommandLine$)
    SetGadgetText(#GADGET_Option_Linker,      *Target\LinkerOptions$)
    SetGadgetText(#GADGET_Option_CurrentDir,  *Target\CurrentDirectory$)
    SetGadgetState(#GADGET_Option_ExecutableFormat, *Target\ExecutableFormat)
    SetGadgetState(#GADGET_Option_CPU          , *Target\CPU)
    SetGadgetState(#GADGET_Option_Purifier     , *Target\EnablePurifier)
    SetGadgetState(#GADGET_Option_EnableASM    , *Target\EnableASM)
    SetGadgetState(#GADGET_Option_EnableThread , *Target\EnableThread)
    SetGadgetState(#GADGET_Option_EnableXP     , *Target\EnableXP)
    SetGadgetState(#GADGET_Option_EnableWayland, *Target\EnableWayland)
    SetGadgetState(#GADGET_Option_EnableAdmin  , *Target\EnableAdmin)
    SetGadgetState(#GADGET_Option_EnableUser   , *Target\EnableUser)
    SetGadgetState(#GADGET_Option_DllProtection, *Target\DllProtection)
    SetGadgetState(#GADGET_Option_SharedUCRT   , *Target\SharedUCRT)
    SetGadgetState(#GADGET_Option_EnableOnError, *Target\EnableOnError)
    
    SetGadgetState(#GADGET_Option_SelectDebugger, *Target\CustomDebugger)
    If *Target\DebuggerType > 0 And *Target\DebuggerType < 4
      SetGadgetState(#GADGET_Option_DebuggerMode, *Target\DebuggerType-1)
    Else
      SetGadgetState(#GADGET_Option_DebuggerMode, 0)
    EndIf
    
    SetGadgetState(#GADGET_Option_SelectWarning, *Target\CustomWarning)
    If *Target\WarningMode >= 0 And *Target\WarningMode < 3
      SetGadgetState(#GADGET_Option_WarningMode, *Target\WarningMode)
    Else
      SetGadgetState(#GADGET_Option_WarningMode, 1)
    EndIf
    
    SetGadgetState(#GADGET_Option_TemporaryExe,    *Target\TemporaryExePlace)
  CompilerEndIf
  
  SetGadgetState(#GADGET_Option_UseCompileCount, *Target\UseCompileCount)
  SetGadgetState(#GADGET_Option_UseBuildCount,   *Target\UseBuildCount)
  SetGadgetState(#GADGET_Option_UseCreateExe,    *Target\UseCreateExe)
  
  SetGadgetText(#GADGET_Option_CompileCount,     Str(*Target\CompileCount))
  SetGadgetText(#GADGET_Option_BuildCount,       Str(*Target\BuildCount))
  
  ClearGadgetItems(#GADGET_Option_ConstantList)
  SetGadgetText(#GADGET_Option_ConstantLine, "")
  For i = 0 To *Target\NbConstants-1
    AddGadgetItem(#GADGET_Option_ConstantList, i, *Target\Constant$[i])
    If *Target\ConstantEnabled[i]
      SetGadgetItemState(#GADGET_Option_ConstantList, i, #PB_ListIcon_Checked)
    EndIf
  Next i
  
  ClearGadgetItems(#GADGET_Option_ToolsList)
  ForEach ToolsList()
    If ToolsList()\SourceSpecific
      Tool$ = ToolsList()\MenuItemName$+Chr(10)+Language("AddTools","Trigger"+Str(ToolsList()\Trigger))
      
      If ToolsList()\DeactivateTool
        Tool$ + Chr(10) + Language("Misc", "Disabled")
      Else
        Tool$ + Chr(10) + Language("Misc", "Enabled")
      EndIf
      
      AddGadgetItem(#GADGET_Option_ToolsList, -1, Tool$)
      
      ; check if the tool is enabled
      ; the list is in uppercase, no spaces (spaces inside names replaced by '_')
      ; separated by comma
      ;
      If FindString(","+*Target\EnabledTools$+",", ","+ReplaceString(UCase(Trim(ToolsList()\MenuItemName$)), " ", "_")+",", 1) <> 0
        SetGadgetItemState(#GADGET_Option_ToolsList, CountGadgetItems(#GADGET_Option_ToolsList)-1, #PB_ListIcon_Checked)
      EndIf
      
    EndIf
  Next ToolsList()
  
  CompilerIf #CompileWindows And Not #SpiderBasic
    For i = 0 To 23
      If i >= 15 And i <= 17 And *Target\VersionField$[i] = "" ; comboboxes
        SetGadgetState(#GADGET_Option_VersionValue0+i, 0)      ; set comboboxes to default
      Else
        SetGadgetText(#GADGET_Option_VersionValue0+i, *Target\VersionField$[i])
      EndIf
    Next i
    SetGadgetState(#GADGET_Option_IncludeVersion, *Target\VersionInfo)
    
    ClearGadgetItems(#GADGET_Option_ResourceList)
    SetGadgetText(#GADGET_Option_ResourceFile, "")
    For i = 0 To *Target\NbResourceFiles-1
      AddGadgetItem(#GADGET_Option_ResourceList, -1, *Target\ResourceFiles$[i])
    Next i
  CompilerEndIf
  
  DisableOptionGadgets()
EndProcedure

; returns #true if changes were made
;
Procedure TargetOptionsChanged(*Target.CompileTarget)
  Changed = 0
  If Options_IsProjectMode
    If *Target\OutputFile$     <> GetGadgetText(#GADGET_Option_OutputFile): Changed = 1: EndIf
  Else
    If *Target\UseMainFile     <> GetGadgetState(#GADGET_Option_UseMainFile): Changed = 1: EndIf
  EndIf
  
  If *Target\CustomCompiler    <> GetGadgetState(#GADGET_Option_UseCompiler): Changed = 1: EndIf
  
  If *Target\CustomCompiler And MatchCompilerVersion(*Target\CompilerVersion$, GetGadgetText(#GADGET_Option_SelectCompiler), #MATCH_Version|#MATCH_Beta|#MATCH_Processor) = 0
    Changed = 1
  EndIf
  
  If *Target\Debugger          <> GetGadgetState(#GADGET_Option_Debugger): Changed = 1: EndIf
  If *Target\Optimizer         <> GetGadgetState(#GADGET_Option_Optimizer): Changed = 1: EndIf
  If *Target\DPIAware          <> GetGadgetState(#GADGET_Option_DPIAware): Changed = 1: EndIf
  
  CompilerIf #SpiderBasic
    If *Target\WindowTheme$           <> GetGadgetText(#GADGET_Option_SelectWindowTheme): Changed = 1: EndIf
    If *Target\GadgetTheme$           <> GetGadgetText(#GADGET_Option_SelectGadgetTheme): Changed = 1: EndIf
    If *Target\WebServerAddress$      <> GetGadgetText(#GADGET_Option_WebServerAddress): Changed = 1: EndIf
    
  CompilerElse
    If *Target\EnableASM         <> GetGadgetState(#GADGET_Option_EnableASM): Changed = 1: EndIf
    If *Target\EnablePurifier    <> GetGadgetState(#GADGET_Option_Purifier): Changed = 1: EndIf
    If *Target\EnableThread      <> GetGadgetState(#GADGET_Option_EnableThread): Changed = 1: EndIf
    If *Target\EnableXP          <> GetGadgetState(#GADGET_Option_EnableXP): Changed = 1: EndIf
    If *Target\EnableWayland     <> GetGadgetState(#GADGET_Option_EnableWayland): Changed = 1: EndIf
    If *Target\EnableAdmin       <> GetGadgetState(#GADGET_Option_EnableAdmin): Changed = 1: EndIf
    If *Target\EnableUser        <> GetGadgetState(#GADGET_Option_EnableUser): Changed = 1: EndIf
    If *Target\DllProtection     <> GetGadgetState(#GADGET_Option_DllProtection): Changed = 1: EndIf
    If *Target\SharedUCRT        <> GetGadgetState(#GADGET_Option_SharedUCRT): Changed = 1: EndIf
    If *Target\EnableOnError     <> GetGadgetState(#GADGET_Option_EnableOnError): Changed = 1: EndIf
    If *Target\CPU               <> GetGadgetState(#GADGET_Option_CPU): Changed = 1: EndIf
    If *Target\ExecutableFormat  <> GetGadgetState(#GADGET_Option_ExecutableFormat): Changed = 1: EndIf
    If *Target\CommandLine$      <> GetGadgetText(#GADGET_Option_CommandLine): Changed = 1: EndIf
    If *Target\LinkerOptions$    <> GetGadgetText(#GADGET_Option_Linker): Changed = 1: EndIf
    If *Target\CurrentDirectory$ <> GetGadgetText(#GADGET_Option_CurrentDir): Changed = 1: EndIf
    If *Target\CustomDebugger    <> GetGadgetState(#GADGET_Option_SelectDebugger): Changed = 1: EndIf
    If *Target\CustomWarning     <> GetGadgetState(#GADGET_Option_SelectWarning): Changed = 1: EndIf
    If *Target\DebuggerType-1    <> GetGadgetState(#GADGET_Option_DebuggerMode) And GetGadgetState(#GADGET_Option_SelectDebugger): Changed = 1: EndIf
    If *Target\WarningMode       <> GetGadgetState(#GADGET_Option_WarningMode) And GetGadgetState(#GADGET_Option_SelectWarning): Changed = 1: EndIf
    If *Target\TemporaryExePlace <> GetGadgetState(#GADGET_Option_TemporaryExe): Changed = 1: EndIf
    If *Target\UseIcon           <> GetGadgetState(#GADGET_Option_UseIcon): Changed = 1: EndIf
    If *Target\IconName$         <> GetGadgetText(#GADGET_Option_IconName): Changed = 1: EndIf
  CompilerEndIf
  If *Target\SubSystem$        <> GetGadgetText(#GADGET_Option_SubSystem): Changed = 1: EndIf
  If *Target\MainFile$         <> GetGadgetText(#GADGET_Option_MainFile): Changed = 1: EndIf
  If *Target\CompileCount      <> Val(GetGadgetText(#GADGET_Option_CompileCount)): Changed = 1: EndIf
  If *Target\BuildCount        <> Val(GetGadgetText(#GADGET_Option_BuildCount)): Changed = 1: EndIf
  If *Target\UseCompileCount   <> GetGadgetState(#GADGET_Option_UseCompileCount): Changed = 1: EndIf
  If *Target\UseBuildCount     <> GetGadgetState(#GADGET_Option_UseBuildCount): Changed = 1: EndIf
  If *Target\UseCreateExe      <> GetGadgetState(#GADGET_Option_UseCreateExe): Changed = 1: EndIf
  If *Target\EnabledTools$     <> CompilerWindow_EnabledToolsList(): Changed = 1: EndIf
  
  Count = CountGadgetItems(#GADGET_Option_ConstantList)
  If *Target\NbConstants <> Count
    Changed = 1
  Else
    For i = 0 To Count-1
      If *Target\Constant$[i] <> GetGadgetItemText(#GADGET_Option_ConstantList, i, 0)
        Changed = 1
        Break
      EndIf
      
      If (GetGadgetItemState(#GADGET_Option_ConstantList, i) & #PB_ListIcon_Checked And *Target\ConstantEnabled[i] = 0) Or (GetGadgetItemState(#GADGET_Option_ConstantList, i) & #PB_ListIcon_Checked = 0 And *Target\ConstantEnabled[i])
        Changed = 1
        Break
      EndIf
    Next i
  EndIf
  
  CompilerIf #CompileWindows And Not #SpiderBasic
    
    If *Target\VersionInfo <> GetGadgetState(#GADGET_Option_IncludeVersion): Changed = 1: EndIf
    For i = 0 To 14
      If *Target\VersionField$[i] <> GetGadgetText(#GADGET_Option_VersionValue0+i): Changed = 1: EndIf
    Next i
    
    ; these fields are made empty when the defaults are set:
    For i = 15 To 17
      If *Target\VersionField$[i] <> "" Or GetGadgetState(#GADGET_Option_VersionValue0+i) <> 0
        If *Target\VersionField$[i] <> GetGadgetText(#GADGET_Option_VersionValue0+i): Changed = 1: EndIf
      EndIf
    Next i
    
    For i = 18 To 23
      If *Target\VersionField$[i] <> GetGadgetText(#GADGET_Option_VersionValue0+i): Changed = 1: EndIf
    Next i
    
    If *Target\NbResourceFiles <> CountGadgetItems(#GADGET_Option_ResourceList): Changed = 1: EndIf
    
    If *Target\NbResourceFiles > 0
      For i = 0 To *Target\NbResourceFiles-1
        If *Target\ResourceFiles$[i] <> GetGadgetItemText(#GADGET_Option_ResourceList, i, 0)
          Changed = 1
          Break
        EndIf
      Next i
    EndIf
    
  CompilerEndIf
  
  ProcedureReturn Changed
EndProcedure


Procedure GetTargetOptions(*Target.CompileTarget)
  
  If Options_IsProjectMode = 0
    *Target\UseMainFile = GetGadgetState(#GADGET_Option_UseMainFile)
  EndIf
  
  *Target\CustomCompiler = GetGadgetState(#GADGET_Option_UseCompiler)
  If *Target\CustomCompiler
    *Target\CompilerVersion$ = GetGadgetText(#GADGET_Option_SelectCompiler)
  EndIf
  
  *Target\Debugger         = GetGadgetState(#GADGET_Option_Debugger)
  *Target\Optimizer        = GetGadgetState(#GADGET_Option_Optimizer)
  *Target\DPIAware         = GetGadgetState(#GADGET_Option_DPIAware)
  
  CompilerIf #SpiderBasic
    *Target\WebServerAddress$ = GetGadgetText(#GADGET_Option_WebServerAddress)
    *Target\WindowTheme$    = GetGadgetText(#GADGET_Option_SelectWindowTheme)
    *Target\GadgetTheme$    = GetGadgetText(#GADGET_Option_SelectGadgetTheme)
    
  CompilerElse
    *Target\EnableASM        = GetGadgetState(#GADGET_Option_EnableASM)
    *Target\EnablePurifier   = GetGadgetState(#GADGET_Option_Purifier)
    *Target\EnableThread     = GetGadgetState(#GADGET_Option_EnableThread)
    *Target\EnableXP         = GetGadgetState(#GADGET_Option_EnableXP)
    *Target\EnableWayland    = GetGadgetState(#GADGET_Option_EnableWayland)
    *Target\EnableAdmin      = GetGadgetState(#GADGET_Option_EnableAdmin)
    *Target\EnableUser       = GetGadgetState(#GADGET_Option_EnableUser)
    *Target\DllProtection    = GetGadgetState(#GADGET_Option_DllProtection)
    *Target\SharedUCRT       = GetGadgetState(#GADGET_Option_SharedUCRT)
    *Target\EnableOnError    = GetGadgetState(#GADGET_Option_EnableOnError)
    *Target\CPU              = GetGadgetState(#GADGET_Option_CPU)
    *Target\TemporaryExePlace= GetGadgetState(#GADGET_Option_TemporaryExe)
    *Target\CustomDebugger   = GetGadgetState(#GADGET_Option_SelectDebugger)
    *Target\DebuggerType     = GetGadgetState(#GADGET_Option_DebuggerMode)+1
    *Target\CustomWarning    = GetGadgetState(#GADGET_Option_SelectWarning)
    *Target\WarningMode      = GetGadgetState(#GADGET_Option_WarningMode)
    *Target\UseIcon          = GetGadgetState(#GADGET_Option_UseIcon)
    If *Target\UseIcon
      *Target\IconName$ = Trim(GetGadgetText(#GADGET_Option_IconName))
    EndIf
  CompilerEndIf
  *Target\UseCompileCount  = GetGadgetState(#GADGET_Option_UseCompileCount)
  *Target\UseBuildCount    = GetGadgetState(#GADGET_Option_UseBuildCount)
  *Target\UseCreateExe     = GetGadgetState(#GADGET_Option_UseCreateExe)
  
  If Options_IsProjectMode
    *Target\MainFile$   = Trim(GetGadgetText(#GADGET_Option_MainFile))
    *Target\OutputFile$ = Trim(GetGadgetText(#GADGET_Option_OutputFile))
    *Target\FileName$   = ResolveRelativePath(GetPathPart(ProjectFile$), *Target\MainFile$)
  ElseIf *Target\UseMainFile
    *Target\MainFile$ = Trim(GetGadgetText(#GADGET_Option_MainFile))
  EndIf
  
  CompilerIf Not #SpiderBasic
    *Target\ExecutableFormat  = GetGadgetState(#GADGET_Option_ExecutableFormat)
    *Target\CommandLine$      = GetGadgetText(#GADGET_Option_CommandLine)
    *Target\LinkerOptions$    = Trim(GetGadgetText(#GADGET_Option_Linker))
    *Target\CurrentDirectory$ = Trim(GetGadgetText(#GADGET_Option_CurrentDir))
  CompilerEndIf
  *Target\SubSystem$        = GetGadgetText(#GADGET_Option_SubSystem)
  *Target\CompileCount      = Val(GetGadgetText(#GADGET_Option_CompileCount))
  *Target\BuildCount        = Val(GetGadgetText(#GADGET_Option_BuildCount))
  *Target\EnabledTools$     = CompilerWindow_EnabledToolsList()
  
  *Target\NbConstants = CountGadgetItems(#GADGET_Option_ConstantList)
  If *Target\NbConstants > #MAX_Constants
    *Target\NbConstants = #MAX_Constants
  EndIf
  
  For i = 0 To *Target\NbConstants-1
    *Target\Constant$[i] = GetGadgetItemText(#GADGET_Option_ConstantList, i, 0)
    If GetGadgetItemState(#GADGET_Option_ConstantList, i) & #PB_ListIcon_Checked
      *Target\ConstantEnabled[i] = #True
    Else
      *Target\ConstantEnabled[i] = #False
    EndIf
  Next i
  
  CompilerIf #CompileWindows And Not #SpiderBasic
    
    *Target\VersionInfo = GetGadgetState(#GADGET_Option_IncludeVersion)
    For i = 0 To 23
      *Target\VersionField$[i] = GetGadgetText(#GADGET_Option_VersionValue0+i)
    Next i
    
    ; make fields empty when the default values are selected ( so they do not appear in the file info block all the time)
    If GetGadgetState(#GADGET_Option_VersionValue0+15) = 0
      *Target\VersionField$[15] = ""
    EndIf
    If GetGadgetState(#GADGET_Option_VersionValue0+16) = 0
      *Target\VersionField$[16] = ""
    EndIf
    If GetGadgetState(#GADGET_Option_VersionValue0+17) = 0
      *Target\VersionField$[17] = ""
    EndIf
    
    *Target\NbResourceFiles = CountGadgetItems(#GADGET_Option_ResourceList)
    If *Target\NbResourceFiles > #MAX_ResourceFiles
      *Target\NbResourceFiles = #MAX_ResourceFiles
    EndIf
    
    For i = 0 To *Target\NbResourceFiles-1
      *Target\ResourceFiles$[i] = Trim(GetGadgetItemText(#GADGET_Option_ResourceList, i, 0))
    Next i
  CompilerEndIf
  
  ProcedureReturn Changed
EndProcedure

Procedure UpdateTargetGadgets()
  State = GetGadgetState(#GADGET_Option_TargetList)
  
  If State = -1
    DisableGadget(#GADGET_Option_EditTarget,     1)
    DisableGadget(#GADGET_Option_CopyTarget,     1)
    DisableGadget(#GADGET_Option_RemoveTarget,   1)
    DisableGadget(#GADGET_Option_TargetUp,       1)
    DisableGadget(#GADGET_Option_TargetDown,     1)
    DisableGadget(#GADGET_Option_DefaultTarget,  1)
    DisableGadget(#GADGET_Option_TargetEnabled,  1)
    SetGadgetState(#GADGET_Option_DefaultTarget, 0)
    SetGadgetState(#GADGET_Option_TargetEnabled, 0)
    
    DisableMenuItem(#POPUPMENU_Options, #GADGET_Option_EditTarget,        1)
    DisableMenuItem(#POPUPMENU_Options, #GADGET_Option_CopyTarget,        1)
    DisableMenuItem(#POPUPMENU_Options, #GADGET_Option_RemoveTarget,      1)
    DisableMenuItem(#POPUPMENU_Options, #GADGET_Option_TargetUp,          1)
    DisableMenuItem(#POPUPMENU_Options, #GADGET_Option_TargetDown,        1)
    DisableMenuItem(#POPUPMENU_Options, #GADGET_Option_DefaultTargetMenu, 1)
    DisableMenuItem(#POPUPMENU_Options, #GADGET_Option_TargetEnabledMenu, 1)
    SetMenuItemState(#POPUPMENU_Options, #GADGET_Option_DefaultTargetMenu, 0)
    SetMenuItemState(#POPUPMENU_Options, #GADGET_Option_TargetEnabledMenu, 0)
  Else
    SelectElement(ProjectOptionTargets(), State)
    Count = ListSize(ProjectOptionTargets())
    
    DisableGadget(#GADGET_Option_EditTarget, 0)
    DisableGadget(#GADGET_Option_CopyTarget, 0)
    DisableMenuItem(#POPUPMENU_Options, #GADGET_Option_EditTarget, 0)
    DisableMenuItem(#POPUPMENU_Options, #GADGET_Option_CopyTarget, 0)
    
    If Count = 1
      DisableGadget(#GADGET_Option_RemoveTarget, 1) ; must keep at least one target (and at least one default)
      DisableGadget(#GADGET_Option_DefaultTarget, 1)
      SetGadgetState(#GADGET_Option_DefaultTarget, 1)
      DisableMenuItem(#POPUPMENU_Options, #GADGET_Option_RemoveTarget, 1)
      DisableMenuItem(#POPUPMENU_Options, #GADGET_Option_DefaultTargetMenu, 1)
      SetMenuItemState(#POPUPMENU_Options, #GADGET_Option_DefaultTargetMenu, 1)
    Else
      DisableGadget(#GADGET_Option_RemoveTarget, 0)
      DisableGadget(#GADGET_Option_DefaultTarget, 0)
      DisableMenuItem(#POPUPMENU_Options, #GADGET_Option_RemoveTarget, 0)
      DisableMenuItem(#POPUPMENU_Options, #GADGET_Option_DefaultTargetMenu, 0)
      
      If ProjectOptionTargets()\IsDefault
        SetGadgetState(#GADGET_Option_DefaultTarget, 1)
        SetMenuItemState(#POPUPMENU_Options, #GADGET_Option_DefaultTargetMenu, 1)
      Else
        SetGadgetState(#GADGET_Option_DefaultTarget, 0)
        SetMenuItemState(#POPUPMENU_Options, #GADGET_Option_DefaultTargetMenu, 0)
      EndIf
    EndIf
    
    If State = 0
      DisableGadget(#GADGET_Option_TargetUp, 1)
      DisableMenuItem(#POPUPMENU_Options, #GADGET_Option_TargetUp, 1)
    Else
      DisableGadget(#GADGET_Option_TargetUp, 0)
      DisableMenuItem(#POPUPMENU_Options, #GADGET_Option_TargetUp, 0)
    EndIf
    
    If State = Count-1
      DisableGadget(#GADGET_Option_TargetDown, 1)
      DisableMenuItem(#POPUPMENU_Options, #GADGET_Option_TargetDown, 1)
    Else
      DisableGadget(#GADGET_Option_TargetDown, 0)
      DisableMenuItem(#POPUPMENU_Options, #GADGET_Option_TargetDown, 0)
    EndIf
    
    DisableGadget(#GADGET_Option_TargetEnabled, 0)
    DisableMenuItem(#POPUPMENU_Options, #GADGET_Option_TargetEnabledMenu, 0)
    
    If ProjectOptionTargets()\IsEnabled
      SetGadgetState(#GADGET_Option_TargetEnabled, 1)
      SetMenuItemState(#POPUPMENU_Options, #GADGET_Option_TargetEnabledMenu, 1)
    Else
      SetGadgetState(#GADGET_Option_TargetEnabled, 0)
      SetMenuItemState(#POPUPMENU_Options, #GADGET_Option_TargetEnabledMenu, 0)
    EndIf
  EndIf
  
EndProcedure

Procedure ProjectTargetImage(*Target.CompileTarget)
  If *Target\IsDefault
    ProcedureReturn ImageID(#IMAGE_Option_DefaultTarget)
  ElseIf *Target\IsEnabled
    ProcedureReturn ImageID(#IMAGE_Option_NormalTarget)
  Else
    ProcedureReturn ImageID(#IMAGE_Option_DisabledTarget)
  EndIf
EndProcedure

Procedure OpenOptionWindow(ForceProjectOptions, *InitialTarget.CompileTarget = 0)
  
  If IsWindow(#WINDOW_Option) = 0
    
    ; Use a slightly different dialog for project options
    ;
    If *ActiveSource = *ProjectInfo Or *ActiveSource\ProjectFile Or (IsProject And ForceProjectOptions)
      Options_IsProjectMode = #True
      OptionWindowDialog = OpenDialog(?Dialog_ProjectCompilerOptions, WindowID(#WINDOW_Main), @ProjectOptionWindowPosition)
    Else
      Options_IsProjectMode = #False
      OptionWindowDialog = OpenDialog(?Dialog_CompilerOptions, WindowID(#WINDOW_Main), @OptionWindowPosition)
    EndIf
    
    If OptionWindowDialog
      EnsureWindowOnDesktop(#WINDOW_Option)
      
      EnableGadgetDrop(#GADGET_Option_MainFile,   #PB_Drop_Files, #PB_Drag_Copy)
      
      CompilerIf #SpiderBasic
        
        If Options_IsProjectMode
          HideGadget(#GADGET_Option_OutputFileLabel, #True)
          HideGadget(#GADGET_Option_OutputFile, #True)
          HideGadget(#GADGET_Option_SelectOutputFile, #True)
        EndIf
        
        ; Scan the available window themes
        ;
        If ExamineDirectory(0, PureBasicPath$+"libraries/javascript/themes", "")
          While NextDirectoryEntry(0)
            If DirectoryEntryType(0) = #PB_DirectoryEntry_Directory And Left(DirectoryEntryName(0), 1) <> "." ; ignore ".", ".." and all hidden directories
              AddGadgetItem(#GADGET_Option_SelectWindowTheme, -1, DirectoryEntryName(0))
            EndIf
          Wend
          
          FinishDirectory(0)
        EndIf
        
        ; Scan the available gadget themes
        ;
        If ExamineDirectory(0, PureBasicPath$+"libraries/javascript/dojo/themes", "")
          While NextDirectoryEntry(0)
            If DirectoryEntryType(0) = #PB_DirectoryEntry_Directory And Left(DirectoryEntryName(0), 1) <> "." ; ignore ".", ".." and all hidden directories
              AddGadgetItem(#GADGET_Option_SelectGadgetTheme, -1, DirectoryEntryName(0))
            EndIf
          Wend
          
          FinishDirectory(0)
        EndIf
        
      CompilerElse
        EnableGadgetDrop(#GADGET_Option_IconName,   #PB_Drop_Files, #PB_Drag_Copy)
        EnableGadgetDrop(#GADGET_Option_Linker,     #PB_Drop_Files, #PB_Drag_Copy)
        EnableGadgetDrop(#GADGET_Option_CurrentDir, #PB_Drop_Files, #PB_Drag_Copy)
      CompilerEndIf
      
      AddGadgetItem(#GADGET_Option_SelectCompiler, -1, DefaultCompiler\VersionString$)
      ForEach Compilers()
        If Compilers()\Validated
          AddGadgetItem(#GADGET_Option_SelectCompiler, -1, Compilers()\VersionString$)
          SetGadgetItemData(#GADGET_Option_SelectCompiler, CountGadgetItems(#GADGET_Option_SelectCompiler)-1, @Compilers())
        EndIf
      Next Compilers()
      
      CompilerIf #CompileWindows And Not #SpiderBasic
        Restore Resource_Strings
        For i = 15 To 17
          Read.l Count
          For s = 1 To Count
            Read.s Value$
            AddGadgetItem(#GADGET_Option_VersionValue0+i, -1, Value$)
          Next s
        Next i
        
        EnableGadgetDrop(#GADGET_Option_ResourceList, #PB_Drop_Files, #PB_Drag_Copy)
        EnableGadgetDrop(#GADGET_Option_ResourceFile, #PB_Drop_Files, #PB_Drag_Copy)
      CompilerEndIf
      
      
      If Options_IsProjectMode
        Options_CurrentBasePath$ = GetPathPart(ProjectFile$)
        
        EnableGadgetDrop(#GADGET_Option_OutputFile, #PB_Drop_Files, #PB_Drag_Copy)
        
        SetGadgetAttribute(#GADGET_Option_AddTarget,    #PB_Button_Image, ImageID(#IMAGE_Option_AddTarget))
        SetGadgetAttribute(#GADGET_Option_EditTarget,   #PB_Button_Image, ImageID(#IMAGE_Option_EditTarget))
        SetGadgetAttribute(#GADGET_Option_CopyTarget,   #PB_Button_Image, ImageID(#IMAGE_Option_CopyTarget))
        SetGadgetAttribute(#GADGET_Option_RemoveTarget, #PB_Button_Image, ImageID(#IMAGE_Option_RemoveTarget))
        SetGadgetAttribute(#GADGET_Option_TargetUp,     #PB_Button_Image, ImageID(#IMAGE_Option_TargetUp))
        SetGadgetAttribute(#GADGET_Option_TargetDown,   #PB_Button_Image, ImageID(#IMAGE_Option_TargetDown))
        
        GadgetToolTip(#GADGET_Option_AddTarget,    Language("Compiler","AddTarget"))
        GadgetToolTip(#GADGET_Option_EditTarget,   Language("Compiler","RenameTarget"))
        GadgetToolTip(#GADGET_Option_CopyTarget,   Language("Compiler","CopyTarget"))
        GadgetToolTip(#GADGET_Option_RemoveTarget, Language("Compiler","RemoveTarget"))
        GadgetToolTip(#GADGET_Option_TargetUp,     Language("Compiler","TargetUp"))
        GadgetToolTip(#GADGET_Option_TargetDown,   Language("Compiler","TargetDown"))
        
        If EnableAccessibility
          ; Give all these controls labels to screen readers, using a hack with SetGadgetText() on ButtonImageGadgets that adds an accessibility label.
          SetGadgetText(#GADGET_Option_AddTarget,    Language("Compiler","AddTarget"))
          SetGadgetText(#GADGET_Option_EditTarget,   Language("Compiler","RenameTarget"))
          SetGadgetText(#GADGET_Option_CopyTarget,   Language("Compiler","CopyTarget"))
          SetGadgetText(#GADGET_Option_RemoveTarget, Language("Compiler","RemoveTarget"))
          SetGadgetText(#GADGET_Option_TargetUp,     Language("Compiler","TargetUp"))
          SetGadgetText(#GADGET_Option_TargetDown,   Language("Compiler","TargetDown"))
        EndIf
        
        ; resize with the actual button images and fold state
        OptionWindowDialog\GuiUpdate()
        
        ; Create the popupmenu
        ;
        If EnableMenuIcons
          *Popup = CreatePopupImageMenu(#POPUPMENU_Options)
        Else
          *Popup = CreatePopupMenu(#POPUPMENU_Options)
        EndIf
        
        ; Re-use the gadget ids for the menu for simplicity (same as for the shortcuts)
        If *Popup
          MenuItem(#GADGET_Option_AddTarget,     Language("Compiler","AddTarget"),    ImageID(#IMAGE_Option_AddTarget))
          MenuItem(#GADGET_Option_CopyTarget,    Language("Compiler","CopyTarget"),   ImageID(#IMAGE_Option_CopyTarget))
          MenuItem(#GADGET_Option_EditTarget,    Language("Compiler","RenameTarget"),   ImageID(#IMAGE_Option_EditTarget))
          MenuBar()
          MenuItem(#GADGET_Option_RemoveTarget,  Language("Compiler","RemoveTarget"), ImageID(#IMAGE_Option_RemoveTarget))
          MenuBar()
          MenuItem(#GADGET_Option_TargetUp,      Language("Compiler","TargetUp"),     ImageID(#IMAGE_Option_TargetUp))
          MenuItem(#GADGET_Option_TargetDown,    Language("Compiler","TargetDown"),   ImageID(#IMAGE_Option_TargetDown))
          MenuBar()
          MenuItem(#GADGET_Option_DefaultTargetMenu, Language("Compiler","DefaultTarget"))
          MenuItem(#GADGET_Option_TargetEnabledMenu, Language("Compiler","EnableTarget"))
        EndIf
        
        ClearList(ProjectOptionTargets())
        CurrentIndex = -1
        *Options_CurrentTarget = 0
        
        If *InitialTarget = 0
          *InitialTarget = *DefaultTarget
        EndIf
        
        ForEach ProjectTargets()
          AddElement(ProjectOptionTargets())
          ProjectOptionTargets() = ProjectTargets() ; copy the entire settings
          
          If @ProjectTargets() = *InitialTarget
            CurrentIndex = ListIndex(ProjectTargets())
            *Options_CurrentTarget = @ProjectOptionTargets()
          EndIf
          
          If @ProjectTargets() = *DefaultTarget
            ProjectOptionTargets()\IsDefault = #True
          Else
            ProjectOptionTargets()\IsDefault = #False
          EndIf
          
          AddGadgetItem(#GADGET_Option_TargetList, -1, ProjectOptionTargets()\Name$, ProjectTargetImage(@ProjectOptionTargets()))
        Next ProjectTargets()
        
        If CurrentIndex <> -1
          SetGadgetState(#GADGET_Option_TargetList, CurrentIndex)
        EndIf
        
        SetTargetOptions(*InitialTarget)
        UpdateTargetGadgets()
      Else
        If *ActiveSource\Filename$ ; already saved
          Options_CurrentBasePath$ = GetPathPart(*ActiveSource\Filename$)
        Else
          Options_CurrentBasePath$ = "" ; use full paths then
        EndIf
        
        ; just set the active source options
        SetTargetOptions(*ActiveSource)
      EndIf
      
      CompilerIf #CompileWindows
        SendMessage_(GadgetID(#GADGET_Option_ConstantList), #LVM_SETCOLUMNWIDTH, 0, #LVSCW_AUTOSIZE_USEHEADER)
        
        If Options_IsProjectMode
          SendMessage_(GadgetID(#GADGET_Option_TargetList), #LVM_SETCOLUMNWIDTH, 0, #LVSCW_AUTOSIZE_USEHEADER)
        EndIf
      CompilerEndIf
      
      ; While this dialog is open, disable the menu entry to avoid inconsistency
      DisableMenuItem(#MENU, #MENU_Debugger, #True)
      
      HideWindow(#WINDOW_Option, 0)
    EndIf
    
  Else
    SetWindowForeground(#WINDOW_Option)
  EndIf
  
  
EndProcedure


Procedure OptionWindowEvents(EventID)
  
  If EventID = #PB_Event_Menu     ; Little wrapper to map the shortcut events (identified as menu)
    EventID  = #PB_Event_Gadget   ; to normal gadget events...
    GadgetID = EventMenu()
  Else
    GadgetID = EventGadget()
  EndIf
  
  Select EventID
      
    Case #PB_Event_CloseWindow
      Quit = 1
      
    Case #PB_Event_GadgetDrop
      
      Select GadgetID
          
        Case #GADGET_Option_MainFile
          File$ = StringField(EventDropFiles(), 1, Chr(10)) ; ignore all but the first entry
          SetGadgetText(#GADGET_Option_MainFile, CreateRelativePath(Options_CurrentBasePath$, File$))
          
        Case #GADGET_Option_OutputFile
          File$ = StringField(EventDropFiles(), 1, Chr(10)) ; ignore all but the first entry
          SetGadgetText(#GADGET_Option_MainFile, CreateRelativePath(Options_CurrentBasePath$, File$))
          
          
          CompilerIf Not #SpiderBasic
          Case #GADGET_Option_IconName
            File$ = StringField(EventDropFiles(), 1, Chr(10))
            SetGadgetText(#GADGET_Option_IconName, CreateRelativePath(Options_CurrentBasePath$, File$))
            
          Case #GADGET_Option_Linker
            File$ = StringField(EventDropFiles(), 1, Chr(10))
            SetGadgetText(#GADGET_Option_Linker, CreateRelativePath(Options_CurrentBasePath$, File$))
            
          Case #GADGET_Option_CurrentDir
            Path$ = StringField(EventDropFiles(), 1, Chr(10))
            If FileSize(Path$) <> -2 ; probably a file then
              Path$ = GetPathPart(Path$)
            EndIf
            SetGadgetText(#GADGET_Option_CurrentDir, CreateRelativePath(Options_CurrentBasePath$, Path$))
            
            CompilerIf #CompileWindows
              
            Case #GADGET_Option_ResourceList
              Files$ = EventDropFiles() ; look at all files here...
              Count  = CountString(Files$, Chr(10))+1
              For i = 1 To Count
                File$ = StringField(Files$, i, Chr(10))
                If FileSize(File$) <> -2 ; no directories!
                  AddGadgetItem(#GADGET_Option_ResourceList, -1, CreateRelativePath(Options_CurrentBasePath$, File$))
                EndIf
              Next i
              
            Case #GADGET_Option_ResourceFile
              File$ = StringField(EventDropFiles(), 1, Chr(10))
              SetGadgetText(#GADGET_Option_ResourceFile, CreateRelativePath(Options_CurrentBasePath$, File$))
              
            CompilerEndIf
            
          CompilerEndIf
          
      EndSelect
      
    Case #PB_Event_Gadget
      
      Select GadgetID
          
        Case #GADGET_Option_Ok
          
          If Options_IsProjectMode = 0
            
            ; Make sure the modified flag is set if any changes were done.
            ;
            If TargetOptionsChanged(*ActiveSource)
              UpdateSourceStatus(1) ; set the changed flag
            EndIf
            
            ; update the highlighting if EnableASM changes
            ;
            OldEnableASM = *ActiveSource\EnableASM
            GetTargetOptions(*ActiveSource)
            
            If OldEnableASM <> *ActiveSource\EnableASM
              UpdateHighlighting()
            EndIf
            
            SetDebuggerMenuStates() ; update the debugger menu state, as we can enable/disable it in the compiler options
            
            Quit = 1
          Else
            ; get the latest changes
            If *Options_CurrentTarget
              GetTargetOptions(*Options_CurrentTarget)
            EndIf
            
            ; check for missing MainFile$ names in the list and warn/abort if so
            Quit = 1
            
            ForEach ProjectOptionTargets()
              If Trim(ProjectOptionTargets()\MainFile$) = ""
                ; make the target in question the current one
                *Options_CurrentTarget = @ProjectOptionTargets()
                SetTargetOptions(*Options_CurrentTarget)
                SetGadgetState(#GADGET_Option_TargetList, ListIndex(ProjectOptionTargets()))
                UpdateTargetGadgets()
                
                If MessageRequester(Language("Compiler","OptionsTitle"), LanguagePattern("Compiler","NoInputFile", "%target%", ProjectOptionTargets()\Name$)+#NewLine+Language("Compiler","SaveAnyway"), #PB_MessageRequester_YesNo|#FLAG_Warning) = #PB_MessageRequester_No
                  Quit = 0
                  Break
                EndIf
              EndIf
            Next ProjectOptionTargets()
            
            ; copy the changes back to the real project list
            If Quit
              ClearList(ProjectTargets())
              ForEach ProjectOptionTargets()
                AddElement(ProjectTargets())
                ProjectTargets() = ProjectOptionTargets() ; structure copy
              Next ProjectOptionTargets()
              
              ; set the *DefaultTarget variable properly and ensuer there is a def target
              SetProjectDefaultTarget()
              SetDebuggerMenuStates()
              
              ; update the menu to reflect our target changes
              StartFlickerFix(#WINDOW_Main)
              CreateIDEMenu()
              StopFlickerFix(#WINDOW_Main, 1)
            EndIf
          EndIf
          
          
        Case #GADGET_Option_Cancel
          ClearList(ProjectOptionTargets()) ; do not apply these changes
          Quit = 1
          
        Case #GADGET_Option_UseMainFile
          DisableOptionGadgets()
          
          
        Case #GADGET_Option_Debugger
          ; No action here anymore, as the menu item is disabled anyway for consistency
          
          
        Case #GADGET_Option_SelectMainFile
          File$ = ResolveRelativePath(Options_CurrentBasePath$, GetGadgetText(#GADGET_Option_MainFile))
          If Trim(File$) = ""
            File$ = Options_CurrentBasePath$
          EndIf
          
          File$ = OpenFileRequester(Language("Compiler","OpenMainFile"), File$, Language("Compiler","SourcePattern"), 0)
          If File$
            SetGadgetText(#GADGET_Option_MainFile, CreateRelativePath(Options_CurrentBasePath$, File$))
          EndIf
          
        Case #GADGET_Option_UseCompiler
          DisableGadget(#GADGET_Option_SelectCompiler, 1-GetGadgetState(#GADGET_Option_UseCompiler))
          
          CompilerIf Not #SpiderBasic
            
          Case #GADGET_Option_SelectOutputFile
            File$ = ResolveRelativePath(Options_CurrentBasePath$, GetGadgetText(#GADGET_Option_OutputFile))
            If Trim(File$) = ""
              File$ = Options_CurrentBasePath$
            EndIf
            
            If GetGadgetState(#GADGET_Option_ExecutableFormat) = 2 ; shared dll
              CompilerIf #CompileWindows
                Pattern$     = Language("Compiler","DllPattern")
                Extension$   = ".dll"
              CompilerElseIf #CompileMac
                Pattern$   = "Shared Library (*.dylib)|*.dylib|All Files (*.*)|*.*"
                Extension$ = ".dylib"
              CompilerElse ; Linux
                Pattern$   = "Shared Library (*.so)|*.so|All Files (*.*)|*.*"
                Extension$ = ".so"
              CompilerEndIf
            Else
              CompilerIf #CompileWindows
                Pattern$   = Language("Compiler","ExePattern")
                Extension$ = ".exe"
              CompilerElseIf #CompileMac
                Pattern$   = ""
                If GetGadgetState(#GADGET_Option_ExecutableFormat) = 1 ; console
                  Extension$ = ""                                      ; console, do not append .app automatically here
                Else
                  Extension$ = ".app"  ; automatically append ".app" for gui programs
                EndIf
              CompilerElse ; Linux
                Pattern$   = ""
                Extension$ = ""
              CompilerEndIf
            EndIf
            
            File$ = SaveFileRequester(Language("Compiler","SetOutputFile"), File$, Pattern$, 0)
            If File$
              If LCase(Right(File$, Len(Extension$))) <> Extension$ And SelectedFilePattern() <> 1
                File$+Extension$
              EndIf
              
              SetGadgetText(#GADGET_Option_OutputFile, CreateRelativePath(Options_CurrentBasePath$, File$))
            EndIf
            
          Case #GADGET_Option_SelectIcon
            File$ = ResolveRelativePath(Options_CurrentBasePath$, GetGadgetText(#GADGET_Option_IconName))
            If Trim(File$) = ""
              File$ = Options_CurrentBasePath$
            EndIf
            
            Pattern$ = Language("Compiler","IconPattern")
            CompilerIf #CompileMac
              ; change .ico to .icns
              Pattern$ = ReplaceString(Pattern$, "ico", "icns")
            CompilerEndIf
            
            File$ = OpenFileRequester(Language("Compiler","OpenIcon"), File$, Pattern$, 0)
            If File$
              
              If SelectedFilePattern() = 0 And GetExtensionPart(File$) = ""
                CompilerIf #CompileWindows
                  Ext$ = "ico"
                CompilerElse
                  Ext$ = "icns"
                CompilerEndIf
                File$ + "." + Ext$
              EndIf
              
              SetGadgetText(#GADGET_Option_IconName, CreateRelativePath(Options_CurrentBasePath$, File$))
            EndIf
            
          Case #GADGET_Option_UseIcon
            Result = GetGadgetState(#GADGET_Option_UseIcon)
            DisableGadget(#GADGET_Option_IconName  , 1-Result)
            DisableGadget(#GADGET_Option_SelectIcon, 1-Result)
            
          Case #GADGET_Option_GetLinker
            File$ = ResolveRelativePath(Options_CurrentBasePath$, GetGadgetText(#GADGET_Option_Linker))
            If Trim(File$) = ""
              File$ = Options_CurrentBasePath$
            EndIf
            
            File$ = OpenFileRequester(Language("Compiler","OpenLinkerFile"), File$, Language("Compiler","AllFilesPattern"), 0)
            If File$
              SetGadgetText(#GADGET_Option_Linker, CreateRelativePath(Options_CurrentBasePath$, File$))
            EndIf
            
            
          Case #GADGET_Option_SelectDebugger
            DisableOptionGadgets()
            
          Case #GADGET_Option_DebuggerMode
            DisableOptionGadgets()
            
          Case #GADGET_Option_SelectWarning
            DisableOptionGadgets()
            
          Case #GADGET_Option_SelectCurrentDir
            If Trim(GetGadgetText(#GADGET_Option_CurrentDir)) = ""
              Path$ = Options_CurrentBasePath$
            Else
              Path$ = ResolveRelativePath(Options_CurrentBasePath$, GetGadgetText(#GADGET_Option_CurrentDir))
            EndIf
            
            Path$ = PathRequester("", Path$)
            If Path$
              SetGadgetText(#GADGET_Option_CurrentDir, CreateRelativePath(Options_CurrentBasePath$, Path$))
            EndIf
            
          CompilerEndIf
          
        Case #GADGET_Option_UseCompileCount
          DisableOptionGadgets()
          
        Case #GADGET_Option_UseBuildCount
          DisableOptionGadgets()
          
        Case #GADGET_Option_ConstantList
          index = GetGadgetState(#GADGET_Option_ConstantList)
          If index = -1
            SetGadgetText(#GADGET_Option_ConstantLine, "")
          Else
            SetGadgetText(#GADGET_Option_ConstantLine, GetGadgetItemText(#GADGET_Option_ConstantList, index, 0))
          EndIf
          
        Case #GADGET_Option_ConstantAdd
          Text$ = GetGadgetText(#GADGET_Option_ConstantLine)
          index = CountGadgetItems(#GADGET_Option_ConstantList)
          If Text$ <> "" And index < #MAX_Constants-1
            AddGadgetItem(#GADGET_Option_ConstantList, index, Text$)
            SetGadgetItemState(#GADGET_Option_ConstantList, index, #PB_ListIcon_Checked)
            SetGadgetState(#GADGET_Option_ConstantList, index)
          EndIf
          
        Case #GADGET_Option_ConstantSet
          Text$ = GetGadgetText(#GADGET_Option_ConstantLine)
          index = GetGadgetState(#GADGET_Option_ConstantList)
          If Text$ <> "" And index <> -1
            SetGadgetItemText(#GADGET_Option_ConstantList, index, Text$, 0)
          EndIf
          
        Case #GADGET_Option_ConstantRemove
          index = GetGadgetState(#GADGET_Option_ConstantList)
          If index <> -1
            RemoveGadgetItem(#GADGET_Option_ConstantList, index)
            SetGadgetText(#GADGET_Option_ConstantLine, "")
          EndIf
          
        Case #GADGET_Option_ConstantClear
          ClearGadgetItems(#GADGET_Option_ConstantList)
          SetGadgetText(#GADGET_Option_ConstantLine, "")
          
        Case #GADGET_Option_TargetList
          State = GetGadgetState(#GADGET_Option_TargetList)
          If State = -1
            ; we must have a selection, so select the default target
            State = 0 ; fallback
            
            ForEach ProjectOptionTargets()
              If ProjectOptionTargets()\IsDefault
                State = ListIndex(ProjectOptionTargets())
                Break
              EndIf
            Next ProjectOptionTargets()
            
            SetGadgetState(#GADGET_Option_TargetList, State)
          EndIf
          
          SelectElement(ProjectOptionTargets(), State)
          
          ; don't need to do anything when the selection did not change
          If *Options_CurrentTarget <> @ProjectOptionTargets()
            If *Options_CurrentTarget
              GetTargetOptions(*Options_CurrentTarget) ; save old options
            EndIf
            *Options_CurrentTarget = @ProjectOptionTargets()
            SetTargetOptions(*Options_CurrentTarget) ; set new options
          EndIf
          
          UpdateTargetGadgets()
          
          ; Display popupmenu if needed
          If EventType() = #PB_EventType_RightClick
            DisplayPopupMenu(#POPUPMENU_Options, WindowID(#WINDOW_Option))
          EndIf
          
        Case #GADGET_Option_AddTarget
          Name$ = Trim(InputRequester(Language("Compiler","AddTarget"), Language("Compiler","EnterTargetName"), Language("Compiler","NewTargetName")))
          If Name$
            found = 0
            ForEach ProjectOptionTargets()
              If UCase(ProjectOptionTargets()\Name$) = Name$
                found = 1
                Break
              EndIf
            Next ProjectOptionTargets()
            
            If found
              MessageRequester(Language("Compiler","OptionsTitle"), Language("Compiler","NameExists"))
            Else
              If *Options_CurrentTarget
                GetTargetOptions(*Options_CurrentTarget) ; save old options
              EndIf
              
              LastElement(ProjectOptionTargets())
              AddElement(ProjectOptionTargets())
              
              ProjectOptionTargets()\ID = GetUniqueID() ; already generate the unique id here (there is no harm if it the user aborts)
              ProjectOptionTargets()\IsProject = #True
              ProjectOptionTargets()\Name$     = Name$
              ProjectOptionTargets()\IsEnabled = #True
              ProjectOptionTargets()\IsDefault = #False
              
              *Options_CurrentTarget = @ProjectOptionTargets()
              SetTargetOptions(*Options_CurrentTarget)
              
              AddGadgetItem(#GADGET_Option_TargetList, -1, Name$, ProjectTargetImage(@ProjectOptionTargets()))
              SetGadgetState(#GADGET_Option_TargetList, CountGadgetItems(#GADGET_Option_TargetList)-1)
              UpdateTargetGadgets()
            EndIf
          EndIf
          
        Case #GADGET_Option_CopyTarget
          State = GetGadgetState(#GADGET_Option_TargetList)
          If State <> -1
            SelectElement(ProjectOptionTargets(), State)
            Name$ = Trim(InputRequester(Language("Compiler","CopyTarget"), Language("Compiler","EnterTargetName"), ProjectOptionTargets()\Name$ + " " + Language("Compiler", "TargetCopySuffix")))
            If Name$
              found = 0
              ForEach ProjectOptionTargets()
                If UCase(ProjectOptionTargets()\Name$) = Name$
                  found = 1
                  Break
                EndIf
              Next ProjectOptionTargets()
              
              If found
                MessageRequester(Language("Compiler","OptionsTitle"), Language("Compiler","NameExists"))
              Else
                If *Options_CurrentTarget
                  GetTargetOptions(*Options_CurrentTarget) ; save old options
                EndIf
                
                ; Copy the whole structure to the end of the list
                ; We need a dummy temp element, as we cannot do CopyStructure across different elements else
                SelectElement(ProjectOptionTargets(), State)
                Temp.CompileTarget = ProjectOptionTargets()
                LastElement(ProjectOptionTargets())
                AddElement(ProjectOptionTargets())
                ProjectOptionTargets() = Temp
                
                ProjectOptionTargets()\ID = GetUniqueID() ; make sure the new target get its own unique id
                ProjectOptionTargets()\Name$     = Name$
                ProjectOptionTargets()\IsDefault = #False ; there can be only 1 default
                
                *Options_CurrentTarget = @ProjectOptionTargets()
                SetTargetOptions(*Options_CurrentTarget)
                
                AddGadgetItem(#GADGET_Option_TargetList, -1, Name$, ProjectTargetImage(@ProjectOptionTargets()))
                SetGadgetState(#GADGET_Option_TargetList, CountGadgetItems(#GADGET_Option_TargetList)-1)
                UpdateTargetGadgets()
              EndIf
            EndIf
          EndIf
          
        Case #GADGET_Option_EditTarget
          State = GetGadgetState(#GADGET_Option_TargetList)
          If State <> -1
            SelectElement(ProjectOptionTargets(), State)
            Name$ = Trim(InputRequester(Language("Compiler","EditTarget"), Language("Compiler","EnterTargetName"), ProjectOptionTargets()\Name$))
            If Name$ <> ""
              ForEach ProjectOptionTargets()
                If ListIndex(ProjectOptionTargets()) <> State And UCase(Name$) = UCase(ProjectOptionTargets()\Name$)
                  found = 1
                  Break
                EndIf
              Next ProjectOptionTargets()
              SelectElement(ProjectOptionTargets(), State)
              
              If found
                MessageRequester(Language("Compiler","OptionsTitle"), Language("Compiler","NameExists"))
              Else
                ProjectOptionTargets()\Name$ = Name$
                SetGadgetItemText(#GADGET_Option_TargetList, State, Name$, 0)
              EndIf
            EndIf
          EndIf
          
        Case #GADGET_Option_RemoveTarget
          State = GetGadgetState(#GADGET_Option_TargetList)
          ; cannot delete the last target
          If State <> -1 And ListSize(ProjectOptionTargets()) > 1 And MessageRequester(Language("Compiler","OptionsTitle"), Language("Compiler","ConfirmTargetDelete"), #PB_MessageRequester_YesNo|#FLAG_Question) = #PB_MessageRequester_Yes
            If State > 0
              NewState = State - 1
            Else
              NewState = 0
            EndIf
            
            SelectElement(ProjectOptionTargets(), State)
            IsDefault = ProjectOptionTargets()\IsDefault
            
            DeleteElement(ProjectOptionTargets())
            RemoveGadgetItem(#GADGET_Option_TargetList, State)
            
            ; If the old target was the default, set a new one
            If IsDefault
              SelectElement(ProjectOptionTargets(), 0)
              ProjectOptionTargets()\IsDefault = #True
              SetGadgetItemImage(#GADGET_Option_TargetList, 0, ProjectTargetImage(@ProjectOptionTargets()))
            EndIf
            
            ; We need a new current element always
            ;
            SetGadgetState(#GADGET_Option_TargetList, NewState)
            SelectElement(ProjectOptionTargets(), NewState)
            *Options_CurrentTarget = @ProjectOptionTargets()
            SetTargetOptions(*Options_CurrentTarget)
            UpdateTargetGadgets()
          EndIf
          
        Case #GADGET_Option_TargetUp
          State = GetGadgetState(#GADGET_Option_TargetList)
          If State > 0
            SelectElement(ProjectOptionTargets(), State)
            *Current = @ProjectOptionTargets()
            If PreviousElement(ProjectOptionTargets())
              SwapElements(ProjectOptionTargets(), @ProjectOptionTargets(), *Current)
              
              SelectElement(ProjectOptionTargets(), State-1)
              SetGadgetItemText(#GADGET_Option_TargetList, State-1, ProjectOptionTargets()\Name$, 0)
              SetGadgetItemImage(#GADGET_Option_TargetList, State-1, ProjectTargetImage(@ProjectOptionTargets()))
              
              SelectElement(ProjectOptionTargets(), State)
              SetGadgetItemText(#GADGET_Option_TargetList, State, ProjectOptionTargets()\Name$, 0)
              SetGadgetItemImage(#GADGET_Option_TargetList, State, ProjectTargetImage(@ProjectOptionTargets()))
              
              ; We end up with the same selection as before, so no change in the displayed target
              SetGadgetState(#GADGET_Option_TargetList, State-1)
              UpdateTargetGadgets()
            EndIf
          EndIf
          
        Case #GADGET_Option_TargetDown
          State = GetGadgetState(#GADGET_Option_TargetList)
          If State <> -1 And State < ListSize(ProjectOptionTargets())-1
            SelectElement(ProjectOptionTargets(), State)
            *Current = @ProjectOptionTargets()
            If NextElement(ProjectOptionTargets())
              SwapElements(ProjectOptionTargets(), @ProjectOptionTargets(), *Current)
              
              SelectElement(ProjectOptionTargets(), State+1)
              SetGadgetItemText(#GADGET_Option_TargetList, State+1, ProjectOptionTargets()\Name$, 0)
              SetGadgetItemImage(#GADGET_Option_TargetList, State+1, ProjectTargetImage(@ProjectOptionTargets()))
              
              SelectElement(ProjectOptionTargets(), State)
              SetGadgetItemText(#GADGET_Option_TargetList, State, ProjectOptionTargets()\Name$, 0)
              SetGadgetItemImage(#GADGET_Option_TargetList, State, ProjectTargetImage(@ProjectOptionTargets()))
              
              ; We end up with the same selection as before, so no change in the displayed target
              SetGadgetState(#GADGET_Option_TargetList, State+1)
              UpdateTargetGadgets()
            EndIf
          EndIf
          
        Case #GADGET_Option_DefaultTarget, #GADGET_Option_DefaultTargetMenu
          State = GetGadgetState(#GADGET_Option_TargetList)
          If State <> -1
            SelectElement(ProjectOptionTargets(), State)
            
            Selected = GetGadgetState(#GADGET_Option_DefaultTarget)
            
            ; If it was menu action, the gadget state did not change, so reverse it ourselves
            If GadgetID = #GADGET_Option_DefaultTargetMenu
              Selected = 1-Selected
            EndIf
            
            If Selected
              ProjectOptionTargets()\IsDefault = #True
              SetGadgetItemImage(#GADGET_Option_TargetList, State, ProjectTargetImage(@ProjectOptionTargets()))
              
              ForEach ProjectOptionTargets()
                If ListIndex(ProjectOptionTargets()) <> State
                  ProjectOptionTargets()\IsDefault = #False
                  SetGadgetItemImage(#GADGET_Option_TargetList, ListIndex(ProjectOptionTargets()), ProjectTargetImage(@ProjectOptionTargets()))
                EndIf
              Next ProjectOptionTargets()
            Else
              If ListSize(ProjectOptionTargets()) = 1
                SetGadgetState(#GADGET_Option_TargetList, #True) ; cannot unset this if it is the only target
              Else
                ProjectOptionTargets()\IsDefault = #False
                SetGadgetItemImage(#GADGET_Option_TargetList, ListIndex(ProjectOptionTargets()), ProjectTargetImage(@ProjectOptionTargets()))
                
                ; select a different target as default, as there must always be one
                If State = 0
                  NextElement(ProjectOptionTargets())
                Else
                  FirstElement(ProjectOptionTargets())
                EndIf
                ProjectOptionTargets()\IsDefault = #True
                SetGadgetItemImage(#GADGET_Option_TargetList, ListIndex(ProjectOptionTargets()), ProjectTargetImage(@ProjectOptionTargets()))
              EndIf
              
            EndIf
          EndIf
          
          UpdateTargetGadgets() ; sync the menu states
          
        Case #GADGET_Option_TargetEnabled, #GADGET_Option_TargetEnabledMenu
          State = GetGadgetState(#GADGET_Option_TargetList)
          If State <> -1
            SelectElement(ProjectOptionTargets(), State)
            ProjectOptionTargets()\IsEnabled = GetGadgetState(#GADGET_Option_TargetEnabled)
            
            ; If it was menu action, the gadget state did not change, so reverse it ourselves
            If GadgetID = #GADGET_Option_TargetEnabledMenu
              ProjectOptionTargets()\IsEnabled = 1-ProjectOptionTargets()\IsEnabled
            EndIf
            
            SetGadgetItemImage(#GADGET_Option_TargetList, State, ProjectTargetImage(@ProjectOptionTargets()))
          EndIf
          
          UpdateTargetGadgets() ; sync the menu states
          
        Case #GADGET_Option_OpenProject
          OpenProjectOptions(#False) ; no new project
          
          CompilerIf #CompileWindows And Not #SpiderBasic
            
          Case #GADGET_Option_EnableAdmin
            If GetGadgetState(#GADGET_Option_EnableAdmin)
              SetGadgetState(#GADGET_Option_EnableUser, 0) ; both cannot be set at once
            EndIf
            
          Case #GADGET_Option_EnableUser
            If GetGadgetState(#GADGET_Option_EnableUser)
              SetGadgetState(#GADGET_Option_EnableAdmin, 0) ; both cannot be set at once
            EndIf
            
          Case #GADGET_Option_IncludeVersion
            DisableOptionGadgets()
            
          Case #GADGET_Option_ResourceAdd
            File$ = GetGadgetText(#GADGET_Option_ResourceFile)
            If File$ <> ""
              AddGadgetItem(#GADGET_Option_ResourceList, -1, File$)
              SetGadgetState(#GADGET_Option_ResourceList, CountGadgetItems(#GADGET_Option_ResourceList)-1)
              SetGadgetText(#GADGET_Option_ResourceFile, "")
            EndIf
            
          Case #GADGET_Option_ResourceRemove
            index = GetGadgetState(#GADGET_Option_ResourceList)
            If index <> -1
              RemoveGadgetItem(#GADGET_Option_ResourceList, index)
            EndIf
            
          Case #GADGET_Option_ResourceClear
            ClearGadgetItems(#GADGET_Option_ResourceList)
            
          Case #GADGET_Option_ResourceSelectFile
            File$ = ResolveRelativePath(Options_CurrentBasePath$, GetGadgetText(#GADGET_Option_ResourceFile))
            If File$ = ""
              File$ = Options_CurrentBasePath$
            EndIf
            
            File$ = OpenFileRequester(Language("Resources","OpenResource"), File$, Language("Resources","ResourcePattern"), 0)
            If File$ <> ""
              SetGadgetText(#GADGET_Option_ResourceFile, CreateRelativePath(Options_CurrentBasePath$, File$))
            EndIf
            
          Case #GADGET_Option_Tokens
            Text$ = ""
            For i = 0 To 4
              Text$ + Language("Resources","Token"+Str(i)) + #NewLine
            Next i
            Text$ + Language("Resources","DateTokens")
            MessageRequester(Language("Resources","Tokens"), Text$, #FLAG_Info)
            
          CompilerEndIf
          
      EndSelect
  EndSelect
  
  If Quit = 1
    If MemorizeWindow
      If Options_IsProjectMode
        OptionWindowDialog\Close(@ProjectOptionWindowPosition)
      Else
        OptionWindowDialog\Close(@OptionWindowPosition)
      EndIf
    Else
      OptionWindowDialog\Close()
    EndIf
    
    ; Re-enable this so the user can make changes again
    DisableMenuItem(#MENU, #MENU_Debugger, #False)
    UpdateProjectInfo()
  EndIf
  
EndProcedure

Procedure UpdateOptionWindow()
  
  ; Update the compiler list
  ;
  If GetGadgetState(#GADGET_Option_UseCompiler)
    OldSelection$ = GetGadgetText(#GADGET_Option_SelectCompiler)
  EndIf
  
  ClearGadgetItems(#GADGET_Option_SelectCompiler)
  AddGadgetItem(#GADGET_Option_SelectCompiler, -1, DefaultCompiler\VersionString$)
  ForEach Compilers()
    If Compilers()\Validated
      AddGadgetItem(#GADGET_Option_SelectCompiler, -1, Compilers()\VersionString$)
      SetGadgetItemData(#GADGET_Option_SelectCompiler, CountGadgetItems(#GADGET_Option_SelectCompiler)-1, @Compilers())
    EndIf
  Next Compilers()
  
  If GetGadgetState(#GADGET_Option_UseCompiler)
    ; find a matching compiler
    *Compiler.Compiler = FindCompiler(OldSelection$)
    
    If *Compiler = 0
      MessageRequester(#ProductName$, Language("Compiler","CompilerNotFound")+":"+#NewLine+OldSelection$, #FLAG_Warning)
      SetGadgetState(#GADGET_Option_SelectCompiler, 0)
    ElseIf *Compiler = @DefaultCompiler
      SetGadgetState(#GADGET_Option_SelectCompiler, 0)
    Else
      ; one of them must match, as FindCompiler() returned something
      last = CountGadgetItems(#GADGET_Option_SelectCompiler)
      For index = 1 To last
        If GetGadgetItemData(#GADGET_Option_SelectCompiler, index) = *Compiler
          SetGadgetState(#GADGET_Option_SelectCompiler, index)
          Break
        EndIf
      Next index
    EndIf
  Else
    SetGadgetState(#GADGET_Option_SelectCompiler, 0)
  EndIf
  
  
  If Options_IsProjectMode
    ; Re-apply the images for theme changes
    ;
    SetGadgetAttribute(#GADGET_Option_AddTarget,    #PB_Button_Image, ImageID(#IMAGE_Option_AddTarget))
    SetGadgetAttribute(#GADGET_Option_EditTarget,   #PB_Button_Image, ImageID(#IMAGE_Option_EditTarget))
    SetGadgetAttribute(#GADGET_Option_CopyTarget,   #PB_Button_Image, ImageID(#IMAGE_Option_CopyTarget))
    SetGadgetAttribute(#GADGET_Option_RemoveTarget, #PB_Button_Image, ImageID(#IMAGE_Option_RemoveTarget))
    SetGadgetAttribute(#GADGET_Option_TargetUp,     #PB_Button_Image, ImageID(#IMAGE_Option_TargetUp))
    SetGadgetAttribute(#GADGET_Option_TargetDown,   #PB_Button_Image, ImageID(#IMAGE_Option_TargetDown))
    
    GadgetToolTip(#GADGET_Option_AddTarget,    Language("Compiler","AddTarget"))
    GadgetToolTip(#GADGET_Option_EditTarget,   Language("Compiler","RenameTarget"))
    GadgetToolTip(#GADGET_Option_CopyTarget,   Language("Compiler","CopyTarget"))
    GadgetToolTip(#GADGET_Option_RemoveTarget, Language("Compiler","RemoveTarget"))
    GadgetToolTip(#GADGET_Option_TargetUp,     Language("Compiler","TargetUp"))
    GadgetToolTip(#GADGET_Option_TargetDown,   Language("Compiler","TargetDown"))
    
    ; Re-create the popup menu with new images/text
    ;
    If EnableMenuIcons
      *Popup = CreatePopupImageMenu(#POPUPMENU_Options)
    Else
      *Popup = CreatePopupMenu(#POPUPMENU_Options)
    EndIf
    
    ; Re-use the gadget ids for the menu for simplicity (same as for the shortcuts)
    If *Popup
      MenuItem(#GADGET_Option_AddTarget,     Language("Compiler","AddTarget"),    ImageID(#IMAGE_Option_AddTarget))
      MenuItem(#GADGET_Option_CopyTarget,    Language("Compiler","CopyTarget"),   ImageID(#IMAGE_Option_CopyTarget))
      MenuItem(#GADGET_Option_EditTarget,    Language("Compiler","EditTarget"),   ImageID(#IMAGE_Option_EditTarget))
      MenuBar()
      MenuItem(#GADGET_Option_RemoveTarget,  Language("Compiler","RemoveTarget"), ImageID(#IMAGE_Option_RemoveTarget))
      MenuBar()
      MenuItem(#GADGET_Option_TargetUp,      Language("Compiler","TargetUp"),     ImageID(#IMAGE_Option_TargetUp))
      MenuItem(#GADGET_Option_TargetDown,    Language("Compiler","TargetDown"),   ImageID(#IMAGE_Option_TargetDown))
      MenuBar()
      MenuItem(#GADGET_Option_DefaultTargetMenu, Language("Compiler","DefaultTarget"))
      MenuItem(#GADGET_Option_TargetEnabledMenu, Language("Compiler","EnableTarget"))
    EndIf
    
    ; apply enabled/disabled states to this new popup menu
    UpdateTargetGadgets()
    
    ; apply theme changes to the list of targets too
    ForEach ProjectOptionTargets()
      SetGadgetItemImage(#GADGET_Option_TargetList, ListIndex(ProjectOptionTargets()), ProjectTargetImage(@ProjectOptionTargets()))
    Next ProjectOptionTargets()
  EndIf
  
  OptionWindowDialog\LanguageUpdate()
  OptionWindowDialog\GuiUpdate()
EndProcedure
