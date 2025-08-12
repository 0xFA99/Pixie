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

; 20 bytes
struc Texture
{
    .id                     dd 0        ;  4 |  0
    .width                  dd 0        ;  4 |  4
    .height                 dd 0        ;  4 |  8
    .mipmaps                dd 0        ;  4 | 12
    .format                 dd 0        ;  4 | 16
}

; 36 bytes
struc SpriteSheet
{
    .texture                Texture     ; 24 |  0
    .frames                 dq 0        ;  8 | 24 | *Rectangle
    .frameCount             dd 0        ;  4 | 32
}

; 12 bytes
struc AnimSeq
{
    .startFrame             dd 0        ;  4 |  0
    .endFrame               dd 0        ;  4 |  4
    .frameRate              dd 0.0      ;  4 |  8
}

; 2 bytes
struc Status
{
    .state                  db 0        ;  1 |  0
    .direction              db 0        ;  1 |  1
}

; 14 bytes
struc AnimState
{
    .animSeq                AnimSeq     ; 12 |  0
    .status                 Status      ;  2 | 12
}

; 50 bytes
struc SpriteEntity
{
    .sheet                  SpriteSheet ; 36 |  0
    .animStates             dq 0        ;  8 | 36 | *AnimState
    .animStateCount         dd 0        ;  4 | 42
    .frameDuration          dd 0.0      ;  4 | 46
}

; 36 bytes
struc Movement
{
    .position               Vector      ;  8 |  0
    .velocity               Vector      ;  8 |  8
    .acceleration           dd 0.0      ;  4 | 16
    .deceleration           dd 0.0      ;  4 | 20
    .topSpeed               dd 0.0      ;  4 | 24
    .jumpForce              dd 0.0      ;  4 | 28
    .breakThreshold         dd 0.0      ;  4 | 32
}

; 59 bytes (no need to align now)
struc Player
{
    .entity                 dq 0        ;  8 |  0 | *SpriteEntity
    .currentState           dq 0        ;  8 |  8 | *AnimState
    .movement               Movement    ; 36 | 16
    .status                 Status      ;  2 | 52
    .currentFrame           dd 0        ;  4 | 54
    .isGrounded             db 0        ;  1 | 58
}

; 24 bytes
struc Camera
{
    .offset                 Vector      ;  8 |  0
    .target                 Vector      ;  8 |  8
    .rotation               dd 0.0      ;  4 | 16
    .zoom                   dd 0.0      ;  4 | 20
}

