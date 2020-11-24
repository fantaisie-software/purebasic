Structure GtkButton
  bin.GtkBin
 *event_window.GdkWindow
 *label_text
  activate_timeout.l
  packed_flags.l
  ; constructed:1
  ; in_button:1
  ; button_down:1
  ; relief:2
  ; use_underline:1
  ; use_stock:1
  ; depressed:1
  ; depress_on_activate:1
  ; focus_on_click:1
EndStructure

Structure GtkButtonClass
  parent_class.GtkBinClass
 *pressed
 *released
 *clicked
 *enter
 *leave
 *activate
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

