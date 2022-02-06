; *** Macros ***

CompilerIf #PB_Compiler_64Bit
  Macro CGFloat:d:EndMacro
CompilerElse
  Macro CGFloat:f:EndMacro
CompilerEndIf

; *** Constants ***

#YES = 1
#NO = 0

#nil = 0

#kCFAllocatorDefault = 0
#kCFNotFound = -1

CompilerIf #PB_Compiler_64Bit
  #NSNotFound = $7fffffffffffffff
CompilerElse
  #NSNotFound = $7fffffff
CompilerEndIf

Enumeration
  #RTLD_LAZY      = 1
  #RTLD_NOW       = 2
  #RTLD_LOCAL     = 4
  #RTLD_GLOBAL    = 8
  #RTLD_NOLOAD    = 16
  #RTLD_NODELETE  = 128
  #RTLD_FIRST     = 256
  #RTLD_NEXT      = -1
  #RTLD_DEFAULT   = -2
  #RTLD_SELF      = -3
  #RTLD_MAIN_ONLY = -5
EndEnumeration

Enumeration
  #NSRoundPlain
  #NSRoundDown
  #NSRoundUp
  #NSRoundBankers
EndEnumeration

Enumeration
  #NSCalculationNoError
  #NSCalculationLossOfPrecision
  #NSCalculationUnderflow
  #NSCalculationOverflow
  #NSCalculationDivideByZero
EndEnumeration

Enumeration
  #NSNoBorder
  #NSLineBorder
  #NSBezelBorder
  #NSGrooveBorder
EndEnumeration

Enumeration
  #NSLeftMouseDown = 1
  #NSLeftMouseUp
  #NSRightMouseDown
  #NSRightMouseUp
  #NSMouseMoved
  #NSLeftMouseDragged
  #NSRightMouseDragged
  #NSMouseEntered
  #NSMouseExited
  #NSKeyDown
  #NSKeyUp
  #NSFlagsChanged
  #NSAppKitDefined
  #NSSystemDefined
  #NSApplicationDefined
  #NSPeriodic
  #NSCursorUpdate
  #NSEventTypeRotate
  #NSEventTypeBeginGesture
  #NSEventTypeEndGesture
  #NSScrollWheel = 22
  #NSTabletPoint
  #NSTabletProximity
  #NSOtherMouseDown
  #NSOtherMouseUp
  #NSOtherMouseDragged
  #NSEventTypeGesture = 29
  #NSEventTypeMagnify
  #NSEventTypeSwipe
  #NSEventTypeSmartMagnify
  #NSEventTypeQuickLook
  #NSEventTypePressure
EndEnumeration

Enumeration
  #NSLeftMouseDownMask      = 1 << #NSLeftMouseDown
  #NSLeftMouseUpMask        = 1 << #NSLeftMouseUp
  #NSRightMouseDownMask     = 1 << #NSRightMouseDown
  #NSRightMouseUpMask       = 1 << #NSRightMouseUp
  #NSMouseMovedMask         = 1 << #NSMouseMoved
  #NSLeftMouseDraggedMask   = 1 << #NSLeftMouseDragged
  #NSRightMouseDraggedMask  = 1 << #NSRightMouseDragged
  #NSMouseEnteredMask       = 1 << #NSMouseEntered
  #NSMouseExitedMask        = 1 << #NSMouseExited
  #NSKeyDownMask            = 1 << #NSKeyDown
  #NSKeyUpMask              = 1 << #NSKeyUp
  #NSFlagsChangedMask       = 1 << #NSFlagsChanged
  #NSAppKitDefinedMask      = 1 << #NSAppKitDefined
  #NSSystemDefinedMask      = 1 << #NSSystemDefined
  #NSApplicationDefinedMask = 1 << #NSApplicationDefined
  #NSPeriodicMask           = 1 << #NSPeriodic
  #NSCursorUpdateMask       = 1 << #NSCursorUpdate
  #NSScrollWheelMask        = 1 << #NSScrollWheel
  #NSTabletPointMask        = 1 << #NSTabletPoint
  #NSTabletProximityMask    = 1 << #NSTabletProximity
  #NSOtherMouseDownMask     = 1 << #NSOtherMouseDown
  #NSOtherMouseUpMask       = 1 << #NSOtherMouseUp
  #NSOtherMouseDraggedMask  = 1 << #NSOtherMouseDragged
  #NSEventMaskGesture       = 1 << #NSEventTypeGesture
  #NSEventMaskMagnify       = 1 << #NSEventTypeMagnify
  #NSEventMaskSwipe         = 1 << #NSEventTypeSwipe
  #NSEventMaskRotate        = 1 << #NSEventTypeRotate
  #NSEventMaskBeginGesture  = 1 << #NSEventTypeBeginGesture
  #NSEventMaskEndGesture    = 1 << #NSEventTypeEndGesture
  #NSEventMaskSmartMagnify  = 1 << #NSEventTypeSmartMagnify
  #NSEventMaskPressure      = 1 << #NSEventTypePressure
  #NSAnyEventMask           = $ffffffff
EndEnumeration

Enumeration
  #NSAlphaShiftKeyMask  = 1 << 16
  #NSShiftKeyMask       = 1 << 17
  #NSControlKeyMask     = 1 << 18
  #NSAlternateKeyMask   = 1 << 19
  #NSCommandKeyMask     = 1 << 20
  #NSNumericPadKeyMask  = 1 << 21
  #NSHelpKeyMask        = 1 << 22
  #NSFunctionKeyMask    = 1 << 23
  #NSDeviceIndependentModifierFlagsMask = $ffff0000
EndEnumeration

Enumeration
  #NSWindowExposedEventType           = 0
  #NSApplicationActivatedEventType    = 1
  #NSApplicationDeactivatedEventType  = 2
  #NSWindowMovedEventType             = 4
  #NSScreenChangedEventType           = 8
  #NSAWTEventType                     = 16
EndEnumeration

Enumeration
  #NSViewNotSizable     = 0
  #NSViewMinXMargin     = 1
  #NSViewWidthSizable   = 2
  #NSViewMaxXMargin     = 4
  #NSViewMinYMargin     = 8
  #NSViewHeightSizable  = 16
  #NSViewMaxYMargin     = 32
EndEnumeration

Enumeration
  #NSWindowCloseButton
  #NSWindowMiniaturizeButton
  #NSWindowZoomButton
  #NSWindowToolbarButton
  #NSWindowDocumentIconButton
  #NSWindowDocumentVersionsButton = 6
  #NSWindowFullScreenButton
EndEnumeration

Enumeration
  #NSWindowCollectionBehaviorDefault                    = 0
  #NSWindowCollectionBehaviorCanJoinAllSpaces           = 1
  #NSWindowCollectionBehaviorMoveToActiveSpace          = 2
  #NSWindowCollectionBehaviorManaged                    = 4
  #NSWindowCollectionBehaviorTransient                  = 8
  #NSWindowCollectionBehaviorStationary                 = 16
  #NSWindowCollectionBehaviorParticipatesInCycle        = 32
  #NSWindowCollectionBehaviorIgnoresCycle               = 64
  #NSWindowCollectionBehaviorFullScreenPrimary          = 128
  #NSWindowCollectionBehaviorFullScreenAuxiliary        = 256
  #NSWindowCollectionBehaviorFullScreenAllowsTiling     = 2048
  #NSWindowCollectionBehaviorFullScreenDisallowsTiling  = 4096
EndEnumeration

Enumeration
  #NSBorderlessWindowMask             = 0
  #NSTitledWindowMask                 = 1
  #NSClosableWindowMask               = 2
  #NSMiniaturizableWindowMask         = 4
  #NSResizableWindowMask              = 8
  #NSTexturedBackgroundWindowMask     = 256
  #NSUnifiedTitleAndToolbarWindowMask = 4096
  #NSFullScreenWindowMask             = 16384
  #NSFullSizeContentViewWindowMask    = 32768
EndEnumeration

Enumeration
  #NSLeftTextAlignment
  CompilerIf #PB_Compiler_Processor = #PB_Processor_Arm64
    #NSCenterTextAlignment
    #NSRightTextAlignment
  CompilerElse
    #NSRightTextAlignment
    #NSCenterTextAlignment
  CompilerEndIf
  #NSJustifiedTextAlignment
  #NSNaturalTextAlignment
EndEnumeration

Enumeration
  #NSWritingDirectionNatural = -1
  #NSWritingDirectionLeftToRight
  #NSWritingDirectionRightToLeft
EndEnumeration

Enumeration
  #NSScrollElasticityAutomatic
  #NSScrollElasticityNone
  #NSScrollElasticityAllowed
EndEnumeration

Enumeration
  #NSStringEncodingConversionAllowLossy = 1
  #NSStringEncodingConversionExternalRepresentation
EndEnumeration

Enumeration
  #NSCaseInsensitiveSearch      = 1
  #NSLiteralSearch              = 2
  #NSBackwardsSearch            = 4
  #NSAnchoredSearch             = 8
  #NSNumericSearch              = 64
  #NSDiacriticInsensitiveSearch = 128
  #NSWidthInsensitiveSearch     = 256
  #NSForcedOrderingSearch       = 512
  #NSRegularExpressionSearch    = 1024
EndEnumeration

Enumeration
  #NSOrderedAscending = -1
  #NSOrderedSame
  #NSOrderedDescending
EndEnumeration

Enumeration
  #NSMacOSRomanStringEncoding         = 30
  #NSWindowsCP1252StringEncoding      = 12
  #NSISOLatin1StringEncoding          = 5
  #NSNEXTSTEPStringEncoding           = 2
  #NSASCIIStringEncoding              = 1
  #NSUnicodeStringEncoding            = 10
  #NSUTF8StringEncoding               = 4
  #NSNonLossyASCIIStringEncoding      = 7
  #NSUTF16StringEncoding              = 10
  #NSUTF16BigEndianStringEncoding     = $90000100
  #NSUTF16LittleEndianStringEncoding  = $94000100
  #NSUTF32StringEncoding              = $8c000100
  #NSUTF32BigEndianStringEncoding     = $98000100
  #NSUTF32LittleEndianStringEncoding  = $9c000100
EndEnumeration

Enumeration
  #NSDateFormatterNoStyle
  #NSDateFormatterShortStyle
  #NSDateFormatterMediumStyle
  #NSDateFormatterLongStyle
  #NSDateFormatterFullStyle
EndEnumeration

Enumeration
  #NSNumberFormatterNoStyle
  #NSNumberFormatterDecimalStyle
  #NSNumberFormatterCurrencyStyle
  #NSNumberFormatterPercentStyle
  #NSNumberFormatterScientificStyle
  #NSNumberFormatterSpellOutStyle
  #NSNumberFormatterOrdinalStyle
  #NSNumberFormatterCurrencyISOCodeStyle = 8
  #NSNumberFormatterCurrencyPluralStyle
  #NSNumberFormatterCurrencyAccountingStyle
EndEnumeration

#NSNumberFormatterParseIntegersOnly = 1

Enumeration
  #NSNumberFormatterRoundCeiling
  #NSNumberFormatterRoundFloor
  #NSNumberFormatterRoundDown
  #NSNumberFormatterRoundUp
  #NSNumberFormatterRoundHalfEven
  #NSNumberFormatterRoundHalfDown
  #NSNumberFormatterRoundHalfUp
EndEnumeration

Enumeration
  #NSNumberFormatterPadBeforePrefix
  #NSNumberFormatterPadAfterPrefix
  #NSNumberFormatterPadBeforeSuffix
  #NSNumberFormatterPadAfterSuffix
EndEnumeration

Enumeration
  #NSCompositeClear
  #NSCompositeCopy
  #NSCompositeSourceOver
  #NSCompositeSourceIn
  #NSCompositeSourceOut
  #NSCompositeSourceAtop
  #NSCompositeDestinationOver
  #NSCompositeDestinationIn
  #NSCompositeDestinationOut
  #NSCompositeDestinationAtop
  #NSCompositeXOR
  #NSCompositePlusDarker
  #NSCompositeHighlight
  #NSCompositePlusLighter
  #NSCompositeMultiply
  #NSCompositeScreen
  #NSCompositeOverlay
  #NSCompositeDarken
  #NSCompositeLighten
  #NSCompositeColorDodge
  #NSCompositeColorBurn
  #NSCompositeSoftLight
  #NSCompositeHardLight
  #NSCompositeDifference
  #NSCompositeExclusion
  #NSCompositeHue
  #NSCompositeSaturation
  #NSCompositeColor
  #NSCompositeLuminosity
EndEnumeration

Enumeration
  #NSImageCacheDefault
  #NSImageCacheAlways
  #NSImageCacheBySize
  #NSImageCacheNever
EndEnumeration

Enumeration
  #NSTIFFFileType
  #NSBMPFileType
  #NSGIFFileType
  #NSJPEGFileType
  #NSPNGFileType
  #NSJPEG2000FileType
EndEnumeration

Enumeration
  #NSApplicationDirectory = 1
  #NSDemoApplicationDirectory
  #NSDeveloperApplicationDirectory
  #NSAdminApplicationDirectory
  #NSLibraryDirectory
  #NSDeveloperDirectory
  #NSUserDirectory
  #NSDocumentationDirectory
  #NSDocumentDirectory
  #NSCoreServiceDirectory
  #NSAutosavedInformationDirectory
  #NSDesktopDirectory
  #NSCachesDirectory
  #NSApplicationSupportDirectory
  #NSDownloadsDirectory
  #NSInputMethodsDirectory
  #NSMoviesDirectory
  #NSMusicDirectory
  #NSPicturesDirectory
  #NSPrinterDescriptionDirectory
  #NSSharedPublicDirectory
  #NSPreferencePanesDirectory
  #NSApplicationScriptsDirectory
  #NSItemReplacementDirectory = 99
  #NSAllApplicationsDirectory
  #NSAllLibrariesDirectory
  #NSTrashDirectory
EndEnumeration

Enumeration
  #NSUserDomainMask     = 1
  #NSLocalDomainMask    = 2
  #NSNetworkDomainMask  = 4
  #NSSystemDomainMask   = 8
  #NSAllDomainsMask     = $ffff
EndEnumeration

Enumeration
  #kCGEventSourceStatePrivate = -1
  #kCGEventSourceStateCombinedSessionState
  #kCGEventSourceStateHIDSystemState
EndEnumeration

Enumeration
  #kCGHIDEventTap
  #kCGSessionEventTap
  #kCGAnnotatedSessionEventTap
EndEnumeration

Enumeration
  #kCGHeadInsertEventTap
  #kCGTailAppendEventTap
EndEnumeration

Enumeration
  #kCGEventTapOptionDefault
  #kCGEventTapOptionListenOnly
EndEnumeration

Enumeration
  #kCFRunLoopEntry          = 1 << 0
  #kCFRunLoopBeforeTimers   = 1 << 1
  #kCFRunLoopBeforeSources  = 1 << 2
  #kCFRunLoopBeforeWaiting  = 1 << 5
  #kCFRunLoopAfterWaiting   = 1 << 6
  #kCFRunLoopExit           = 1 << 7
  #kCFRunLoopAllActivities  = $0fffffff
EndEnumeration

Enumeration
  #kCFCompareCaseInsensitive      = 1
  #kCFCompareBackwards            = 4
  #kCFCompareAnchored             = 8
  #kCFCompareNonliteral           = 16
  #kCFCompareLocalized            = 32
  #kCFCompareNumerically          = 64
  #kCFCompareDiacriticInsensitive = 128
  #kCFCompareWidthInsensitive     = 256
  #kCFCompareForcedOrdering       = 512
EndEnumeration

Enumeration
  #kCFCompareLessThan = -1
  #kCFCompareEqualTo
  #kCFCompareGreaterThan
EndEnumeration

Enumeration
  #kCFStringEncodingMacRoman      = 0
  #kCFStringEncodingWindowsLatin1 = $0500
  #kCFStringEncodingISOLatin1     = $0201
  #kCFStringEncodingNextStepLatin = $0B01
  #kCFStringEncodingASCII         = $0600
  #kCFStringEncodingUnicode       = $0100
  #kCFStringEncodingUTF8          = $08000100
  #kCFStringEncodingNonLossyASCII = $0BFF
  #kCFStringEncodingUTF16         = $0100
  #kCFStringEncodingUTF16BE       = $10000100
  #kCFStringEncodingUTF16LE       = $14000100
  #kCFStringEncodingUTF32         = $0c000100
  #kCFStringEncodingUTF32BE       = $18000100
  #kCFStringEncodingUTF32LE       = $1c000100
EndEnumeration

Enumeration
  #kCFDateFormatterNoStyle
  #kCFDateFormatterShortStyle
  #kCFDateFormatterMediumStyle
  #kCFDateFormatterLongStyle
  #kCFDateFormatterFullStyle
EndEnumeration

Enumeration
  #kCFNumberSInt8Type = 1
  #kCFNumberSInt16Type
  #kCFNumberSInt32Type
  #kCFNumberSInt64Type
  #kCFNumberFloat32Type
  #kCFNumberFloat64Type
  #kCFNumberCharType
  #kCFNumberShortType
  #kCFNumberIntType
  #kCFNumberLongType
  #kCFNumberLongLongType
  #kCFNumberFloatType
  #kCFNumberDoubleType
  #kCFNumberCFIndexType
  #kCFNumberNSIntegerType
  #kCFNumberCGFloatType
  #kCFNumberMaxType = 16
EndEnumeration

Enumeration
  #kCFNumberFormatterNoStyle
  #kCFNumberFormatterDecimalStyle
  #kCFNumberFormatterCurrencyStyle
  #kCFNumberFormatterPercentStyle
  #kCFNumberFormatterScientificStyle
  #kCFNumberFormatterSpellOutStyle
  #kCFNumberFormatterOrdinalStyle
  #kCFNumberFormatterCurrencyISOCodeStyle = 8
  #kCFNumberFormatterCurrencyPluralStyle
  #kCFNumberFormatterCurrencyAccountingStyle
EndEnumeration

#kCFNumberFormatterParseIntegersOnly = 1

Enumeration
  #kCFNumberFormatterRoundCeiling
  #kCFNumberFormatterRoundFloor
  #kCFNumberFormatterRoundDown
  #kCFNumberFormatterRoundUp
  #kCFNumberFormatterRoundHalfEven
  #kCFNumberFormatterRoundHalfDown
  #kCFNumberFormatterRoundHalfUp
EndEnumeration

Enumeration
  #kCFNumberFormatterPadBeforePrefix
  #kCFNumberFormatterPadAfterPrefix
  #kCFNumberFormatterPadBeforeSuffix
  #kCFNumberFormatterPadAfterSuffix
EndEnumeration

Enumeration
  #kvImageNoFlags                = 0
  #kvImageLeaveAlphaUnchanged    = 1
  #kvImageCopyInPlace            = 2
  #kvImageBackgroundColorFill    = 4
  #kvImageEdgeExtend             = 8
  #kvImageDoNotTile              = 16
  #kvImageHighQualityResampling  = 32
  #kvImageTruncateKernel         = 64
  #kvImageGetTempBufferSize      = 128
EndEnumeration

; *** Structures ***

Structure NSDecimal
  _bitFields.l
  _mantissa.q[2]
EndStructure

Structure NSRange
  location.i
  length.i
EndStructure

Structure NSPoint
  x.CGFloat
  y.CGFloat
EndStructure

Structure NSSize
  width.CGFloat
  height.CGFloat
EndStructure

Structure NSRect
  origin.NSPoint
  size.NSSize
EndStructure

Structure NSAffineTransform
  m11.CGFloat
  m12.CGFloat
  m21.CGFloat
  m22.CGFloat
  tX.CGFloat
  tY.CGFloat
EndStructure

Structure CGPoint Extends NSPoint
EndStructure

Structure CGSize Extends NSSize
EndStructure

Structure CGRect Extends NSRect
EndStructure

Structure CGAffineTransform
  a.CGFloat
  b.CGFloat
  c.CGFloat
  d.CGFloat
  tx.CGFloat
  ty.CGFloat
EndStructure

Structure CGVector
  dx.CGFloat
  dy.CGFloat
EndStructure

Structure CFRange
  location.i
  length.i
EndStructure

Structure vImage_Buffer
  *data
  height.i
  width.i
  rowBytes.i
EndStructure

Structure vImage_AffineTransform
  a.f
  b.f
  c.f
  d.f
  tx.f
  ty.f
EndStructure

Structure VoiceSpec
  creator.l
  id.l
EndStructure

Structure VoiceDescription
  length.l
  voice.VoiceSpec
  version.l
  nameLen.a
  name.a[63]
  commentLen.a
  comment.a[255]
  gender.w
  age.w
  script.w
  language.w
  region.w
  reserved.l[4]
EndStructure
