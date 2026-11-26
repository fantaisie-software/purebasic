
; IBDA_TIF_REGISTRATION interface definition
;
Interface IBDA_TIF_REGISTRATION Extends IUnknown
  RegisterTIFEx(a.l, b.l, c.l)
  UnregisterTIF(a.l)
EndInterface

; IMPEG2_TIF_CONTROL interface definition
;
Interface IMPEG2_TIF_CONTROL Extends IUnknown
  RegisterTIF(a.l, b.l)
  UnregisterTIF(a.l)
  AddPIDs(a.l, b.l)
  DeletePIDs(a.l, b.l)
  GetPIDCount(a.l)
  GetPIDs(a.l, b.l)
EndInterface

; ITuneRequestInfo interface definition
;
Interface ITuneRequestInfo Extends IUnknown
  GetLocatorData(a.l)
  GetComponentData(a.l)
  CreateComponentList(a.l)
  GetNextProgram(a.l, b.l)
  GetPreviousProgram(a.l, b.l)
  GetNextLocator(a.l, b.l)
  GetPreviousLocator(a.l, b.l)
EndInterface

; IGuideDataEvent interface definition
;
Interface IGuideDataEvent Extends IUnknown
  GuideDataAcquired()
  ProgramChanged(a.p-variant)
  ServiceChanged(a.p-variant)
  ScheduleEntryChanged(a.p-variant)
  ProgramDeleted(a.p-variant)
  ServiceDeleted(a.p-variant)
  ScheduleDeleted(a.p-variant)
EndInterface

; IGuideDataProperty interface definition
;
Interface IGuideDataProperty Extends IUnknown
  get_Name(a.l)
  get_Language(a.l)
  get_Value(a.l)
EndInterface

; IEnumGuideDataProperties interface definition
;
Interface IEnumGuideDataProperties Extends IUnknown
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; IEnumTuneRequests interface definition
;
Interface IEnumTuneRequests Extends IUnknown
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; IGuideData interface definition
;
Interface IGuideData Extends IUnknown
  GetServices(a.l)
  GetServiceProperties(a.l, b.l)
  GetGuideProgramIDs(a.l)
  GetProgramProperties(a.p-variant, b.l)
  GetScheduleEntryIDs(a.l)
  GetScheduleEntryProperties(a.p-variant, b.l)
EndInterface

; IGuideDataLoader interface definition
;
Interface IGuideDataLoader Extends IUnknown
  Init(a.l)
  Terminate()
EndInterface
