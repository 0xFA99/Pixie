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

public _updateParallax
_updateParallax:
    mov         r12, rdi

    ; mov         edi, KEY_RIGHT
    ; call        IsKeyDown
    ; movzx       r14d, al

    ; mov         edi, KEY_LEFT
    ; call        IsKeyDown
    ; movzx       r15d, al

    ; sub         r14d, r15d
    ; test        r14d, r14d
    ; jz          .done

    xor         ecx, ecx                    ; index
    mov         r13d, [r12 + 512]           ; parallax.count

.loop:
    mov         eax, ecx
    shl         rax, 5
    lea         rbx, [r12 + rax]

    ; xmm0 = velocity.x
    ; xmm1 = player.pos.x
    ; xmm2 = frameTime
;
;     movss       xmm3, [rbx + 20]            ; parallax.position.x
;     movss       xmm4, [rbx + 4]             ; parallax.texture.width
;
;     ; offset right
;     movss       xmm5, xmm3
;     addss       xmm5, xmm4
;
;     ; offset left
;     movss       xmm6, xmm3
;     subss       xmm6, xmm4
;
;     ; if (playerPosX >= offsetRight)
;     comiss      xmm1, xmm5
;     jb          .checkLeft                  ; if player < offsetRight, skip
;
;     movss       [rbx + 20], xmm5
;     jmp         .afterSnap
;
; .checkLeft:
;     ; if (playerPosX <= offsetLeft)
;     comiss      xmm1, xmm6
;     ja          .afterSnap                  ; if player > offsetLeft, skip
;
;     movss       [rbx + 20], xmm6
;
; .afterSnap:
;
    ; apply velocity: pos.x -= vel * speed * dt
    ; movss       xmm3, [rbx + 20]            ; pos.x
    ; movss       xmm4, [rbx + 28]            ; speed
    ; mulss       xmm0, xmm4                  ; vel * speed
    ; mulss       xmm0, xmm2                  ; * dt
    ; addss       xmm3, xmm0                  ; pos.x - result
    mov         eax, MASK_NEG
    movd        xmm2, eax
    xorps       xmm1, xmm2
    movss       [rbx + 20], xmm1

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

    mov         rbx, rdi                    ; base = parallax

.loop:
    mov         eax, r12d                   ; index
    shl         rax, 5                      ; sizeof ParallaxData (36_
    lea         r14, [rbx + rax]            ; base[count]

    sub         rsp, 32
    movaps      xmm0, [r14]                 ; texture {id, w, h, f, m }
    mov         eax, [r14 + 16]
    movaps      [rsp], xmm0
    mov         [rsp + 16], eax

    mov         eax, [r14 + 4]             ; parallax.width
    sar         eax, 1
    cvtsi2ss    xmm1, eax

    movq        xmm0, [r14 + 20]            ; parallax.position
    subss       xmm0, xmm1
    movaps      xmm8, xmm0

    pxor        xmm1, xmm1                  ; rotation = 0.0

    mov         eax, 0x3f800000             ; scale = 1.0
    movd        xmm2, eax

    mov         edi, 0xFFFFFFFF
    call        DrawTextureEx

    movaps      xmm0, xmm8
    cvtsi2ss    xmm1, [r14 + 4]
    subss       xmm0, xmm1

    pxor        xmm1, xmm1                  ; rotation = 0.0

    mov         eax, 0x3f800000             ; scale = 1.0
    movd        xmm2, eax

    mov         edi, 0xFFFFFFFF
    call        DrawTextureEx

    movaps      xmm0, xmm8
    cvtsi2ss    xmm1, [r14 + 4]
    addss       xmm0, xmm1

    pxor        xmm1, xmm1                  ; rotation = 0.0

    mov         eax, 0x3f800000             ; scale = 1.0
    movd        xmm2, eax

    mov         edi, 0xFFFFFFFF
    call        DrawTextureEx

    add         rsp, 32

    inc         r12d

    cmp         r12d, r13d
    jl          .loop

.done:
    pop         rbp
    ret

