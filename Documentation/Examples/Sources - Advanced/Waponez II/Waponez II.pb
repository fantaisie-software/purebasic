;
; **************
;               *
; Waponez II     **********************************************
;                                                              *
;   Original Waponez is from NC Gamez ! Check it on Aminet...   *
;                                                                *
; *****************************************************************
;

;
; Initialization of all the used resources
;
If InitSprite() = 0 Or InitKeyboard() = 0
  MessageRequester("Error", "Can't initialize GFX card", 0)
  End
EndIf


If InitSound() = 0
  MessageRequester("Error", "Sound card is not available", 0)
  End
EndIf

If InitJoystick()
  EnableJoystick = 1
EndIf

; Game config
;
#ScreenWidth  = 1920
#ScreenHeight = 1080

#PlayerSpeedX = 6
#PlayerSpeedY = 6

#BulletSpeed = 10

#EnemyDelay = 5 ; in ms. The lower the value, the more enemies will be spawn

;
; Our bullet structure, which will be used by the linkedlist Bullet()
;

Structure Bullet
  x.w
  y.w
  Width.w
  Height.w
  Image.w
  SpeedX.w
  SpeedY.w
EndStructure

Global NewList Bullet.Bullet()


Structure Explosion
  x.w
  y.w
  State.w
  Delay.w
EndStructure

Global NewList Explosion.Explosion()


Structure Alien
  x.w
  y.w
  Width.w
  Height.w
  Speed.w
  StartImage.w
  EndImage.w
  ImageDelay.w
  NextImageDelay.w
  ActualImage.w
  Armor.w
EndStructure

Global NewList Aliens.Alien()


Procedure AddBullet(Sprite, x, y, SpeedX, SpeedY)
  AddElement(Bullet())
  Bullet()\x      = x
  Bullet()\y      = y
  Bullet()\Width  = SpriteWidth(Sprite)
  Bullet()\Height = SpriteHeight(Sprite)
  Bullet()\Image  = Sprite
  Bullet()\SpeedX = SpeedX
  Bullet()\SpeedY = SpeedY
EndProcedure
    

MessageRequester("Welcome !", "It was the first game done with PureBasic x86 !"+Chr(10)+"Use the Arrows + Space To blast them all !"+Chr(10)+Chr(10)+"Enjoy !", 0)

Path$ = "Data\"

; SetRefreshRate(60)
If OpenScreen(#ScreenWidth, #ScreenHeight, 32, "Waponez II")
  ;
  ; Load the sound effects
  ;
  LoadSound(0, Path$+"Lazer.wav")
  LoadSound(2, Path$+"Explosion.wav")
    
  ;
  ; Load the player sprites
  ;
  LoadSprite(3, Path$+"Player_1.bmp", #PB_Sprite_PixelCollision)
  LoadSprite(0, Path$+"Player_2.bmp", #PB_Sprite_PixelCollision)
  LoadSprite(2, Path$+"Player_3.bmp", #PB_Sprite_PixelCollision)
 
  ;
  ; Load the bullets
  ;
  LoadSprite( 4, Path$+"Bullet_1.bmp", #PB_Sprite_PixelCollision)
  LoadSprite( 6, Path$+"Bullet_Right.bmp", #PB_Sprite_PixelCollision)
  LoadSprite( 7, Path$+"Bullet_Left.bmp", #PB_Sprite_PixelCollision)
  LoadSprite( 8, Path$+"Bullet_Diag1.bmp", #PB_Sprite_PixelCollision)
  LoadSprite( 9, Path$+"Bullet_Diag2.bmp", #PB_Sprite_PixelCollision)
  LoadSprite(55, Path$+"Bullet_Bottom.bmp", #PB_Sprite_PixelCollision)

  ;
  ; Sprite 10 to 15 reserved for the rotating animated alien..
  ;
  For k=0 To 5
    LoadSprite(k+10, Path$+"Ennemy_3_"+Str(k+1)+".bmp", #PB_Sprite_PixelCollision)
  Next
 
  ;
  ; Sprite 20 to 30 reserved for the explosions...
  ;
  For k=0 To 7
    LoadSprite(k+20, Path$+"Explosion_"+Str(k+1)+".bmp", #PB_Sprite_PixelCollision)
  Next
    
  ;
  ; Load the background sprite
  ;
  LoadSprite(20, Path$+"Back_3.bmp", 0)
  
  PlayerWidth  = SpriteWidth(3)
  PlayerHeight = SpriteHeight(3)
  PlayerX = (#ScreenWidth-PlayerWidth) / 2
  PlayerY = #ScreenHeight-80

  Repeat
    FlipBuffers() ; This should be always in the loop, the events are handle by this functions
          
    If IsScreenActive() ; Check if is active or not (ALT+TAB symptom :)
      db = 1-db
      
      ; Draw the background (an unified one...)
      
      For BackX=0 To #ScreenWidth Step 32
        For BackY=-32 To #ScreenHeight Step 32
          DisplaySprite(20, BackX, BackY+ScrollY)
        Next
      Next
      
      Gosub CheckCollisions

      Gosub MovePlayers
      
      Gosub DisplayBullets
      
      Gosub NewAlienWave
     
      Gosub DisplayAliens
      
      Gosub DisplayExplosions

      If BulletDelay > 0
        BulletDelay-1
      EndIf

      If ScrollDelay = 0
        ScrollY+1
        ScrollDelay = 0
      Else
        ScrollDelay-1
      EndIf
      
      If ScrollY>31
        ScrollY = 0
      EndIf
      
    Else
          ; The screen is no more active but our game multitask friendly, so we stop the sounds and
          ; add a delay to not eat the whole CPU. Smart hey ? :)
          
      StopSound(-1)
      Delay(20)
    EndIf
        
  Until KeyboardPushed(#PB_Key_Escape)
Else
  MessageRequester("Waponez II", "Can't open a #ScreenWidth*#ScreenHeight 32-bit screen !", 0)
EndIf

End


MovePlayers:
  Fire = 0
  PlayerImage = 3  ; Non-moving player image

  If EnableJoystick
    If ExamineJoystick(0)
    
      PlayerX+JoystickAxisX(0)*#PlayerSpeedX
      PlayerY+JoystickAxisY(0)*#PlayerSpeedY

      If JoystickAxisX(0) = 1
        PlayerImage = 0
      EndIf
      
      If JoystickAxisX(0) = -1
        PlayerImage = 2
      EndIf
      
      ; All buttons works to fire the aLiEnZ !
      ;
      If JoystickButton(0, 1) Or JoystickButton(0, 2) Or JoystickButton(0, 3) Or JoystickButton(0, 4)
        Fire = 1
      EndIf
   
    EndIf
  EndIf

  ExamineKeyboard()
     
  If KeyboardPushed(#PB_Key_Left)
    PlayerX-#PlayerSpeedX
    PlayerImage = 2  ; Left moving player image
  EndIf
  
  If KeyboardPushed(#PB_Key_Right)
    PlayerX+#PlayerSpeedX
    PlayerImage = 0  ; Right moving player image
  EndIf
  
  If KeyboardPushed(#PB_Key_Up)
    PlayerY-#PlayerSpeedY
  EndIf
  
  If KeyboardPushed(#PB_Key_Down)
    PlayerY+#PlayerSpeedY
  EndIf

  If PlayerX < 0 : PlayerX = 0 : EndIf
  If PlayerY < 0 : PlayerY = 0 : EndIf

  If PlayerX > #ScreenWidth-PlayerWidth  : PlayerX = #ScreenWidth-PlayerWidth : EndIf
  If PlayerY > #ScreenHeight-PlayerHeight : PlayerY = #ScreenHeight-PlayerHeight : EndIf

 
  If Dead = 1
    AddElement(Explosion())
    Explosion()\x = PlayerX
    Explosion()\y = PlayerY

    Dead = 0
  Else
    If DeadDelay>0
      DeadDelay-1
      If db=1
        If DeadDelay < 200
          DisplayTransparentSprite(PlayerImage, PlayerX, PlayerY)
        EndIf
      EndIf
    Else
      DisplayTransparentSprite(PlayerImage, PlayerX, PlayerY)
    EndIf
  EndIf
  
    
  If KeyboardPushed(#PB_Key_Space) Or Fire
    If BulletDelay = 0
      If DeadDelay < 100
        BulletDelay = 10

        ; AddBullet() syntax: (#Sprite, x, y, SpeedX, SpeedY)
        ;
        AddBullet(4, PlayerX+5 , PlayerY-10,  0          , -#BulletSpeed) ; Front bullet (Double bullet sprite)
        AddBullet(6, PlayerX+45, PlayerY+6 ,  #BulletSpeed, 0)            ; Right side bullet
        AddBullet(7, PlayerX-11, PlayerY+6 , -#BulletSpeed, 0)            ; Left side bullet
        AddBullet(8, PlayerX+45, PlayerY-6 ,  #BulletSpeed, -#BulletSpeed) ; Front-Right bullet
        AddBullet(9, PlayerX-11, PlayerY-6 , -#BulletSpeed, -#BulletSpeed) ; Front-Left bullet
        AddBullet(55,PlayerX+20, PlayerY+45,  0          ,  #BulletSpeed) ; Rear bullet
     
        ;PlaySound(0, 0)    ; Play the 'pffffiiiouuu' laser like sound
      EndIf
    EndIf
  EndIf

Return


DisplayBullets:
  
  ResetList(Bullet())
  While NextElement(Bullet())  ; Process all the bullet actually displayed on the screen

    If Bullet()\y < 0          ; If a bullet is now out of the screen, simply delete it..
      DeleteElement(Bullet())
    Else
      If Bullet()\x < 0        ; If a bullet is now out of the screen, simply delete it..
        DeleteElement(Bullet())
      Else
        If Bullet()\x > #ScreenWidth-Bullet()\Width
          DeleteElement(Bullet())
        Else
          If Bullet()\y > #ScreenHeight
            DeleteElement(Bullet())
          Else
            DisplayTransparentSprite(Bullet()\Image, Bullet()\x, Bullet()\y)   ; Display the bullet..

            Bullet()\y + Bullet()\SpeedY
            Bullet()\x + Bullet()\SpeedX
          EndIf
        EndIf
      EndIf
    EndIf
    
  Wend

Return


NewAlienWave:

  If AlienDelay = 0

    AddElement(Aliens())

    Aliens()\x = Random(#ScreenWidth-40)
    Aliens()\y = -32
    Aliens()\Width  = SpriteWidth(10)
    Aliens()\Height = SpriteHeight(10)
    Aliens()\Speed  = 3
    Aliens()\StartImage  = 10
    Aliens()\EndImage    = 15
    Aliens()\ImageDelay  =  4
    Aliens()\NextImageDelay = Aliens()\ImageDelay
    Aliens()\ActualImage = 10
    Aliens()\Armor = 5
    
    AlienDelay = Random(#EnemyDelay)
  Else
    AlienDelay-1
  EndIf

Return


DisplayAliens:

  ResetList(Aliens())
  While NextElement(Aliens())

    DisplayTransparentSprite(Aliens()\ActualImage, Aliens()\x, Aliens()\y)

    Aliens()\y + Aliens()\Speed

    If Aliens()\NextImageDelay = 0
 
      Aliens()\ActualImage+1

      If Aliens()\ActualImage > Aliens()\EndImage
        Aliens()\ActualImage = Aliens()\StartImage
      EndIf

      Aliens()\NextImageDelay = Aliens()\ImageDelay
    Else
      Aliens()\NextImageDelay-1
    EndIf

    If Aliens()\Armor <= 0
      AddElement(Explosion())
      Explosion()\x = Aliens()\x
      Explosion()\y = Aliens()\y

      Score+20
      DeleteElement(Aliens())
    Else
      If Aliens()\y > #ScreenHeight
        DeleteElement(Aliens())
      EndIf
    EndIf
    
  Wend
Return


CheckCollisions:

  ResetList(Aliens())
  While NextElement(Aliens())
    ResetList(Bullet())
    While NextElement(Bullet())
    
      If SpritePixelCollision(Bullet()\Image, Bullet()\x, Bullet()\y, Aliens()\ActualImage, Aliens()\x, Aliens()\y)
        Aliens()\Armor-1
        DeleteElement(Bullet())
      EndIf
      
    Wend

    If DeadDelay = 0 ; No more invincible...
      If SpritePixelCollision(PlayerImage, PlayerX, PlayerY, Aliens()\ActualImage, Aliens()\x, Aliens()\y)
        Dead = 1
        DeadDelay = 300

        AddElement(Explosion())
        Explosion()\x = Aliens()\x
        Explosion()\y = Aliens()\y

        DeleteElement(Aliens())
      EndIf
    EndIf
  
  Wend
Return


; DisplayExplosion:
; -----------------
;
; Once an explosion has been declared (an aliens has been destroyed or the player...), it will be
; displayed inside this routine. The object remains until the end of the explosion (all the pictures
; have been displayed). Then the object is removed with DeleteElement().
;

DisplayExplosions:

  ResetList(Explosion())
  While NextElement(Explosion())   ; Take the explosions objects, one by one.

    ; For each object, display the current explosion image (called state here)
    
    DisplayTransparentSprite(Explosion()\State+20, Explosion()\x, Explosion()\y)

    If Explosion()\Delay = 0
      If Explosion()\State = 0  ; Play the sound only at the explosion start.
        ;PlaySound(2, 0)
      EndIf

      If Explosion()\State < 7
        Explosion()\State+1
        Explosion()\Delay = 3
      Else
        DeleteElement(Explosion())
      EndIf
    Else
      Explosion()\Delay-1
    EndIf
  Wend

Return