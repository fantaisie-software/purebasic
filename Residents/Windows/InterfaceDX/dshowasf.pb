
; IConfigAsfWriter interface definition
;
Interface IConfigAsfWriter
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  ConfigureFilterUsingProfileId(a.l)
  GetCurrentProfileId(a.l)
  ConfigureFilterUsingProfileGuid(a.l)
  GetCurrentProfileGuid(a.l)
  ConfigureFilterUsingProfile(a.l)
  GetCurrentProfile(a.l)
  SetIndexMode(a.l)
  GetIndexMode(a.l)
EndInterface
