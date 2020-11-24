Enumeration   ; GtkFileFilterFlags
  #GTK_FILE_FILTER_FILENAME = 1<<0
  #GTK_FILE_FILTER_URI = 1<<1
  #GTK_FILE_FILTER_DISPLAY_NAME = 1<<2
  #GTK_FILE_FILTER_MIME_TYPE = 1<<3
EndEnumeration

Structure GtkFileFilterInfo
  contains.l  ; GtkFileFilterFlags enum
  PB_Align(0, 4)
 *filename
 *uri
 *display_name
 *mime_type
EndStructure

