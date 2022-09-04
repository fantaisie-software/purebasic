; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

;- zlib import
;
#Z_OK            = 0
#Z_STREAM_END    = 1
#Z_NEED_DICT     = 2
#Z_ERRNO         = (-1)
#Z_STREAM_ERROR  = (-2)
#Z_DATA_ERROR    = (-3)
#Z_MEM_ERROR     = (-4)
#Z_BUF_ERROR     = (-5)
#Z_VERSION_ERROR = (-6)

#Z_NO_FLUSH      = 0
#Z_PARTIAL_FLUSH = 1 ; /* will be removed, use Z_SYNC_FLUSH instead */
#Z_SYNC_FLUSH    = 2
#Z_FULL_FLUSH    = 3
#Z_FINISH        = 4
#Z_BLOCK         = 5


CompilerIf #PB_Compiler_64Bit And #PB_Compiler_OS <> #PB_OS_Windows
  
  ; On Linux x64, a long is 8 byte (unlike Windows x64)
  ;
  Structure z_stream
    *next_in.BYTE
    avail_in.l
    pad.l
    total_in.i ; uLong
    
    *next_out.BYTE
    avail_out.l
    pad2.l
    total_out.i ; uLong
    
    *msg.BYTE
    *state
    
    zalloc.i
    zfree.i
    opaque.i
    
    data_type.l
    pad3.l
    adler.i    ; uLong
    reserved.i ; uLong
  EndStructure
  
CompilerElse
  
  Structure z_stream
    *next_in.BYTE
    avail_in.l
    total_in.l ; uLong
    
    *next_out.BYTE
    avail_out.l
    total_out.l ; uLong
    
    *msg.BYTE
    *state
    
    zalloc.i
    zfree.i
    opaque.i
    
    data_type.l
    adler.l    ; uLong
    reserved.l ; uLong
    
    ; without this, the inflateInit2() fails with a version error
    CompilerIf #PB_Compiler_64Bit
      alignment.l
    CompilerEndIf
  EndStructure
  
CompilerEndIf

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  #ZLib_Library = "zlib.lib"
CompilerElse
  #ZLib_Library = "-lz"
CompilerEndIf

ImportC #ZLib_Library
  ; Note: These do not work with zip data, as they expect a zlib header
  ;       But they are used for non-zip compression (example: EditHistory)
  ;
  ; Note also here the Windows/Linux difference on 64bit.
  ;       It should be ok to use the methods with all INTEGER types as long as they
  ;       have no garbage in their upper 32bits
  CompilerIf #PB_Compiler_64Bit And #PB_Compiler_OS <> #PB_OS_Windows
    compress.l(*dest, *destlen.INTEGER, *source, sourcelen.i)
    compress2.l(*dest, *destlen.INTEGER, *source, sourcelen.i, level.l)
    uncompress.l(*dest, *destlen.INTEGER, *source, sourcelen.i)
    compressBound.i(sourcelen.i)
  CompilerElse
    compress.l(*dest, *destlen.LONG, *source, sourcelen.l)
    compress2.l(*dest, *destlen.LONG, *source, sourcelen.l, level.l)
    uncompress.l(*dest, *destlen.LONG, *source, sourcelen.l)
    compressBound.l(sourcelen.l)
  CompilerEndIf
  
  ; ZEXTERN uLong ZEXPORT compressBound OF((uLong sourceLen));
  
  ; According to zlib.h, calling inflateInit2
  ; with a negative window size enters "raw mode",
  ; which we need for zip extraction
  ;
  ; It also notes that it needs an extra input byte in this mode to finish
  ; properly. (to be checked)
  ;
  inflateInit2_.l(*stream.z_stream, windowBits.l, *version, streamsize.l)
  inflate.l(*stream.z_stream, flush.l)
  inflateEnd.l(*stream.z_stream)
EndImport

; definition of the zlib macro
Macro inflateInit2(stream, windowBits)
  inflateInit2_(stream, windowBits, @"1.2.5", SizeOf(z_stream))
EndMacro



