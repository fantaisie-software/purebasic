;
; ------------------------------------------------------------
;
;   PureBasic - FileSystem example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

If OpenWindow(0, 100, 200, 290, 200, "PureBasic - FileSystem Example")

  StringGadget  (0,  10, 10, 202, 24, GetHomeDirectory())
  ButtonGadget  (1, 220, 10, 60 , 24, "List")
  ListViewGadget(2,  10, 40, 270, 150)

  Repeat
    Event = WaitWindowEvent()

    If Event = #PB_Event_Gadget
      If EventGadget() = 1 ; Read

        ClearGadgetItems(2)  ; Clear all the items found in the ListView

        If ExamineDirectory(0, GetGadgetText(0), "*.*")

          While NextDirectoryEntry(0)

            FileName$ = DirectoryEntryName(0)
            If DirectoryEntryType(0) = #PB_DirectoryEntry_Directory
              FileName$ = "[DIR] "+FileName$
            EndIf
            
            AddGadgetItem(2, -1, FileName$)
            
          Wend
          
        Else
          MessageRequester("Error","Can't examine this directory: "+GetGadgetText(0),0)
        EndIf

      EndIf
    EndIf

  Until Event = #PB_Event_CloseWindow

EndIf

End