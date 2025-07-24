; Struct size                           | size | offset | pointer

; 8 bytes
struc Vector
{
    .x                      dd 0.0      ;  4 |  0
    .y                      dd 0.0      ;  4 |  4
}

struc Rectangle
{
    .x                      dd 0.0
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

; 32 bytes
struc SpriteEntity
{
    .sheet                  SpriteSheet ; 32 | 0
}

; 8 bytes
struc Movement
{
    .position               Vector      ;  8 |  0
}

; 12 bytes
struc Player
{
    .entity                 dq 0        ;  8 |  0 | *SpriteEntity
    .movement               Movement    ;  8 |  8
    .currentFrame           dd 0        ;  4 |  16
}

; 24 bytes
struc Camera
{
    .offset                 Vector      ;  8 |  0
    .target                 Vector      ;  8 |  8
    .rotation               dd 0.0      ;  4 | 16
    .zoom                   dd 0.0      ;  4 | 20
}

