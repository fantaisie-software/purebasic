;
; ------------------------------------------------------------
;
;   PureBasic - Raw DirectX 7 example using Interfaces
;
;   Based on 'z00m' by Danilo, March 2002
;
;   (c) Fantaisie Software
;
; ------------------------------------------------------------
;


#ScreenResX = 640
#ScreenResY = 480
#ScreenBits = 32

; Structures and Constants
;
IncludeFile "MiniDirectDraw.pb"

SurfaceDescriptor.DDSURFACEDESC2

If OpenLibrary(0,"ddraw.dll")
  If CallFunction(0,"DirectDrawCreateEx",0,@DirectDraw.IDirectDraw7,?IID_IDirectDraw7,0) <> #DD_OK
    MessageRequester("Warning:","Couldn't init DirectDraw",0)
    End
  EndIf
Else
  MessageRequester("Warning:","Couldn't init DirectDraw",0)
  End
EndIf

MessageRequester("PureBasic - DirectX", "Enjoy the full object oriented DirectX example"+Chr(10)+"Press ALT+F4 to quit !")

; Here, DirectDraw is correctly initialized. The real fun begins...
;

hWnd = OpenWindow(1, 100, 100, 300, 400, "PureBasic - Raw DirectX Test", #WS_POPUP)
SetFocus_(hWnd)

If DirectDraw\SetCooperativeLevel(hWnd, #DDSCL_EXCLUSIVE | #DDSCL_FULLSCREEN) = #DD_OK

  If DirectDraw\SetDisplayMode(#ScreenResX, #ScreenResY, #ScreenBits, 0, 0) = #DD_OK

    ;
    ; Double buffer
    ;
    SurfaceDescriptor\dwSize            = SizeOf(DDSURFACEDESC2)
    SurfaceDescriptor\dwFlags           = #DDSD_CAPS | #DDSD_BACKBUFFERCOUNT
    SurfaceDescriptor\ddsCaps\dwCaps    = #DDSCAPS_PRIMARYSURFACE | #DDSCAPS_FLIP | #DDSCAPS_COMPLEX
    SurfaceDescriptor\dwBackBufferCount = 1

    If DirectDraw\CreateSurface(SurfaceDescriptor, @PrimarySurface.IDirectDrawSurface7, 0) <> #DD_OK
      MessageRequester("Warning:","Couldn't create primary surface",0)
      End
    EndIf
    
    ddscaps.DDSCAPS2
    ;Get a pointer To the back buffer
    ddscaps\dwCaps = #DDSCAPS_BACKBUFFER;
    If PrimarySurface\GetAttachedSurface(ddscaps, @BackSurface.IDirectDrawSurface7) <> #DD_OK
      MessageRequester("Warning:","Couldn't create primary surface",0)
      End
    EndIf
    
    ;
    ; LOAD the image and create a surface
    ;
    
    ;// Create the offscreen surface, by loading our bitmap.
    hbm.l                   ;HBITMAP
    bm.BITMAP               ;BITMAP
    pdds.l;

    hbm = LoadImage_(0, @"Sprite.bmp", #IMAGE_BITMAP, 0, 0, #LR_LOADFROMFILE | #LR_CREATEDIBSECTION);
    If hbm = 0
      MessageRequester("INFO","Couldn't load the Sprite",0)
      End
    EndIf

    Debug hbm
    
    GetObject_(hbm, SizeOf(BITMAP), bm)
    
    Debug bm\bmWidth
    Debug bm\bmHeight

    SurfaceDescriptor\dwSize         = SizeOf(DDSURFACEDESC2)
    SurfaceDescriptor\dwFlags        = #DDSD_CAPS | #DDSD_HEIGHT | #DDSD_WIDTH
    SurfaceDescriptor\ddsCaps\dwCaps = #DDSCAPS_OFFSCREENPLAIN
    SurfaceDescriptor\dwWidth        = bm\bmWidth
    SurfaceDescriptor\dwHeight       = bm\bmHeight
    If DirectDraw\CreateSurface(SurfaceDescriptor, @Sprite.IDirectDrawSurface7, 0) <> #DD_OK
      MessageRequester("Error","Couldn't create Sprite surface",0)
      End
    EndIf

    hdcImage.l
    hdc.l
    bm2.BITMAP;
    ddsd2.DDSURFACEDESC2;
    hr.l;

    hdcImage = CreateCompatibleDC_(0);
    If hdcImage = 0
      MessageRequester("INFO","createcompatible dc failed",0)
      End
    EndIf
    
    SelectObject_(hdcImage, hbm);
    GetObject_(hbm, SizeOf(BITMAP), bm2);
    dx = bm2\bmWidth
    dy = bm2\bmHeight
    ddsd2\dwSize = SizeOf(DDSURFACEDESC2);
    ddsd2\dwFlags = #DDSD_HEIGHT | #DDSD_WIDTH;
    Sprite\GetSurfaceDesc(@ddsd2)

    hr = Sprite\GetDC(@hdc)
    If hr = #DD_OK
        StretchBlt_(hdc, 0, 0, ddsd2\dwWidth, ddsd2\dwHeight, hdcImage, 0, 0, dx, dy, #SRCCOPY);
        Sprite\ReleaseDC(hdc)
    Else
      Beep_(1000,1000)
    EndIf
    DeleteDC_(hdcImage);
    DeleteObject_(hbm);
    Sprite.IDirectDrawSurface7 = Sprite

    If Sprite = 0
      MessageRequester("INFO","DDLoadBitmap FAILED",0)
      End
    EndIf

    ddck.DDCOLORKEY;
    ddck\dwColorSpaceLowValue  = 0
    ddck\dwColorSpaceHighValue = 0
    Sprite\SetColorKey(#DDCKEY_SRCBLT, ddck)
    
    ;
    ; OK, Image is now loaded (hopefully ;)
    ;

    ShowWindow_(hWnd, #SW_SHOW)
    ShowCursor_(0)
    
    ;
    ; Message-Loop
    ;
    Color = $00FFFF00

    Repeat
      EventID = WindowEvent()
      
      If EventID = #PB_Event_CloseWindow  ; If the user has pressed on the close button
        Quit = 1
      EndIf

      If GetFocus_() = hWnd

        PrimarySurface\Flip(0, #DDFLIP_WAIT)  ; Swap the 2 buffers (front and back)
                
        rcRect.RECT
        rcRect\left   = 0
        rcRect\top    = 0
        rcRect\right  = 640
        rcRect\bottom = 480
        
        
        BlitFX.DDBLTFX\dwSize = SizeOf(DDBLTFX)
        BlitFX\dwFillColor = 0 ; Black fill
  
        BackSurface\Blt(0, 0, 0, #DDBLT_COLORFILL, BlitFX)

        rcRect\left   = 0
        rcRect\top    = 0
        rcRect\right  = bm\bmWidth-1
        rcRect\bottom = bm\bmHeight-1

        destRECT.RECT
        destRECT\left   = 100
        destRECT\top    = 100
        destRECT\right  = 100+myX
        destRECT\bottom = 100+myX

        BackSurface\Blt(destRECT, Sprite, rcRect, #DDBLT_KEYSRC, BlitFX)

        myX + 1
        If myX > 300
          myX = 10
        EndIf
      EndIf
      
    Until Quit = 1 

  Else
     MessageRequester("Warning:", "Couldn't set display mode", 0)
  EndIf
Else
  MessageRequester("Error:","Couldn't set DirectDraw cooperative level")
EndIf

End
 
DataSection
  IID_IDirectDraw7:
    Data.l $15e65ec0
    Data.w $3b9c, $11d2
    Data.b $b9, $2f, $00, $60, $97, $97, $ea, $5b
EndDataSection 