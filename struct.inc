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
; GAME STRUCT -----
struc GameWindow
{
    .width      dd ?
    .height     dd ?
    .title      db "Pixie", 0x00
}

; SPRITE STRUCT -----
struc SpriteSheet
{
    .texture    Texture
    .frames     Rectangle
    .frameCount dd ?
}

struc AnimationSequence
{
    .startFrame dd ?
    .endFrame   dd ?
    .frameRate  dd ?
}

struc AnimationState
{
    .animationSequence  AnimationSequence
    .state      dd ?
    .direction  dd ?
}

struc SpriteEntity
{
    .spriteSheet            SpriteSheet
    .animationState         AnimationState
    .animationStateCount    dd ?
    .frameDuration          dd ?
}

; PLAYER STRUCT -----
struc PlayerMovement
{
    .position       Vector2
    .velocity       Vector2
    .acceleration   dd ?
    .speed          dd ?
}

struc PlayerStatus
{
    .state          dd ?
    .direction      dd ?
}

struc Player
{
    .entity         SpriteEntity
    .animation      AnimationState
    .movement       PlayerMovement
    .status         PlayerStatus
    .currentFrame   dd ?
}

