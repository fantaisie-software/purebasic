Enumeration   ; GThreadError
  #G_THREAD_ERROR_AGAIN
EndEnumeration

Enumeration   ; GThreadPriority
  #G_THREAD_PRIORITY_LOW
  #G_THREAD_PRIORITY_NORMAL
  #G_THREAD_PRIORITY_HIGH
  #G_THREAD_PRIORITY_URGENT
EndEnumeration

Structure GThread
  *func.GThreadFunc
  Data.i     ; gpointer
  joinable.l ; gboolean
  priority.l ; GThreadPriority enum
EndStructure

Structure GThreadFunctions
  *mutex_new
  *mutex_lock
  *mutex_trylock
  *mutex_unlock
  *mutex_free
  *cond_new
  *cond_signal
  *cond_broadcast
  *cond_wait
  *cond_timed_wait
  *cond_free
  *private_new
  *private_get
  *private_set
  *thread_create
  *thread_yield
  *thread_join
  *thread_exit
  *thread_set_priority
  *thread_self
  *thread_equal
EndStructure

#G_MUTEX_DEBUG_MAGIC = $f8e18ad7
Structure GStaticPrivate
  index.l ; guint
          ; Exceptionnally, it doesn't have to be aligned on x64
EndStructure

; Dummy struct as we didn't find it in the gtk header !
;
Structure GStaticMutex
  CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
    dummy.b[48]
  CompilerElse
    dummy.b[28]
  CompilerEndIf
EndStructure

; Dummy struct as we didn't find it in the gtk header !
;
Structure GSystemThread
  dummy.l[2]
EndStructure

Structure GStaticRecMutex
  mutex.GStaticMutex
  depth.l ; guint
  PB_Align(0, 4)
  owner.GSystemThread
EndStructure

Structure GStaticRWLock
  mutex.GStaticMutex
  *read_cond.GCond
  *write_cond.GCond
  read_counter.l
  have_writer.l
  want_to_read.l
  want_to_write.l
EndStructure

Enumeration   ; GOnceStatus
  #G_ONCE_STATUS_NOTCALLED
  #G_ONCE_STATUS_PROGRESS
  #G_ONCE_STATUS_READY
EndEnumeration

Structure GOnce
  status.l ; GOnceStatus enum
  PB_Align(0, 4)
  retval.i ; gpointer
EndStructure

