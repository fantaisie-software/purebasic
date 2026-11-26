
; IConfigAsfWriter interface definition
;
Interface IConfigAsfWriter Extends IUnknown
  ConfigureFilterUsingProfileId(a.l)
  GetCurrentProfileId(a.l)
  ConfigureFilterUsingProfileGuid(a.l)
  GetCurrentProfileGuid(a.l)
  ConfigureFilterUsingProfile(a.l)
  GetCurrentProfile(a.l)
  SetIndexMode(a.l)
  GetIndexMode(a.l)
EndInterface
