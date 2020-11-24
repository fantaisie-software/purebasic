Structure GtkImagePixmapData
 *pixmap.GdkPixmap
EndStructure

Structure GtkImageImageData
 *image.GdkImage
EndStructure

Structure GtkImagePixbufData
 *pixbuf.GdkPixbuf
EndStructure

Structure GtkImageStockData
 *stock_id
EndStructure

Structure GtkImageIconSetData
 *icon_set.GtkIconSet
EndStructure

Structure GtkImageAnimationData
 *anim.GdkPixbufAnimation
 *iter.GdkPixbufAnimationIter
  frame_timeout.l  ; guint
  PB_Align(0, 4)
EndStructure

Enumeration   ; GtkImageType
  #GTK_IMAGE_EMPTY
  #GTK_IMAGE_PIXMAP
  #GTK_IMAGE_IMAGE
  #GTK_IMAGE_PIXBUF
  #GTK_IMAGE_STOCK
  #GTK_IMAGE_ICON_SET
  #GTK_IMAGE_ANIMATION
EndEnumeration

Structure GtkImage
  misc.GtkMisc
  storage_type.l ; GtkImageType enum
  PB_Align(0, 4)
  StructureUnion
    pixmap.GtkImagePixmapData
    image.GtkImageImageData
    pixbuf.GtkImagePixbufData
    stock.GtkImageStockData
    icon_set.GtkImageIconSetData
    anim.GtkImageAnimationData
  EndStructureUnion
 *mask.GdkBitmap
  icon_size.l ; GtkIconSize enum
  PB_Align(0, 4, 1)
EndStructure

Structure GtkImageClass
  parent_class.GtkMiscClass
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

