; RAYLIB
struc Vector2
{
    .x dd ?
    .y dd ?
}

struc Rectangle
{
    .x          dd ?
    .y          dd ?
    .width      dd ?
    .height     dd ?
}

struc Texture
{
    .id         dd ?
    .width      dd ?
    .height     dd ?
    .mipmaps    dd ?
    .format     dd ?
}

struc Camera2D
{
    .offset     Vector2
    .target     Vector2
    .rotation   dd ?
    .zoom       dd ?
}

; PIXIE
struc GameWindow
{
    .width      dd ?
    .height     dd ?
    .title      db "Pixie", 0x00
}

struc SpriteSheet
{
    .texture    Texture
    .frames     Rectangle
    .frameCount dd ?
}

