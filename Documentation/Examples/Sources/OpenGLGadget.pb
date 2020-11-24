;
; OpenGL Gadget demonstration
;
; (c) Fantaisie Software
;
; Axis explainations:
;
;             +
;             y
;
;             |
;             |
;             |            +
;             /---------- x
;            /
;           /
;          /
;         / z+
;
; So a rotate on the y axis will take the y axis as center. With OpenGL, we can specify
; positive And negative value. Positive values are always in the same sens as the axis
; (like described on the schmatic, with '+' signs)
;

Global RollAxisX.f
Global RollAxisY.f
Global RollAxisZ.f

Global RotateSpeedX.f = 1.0
Global RotateSpeedY.f
Global RotateSpeedZ.f = 1.0

Global ZoomFactor.f = 1.0 ; Distance of the camera. Negative value = zoom back

Procedure DrawCube(Gadget)
  SetGadgetAttribute(Gadget, #PB_OpenGL_SetContext, #True)
  
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

  SetGadgetAttribute(Gadget, #PB_OpenGL_FlipBuffers, #True)
EndProcedure


Procedure SetupGL()
    
  glMatrixMode_(#GL_PROJECTION)
  gluPerspective_(30.0, 200/200, 1.0, 10.0)
  
  ; position viewer
  glMatrixMode_(#GL_MODELVIEW)
  
  glTranslatef_(0, 0, -5.0)
  
  glEnable_(#GL_DEPTH_TEST)   ; Enabled, it slowdown a lot the rendering. It's to be sure than the
                              ; rendered objects are inside the z-buffer.
  
  glEnable_(#GL_CULL_FACE)    ; This will enhance the rendering speed as all the back face will be
                              ; ignored. This works only with CLOSED objects like a cube... Singles
                              ; planes surfaces will be visibles only on one side.
    
  glShadeModel_(#GL_SMOOTH)
EndProcedure


Procedure HandleError (Result, Text$)
  If Result = 0
    MessageRequester("Error", Text$, 0)
    End
  EndIf
EndProcedure

OpenWindow(0, 0, 0, 530, 320, "OpenGL Gadget", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)

OpenGLGadget(0, 10, 10, 200, 200)
SetupGL()

OpenGLGadget(1, 220, 10, 300, 300)
SetupGL()

AddWindowTimer(0, 1, 16) ; about 60 fps

Repeat
  Event = WaitWindowEvent()
  
  Select Event
    Case #PB_Event_Timer
      If EventTimer() = 1
        DrawCube(0)
        DrawCube(1)
      EndIf
  EndSelect
  
Until Event = #PB_Event_CloseWindow
