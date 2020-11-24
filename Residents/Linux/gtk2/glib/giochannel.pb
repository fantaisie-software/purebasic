Enumeration   ; GIOError
  #G_IO_ERROR_NONE
  #G_IO_ERROR_AGAIN
  #G_IO_ERROR_INVAL
  #G_IO_ERROR_UNKNOWN
EndEnumeration

Enumeration   ; GIOChannelError
  #G_IO_CHANNEL_ERROR_FBIG
  #G_IO_CHANNEL_ERROR_INVAL
  #G_IO_CHANNEL_ERROR_IO
  #G_IO_CHANNEL_ERROR_ISDIR
  #G_IO_CHANNEL_ERROR_NOSPC
  #G_IO_CHANNEL_ERROR_NXIO
  #G_IO_CHANNEL_ERROR_OVERFLOW
  #G_IO_CHANNEL_ERROR_PIPE
  #G_IO_CHANNEL_ERROR_FAILED
EndEnumeration

Enumeration   ; GIOStatus
  #G_IO_STATUS_ERROR
  #G_IO_STATUS_NORMAL
  #G_IO_STATUS_EOF
  #G_IO_STATUS_AGAIN
EndEnumeration

Enumeration   ; GSeekType
  #G_SEEK_CUR
  #G_SEEK_SET
  #G_SEEK_END
EndEnumeration

Enumeration   ; GIOCondition
;  #G_IO_IN = #GLIB_SYSDEF_POLLIN
;  #G_IO_OUT = #GLIB_SYSDEF_POLLOUT
;  #G_IO_PRI = #GLIB_SYSDEF_POLLPRI
;  #G_IO_ERR = #GLIB_SYSDEF_POLLERR
;  #G_IO_HUP = #GLIB_SYSDEF_POLLHUP
;  #G_IO_NVAL = #GLIB_SYSDEF_POLLNVAL
EndEnumeration

Enumeration   ; GIOFlags
  #G_IO_FLAG_APPEND = 1<<0
  #G_IO_FLAG_NONBLOCK = 1<<1
  #G_IO_FLAG_IS_READABLE = 1<<2
  #G_IO_FLAG_IS_WRITEABLE = 1<<3
  #G_IO_FLAG_IS_SEEKABLE = 1<<4
  #G_IO_FLAG_MASK = (1<<5)-1
  #G_IO_FLAG_GET_MASK = #G_IO_FLAG_MASK
  #G_IO_FLAG_SET_MASK = #G_IO_FLAG_APPEND|#G_IO_FLAG_NONBLOCK
EndEnumeration

Structure GIOChannel
  ref_count.l  ; gint
  PB_Align(0, 4)
 *funcs.GIOFuncs
 *encoding
 *read_cd.GIConv
 *write_cd.GIConv
 *line_term
  line_term_len.l ; guint
  buf_size.i      ; gsize
  PB_Align(0, 4, 1)
 *read_buf.GString
 *encoded_read_buf.GString
 *write_buf.GString
  partial_write_buf.b[6]
  packed_flags.w
  ; use_buffer:1
  ; do_encode:1
  ; close_on_unref:1
  ; is_readable:1
  ; is_writeable:1
  ; is_seekable:1
  reserved1.i ; gpointer
  reserved2.i ; gpointer
EndStructure

Structure GIOFuncs
 *io_read
 *io_write
 *io_seek
 *io_close
 *io_create_watch
 *io_free
 *io_set_flags
 *io_get_flags
EndStructure

#G_WIN32_MSG_HANDLE = 19981206
