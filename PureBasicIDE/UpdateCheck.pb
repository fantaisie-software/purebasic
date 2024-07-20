; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

; The URL that contains the update check file
;
; Example file:
;
; <?xml version="1.0" encoding="UTF-8"?>
; <versions xmlns="http://www.purebasic.com/namespace">
;   <version category="bugfix" number="5.11" name="PureBasic 5.11" />
;   <version category="beta" number="5.30" beta="3" name="PureBasic 5.30 beta 3" />
;   <version category="release" number="5.20" lts="1" name="PureBasic 5.20 LTS" />
; </versions>
;
; Possible values for each release: (note that names are case sensitive)
;
; category:
;   "release" - a feature release: 5.10, 5.20, ...
;   "bugfix"  - a bugfix release: 5.11, 5.12, ...
;   "beta"    - a beta release
;
; number:
;   release number in the form "5.20"
;
; beta:
;   beta number for beta releases
;
; lts:
;   "1" if the release is a LTS release
;
; name:
;   full name of the version for display
;

#UPDATE_CHECK_URL = #ProductWebSite$ + "/versions.xml"


; info about an available version
;
Structure Release
  Name$      ; string for display
  Category.l ; see below
  Number.l   ; release number (same as #PB_Compiler_Version)
  Beta.l     ; number of beta release (if category is "beta")
  LTS.l      ; true if this is an LTS version
  SortKey.l  ; for simpler sorting
EndStructure

; more important release last for sorting (so a final is higher than a beta)
Enumeration 1
  #CATEGORY_Beta
  #CATEGORY_Bugfix
  #CATEGORY_Final
EndEnumeration

Global UpdateCheck_DownloadComplete
Global UpdateCheck_DownloadResult
Global UpdateCheck_ShowNoUpdates

Procedure VisitDownloadSite()
  
  CompilerIf #DEMO = 0
    
    ; For registered users, directly open the secure download page
    Select UCase(CurrentLanguage$)
      Case "DEUTSCH":  Url$ = #ProductWebSite$ + "/securedownload/Login.php?language=DE"
      Case "FRANCAIS": Url$ = #ProductWebSite$ + "/securedownload/Login.php?language=FR"
      Default:         Url$ = #ProductWebSite$ + "/securedownload/Login.php?language="
    EndSelect
    
  CompilerElse
    
    ; For demo users, show the main download page
    Select UCase(CurrentLanguage$)
      Case "DEUTSCH":  Url$ = #ProductWebSite$ + "/german/download.php"
      Case "FRANCAIS": Url$ = #ProductWebSite$ + "/french/download.php"
      Default:         Url$ = #ProductWebSite$ + "/download.php"
    EndSelect
    
  CompilerEndIf
  
  OpenWebBrowser(Url$)
  
EndProcedure

Procedure UpdateWindowEvents(EventID)
  
  If EventID = #PB_Event_Menu     ; Little wrapper to map the shortcut events (identified as menu)
    EventID  = #PB_Event_Gadget   ; to normal gadget events...
    GadgetID = EventMenu()
  Else
    GadgetID = EventGadget()
  EndIf
  
  Select EventID
    Case #PB_Event_CloseWindow
      Quit = 1
      
    Case #PB_Event_Gadget
      Select GadgetID
          
        Case #GADGET_Updates_Website
          VisitDownloadSite()
          Quit = 1
          
        Case #GADGET_Updates_Settings
          OpenPreferencesWindow()
          Quit = 1
          
        Case #GADGET_Updates_Ok
          Quit = 1
          
      EndSelect
      
  EndSelect
  
  If Quit
    If MemorizeWindow
      UpdateWindowDialog\Close(@UpdateWindowPosition)
    Else
      UpdateWindowDialog\Close()
    EndIf
  EndIf
  
EndProcedure

Procedure ReadVersionFile(FileName$, List Releases.Release())
  ClearList(Releases())
  Result = #False
  
  If LoadXML(#XML_UpdateCheck, FileName$)
    If XMLStatus(#XML_UpdateCheck) = #PB_XML_Success And MainXMLNode(#XML_UpdateCheck)
      ; check the namespace
      *AllVersions = MainXMLNode(#XML_UpdateCheck)
      If ResolveXMLNodeName(*AllVersions, "/") = #UpdateCheckNamespace$ + "/versions"
        
        ; examine child nodes
        *Version = ChildXMLNode(*AllVersions)
        While *Version
          If XMLNodeType(*Version) = #PB_XML_Normal And GetXMLNodeName(*Version) = "version"
            
            Select GetXMLAttribute(*Version, "category")
              Case "final":  Category = #CATEGORY_Final
              Case "bugfix": Category = #CATEGORY_Bugfix
              Case "beta":   Category = #CATEGORY_Beta
              Default:       Category = -1
            EndSelect
            
            If Category <> -1 ; filter unknown categories (for future expandability)
              
              AddElement(Releases())
              Releases()\Name$    = GetXMLAttribute(*Version, "name")
              Releases()\Category = Category
              Releases()\Number   = Int(ValD(Trim(GetXMLAttribute(*Version, "number"))) * 100)
              
              LTS$ = GetXMLAttribute(*Version, "lts")
              If LTS$
                Releases()\LTS = Val(LTS$)
              EndIf
              
              Beta$ = GetXMLAttribute(*Version, "beta")
              If Beta$ <> ""
                Releases()\Beta = Val(Beta$)
              EndIf
              
              ; calculate a sort key
              Releases()\SortKey = Releases()\Number * 10000 + Releases()\Category * 100 + Releases()\Beta
              
            EndIf
            
          EndIf
          *Version = NextXMLNode(*Version)
        Wend
        
        Result = #True
      EndIf
    EndIf
    FreeXML(#XML_UpdateCheck)
  EndIf
  
  ; sort to have the highest release first
  SortStructuredList(Releases(), #PB_Sort_Descending, OffsetOf(Release\SortKey), #PB_Long)
  
  ProcedureReturn Result
EndProcedure

Procedure UpdateCheckTimer()
  
  ; test if the download is complete
  If Not UpdateCheck_DownloadComplete
    ProcedureReturn
  EndIf
  
  ; kill the timer
  RemoveWindowTimer(#WINDOW_Main, #TIMER_UpdateCheck)
  
  If Not UpdateCheck_DownloadResult
    ; download failed
    If UpdateCheck_ShowNoUpdates
      MessageRequester(Language("Updates","Title"), Language("Updates","Error"))
    EndIf
    ProcedureReturn
  EndIf
  
  ; perform the update check
  Protected NewList CheckedReleases.Release()
  Protected NewList AvailableReleases.Release()
  
  ; read the file from the previous check (if any)
  ReadVersionFile(UpdateCheckFile$, CheckedReleases())
  
  ; read the newly downloaded file
  If ReadVersionFile(UpdateCheckFile$ + "_new", AvailableReleases())
    ; replace the old file with the current one
    DeleteFile(UpdateCheckFile$)
    RenameFile(UpdateCheckFile$ + "_new", UpdateCheckFile$)
  Else
    If UpdateCheck_ShowNoUpdates
      MessageRequester(Language("Updates","Title"), Language("Updates","Error"))
    EndIf
    DeleteFile(UpdateCheckFile$ + "_new")
    ProcedureReturn
  EndIf
  
  ; get the current compiler version
  TokenizeCompilerVersion(DefaultCompiler\VersionString$, @CurrentNumber, @CurrentBeta, @OS, @Processor)
  If CurrentBeta = $FFFF
    ; a final release
    If (CurrentNumber % 10) = 0
      CurrentCategory = #CATEGORY_Final
    Else
      CurrentCategory = #CATEGORY_Bugfix
    EndIf
    CurrentBeta = 0
  Else
    ; a beta release
    CurrentCategory = #CATEGORY_Beta
    CurrentBeta >> 8  ; remove the alpha part
  EndIf
  
  ; filter the available releases list by:
  ;  - the list of previously checked versions
  ;  - the current compiler (default one)
  ;  - the preference settings
  ;
  ForEach AvailableReleases()
    Filter = #False
    
    ; check against current version
    If AvailableReleases()\Number < CurrentNumber
      Filter = #True
    ElseIf AvailableReleases()\Number = CurrentNumber And AvailableReleases()\Category < CurrentCategory
      Filter = #True
    ElseIf AvailableReleases()\Number = CurrentNumber And AvailableReleases()\Category = CurrentCategory And AvailableReleases()\Beta <= CurrentBeta
      Filter = #True
    EndIf
    
    ; check against preferences
    If UpdateCheckVersions = #UPDATE_Version_LTS And (AvailableReleases()\LTS = 0 Or AvailableReleases()\Category = #CATEGORY_Beta)
      Filter = #True
    ElseIf UpdateCheckVersions = #UPDATE_Version_Final And AvailableReleases()\Category = #CATEGORY_Beta
      Filter = #True
    EndIf
    
    ; check against previously seen versions
    ForEach CheckedReleases()
      If CheckedReleases()\Category = AvailableReleases()\Category And
         CheckedReleases()\Number = AvailableReleases()\Number And
         CheckedReleases()\Beta = AvailableReleases()\Beta And
         CheckedReleases()\LTS = AvailableReleases()\LTS And
         CheckedReleases()\Name$ = AvailableReleases()\Name$
        
        Filter = #True
        Break
      EndIf
    Next CheckedReleases()
    
    If Filter
      DeleteElement(AvailableReleases())
    EndIf
  Next AvailableReleases()
  
  
  ; open the dialog only if one or more releases remain!
  ;
  If ListSize(AvailableReleases()) > 0
    
    UpdateWindowDialog = OpenDialog(?Dialog_Updates, WindowID(#WINDOW_Main), @UpdateWindowPosition)
    If UpdateWindowDialog
      EnsureWindowOnDesktop(#WINDOW_Updates)
      
      ; get the right text
      If #DEMO
        Text$ = Language("Updates", "MessageDemo")
      ElseIf ListSize(AvailableReleases()) = 1
        Text$ = Language("Updates", "MessageSingle")
      Else
        Text$ = Language("Updates", "MessageMulti")
      EndIf
      
      Text$ + ":" + #NewLine + #NewLine
      
      ForEach AvailableReleases()
        Text$ + AvailableReleases()\Name$ + #NewLine
      Next AvailableReleases()
      
      SetGadgetText(#GADGET_Updates_Message, Text$)
      SetGadgetColor(#GADGET_Updates_Website, #PB_Gadget_FrontColor, $F00000)
      SetGadgetColor(#GADGET_Updates_Settings, #PB_Gadget_FrontColor, $F00000)
      
      UpdateWindowDialog\GuiUpdate() ; needed in case the text is very big
      HideWindow(#WINDOW_Updates, #False)
      
      ; fix required for the centereing of non-resizable windows in the dialog manager
      ; (works only if window is visible)
      CompilerIf #CompileLinuxGtk
        If UpdateWindowPosition\x = -1 And UpdateWindowPosition\y = -1
          While WindowEvent(): Wend
          gtk_window_set_position_(WindowID(#WINDOW_Updates), #GTK_WIN_POS_CENTER)
        EndIf
      CompilerEndIf
    EndIf
    
  ElseIf UpdateCheck_ShowNoUpdates = #True
    
    If UpdateCheckVersions = #UPDATE_Version_LTS
      NoUpdate$ = Language("Updates", "NoUpdatesLTS")
    ElseIf UpdateCheckVersions = #UPDATE_Version_All
      NoUpdate$ = Language("Updates", "NoUpdatesBeta")
    Else
      NoUpdate$ = Language("Updates", "NoUpdates")
    EndIf
    
    MessageRequester(Language("Updates","Title"), NoUpdate$, #FLAG_Info)
  EndIf
  
  ; update the "last check" time
  LastUpdateCheck = Date()
EndProcedure

; a thread to download the update check file in the background
;
Procedure UpdateCheck_Download(Dummy)
  CompilerIf #PB_Compiler_Thread = 0
    CompilerError "Need threadsafe for this routine"
  CompilerEndIf
  
  ; debugging
  ;UpdateCheck_DownloadResult = CopyFile("b:\versions.xml", UpdateCheckFile$ + "_new")
  
  UpdateCheck_DownloadResult = ReceiveHTTPFile(#UPDATE_CHECK_URL, UpdateCheckFile$ + "_new")
  UpdateCheck_DownloadComplete = #True
  
EndProcedure

Procedure UpdateCheck_Start()
  
  ; close any existing window
  If IsWindow(#WINDOW_Updates)
    UpdateWindowEvents(#PB_Event_CloseWindow)
  EndIf
  
  ; initiate a background download
  UpdateCheck_DownloadComplete = #False
  CreateThread(@UpdateCheck_Download(), 0)
  
  ; set a timer to read the result when download is complete
  AddWindowTimer(#WINDOW_Main, #TIMER_UpdateCheck, 500)
  
EndProcedure

Procedure CheckForUpdatesManual()
  
  ; show a requester if no updates are found
  UpdateCheck_ShowNoUpdates = #True
  
  ; delete old file, so any found version is returned, even
  ; if it was already shown in a previous check
  DeleteFile(UpdateCheckFile$)
  
  UpdateCheck_Start()
  
EndProcedure


Procedure CheckForUpdatesSchedule()
  
  ; When doing this check, do not show the requester if there
  ; are no updates
  UpdateCheck_ShowNoUpdates = #False
  
  ; Do the check only if the configured interval elapsed
  ;
  Select UpdateCheckInterval
      
    Case #UPDATE_Interval_Start
      UpdateCheck_Start()
      
    Case #UPDATE_Interval_Weekly
      If Date() > LastUpdateCheck + (7 * 24 * 60 * 60)
        UpdateCheck_Start()
      EndIf
      
    Case #UPDATE_Interval_Monthly
      Now = Date()
      If Year(Now) > Year(LastUpdateCheck) Or Month(Now) > Month(LastUpdateCheck)
        UpdateCheck_Start()
      EndIf
      
    Case #UPDATE_Interval_Never
      ; don't check
      
  EndSelect
  
  
EndProcedure


