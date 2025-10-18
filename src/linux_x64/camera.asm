
format ELF64

include 'include/consts.inc'

extrn GetScreenWidth
extrn GetScreenHeight
extrn IsKeyPressed

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

    sub         rsp, 40                     ; 8 padding + 32
    movdqa      [rsp], xmm8
    movdqa      [rsp + 16], xmm9

    mov         r12, rdi                    ; camera
    mov         r13, rsi                    ; player
    movss       xmm9, [r12 + 20]            ; camera.zoom

    mov         eax, 0x3dcccccd             ; 1.0
    movd        xmm8, eax

    mov         edi, KEY_Z
    call        IsKeyPressed
    test        al, al
    jz          .checkX

    addss       xmm9, xmm8                  ; camera.zoom += 1.0

.checkX:
    mov         edi, KEY_X
    call        IsKeyPressed
    test        al, al
    jz          .checkC

    subss       xmm9, xmm8                  ; camera.zoom -= 1.0

.checkC:
    mov         edi, KEY_C
    call        IsKeyPressed
    test        al, al
    jz          .done

    mov         eax, 0x3fe66666             ; 1.8
    movd        xmm9, eax                   ; camera.zoom

.done:
    movss       [r12 + 20], xmm9            ; camera.zoom

    movsd       xmm0, [r13 + 16]            ; player.position {x, y}
    movsd       [r12 + 8], xmm0             ; camera.target {x, y}

    movdqa      xmm9, [rsp + 16]
    movdqa      xmm8, [rsp]
    add         rsp, 40                     ; 8 padding + 32

    pop         r13
    pop         r12
    ret



section '.note.GNU-stack'

