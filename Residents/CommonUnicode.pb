; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------
;
; Unicode specific
;

Structure Character
  c.c
EndStructure


;- special ASCII chars (moved to Unicode.res to have the string ones in unicode!)
#NUL = 0
#Empty$ = ""
#SOH$   = Chr(001)  :  #SOH =   1 ;    (Start of Header)
#STX$   = Chr(002)  :  #STX =   2 ;    (Start of Text)
#ETX$   = Chr(003)  :  #ETX =   3 ;    (End of Text)
#EOT$   = Chr(004)  :  #EOT =   4 ;    (End of Transmission)
#ENQ$   = Chr(005)  :  #ENQ =   5 ;    (Enquiry)
#ACK$   = Chr(006)  :  #ACK =   6 ;    (Acknowledgment)
#BEL$   = Chr(007)  :  #BEL =   7 ;    (Bell)
#BS$    = Chr(008)  :  #BS  =   8 ;    (Backspace)
#HT$    = Chr(009)  :  #HT  =   9 ;    (Horizontal Tab)
#TAB$   = Chr(009)  :  #TAB =   9 ;    (TAB)
#LF$    = Chr(010)  :  #LF  =  10 ;    (Line Feed)
#VT$    = Chr(011)  :  #VT  =  11 ;    (Vertical Tab)
#FF$    = Chr(012)  :  #FF  =  12 ;    (Form Feed)
#CR$    = Chr(013)  :  #CR  =  13 ;    (Carriage Return)
#SO$    = Chr(014)  :  #SO  =  14 ;    (Shift Out)
#SI$    = Chr(015)  :  #SI  =  15 ;    (Shift In)
#DLE$   = Chr(016)  :  #DLE =  16 ;    (Data Link Escape)
#DC1$   = Chr(017)  :  #DC1 =  17 ;    (Device Control 1) (XON)
#DC2$   = Chr(018)  :  #DC2 =  18 ;    (Device Control 2)
#DC3$   = Chr(019)  :  #DC3 =  19 ;    (Device Control 3) (XOFF)
#DC4$   = Chr(020)  :  #DC4 =  20 ;    (Device Control 4)
#NAK$   = Chr(021)  :  #NAK =  21 ;    (Negative Acknowledgement)
#SYN$   = Chr(022)  :  #SYN =  22 ;    (Synchronous Idle)
#ETB$   = Chr(023)  :  #ETB =  23 ;    (End of Trans. Block)
#CAN$   = Chr(024)  :  #CAN =  24 ;    (Cancel)
#EM$    = Chr(025)  :  #EM  =  25 ;    (End of Medium)
#SUB$   = Chr(026)  :  #SUB =  26 ;    (Substitute)
#ESC$   = Chr(027)  :  #ESC =  27 ;    (Escape)
#FS$    = Chr(028)  :  #FS  =  28 ;    (File Separator)
#GS$    = Chr(029)  :  #GS  =  29 ;    (Group Separator)
#RS$    = Chr(030)  :  #RS  =  30 ;    (Request to Send)(Record Separator)
#US$    = Chr(031)  :  #US  =  31 ;    (Unit Separator)
#DEL$   = Chr(127)  :  #DEL = 127 ;    (delete)
#CRLF$  = Chr(13) + Chr(10)
#LFCR$  = Chr(10) + Chr(13)
#DOUBLEQUOTE$ = Chr(34)
#DQUOTE$      = Chr(34)

; Path separator constants
;
CompilerIf (#PB_Compiler_OS = #PB_OS_Windows)
  #PS  = '\'
  #NPS = '/'
CompilerElse
  #PS  = '/'
  #NPS = '\'
CompilerEndIf

#PS$  = Chr(#PS)
#NPS$ = Chr(#NPS)
