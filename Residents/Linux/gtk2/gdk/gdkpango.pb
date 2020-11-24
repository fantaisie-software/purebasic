Structure PangoAttribute
 *klass.PangoAttrClass
  start_index.l
  end_index.l
EndStructure

Structure GdkPangoAttrStipple
  attr.PangoAttribute
 *stipple.GdkBitmap
EndStructure

Structure GdkPangoAttrEmbossed
  attrl.PangoAttribute
  embossed.l ; gboolean
  PB_Align(0, 4)
EndStructure

