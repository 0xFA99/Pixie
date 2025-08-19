macro callWith object, function
{
    mov         rdi, object
    call        function
}

macro addAsset var, path
{
    var db "assets/", path, 0x0
}

macro addAnimation entity, state, direction, frameStart, frameEnd, fps
{
    mov         rdi, entity
    mov         si, state
    mov         dx, direction
    mov         ecx, frameStart
    mov         r8d, frameEnd
    mov         eax, fps
    movd        xmm8, eax
    call        _addAnimationSprite
}

macro setAnimation object, state, direction
{
    mov         rdi, object
    mov         si, state
    mov         dx, direction
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

