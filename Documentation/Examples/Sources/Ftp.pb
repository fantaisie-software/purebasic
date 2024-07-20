;
; ------------------------------------------------------------
;
;   PureBasic - Ftp example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

If OpenFTP(0, "127.0.0.1", "test", "test", 0)

  Result = SendFTPFile(0, OpenFileRequester("Choose a file to send", "", "*.*", 0), "purebasic_sent.file", 1)
  
  Repeat
    Debug FTPProgress(0)
    Delay(300)
  Until FTPProgress(0) = #PB_FTP_Finished Or FTPProgress(0) =  #PB_FTP_Error

  Debug "finished"
  
Else
  MessageRequester("Error", "Can't connect to the FTP server")
EndIf
