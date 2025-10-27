
format ELF64

include 'include/consts.inc'

extrn GetScreenWidth
extrn GetScreenHeight
extrn GetMouseWheelMove
extrn IsKeyPressed
extrn targetZoom

section '.text' executable

public _initCamera
_initCamera:
    push        rbx

    mov         rbx, rdi                    ; camera

    call        GetScreenWidth
    shr         rax, 1
    cvtsi2ss    xmm0, rax                   ; xmm0 = screenWidth / 2.0

    call        GetScreenHeight
    shr         rax, 1
    cvtsi2ss    xmm1, rax                   ; xmm1 = screenHeight / 2.0

    movss       [rbx], xmm0
    movss       [rbx + 4], xmm1
    mov         dword [rbx + 20], 0x3fe66666

    pop         rbx
    ret



public _updateCamera
_updateCamera:
    push        r12
    push        r13
    sub         rsp, 8

    mov         r12, rdi
    mov         r13, rsi

    mov         edi, KEY_C
    call        IsKeyPressed
    test        al, al
    jz          .checkMouseScroll

    mov         dword [targetZoom], 0x3fe66666
    jmp         .apply

.checkMouseScroll:
    call        GetMouseWheelMove
    pxor        xmm1, xmm1
    comiss      xmm0, xmm1
    je          .apply

    mov         eax, 0x3dcccccd
    movd        xmm2, eax
    movd        xmm3, eax

    mulss       xmm0, xmm2
    addss       xmm0, [targetZoom]

    maxss       xmm0, xmm3
    mov         eax, 0x40a00000
    movd        xmm4, eax
    minss       xmm0, xmm4

    movss       [targetZoom], xmm0

.apply:
    movss       xmm0, [targetZoom]
    movss       xmm1, [r12 + 20]
    mov         eax, 0x3d4ccccd
    movd        xmm2, eax

    subss       xmm0, xmm1
    mulss       xmm0, xmm2
    addss       xmm0, xmm1
    movss       [r12 + 20], xmm0

    movsd       xmm0, [r13 + 16]
    movsd       [r12 + 8], xmm0

    add         rsp, 8
    pop         r13
    pop         r12
    ret



section '.note.GNU-stack'

