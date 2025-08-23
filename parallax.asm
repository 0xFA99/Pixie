; @func     _addParallax
; @desc     stack background layers like broken promises
; @param    rdi     -> parallax
; @param    rsi     -> texture
; @param    edx     -> posX
; @param    ecx     -> posY
; @param    xmm8    -> speed
; @note     creates fake depth because real depth is too expensive

_addParallax:
    push        rbp
    mov         rbp, rsp

    mov         r12, rdi                    ; parallax
    mov         r13, rsi                    ; texture
    mov         r14d, edx                   ; position.x
    mov         r15d, ecx                   ; position.y

    mov         rax, [r12]                  ; parallax.data
    test        rax, rax                    ; check if parallax.data is NULL
    jnz         .reAlloc

    mov         rdi, 32                     ; sizeof ParallaxData (32)
    call        malloc
    mov         [r12], rax                  ; parallax.data

    jmp         .fill

.reAlloc:
    mov         rdi, [r12]                  ; parallax.data (first parameter)
    mov         esi, [r12 + 8]              ; parallax.count
    inc         esi                         ; parallax.count + 1
    shl         rsi, 5                      ; sizeof ParallaxData (32)
    call        realloc
    mov         [r12], rax                  ; reallocated parallax.data

.fill:
    mov         rdi, [r12]                  ; parallax.data
    mov         rsi, [r12 + 8]              ; parallax.count
    shl         rsi, 5                      ; sizeof ParallaxData (32)
    add         rdi, rsi

    movd        [rdi + 28], xmm8            ; speed

    mov         [rdi + 20], r14d            ; position.x
    mov         [rdi + 24], r15d            ; position.y

    mov         rsi, r13                    ; texture
    call        LoadTexture

    add         dword [r12 + 8], 1          ; parallax.count

    pop         rbp
    ret

