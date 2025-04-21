_renderPlayer:
    push rbp
    mov rbp, rsp

    mov r12, rdi        ; Player*
    mov r13, [rdi]      ; Player->entity

    ; Setup the texture
    sub rsp, 32         ; 20 bytes tuxture + 12 padding
    mov rax, [r13]
    mov rdx, [r13 + 8]
    mov [rsp], rax
    mov [rsp + 8], rdx
    mov rax, [r13 + 16]
    mov [rsp + 16], rax

    ; Get reference of current frames
    mov rdi, [r13 + 20]
    mov eax, [r12 + 48] ; player current frame
    imul eax, 16
    cdqe
    add rdi, rax

    ; Get the frame rectangle
    movq xmm0, [rdi]
    movq xmm1, [rdi + 8]

    ; Get Player coordinate
    movsd xmm2, [r12 + 16]      ; Player.position
    movsd xmm3, [rdi + 8]       ; texture.width
    subps xmm2, xmm3            ; position - width

    ; Get size of frame
    movq xmm3, [rdi + 8]
   
    ; Check if frame width is negative
    pxor xmm4, xmm4
    comiss xmm2, xmm4
    jnb .skipFlip

    ; Change to positive
    pxor xmm2, xmm4

.skipFlip:
    ; Set offset
    pxor xmm4, xmm4

    ; Rotation
    pxor xmm5, xmm5
   
    ; Color
    mov edi, -1

    call _drawTexturePro
    add rsp, 32

    pop rbp
    ret

; @ params
; rdi = Parallax*
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
    imul eax, 32
    cdqe
    add rdi, rax

    ; Get Parallax.texture.width
    cvtsi2ss xmm0, [rdi + 4]

    cmp r15d, 0
    je .setupBackParallax

    cmp r15d, 1
    je .setupMidParallax

    cmp r15d, 2
    je .setupFrontParallax

.setupBackParallax:
    ; Set the position in the back
    ; of original parallax position
    addss xmm0, xmm0

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
    ; Set the position in the front
    ; of original parallax position
    addss xmm0, xmm0

    ; Sum the result with parallax position
    movss xmm1, [rdi + 20]
    addss xmm0, xmm1

.drawParallax:
    ; Texture
    sub rsp, 32     ; 20 bytes + 12 bytes padding
    mov rax, [rdi]
    mov rdx, [rdi + 8]
    mov [rsp], rax
    mov [rsp + 8], rdx
    mov eax, [rdi + 16]
    mov [rsp + 16], eax

    ; Position
    cvtsi2ss xmm1, [rdi + 24]
    unpcklps xmm0, xmm1

    ; Rotation
    pxor xmm1, xmm1

    ; Scale
    mov eax, 2.0
    movd xmm2, eax

    ; Color
    mov edi, -1

    call _drawTextureEx
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

