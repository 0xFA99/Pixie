format MS64 COFF

include 'include/consts.inc'

extrn IsKeyPressed
extrn GetScreenWidth
extrn GetScreenHeight
extrn GetMouseWheelMove

extrn targetZoom

section '.text' code readable executable

; rcx = camera*
public _initCamera
_initCamera:
    push        rbx
    sub         rsp, 32                     ; shadow space

    mov         rbx, rcx                    ; camera*

    call        GetScreenWidth              ; screen width
    shr         rax, 1                      ; screen width / 2
    cvtsi2ss    xmm0, rax                   ; int to float

    call        GetScreenHeight             ; screen height
    shr         rax, 1                      ; screen height / 2
    cvtsi2ss    xmm1, rax                   ; int to float

    movss       [rbx], xmm0                 ; camera.offset.x
    movss       [rbx + 4], xmm1             ; camera.offset.y
    mov         dword [rbx + 20], 0x3fe66666; camera.zoom = 1.8

    add         rsp, 32
    pop         rbx
    ret



public _updateCamera
_updateCamera:
    push        r12
    push        r13
    sub         rsp, 40                     ; 8 padding + 32 shadow space

    mov         r12, rcx
    mov         r13, rdx

    mov         ecx, KEY_C
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

    add         rsp, 40
    pop         r13
    pop         r12
    ret

