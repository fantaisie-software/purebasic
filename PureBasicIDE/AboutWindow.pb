;--------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
;--------------------------------------------------------------------------------------------

Procedure OpenAboutWindow()
  
  If IsWindow(#WINDOW_About) = 0
    
    AboutWindowDialog = OpenDialog(?Dialog_About, WindowID(#WINDOW_Main), @AboutWindowPosition)
    If AboutWindowDialog
      EnsureWindowOnDesktop(#WINDOW_About)
      
      ; Image
      If IsImage(#IMAGE_PureBasiclogo) = 0
        CatchPackedImage(#IMAGE_PureBasiclogo, ?General_Images, 1)
        ResizeImage(#IMAGE_PureBasiclogo, DesktopScaledX(ImageWidth(#IMAGE_PureBasiclogo)), DesktopScaledY(ImageHeight(#IMAGE_PureBasiclogo)))
      EndIf
      SetGadgetState(#GADGET_About_Image, ImageID(#IMAGE_PureBasiclogo))
      
      CompilerIf #SpiderBasic
        ProductQuote$ = "..- a Basic to master the Web -.."
        
      CompilerElse
        FormerDevelopers$ =  "Former Team Members :" + #NewLine +
                             "Richard Andersson"     + #NewLine +
                             "Benny 'Berikco' Sels"  + #NewLine +
                             "Danilo Krahn"          + #NewLine + #NewLine
        
        ProductQuote$ = "Feel the ..Pure.. Power"
      CompilerEndIf
      
      ; Text
      Text$ = DefaultCompiler\VersionString$ + #NewLine +
              ProductQuote$ + #NewLine +
              #NewLine +
              "Team Members :" + #NewLine +
              "Frederic 'AlphaSND' Laboureur" + #NewLine +
              "Andre Beer" + #NewLine +
              "Timo 'fr34k' Harter" + #NewLine +
              #NewLine +
              FormerDevelopers$ +
              #ProductName$ + ", all the provided tools and components" + #NewLine +
              "are copyright © 1998-2020 Fantaisie Software" + #NewLine +
              #NewLine +
              #ProductWebSite$ + #NewLine +
              #NewLine +
              "Special thanks to all " + #ProductName$ + " users and beta-testers !" + #NewLine +
              #NewLine +
              "Thanks to Gary Willoughby (Kale) for designing the original" + #NewLine +
              "Toolbar icons for this IDE." + #NewLine +
              #NewLine +
              "Thanks to Mark James for the 'silk icon set'." + #NewLine +
              "http://www.famfamfam.com/lab/icons/silk/" + #NewLine +
              #NewLine +
              "Thanks to Neil Hodgson for the scintilla" + #NewLine +
              "editing component." + #NewLine +
              #NewLine +
              "Scintilla © 1998-2020 Neil Hodgson <neilh@scintilla.org> " + #NewLine +
              #NewLine +
              "Thanks to Wimer Hazenberg for Monokai color palette." + #NewLine +
              "http://www.monokai.nl/"
      
      ; For better debugging
      ;
      Text$ + #NewLine + #NewLine
      Text$ + "IDE build on " + FormatDate("%mm/%dd/%yyyy [%hh:%ii]", #PB_Compiler_Date) + " by " + #BUILDINFO_User + #NewLine
      Text$ + "Branch: " + #BUILDINFO_Branch + "  Revision: " + #BUILDINFO_Revision + #NewLine
      
      CompilerIf #CompileWindows
        ; Let's have a cool centered text box on Windows
        ; must be before the SetGadgetText!
        ;
        Format.PARAFORMAT\cbSize = SizeOf(PARAFORMAT)
        Format\dwMask     = #PFM_ALIGNMENT
        Format\wAlignment = #PFA_CENTER
        SendMessage_(GadgetID(#GADGET_About_Editor), #EM_SETPARAFORMAT, 0, Format)
      CompilerEndIf
      
      CompilerIf #CompileMacCocoa
        PB_Gadget_CenterEditorGadget(GadgetID(#GADGET_About_Editor))
      CompilerEndIf
      
      SetGadgetText(#GADGET_About_Editor, Text$)
      
      CompilerIf #CompileLinuxGtk2
        ; center for gtk2
        gtk_text_view_set_justification_(GadgetID(#GADGET_About_Editor), #GTK_JUSTIFY_CENTER)
        gtk_text_view_set_wrap_mode_(GadgetID(#GADGET_About_Editor), #GTK_WRAP_WORD) ; set autowrap, as the version line is a bit long
      CompilerEndIf
      
      CompilerIf #CompileMacCocoa
        PB_Gadget_CenterEditorGadget(GadgetID(#GADGET_About_Editor))
      CompilerEndIf
      
      AboutWindowDialog\GuiUpdate() ; needed because of the image change since creation
      HideWindow(#WINDOW_About, #False)
      
      ; fix required for the centereing of non-resizable windows in the dialog manager
      ; (works only if window is visible)
      CompilerIf #CompileLinuxGtk2
        If AboutWindowPosition\x = -1 And AboutWindowPosition\y = -1
          While WindowEvent(): Wend
          gtk_window_set_position_(WindowID(#WINDOW_About), #GTK_WIN_POS_CENTER)
        EndIf
      CompilerEndIf
    EndIf
    
  Else
    SetWindowforeground(#WINDOW_About)
  EndIf
  
EndProcedure


Procedure AboutWindowEvents(EventID)
  
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
      If GadgetID = #GADGET_About_Ok
        Quit = 1
      EndIf
      
  EndSelect
  
  If Quit
    If MemorizeWindow
      AboutWindowDialog\Close(@AboutWindowPosition)
    Else
      AboutWindowDialog\Close()
    EndIf
  EndIf
  
EndProcedure
