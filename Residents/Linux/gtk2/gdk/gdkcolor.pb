Structure GdkColor
  pixel.l
  red.u
  green.u
  blue.u
  pad.u
  ; Exceptionnally, the structure isn't 8 bytes aligned on x64
EndStructure

Structure GdkColormap
  parent_instance.GObject
  size.l           ; gint
  PB_Align(0, 4)
 *colors.GdkColor
 *visual.GdkVisual
  windowing_data.i ; gpointer
EndStructure

Structure GdkColormapClass
  parent_class.GObjectClass
EndStructure

