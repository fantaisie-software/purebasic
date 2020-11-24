
; ID3DXFile interface definition
;
Interface ID3DXFile
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  CreateEnumObject(a.l, b.l, c.l)
  CreateSaveObject(a.l, b.l, c.l, d.l)
  RegisterTemplates(a.l, b.l)
  RegisterEnumTemplates(a.l)
EndInterface

; ID3DXFileSaveObject interface definition
;
Interface ID3DXFileSaveObject
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetFile(a.l)
  AddDataObject(a.l, b.s, c.l, d.l, e.l, f.l)
  Save()
EndInterface

; ID3DXFileSaveData interface definition
;
Interface ID3DXFileSaveData
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetSave(a.l)
  GetName(a.l, b.l)
  GetId(a.l)
  GetType(a.l)
  AddDataObject(a.l, b.s, c.l, d.l, e.l, f.l)
  AddDataReference(a.s, b.l)
EndInterface

; ID3DXFileEnumObject interface definition
;
Interface ID3DXFileEnumObject
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetFile(a.l)
  GetChildren(a.l)
  GetChild(a.l, b.l)
  GetDataObjectById(a.l, b.l)
  GetDataObjectByName(a.s, b.l)
EndInterface

; ID3DXFileData interface definition
;
Interface ID3DXFileData
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetEnum(a.l)
  GetName(a.l, b.l)
  GetId(a.l)
  Lock(a.l, b.l)
  Unlock()
  GetType(a.l)
  IsReference()
  GetChildren(a.l)
  GetChild(a.l, b.l)
EndInterface
