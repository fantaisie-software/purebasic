#GDK_PRIORITY_EVENTS = (#G_PRIORITY_DEFAULT)
#GDK_PRIORITY_REDRAW = (#G_PRIORITY_HIGH_IDLE+20)
Enumeration   ; GdkFilterReturn
  #GDK_FILTER_CONTINUE
  #GDK_FILTER_TRANSLATE
  #GDK_FILTER_REMOVE
EndEnumeration

Enumeration   ; GdkEventType
  #GDK_NOTHING = -1
  #GDK_DELETE = 0
  #GDK_DESTROY = 1
  #GDK_EXPOSE = 2
  #GDK_MOTION_NOTIFY = 3
  #GDK_BUTTON_PRESS = 4
  #GDK_2BUTTON_PRESS = 5
  #GDK_3BUTTON_PRESS = 6
  #GDK_BUTTON_RELEASE = 7
  #GDK_KEY_PRESS = 8
  #GDK_KEY_RELEASE = 9
  #GDK_ENTER_NOTIFY = 10
  #GDK_LEAVE_NOTIFY = 11
  #GDK_FOCUS_CHANGE = 12
  #GDK_CONFIGURE = 13
  #GDK_MAP = 14
  #GDK_UNMAP = 15
  #GDK_PROPERTY_NOTIFY = 16
  #GDK_SELECTION_CLEAR = 17
  #GDK_SELECTION_REQUEST = 18
  #GDK_SELECTION_NOTIFY = 19
  #GDK_PROXIMITY_IN = 20
  #GDK_PROXIMITY_OUT = 21
  #GDK_DRAG_ENTER = 22
  #GDK_DRAG_LEAVE = 23
  #GDK_DRAG_MOTION = 24
  #GDK_DRAG_STATUS = 25
  #GDK_DROP_START = 26
  #GDK_DROP_FINISHED = 27
  #GDK_CLIENT_EVENT = 28
  #GDK_VISIBILITY_NOTIFY = 29
  #GDK_NO_EXPOSE = 30
  #GDK_SCROLL = 31
  #GDK_WINDOW_STATE = 32
  #GDK_SETTING = 33
EndEnumeration

Enumeration   ; GdkEventMask
  #GDK_EXPOSURE_MASK = 1<<1
  #GDK_POINTER_MOTION_MASK = 1<<2
  #GDK_POINTER_MOTION_HINT_MASK = 1<<3
  #GDK_BUTTON_MOTION_MASK = 1<<4
  #GDK_BUTTON1_MOTION_MASK = 1<<5
  #GDK_BUTTON2_MOTION_MASK = 1<<6
  #GDK_BUTTON3_MOTION_MASK = 1<<7
  #GDK_BUTTON_PRESS_MASK = 1<<8
  #GDK_BUTTON_RELEASE_MASK = 1<<9
  #GDK_KEY_PRESS_MASK = 1<<10
  #GDK_KEY_RELEASE_MASK = 1<<11
  #GDK_ENTER_NOTIFY_MASK = 1<<12
  #GDK_LEAVE_NOTIFY_MASK = 1<<13
  #GDK_FOCUS_CHANGE_MASK = 1<<14
  #GDK_STRUCTURE_MASK = 1<<15
  #GDK_PROPERTY_CHANGE_MASK = 1<<16
  #GDK_VISIBILITY_NOTIFY_MASK = 1<<17
  #GDK_PROXIMITY_IN_MASK = 1<<18
  #GDK_PROXIMITY_OUT_MASK = 1<<19
  #GDK_SUBSTRUCTURE_MASK = 1<<20
  #GDK_SCROLL_MASK = 1<<21
  #GDK_ALL_EVENTS_MASK = $3FFFFE
EndEnumeration

Enumeration   ; GdkVisibilityState
  #GDK_VISIBILITY_UNOBSCURED
  #GDK_VISIBILITY_PARTIAL
  #GDK_VISIBILITY_FULLY_OBSCURED
EndEnumeration

Enumeration   ; GdkScrollDirection
  #GDK_SCROLL_UP
  #GDK_SCROLL_DOWN
  #GDK_SCROLL_LEFT
  #GDK_SCROLL_RIGHT
EndEnumeration

Enumeration   ; GdkNotifyType
  #GDK_NOTIFY_ANCESTOR = 0
  #GDK_NOTIFY_VIRTUAL = 1
  #GDK_NOTIFY_INFERIOR = 2
  #GDK_NOTIFY_NONLINEAR = 3
  #GDK_NOTIFY_NONLINEAR_VIRTUAL = 4
  #GDK_NOTIFY_UNKNOWN = 5
EndEnumeration

Enumeration   ; GdkCrossingMode
  #GDK_CROSSING_NORMAL
  #GDK_CROSSING_GRAB
  #GDK_CROSSING_UNGRAB
EndEnumeration

Enumeration   ; GdkPropertyState
  #GDK_PROPERTY_NEW_VALUE
  #GDK_PROPERTY_DELETE
EndEnumeration

Enumeration   ; GdkWindowState
  #GDK_WINDOW_STATE_WITHDRAWN = 1<<0
  #GDK_WINDOW_STATE_ICONIFIED = 1<<1
  #GDK_WINDOW_STATE_MAXIMIZED = 1<<2
  #GDK_WINDOW_STATE_STICKY = 1<<3
  #GDK_WINDOW_STATE_FULLSCREEN = 1<<4
  #GDK_WINDOW_STATE_ABOVE = 1<<5
  #GDK_WINDOW_STATE_BELOW = 1<<6
EndEnumeration

Enumeration   ; GdkSettingAction
  #GDK_SETTING_ACTION_NEW
  #GDK_SETTING_ACTION_CHANGED
  #GDK_SETTING_ACTION_DELETED
EndEnumeration

Structure GdkEventAny
  type.l ; GdkEventType enum
  PB_Align(0, 4, 0)
 *window.GdkWindow
  send_event.b
  PB_Align(3, 7, 1)
EndStructure

Structure GdkEventExpose
  type.l ; GdkEventType enum
  PB_Align(0, 4, 0)
 *window.GdkWindow
  send_event.b
  PB_Align(3, 7, 1)
  area.GdkRectangle
 *region.GdkRegion
  count.l ; gint
  PB_Align(0, 4, 2)
EndStructure

Structure GdkEventNoExpose
  type.l ; GdkEventType enum
  PB_Align(0, 4, 0)
 *window.GdkWindow
  send_event.b
  PB_Align(3, 7, 1)
EndStructure

Structure GdkEventVisibility
  type.l ; GdkEventType enum
  PB_Align(0, 4, 0)
 *window.GdkWindow
  send_event.b
  PB_Align(3, 3, 1)
  state.l ; GdkVisibilityState enum
EndStructure

Structure GdkEventMotion
  type.l ; GdkEventType enum
  PB_Align(0, 4, 0)
 *window.GdkWindow
  send_event.b
  PB_Align(3, 3, 1)
  time.l ; guint
  x.d
  y.d
 *axes
  state.l
  is_hint.w
  pad2.w
 *device.GdkDevice
  x_root.d
  y_root.d
EndStructure

Structure GdkEventButton
  type.l ; GdkEventType enum
  PB_Align(0, 4, 0)
 *window.GdkWindow
  send_event.b
  pad.b[3]
  time.l
  x.d
  y.d
 *axes
  state.l
  button.l
 *device.GdkDevice
  x_root.d
  y_root.d
EndStructure

Structure GdkEventScroll
  type.l ; GdkEventType enum
  PB_Align(0, 4, 0)
 *window.GdkWindow
  send_event.b
  pad.b[3]
  time.l
  x.d
  y.d
  state.l
  direction.l
 *device.GdkDevice
  x_root.d
  y_root.d
EndStructure

Structure GdkEventKey
  type.l ; GdkEventType enum
  PB_Align(0, 4, 0)
 *window.GdkWindow
  send_event.b
  PB_Align(3, 3, 1)
  time.l  ; guint
  state.l
  keyval.l
  length.l
  PB_Align(0, 4, 2)
 *string
  hardware_keycode.w
  group.b
  PB_Align(1, 5, 3)
EndStructure

Structure GdkEventCrossing
  type.l ; GdkEventType enum
  PB_Align(0, 4, 0)
 *window.GdkWindow
  send_event.b
  PB_Align(3, 7, 1)
 *subwindow.GdkWindow
  time.l ; gunit
  PB_Align(0, 4, 2)
  x.d
  y.d
  x_root.d
  y_root.d
  mode.l   ; GdkCrossingMode enum
  detail.l ; GdkNotifyType enum
  focus.l  ; gboolean
  state.l  ; guint
EndStructure

Structure GdkEventFocus
  type.l ; GdkEventType enum
  PB_Align(0, 4, 0)
 *window.GdkWindow
  send_event.b
  PB_Align(1, 1, 1)
  in.w
  PB_Align(0, 4, 2)
EndStructure

Structure GdkEventConfigure
  type.l ; GdkEventType enum
  PB_Align(0, 4, 0)
 *window.GdkWindow
  send_event.b
  PB_Align(3, 3, 1)
  x.l      ; gint
  y.l      ; gint
  width.l  ; gint
  height.l ; gint
  PB_Align(0, 4, 2)
EndStructure

Structure GdkEventProperty
  type.l ; GdkEventType enum
  PB_Align(0, 4, 0)
 *window.GdkWindow
  send_event.b
  PB_Align(3, 7, 1)
  atom.i   ; GdkAtom
  time.l   ; guint
  state.l  ; guint
EndStructure

Structure GdkEventSelection
  type.l ; GdkEventType enum
  PB_Align(0, 4, 0)
 *window.GdkWindow
  send_event.b
  PB_Align(3, 7, 1)
  selection.i ; GdkAtom
  target.i    ; GdkAtom
  property.i  ; GdkAtom
  time.l      ; guint
  requestor.l ; GdkNativeWindow, which can be a pointer if 'GDK_NATIVE_WINDOW_POINTER' is defined (which doesn't seems to be the case on my Linux x64)
EndStructure

Structure GdkEventProximity
  type.l ; GdkEventType enum
  PB_Align(0, 4, 0)
 *window.GdkWindow
  send_event.b
  pad.b[3]
  time.l
 *device.GdkDevice
EndStructure

Structure GdkEventClient
  type.l ; GdkEventType enum
  PB_Align(0, 4, 0)
 *window.GdkWindow
  send_event.b
  PB_Align(3, 7, 1)
  message_type.i ; GdkAtom
  data_format.w
  PB_Align(2, 6, 2)
  StructureUnion
    b.b[20]
    s.w[10]
    l.i[5]   ; long
  EndStructureUnion
EndStructure

Structure GdkEventSetting
  type.l ; GdkEventType enum
  PB_Align(0, 4, 0)
 *window.GdkWindow
  send_event.b
  pad.b[3]
  action.l
 *name
EndStructure

Structure GdkEventWindowState
  type.l ; GdkEventType enum
  PB_Align(0, 4, 0)
 *window.GdkWindow
  send_event.b
  PB_Align(3, 3, 1)
  changed_mask.l     ; GdkWindowState enum
  new_window_state.l ; GdkWindowState enum
  PB_Align(0, 4, 2)
EndStructure

Structure GdkEventDND
  type.l ; GdkEventType enum
  PB_Align(0, 4, 0)
 *window.GdkWindow
  send_event.b
  PB_Align(3, 7, 1)
 *context.GdkDragContext
  time.l    ; guint
  x_root.w  ; gshort
  y_root.w  ; gshort
EndStructure

