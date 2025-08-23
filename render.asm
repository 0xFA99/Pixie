; @func     _renderPlayer
; @desc     Render player to screen
; @param    rdi     -> Player pointer

_renderPlayer:
    push rbp
    mov rbp, rsp

    mov r12, rdi                            ; Player*
    mov r13, [rdi]                          ; Player->entity

    ; @param 1 - Texture - DrawTexturePro
    ; Setup texture
    sub rsp, 32                             ; 20 texture + 12 padding
    movaps xmm0, [r13]                      ; texture {id, w, h, mipmaps}
    movaps [rsp], xmm0
    mov eax, [r13 + 16]                     ; texture.format
    mov [rsp + 16], eax

    ; player.frames[player.currentFrame]
    mov rdi, [r13 + 20]                     ; player.frames*
    mov eax, [r12 + 56]                     ; player.currentFrame
    sal rax, 4                              ; sizeof rectangle (16)
    add rdi, rax                            ; base + currentFrame

    ; @param 2 - Source Rectangle - DrawTexturePro
    ; get data of current frame
    movsd xmm0, [rdi]                       ; source.frame { x, y }
    movsd xmm1, [rdi + 8]                   ; source.frame { width, height }

    ; @param 3 - Destination Rectangle - DrawTexturePro
    movsd xmm2, [r12 + 16]                  ; player.position { x, y }
    movsd xmm3, xmm1                        ; source.frame { width, height }

    ; @param 4 - Offset
    pxor xmm4, xmm4                         ; { 0.0, 0.0 }

    ; @param 5 - Rotation
    pxor xmm5, xmm5                         ; 0.0

    ; @param 6 - Color
    mov edi, 0xFFFFFFFF                     ; white

    call DrawTexturePro
    add rsp, 32

    pop rbp
    ret

; @func     _renderParallax
; @desc     draw layered backgrounds to create illusion of depth and meaning
; @param    rdi     -> parallax
; @param    xmm8    -> scale
; @note     renders fake depth because real depth costs extra

_renderParallax:
    push rbp
    mov rbp, rsp

    ; Save parallax address to r12
    mov r12, rdi

    ; Get parallax.count
    mov r13d, [r12 + 8]

    ; Index loop 1
    mov r14d, 0
    jmp .L1

.L4:
    ; Index loop 2
    mov r15d, 0
    jmp .L2

.L3:
    inc r15d

.L2:
    ; Get reference of parallax.data[count]
    mov rdi, [r12]
    mov eax, r14d
    shl rax, 5
    add rdi, rax

    ; Get Parallax.texture.width
    cvtsi2ss xmm0, [rdi + 4]
    mulss xmm0, xmm8

    cmp r15d, 0
    je .setupBackParallax

    cmp r15d, 1
    je .setupMidParallax

    cmp r15d, 2
    je .setupFrontParallax

.setupBackParallax:
    ; Make it negative
    mov eax, -0.0
    movd xmm1, eax
    xorps xmm0, xmm1

    ; Sum the result with parallax position
    movss xmm1, [rdi + 20]
    addss xmm0, xmm1

    jmp .drawParallax

.setupMidParallax:
    movss xmm0, [rdi + 20]
    jmp .drawParallax

.setupFrontParallax:
    ; Sum the result with parallax position
    movss xmm1, [rdi + 20]
    addss xmm0, xmm1

.drawParallax:
    ; Texture
    sub rsp, 32                             ; 20 bytes + 12 bytes padding
    movaps xmm1, [rdi]
    mov eax, [rdi + 16]
    movaps [rsp], xmm1
    mov [rsp + 16], eax

    ; Position
    cvtsi2ss xmm1, [rdi + 24]
    unpcklps xmm0, xmm1

    ; Rotation
    pxor xmm1, xmm1

    ; Scale
    movss   xmm2, xmm8

    ; Color
    mov edi, -1

    call DrawTextureEx
    add rsp, 32

    ; Compare index with 3
    ; (back, mid, fore)
    cmp r15d, 3
    jl .L3

    inc r14d

.L1:
    cmp r14d, r13d
    jl .L4

    pop rbp
    ret

