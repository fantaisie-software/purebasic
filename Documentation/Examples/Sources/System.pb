;
; ------------------------------------------------------------
;
;   PureBasic - System example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

MessageRequester("System information", "User: " + UserName() + #LF$ +
                                       "Computer name: " + ComputerName() + #LF$ +
                                       "NbCPUs: " + CountCPUs() + #LF$ +
                                       "Physical memory: " + Str(MemoryStatus(#PB_System_TotalPhysical) / (1024 * 1024)) + " MB")
