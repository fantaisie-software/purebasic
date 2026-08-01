;
; ------------------------------------------------------------
;
;   PureBasic - Some Pb Compiler, FileSystem and system data
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;
Debug "Compiler:"
Debug "*********"
If #PB_Compiler_OS = #PB_OS_Windows:Debug "#PB_Compiler_OS = #PB_OS_Windows":EndIf
If #PB_Compiler_OS = #PB_OS_Linux:Debug "#PB_Compiler_OS = #PB_OS_Linux":EndIf
If #PB_Compiler_OS = #PB_OS_MacOS:Debug "#PB_Compiler_OS = #PB_OS_MacOS":EndIf

If #PB_Compiler_Processor = #PB_Processor_x86:Debug "#PB_Compiler_Processor = #PB_Processor_x86":EndIf
If #PB_Compiler_Processor = #PB_Processor_x64:Debug "#PB_Compiler_Processor = #PB_Processor_x64":EndIf

If #PB_Compiler_ExecutableFormat = #PB_Compiler_Executable:Debug "#PB_Compiler_ExecutableFormat = #PB_Compiler_Executable":EndIf
If #PB_Compiler_ExecutableFormat = #PB_Compiler_Console:Debug "#PB_Compiler_ExecutableFormat = #PB_Compiler_Console":EndIf
If #PB_Compiler_ExecutableFormat = #PB_Compiler_DLL:Debug "#PB_Compiler_ExecutableFormat = #PB_Compiler_DLL":EndIf

Debug "#PB_Compiler_Date: " + FormatDate("%yyyy,%mm,%dd",#PB_Compiler_Date)
Debug "#PB_Compiler_File: "       + #PB_Compiler_File
Debug "#PB_Compiler_FilePath: "   + #PB_Compiler_FilePath
Debug "#PB_Compiler_Line: "       + #PB_Compiler_Line
Debug "#PB_Compiler_Procedure: "  + #PB_Compiler_Procedure
Debug "#PB_Compiler_Module: "     + #PB_Compiler_Module
Debug "#PB_Compiler_Version: "    + #PB_Compiler_Version
Debug "#PB_Compiler_Home: "       + #PB_Compiler_Home
Debug "#PB_Compiler_Debugger: "   + #PB_Compiler_Debugger
Debug "#PB_Compiler_Thread: "     + #PB_Compiler_Thread
Debug "#PB_Compiler_Unicode: "    + #PB_Compiler_Unicode
Debug "#PB_Compiler_LineNumbering: "  + #PB_Compiler_LineNumbering
Debug "#PB_Compiler_InlineAssembly: " + #PB_Compiler_InlineAssembly
Debug "#PB_Compiler_EnableExplicit: " + #PB_Compiler_EnableExplicit
Debug "#PB_Compiler_IsMainFile: "     + #PB_Compiler_IsMainFile
Debug "#PB_Compiler_IsIncludeFile: "  + #PB_Compiler_IsIncludeFile

Debug ""
Debug "File Sytem :"
Debug "************"
Debug "GetCurrentDirectory(): " + GetCurrentDirectory()
Debug "GetHomeDirectory(): " + GetHomeDirectory()
Debug "GetTemporaryDirectory(): " + GetTemporaryDirectory()
Debug "GetUserDirectory(#PB_Directory_Documents): "   + GetUserDirectory(#PB_Directory_Documents)
Debug "GetUserDirectory(#PB_Directory_Downloads): "   + GetUserDirectory(#PB_Directory_Downloads)
Debug "GetUserDirectory(#PB_Directory_Documents): "   + GetUserDirectory(#PB_Directory_Documents)
Debug "GetUserDirectory(#PB_Directory_Pictures): "    + GetUserDirectory(#PB_Directory_Pictures)
Debug "GetUserDirectory(#PB_Directory_Musics): "      + GetUserDirectory(#PB_Directory_Musics)
Debug "GetUserDirectory(#PB_Directory_Videos): "      + GetUserDirectory(#PB_Directory_Videos)
Debug "GetUserDirectory(#PB_Directory_Public): "      + GetUserDirectory(#PB_Directory_Public)
Debug "GetUserDirectory(#PB_Directory_ProgramData): " + GetUserDirectory(#PB_Directory_ProgramData)

Debug "GetUserDirectory(#PB_Directory_AllUserData): " + GetUserDirectory(#PB_Directory_AllUserData)
Debug "GetUserDirectory(#PB_Directory_Programs): "    + GetUserDirectory(#PB_Directory_Programs)

Debug ""
Debug "Sytem :"
Debug "*******"
Debug "CPUName(): " +  CPUName()
Debug "ComputerName(): " + ComputerName()
Debug "CountCPUs(#PB_System_CPUs): " + CountCPUs(#PB_System_CPUs)
Debug "CountCPUs(#PB_System_ProcessCPUs): " + CountCPUs(#PB_System_ProcessCPUs)
Debug "DoubleClickTime(): " + DoubleClickTime()
Debug "ElapsedMilliseconds(): " + ElapsedMilliseconds()
Debug "MemoryStatus(#PB_System_TotalPhysical): " + MemoryStatus(#PB_System_TotalPhysical)
Debug "MemoryStatus(#PB_System_FreePhysical): " + MemoryStatus(#PB_System_FreePhysical)
Debug "MemoryStatus(#PB_System_PageSize): " + MemoryStatus(#PB_System_PageSize)
Debug "MemoryStatus(#PB_System_TotalSwap) (Windows & Linux): " + MemoryStatus(#PB_System_TotalSwap)
Debug "MemoryStatus(#PB_System_FreeSwap) (Windows & Linux): " + MemoryStatus(#PB_System_FreeSwap)
Debug "MemoryStatus(#PB_System_TotalVirtual) (Windows): " + MemoryStatus(#PB_System_TotalVirtual)
Debug "MemoryStatus(#PB_System_FreeVirtual) (Windows): " + MemoryStatus(#PB_System_FreeVirtual)
Debug "OSVersion(): "
Select OSVersion()
    ;Windows
  Case #PB_OS_Windows_NT3_51:Debug "#PB_OS_Windows_NT3_51"
  Case #PB_OS_Windows_95:Debug "#PB_OS_Windows_95"
  Case #PB_OS_Windows_NT_4:Debug "#PB_OS_Windows_NT_4"
  Case #PB_OS_Windows_98:Debug "#PB_OS_Windows_98"
  Case #PB_OS_Windows_ME:Debug "#PB_OS_Windows_ME"
  Case #PB_OS_Windows_2000:Debug "#PB_OS_Windows_2000"
  Case #PB_OS_Windows_XP:Debug "#PB_OS_Windows_XP"
  Case #PB_OS_Windows_Server_2003:Debug "#PB_OS_Windows_Server_2003"
  Case #PB_OS_Windows_Vista:Debug "#PB_OS_Windows_Vista"
  Case #PB_OS_Windows_Server_2008:Debug "#PB_OS_Windows_Server_2008"
  Case #PB_OS_Windows_7:Debug "#PB_OS_Windows_7"
  Case #PB_OS_Windows_Server_2008_R2:Debug "#PB_OS_Windows_Server_2008_R2"
  Case #PB_OS_Windows_8:Debug "#PB_OS_Windows_8"
  Case #PB_OS_Windows_Server_2012:Debug "#PB_OS_Windows_Server_2012"
  Case #PB_OS_Windows_8_1:Debug "#PB_OS_Windows_8_1"
  Case #PB_OS_Windows_Server_2012_R2:Debug "#PB_OS_Windows_Server_2012_R2"
  Case #PB_OS_Windows_10:Debug "#PB_OS_Windows_10"
  Case #PB_OS_Windows_Server_2016:Debug "#PB_OS_Windows_Server_2016"
  Case #PB_OS_Windows_Server_2019:Debug "#PB_OS_Windows_Server_2019"
  Case #PB_OS_Windows_Server_2022:Debug " #PB_OS_Windows_Server_2022"
  Case #PB_OS_Windows_11:Debug "#PB_OS_Windows_11"
  Case #PB_OS_Windows_Server_2025:Debug "#PB_OS_Windows_Server_2025"
  Case #PB_OS_Windows_Future:Debug "#PB_OS_Windows_Future"
    
    ;Linux
  Case #PB_OS_Linux_2_2:Debug "#PB_OS_Linux_2_2"
  Case #PB_OS_Linux_2_4:Debug "#PB_OS_Linux_2_4"
  Case #PB_OS_Linux_2_6:Debug "#PB_OS_Linux_2_6"
  Case #PB_OS_Linux_Future:Debug "#PB_OS_Linux_Future"
    
    ;MacOSX
  Case #PB_OS_MacOSX_10_0:Debug "#PB_OS_MacOSX_10_0"
  Case #PB_OS_MacOSX_10_1:Debug "#PB_OS_MacOSX_10_1"
  Case #PB_OS_MacOSX_10_2:Debug "#PB_OS_MacOSX_10_2"
  Case #PB_OS_MacOSX_10_3:Debug "#PB_OS_MacOSX_10_3"
  Case #PB_OS_MacOSX_10_4:Debug "#PB_OS_MacOSX_10_4"
  Case #PB_OS_MacOSX_10_5:Debug "#PB_OS_MacOSX_10_5"
  Case #PB_OS_MacOSX_10_6:Debug "#PB_OS_MacOSX_10_6"
  Case #PB_OS_MacOSX_10_7:Debug "#PB_OS_MacOSX_10_7"
  Case #PB_OS_MacOSX_10_8:Debug "#PB_OS_MacOSX_10_8"
  Case #PB_OS_MacOSX_10_9:Debug "#PB_OS_MacOSX_10_9"
  Case #PB_OS_MacOSX_10_10:Debug "#PB_OS_MacOSX_10_10"
  Case #PB_OS_MacOSX_10_11:Debug "#PB_OS_MacOSX_10_11"
  Case #PB_OS_MacOSX_Future:Debug "#PB_OS_MacOSX_Future"
    
  Default
    Debug "Unknown"
EndSelect

Debug "UserName(): " + UserName()
