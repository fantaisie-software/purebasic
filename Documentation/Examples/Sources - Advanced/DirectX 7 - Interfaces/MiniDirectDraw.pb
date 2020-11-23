;***************************************************************************
;*
;*  File:       ddraw.pb / DirectX 7 SDK
;*  Content:    DirectDraw include file
;*              for PureBasic (www.PureBasic.com)
;*  Autor:      Danilo, March 2002
;*  Note:       Minimal version for PureBasic example
;*
;***************************************************************************

;* DDCOLORKEY
Structure DDCOLORKEY
   dwColorSpaceLowValue.l  ;// low boundary of color space that is to
                           ;// be treated as Color Key, inclusive
   dwColorSpaceHighValue.l ;// high boundary of color space that is
                           ;// to be treated as Color Key, inclusive
EndStructure


;* DDSCAPS2
Structure DDSCAPS2
   dwCaps.l                ;// capabilities of surface wanted
   dwCaps2.l
   dwCaps3.l
   dwCaps4.l
EndStructure


;* DDPIXELFORMAT
Structure DDPIXELFORMAT
   dwSize.l;                             // size of structure
   dwFlags.l;                            // pixel format flags
   dwFourCC.l;                           // (FOURCC code)

    StructureUnion
        dwRGBBitCount.l;                 // how many bits per pixel
        dwYUVBitCount.l;                 // how many bits per pixel
        dwZBufferBitDepth.l;             // how many total bits/pixel in z buffer (including any stencil bits)
        dwAlphaBitDepth.l;               // how many bits for alpha channels
        dwLuminanceBitCount.l;           // how many bits per pixel
        dwBumpBitCount.l;                // how many bits per "buxel", total
    EndStructureUnion

    StructureUnion
        dwRBitMask.l;                    // mask for red bit
        dwYBitMask.l;                    // mask for Y bits
        dwStencilBitDepth.l;             // how many stencil bits (note: dwZBufferBitDepth-dwStencilBitDepth is total Z-only bits)
        dwLuminanceBitMask.l;            // mask for luminance bits
        dwBumpDuBitMask.l;               // mask for bump map U delta bits
    EndStructureUnion

    StructureUnion
        dwGBitMask.l;                    // mask for green bits
        dwUBitMask.l;                    // mask for U bits
        dwZBitMask.l;                    // mask for Z bits
        dwBumpDvBitMask.l;               // mask for bump map V delta bits
    EndStructureUnion

    StructureUnion
        dwBBitMask.l;                    // mask for blue bits
        dwVBitMask.l;                    // mask for V bits
        dwStencilBitMask.l;              // mask for stencil bits
        dwBumpLuminanceBitMask.l;        // mask for luminance in bump map
    EndStructureUnion

    StructureUnion
        dwRGBAlphaBitMask.l;             // mask for alpha channel
        dwYUVAlphaBitMask.l;             // mask for alpha channel
        dwLuminanceAlphaBitMask.l;       // mask for alpha channel
        dwRGBZBitMask.l;                 // mask for Z channel
        dwYUVZBitMask.l;                 // mask for Z channel
    EndStructureUnion
EndStructure


;* DDSURFACEDESC2
Structure DDSURFACEDESC2
   dwSize.l;                                // size of the DDSURFACEDESC structure
   dwFlags.l;                               // determines what fields are valid
   dwHeight.l;                              // height of surface to be created
   dwWidth.l;                               // width of input surface
    StructureUnion
        lPitch.l;                           // distance to start of next line (return value only)
        dwLinearSize.l;                     // Formless late-allocated optimized surface size
    EndStructureUnion
   dwBackBufferCount.l;                     // number of back buffers requested
    StructureUnion
        dwMipMapCount.l;                    // number of mip-map levels requestde
        ;                                   // dwZBufferBitDepth removed, use ddpfPixelFormat one instead
        dwRefreshRate.l;                    // refresh rate (used when display mode is described)
        dwSrcVBHandle.l;                    // The source used in VB::Optimize
    EndStructureUnion
   dwAlphaBitDepth.l;                       // depth of alpha buffer requested
   dwReserved.l;                            // reserved
   lpSurface.l;                             // pointer to the associated surface memory
    StructureUnion
        ddckCKDestOverlay.DDCOLORKEY;       // color key for destination overlay use
        dwEmptyFaceColor.l;                 // Physical color for empty cubemap faces
    EndStructureUnion
   ddckCKDestBlt.DDCOLORKEY;                // color key for destination blt use
   ddckCKSrcOverlay.DDCOLORKEY;             // color key for source overlay use
   ddckCKSrcBlt.DDCOLORKEY;                 // color key for source blt use
    StructureUnion
        ddpfPixelFormat.DDPIXELFORMAT;      // pixel format description of the surface
        dwFVF.l;                            // vertex format description of vertex buffers
    EndStructureUnion
   ddsCaps.DDSCAPS2;                        // direct draw surface capabilities
   dwTextureStage.l;                        // stage in multitexture cascade
EndStructure

Structure DDBLTFX
   dwSize.l;                         // size of structure
   dwDDFX.l;                         // FX operations
   dwROP.l;                          // Win32 raster operations
   dwDDROP.l;                        // Raster operations new for DirectDraw
   dwRotationAngle.l;                // Rotation angle for blt
   dwZBufferOpCode.l;                // ZBuffer compares
   dwZBufferLow.l;                   // Low limit of Z buffer
   dwZBufferHigh.l;                  // High limit of Z buffer
   dwZBufferBaseDest.l;              // Destination base value
   dwZDestConstBitDepth.l;           // Bit depth used to specify Z constant for destination

    StructureUnion
       dwZDestConst.l;               // Constant to use as Z buffer for dest
       lpDDSZBufferDest.l;           // Surface to use as Z buffer for dest
    EndStructureUnion

   dwZSrcConstBitDepth.l;            // Bit depth used to specify Z constant for source

    StructureUnion
       dwZSrcConst.l;                // Constant to use as Z buffer for src
       lpDDSZBufferSrc.l;            // Surface to use as Z buffer for src
    EndStructureUnion

   dwAlphaEdgeBlendBitDepth.l;       // Bit depth used to specify constant for alpha edge blend
   dwAlphaEdgeBlend.l;               // Alpha for edge blending
   dwReserved.l;
   dwAlphaDestConstBitDepth.l;       // Bit depth used to specify alpha constant for destination

    StructureUnion
       dwAlphaDestConst.l;           // Constant to use as Alpha Channel
       lpDDSAlphaDest.l;             // Surface to use as Alpha Channel
    EndStructureUnion

   dwAlphaSrcConstBitDepth.l;        // Bit depth used to specify alpha constant for source

    StructureUnion
       dwAlphaSrcConst.l;            // Constant to use as Alpha Channel
       lpDDSAlphaSrc.l;              // Surface to use as Alpha Channel
    EndStructureUnion

    StructureUnion
       dwFillColor.l;                // color in RGB or Palettized
       dwFillDepth.l;                // depth value for z-buffer
       dwFillPixel.l;                // pixel value for RGBA or RGBZ
       lpDDSPattern.l;               // Surface to use as pattern
    EndStructureUnion

   ddckDestColorkey.DDCOLORKEY;      // DestColorkey override
   ddckSrcColorkey.DDCOLORKEY;       // SrcColorkey override
EndStructure




#DD_OK                         = 0
#DD_FALSE                      = 1

#DDSCL_FULLSCREEN                                 = $00000001
#DDSCL_EXCLUSIVE                                  = $00000010

#DDSD_CAPS                    = $00000001
#DDSD_HEIGHT                  = $00000002
#DDSD_WIDTH                   = $00000004
#DDSD_BACKBUFFERCOUNT         = $00000020

#DDSCAPS_BACKBUFFER                           = $00000004
#DDSCAPS_OFFSCREENPLAIN                       = $00000040
#DDSCAPS_PRIMARYSURFACE                       = $00000200
#DDSCAPS_COMPLEX                              = $00000008
#DDSCAPS_FLIP                                 = $00000010

#DDCKEY_SRCBLT                                    = $00000008

#DDFLIP_WAIT                                      = $00000001
#DDBLTFAST_NOCOLORKEY                             = $00000000

#DDBLT_KEYSRC                                     = $00008000
#DDBLT_COLORFILL                                  = $00000400





; ExecutableFormat=Windows
; EOF