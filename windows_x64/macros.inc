
macro addSpriteAnimation object*, state*, direction*, frameStart*, frameEnd*, fps*
{
    sub         rsp, 16
    mov         rcx, object
    mov         dx, state
    mov         r8w, direction
    mov         r9d, frameStart
    mov         dword [rsp + 32], frameEnd
    mov         dword [rsp + 40], fps
    call        _addSpriteAnimation
    add         rsp, 16
}


macro setSpriteAnimation object*, state*, direction*
{
    mov         rcx, object
    mov         dx, state
    mov         r8w, direction
    call        _setSpriteAnimation
}

