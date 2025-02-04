    ; Update Camera
    movsd xmm0, [playerPosition]

    mov rax, [spriteSheet.frames]
    movsd xmm1, [rax + 8]

    mov eax, 0x40000000
    movd xmm2, eax
    shufps xmm2, xmm2, 0
    divps xmm1, xmm2

    addps xmm0, xmm1

    movsd [camera2D.target], xmm0

