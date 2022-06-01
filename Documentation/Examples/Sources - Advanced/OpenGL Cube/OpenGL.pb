;
; Native OpenGL Test
;
; (c) Fantaisie Software
;
; This source is based on an ASM source code found on the web (can't remember which one).
;
; Axis explainations:
;
;             +
;             y
;
;             |
;             |
;  +          |
;  x ---------\
;              \
;               \
;                \
;                  z+
;
; So a rotate on the y axis will take the y axis as center. With OpenGL, we can specify
; positive And negative value. Positive values are always in the same sens as the axis
; (like described on the schmatic, with '+' signs)
;

CompilerIf #PB_Compiler_OS <> #PB_OS_Windows
  CompilerError "This example code is Windows only."  
CompilerEndIf

Global RollAxisX.f
Global RollAxisY.f
Global RollAxisZ.f

Global RotateSpeedX.f
Global RotateSpeedY.f
Global RotateSpeedZ.f

Global ZoomFactor.f

Procedure DrawCube(hdc)
  glPushMatrix_()                  ; Save the original Matrix coordinates
  glMatrixMode_(#GL_MODELVIEW)

  glTranslatef_(0, 0, ZoomFactor)  ;  move it forward a bit

  glRotatef_ (RollAxisX, 1.0, 0, 0) ; rotate around X axis
  glRotatef_ (RollAxisY, 0, 1.0, 0) ; rotate around Y axis
  glRotatef_ (RollAxisZ, 0, 0, 1.0) ; rotate around Z axis
 
  RollAxisX + RotateSpeedX
  RollAxisY + RotateSpeedY
  RollAxisZ + RotateSpeedZ

  ; clear framebuffer And depth-buffer

  glClear_ (#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT)

  ; draw the faces of a cube
  
  ; draw colored faces

  glDisable_(#GL_LIGHTING)
  glBegin_  (#GL_QUADS)
  
  ; Build a face, composed of 4 vertex !
  ; glBegin() specify how the vertexes are considered. Here a group of
  ; 4 vertexes (GL_QUADS) form a rectangular surface.

  ; Now, the color stuff: It's r,v,b but with float values which
  ; can go from 0.0 To 1.0 (0 is .. zero And 1.0 is full intensity)
  
  glNormal3f_ (0,0,1.0)
  glColor3f_  (0,0,1.0)
  glVertex3f_ (0.5,0.5,0.5)
  glColor3f_  (0,1.0,1.0)
  glVertex3f_ (-0.5,0.5,0.5)
  glColor3f_  (1.0,1.0,1.0)
  glVertex3f_ (-0.5,-0.5,0.5)
  glColor3f_  (0,0,0)
  glVertex3f_ (0.5,-0.5,0.5)

  ; The other face is the same than the previous one
  ; except the colour which is nice blue To white gradiant

  glNormal3f_ (0,0,-1.0)
  glColor3f_  (0,0,1.0)
  glVertex3f_ (-0.5,-0.5,-0.5)
  glColor3f_  (0,0,1.0)
  glVertex3f_ (-0.5,0.5,-0.5)
  glColor3f_  (1.0,1.0,1.0)
  glVertex3f_ (0.5,0.5,-0.5)
  glColor3f_  (1.0,1.0,1.0)
  glVertex3f_ (0.5,-0.5,-0.5)
  
  glEnd_()
  
  ; draw shaded faces

  glEnable_(#GL_LIGHTING)
  glEnable_(#GL_LIGHT0)
  glBegin_ (#GL_QUADS)

  glNormal3f_ (   0, 1.0,   0)
  glVertex3f_ ( 0.5, 0.5, 0.5)
  glVertex3f_ ( 0.5, 0.5,-0.5)
  glVertex3f_ (-0.5, 0.5,-0.5)
  glVertex3f_ (-0.5, 0.5, 0.5)

  glNormal3f_ (0,-1.0,0)
  glVertex3f_ (-0.5,-0.5,-0.5)
  glVertex3f_ (0.5,-0.5,-0.5)
  glVertex3f_ (0.5,-0.5,0.5)
  glVertex3f_ (-0.5,-0.5,0.5)

  glNormal3f_ (1.0,0,0)
  glVertex3f_ (0.5,0.5,0.5)
  glVertex3f_ (0.5,-0.5,0.5)
  glVertex3f_ (0.5,-0.5,-0.5)
  glVertex3f_ (0.5,0.5,-0.5)

  glNormal3f_ (-1.0,   0,   0)
  glVertex3f_ (-0.5,-0.5,-0.5)
  glVertex3f_ (-0.5,-0.5, 0.5)
  glVertex3f_ (-0.5, 0.5, 0.5)
  glVertex3f_ (-0.5, 0.5,-0.5)

  glEnd_()

  glPopMatrix_()
  glFinish_()

  SwapBuffers_(hdc)
EndProcedure


Procedure HandleError (Result, Text$)
  If Result = 0
    MessageRequester("Error", Text$, 0)
    End
  EndIf
EndProcedure


pfd.PIXELFORMATDESCRIPTOR

FlatMode = 0         ; Enable Or disable the 'Flat' rendering

WindowWidth  = 600   ; The window & GLViewport dimensions
WindowHeight = 600

RotateSpeedX = 5.0   ; The speed of the rotation For the 3 axis
RotateSpeedY = 0
RotateSpeedZ = 5.0

ZoomFactor = 1       ; Distance of the camera. Negative value = zoom back

hWnd = OpenWindow(0, 10, 10, WindowWidth, WindowHeight, "First OpenGL Test")

hdc = GetDC_(hWnd)

pfd\nSize        = SizeOf(PIXELFORMATDESCRIPTOR)
pfd\nVersion     = 1
pfd\dwFlags      = #PFD_SUPPORT_OPENGL | #PFD_DOUBLEBUFFER | #PFD_DRAW_TO_WINDOW
pfd\dwLayerMask  = #PFD_MAIN_PLANE
pfd\iPixelType   = #PFD_TYPE_RGBA
pfd\cColorBits   = 16
pfd\cDepthBits   = 16

pixformat = ChoosePixelFormat_(hdc, pfd)

HandleError(SetPixelFormat_(hdc, pixformat, pfd), "SetPixelFormat()")

hrc = wglCreateContext_(hdc)

HandleError(wglMakeCurrent_(hdc,hrc), "vglMakeCurrent()")

glMatrixMode_(#GL_PROJECTION)

gluPerspective_(30.0, WindowWidth/WindowHeight, 1.0, 10.0)

; position viewer
glMatrixMode_(#GL_MODELVIEW)

glTranslatef_(0, 0, -5.0)

If (FlatMode)
  glShadeModel_(#GL_FLAT)
Else
  glShadeModel_(#GL_SMOOTH)
EndIf

glEnable_(#GL_DEPTH_TEST)   ; Enabled, it slowdown a lot the rendering. It's to be sure than the
                            ; rendered objects are inside the z-buffer.

glEnable_(#GL_CULL_FACE)    ; This will enhance the rendering speed as all the back face will be
                            ; ignored. This works only with CLOSED objects like a cube... Singles
                            ; planes surfaces will be visibles only on one side.

glViewport_(0, 0, DesktopScaledX(WindowWidth-30), DesktopScaledY(WindowHeight-30))

AddWindowTimer(0, 0, 16) ; About 60 fps

Repeat
  Event = WaitWindowEvent()
  
  Select Event
    Case #PB_Event_CloseWindow
      End
      
    Case #PB_Event_Timer
      DrawCube(hdc)
      
  EndSelect
ForEver
  