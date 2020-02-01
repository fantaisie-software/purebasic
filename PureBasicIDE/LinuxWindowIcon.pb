;--------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
;--------------------------------------------------------------------------------------------


;
; All this is much easier with 4.40 where a PB image is actually a GdkPixbuf with
; full alpha information, so we can just use the gtk function directly.
;

CompilerIf #CompileLinux
  
  UsePNGImageDecoder()
  
  
  If CatchImage(#IMAGE_LinuxWindowIcon, ?Image_LinuxWindowIcon)
    ; This applies the icon to all new windows, so no need to patch the OpenWindow() even
    gtk_window_set_default_icon_(ImageID(#IMAGE_LinuxWindowIcon))
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


; ;
; ; Applies a default icon used for all windows opened by the App.
; ; Something like this should be implemented natively so an icon can be added
; ; to an app like on windows with the next update (4.1)
; ; For now it is just for the IDE
; ;
; ; Note that Gtk actually provides a function to set a default window icon,
; ; but i do not want to go through the hassle of dealing with the GdkPixbuf lib right now.
; ;
; ; Note: We make use of the image decoder directly, as we want the full
; ; alpha information, not just the transparent/nontransparent that the image lib provides
; ; We know that it is 48x48 with alpha, so we can skip most of the checks
; ; I know this is not the cleanest, but it works for now.
; ;
;
; CompilerIf #CompileLinuxGtk2
;
; CompilerIf #CompileX64
;   CompilerError "to check for x64"
; CompilerEndIf
;
; Structure _GdkScreen Extends GdkScreen ; PB def seems to be incomplete
;   *font_options;
;   resolution.d;		/* pixels/points scale factor for fonts */
; EndStructure
;
;
; Structure GdkScreenX11
;   parent_instance._GdkScreen;
;
;   *display;
;   *xdisplay;
;   *xscreen;
;
;   ; incomplete def!
; EndStructure
;
; Structure GdkDrawableImplX11
;   parent_instance.GdkDrawable
;   *wrapper;
;   *colormap;
;
;   xid.l
;   *screen
;
;   picture.l ;Picture
;   *cairo_surface;
; EndStructure
;
; Structure _GdkWindowObject ; PB def is empty!
;   parent_instance.GdkDrawable;
;   *impl.GdkDrawable ; /* window-system-specific delegate object */
;   *parent;
;   user_data.l
;   ; incomplete def!
; EndStructure
;
; ;#define GDK_WINDOW_XDISPLAY(win)      (GDK_SCREEN_X11 (GDK_WINDOW_SCREEN (win))->xdisplay)
; ;#define GDK_WINDOW_XID(win)           (GDK_DRAWABLE_IMPL_X11(((GdkWindowObject *)win)->impl)->xid)
; ;#define GDK_WINDOW_SCREEN(win)	      (GDK_DRAWABLE_IMPL_X11 (((GdkWindowObject *)win)->impl)->screen)
; ;#define GDK_SCREEN_X11(object)           (G_TYPE_CHECK_INSTANCE_CAST ((object), GDK_TYPE_SCREEN_X11, GdkScreenX11))
; ;#define GDK_DRAWABLE_IMPL_X11(object)           (G_TYPE_CHECK_INSTANCE_CAST ((object), GDK_TYPE_DRAWABLE_IMPL_X11, GdkDrawableImplX11))
;
; #PropModeReplace = 0
;
; ; Simply import an already linked file to get access to the XLib functions (which is linked as well)
; ;
; ImportC #PB_Compiler_Home+"compilers/stringutility.a"
;   XInternAtom(display, name.p-ascii, only_if_exists)
;   XChangeProperty(display, window, property, type, size, mode, buffer, count)
;
;   ; get access to ImageDecoder functions too
;   PB_ImageDecoder_Check(a, b)
;   PB_ImageDecoder_GetWidth()
;   PB_ImageDecoder_GetHeight()
;   PB_ImageDecoder_Decode(a, b, c)
; EndImport
;
; Global *LinuxWindowIcon
;
; Procedure LoadLinuxWindowIcon()
;   Protected *Pointer.LONG
;
;   If PB_ImageDecoder_Check(99999999, ?Image_LinuxWindowIcon)
;     If PB_ImageDecoder_GetWidth() = 48 And PB_ImageDecoder_GetHeight() = 48
;       *LinuxWindowIcon = AllocateMemory(4 * 48 * 48 + 8) ; not freed during program run
;       If *LinuxWindowIcon
;         PokeL(*LinuxWindowIcon, 48)
;         PokeL(*LinuxWindowIcon+4, 48)
;         PB_ImageDecoder_Decode(*LinuxWindowIcon+8, 4*48, 0)
;
;         ; need to change image from BGRA to RGBA
;         *Pointer = *LinuxWindowIcon+8
;         While *Pointer < *LinuxWindowIcon + 8 + 48*48*4
;           *Pointer\l = (*Pointer\l & $FF00FF00) | (*Pointer\l & $FF0000) >> 16 | (*Pointer\l & $FF) << 16
;           *Pointer + 4
;         Wend
;       EndIf
;     EndIf
;   EndIf
; EndProcedure
;
; Procedure OpenWindow_Linux(Window, x, y, Width, Height, Title$, Flags = 0, Parent = 0)
;   result = OpenWindow(Window, x, y, Width, Height, Title$, Flags, ParentWindow)
;
;   If result And (Flags & #PB_Window_SystemMenu Or Flags & #PB_Window_TitleBar)
;     If Window = #PB_Any
;       *Window.GtkWidget  = WindowID(result)
;     Else
;       *Window.GtkWidget  = WindowID(Window)
;     EndIf
;
;     *gdkwindowobj._GdkWindowObject = *Window\window
;     *impl.GdkDrawableImplX11 = *gdkwindowobj\impl
;     *screen.GdkScreenX11 = *impl\screen
;     xwindow  = *impl\xid
;     xdisplay = *screen\xdisplay
;
;     _NET_WM_ICON = XInternAtom(xdisplay, "_NET_WM_ICON", #False)
;     CARDINAL     = XInternAtom(xdisplay, "CARDINAL", #False)
;     XChangeProperty(xdisplay, xwindow, _NET_WM_ICON, CARDINAL, 32, #PropModeReplace, *LinuxWindowIcon, 48*48+2)
;   EndIf
;
;   ProcedureReturn result
; EndProcedure
;
; UsePNGImageDecoder()
; LoadLinuxWindowIcon()
;
; ; replace the PB function with our own
; Macro OpenWindow
;   OpenWindow_Linux
; EndMacro
;
; DataSection
;   Image_LinuxWindowIcon:
;     IncludeBinary "../PureBasicIDE/data/logo/PBLogoLinux.png"
; EndDataSection
;
; CompilerEndIf