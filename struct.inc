; Struct size                           | size | offset | pointer

; 8 bytes
struc Vector
{
    .x                      dd 0.0      ;  4 |  0
    .y                      dd 0.0      ;  4 |  4
}

; 16 bytes
struc Rectangle
{
    .position               Vector      ;  8 |  0
    .width                  dd 0.0      ;  4 |  8
    .height                 dd 0.0      ;  4 | 12
}

; 24 bytes
struc Texture
{
    .id                     dd 0        ;  4 |  0
    .width                  dd 0        ;  4 |  4
    .height                 dd 0        ;  4 |  8
    .mipmaps                dd 0        ;  4 | 12
    .format                 dd 0        ;  4 | 16
    .padding                dd 0        ;  4 | 20
}

; 40 bytes
struc SpriteSheet
{
    .texture                Texture     ; 24 |  0
    .frames                 dq 0        ;  8 | 24 | *Rectangle
    .frameCount             dd 0        ;  4 | 32
    .padding                dd 0        ;  4 | 36
}

; 16 bytes
struc AnimSeq
{
    .startFrame             dd 0        ;  4 |  0
    .endFrame               dd 0        ;  4 |  4
    .frameRate              dd 0.0      ;  4 |  8
    .padding                dd 0        ;  4 | 12
}

; 8 bytes
struc Status
{
    .state                  dd 0        ;  4 |  0
    .direction              dd 0        ;  4 |  4
}

; 32 bytes
struc AnimState
{
    .animSeq                AnimSeq     ; 16 |  0
    .status                 Status      ;  8 | 16
    .padding                dq 0        ;  8 | 24 | NULL
}

; 56 bytes
struc SpriteEntity
{
    .sheet                  SpriteSheet ; 40 |  0
    .animStates             dq 0        ;  8 | 40 | *AnimState
    .animStateCount         dd 0        ;  4 | 48
    .frameDuration          dd 0.0      ;  4 | 52
}

; 32 bytes
struc Movement
{
    .position               Vector      ;  8 |  0
    .velocity               Vector      ;  8 |  8
    .acceleration           dd 0.0      ;  4 | 16
    .deceleration           dd 0.0      ;  4 | 20
    .topSpeed               dd 0.0      ;  4 | 24
    .jumpStr                dd 0.0      ;  4 | 28
}

; 64 bytes
struc Player
{
    .entity                 dq 0        ;  8 |  0 | *SpriteEntity
    .currentState           dq 0        ;  8 |  8 | *AnimState
    .movement               Movement    ; 32 | 16
    .status                 Status      ;  8 | 48
    .currentFrame           dd 0        ;  4 | 56
    .isGrounded             db 0        ;  1 | 60
    .padding                db 3        ;  3 | 61
}

; 24 bytes
struc Camera
{
    .offset                 Vector      ;  8 |  0
    .target                 Vector      ;  8 |  8
    .rotation               dd 0.0      ;  4 | 16
    .zoom                   dd 0.0      ;  4 | 20
}

