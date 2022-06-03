;
; ------------------------------------------------------------
;
;   PureBasic - Mail example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

If CreateMail(0, "fred@purebasic.com", "Hello !")

  SetMailBody(0, "Hello !" + #CRLF$ +
                 "This is a multi-" + #CRLF$ +
                 "line mail !")
  
  AddMailAttachment(0, "Geebee !"  , "Data/Geebee2.bmp")
  AddMailAttachment(0, "World icon", "Data/world.png")
  
  ; Change the recipients to real one
  ;
  AddMailRecipient(0, "test@yourdomain.com", #PB_Mail_To)
  AddMailRecipient(0, "test_cc@yourdomain.com", #PB_Mail_Cc)
  
  ; Set the SMTP server to use
  ;
  Result = SendMail(0, "smtp.free.fr", 25, #PB_Mail_Asynchronous)
  
  Repeat
    Progress = MailProgress(0)
    Delay(300)
  Until Progress = #PB_Mail_Finished Or Progress = #PB_Mail_Error
  
  If Progress = #PB_Mail_Finished
    MessageRequester("Information", "Mail correctly sent !")
  Else
    MessageRequester("Error", "Can't sent the mail !")
  EndIf
  
EndIf
