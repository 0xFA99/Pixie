; rdi = Camera*
; rsi = Player*
public _UpdateCamera
_UpdateCamera:
    push rbp
    mov rbp, rsp

    movss xmm0, [rsi + 16]

    mov rax, [rsi]
    mov rax, [rax + 24]
    movss xmm1, [rax + 8]

    mov eax, 2.0
    movd xmm2, eax

    divss xmm1, xmm2
    addss xmm0, xmm1
    movss [rdi + 8], xmm0

    pop rbp
    ret

