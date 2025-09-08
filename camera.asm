_initCamera:
    mov         rbx, rdi

    call        GetScreenWidth
    shr         rax, 1
    cvtsi2ss    xmm0, rax

    call        GetScreenHeight
    shr         rax, 1
    cvtsi2ss    xmm1, rax

    movss       [rdi], xmm0
    movss       [rdi + 4], xmm1

    mov         dword [rdi + 20], 0x3fc00000
    ret

_updateCamera:
    movss       xmm0, [rsi + 16]
    movss       [rdi + 8], xmm0
    ret

