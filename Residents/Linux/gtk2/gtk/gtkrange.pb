Structure GtkRange
  widget.GtkWidget
 *adjustment.GtkAdjustment
  update_policy.l
  packed_flags.l
  ; inverted:1
  ; flippable:1
  ; has_stepper_a:1
  ; has_stepper_b:1
  ; has_stepper_c:1
  ; has_stepper_d:1
  ; need_recalc:1
  ; slider_size_fixed:1
  min_slider_size.l
  orientation.l
  range_rect.GdkRectangle
  slider_start.l
  slider_end.l
  round_digits.l
  packed_flags_2.l
  ; trough_click_forward:1
  ; update_pending:1
 *layout.GtkRangeLayout
 *timer.GtkRangeStepTimer
  slide_initial_slider_position.l  ; gint
  slide_initial_coordinate.l       ; gint
  update_timeout_id.l              ; guint
  PB_Align(0, 4)
 *event_window.GdkWindow
EndStructure

Structure GtkRangeClass
  parent_class.GtkWidgetClass
 *slider_detail
 *stepper_detail
 *value_changed
 *adjust_bounds
 *move_slider
 *get_range_border
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

