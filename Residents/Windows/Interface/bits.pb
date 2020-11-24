
; IBackgroundCopyFile interface definition
;
Interface IBackgroundCopyFile
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetRemoteName(a.l)
  GetLocalName(a.l)
  GetProgress(a.l)
EndInterface

; IEnumBackgroundCopyFiles interface definition
;
Interface IEnumBackgroundCopyFiles
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
  GetCount(a.l)
EndInterface

; IBackgroundCopyError interface definition
;
Interface IBackgroundCopyError
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetError(a.l, b.l)
  GetFile(a.l)
  GetErrorDescription(a.l, b.l)
  GetErrorContextDescription(a.l, b.l)
  GetProtocol(a.l)
EndInterface

; IBackgroundCopyJob interface definition
;
Interface IBackgroundCopyJob
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  AddFileSet(a.l, b.l)
  AddFile(a.l, b.l)
  EnumFiles(a.l)
  Suspend()
  Resume()
  Cancel()
  Complete()
  GetId(a.l)
  GetType(a.l)
  GetProgress(a.l)
  GetTimes(a.l)
  GetState(a.l)
  GetError(a.l)
  GetOwner(a.l)
  SetDisplayName(a.l)
  GetDisplayName(a.l)
  SetDescription(a.l)
  GetDescription(a.l)
  SetPriority(a.l)
  GetPriority(a.l)
  SetNotifyFlags(a.l)
  GetNotifyFlags(a.l)
  SetNotifyInterface(a.l)
  GetNotifyInterface(a.l)
  SetMinimumRetryDelay(a.l)
  GetMinimumRetryDelay(a.l)
  SetNoProgressTimeout(a.l)
  GetNoProgressTimeout(a.l)
  GetErrorCount(a.l)
  SetProxySettings(a.l, b.l, c.l)
  GetProxySettings(a.l, b.l, c.l)
  TakeOwnership()
EndInterface

; IEnumBackgroundCopyJobs interface definition
;
Interface IEnumBackgroundCopyJobs
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
  GetCount(a.l)
EndInterface

; IBackgroundCopyCallback interface definition
;
Interface IBackgroundCopyCallback
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  JobTransferred(a.l)
  JobError(a.l, b.l)
  JobModification(a.l, b.l)
EndInterface

; AsyncIBackgroundCopyCallback interface definition
;
Interface AsyncIBackgroundCopyCallback
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Begin_JobTransferred(a.l)
  Finish_JobTransferred()
  Begin_JobError(a.l, b.l)
  Finish_JobError()
  Begin_JobModification(a.l, b.l)
  Finish_JobModification()
EndInterface

; IBackgroundCopyManager interface definition
;
Interface IBackgroundCopyManager
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  CreateJob(a.l, b.l, c.l, d.l)
  GetJob(a.l, b.l)
  EnumJobs(a.l, b.l)
  GetErrorDescription(a.l, b.l, c.l)
EndInterface
