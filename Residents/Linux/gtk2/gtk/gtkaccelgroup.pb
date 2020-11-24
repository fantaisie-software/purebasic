Enumeration   ; GtkAccelFlags
  #GTK_ACCEL_VISIBLE = 1<<0
  #GTK_ACCEL_LOCKED = 1<<1
  #GTK_ACCEL_MASK = $07
EndEnumeration

Structure GtkAccelGroup
  parent.GObject
  lock_count.l    ; guint
  modifier_mask.l ; GdkModifierType enum
 *acceleratables.GSList
  n_accels.l      ; guint
  PB_Align(0, 4)
 *priv_accels.GtkAccelGroupEntry
EndStructure

Structure GtkAccelGroupClass
  parent_class.GObjectClass
 *accel_changed
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

Structure GtkAccelKey
  accel_key.l
  accel_mods.l
  packed_flags.l
  ; accel_flags:16
  ; It stays unaligned on linux x64 (12 bytes long)
EndStructure

Structure GtkAccelGroupEntry
  key.GtkAccelKey
  PB_Align(0, 4, 0)
 *closure.GClosure
  accel_path_quark.l ; GQuark
  PB_Align(0, 4, 1)
EndStructure

