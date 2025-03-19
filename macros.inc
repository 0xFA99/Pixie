; Make sure allocate 16 bytes first
macro LoadTextureData texture
{
    mov rcx, rsp
    mov rax, [texture]
    mov rdx, [texture + 8]
    mov [rcx], rax
    mov [rcx + 8], rdx
    mov eax, [texture + 16]
    mov [rcx + 16], eax
}

macro AddAnimationState object, state, direction, first, last, FPS
{
    lea rdi, [object]
    mov esi, state
    mov edx, direction
    mov ecx, first
    mov r8d, last
    mov r9d, FPS
    call _AddAnimationState
}

; ==============================================================================
;                              PARALLAX BACKGROUND
; ==============================================================================
macro ScrollingParallax layer, speed
{
    mov eax, speed
    movd xmm1, eax
    movss xmm0, [layer]
    addss xmm0, xmm1
    movss [layer], xmm0
}

macro CheckParallaxLimit layer, scroll, nextLabel, direction
{
    cvtsi2ss xmm0, [layer + 4]
    addss xmm0, xmm0

    if direction eq DIRECTION_LEFT
        mov eax, -0.0
        movd xmm1, eax
        xorps xmm0, xmm1
    end if

    movss xmm1, [scroll]

    if direction eq DIRECTION_LEFT
        comiss xmm0, xmm1
    else
        comiss xmm1, xmm0
    end if

    jb nextLabel

    pxor xmm0, xmm0
    movss [scroll], xmm0
}

; Make sure allocate 16 bytes first
macro DrawParallaxLayer layer, scroll, posY, scale, order
{
    cvtsi2ss xmm0, [layer + 4]

    if order eq BACK
        addss xmm0, xmm0

        mov eax, -0.0
        movd xmm1, eax
        xorps xmm0, xmm1

        movss xmm1, [scroll]
        addss xmm0, xmm1
    else if order eq MIDDLE
        movss xmm0, [scroll]
    else
        addss xmm0, xmm0

        movss xmm1, [scroll]
        addss xmm0, xmm1
    end if

    mov eax, posY
    movd xmm1, eax

    movss [rbp - 4], xmm1
    movss [rbp - 8], xmm0

    ; Texture
    sub rsp, 16
    LoadTextureData layer

    ; Position
    mov rax, [rbp - 8]
    movq xmm0, rax

    ; Rotation
    pxor xmm1, xmm1

    ; Scale
    mov eax, scale
    movd xmm2, eax

    ; Color
    mov edi, -1

    call DrawTextureEx
    add rsp, 16
}

