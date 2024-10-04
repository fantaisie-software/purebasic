; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


;
; All this is much easier with 4.40 where a PB image is actually a GdkPixbuf with
; full alpha information, so we can just use the gtk function directly.
;

CompilerIf #CompileLinux
  
  CompilerIf #CompileLinuxQt
    ImportC "Build/QtHelpers.a"
      QT_SetDefaultWindowIcon(*Image)
    EndImport
  CompilerEndIf
  
  UsePNGImageDecoder()

  If CatchImage(#IMAGE_LinuxWindowIcon, ?Image_LinuxWindowIcon)
    ; This applies the icon to all new windows, so no need to patch the OpenWindow() even
    
    CompilerIf #CompileLinuxGtk
      gtk_window_set_default_icon_(ImageID(#IMAGE_LinuxWindowIcon))
    CompilerElse
      QT_SetDefaultWindowIcon(ImageID(#IMAGE_LinuxWindowIcon))
    CompilerEndIf
  EndIf
  
  
  DataSection
    Image_LinuxWindowIcon:
    CompilerIf #SpiderBasic
      IncludeBinary "../PureBasicIDE/data/SpiderBasic/Logo_48x48.png"
    CompilerElse
      IncludeBinary "../PureBasicIDE/data/logo/PBLogoLinux.png"
    CompilerEndIf
  EndDataSection
  
CompilerEndIf

