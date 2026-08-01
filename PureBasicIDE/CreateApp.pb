; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


Global *CurrentAppTarget.CompileTarget, CurrentAppTab, CurrentAppIsProject


Procedure UpdateCreateAppWindow()
  
  IsDisabled = Bool(Not GetGadgetState(#GADGET_WebApp_EnableResourceDirectory))
  DisableGadget(#GADGET_WebApp_ResourceDirectory, IsDisabled)
  DisableGadget(#GADGET_WebApp_SelectResourceDirectory, IsDisabled)
  
  IsDisabled = Bool(Not GetGadgetState(#GADGET_iOSApp_EnableResourceDirectory))
  DisableGadget(#GADGET_iOSApp_ResourceDirectory, IsDisabled)
  DisableGadget(#GADGET_iOSApp_SelectResourceDirectory, IsDisabled)
  
  IsDisabled = Bool(Not GetGadgetState(#GADGET_AndroidApp_EnableResourceDirectory))
  DisableGadget(#GADGET_AndroidApp_ResourceDirectory, IsDisabled)
  DisableGadget(#GADGET_AndroidApp_SelectResourceDirectory, IsDisabled)
  
  IsDebugger = GetGadgetState(#GADGET_AndroidApp_EnableDebugger)
  If IsDebugger = 0
    SetGadgetState(#GADGET_AndroidApp_AutoUpload, 0)
  EndIf
  
  DisableGadget(#GADGET_AndroidApp_AutoUpload, Bool(Not IsDebugger))
  
EndProcedure


Procedure UpdateCreateAppStartupColor(Color$)
  
  ; Recreate the image with the right background color
  Color = RGB(Val("$"+Mid(Color$, 2, 2)), Val("$"+Mid(Color$, 4, 2)), Val("$"+Mid(Color$, 6, 2)))
  CreateImage(#IMAGE_CreateApp_StartupColor, 30, 30, 24, Color)
  SetGadgetAttribute(#GADGET_AndroidApp_SelectStartupColor, #PB_Button_Image, ImageID(#IMAGE_CreateApp_StartupColor))
  SetGadgetText(#GADGET_AndroidApp_StartupColor, Color$)
  
EndProcedure


Procedure OpenCreateAppWindow(*Target.CompileTarget, IsProject)
  
  If IsWindow(#WINDOW_CreateApp) = 0
    
    ; Reuse the Options_CurrentBasePath$ from CompilerOption to have our path relative to the source or to the project file
    ;
    If *ActiveSource = *ProjectInfo Or *ActiveSource\ProjectFile
      Options_CurrentBasePath$ = GetPathPart(ProjectFile$)
    Else
      If *ActiveSource\Filename$ ; already saved
        Options_CurrentBasePath$ = GetPathPart(*ActiveSource\Filename$)
      Else
        Options_CurrentBasePath$ = "" ; use full paths then
      EndIf
    EndIf
    
    ; Default value if not set
    ;
    If *Target\AndroidAppStartupColor$ = "" 
      *Target\AndroidAppStartupColor$ = "#FFFFFF" ; white background by default
    EndIf
    
    If *Target\AndroidAppCode = 0
      *Target\AndroidAppCode = 1 ; can't be zero, so avoid a wrong value
    EndIf
      
    CreateAppWindowDialog = OpenDialog(?Dialog_CreateApp, WindowID(#WINDOW_Main), @CreateAppWindowPosition)
    If CreateAppWindowDialog
      EnsureWindowOnDesktop(#WINDOW_CreateApp)
      
      *CurrentAppTarget = *Target
      CurrentAppIsProject = IsProject
      
      SetGadgetText(#GADGET_WebApp_Name                   , *Target\WebAppName$)
      SetGadgetText(#GADGET_WebApp_Icon                   , *Target\WebAppIcon$)
      SetGadgetText(#GADGET_WebApp_HtmlFilename           , *Target\HtmlFilename$)
      SetGadgetText(#GADGET_WebApp_JavaScriptFilename     , *Target\JavaScriptFilename$)
      SetGadgetText(#GADGET_WebApp_JavaScriptPath         , *Target\JavaScriptPath$)
      SetGadgetState(#GADGET_WebApp_CopyJavaScriptLibrary , *Target\CopyJavaScriptLibrary)
      SetGadgetText(#GADGET_WebApp_ExportCommandLine      , *Target\ExportCommandLine$)
      SetGadgetText(#GADGET_WebApp_ExportArguments        , *Target\ExportArguments$)
      SetGadgetState(#GADGET_WebApp_EnableResourceDirectory, *Target\EnableResourceDirectory)
      SetGadgetText(#GADGET_WebApp_ResourceDirectory      , *Target\ResourceDirectory$)
      SetGadgetState(#GADGET_WebApp_EnableDebugger        , *Target\WebAppEnableDebugger)
      
      
      SetGadgetText(#GADGET_iOSApp_Name           , *Target\iOSAppName$)
      SetGadgetText(#GADGET_iOSApp_Icon           , *Target\iOSAppIcon$)
      SetGadgetText(#GADGET_iOSApp_Version        , *Target\iOSAppVersion$)
      SetGadgetText(#GADGET_iOSApp_PackageID      , *Target\iOSAppPackageID$)
      SetGadgetText(#GADGET_iOSApp_StartupImage   , *Target\iOSAppStartupImage$)
      SetGadgetText(#GADGET_iOSApp_Output         , *Target\iOSAppOutput$)
      SetGadgetText(#GADGET_iOSApp_ResourceDirectory, *Target\iOSAppResourceDirectory$)
      SetGadgetState(#GADGET_iOSApp_Orientation   , *Target\iOSAppOrientation)
      SetGadgetState(#GADGET_iOSApp_FullScreen    , *Target\iOSAppFullScreen)
      SetGadgetState(#GADGET_iOSApp_AutoUpload    , *Target\iOSAppAutoUpload)
      SetGadgetState(#GADGET_iOSApp_EnableResourceDirectory, *Target\iOSAppEnableResourceDirectory)
      SetGadgetState(#GADGET_iOSApp_EnableDebugger, *Target\iOSAppEnableDebugger)
      SetGadgetState(#GADGET_iOSApp_KeepAppDirectory, *Target\iOSAppKeepAppDirectory)
      
      SetGadgetText(#GADGET_AndroidApp_Name           , *Target\AndroidAppName$)
      SetGadgetText(#GADGET_AndroidApp_Icon           , *Target\AndroidAppIcon$)
      SetGadgetText(#GADGET_AndroidApp_Version        , *Target\AndroidAppVersion$)
      SetGadgetText(#GADGET_AndroidApp_Code           , Str(*Target\AndroidAppCode))
      SetGadgetText(#GADGET_AndroidApp_PackageID      , *Target\AndroidAppPackageID$)
      SetGadgetText(#GADGET_AndroidApp_IAPKey         , *Target\AndroidAppIAPKey$)
      SetGadgetText(#GADGET_AndroidApp_StartupImage   , *Target\AndroidAppStartupImage$)
      SetGadgetText(#GADGET_AndroidApp_Output         , *Target\AndroidAppOutput$)
      SetGadgetText(#GADGET_AndroidApp_ResourceDirectory, *Target\AndroidAppResourceDirectory$)
      SetGadgetState(#GADGET_AndroidApp_Orientation   , *Target\AndroidAppOrientation)
      SetGadgetState(#GADGET_AndroidApp_FullScreen    , *Target\AndroidAppFullScreen)
      SetGadgetState(#GADGET_AndroidApp_AutoUpload    , *Target\AndroidAppAutoUpload)
      SetGadgetState(#GADGET_AndroidApp_EnableResourceDirectory, *Target\AndroidAppEnableResourceDirectory)
      SetGadgetState(#GADGET_AndroidApp_EnableDebugger, *Target\AndroidAppEnableDebugger)
      SetGadgetState(#GADGET_AndroidApp_KeepAppDirectory, *Target\AndroidAppKeepAppDirectory)
      SetGadgetState(#GADGET_AndroidApp_InsecureFileMode, *Target\AndroidAppInsecureFileMode)
      UpdateCreateAppStartupColor(*Target\AndroidAppStartupColor$)
      
      UpdateCreateAppWindow()
      
      SetGadgetState(#GADGET_App_Panel, CurrentAppTab)
      
      HideWindow(#WINDOW_CreateApp, #False)
    EndIf
    
  Else
    SetWindowForeground(#WINDOW_CreateApp)
  EndIf
  
  
EndProcedure


Procedure AppWindowChanged()
  
  If *CurrentAppTarget\WebAppName$            <> GetGadgetText(#GADGET_WebApp_Name) : Changed = #True : EndIf
  If *CurrentAppTarget\WebAppIcon$            <> GetGadgetText(#GADGET_WebApp_Icon) : Changed = #True : EndIf
  If *CurrentAppTarget\HtmlFilename$          <> GetGadgetText(#GADGET_WebApp_HtmlFilename) : Changed = #True : EndIf
  If *CurrentAppTarget\JavaScriptFilename$    <> GetGadgetText(#GADGET_WebApp_JavaScriptFilename) : Changed = #True : EndIf
  If *CurrentAppTarget\JavaScriptPath$        <> GetGadgetText(#GADGET_WebApp_JavaScriptPath) : Changed = #True : EndIf
  If *CurrentAppTarget\CopyJavaScriptLibrary  <> GetGadgetState(#GADGET_WebApp_CopyJavaScriptLibrary) : Changed = #True : EndIf
  If *CurrentAppTarget\ExportCommandLine$     <> GetGadgetText(#GADGET_WebApp_ExportCommandLine) : Changed = #True : EndIf
  If *CurrentAppTarget\ExportArguments$       <> GetGadgetText(#GADGET_WebApp_ExportArguments) : Changed = #True : EndIf
  If *CurrentAppTarget\EnableResourceDirectory<> GetGadgetState(#GADGET_WebApp_EnableResourceDirectory) : Changed = #True : EndIf
  If *CurrentAppTarget\ResourceDirectory$     <> GetGadgetText(#GADGET_WebApp_ResourceDirectory) : Changed = #True : EndIf
  If *CurrentAppTarget\WebAppEnableDebugger   <> GetGadgetState(#GADGET_WebApp_EnableDebugger) : Changed = #True : EndIf
  
  If *CurrentAppTarget\iOSAppName$         <> GetGadgetText(#GADGET_iOSApp_Name) : Changed = #True : EndIf
  If *CurrentAppTarget\iOSAppIcon$         <> GetGadgetText(#GADGET_iOSApp_Icon) : Changed = #True : EndIf
  If *CurrentAppTarget\iOSAppVersion$      <> GetGadgetText(#GADGET_iOSApp_Version) : Changed = #True : EndIf
  If *CurrentAppTarget\iOSAppPackageID$    <> GetGadgetText(#GADGET_iOSApp_PackageID) : Changed = #True : EndIf
  If *CurrentAppTarget\iOSAppStartupImage$ <> GetGadgetText(#GADGET_iOSApp_StartupImage) : Changed = #True : EndIf
  If *CurrentAppTarget\iOSAppOutput$       <> GetGadgetText(#GADGET_iOSApp_Output) : Changed = #True : EndIf
  If *CurrentAppTarget\iOSAppOrientation   <> GetGadgetState(#GADGET_iOSApp_Orientation) : Changed = #True : EndIf
  If *CurrentAppTarget\iOSAppFullScreen    <> GetGadgetState(#GADGET_iOSApp_FullScreen) : Changed = #True : EndIf
  If *CurrentAppTarget\iOSAppAutoUpload    <> GetGadgetState(#GADGET_iOSApp_AutoUpload) : Changed = #True : EndIf
  If *CurrentAppTarget\iOSAppEnableResourceDirectory<> GetGadgetState(#GADGET_iOSApp_EnableResourceDirectory) : Changed = #True : EndIf
  If *CurrentAppTarget\iOSAppResourceDirectory$     <> GetGadgetText(#GADGET_iOSApp_ResourceDirectory) : Changed = #True : EndIf
  If *CurrentAppTarget\iOSAppEnableDebugger <> GetGadgetState(#GADGET_iOSApp_EnableDebugger) : Changed = #True : EndIf
  If *CurrentAppTarget\iOSAppKeepAppDirectory <> GetGadgetState(#GADGET_iOSApp_KeepAppDirectory) : Changed = #True : EndIf
  
  If *CurrentAppTarget\AndroidAppName$         <> GetGadgetText(#GADGET_AndroidApp_Name) : Changed = #True : EndIf
  If *CurrentAppTarget\AndroidAppIcon$         <> GetGadgetText(#GADGET_AndroidApp_Icon) : Changed = #True : EndIf
  If *CurrentAppTarget\AndroidAppVersion$      <> GetGadgetText(#GADGET_AndroidApp_Version) : Changed = #True : EndIf
  If *CurrentAppTarget\AndroidAppCode          <> Val(GetGadgetText(#GADGET_AndroidApp_Code)) : Changed = #True : EndIf
  If *CurrentAppTarget\AndroidAppPackageID$    <> GetGadgetText(#GADGET_AndroidApp_PackageID) : Changed = #True : EndIf
  If *CurrentAppTarget\AndroidAppIAPKey$       <> GetGadgetText(#GADGET_AndroidApp_IAPKey) : Changed = #True : EndIf
  If *CurrentAppTarget\AndroidAppStartupImage$ <> GetGadgetText(#GADGET_AndroidApp_StartupImage) : Changed = #True : EndIf
  If *CurrentAppTarget\AndroidAppStartupColor$ <> GetGadgetText(#GADGET_AndroidApp_StartupColor) : Changed = #True : EndIf
  If *CurrentAppTarget\AndroidAppOutput$       <> GetGadgetText(#GADGET_AndroidApp_Output) : Changed = #True : EndIf
  If *CurrentAppTarget\AndroidAppOrientation   <> GetGadgetState(#GADGET_AndroidApp_Orientation) : Changed = #True : EndIf
  If *CurrentAppTarget\AndroidAppFullScreen    <> GetGadgetState(#GADGET_AndroidApp_FullScreen) : Changed = #True : EndIf
  If *CurrentAppTarget\AndroidAppAutoUpload    <> GetGadgetState(#GADGET_AndroidApp_AutoUpload) : Changed = #True : EndIf
  If *CurrentAppTarget\AndroidAppEnableResourceDirectory<> GetGadgetState(#GADGET_AndroidApp_EnableResourceDirectory) : Changed = #True : EndIf
  If *CurrentAppTarget\AndroidAppResourceDirectory$     <> GetGadgetText(#GADGET_AndroidApp_ResourceDirectory) : Changed = #True : EndIf
  If *CurrentAppTarget\AndroidAppEnableDebugger<> GetGadgetState(#GADGET_AndroidApp_EnableDebugger) : Changed = #True : EndIf
  If *CurrentAppTarget\AndroidAppKeepAppDirectory<> GetGadgetState(#GADGET_AndroidApp_KeepAppDirectory) : Changed = #True : EndIf
  If *CurrentAppTarget\AndroidAppInsecureFileMode<> GetGadgetState(#GADGET_AndroidApp_InsecureFileMode) : Changed = #True : EndIf
  
  ProcedureReturn Changed
EndProcedure


Procedure RelativeFilenameRequester(Gadget, Title$, Filter$)
  File$ = ResolveRelativePath(Options_CurrentBasePath$, GetGadgetText(Gadget))
  If Trim(File$) = ""
    File$ = Options_CurrentBasePath$
  EndIf
  
  File$ = OpenFileRequester(Title$, File$, Filter$, 0)
  If File$
    SetGadgetText(Gadget, CreateRelativePath(Options_CurrentBasePath$, File$))
  EndIf
EndProcedure



Procedure RelativePathRequester(Gadget, Title$)
  File$ = ResolveRelativePath(Options_CurrentBasePath$, GetGadgetText(Gadget))
  If Trim(File$) = ""
    File$ = Options_CurrentBasePath$
  EndIf
  
  File$ = PathRequester(Title$, File$)
  If File$
    SetGadgetText(Gadget, CreateRelativePath(Options_CurrentBasePath$, File$))
  EndIf
EndProcedure


Procedure UpdateCreateAppSettings()
  
  If AppWindowChanged()
    UpdateSourceStatus(1) ; set the changed flag
  EndIf
  
  *CurrentAppTarget\WebAppName$            = GetGadgetText(#GADGET_WebApp_Name)
  *CurrentAppTarget\WebAppIcon$            = GetGadgetText(#GADGET_WebApp_Icon)
  *CurrentAppTarget\HtmlFilename$          = GetGadgetText(#GADGET_WebApp_HtmlFilename)
  *CurrentAppTarget\JavaScriptFilename$    = GetGadgetText(#GADGET_WebApp_JavaScriptFilename)
  *CurrentAppTarget\JavaScriptPath$        = GetGadgetText(#GADGET_WebApp_JavaScriptPath)
  *CurrentAppTarget\CopyJavaScriptLibrary  = GetGadgetState(#GADGET_WebApp_CopyJavaScriptLibrary)
  *CurrentAppTarget\ExportCommandLine$     = GetGadgetText(#GADGET_WebApp_ExportCommandLine)
  *CurrentAppTarget\ExportArguments$       = GetGadgetText(#GADGET_WebApp_ExportArguments)
  *CurrentAppTarget\EnableResourceDirectory= GetGadgetState(#GADGET_WebApp_EnableResourceDirectory)
  *CurrentAppTarget\ResourceDirectory$     = GetGadgetText(#GADGET_WebApp_ResourceDirectory)
  *CurrentAppTarget\WebAppEnableDebugger   = GetGadgetState(#GADGET_WebApp_EnableDebugger)
  
  *CurrentAppTarget\iOSAppName$         = GetGadgetText(#GADGET_iOSApp_Name)
  *CurrentAppTarget\iOSAppIcon$         = GetGadgetText(#GADGET_iOSApp_Icon)
  *CurrentAppTarget\iOSAppVersion$      = GetGadgetText(#GADGET_iOSApp_Version)
  *CurrentAppTarget\iOSAppPackageID$    = GetGadgetText(#GADGET_iOSApp_PackageID)
  *CurrentAppTarget\iOSAppStartupImage$ = GetGadgetText(#GADGET_iOSApp_StartupImage)
  *CurrentAppTarget\iOSAppOutput$       = GetGadgetText(#GADGET_iOSApp_Output)
  *CurrentAppTarget\iOSAppResourceDirectory$     = GetGadgetText(#GADGET_iOSApp_ResourceDirectory)
  *CurrentAppTarget\iOSAppEnableResourceDirectory= GetGadgetState(#GADGET_iOSApp_EnableResourceDirectory)
  *CurrentAppTarget\iOSAppOrientation   = GetGadgetState(#GADGET_iOSApp_Orientation)
  *CurrentAppTarget\iOSAppFullScreen    = GetGadgetState(#GADGET_iOSApp_FullScreen)
  *CurrentAppTarget\iOSAppAutoUpload    = GetGadgetState(#GADGET_iOSApp_AutoUpload)
  *CurrentAppTarget\iOSAppEnableDebugger= GetGadgetState(#GADGET_iOSApp_EnableDebugger)
  *CurrentAppTarget\iOSAppKeepAppDirectory= GetGadgetState(#GADGET_iOSApp_KeepAppDirectory)
  
  *CurrentAppTarget\AndroidAppName$         = GetGadgetText(#GADGET_AndroidApp_Name)
  *CurrentAppTarget\AndroidAppIcon$         = GetGadgetText(#GADGET_AndroidApp_Icon)
  *CurrentAppTarget\AndroidAppVersion$      = GetGadgetText(#GADGET_AndroidApp_Version)
  *CurrentAppTarget\AndroidAppCode          = Val(GetGadgetText(#GADGET_AndroidApp_Code))
  *CurrentAppTarget\AndroidAppPackageID$    = GetGadgetText(#GADGET_AndroidApp_PackageID)
  *CurrentAppTarget\AndroidAppIAPKey$       = GetGadgetText(#GADGET_AndroidApp_IAPKey)
  *CurrentAppTarget\AndroidAppStartupImage$ = GetGadgetText(#GADGET_AndroidApp_StartupImage)
  *CurrentAppTarget\AndroidAppStartupColor$ = GetGadgetText(#GADGET_AndroidApp_StartupColor)
  *CurrentAppTarget\AndroidAppOutput$       = GetGadgetText(#GADGET_AndroidApp_Output)
  *CurrentAppTarget\AndroidAppResourceDirectory$      = GetGadgetText(#GADGET_AndroidApp_ResourceDirectory)
  *CurrentAppTarget\AndroidAppEnableResourceDirectory = GetGadgetState(#GADGET_AndroidApp_EnableResourceDirectory)
  *CurrentAppTarget\AndroidAppOrientation   = GetGadgetState(#GADGET_AndroidApp_Orientation)
  *CurrentAppTarget\AndroidAppFullScreen    = GetGadgetState(#GADGET_AndroidApp_FullScreen)
  *CurrentAppTarget\AndroidAppAutoUpload    = GetGadgetState(#GADGET_AndroidApp_AutoUpload)
  *CurrentAppTarget\AndroidAppEnableDebugger= GetGadgetState(#GADGET_AndroidApp_EnableDebugger)
  *CurrentAppTarget\AndroidAppKeepAppDirectory= GetGadgetState(#GADGET_AndroidApp_KeepAppDirectory)
  *CurrentAppTarget\AndroidAppInsecureFileMode= GetGadgetState(#GADGET_AndroidApp_InsecureFileMode)
  
EndProcedure


Procedure CloseCreateAppWindow()
  
  If CreateAppWindowDialog
    CurrentAppTab = GetGadgetState(#GADGET_App_Panel)
    
    If MemorizeWindow
      CreateAppWindowDialog\Close(@CreateAppWindowPosition)
    Else
      CreateAppWindowDialog\Close()
    EndIf
  EndIf
  
EndProcedure

; Our own package id validator to avoid criptic message from the app creation tool
;
Procedure CheckAndroidPackageID(ID$)
  If ID$
    NbDots = CountString(ID$, ".")
    If NbDots >= 2 ; At least 2 dots needed, as it's in the form com.spiderbasic.yourapp (NOTE: it can also be: com.spiderbasic.yourapp.suboption.suboption2)
      For k = 1 To NbDots+1
        Field$ = StringField(ID$, k, ".")
        
        If Asc(Field$) < 'a' Or Asc(Field$) > 'z' ; a field has to start with a lowercase ASCII char
          ProcedureReturn 0                       ; Fail
        EndIf
        
        ; now check it's only ascii chars for the whole field
        ;
        For i = 1 To Len(Field$)
          Char$ = LCase(Mid(Field$, i, 1))
          If (Char$ < "a" Or Char$ > "z") And (Char$ < "0" Or Char$ > "9")  And Char$ <> "_" ; a field can only contains ascii chars and numbers
            ProcedureReturn 0
          EndIf
        Next
      Next
      
      ProcedureReturn 1 ; Success
    EndIf
  EndIf
  
  ProcedureReturn 0
EndProcedure


Procedure LaunchAppBuild(OutputFilename$)
  
  If CurrentAppIsProject
    ProcedureReturn CreateExecutableProject()
  Else
    ProcedureReturn StartInternalBuild(*CurrentAppTarget\FileName$, OutputFilename$)
  EndIf
  
EndProcedure



Procedure CreateAppWindowEvents(EventID)
  
  If EventID = #PB_Event_Menu     ; Little wrapper to map the shortcut events (identified as menu)
    EventID  = #PB_Event_Gadget   ; to normal gadget events...
    GadgetID = EventMenu()
  Else
    GadgetID = EventGadget()
  EndIf
  
  Select EventID
      
    Case #PB_Event_CloseWindow
      CloseCreateAppWindow()
      
    Case #PB_Event_Gadget
      
      Select GadgetID
          
          ; Web
          ;
        Case #GADGET_WebApp_SelectIcon
          RelativeFilenameRequester(#GADGET_WebApp_Icon, Language("App", "SelectIcon"), "PNG images|*.png")
          
        Case #GADGET_WebApp_SelectHtmlFilename
          RelativeFilenameRequester(#GADGET_WebApp_HtmlFilename, Language("WebApp", "SelectHtmlFile"), "HTML files|*.html")
          
        Case #GADGET_WebApp_SelectResourceDirectory
          RelativePathRequester(#GADGET_WebApp_ResourceDirectory, Language("App", "SelectResourceDirectory"))
          
          ; iOS
          ;
        Case #GADGET_iOSApp_SelectIcon
          RelativeFilenameRequester(#GADGET_iOSApp_Icon, Language("App","SelectIcon"), "PNG images|*.png")
          
        Case #GADGET_iOSApp_SelectStartupImage
          RelativeFilenameRequester(#GADGET_iOSApp_StartupImage, Language("App", "SelectStartupImage"), "PNG images|*.png")
          
        Case #GADGET_iOSApp_SelectOutput
          RelativeFilenameRequester(#GADGET_iOSApp_Output, Language("iOS", "SelectOutput"), "IPA files|*.ipa")
          
        Case #GADGET_iOSApp_SelectResourceDirectory
          RelativePathRequester(#GADGET_iOSApp_ResourceDirectory, Language("App", "SelectResourceDirectory"))
          
          ; Android
          ;
        Case #GADGET_AndroidApp_SelectIcon
          RelativeFilenameRequester(#GADGET_AndroidApp_Icon, Language("App","SelectIcon"), "PNG images|*.png")
          
        Case #GADGET_AndroidApp_SelectStartupImage
          RelativeFilenameRequester(#GADGET_AndroidApp_StartupImage, Language("App", "SelectStartupImage"), "PNG images|*.png")
          
        Case #GADGET_AndroidApp_SelectStartupColor
          Color = ColorRequester(0, WindowID(#WINDOW_CreateApp))
          If Color <> -1
            UpdateCreateAppStartupColor("#"+RSet(Hex(Red(Color))  , 2, "0") +
                                            RSet(Hex(Green(Color)), 2, "0") +
                                            RSet(Hex(Blue(Color)), 2, "0"))
          EndIf

        Case #GADGET_AndroidApp_SelectOutput
          RelativeFilenameRequester(#GADGET_AndroidApp_Output, Language("Android", "SelectOutput"), "APK files|*.apk")
          
        Case #GADGET_AndroidApp_SelectResourceDirectory
          RelativePathRequester(#GADGET_AndroidApp_ResourceDirectory, Language("App", "SelectResourceDirectory"))
          
        Case #GADGET_WebApp_EnableResourceDirectory,
             #GADGET_AndroidApp_EnableResourceDirectory,
             #GADGET_iOSApp_EnableResourceDirectory,
             #GADGET_AndroidApp_EnableDebugger
          UpdateCreateAppWindow()
          
       Case #GADGET_AndroidApp_CheckInstall
          If MessageRequester(#ProductName$, Language("AndroidApp","DoCheckInstall"), #FLAG_Info | #PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
            RunProgram("open", "-a Terminal.app " + #DQUOTE$ + PureBasicPath$ + "install-cordova.sh" + #DQUOTE$, "", #PB_Program_Wait)
          EndIf
          
        Case #GADGET_iOSApp_CheckInstall
          If MessageRequester(#ProductName$, Language("iOSApp","DoCheckInstall"), #FLAG_Info | #PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
            RunProgram("open", "-a Terminal.app " + #DQUOTE$ + PureBasicPath$ + "install-cordova.sh" + #DQUOTE$, "", #PB_Program_Wait)
          EndIf
          
        Case #GADGET_App_OK
          UpdateCreateAppSettings()
          CloseCreateAppWindow()
          
        Case #GADGET_App_Create
          
          UpdateCreateAppSettings()
          
          Select GetGadgetState(#GADGET_App_Panel)
            Case 0 ; Web App
              
              *CurrentAppTarget\AppFormat = #AppFormatWeb
              
              If *CurrentAppTarget\HtmlFileName$
                
                CloseCreateAppWindow()
                
                If LaunchAppBuild(*CurrentAppTarget\HtmlFilename$)
                  ; *ActiveSource = *InitialActiveSource ; Restore the active source only if the compilation has succeeded
                  
                  Debugger_AddLog_BySource(*ActiveSource, LanguagePattern("Compiler", "ExportSuccess", "%target%", *CurrentAppTarget\HtmlFileName$), Date())
                  
                  If *CurrentAppTarget\ExportCommandLine$
                    If RunProgram(*CurrentAppTarget\ExportCommandLine$, *CurrentAppTarget\ExportArguments$, GetPathPart(*CurrentAppTarget\FileName$))
                      Debugger_AddLog_BySource(*ActiveSource, LanguagePattern("Compiler", "ExportCommandLineSuccess", "%commandline%", *CurrentAppTarget\ExportCommandLine$), Date())
                    Else
                      MessageRequester(#ProductName$, LanguagePattern("Compiler", "ExportCommandLineError", "%commandline%", *CurrentAppTarget\ExportCommandLine$), #FLAG_ERROR)
                    EndIf
                  EndIf
                EndIf
                
              Else
                MessageRequester(#ProductName$, Language("Compiler","ExportHtmlMissingError"), #FLAG_ERROR)
              EndIf
              
            Case 1 ; iOS
              
              CompilerIf #CompileMac
                *CurrentAppTarget\AppFormat = #AppFormatiOS
                
                If *CurrentAppTarget\iOSAppOutput$ = ""
                  MessageRequester(#ProductName$, Language("App","NoAppOutput"), #FLAG_ERROR)
                  
                ElseIf UCase(GetExtensionPart(*CurrentAppTarget\iOSAppOutput$)) <> "IPA"
                  MessageRequester(#ProductName$, Language("iOSApp","WrongOutputExtension"), #FLAG_ERROR)
                  
                ElseIf OptionAppleTeamID$ = ""
                  MessageRequester(#ProductName$, Language("iOSApp","NoAppleTeamID"), #FLAG_ERROR)
                  
                ElseIf FileSize("/usr/local/bin/cordova") = -1
                  
                  If MessageRequester(#ProductName$, Language("iOSApp","NoCordova"), #FLAG_Error | #PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
                    RunProgram("open", "-a Terminal.app " + #DQUOTE$ + PureBasicPath$ + "install-cordova.sh" + #DQUOTE$, "", #PB_Program_Wait)
                  EndIf
                  
                Else
                  CloseCreateAppWindow()
                  
                  If LaunchAppBuild(*CurrentAppTarget\iOSAppOutput$)
                    ;*ActiveSource = *InitialActiveSource ; Restore the active source only if the compilation has succeeded
                    
                    Debugger_AddLog_BySource(*ActiveSource, LanguagePattern("Compiler", "ExportSuccess", "%target%", *CurrentAppTarget\iOSAppOutput$), Date())
                  EndIf
                EndIf
                
              CompilerElse
                MessageRequester(#ProductName$, Language("App","iOSMacOnly"), #FLAG_ERROR)
                
              CompilerEndIf
              
            Case 2 ; Android
              
              *CurrentAppTarget\AppFormat = #AppFormatAndroid
              
              If *CurrentAppTarget\AndroidAppOutput$ = ""
                MessageRequester(#ProductName$, Language("App","NoAppOutput"), #FLAG_ERROR)
                
              ElseIf UCase(GetExtensionPart(*CurrentAppTarget\AndroidAppOutput$)) <> "APK"
                MessageRequester(#ProductName$, Language("AndroidApp","WrongOutputExtension"), #FLAG_ERROR)

              ; The JAVA check is a Windows only issue as it works with OpenJDK on Ubuntu
              ;
              CompilerIf #CompileWindows                
                ElseIf OptionJDK$ = ""
                  MessageRequester(#ProductName$, Language("AndroidApp","NoJDK"), #FLAG_ERROR)

                ElseIf FileSize(OptionJDK$ + "\include") <> -2 ; Check the include dir is here, so it's not a JRE
                  MessageRequester(#ProductName$, Language("AndroidApp","InvalidJDK"), #FLAG_ERROR)
              CompilerEndIf
                
              ElseIf CheckAndroidPackageID(*CurrentAppTarget\AndroidAppPackageID$) = 0
                MessageRequester(#ProductName$, Language("AndroidApp","InvalidPackageID"), #FLAG_ERROR)
                SetActiveGadget(#GADGET_AndroidApp_PackageID)
                
              Else
                CloseCreateAppWindow()
                
                If LaunchAppBuild(*CurrentAppTarget\AndroidAppOutput$)
                  ;*ActiveSource = *InitialActiveSource ; Restore the active source only if the compilation has succeeded
                  
                  Debugger_AddLog_BySource(*ActiveSource, LanguagePattern("Compiler", "ExportSuccess", "%target%", *CurrentAppTarget\AndroidAppOutput$), Date())
                  
                  ; An AAB is also automatically generated in release mode
                  If *CurrentAppTarget\AndroidAppEnableDebugger = #False
                    Debugger_AddLog_BySource(*ActiveSource, LanguagePattern("Compiler", "ExportSuccess", "%target%", ReplaceString(*CurrentAppTarget\AndroidAppOutput$, ".apk", ".aab")), Date())
                  EndIf
                EndIf
              EndIf
          EndSelect
          
          
        Case #GADGET_App_Cancel
          CloseCreateAppWindow()
          
      EndSelect
      
  EndSelect
  
EndProcedure
