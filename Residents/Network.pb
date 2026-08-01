; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

CompilerSelect #PB_Compiler_OS
  CompilerCase #PB_OS_Linux
    #AF_INET6 = 10
  CompilerCase #PB_OS_MacOS
    #AF_INET6 = 30
  CompilerCase #PB_OS_Windows
    #AF_INET6 = 23
CompilerEndSelect

Structure in6_addr Align #PB_Structure_AlignC
  StructureUnion
    s6_addr.a[16]
    s6_addr16.u[8]
    s6_addr32.l[4]
  EndStructureUnion
EndStructure

Structure sockaddr_in6 Align #PB_Structure_AlignC
  CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
    sin6_len.a
    sin6_family.a
  CompilerElse
    sin6_family.u
  CompilerEndIf
  sin6_port.u
  sin6_flowinfo.l
  sin6_addr.in6_addr
  sin6_scope_id.l
EndStructure
