XIncludeFile "common.pbi"


CompilerSelect #PB_Compiler_OS

CompilerCase #PB_OS_Windows

  Import "glu32.lib"

CompilerCase #PB_OS_MacOS

  ImportC "-framework Carbon -framework OpenGL"

CompilerDefault ; Linux

  ImportC "-L/usr/X11R6/lib -lGL -lGLU -lXxf86vm -lX11"

CompilerEndSelect

  Api(gluBeginCurve, (arg1), 4)
  Api(gluBeginPolygon, (arg1), 4)
  Api(gluBeginSurface, (arg1), 4)
  Api(gluBeginTrim, (arg1), 4)
  Api(gluBuild1DMipmaps, (arg1, arg2, arg3, arg4, arg5, arg6), 24)
  Api(gluBuild2DMipmaps, (arg1, arg2, arg3, arg4, arg5, arg6, arg7), 28)
  Api(gluCylinder, (arg1, arg2.d, arg3.d, arg4.d, arg5, arg6), 36)
  Api(gluDeleteNurbsRenderer, (arg1), 4)
  Api(gluDeleteQuadric, (arg1), 4)
  Api(gluDeleteTess, (arg1), 4)
  Api(gluDisk, (arg1, arg2.d, arg3.d, arg4, arg5), 28)
  Api(gluEndCurve, (arg1), 4)
  Api(gluEndPolygon, (arg1), 4)
  Api(gluEndSurface, (arg1), 4)
  Api(gluEndTrim, (arg1), 4)
  Api(gluErrorString, (arg1), 4)
  Api(gluErrorUnicodeStringEXT, (arg1), 4)
  Api(gluGetNurbsProperty, (arg1, arg2, arg3), 12)
  Api(gluLoadSamplingMatrices, (arg1, arg2, arg3, arg4), 16)
  Api(gluLookAt, (arg1.d, arg2.d, arg3.d, arg4.d, arg5.d, arg6.d, arg7.d, arg8.d, arg9.d), 72)
  Api(gluNewNurbsRenderer, (), 0)
  Api(gluNewQuadric, (), 0)
  Api(gluNewTess, (), 0)
  Api(gluNextContour, (arg1, arg2), 8)
  Api(gluNurbsCallback, (arg1, arg2, arg3), 12)
  Api(gluNurbsCurve, (arg1, arg2, arg3, arg4, arg5, arg6, arg7), 28)
  Api(gluNurbsProperty, (arg1, arg2, arg3), 12)
  Api(gluNurbsSurface, (arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11), 44)
  Api(gluOrtho2D, (arg1.d, arg2.d, arg3.d, arg4.d), 32)
  Api(gluPartialDisk, (arg1, arg2.d, arg3.d, arg4, arg5, arg6.d, arg7.d), 44)
  Api(gluPerspective, (arg1.d, arg2.d, arg3.d, arg4.d), 32)
  Api(gluPickMatrix, (arg1.d, arg2.d, arg3.d, arg4.d, arg5), 36)
  Api(gluProject, (arg1.d, arg2.d, arg3.d, arg4, arg5, arg6, arg7, arg8, arg9), 48)
  Api(gluPwlCurve, (arg1, arg2, arg3, arg4, arg5), 20)
  Api(gluQuadricCallback, (arg1, arg2, arg3), 12)
  Api(gluQuadricDrawStyle, (arg1, arg2), 8)
  Api(gluQuadricNormals, (arg1, arg2), 8)
  Api(gluQuadricOrientation, (arg1, arg2), 8)
  Api(gluQuadricTexture, (arg1, arg2), 8)
  Api(gluScaleImage, (arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9), 36)
  Api(gluSphere, (arg1, arg2.d, arg3, arg4), 20)
  Api(gluTessBeginContour, (arg1), 4)
  Api(gluTessBeginPolygon, (arg1, arg2), 8)
  Api(gluTessCallback, (arg1, arg2, arg3), 12)
  Api(gluTessEndContour, (arg1), 4)
  Api(gluTessEndPolygon, (arg1), 4)
  Api(gluTessNormal, (arg1, arg2.d, arg3.d, arg4.d), 28)
  Api(gluTessProperty, (arg1, arg2, arg3), 12)
  Api(gluTessVertex, (arg1, arg2, arg3), 12)
  Api(gluUnProject, (arg1.d, arg2.d, arg3.d, arg4, arg5, arg6, arg7, arg8, arg9), 48)
EndImport
