; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

#SQLITE_VERSION        = "3.4.1"
#SQLITE_VERSION_NUMBER = 3004001

#SQLITE_OK         =  0   ; Successful result
#SQLITE_ERROR      =  1   ; SQL error or missing database
#SQLITE_INTERNAL   =  2   ; NOT USED. Internal logic error in SQLite
#SQLITE_PERM       =  3   ; Access permission denied
#SQLITE_ABORT      =  4   ; Callback routine requested an abort
#SQLITE_BUSY       =  5   ; The database file is locked
#SQLITE_LOCKED     =  6   ; A table in the database is locked
#SQLITE_NOMEM      =  7   ; A malloc() failed
#SQLITE_READONLY   =  8   ; Attempt to write a readonly database
#SQLITE_INTERRUPT  =  9   ; Operation terminated by sqlite3_interrupt()
#SQLITE_IOERR      = 10   ; Some kind of disk I/O error occurred
#SQLITE_CORRUPT    = 11   ; The database disk image is malformed
#SQLITE_NOTFOUND   = 12   ; NOT USED. Table or record not found
#SQLITE_FULL       = 13   ; Insertion failed because database is full
#SQLITE_CANTOPEN   = 14   ; Unable to open the database file
#SQLITE_PROTOCOL   = 15   ; NOT USED. Database lock protocol error
#SQLITE_EMPTY      = 16   ; Database is empty
#SQLITE_SCHEMA     = 17   ; The database schema changed
#SQLITE_TOOBIG     = 18   ; String or BLOB exceeds size limit
#SQLITE_CONSTRAINT = 19   ; Abort due to contraint violation
#SQLITE_MISMATCH   = 20   ; Data type mismatch
#SQLITE_MISUSE     = 21   ; Library used incorrectly
#SQLITE_NOLFS      = 22   ; Uses OS features not supported on host
#SQLITE_AUTH       = 23   ; Authorization denied
#SQLITE_FORMAT     = 24   ; Auxiliary database format error
#SQLITE_RANGE      = 25   ; 2nd parameter to sqlite3_bind out of range
#SQLITE_NOTADB     = 26   ; File opened that is not a database file
#SQLITE_ROW        = 100  ; sqlite3_step() has another row ready
#SQLITE_DONE       = 101  ; sqlite3_step() has finished executing
; end-of-error-codes

#SQLITE_IOERR_READ       =   (#SQLITE_IOERR | (1<<8))
#SQLITE_IOERR_SHORT_READ =   (#SQLITE_IOERR | (2<<8))
#SQLITE_IOERR_WRITE      =   (#SQLITE_IOERR | (3<<8))
#SQLITE_IOERR_FSYNC      =   (#SQLITE_IOERR | (4<<8))
#SQLITE_IOERR_DIR_FSYNC  =   (#SQLITE_IOERR | (5<<8))
#SQLITE_IOERR_TRUNCATE   =   (#SQLITE_IOERR | (6<<8))
#SQLITE_IOERR_FSTAT      =   (#SQLITE_IOERR | (7<<8))
#SQLITE_IOERR_UNLOCK     =   (#SQLITE_IOERR | (8<<8))
#SQLITE_IOERR_RDLOCK     =   (#SQLITE_IOERR | (9<<8))
#SQLITE_IOERR_DELETE     =   (#SQLITE_IOERR | (10<<8))
#SQLITE_IOERR_BLOCKED    =   (#SQLITE_IOERR | (11<<8))

#SQLITE_CREATE_INDEX        =  1   ; Index Name      Table Name
#SQLITE_CREATE_TABLE        =  2   ; Table Name      NULL
#SQLITE_CREATE_TEMP_INDEX   =  3   ; Index Name      Table Name
#SQLITE_CREATE_TEMP_TABLE   =  4   ; Table Name      NULL
#SQLITE_CREATE_TEMP_TRIGGER =  5   ; Trigger Name    Table Name
#SQLITE_CREATE_TEMP_VIEW    =  6   ; View Name       NULL
#SQLITE_CREATE_TRIGGER      =  7   ; Trigger Name    Table Name
#SQLITE_CREATE_VIEW         =  8   ; View Name       NULL
#SQLITE_DELETE              =  9   ; Table Name      NULL
#SQLITE_DROP_INDEX          = 10   ; Index Name      Table Name
#SQLITE_DROP_TABLE          = 11   ; Table Name      NULL
#SQLITE_DROP_TEMP_INDEX     = 12   ; Index Name      Table Name
#SQLITE_DROP_TEMP_TABLE     = 13   ; Table Name      NULL
#SQLITE_DROP_TEMP_TRIGGER   = 14   ; Trigger Name    Table Name
#SQLITE_DROP_TEMP_VIEW      = 15   ; View Name       NULL
#SQLITE_DROP_TRIGGER        = 16   ; Trigger Name    Table Name
#SQLITE_DROP_VIEW           = 17   ; View Name       NULL
#SQLITE_INSERT              = 18   ; Table Name      NULL
#SQLITE_PRAGMA              = 19   ; Pragma Name     1st arg or NULL
#SQLITE_READ                = 20   ; Table Name      Column Name
#SQLITE_SELECT              = 21   ; NULL            NULL
#SQLITE_TRANSACTION         = 22   ; NULL            NULL
#SQLITE_UPDATE              = 23   ; Table Name      Column Name
#SQLITE_ATTACH              = 24   ; Filename        NULL
#SQLITE_DETACH              = 25   ; Database Name   NULL
#SQLITE_ALTER_TABLE         = 26   ; Database Name   Table Name
#SQLITE_REINDEX             = 27   ; Index Name      NULL
#SQLITE_ANALYZE             = 28   ; Table Name      NULL
#SQLITE_CREATE_VTABLE       = 29   ; Table Name      Module Name
#SQLITE_DROP_VTABLE         = 30   ; Table Name      Module Name
#SQLITE_FUNCTION            = 31   ; Function Name   NULL
#SQLITE_COPY                =  0   ; No longer used


#SQLITE_INTEGER = 1
#SQLITE_FLOAT   = 2
#SQLITE_BLOB    = 4
#SQLITE_NULL    = 5
#SQLITE_TEXT    = 3
#SQLITE3_TEXT   = 3

; These constant define integer codes that represent the various
; text encodings supported by SQLite.
;
#SQLITE_UTF8          = 1
#SQLITE_UTF16LE       = 2
#SQLITE_UTF16BE       = 3
#SQLITE_UTF16         = 4    ; Use native byte order
#SQLITE_ANY           = 5    ; sqlite3_create_function only
#SQLITE_UTF16_ALIGNED = 8    ; sqlite3_create_collation only


#SQLITE_STATIC     = 0
#SQLITE_TRANSIENT  = -1

#SQLITE_DENY   = 1   ; Abort the SQL statement with an error
#SQLITE_IGNORE = 2   ; Don't allow access, but don't generate an error


#SQLITE_INDEX_CONSTRAINT_EQ    = 2
#SQLITE_INDEX_CONSTRAINT_GT    = 4
#SQLITE_INDEX_CONSTRAINT_LE    = 8
#SQLITE_INDEX_CONSTRAINT_LT    = 16
#SQLITE_INDEX_CONSTRAINT_GE    = 32
#SQLITE_INDEX_CONSTRAINT_MATCH = 64
