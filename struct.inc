; Struct size                           | size | offset | pointer

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

struc SpriteEntity
{
    .sheet                  SpriteSheet ; 32 | 0
}

struc Player
{
    .entity                 dq 0        ;  8 |  0 | *SpriteEntity
}

