
; IGPEInformation interface definition
;
Interface IGPEInformation
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetName(a.l, b.l)
  GetDisplayName(a.l, b.l)
  GetRegistryKey(a.l, b.l)
  GetDSPath(a.l, b.l, c.l)
  GetFileSysPath(a.l, b.l, c.l)
  GetOptions(a.l)
  GetType(a.l)
  GetHint(a.l)
  PolicyChanged(a.l, b.l, c.l, d.l)
EndInterface

; IGroupPolicyObject interface definition
;
Interface IGroupPolicyObject
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  New(a.l, b.l, c.l)
  OpenDSGPO(a.l, b.l)
  OpenLocalMachineGPO(a.l)
  OpenRemoteMachineGPO(a.l, b.l)
  Save(a.l, b.l, c.l, d.l)
  Delete()
  GetName(a.l, b.l)
  GetDisplayName(a.l, b.l)
  SetDisplayName(a.l)
  GetPath(a.l, b.l)
  GetDSPath(a.l, b.l, c.l)
  GetFileSysPath(a.l, b.l, c.l)
  GetRegistryKey(a.l, b.l)
  GetOptions(a.l)
  SetOptions(a.l, b.l)
  GetType(a.l)
  GetMachineName(a.l, b.l)
  GetPropertySheetPages(a.l, b.l)
EndInterface

; IRSOPInformation interface definition
;
Interface IRSOPInformation
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetNamespace(a.l, b.l, c.l)
  GetFlags(a.l)
  GetEventLogEntryText(a.l, b.l, c.l, d.l, e.l)
EndInterface
