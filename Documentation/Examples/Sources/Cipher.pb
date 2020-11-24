;
; ------------------------------------------------------------
;
;   PureBasic - Cipher example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;
;

UseCRC32Fingerprint()
UseMD5Fingerprint()

MessageRequester("CRC32 Test", "Should be 352441c2 : "+StringFingerprint("abc", #PB_Cipher_CRC32, #PB_Ascii), 0)

MessageRequester("MD5 Test"  , "Should be ed50deb5bb795508b8a5c8e50dafa954 : "+StringFingerprint("PureBasic", #PB_Cipher_MD5, #PB_Ascii), 0)

MessageRequester("DES Test"  , "Should be FrfWXJ4yTjycc : "+DESFingerprint("1Fr", "Fr"), 0)
