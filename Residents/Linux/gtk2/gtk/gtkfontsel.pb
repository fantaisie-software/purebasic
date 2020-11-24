Structure GtkFontSelection
  parent_instance.GtkVBox
 *font_entry.GtkWidget
 *family_list.GtkWidget
 *font_style_entry.GtkWidget
 *face_list.GtkWidget
 *size_entry.GtkWidget
 *size_list.GtkWidget
 *pixels_button.GtkWidget
 *points_button.GtkWidget
 *filter_button.GtkWidget
 *preview_entry.GtkWidget
 *family.PangoFontFamily
 *face.PangoFontFace
  size.l  ; gint
  PB_Align(0, 4)
 *font.GdkFont
EndStructure

Structure GtkFontSelectionClass
  parent_class.GtkVBoxClass
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

Structure GtkFontSelectionDialog
  parent_instance.GtkDialog
 *fontsel.GtkWidget
 *main_vbox.GtkWidget
 *action_area.GtkWidget
 *ok_button.GtkWidget
 *apply_button.GtkWidget
 *cancel_button.GtkWidget
  dialog_width.l
  auto_resize.l
EndStructure

Structure GtkFontSelectionDialogClass
  parent_class.GtkDialogClass
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

