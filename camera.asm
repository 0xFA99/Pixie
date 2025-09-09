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

    mov         dword [rdi + 20], 0x40000000
    ret

_updateCamera:
    mov         r12, rdi                    ; camera
    mov         r13, rsi                    ; player

    mov         eax, 0x3dcccccd
    movd        xmm8, eax

    movss       xmm9, [r12 + 20]

    mov         edi, KEY_Z
    call        IsKeyPressed
    test        al, al
    jz          .checkZoomOut

    addss       xmm9, xmm8

.checkZoomOut:
    mov         edi, KEY_X
    call        IsKeyPressed
    test        al, al
    jz          .checkReset
    subss       xmm9, xmm8

.checkReset:
    mov         edi, KEY_C
    call        IsKeyPressed
    test        al, al
    jz          .updateTarget

    mov         eax, 0x40000000
    movd        xmm9, eax

.updateTarget:
    movss       [r12 + 20], xmm9

    movsd       xmm0, [r13 + 16]
    movsd       [r12 + 8], xmm0
    ret

