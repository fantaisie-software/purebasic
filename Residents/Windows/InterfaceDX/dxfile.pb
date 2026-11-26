
; IDirectXFile interface definition
;
Interface IDirectXFile Extends IUnknown
  CreateEnumObject(a.l, b.l, c.l)
  CreateSaveObject(a.s, b.l, c.l)
  RegisterTemplates(a.l, b.l)
EndInterface

; IDirectXFileEnumObject interface definition
;
Interface IDirectXFileEnumObject Extends IUnknown
  GetNextDataObject(a.l)
  GetDataObjectById(a.l, b.l)
  GetDataObjectByName(a.s, b.l)
EndInterface

; IDirectXFileSaveObject interface definition
;
Interface IDirectXFileSaveObject Extends IUnknown
  SaveTemplates(a.l, b.l)
  CreateDataObject(a.l, b.s, c.l, d.l, e.l, f.l)
  SaveData(a.l)
EndInterface

; IDirectXFileObject interface definition
;
Interface IDirectXFileObject Extends IUnknown
  GetName(a.l, b.l)
  GetId(a.l)
EndInterface

; IDirectXFileData interface definition
;
Interface IDirectXFileData Extends IDirectXFileObject
  GetData(a.s, b.l, c.l)
  GetType(a.l)
  GetNextObject(a.l)
  AddDataObject(a.l)
  AddDataReference(a.s, b.l)
  AddBinaryObject(a.s, b.l, c.s, d.l, e.l)
EndInterface

; IDirectXFileDataReference interface definition
;
Interface IDirectXFileDataReference Extends IDirectXFileObject
  Resolve(a.l)
EndInterface

; IDirectXFileBinary interface definition
;
Interface IDirectXFileBinary Extends IDirectXFileObject
  GetSize(a.l)
  GetMimeType(a.l)
  Read(a.l, b.l, c.l)
EndInterface
