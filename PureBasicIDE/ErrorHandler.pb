; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

; Do not use OnError if the real debugger is present (for better debugging)
; Note: OnError() isn't supported on Windows arm64 for now so disable it
CompilerIf #PB_Compiler_Debugger = 0 And (#CompileWindows = 0 Or #PB_Compiler_Processor <> #PB_Processor_Arm64)
  
  ErrorHandler_Called = #False
  
  Goto ErrorHandler_End
  
  ErrorHandler:
  If ErrorHandler_Called  ; avoid changed calls if something goes wrong in here too
    End
  EndIf
  ErrorHandler_Called = #True
  
  CompilerIf #DEBUG
    Message$ = "Error: " + ErrorMessage() + #NewLine
    Message$ + "File : " + ErrorFile() + #NewLine
    Message$ + "Line : " + Str(ErrorLine()) + #NewLine
  CompilerElse
    Message$ = "An Error has been detected in the IDE!" + #NewLine
    Message$ + "Error: " + ErrorMessage() + #NewLine
    If ErrorLine() <> -1
      Message$ + "File : " + ErrorFile() + #NewLine
      Message$ + "Line : " + Str(ErrorLine()) + #NewLine
    EndIf
  CompilerEndIf
  
  Message$ + #NewLine
  Message$ + "IDE build on " + FormatDate("%mm/%dd/%yyyy [%hh:%ii]", #PB_Compiler_Date) + " by " + #BUILDINFO_User + #NewLine
  Message$ + "Branch: " + #BUILDINFO_Branch + "  Revision: " + #BUILDINFO_Revision
  
  
  MessageRequester("Error", Message$, #FLAG_Error)
  
  If (CompilerProgram)
    KillProgram(CompilerProgram)
    CloseProgram(CompilerProgram)
  EndIf
  
  ; delete temporary files to not leave them forever
  DeleteRegisteredFiles()
  CompilerCleanup()
  
  ; NOTE: We do not try to save sourcecodes here, as the reason for this
  ;   crash could have also messed them up. Better to loose the recent changes
  ;   than to loose the whole file, because it was corrupted here.
  ;
  ; A backup functionality should solve this sometime in the future... :)
  End
  
  ErrorHandler_End:
  
  OnErrorGoto(?ErrorHandler)
  
  
CompilerEndIf