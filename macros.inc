macro addAsset var, path
{
    var db "assets/", path, 0x0
}

macro addParallax parallax, texture, posX, posY, speed
{
    mov         rdi, parallax
    mov         rsi, texture
    mov         edx, posX
    mov         ecx, posY
    mov         eax, speed
    movd        xmm8, eax
    call        _addParallax
}

macro addAnimation entity, state, direction, frameStart, frameEnd, fps
{
    mov         rdi, entity
    mov         rsi, state
    mov         rdx, direction
    mov         rcx, frameStart
    mov         r8d, frameEnd
    mov         eax, fps
    movd        xmm8, eax
    call        _addAnimationSprite
}

macro setAnimation object, state, direction
{
    mov         rdi, object
    mov         rsi, state
    mov         rdx, direction
    call        _setAnimationSprite
}

macro clampss reg, min, max
{
    minss       reg, max
    maxss       reg, min
}

macro fabsf reg
{
    mov         eax, MASK_ABS               ; 0x80000000
    movd        xmm8, eax
    andps       reg, xmm8
}

