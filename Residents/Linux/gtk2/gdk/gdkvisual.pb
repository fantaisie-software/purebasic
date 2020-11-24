Enumeration   ; GdkVisualType
  #GDK_VISUAL_STATIC_GRAY
  #GDK_VISUAL_GRAYSCALE
  #GDK_VISUAL_STATIC_COLOR
  #GDK_VISUAL_PSEUDO_COLOR
  #GDK_VISUAL_TRUE_COLOR
  #GDK_VISUAL_DIRECT_COLOR
EndEnumeration

Structure GdkVisual
  parent_instance.GObject
  type.l
  depth.l
  byte_order.l
  colormap_size.l
  bits_per_rgb.l
  red_mask.l
  red_shift.l
  red_prec.l
  green_mask.l
  green_shift.l
  green_prec.l
  blue_mask.l
  blue_shift.l
  blue_prec.l
EndStructure

