macro callWith object, function
{
    mov rdi, object
    call function
}

macro addAsset var, path
{
    var db "assets/", path, 0x0
}

macro addAnimation entity, state, direction, frameStart, frameEnd, fps
{
    mov rdi, entity
    mov esi, state
    mov edx, direction
    mov ecx, frameStart
    mov r8d, frameEnd

    mov eax, fps
    movd xmm0, eax

    call _addAnimationSprite
}

macro setAnimation object, state, direction
{
    mov rdi, object
    mov esi, state
    mov edx, direction
    call _setAnimationSprite
}

