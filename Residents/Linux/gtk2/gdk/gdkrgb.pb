Structure GdkRgbCmap
  colors.l[256] ; guint
  n_colors.l    ; gint
  PB_Align(0, 4)
 *info_list.GSList
EndStructure

Enumeration   ; GdkRgbDither
  #GDK_RGB_DITHER_NONE
  #GDK_RGB_DITHER_NORMAL
  #GDK_RGB_DITHER_MAX
EndEnumeration

