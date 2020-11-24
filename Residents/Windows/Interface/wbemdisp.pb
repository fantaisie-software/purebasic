
; ISWbemServices interface definition
;
Interface ISWbemServices
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  Get(a.p-bstr, b.l, c.l, d.l)
  GetAsync(a.l, b.p-bstr, c.l, d.l, e.l)
  Delete(a.p-bstr, b.l, c.l)
  DeleteAsync(a.l, b.p-bstr, c.l, d.l, e.l)
  InstancesOf(a.p-bstr, b.l, c.l, d.l)
  InstancesOfAsync(a.l, b.p-bstr, c.l, d.l, e.l)
  SubclassesOf(a.p-bstr, b.l, c.l, d.l)
  SubclassesOfAsync(a.l, b.p-bstr, c.l, d.l, e.l)
  ExecQuery(a.p-bstr, b.p-bstr, c.l, d.l, e.l)
  ExecQueryAsync(a.l, b.p-bstr, c.p-bstr, d.l, e.l, f.l)
  AssociatorsOf(a.p-bstr, b.p-bstr, c.p-bstr, d.p-bstr, e.p-bstr, f.l, g.l, h.p-bstr, i.p-bstr, j.l, k.l, l.l)
  AssociatorsOfAsync(a.l, b.p-bstr, c.p-bstr, d.p-bstr, e.p-bstr, f.p-bstr, g.l, h.l, i.p-bstr, j.p-bstr, k.l, l.l, m.l)
  ReferencesTo(a.p-bstr, b.p-bstr, c.p-bstr, d.l, e.l, f.p-bstr, g.l, h.l, i.l)
  ReferencesToAsync(a.l, b.p-bstr, c.p-bstr, d.p-bstr, e.l, f.l, g.p-bstr, h.l, i.l, j.l)
  ExecNotificationQuery(a.p-bstr, b.p-bstr, c.l, d.l, e.l)
  ExecNotificationQueryAsync(a.l, b.p-bstr, c.p-bstr, d.l, e.l, f.l)
  ExecMethod(a.p-bstr, b.p-bstr, c.l, d.l, e.l, f.l)
  ExecMethodAsync(a.l, b.p-bstr, c.p-bstr, d.l, e.l, f.l, g.l)
  get_Security_(a.l)
EndInterface

; ISWbemLocator interface definition
;
Interface ISWbemLocator
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  ConnectServer(a.p-bstr, b.p-bstr, c.p-bstr, d.p-bstr, e.p-bstr, f.p-bstr, g.l, h.l, i.l)
  get_Security_(a.l)
EndInterface

; ISWbemObject interface definition
;
Interface ISWbemObject
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  Put_(a.l, b.l, c.l)
  PutAsync_(a.l, b.l, c.l, d.l)
  Delete_(a.l, b.l)
  DeleteAsync_(a.l, b.l, c.l, d.l)
  Instances_(a.l, b.l, c.l)
  InstancesAsync_(a.l, b.l, c.l, d.l)
  Subclasses_(a.l, b.l, c.l)
  SubclassesAsync_(a.l, b.l, c.l, d.l)
  Associators_(a.p-bstr, b.p-bstr, c.p-bstr, d.p-bstr, e.l, f.l, g.p-bstr, h.p-bstr, i.l, j.l, k.l)
  AssociatorsAsync_(a.l, b.p-bstr, c.p-bstr, d.p-bstr, e.p-bstr, f.l, g.l, h.p-bstr, i.p-bstr, j.l, k.l, l.l)
  References_(a.p-bstr, b.p-bstr, c.l, d.l, e.p-bstr, f.l, g.l, h.l)
  ReferencesAsync_(a.l, b.p-bstr, c.p-bstr, d.l, e.l, f.p-bstr, g.l, h.l, i.l)
  ExecMethod_(a.p-bstr, b.l, c.l, d.l, e.l)
  ExecMethodAsync_(a.l, b.p-bstr, c.l, d.l, e.l, f.l)
  Clone_(a.l)
  GetObjectText_(a.l, b.l)
  SpawnDerivedClass_(a.l, b.l)
  SpawnInstance_(a.l, b.l)
  CompareTo_(a.l, b.l, c.l)
  get_Qualifiers_(a.l)
  get_Properties_(a.l)
  get_Methods_(a.l)
  get_Derivation_(a.l)
  get_Path_(a.l)
  get_Security_(a.l)
EndInterface

; ISWbemObjectSet interface definition
;
Interface ISWbemObjectSet
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get__NewEnum(a.l)
  Item(a.p-bstr, b.l, c.l)
  get_Count(a.l)
  get_Security_(a.l)
EndInterface

; ISWbemNamedValue interface definition
;
Interface ISWbemNamedValue
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Value(a.l)
  put_Value(a.l)
  get_Name(a.l)
EndInterface

; ISWbemNamedValueSet interface definition
;
Interface ISWbemNamedValueSet
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get__NewEnum(a.l)
  Item(a.p-bstr, b.l, c.l)
  get_Count(a.l)
  Add(a.p-bstr, b.l, c.l, d.l)
  Remove(a.p-bstr, b.l)
  Clone(a.l)
  DeleteAll()
EndInterface

; ISWbemQualifier interface definition
;
Interface ISWbemQualifier
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Value(a.l)
  put_Value(a.l)
  get_Name(a.l)
  get_IsLocal(a.l)
  get_PropagatesToSubclass(a.l)
  put_PropagatesToSubclass(a.l)
  get_PropagatesToInstance(a.l)
  put_PropagatesToInstance(a.l)
  get_IsOverridable(a.l)
  put_IsOverridable(a.l)
  get_IsAmended(a.l)
EndInterface

; ISWbemQualifierSet interface definition
;
Interface ISWbemQualifierSet
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get__NewEnum(a.l)
  Item(a.p-bstr, b.l, c.l)
  get_Count(a.l)
  Add(a.p-bstr, b.l, c.l, d.l, e.l, f.l, g.l)
  Remove(a.p-bstr, b.l)
EndInterface

; ISWbemProperty interface definition
;
Interface ISWbemProperty
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Value(a.l)
  put_Value(a.l)
  get_Name(a.l)
  get_IsLocal(a.l)
  get_Origin(a.l)
  get_CIMType(a.l)
  get_Qualifiers_(a.l)
  get_IsArray(a.l)
EndInterface

; ISWbemPropertySet interface definition
;
Interface ISWbemPropertySet
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get__NewEnum(a.l)
  Item(a.p-bstr, b.l, c.l)
  get_Count(a.l)
  Add(a.p-bstr, b.l, c.l, d.l, e.l)
  Remove(a.p-bstr, b.l)
EndInterface

; ISWbemMethod interface definition
;
Interface ISWbemMethod
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Name(a.l)
  get_Origin(a.l)
  get_InParameters(a.l)
  get_OutParameters(a.l)
  get_Qualifiers_(a.l)
EndInterface

; ISWbemMethodSet interface definition
;
Interface ISWbemMethodSet
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get__NewEnum(a.l)
  Item(a.p-bstr, b.l, c.l)
  get_Count(a.l)
EndInterface

; ISWbemEventSource interface definition
;
Interface ISWbemEventSource
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  NextEvent(a.l, b.l)
  get_Security_(a.l)
EndInterface

; ISWbemObjectPath interface definition
;
Interface ISWbemObjectPath
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Path(a.l)
  put_Path(a.p-bstr)
  get_RelPath(a.l)
  put_RelPath(a.p-bstr)
  get_Server(a.l)
  put_Server(a.p-bstr)
  get_Namespace(a.l)
  put_Namespace(a.p-bstr)
  get_ParentNamespace(a.l)
  get_DisplayName(a.l)
  put_DisplayName(a.p-bstr)
  get_Class(a.l)
  put_Class(a.p-bstr)
  get_IsClass(a.l)
  SetAsClass()
  get_IsSingleton(a.l)
  SetAsSingleton()
  get_Keys(a.l)
  get_Security_(a.l)
  get_Locale(a.l)
  put_Locale(a.p-bstr)
  get_Authority(a.l)
  put_Authority(a.p-bstr)
EndInterface

; ISWbemLastError interface definition
;
Interface ISWbemLastError
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  Put_(a.l, b.l, c.l)
  PutAsync_(a.l, b.l, c.l, d.l)
  Delete_(a.l, b.l)
  DeleteAsync_(a.l, b.l, c.l, d.l)
  Instances_(a.l, b.l, c.l)
  InstancesAsync_(a.l, b.l, c.l, d.l)
  Subclasses_(a.l, b.l, c.l)
  SubclassesAsync_(a.l, b.l, c.l, d.l)
  Associators_(a.p-bstr, b.p-bstr, c.p-bstr, d.p-bstr, e.l, f.l, g.p-bstr, h.p-bstr, i.l, j.l, k.l)
  AssociatorsAsync_(a.l, b.p-bstr, c.p-bstr, d.p-bstr, e.p-bstr, f.l, g.l, h.p-bstr, i.p-bstr, j.l, k.l, l.l)
  References_(a.p-bstr, b.p-bstr, c.l, d.l, e.p-bstr, f.l, g.l, h.l)
  ReferencesAsync_(a.l, b.p-bstr, c.p-bstr, d.l, e.l, f.p-bstr, g.l, h.l, i.l)
  ExecMethod_(a.p-bstr, b.l, c.l, d.l, e.l)
  ExecMethodAsync_(a.l, b.p-bstr, c.l, d.l, e.l, f.l)
  Clone_(a.l)
  GetObjectText_(a.l, b.l)
  SpawnDerivedClass_(a.l, b.l)
  SpawnInstance_(a.l, b.l)
  CompareTo_(a.l, b.l, c.l)
  get_Qualifiers_(a.l)
  get_Properties_(a.l)
  get_Methods_(a.l)
  get_Derivation_(a.l)
  get_Path_(a.l)
  get_Security_(a.l)
EndInterface

; ISWbemSinkEvents interface definition
;
Interface ISWbemSinkEvents
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
EndInterface

; ISWbemSink interface definition
;
Interface ISWbemSink
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  Cancel()
EndInterface

; ISWbemSecurity interface definition
;
Interface ISWbemSecurity
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_ImpersonationLevel(a.l)
  put_ImpersonationLevel(a.l)
  get_AuthenticationLevel(a.l)
  put_AuthenticationLevel(a.l)
  get_Privileges(a.l)
EndInterface

; ISWbemPrivilege interface definition
;
Interface ISWbemPrivilege
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_IsEnabled(a.l)
  put_IsEnabled(a.l)
  get_Name(a.l)
  get_DisplayName(a.l)
  get_Identifier(a.l)
EndInterface

; ISWbemPrivilegeSet interface definition
;
Interface ISWbemPrivilegeSet
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get__NewEnum(a.l)
  Item(a.l, b.l)
  get_Count(a.l)
  Add(a.l, b.l, c.l)
  Remove(a.l)
  DeleteAll()
  AddAsString(a.p-bstr, b.l, c.l)
EndInterface

; ISWbemServicesEx interface definition
;
Interface ISWbemServicesEx
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  Get(a.p-bstr, b.l, c.l, d.l)
  GetAsync(a.l, b.p-bstr, c.l, d.l, e.l)
  Delete(a.p-bstr, b.l, c.l)
  DeleteAsync(a.l, b.p-bstr, c.l, d.l, e.l)
  InstancesOf(a.p-bstr, b.l, c.l, d.l)
  InstancesOfAsync(a.l, b.p-bstr, c.l, d.l, e.l)
  SubclassesOf(a.p-bstr, b.l, c.l, d.l)
  SubclassesOfAsync(a.l, b.p-bstr, c.l, d.l, e.l)
  ExecQuery(a.p-bstr, b.p-bstr, c.l, d.l, e.l)
  ExecQueryAsync(a.l, b.p-bstr, c.p-bstr, d.l, e.l, f.l)
  AssociatorsOf(a.p-bstr, b.p-bstr, c.p-bstr, d.p-bstr, e.p-bstr, f.l, g.l, h.p-bstr, i.p-bstr, j.l, k.l, l.l)
  AssociatorsOfAsync(a.l, b.p-bstr, c.p-bstr, d.p-bstr, e.p-bstr, f.p-bstr, g.l, h.l, i.p-bstr, j.p-bstr, k.l, l.l, m.l)
  ReferencesTo(a.p-bstr, b.p-bstr, c.p-bstr, d.l, e.l, f.p-bstr, g.l, h.l, i.l)
  ReferencesToAsync(a.l, b.p-bstr, c.p-bstr, d.p-bstr, e.l, f.l, g.p-bstr, h.l, i.l, j.l)
  ExecNotificationQuery(a.p-bstr, b.p-bstr, c.l, d.l, e.l)
  ExecNotificationQueryAsync(a.l, b.p-bstr, c.p-bstr, d.l, e.l, f.l)
  ExecMethod(a.p-bstr, b.p-bstr, c.l, d.l, e.l, f.l)
  ExecMethodAsync(a.l, b.p-bstr, c.p-bstr, d.l, e.l, f.l, g.l)
  get_Security_(a.l)
  Put(a.l, b.l, c.l, d.l)
  PutAsync(a.l, b.l, c.l, d.l, e.l)
EndInterface

; ISWbemObjectEx interface definition
;
Interface ISWbemObjectEx
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  Put_(a.l, b.l, c.l)
  PutAsync_(a.l, b.l, c.l, d.l)
  Delete_(a.l, b.l)
  DeleteAsync_(a.l, b.l, c.l, d.l)
  Instances_(a.l, b.l, c.l)
  InstancesAsync_(a.l, b.l, c.l, d.l)
  Subclasses_(a.l, b.l, c.l)
  SubclassesAsync_(a.l, b.l, c.l, d.l)
  Associators_(a.p-bstr, b.p-bstr, c.p-bstr, d.p-bstr, e.l, f.l, g.p-bstr, h.p-bstr, i.l, j.l, k.l)
  AssociatorsAsync_(a.l, b.p-bstr, c.p-bstr, d.p-bstr, e.p-bstr, f.l, g.l, h.p-bstr, i.p-bstr, j.l, k.l, l.l)
  References_(a.p-bstr, b.p-bstr, c.l, d.l, e.p-bstr, f.l, g.l, h.l)
  ReferencesAsync_(a.l, b.p-bstr, c.p-bstr, d.l, e.l, f.p-bstr, g.l, h.l, i.l)
  ExecMethod_(a.p-bstr, b.l, c.l, d.l, e.l)
  ExecMethodAsync_(a.l, b.p-bstr, c.l, d.l, e.l, f.l)
  Clone_(a.l)
  GetObjectText_(a.l, b.l)
  SpawnDerivedClass_(a.l, b.l)
  SpawnInstance_(a.l, b.l)
  CompareTo_(a.l, b.l, c.l)
  get_Qualifiers_(a.l)
  get_Properties_(a.l)
  get_Methods_(a.l)
  get_Derivation_(a.l)
  get_Path_(a.l)
  get_Security_(a.l)
  Refresh_(a.l, b.l)
  get_SystemProperties_(a.l)
  GetText_(a.l, b.l, c.l, d.l)
  SetFromText_(a.p-bstr, b.l, c.l, d.l)
EndInterface

; ISWbemDateTime interface definition
;
Interface ISWbemDateTime
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Value(a.l)
  put_Value(a.p-bstr)
  get_Year(a.l)
  put_Year(a.l)
  get_YearSpecified(a.l)
  put_YearSpecified(a.l)
  get_Month(a.l)
  put_Month(a.l)
  get_MonthSpecified(a.l)
  put_MonthSpecified(a.l)
  get_Day(a.l)
  put_Day(a.l)
  get_DaySpecified(a.l)
  put_DaySpecified(a.l)
  get_Hours(a.l)
  put_Hours(a.l)
  get_HoursSpecified(a.l)
  put_HoursSpecified(a.l)
  get_Minutes(a.l)
  put_Minutes(a.l)
  get_MinutesSpecified(a.l)
  put_MinutesSpecified(a.l)
  get_Seconds(a.l)
  put_Seconds(a.l)
  get_SecondsSpecified(a.l)
  put_SecondsSpecified(a.l)
  get_Microseconds(a.l)
  put_Microseconds(a.l)
  get_MicrosecondsSpecified(a.l)
  put_MicrosecondsSpecified(a.l)
  get_UTC(a.l)
  put_UTC(a.l)
  get_UTCSpecified(a.l)
  put_UTCSpecified(a.l)
  get_IsInterval(a.l)
  put_IsInterval(a.l)
  GetVarDate(a.l, b.l)
  SetVarDate(a.l, b.l)
  GetFileTime(a.l, b.l)
  SetFileTime(a.p-bstr, b.l)
EndInterface

; ISWbemRefresher interface definition
;
Interface ISWbemRefresher
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get__NewEnum(a.l)
  Item(a.l, b.l)
  get_Count(a.l)
  Add(a.l, b.p-bstr, c.l, d.l, e.l)
  AddEnum(a.l, b.p-bstr, c.l, d.l, e.l)
  Remove(a.l, b.l)
  Refresh(a.l)
  get_AutoReconnect(a.l)
  put_AutoReconnect(a.l)
  DeleteAll()
EndInterface

; ISWbemRefreshableItem interface definition
;
Interface ISWbemRefreshableItem
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Index(a.l)
  get_Refresher(a.l)
  get_IsSet(a.l)
  get_Object(a.l)
  get_ObjectSet(a.l)
  Remove(a.l)
EndInterface
