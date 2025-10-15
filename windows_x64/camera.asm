format MS64 COFF

extrn GetScreenWidth
extrn GetScreenHeight

section '.text' code readable executable

public _initCamera
_initCamera:
    push        rbx
    sub         rsp, 48

    mov         rbx, rcx

    call        GetScreenWidth
    shr         rax, 1
    cvtsi2ss    xmm0, rax

    call        GetScreenHeight
    shr         rax, 1
    cvtsi2ss    xmm1, rax

    movss       [rbx], xmm0
    movss       [rbx + 4], xmm1
    mov         dword [rbx + 20], 0x40000000

    add         rsp, 48
    pop         rbx
    ret


