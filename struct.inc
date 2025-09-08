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

; 32 bytes
struc SpriteSheet
{
    .texture                Texture     ; 20 |  0
    .frames                 dq 0        ;  8 | 20 | *Rectangle
    .frameCount             dd 0        ;  4 | 28
}

; 12 bytes
struc AnimSeq
{
    .startFrame             dd 0        ;  4 |  0
    .endFrame               dd 0        ;  4 |  4
    .frameRate              dd 0.0      ;  4 |  8
}

; 4 bytes
struc Status
{
    .state                  dw 0        ;  2 |  0
    .direction              dw 0        ;  2 |  2
}

; 16 bytes
struc AnimState
{
    .animSeq                AnimSeq     ; 12 |  0
    .status                 Status      ;  4 | 12
}

; 424 bytes
struc SpriteEntity
{
    .sheet                  SpriteSheet                     ;  32 |   0
    .animationStates        db ANIMATION_STATES_CAP * 16    ; 256 |  32
    .animationLookUp        dq ANIMATION_LOOKUP_CAP * 2     ; 128 | 288
    .animationCount         dd 0                            ;   4 | 416
    .frameDuration          dd 0.0                          ;   4 | 420
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

; 61 bytes (no need to align for now :P)
struc Player
{
    .entity                 dq 0        ;  8 |  0 | *SpriteEntity
    .currentState           dq 0        ;  8 |  8 | *AnimState
    .movement               Movement    ; 36 | 16
    .status                 Status      ;  4 | 52
    .currentFrame           dd 0        ;  4 | 56
    .isGrounded             db 0        ;  1 | 60
}

; 24 bytes
struc Camera
{
    .offset                 Vector      ;  8 |  0
    .target                 Vector      ;  8 |  8
    .rotation               dd 0.0      ;  4 | 16
    .zoom                   dd 0.0      ;  4 | 20
}

; 32 bytes
struc ParallaxData
{
    .texture                Texture     ; 20 |  0
    .position               Vector      ;  8 | 20
    .speed                  dd 0.0      ;  4 | 28
}

; 516 bytes
struc Parallax
{
    .data                   dq PARALLAX_LAYER_CAP * 32 ; 512 |  0
    .count                  dd 0        ;  4 | 512
}

