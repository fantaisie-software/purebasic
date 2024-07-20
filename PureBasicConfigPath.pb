; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


; -----------------------------------------------------------------
;
; Returns the Path where to store PureBasic specific config files
;   On Windows  : %UsersDir%\ApplicationData\PureBasic
;   On Linux/Mac: %home%\.purebasic\
;
; Also ensures that the returned path exists.
;
; This function should be used by all tools in the PureBasic package
; to ensure a consistent place where config files are stored.
;
; -----------------------------------------------------------------

CompilerIf Not Defined(SpiderBasic, #PB_Constant)
  #SpiderBasic = 0
CompilerEndIf


Procedure.s PureBasicConfigPath()
  Static ConfigPath$
  
  ; We cache the value for multiple uses within a program
  If ConfigPath$ <> ""
    ProcedureReturn ConfigPath$
  EndIf
  
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    Protected pidl, Index
    
    #CSIDL_APPDATA = $001a
    ConfigPath$ = GetHomeDirectory() ; fallback option if the below fails (no IE4 present)
    
    If SHGetSpecialFolderLocation_(0, #CSIDL_APPDATA, @pidl) = #S_OK
      ConfigPath$ = Space(#MAX_PATH)
      If SHGetPathFromIDList_(pidl, @ConfigPath$) = 0
        ConfigPath$ = GetHomeDirectory()
      EndIf
    EndIf
    
    CompilerIf #SpiderBasic
      If Right(ConfigPath$, 1) <> "\"
        ConfigPath$ + "\SpiderBasic\"
      Else
        ConfigPath$ + "SpiderBasic\"
      EndIf
      
    CompilerElse
      If Right(ConfigPath$, 1) <> "\"
        ConfigPath$ + "\PureBasic\"
      Else
        ConfigPath$ + "PureBasic\"
      EndIf
    CompilerEndIf
    
    ; Ensure that the path exists
    ; Must check all parents too, as CreateDirectory() fails else
    ;
    If FileSize(ConfigPath$) <> -2
      Index = 3 ; the drive surely exists
      While FindString(ConfigPath$, "\", Index+1) > 0
        Index = FindString(ConfigPath$, "\", Index+1)
        If FileSize(Left(ConfigPath$, Index)) <> -2
          If CreateDirectory(Left(ConfigPath$, Index)) = 0
            Break
          EndIf
        EndIf
      Wend
    EndIf
    
  CompilerElse
    
    CompilerIf #SpiderBasic
      ConfigPath$ = GetHomeDirectory() + ".spiderbasic/"
      
    CompilerElse
      ConfigPath$ = GetHomeDirectory() + ".purebasic/"
    CompilerEndIf
    
    ; Note: no recursive creation needed here, as the home dir should
    ; be existent already and we go only one level below that.
    ;
    If FileSize(ConfigPath$) <> -2
      CreateDirectory(ConfigPath$)
    EndIf
    
  CompilerEndIf
  
  ProcedureReturn ConfigPath$
EndProcedure

