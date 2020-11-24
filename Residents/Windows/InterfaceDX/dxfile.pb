
; IDirectXFile interface definition
;
Interface IDirectXFile
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  CreateEnumObject(a.l, b.l, c.l)
  CreateSaveObject(a.s, b.l, c.l)
  RegisterTemplates(a.l, b.l)
EndInterface

; IDirectXFileEnumObject interface definition
;
Interface IDirectXFileEnumObject
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetNextDataObject(a.l)
  GetDataObjectById(a.l, b.l)
  GetDataObjectByName(a.s, b.l)
EndInterface

; IDirectXFileSaveObject interface definition
;
Interface IDirectXFileSaveObject
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SaveTemplates(a.l, b.l)
  CreateDataObject(a.l, b.s, c.l, d.l, e.l, f.l)
  SaveData(a.l)
EndInterface

; IDirectXFileObject interface definition
;
Interface IDirectXFileObject
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetName(a.l, b.l)
  GetId(a.l)
EndInterface

; IDirectXFileData interface definition
;
Interface IDirectXFileData
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetName(a.l, b.l)
  GetId(a.l)
  GetData(a.s, b.l, c.l)
  GetType(a.l)
  GetNextObject(a.l)
  AddDataObject(a.l)
  AddDataReference(a.s, b.l)
  AddBinaryObject(a.s, b.l, c.s, d.l, e.l)
EndInterface

; IDirectXFileDataReference interface definition
;
Interface IDirectXFileDataReference
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetName(a.l, b.l)
  GetId(a.l)
  Resolve(a.l)
EndInterface

; IDirectXFileBinary interface definition
;
Interface IDirectXFileBinary
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetName(a.l, b.l)
  GetId(a.l)
  GetSize(a.l)
  GetMimeType(a.l)
  Read(a.l, b.l, c.l)
EndInterface
