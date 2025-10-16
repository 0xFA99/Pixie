format MS64 COFF

include 'consts.inc'

extrn IsKeyPressed
extrn GetScreenWidth
extrn GetScreenHeight

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
    mov         dword [rbx + 20], 0x40000000; camera.zoom = 2.0

    add         rsp, 32
    pop         rbx
    ret


public _updateCamera
_updateCamera:
    push        r12
    push        r13

    sub         rsp, 40
    movdqa      [rsp], xmm6
    movdqa      [rsp + 16], xmm7

    sub         rsp, 32

    mov         r12, rcx                    ; camera
    mov         r13, rdx                    ; player

    movss       xmm7, [r12 + 20]            ; camera.zoom
    mov         eax, 0x3dcccccd             ; 1.0
    movd        xmm6, eax

    mov         ecx, KEY_Z
    call        IsKeyPressed
    test        al, al
    jz          .checkX

    addss       xmm7, xmm6                  ; camera.zoom += 1.0

.checkX:
    mov         ecx, KEY_X
    call        IsKeyPressed
    test        al, al
    jz          .checkC

    subss       xmm7, xmm6                  ; camera.zoom -= 1.0

.checkC:
    mov         ecx, KEY_C
    call        IsKeyPressed
    test        al, al
    jz          .done

    mov         eax, 0x40000000             ; 2.0
    movd        xmm7, eax

.done:
    movss       [r12 + 20], xmm7            ; camera.zoom

    movsd       xmm0, [r13 + 16]            ; player.position {x, y}
    movsd       [r12 + 8], xmm0             ; camera.target {x, y}

    add         rsp, 32

    movdqa      xmm7, [rsp + 16]
    movdqa      xmm6, [rsp]
    add         rsp, 40

    pop         r13
    pop         r12
    ret

