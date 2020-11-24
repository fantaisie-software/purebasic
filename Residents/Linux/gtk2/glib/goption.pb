Enumeration   ; GOptionFlags
  #G_OPTION_FLAG_HIDDEN = 1<<0
  #G_OPTION_FLAG_IN_MAIN = 1<<1
  #G_OPTION_FLAG_REVERSE = 1<<2
EndEnumeration

Enumeration   ; GOptionArg
  #G_OPTION_ARG_NONE
  #G_OPTION_ARG_STRING
  #G_OPTION_ARG_INT
  #G_OPTION_ARG_CALLBACK
  #G_OPTION_ARG_FILENAME
  #G_OPTION_ARG_STRING_ARRAY
  #G_OPTION_ARG_FILENAME_ARRAY
EndEnumeration

Enumeration   ; GOptionError
  #G_OPTION_ERROR_UNKNOWN_OPTION
  #G_OPTION_ERROR_BAD_VALUE
  #G_OPTION_ERROR_FAILED
EndEnumeration

Structure GOptionEntry
 *long_name
  short_name.b
  PB_Align(3, 3)
  flags.l     ; gint
 *arg.GOptionArg
  arg_data.i  ; gpointer
 *description
 *arg_description
EndStructure

#G_OPTION_REMAINING = ""
