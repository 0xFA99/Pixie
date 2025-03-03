; ======================
;        Raylib
; ======================
struc Vector2
{
    .x                      dd ?
    .y                      dd ?
}

struc Rectangle
{
    .x                      dd ?
    .y                      dd ?
    .width                  dd ?
    .height                 dd ?
}

struc Texture
{
    .id                     dd ?
    .width                  dd ?
    .height                 dd ?
    .mipmaps                dd ?
    .format                 dd ?
}

; ======================
;         Pixie 
; ======================
struc GameWindow
{
    .width                  dd ?
    .height                 dd ?
    .title                  db "Pixie", 0x00
}

struc SpriteSheet
{
    .texture                Texture
    .frames                 Rectangle
    .frameCount             dd ?
}

struc AnimationSequence
{
    .startFrame             dd ?
    .endFrame               dd ?
    .frameRate              dd ?
}

struc AnimationState
{
    .animationSequence      AnimationSequence
    .state                  dd ?
    .direction              dd ?
}

struc SpriteEntity
{
    .spriteSheet            SpriteSheet
    .animationState         AnimationState
    .animationStateCount    dd ?
    .frameDuration          dd ?
}

struc Movement
{
    .position               Vector2
    .velocity               Vector2
    .acceleration           dd ?
    .speed                  dd ?
}

struc Status
{
    .state                  dd ?
    .direction              dd ?
}

struc Player
{
    .entity                 SpriteEntity
    .animation              AnimationState
    .movement               Movement
    .status                 Status
    .currentFrame           dd ?
}

