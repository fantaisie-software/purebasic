Enumeration   ; GtkRcFlags
  #GTK_RC_FG = 1<<0
  #GTK_RC_BG = 1<<1
  #GTK_RC_TEXT = 1<<2
  #GTK_RC_BASE = 1<<3
EndEnumeration

Structure GtkRcStyle
  parent_instance.GObject
 *name
 *bg_pixmap_name[5]
 *font_desc.PangoFontDescription
  color_flags.l[5] ; GtkRcFlags enum
  PB_Align(0, 4)
  fg.GdkColor[5]
  bg.GdkColor[5]
  text.GdkColor[5]
  base.GdkColor[5]
  xthickness.l
  ythickness.l
 *rc_properties.GArray
 *rc_style_lists.GSList
 *icon_factories.GSList
  packed_flags.l
  ; engine_specified:1
  PB_Align(0, 4, 1)
EndStructure

Structure GtkRcStyleClass
  parent_class.GObjectClass
 *create_rc_style
 *parse
 *merge
 *create_style
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

Enumeration   ; GtkRcTokenType
  #GTK_RC_TOKEN_INVALID = #G_TOKEN_LAST
  #GTK_RC_TOKEN_INCLUDE
  #GTK_RC_TOKEN_NORMAL
  #GTK_RC_TOKEN_ACTIVE
  #GTK_RC_TOKEN_PRELIGHT
  #GTK_RC_TOKEN_SELECTED
  #GTK_RC_TOKEN_INSENSITIVE
  #GTK_RC_TOKEN_FG
  #GTK_RC_TOKEN_BG
  #GTK_RC_TOKEN_TEXT
  #GTK_RC_TOKEN_BASE
  #GTK_RC_TOKEN_XTHICKNESS
  #GTK_RC_TOKEN_YTHICKNESS
  #GTK_RC_TOKEN_FONT
  #GTK_RC_TOKEN_FONTSET
  #GTK_RC_TOKEN_FONT_NAME
  #GTK_RC_TOKEN_BG_PIXMAP
  #GTK_RC_TOKEN_PIXMAP_PATH
  #GTK_RC_TOKEN_STYLE
  #GTK_RC_TOKEN_BINDING
  #GTK_RC_TOKEN_BIND
  #GTK_RC_TOKEN_WIDGET
  #GTK_RC_TOKEN_WIDGET_CLASS
  #GTK_RC_TOKEN_CLASS
  #GTK_RC_TOKEN_LOWEST
  #GTK_RC_TOKEN_GTK
  #GTK_RC_TOKEN_APPLICATION
  #GTK_RC_TOKEN_THEME
  #GTK_RC_TOKEN_RC
  #GTK_RC_TOKEN_HIGHEST
  #GTK_RC_TOKEN_ENGINE
  #GTK_RC_TOKEN_MODULE_PATH
  #GTK_RC_TOKEN_IM_MODULE_PATH
  #GTK_RC_TOKEN_IM_MODULE_FILE
  #GTK_RC_TOKEN_STOCK
  #GTK_RC_TOKEN_LTR
  #GTK_RC_TOKEN_RTL
  #GTK_RC_TOKEN_LAST
EndEnumeration

Structure GtkRcProperty
  type_name.l
  property_name.l
 *origin
  value.GValue
EndStructure

