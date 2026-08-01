;
; ------------------------------------------------------------
;
;   PureBasic - TLS Server
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

Key$ = "-----BEGIN PRIVATE KEY-----"+#LF$+
       "MIICdQIBADANBgkqhkiG9w0BAQEFAASCAl8wggJbAgEAAoGBAPEbSQq/uwESZduPtDd83qXXkSPf6lUNa17xhM2fOZQxGr0Fdmvw6IsC+QGX25EE1TG6TFQkHlM2rW8y6a3WEC/WzCNWaTCPYD/rguiAFG+4eQmwHjiJFVec0InjjSG9SX8xwS/gQeWdQniKROO4DmMJO8N7mdUhdHODSntXdr9zAgMBAAECgYAE+VMgbaQl+YMwbF6DZogRU8kivFPRPV2hr8nVlBtT+09Z5uryfx3NAFqytbdJ3penVviMI9KcVNxvFtXLSEc9KyjzgysorAfUpwFuECCLDbOXX0HlV6rgkqJdhyV6FybcDLvgcvulHQ64QdYRhW+jPx7vXk3h0/JRFqKQJsY7QQJBAPrDLJRPbAw+Mlq1fHBWk8Z1Qn1ivPAmz+2nPAgDya/xdAlb9GbFAMzCS3upIBpxW70uLI04OuTVhwYL194I5C0CQQD2JHtHp25SkIDpBgZGicEC7yAIE/wPC0P9X85UJqXx5dPx4HbEc8lqSKMbCzkbHyvjHonSHu00QxU1W6ZALFYfAkBcPWzphSl+e2Z0XWvPutkS2FFD5A0R3YUAq1J2tEX9NTj0tGF7aB36M8ImU7jeYTJYrWJv8+4d/Ll1LOgT4XtlAkAxofOV5EYTsf28fzF+wcJAtDUyS81Uv0HLcqkpQM3PdDeDm253eJ2Rp+nzxxSRynxQBNVnoELWefxp0Pw6DnajAkBF5h7fQIbwAEPrhDzhjMXU7g9k9KzkkJN/bluLbleqkkAz1kfkGtWXJdGITZuY4K/X2yp1diWQ0utZjmOmhWsl"+#LF$+
       "-----END PRIVATE KEY-----"

Cert$ = "-----BEGIN CERTIFICATE-----"+#LF$+
        "MIICnTCCAgYCCQD0AWy2vzfcpzANBgkqhkiG9w0BAQUFADCBkjELMAkGA1UEBhMCVVMxDjAMBgNVBAgTBVN0YXRlMQ0wCwYDVQQHEwRDaXR5MRUwEwYDVQQKEwxPcmdhbml6YXRpb24xHDAaBgNVBAsTE09yZ2FuaXphdGlvbmFsIFVuaXQxLzAtBgNVBAMTJkNvbW1vbiBOYW1lIChlLmcuLCB5b3VyIHNlcnZlciBkb21haW4pMB4XDTI0MTEwNjE2NTI1N1oXDTI0MTIwNjE2NTI1N1owgZIxCzAJBgNVBAYTAlVTMQ4wDAYDVQQIEwVTdGF0ZTENMAsGA1UEBxMEQ2l0eTEVMBMGA1UEChMMT3JnYW5pemF0aW9uMRwwGgYDVQQLExNPcmdhbml6YXRpb25hbCBVbml0MS8wLQYDVQQDEyZDb21tb24gTmFtZSAoZS5nLiwgeW91ciBzZXJ2ZXIgZG9tYWluKTCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEA8RtJCr+7ARJl24+0N3zepdeRI9/qVQ1rXvGEzZ85lDEavQV2a/DoiwL5AZfbkQTVMbpMVCQeUzatbzLprdYQL9bMI1ZpMI9gP+uC6IAUb7h5CbAeOIkVV5zQieONIb1JfzHBL+BB5Z1CeIpE47gOYwk7w3uZ1SF0c4NKe1d2v3MCAwEAATANBgkqhkiG9w0BAQUFAAOBgQCprm5a5bg1LqCDdtwDTnRDmVcca6HoUlvbjZLmWdLjltG1McNAATppTy/bF7vT3jXLobA1Vzs2g14POjYQhPnIbRPEnNzvAe+Se3y0YeFOwYarEyFBHKHODGIPaCnXGH8gB9fgcp2SYtLaPKvXdNL44VeYGbD4+fvUcu/zkXqTSg=="+#LF$+
        "-----END CERTIFICATE-----"

UseNetworkTLS(Key$, Cert$)
Connection = CreateNetworkServer(#PB_Any, 20252, #PB_Network_TCP | #PB_Network_IPv4 | #PB_Network_TLSv1_3)

If Connection
  Debug "TLS Server started: launch NetworkTlsClient.pb to send a string !"
  Timeout = 10000
  
  *Buffer = AllocateMemory(1000)
  
  Repeat
    Select NetworkServerEvent()
      Case #PB_NetworkEvent_Data
        
        Debug "Data !"
        ClientID = EventClient()
        PokeA(*Buffer, 0)
        Debug ReceiveNetworkData(ClientID, *Buffer, 1000)
        
        Debug "String: "+PeekS(*Buffer, -1, #PB_UTF8)
        SendNetworkString(ClientID, "Well received !")
        
      Case #PB_NetworkEvent_None
        Delay(200)
        Timeout - 1
    EndSelect
        
  Until Timeout = 0
  
  CloseNetworkServer(Connection)
Else
  Debug "Can't create the server"
EndIf
