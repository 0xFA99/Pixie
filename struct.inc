; ======================
;        Raylib
; ======================
struc Vector2
{
    .x              dd ?
    .y              dd ?
}

struc Rectangle
{
    .x              dd ?
    .y              dd ?
    .width          dd ?
    .height         dd ?
}

struc Texture
{
    .id             dd ?
    .width          dd ?
    .height         dd ?
    .mipmaps        dd ?
    .format         dd ?
}

; ======================
;         Pixie 
; ======================
struc GameWindow
{
    .width          dd ?
    .height         dd ?
    .title          db "Pixie", 0x00
}

struc SpriteSheet
{
    .texture        Texture
    .frames         Rectangle
    .frameCount     dd ?
}
