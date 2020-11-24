Structure GtkIconTheme
  parent_instance.GObject
 *priv.GtkIconThemePrivate
EndStructure

Structure GtkIconThemeClass
  parent_class.GObjectClass
 *changed
EndStructure

Enumeration   ; GtkIconLookupFlags
  #GTK_ICON_LOOKUP_NO_SVG = 1<<0
  #GTK_ICON_LOOKUP_FORCE_SVG = 1<<1
  #GTK_ICON_LOOKUP_USE_BUILTIN = 1<<2
EndEnumeration

Enumeration   ; GtkIconThemeError
  #GTK_ICON_THEME_NOT_FOUND
  #GTK_ICON_THEME_FAILED
EndEnumeration

