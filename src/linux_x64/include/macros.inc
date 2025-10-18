
extrn BeginScissorMode
extrn EndScissorMode
extrn BeginMode2D
extrn EndMode2D

extrn _addSpriteAnimation
extrn _setSpriteAnimation
extrn _addParallax


macro addAsset var*, path*
{
    var db "assets/", path, 0x0
}

macro addParallax parallax*, texture*, posY*, speed*
{
    mov         rdi, parallax
    mov         rsi, texture
    mov         edx, posY
    mov         eax, speed
    movd        xmm0, eax
    call        _addParallax
}

macro addSpriteAnimation object*, state*, direction*, frameStart*, frameEnd*, fps*
{
    mov         rdi, object
    mov         si, state
    mov         dx, direction
    mov         ecx, frameStart
    mov         r8d, frameEnd
    mov         eax, fps
    movd        xmm0, eax
    call        _addSpriteAnimation
}

macro setSpriteAnimation object*, state*, direction*
{
    mov         rdi, object
    mov         si, state
    mov         dx, direction
    call        _setSpriteAnimation
}

macro startCamera camera*
{
    sub         rsp, 32                     ; 24 camera + 8 padding
    movaps      xmm0, [camera]              ; offset(x, y), target(x, y)
    mov         rax, [camera + 16]          ; rotation, zoom
    movaps      [rsp], xmm0
    mov         [rsp + 16], rax
    call        BeginMode2D
    add         rsp, 32
}

macro endCamera
{
    call        EndMode2D
}

macro startScissorMode x, y, width, height
{
    ; mov         edi, 20
    ; mov         esi, 20
    ; mov         edx, [screenWidth]
    ; mov         ecx, [screenHeight]
    ; lea         edx, [edx - 40]
    ; lea         ecx, [ecx - 40]

    xor         edi, edi
    xor         esi, esi
    mov         edx, [screenWidth]
    mov         ecx, [screenHeight]
    call        BeginScissorMode
}

macro endScissorMode
{
    call        EndScissorMode
}

