Enumeration   ; GtkCalendarDisplayOptions
  #GTK_CALENDAR_SHOW_HEADING = 1<<0
  #GTK_CALENDAR_SHOW_DAY_NAMES = 1<<1
  #GTK_CALENDAR_NO_MONTH_CHANGE = 1<<2
  #GTK_CALENDAR_SHOW_WEEK_NUMBERS = 1<<3
  #GTK_CALENDAR_WEEK_START_MONDAY = 1<<4
EndEnumeration

Structure GtkCalendar
  widget.GtkWidget
 *header_style.GtkStyle
 *label_style.GtkStyle
  month.l
  year.l
  selected_day.l
  day_month.l[6*7]
  day.l[6*7]
  num_marked_dates.l
  marked_date.l[31]
  display_flags.l
  marked_date_color.GdkColor[31]
  PB_Align(0, 4)
 *gc.GdkGC
 *xor_gc.GdkGC
  focus_row.l
  focus_col.l
  highlight_row.l
  highlight_col.l
 *private_data
  grow_space.b[32]
 *_gtk_reserved1
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

Structure GtkCalendarClass
  parent_class.GtkWidgetClass
 *month_changed
 *day_selected
 *day_selected_double_click
 *prev_month
 *next_month
 *prev_year
 *next_year
EndStructure

