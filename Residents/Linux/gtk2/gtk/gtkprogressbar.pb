Enumeration   ; GtkProgressBarStyle
  #GTK_PROGRESS_CONTINUOUS
  #GTK_PROGRESS_DISCRETE
EndEnumeration

Enumeration   ; GtkProgressBarOrientation
  #GTK_PROGRESS_LEFT_TO_RIGHT
  #GTK_PROGRESS_RIGHT_TO_LEFT
  #GTK_PROGRESS_BOTTOM_TO_TOP
  #GTK_PROGRESS_TOP_TO_BOTTOM
EndEnumeration

Structure GtkProgressBar
  progress.GtkProgress
  bar_style.l        ; GtkProgressBarStyle enum
  orientation.l      ; GtkProgressBarOrientation enum
  blocks.l           ; guint
  in_block.l         ; gint
  activity_pos.l     ; gint
  activity_step.l    ; guint
  activity_blocks.l  ; guint
  PB_Align(0, 4, 0)
  pulse_fraction.d
  packed_flags.l
  ; activity_dir:1
  PB_Align(0, 4, 1)
EndStructure

Structure GtkProgressBarClass
  parent_class.GtkProgressClass
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

