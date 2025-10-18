
format MS64 COFF

include 'consts.inc'

extrn LoadTexture
extrn DrawTextureEx

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


public _renderParallax
_renderParallax:
    push        rbx
    push        r12
    push        r13
    push        r14
    sub         rsp, 72
    movdqa      [rsp], xmm6
    movdqa      [rsp + 16], xmm7
    movdqa      [rsp + 32], xmm8
    movdqa      [rsp + 48], xmm9

    sub         rsp, 80

    mov         rbx, rcx                    ; parallax*

    xor         r12d, r12d                  ; index = 0
    mov         r13d, [rcx + 512]           ; parallax.count

    mov         dword [rsp + 32], -1        ; white (0xFFFFFFFF)

    mov         dword [rsp + 36], 1.0       ; scale

.loop:
    mov         eax, r12d                   ; index
    shl         rax, 5                      ; sizeof ParallaxData (52)
    lea         r14, [rbx + rax]            ; parallax.base + offset

    movaps      xmm0, [r14]                 ; texture {id, w, h, f}
    mov         eax, [r14 + 16]             ; texture.mipmaps
    movaps      [rsp + 48], xmm0
    mov         [rsp + 64], eax

    mov         eax, [r14 + 4]              ; parallax.width
    cvtsi2ss    xmm6, eax
    sar         eax, 1
    cvtsi2ss    xmm7, eax                   ; parallax.width / 2.0

    movq        xmm0, [r14 + 20]            ; parallax.position {x, y}

    subss       xmm0, xmm7
    movaps      xmm9, xmm0

    ; back
    movaps      xmm0, xmm9
    subss       xmm0, xmm6

    movss       xmm3, [rsp + 36]            ; scale
    pxor        xmm2, xmm2                  ; rotation
    movq        rdx, xmm0
    lea         rcx, [rsp + 48]             ; texture
    call        DrawTextureEx


    ; middle
    movss       xmm3, [rsp + 36]            ; scale
    pxor        xmm2, xmm2                  ; rotation
    movq        rdx, xmm9                   ; position
    lea         rcx, [rsp + 48]             ; texture
    call        DrawTextureEx

    ; front
    movaps      xmm0, xmm9
    addss       xmm0, xmm6

    movss       xmm3, [rsp + 36]            ; scale
    pxor        xmm2, xmm2                  ; rotation
    movq        rdx, xmm0
    lea         rcx, [rsp + 48]             ; texture
    call        DrawTextureEx

    inc         r12d                        ; index
    cmp         r12d, r13d                  ; parallax.count
    jl          .loop

    add         rsp, 80

    movdqa      [rsp + 48], xmm9
    movdqa      [rsp + 32], xmm8
    movdqa      [rsp + 16], xmm7
    add         rsp, 72
    pop         r14
    pop         r13
    pop         r12
    pop         rbx
    ret

