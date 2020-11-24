Enumeration   ; GdkImageType
  #GDK_IMAGE_NORMAL
  #GDK_IMAGE_SHARED
  #GDK_IMAGE_FASTEST
EndEnumeration

Structure GdkImage
  parent_instance.GObject
  type.l ; GdkImageType enum
  PB_Align(0, 4, 0)
 *visual.GdkVisual
  byte_order.l ; GdkByteOrder enum
  width.l      ; guint
  height.l     ; guint
  depth.w
  bpp.w
  bpl.w
  bits_per_pixel.w
  PB_Align(0, 4, 1)
  mem.i            ; gpointer
 *colormap.GdkColormap
  windowing_data.i ; gpointer
EndStructure

Structure GdkImageClass
  parent_class.GObjectClass
EndStructure

