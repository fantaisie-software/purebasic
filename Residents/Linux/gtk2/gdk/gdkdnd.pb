Enumeration   ; GdkDragAction
  #GDK_ACTION_DEFAULT = 1<<0
  #GDK_ACTION_COPY = 1<<1
  #GDK_ACTION_MOVE = 1<<2
  #GDK_ACTION_LINK = 1<<3
  #GDK_ACTION_PRIVATE = 1<<4
  #GDK_ACTION_ASK = 1<<5
EndEnumeration

Enumeration   ; GdkDragProtocol
  #GDK_DRAG_PROTO_MOTIF
  #GDK_DRAG_PROTO_XDND
  #GDK_DRAG_PROTO_ROOTWIN
  #GDK_DRAG_PROTO_NONE
  #GDK_DRAG_PROTO_WIN32_DROPFILES
  #GDK_DRAG_PROTO_OLE2
  #GDK_DRAG_PROTO_LOCAL
EndEnumeration

Structure GdkDragContext
  parent_instance.GObject
  protocol.l  ; GdkDragProtocol enum
  is_source.l ; gboolean
 *source_window.GdkWindow
 *dest_window.GdkWindow
 *targets.GList
  actions.l  				 ; GdkDragProtocol enum
  suggested_action.l ; GdkDragProtocol enum
  action.l           ; GdkDragProtocol enum
  start_time.l       ; guint
  windowing_data.i   ; gpointer
EndStructure

Structure GdkDragContextClass
  parent_class.GObjectClass
EndStructure

