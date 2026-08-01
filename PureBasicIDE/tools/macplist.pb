; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


;
;
;  For execution by the IDE makefile
;
;  Creates the 'Info.plist' for The PureBasic bundle.
;  This is done manually as we can better customize the whole think than the compiler does.
;  (the icon option from the compiler is Not needed when using this)
;
;  Customisations are:
;   - associate .pb and .pbi with the IDE and set a custom icon
;   - set a different CDBundleSignature than the compiler to differentiate from PB created apps (this is for the file association as well)
;
;  Commandline Argument
;   - the target bundle path (ie "/Applications/purebasic/PureBasic.app/")
;
; This must be executed in the IDE source dir

#q = Chr(34)

Path$ = ProgramParameter()

If Right(Path$, 1) <> "/"
  Path$ + "/"
EndIf

OpenConsole()

FileSize = FileSize(Path$+"Contents/MacOS/PureBasic");

If FileSize <=0 ; Try with SpiderBasic as well
  FileSize = FileSize(Path$+"Contents/MacOS/SpiderBasic")
  IsSpiderBasic = 1
EndIf

If FileSize <= 0
  PrintN("Wrong commandline argument! Pass the IDE path (including the .app) as argument")
  End 1
EndIf

DeleteFile(Path$+"Contents/Resources/PB3D_MacIcon.icns")
DeleteFile(Path$+"Contents/Resources/FileIcon.icns")
DeleteFile(Path$+"Contents/Resources/Logo.icns")

If IsSpiderBasic
  
  If CopyFile("data/SpiderBasic/Logo.icns", Path$+"Contents/Resources/Logo.icns") = 0
    PrintN("Cannot copy 'data/SpiderBasic/Logo.icns' !")
    End 1
  EndIf
  
  ; We uses the same file for now
  If CopyFile("data/SpiderBasic/Logo.icns", Path$+"Contents/Resources/FileIcon.icns") = 0
    PrintN("Cannot copy 'data/SpiderBasic/FileIcon.icns' !")
    End 1
  EndIf
  
Else
  
  If CopyFile("data/logo/PB3D_MacIcon.icns", Path$+"Contents/Resources/PB3D_MacIcon.icns") = 0
    PrintN("Cannot copy 'data/logo/PB3D_MacIcon.icns'!")
    End 1
  EndIf
  
  If CopyFile("data/logo/mac/FileIcon.icns", Path$+"Contents/Resources/FileIcon.icns") = 0
    PrintN("Cannot copy 'data/logo/mac/FileIcon.icns'!")
    End 1
  EndIf
  
EndIf

; Try to get the PB Version
If IsSpiderBasic
  VersionString$ = "SpiderBasic for OSX" ; fallback
  
  Exe$ = GetEnvironmentVariable("SPIDERBASIC_HOME")
  If Right(Exe$, 1) = "/"
    Exe$ + "compilers/sbcompiler"
  Else
    Exe$ + "/compilers/sbcompiler"
  EndIf
Else
  VersionString$ = "PureBasic for OSX" ; fallback
  
  Exe$ = GetEnvironmentVariable("PUREBASIC_HOME")
  If Right(Exe$, 1) = "/"
    Exe$ + "compilers/pbcompiler"
  Else
    Exe$ + "/compilers/pbcompiler"
  EndIf
EndIf

If FileSize(Exe$) > 0
  Compiler = RunProgram(Exe$, " --standby", "", #PB_Program_Open|#PB_Program_Read|#PB_Program_Write)
  If Compiler
    Line$ = ReadProgramString(Compiler)
    Debug Line$
    
    If StringField(Line$, 1, Chr(9)) = "STARTING"
      VersionString$ = StringField(Line$, 3, Chr(9))
    EndIf
    
    WriteProgramStringN(Compiler, "END")
    While ProgramRunning(Compiler)
      ReadProgramString(Compiler)
    Wend
    CloseProgram(Compiler)
  EndIf
EndIf


; We could use our cool XML lib here, but it is too much work,
; as the structure we create is quite static anyway :)
;
If CreateFile(0, Path$+"Contents/Info.plist") = 0
  PrintN("Cannot create '"+Path$+"Contents/Info.plist"+"'!")
  End 1
EndIf

; The usual header stuff
WriteStringN(0, "<?xml version="+#q+"1.0"+#q+" encoding="+#q+"UTF-8"+#q+"?>")
WriteStringN(0, "<!DOCTYPE plist PUBLIC "+#q+"-//Apple Computer//DTD PLIST 1.0//EN"+#q+" "+#q+"http://www.apple.com/DTDs/PropertyList-1.0.dtd"+#q+">")
WriteStringN(0, "<plist version="+#q+"1.0"+#q+">")
WriteStringN(0, "<dict>")

; This sets the file association and icon
;
WriteStringN(0, "  <key>CFBundleDocumentTypes</key>")
WriteStringN(0, "  <array>")
WriteStringN(0, "    <dict>")
If IsSpiderBasic
  WriteStringN(0, "      <key>CFBundleTypeExtensions</key>")
  WriteStringN(0, "      <array>")
  WriteStringN(0, "        <string>sb</string>")
  WriteStringN(0, "        <string>sbi</string>")
  WriteStringN(0, "        <string>sbp</string>")
  WriteStringN(0, "      </array>")
  WriteStringN(0, "      <key>CFBundleTypeName</key>")
  WriteStringN(0, "      <string>SpiderBasic Sourcecode</string>")
Else
  WriteStringN(0, "      <key>CFBundleTypeExtensions</key>")
  WriteStringN(0, "      <array>")
  WriteStringN(0, "        <string>pb</string>")
  WriteStringN(0, "        <string>pbi</string>")
  WriteStringN(0, "        <string>pbp</string>")
  WriteStringN(0, "      </array>")
  WriteStringN(0, "      <key>CFBundleTypeName</key>")
  WriteStringN(0, "      <string>PureBasic Sourcecode</string>")
EndIf
WriteStringN(0, "      <key>CFBundleTypeIconFile</key>")
WriteStringN(0, "      <string>FileIcon.icns</string>")
WriteStringN(0, "      <key>CFBundleTypeRole</key>")
WriteStringN(0, "      <string>Editor</string>")
WriteStringN(0, "    </dict>")
WriteStringN(0, "  </array>")

; Put a version string for the 'File Info' dialog
WriteStringN(0, "  <key>CFBundleGetInfoString</key>")
WriteStringN(0, "  <string>"+VersionString$+"</string>")

; This must be different from 'PURE', as it is used to associate filetypes as well, and we
; get confusion with PB created executables if we use 'PURE' here
If IsSpiderBasic
  WriteStringN(0, "  <key>CFBundleSignature</key>")
  WriteStringN(0, "  <string>SBED</string>")
  
  ; This is used to "identify the application at runtime". could help to implement a "runonce" for OSX
  WriteStringN(0, "  <key>CFBundleIdentifier</key>")
  WriteStringN(0, "  <string>com.fantaisiesoftware.spiderbasicide</string>")
  
  WriteStringN(0, "  <key>CFBundleExecutable</key>")
  WriteStringN(0, "  <string>SpiderBasic</string>")
  
  WriteStringN(0, "  <key>CFBundleIconFile</key>")
  WriteStringN(0, "  <string>Logo.icns</string>")
Else
  WriteStringN(0, "  <key>CFBundleSignature</key>")
  WriteStringN(0, "  <string>PBED</string>")
  
  ; This is used to "identify the application at runtime". could help to implement a "runonce" for OSX
  WriteStringN(0, "  <key>CFBundleIdentifier</key>")
  WriteStringN(0, "  <string>com.fantaisiesoftware.purebasicide</string>")
  
  WriteStringN(0, "  <key>CFBundleExecutable</key>")
  WriteStringN(0, "  <string>PureBasic</string>")
  
  WriteStringN(0, "  <key>CFBundleIconFile</key>")
  WriteStringN(0, "  <string>PB3D_MacIcon.icns</string>")
EndIf

; Stuff that is equal to the Compiler created plist
;
WriteStringN(0, "  <key>CFBundleLocalizations</key>")
WriteStringN(0, "  <array>")
WriteStringN(0, "    <string>en</string>")
WriteStringN(0, "    <string>zh-Hans</string>")
WriteStringN(0, "    <string>zh-Hant</string>")
WriteStringN(0, "    <string>hi</string>")
WriteStringN(0, "    <string>es</string>")
WriteStringN(0, "    <string>fr</string>")
WriteStringN(0, "    <string>ar</string>")
WriteStringN(0, "    <string>bn</string>")
WriteStringN(0, "    <string>pt</string>")
WriteStringN(0, "    <string>ru</string>")
WriteStringN(0, "    <string>ja</string>")
WriteStringN(0, "    <string>pa</string>")
WriteStringN(0, "    <string>de</string>")
WriteStringN(0, "    <string>jv</string>")
WriteStringN(0, "    <string>ko</string>")
WriteStringN(0, "    <string>te</string>")
WriteStringN(0, "    <string>vi</string>")
WriteStringN(0, "    <string>mr</string>")
WriteStringN(0, "    <string>ta</string>")
WriteStringN(0, "    <string>tr</string>")
WriteStringN(0, "    <string>it</string>")
WriteStringN(0, "    <string>ur</string>")
WriteStringN(0, "    <string>th</string>")
WriteStringN(0, "    <string>gu</string>")
WriteStringN(0, "    <string>pl</string>")
WriteStringN(0, "    <string>uk</string>")
WriteStringN(0, "    <string>ml</string>")
WriteStringN(0, "    <string>kn</string>")
WriteStringN(0, "    <string>or</string>")
WriteStringN(0, "    <string>nl</string>")
WriteStringN(0, "  </array>")
WriteStringN(0, "  <key>CFBundleDevelopmentRegion</key>")
WriteStringN(0, "  <string>en</string>")
WriteStringN(0, "  <key>CFBundleInfoDictionaryVersion</key>")
WriteStringN(0, "  <string>6.0</string>")
WriteStringN(0, "  <key>CFBundlePackageType</key>")
WriteStringN(0, "  <string>APPL</string>")
WriteStringN(0, "  <key>CFBundleVersion</key>")
WriteStringN(0, "  <string>0.1</string>")
WriteStringN(0, "  <key>CSResourcesFileMapped</key>")
WriteStringN(0, "  <true/>")
WriteStringN(0, "  <key>NSHighResolutionCapable</key>")
WriteStringN(0, "  <true/>")
WriteStringN(0, "</dict>")
WriteStringN(0, "</plist>")



CloseFile(0)
End 0 ; success
