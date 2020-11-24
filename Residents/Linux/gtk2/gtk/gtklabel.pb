Structure GtkLabel
  misc.GtkMisc
 *label
  packed_flags.l
  ; jtype:2
  ; wrap:1
  ; use_underline:1
  ; use_markup:1
  mnemonic_keyval.l
 *text
 *attrs.PangoAttrList
 *effective_attrs.PangoAttrList
 *layout.PangoLayout
 *mnemonic_widget.GtkWidget
 *mnemonic_window.GtkWindow
 *select_info.GtkLabelSelectionInfo
EndStructure

Structure GtkLabelClass
  parent_class.GtkMiscClass
 *move_cursor
 *copy_clipboard
 *populate_popup
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

