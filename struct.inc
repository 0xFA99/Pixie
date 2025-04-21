struc Vector2
{
    .x                      dd 0.0
    .y                      dd 0.0
}

struc Texture
{
    .id                     dd 0
    .width                  dd 0
    .height                 dd 0
    .mipmaps                dd 0
    .format                 dd 0
}

struc Camera
{
    .offset                 Vector2
    .target                 Vector2
    .rotation               dd 0.0
    .zoom                   dd 0.0
}

struc GameWindow
{
    .width                  dd 0
    .height                 dd 0
}

struc SpriteSheet
{
    .texture                Texture
    .frames                 dq 0        ; Rectangle*
    .frameCount             dd 0
}

struc AnimationSequence
{
    .startFrame             dd 0
    .endFrame               dd 0
    .frameRate              dd 0.0
}

struc Status
{
    .state                  dd 0    ; offset 36
    .direction              dd 0
}

struc AnimationState
{
    .animationSequence      AnimationSequence
    .status                 Status
}

struc SpriteEntity
{
    .spriteSheet            SpriteSheet ; 32 bytes
    .animationStates        dq 0        ; AnimationState*
    .animationStateCount    dd 0
    .frameDuration          dd 0.0
}

struc Movement
{
    .position               Vector2
    .velocity               Vector2
    .acceleration           dd 0.0
    .speed                  dd 0.0
}

struc Player
{
    .entity                 dq 0        ; SpriteEntity*
    .animation              dq 0        ; AnimationState*
    .movement               Movement    ; offset 32
    .status                 Status
    .currentFrame           dd 0
}

struc ParallaxData
{
    .texture            Texture
    .position           Vector2
    .speed              dd 0.0
}

struc Parallax
{
    .data               dq 0
    .count              dd 0
}

