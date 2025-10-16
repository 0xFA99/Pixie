
format MS64 COFF

include 'consts.inc'

extrn LoadTexture

section '.text' code readable executable

; rcx = parallax*
; rdx = texture*
; r8d = posY
; xmm3 = speed
public _addParallax
_addParallax:
    push        rbx
    push        r12
    push        r14
    push        r15

    sub         rsp, 40                     ; 8 padding + 32 shadow space

    mov         rbx, rcx                    ; parallax

    mov         r14d, r8d                   ; position.y
    movd        r15d, xmm3                  ; speed

    mov         eax, [rcx + 512]            ; parallax.count
    cmp         eax, PARALLAX_LAYER_CAP
    jge         .done

    shl         rax, 5                      ; sizeof ParallaxData (32)
    lea         rcx, [rbx + rax]            ; parallax[count]
    mov         r12, rcx
    call        LoadTexture

    mov         dword [r12 + 20], 0.0       ; position.x
    mov         [r12 + 24], r14d            ; position.y
    mov         [r12 + 28], r15d            ; speed

    inc         dword [rbx + 512]           ; parallax.count

.done:
    add         rsp, 40
    pop         r15
    pop         r14
    pop         r12
    pop         rbx
    ret
