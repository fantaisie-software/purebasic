
; ------------------------------------------------------------
;
;   PureBasic - Water
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------

;#################################################################################################################

#end_distance=1024*4

Procedure ColorBlend(color1.l, color2.l, blend.f)
  Protected r.w,g.w,b.w,a.w
  r=  Red(color1) + (Red(color2)     - Red(color1)) * blend
  g=Green(color1) + (Green(color2) - Green(color1)) * blend
  b= Blue(color1) + (Blue(color2) -   Blue(color1)) * blend
  a=Alpha(color1) + (Alpha(color2) - Alpha(color1)) * blend
  ProcedureReturn  RGBA(r,g,b,a)
EndProcedure

InitEngine3D():InitSprite():InitKeyboard():InitMouse()

ExamineDesktops():dx=DesktopWidth(0)*0.9:dy=DesktopHeight(0)*0.9
OpenWindow(0, 0,0, DesktopUnscaledX(dx),DesktopUnscaledY(dy), " Water - [F12] Wireframe  [Esc] quit",#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, dx, dy, 0, 0, 0)
InitScreenGadgets()

Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
Parse3DScripts()

CreateCamera(0, 0, 0, 100, 100):MoveCamera(0,0,5,0):CameraLookAt(0,2,5,10)

;sky
tx_sky=LoadTexture(#PB_Any,"sky.png")
SkyDome(TextureID(tx_sky),$cc6600,$0088ff,3,400,-0.5,0)

;ocean
tx_water=LoadTexture(#PB_Any,"waternormal.png")
tx_foam=LoadTexture(#PB_Any,"foam.png")
CreateWater(TextureID(tx_water),TextureID(tx_foam),    $cc888800,$886666,  #end_distance,    1.5,1.5,0.0,0.7)

;ground
tx_ground=LoadTexture(#PB_Any,"Dirt.jpg")
CreateMaterial(2,TextureID(tx_ground))
CreatePlane(2,#end_distance*2,#end_distance*2,16,16,#end_distance/64,#end_distance/64)
CreateEntity(2,MeshID(2),MaterialID(2),0,-7,0)

;GUI
TextScreenGadget(-1,8,y,200,24,"wave big"   ):y+24:TrackBarScreenGadget(1,8,y,256,16,0,10):SetScreenGadgetState(1,5):y+24
TextScreenGadget(-1,8,y,200,24,"wave litlle"):y+24:TrackBarScreenGadget(2,8,y,256,16,0,10):SetScreenGadgetState(2,5):y+24
TextScreenGadget(-1,8,y,200,24,"Sweell"     ):y+24:TrackBarScreenGadget(3,8,y,256,16,0,10):SetScreenGadgetState(3,2):y+24
TextScreenGadget(-1,8,y,200,24,"Foam"       ):y+24:TrackBarScreenGadget(4,8,y,256,16,0,10):SetScreenGadgetState(4,7):y+48
TextScreenGadget(-1,8,y,200,24,"Sun height" ):y+24:TrackBarScreenGadget(5,8,y,256,16,0,20):SetScreenGadgetState(5,20)


Procedure CameraUserControl(camera,speed.f=0.2,smooth.f=0.1,yfixed.f=1e10)
  Static.f MouseX,Mousey,depx,depz,sdepx,sdepz
  
  depx=-speed*(KeyboardPushed(#PB_Key_Left)-KeyboardPushed(#PB_Key_Right))
  depz=-speed*(KeyboardPushed(#PB_Key_Down)-KeyboardPushed(#PB_Key_Up)-MouseWheel()*20)
  MouseX = -MouseDeltaX() *  0.05
  MouseY = -MouseDeltaY() *  0.05
  RotateCamera(camera, MouseY, MouseX, 0, #PB_Relative)
  sdepx+(depx-sdepx)*smooth
  sdepz+(depz-sdepz)*smooth
  MoveCamera  (camera, sdepX, 0, -sdepz)
  If yfixed<>1e10:MoveCamera(camera,CameraX(camera),yfixed,CameraZ(camera),#PB_Absolute):EndIf
EndProcedure

Define.f r=1,rr
Repeat
  While WindowEvent():Wend
  ExamineKeyboard()
  ExamineMouse()
  If KeyboardReleased(#PB_Key_F12):fdf=1-fdf:If fdf:CameraRenderMode(0,#PB_Camera_Wireframe):Else:CameraRenderMode(0,#PB_Camera_Textured):EndIf:EndIf
  
  CameraUserControl(0,0.2,0.1)
  
  SetWorldAttribute(#PB_Water_WaveHeight,GetScreenGadgetState(1)*3/10)
  SetWorldAttribute(#PB_Water_WaveSmall,GetScreenGadgetState(2)*3/10)
  SetWorldAttribute(#PB_Water_Swell,GetScreenGadgetState(3)*1/10)
  SetWorldAttribute(#PB_Water_Foam,GetScreenGadgetState(4)*1/10)
  
  ; sun height
  r=GetScreenGadgetState(5)/20:rr=Pow(r,0.25)
  CreateLight(0,ColorBlend($0088ff,$ffffff,rr),20000, r*40000,20000)
  AmbientColor($010101*Int(r*48+64))
  Fog(ColorBlend($004488,$ffccaa,r),1,0,#end_distance)
  
  RenderWorld()
  RenderScreenGadgets()
  FlipBuffers()    
Until KeyboardReleased(#PB_Key_Escape) Or MouseButton(3)
