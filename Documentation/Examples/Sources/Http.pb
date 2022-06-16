;
; ------------------------------------------------------------
;
;   PureBasic - Http example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

URL$ = "http://user:pass@www.purebasic.com:1024/subdirectory/index.php?year=2008&month=12&day=3"
Debug GetURLPart(URL$, "year")
Debug GetURLPart(URL$, #PB_URL_Site)
Debug GetURLPart(URL$, #PB_URL_Port)
Debug GetURLPart(URL$, #PB_URL_Parameters)
Debug GetURLPart(URL$, #PB_URL_Path)
Debug GetURLPart(URL$, #PB_URL_User)
Debug GetURLPart(URL$, #PB_URL_Password)

Debug "-------"
Debug SetURLPart(URL$, #PB_URL_Site, "forums.purebasic.fr")
Debug SetURLPart(URL$, #PB_URL_Port, "80")
Debug SetURLPart(URL$, #PB_URL_User, "bericko")
Debug SetURLPart(URL$, #PB_URL_Password, "password")



