
format ELF64

include 'include/consts.inc'

extrn LoadTexture
extrn DrawTextureEx

section '.text' executable

; @param    rdi     -> parallax
; @param    rsi     -> texture
; @param    edx     -> posY
; @param    xmm0    -> speed
public _addParallax
_addParallax:
    push        rbx
    push        r12
    push        r13
    push        r14

    sub         rsp, 8                      ; padding

    mov         rbx, rdi                    ; parallax
    mov         r13d, edx                   ; position.y
    movd        r14d, xmm0                  ; frameTime

    mov         eax, [rbx + 512]            ; parallax.count
    cmp         eax, PARALLAX_LAYER_CAP
    jge         .done

    shl         rax, 5                      ; sizeof Parallax.data (32)
    lea         rdi, [rbx + rax]            ; parallax.base[parallax.count]
    mov         r12, rdi
    call        LoadTexture

    mov         dword [r12 + 20], 0.0       ; position.x
    mov         [r12 + 24], r13d            ; position.y
    mov         [r12 + 28], r14d            ; frameTime

    inc         dword [rbx + 512]           ; parallax.count

.done:
    add         rsp, 8

    pop         r14
    pop         r13
    pop         r12
    pop         rbx
    ret



public _updateParallax
_updateParallax:
    push        rbx
    push        r12
    push        r13

    mov         r12,  rdi                   ; store pointer
    xor         ecx,  ecx                   ; index = 0
    mov         r13d,  [r12 + 512]          ; parallax.count

.loop:
    mov         eax,  ecx
    shl         rax,  5                     ; index * 32
    lea         rbx,  [r12 + rax]           ; base[index]

    movss       xmm3,  [rbx + 20]           ; parallax.position.x
    mov         eax,  dword [rbx + 4]
    cvtsi2ss    xmm4,  eax                  ; width/2

    movss       xmm5,  xmm3
    addss       xmm5,  xmm4                 ; offsetRight

    movss       xmm6,  xmm3
    subss       xmm6,  xmm4                 ; offsetLeft

    ; if (playerPosX >= offsetRight)
    comiss      xmm1,  xmm5
    jb          .checkLeft
    movss       xmm3,  xmm5
    jmp         .apply

.checkLeft:
    ; else if (playerPosX <= offsetLeft)
    comiss      xmm1,  xmm6
    ja          .apply
    movss       xmm3,  xmm6

.apply:
    ; pos -= velocityX * speed * frameTime
    movss       xmm7,  [rbx + 28]           ; load speed
    mulss       xmm7,  xmm0                 ; * velocityX
    mulss       xmm7,  xmm2                 ; * frameTime
    subss       xmm3,  xmm7
    movss       [rbx + 20],  xmm3           ; store result

    inc         ecx
    cmp         ecx,  r13d
    jl          .loop

    pop         r13
    pop         r12
    pop         rbx
    ret



public _renderParallax
_renderParallax:
    push        rbx
    push        r12
    push        r13
    push        r14

    sub         rsp, 72                     ; 4 xmm reg + 8 padding
    movdqa      [rsp], xmm8
    movdqa      [rsp + 16], xmm9
    movdqa      [rsp + 32], xmm10
    movdqa      [rsp + 48], xmm11

    xor         r12d, r12d                  ; index = 0
    mov         r13d, [rdi + 512]           ; parallax.count
    mov         rbx, rdi                    ; base
    mov         eax, 0x3f800000             ; scale = 1.0
    movd        xmm11, eax

.loop:
    mov         eax, r12d                   ; index
    shl         rax, 5                      ; sizeof ParallaxData (32)
    lea         r14, [rbx + rax]            ; base[offset]

    sub         rsp, 32                     ; 20 texture + 12 padding
    movaps      xmm0, [r14]                 ; texture {id, w, h, f, m}
    mov         eax, [r14 + 16]
    movaps      [rsp], xmm0
    mov         [rsp + 16], eax

    mov         eax, [r14 + 4]              ; parallax.width
    cvtsi2ss    xmm8, eax
    sar         eax, 1
    cvtsi2ss    xmm9, eax                   ; parallax.width / 2.0

    movq        xmm0, [r14 + 20]            ; parallax.position
    subss       xmm0, xmm9
    movaps      xmm10, xmm0
    pxor        xmm1, xmm1                  ; rotation = 0.0
    movss       xmm2, xmm11                 ; scale
    mov         edi, 0xFFFFFFFF             ; color (white)
    call        DrawTextureEx

    movaps      xmm0, xmm10
    addss       xmm0, xmm8
    pxor        xmm1, xmm1                  ; rotation = 0.0
    movss       xmm2, xmm11                 ; scale
    mov         edi, 0xFFFFFFFF             ; color
    call        DrawTextureEx

    movaps      xmm0, xmm10
    subss       xmm0, xmm8
    pxor        xmm1, xmm1                  ; rotation = 0.0
    movss       xmm2, xmm11                 ; scale
    mov         edi, 0xFFFFFFFF             ; color
    call        DrawTextureEx

    movaps      xmm0, xmm10
    addss       xmm0, xmm8
    addss       xmm0, xmm8
    pxor        xmm1, xmm1                  ; rotation = 0.0
    movss       xmm2, xmm11                 ; scale
    mov         edi, 0xFFFFFFFF             ; color
    call        DrawTextureEx

    movaps      xmm0, xmm10
    subss       xmm0, xmm8
    subss       xmm0, xmm8
    pxor        xmm1, xmm1                  ; rotation = 0.0
    movss       xmm2, xmm11                 ; scale
    mov         edi, 0xFFFFFFFF             ; color
    call        DrawTextureEx

    add         rsp, 32

    inc         r12d                        ; index++
    cmp         r12d, r13d                  ; compare with count
    jl          .loop

.done:
    movdqa      xmm11, [rsp + 48]
    movdqa      xmm10, [rsp + 32]
    movdqa      xmm9, [rsp + 16]
    movdqa      xmm8, [rsp]
    add         rsp, 72

    pop         r14
    pop         r13
    pop         r12
    pop         rbx
    ret



section '.note.GNU-stack'

