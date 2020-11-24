XIncludeFile "common.pbi"

ImportC "-framework Accelerate"
  ApiC(vImageAffineWarp_ARGB8888, (*src, *dest, *tempBuffer, *transform, *backColor, flags))
  ApiC(vImageBufferFill_ARGB8888, (*dest, *color, flags))
  ApiC(vImageConvert_ARGB8888toRGB888, (*src, *dest, flags))
  ApiC(vImageFlatten_ARGB8888ToRGB888, (*src, *dst, *backColor, isPremultiplied, flags))
  ApiC(vImageHistogramCalculation_ARGB8888, (*src, *histogram, flags))
  ApiC(vImageHorizontalReflect_ARGB8888, (*src, *dest, flags))
  ApiC(vImagePermuteChannels_ARGB8888, (*src, *dest, *permuteMap, flags))
  ApiC(vImagePremultiplyData_ARGB8888, (*src, *dest, flags))
  ApiC(vImagePremultiplyData_RGBA8888, (*src, *dest, flags))
  ApiC(vImageUnpremultiplyData_ARGB8888, (*src, *dest, flags))
  ApiC(vImageUnpremultiplyData_RGBA8888, (*src, *dest, flags))
  ApiC(vImageVerticalReflect_ARGB8888, (*src, *dest, flags))
EndImport
