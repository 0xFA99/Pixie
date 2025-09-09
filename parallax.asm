; @param    rdi     -> parallax
; @param    rsi     -> texture
; @param    edx     -> posX
; @param    ecx     -> posY
; @param    xmm0    -> speed
_addParallax:
    push        rbp
    mov         rbp, rsp

    mov         rbx, rdi                    ; parallax

    mov         r13d, edx                   ; position.x
    mov         r14d, ecx                   ; position.y
    movd        r15d, xmm0

    mov         eax, [rdi + 512]            ; parallax.count
    cmp         eax, PARALLAX_LAYER_CAP
    jge         .done

    shl         rax, 5                      ; sizeof ParallaxData (32)
    lea         rdi, [rbx + rax]            ; parallax.base[parallax.count]
    mov         r12, rdi
    call        LoadTexture

    mov         [r12 + 20], r13d
    mov         [r12 + 24], r14d
    mov         [r12 + 28], r15d

    inc         dword [rbx + 512]

.done:
    pop         rbp
    ret

_updateParallax:
    mov         r12, rdi

    xor         ecx, ecx                    ; index
    mov         r13d, [r12 + 512]           ; parallax.count

.loop:
    mov         eax, ecx
    shl         rax, 5
    lea         rbx, [r12 + rax]

    ; xmm0 = velocityX
    ; xmm1 = playerPosX
    ; xmm2 = frameTime

    movss       xmm3, [rbx+20]        ; parallax.position.x
    mov         eax, dword [rbx + 4]
    cvtsi2ss    xmm4, eax

    movss       xmm5, xmm3
    addss       xmm5, xmm4            ; offsetRight

    movss       xmm6, xmm3
    subss       xmm6, xmm4            ; offsetLeft

    ; if (playerPosX >= offsetRight)
    comiss      xmm1, xmm5
    jb          .checkLeft
    movss       xmm3, xmm5
    jmp         .apply

.checkLeft:
    ; else if (playerPosX <= offsetLeft)
    comiss      xmm1, xmm6
    ja          .apply
    movss       xmm3, xmm6

.apply:
    ; pos -= velocityX * speed * frameTime
    movss       xmm7, [rbx+28]
    mulss       xmm7, xmm0
    mulss       xmm7, xmm2
    subss       xmm3, xmm7
    movss       [rbx+20], xmm3

    inc         ecx
    cmp         ecx, r13d
    jl          .loop

.done:
    ret

_renderParallax:
    push        rbp
    mov         rbp, rsp

    xor         r12d, r12d                  ; index = 0
    mov         r13d, [rdi + 512]           ; parallax.count

    mov         rbx, rdi                    ; base

    mov         eax, 0x3f800000             ; scale = 1.0
    movd        xmm11, eax

.loop:
    mov         eax, r12d                   ; index
    shl         rax, 5                      ; sizeof ParallaxData (36)
    lea         r14, [rbx + rax]            ; base[offset]

    sub         rsp, 32
    movaps      xmm0, [r14]                 ; texture {id, w, h, f, m }
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
    movss       xmm2, xmm11
    mov         edi, 0xFFFFFFFF
    call        DrawTextureEx

    movaps      xmm0, xmm10
    addss       xmm0, xmm8
    pxor        xmm1, xmm1                  ; rotation = 0.0
    movss       xmm2, xmm11
    mov         edi, 0xFFFFFFFF
    call        DrawTextureEx

    movaps      xmm0, xmm10
    subss       xmm0, xmm8
    pxor        xmm1, xmm1                  ; rotation = 0.0
    movss       xmm2, xmm11
    mov         edi, 0xFFFFFFFF
    call        DrawTextureEx

    add         rsp, 32

    inc         r12d
    cmp         r12d, r13d
    jl          .loop

.done:
    pop         rbp
    ret

