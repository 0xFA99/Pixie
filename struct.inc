struc Vector2
{
    .x dd ?
    .y dd ?
}

struc Rectangle
{
    .x dd ?
    .y dd ?
    .width dd ?
    .height dd ?
}

struc Player
{
    .position   Vector2
    .speed      dd ?
    .canJump    db ?
}

struc Camera2D
{
    .offset     Vector2
    .target     Vector2
    .rotation   dd ?
    .zoom       dd ?
}

struc Image
{
    .data       dq ?
    .width      dd ?
    .height     dd ?
    .mipmaps    dd ?
    .format     dd ?
}

struc Texture2D
{
    .id         dd ?
    .width      dd ?
    .height     dd ?
    .mipmaps    dd ?
    .format     dd ?
}

