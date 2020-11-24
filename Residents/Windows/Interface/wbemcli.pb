
; IWbemClassObject interface definition
;
Interface IWbemClassObject
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetQualifierSet(a.l)
  Get(a.l, b.l, c.l, d.l, e.l)
  Put(a.l, b.l, c.l, d.l)
  Delete(a.l)
  GetNames(a.l, b.l, c.l, d.l)
  BeginEnumeration(a.l)
  Next(a.l, b.l, c.l, d.l, e.l)
  EndEnumeration()
  GetPropertyQualifierSet(a.l, b.l)
  Clone(a.l)
  GetObjectText(a.l, b.l)
  SpawnDerivedClass(a.l, b.l)
  SpawnInstance(a.l, b.l)
  CompareTo(a.l, b.l)
  GetPropertyOrigin(a.l, b.l)
  InheritsFrom(a.l)
  GetMethod(a.l, b.l, c.l, d.l)
  PutMethod(a.l, b.l, c.l, d.l)
  DeleteMethod(a.l)
  BeginMethodEnumeration(a.l)
  NextMethod(a.l, b.l, c.l, d.l)
  EndMethodEnumeration()
  GetMethodQualifierSet(a.l, b.l)
  GetMethodOrigin(a.l, b.l)
EndInterface

; IWbemObjectAccess interface definition
;
Interface IWbemObjectAccess
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetQualifierSet(a.l)
  Get(a.l, b.l, c.l, d.l, e.l)
  Put(a.l, b.l, c.l, d.l)
  Delete(a.l)
  GetNames(a.l, b.l, c.l, d.l)
  BeginEnumeration(a.l)
  Next(a.l, b.l, c.l, d.l, e.l)
  EndEnumeration()
  GetPropertyQualifierSet(a.l, b.l)
  Clone(a.l)
  GetObjectText(a.l, b.l)
  SpawnDerivedClass(a.l, b.l)
  SpawnInstance(a.l, b.l)
  CompareTo(a.l, b.l)
  GetPropertyOrigin(a.l, b.l)
  InheritsFrom(a.l)
  GetMethod(a.l, b.l, c.l, d.l)
  PutMethod(a.l, b.l, c.l, d.l)
  DeleteMethod(a.l)
  BeginMethodEnumeration(a.l)
  NextMethod(a.l, b.l, c.l, d.l)
  EndMethodEnumeration()
  GetMethodQualifierSet(a.l, b.l)
  GetMethodOrigin(a.l, b.l)
  GetPropertyHandle(a.l, b.l, c.l)
  WritePropertyValue(a.l, b.l, c.l)
  ReadPropertyValue(a.l, b.l, c.l, d.l)
  ReadDWORD(a.l, b.l)
  WriteDWORD(a.l, b.l)
  ReadQWORD(a.l, b.l)
  WriteQWORD(a.l, b.l)
  GetPropertyInfoByHandle(a.l, b.l, c.l)
  Lock(a.l)
  Unlock(a.l)
EndInterface

; IWbemQualifierSet interface definition
;
Interface IWbemQualifierSet
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Get(a.l, b.l, c.l, d.l)
  Put(a.l, b.l, c.l)
  Delete(a.l)
  GetNames(a.l, b.l)
  BeginEnumeration(a.l)
  Next(a.l, b.l, c.l, d.l)
  EndEnumeration()
EndInterface

; IWbemServices interface definition
;
Interface IWbemServices
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  OpenNamespace(a.l, b.l, c.l, d.l, e.l)
  CancelAsyncCall(a.l)
  QueryObjectSink(a.l, b.l)
  GetObject(a.l, b.l, c.l, d.l, e.l)
  GetObjectAsync(a.l, b.l, c.l, d.l)
  PutClass(a.l, b.l, c.l, d.l)
  PutClassAsync(a.l, b.l, c.l, d.l)
  DeleteClass(a.l, b.l, c.l, d.l)
  DeleteClassAsync(a.l, b.l, c.l, d.l)
  CreateClassEnum(a.l, b.l, c.l, d.l)
  CreateClassEnumAsync(a.l, b.l, c.l, d.l)
  PutInstance(a.l, b.l, c.l, d.l)
  PutInstanceAsync(a.l, b.l, c.l, d.l)
  DeleteInstance(a.l, b.l, c.l, d.l)
  DeleteInstanceAsync(a.l, b.l, c.l, d.l)
  CreateInstanceEnum(a.l, b.l, c.l, d.l)
  CreateInstanceEnumAsync(a.l, b.l, c.l, d.l)
  ExecQuery(a.l, b.l, c.l, d.l, e.l)
  ExecQueryAsync(a.l, b.l, c.l, d.l, e.l)
  ExecNotificationQuery(a.l, b.l, c.l, d.l, e.l)
  ExecNotificationQueryAsync(a.l, b.l, c.l, d.l, e.l)
  ExecMethod(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  ExecMethodAsync(a.l, b.l, c.l, d.l, e.l, f.l)
EndInterface

; IWbemLocator interface definition
;
Interface IWbemLocator
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  ConnectServer(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
EndInterface

; IWbemObjectSink interface definition
;
Interface IWbemObjectSink
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Indicate(a.l, b.l)
  SetStatus(a.l, b.l, c.p-bstr, d.l)
EndInterface

; IEnumWbemClassObject interface definition
;
Interface IEnumWbemClassObject
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Reset()
  Next(a.l, b.l, c.l, d.l)
  NextAsync(a.l, b.l)
  Clone(a.l)
  Skip(a.l, b.l)
EndInterface

; IWbemCallResult interface definition
;
Interface IWbemCallResult
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetResultObject(a.l, b.l)
  GetResultString(a.l, b.l)
  GetResultServices(a.l, b.l)
  GetCallStatus(a.l, b.l)
EndInterface

; IWbemContext interface definition
;
Interface IWbemContext
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Clone(a.l)
  GetNames(a.l, b.l)
  BeginEnumeration(a.l)
  Next(a.l, b.l, c.l)
  EndEnumeration()
  SetValue(a.l, b.l, c.l)
  GetValue(a.l, b.l, c.l)
  DeleteValue(a.l, b.l)
  DeleteAll()
EndInterface

; IUnsecuredApartment interface definition
;
Interface IUnsecuredApartment
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  CreateObjectStub(a.l, b.l)
EndInterface

; IWbemUnsecuredApartment interface definition
;
Interface IWbemUnsecuredApartment
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  CreateObjectStub(a.l, b.l)
  CreateSinkStub(a.l, b.l, c.l, d.l)
EndInterface

; IWbemStatusCodeText interface definition
;
Interface IWbemStatusCodeText
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetErrorCodeText(a.l, b.l, c.l, d.l)
  GetFacilityCodeText(a.l, b.l, c.l, d.l)
EndInterface

; IWbemBackupRestore interface definition
;
Interface IWbemBackupRestore
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Backup(a.l, b.l)
  Restore(a.l, b.l)
EndInterface

; IWbemBackupRestoreEx interface definition
;
Interface IWbemBackupRestoreEx
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Backup(a.l, b.l)
  Restore(a.l, b.l)
  Pause()
  Resume()
EndInterface

; IWbemRefresher interface definition
;
Interface IWbemRefresher
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Refresh(a.l)
EndInterface

; IWbemHiPerfEnum interface definition
;
Interface IWbemHiPerfEnum
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  AddObjects(a.l, b.l, c.l, d.l)
  RemoveObjects(a.l, b.l, c.l)
  GetObjects(a.l, b.l, c.l, d.l)
  RemoveAll(a.l)
EndInterface

; IWbemConfigureRefresher interface definition
;
Interface IWbemConfigureRefresher
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  AddObjectByPath(a.l, b.l, c.l, d.l, e.l, f.l)
  AddObjectByTemplate(a.l, b.l, c.l, d.l, e.l, f.l)
  AddRefresher(a.l, b.l, c.l)
  Remove(a.l, b.l)
  AddEnum(a.l, b.l, c.l, d.l, e.l, f.l)
EndInterface

; IWbemShutdown interface definition
;
Interface IWbemShutdown
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Shutdown(a.l, b.l, c.l)
EndInterface

; IWbemObjectTextSrc interface definition
;
Interface IWbemObjectTextSrc
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetText(a.l, b.l, c.l, d.l, e.l)
  CreateFromText(a.l, b.p-bstr, c.l, d.l, e.l)
EndInterface

; IMofCompiler interface definition
;
Interface IMofCompiler
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  CompileFile(a.p-unicode, b.p-unicode, c.p-unicode, d.p-unicode, e.p-unicode, f.l, g.l, h.l, i.l)
  CompileBuffer(a.l, b.l, c.p-unicode, d.p-unicode, e.p-unicode, f.p-unicode, g.l, h.l, i.l, j.l)
  CreateBMOF(a.p-unicode, b.p-unicode, c.p-unicode, d.l, e.l, f.l, g.l)
EndInterface
