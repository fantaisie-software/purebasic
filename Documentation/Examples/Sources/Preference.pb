;
; ------------------------------------------------------------
;
;   PureBasic - Preference example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

If CreatePreferences(GetTemporaryDirectory()+"Preferences.prefs")
  PreferenceGroup("Global")
    WritePreferenceString("ApplicationName", "MP3 Player")
    WritePreferenceString("Version", "1.1b")

  PreferenceComment(" This is the Window dimension")
  PreferenceComment("")

  PreferenceGroup("Window")
    WritePreferenceLong ("WindowX", 123)
    WritePreferenceLong ("WindowY", 124)
    WritePreferenceFloat("WindowZ", -125.5)

  ClosePreferences()
EndIf


OpenPreferences(GetTemporaryDirectory()+"Preferences.prefs")

  PreferenceGroup("Window")
    Debug ReadPreferenceLong ("WindowX", 0)
    Debug ReadPreferenceLong ("WindowY", 0)
    Debug ReadPreferenceFloat("WindowZ", 0)
    
  PreferenceGroup("Global")
    Debug ReadPreferenceString("ApplicationName", "")
    Debug ReadPreferenceString("Version", "")
    
ClosePreferences()