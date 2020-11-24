Enumeration   ; GtkFileInfoType
  #GTK_FILE_INFO_DISPLAY_NAME = 1<<0
  #GTK_FILE_INFO_IS_FOLDER = 1<<1
  #GTK_FILE_INFO_IS_HIDDEN = 1<<2
  #GTK_FILE_INFO_MIME_TYPE = 1<<3
  #GTK_FILE_INFO_MODIFICATION_TIME = 1<<4
  #GTK_FILE_INFO_SIZE = 1<<5
  #GTK_FILE_INFO_ALL = (1<<6)-1
EndEnumeration

Enumeration   ; GtkFileSystemError
  #GTK_FILE_SYSTEM_ERROR_NONEXISTENT
  #GTK_FILE_SYSTEM_ERROR_NOT_FOLDER
  #GTK_FILE_SYSTEM_ERROR_INVALID_URI
  #GTK_FILE_SYSTEM_ERROR_BAD_FILENAME
  #GTK_FILE_SYSTEM_ERROR_FAILED
  #GTK_FILE_SYSTEM_ERROR_ALREADY_EXISTS
EndEnumeration

; Structure GtkFileSystemIface
;   base_iface.GTypeInterface
;  *file_system).(*list_volumes)(GtkFileSystem
;  *path).const GtkFilePath
;  **error).GError
;  *create_folder
;  *volume_free
;  *volume).GtkFileSystemVolume
;  *volume_get_is_mounted
;  *volume_mount
;  *volume).GtkFileSystemVolume
;  **error).GError
;  *get_parent
;  **error).GError
;  *parse
;  *path).const GtkFilePath
;  *path).const GtkFilePath
;  *uri)
;  *path)
;  **error).GError
;  *insert_bookmark
;  *remove_bookmark
;  *file_system).(*list_bookmarks)(GtkFileSystem
;  *volumes_changed
;  *bookmarks_changed
; EndStructure
;
; Structure GtkFileFolderIface
;   base_iface.GTypeInterface
;  **error).GError
;  *list_children
;  *deleted
;  *files_added
;  *files_changed
;  *files_removed
;  *is_finished_loading
;  *finished_loading
; EndStructure

