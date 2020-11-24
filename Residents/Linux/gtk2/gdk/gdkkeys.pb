Structure GdkKeymapKey
  keycode.l
  group.l
  level.l
EndStructure

Structure GdkKeymap
  parent_instance.GObject
 *display.GdkDisplay
EndStructure

Structure GdkKeymapClass
  parent_class.GObjectClass
 *direction_changed
 *keys_changed
 *state_changed
EndStructure

