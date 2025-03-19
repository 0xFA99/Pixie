; rdi = Player*
_RenderPlayer:
    push rbp
    mov rbp, rsp
    sub rsp, 80

    mov [rbp - 8], rdi

    ; Texture 20 bytes
    mov rax, [rbp - 8]
    mov rax, [rax]

    mov rdx, [rax]
    mov rcx, [rax + 8]
    mov [rbp - 28], rdx
    mov [rbp - 20], rcx
    mov eax, [rax + 16]
    mov [rbp - 12], eax

    ; Frame 16 bytes
    mov rax, [rbp - 8]
    mov rax, [rax]
    mov rdx, [rax + 24]

    mov rax, [rbp - 8]
    mov eax, [rax + 48]
    imul eax, 16
    cdqe
    add rax, rdx

    movsd xmm0, [rax]
    movsd xmm1, [rax + 8]
    movsd [rbp - 44], xmm0
    movsd [rbp - 36], xmm1

    ; Position 16 bytes
    mov rax, [rbp - 8]
    movsd xmm0, [rax + 16]
    movsd [rbp - 60], xmm0

    movss xmm0, [rbp - 32]
    movss [rbp - 48], xmm0

    ; Check if position.width is negative
    ; convert to positive
    movss xmm0, [rbp - 36]
    mov eax, -0.0
    movd xmm2, eax
    pxor xmm1, xmm1
    comiss xmm1, xmm0
    jbe .positive

    xorps xmm0, xmm2

.positive:
    movss [rbp - 52], xmm0

    movss xmm0, [rbp - 52]
    movss [rbp - 52], xmm0

    ; Vector 8 bytes
    pxor xmm0, xmm0
    movsd [rbp - 68], xmm0

    sub rsp, 16
    mov rcx, rsp

    ; texture
    mov rax, [rbp - 28]
    mov rdx, [rbp - 20]
    mov [rcx], rax
    mov [rcx + 8], rdx
    mov eax, [rbp - 12]
    mov [rcx + 16], eax

    ; frame
    movsd xmm0, [rbp - 44]
    movsd xmm1, [rbp - 36]

    ; position
    movsd xmm2, [rbp - 60]
    movsd xmm3, [rbp - 52]

    ; offset
    movsd xmm4, [rbp - 68]

    ; rotation
    pxor xmm5, xmm5

    ; Color = 0xFFFFFFFF
    mov edi, -1

    call DrawTexturePro

    add rsp, 16

    add rsp, 80
    pop rbp
    ret

_RenderBackground:
    push rbp
    mov rbp, rsp
    sub rsp, 16

;   ========== BACKGROUND BACK =============
    mov eax, [background + 4]
    cvtsi2ss xmm0, eax
    addss xmm0, xmm0

    mov eax, -0.0
    movd xmm1, eax
    xorps xmm0, xmm1

    movss xmm1, [backgroundScrolling]
    addss xmm0, xmm1

    movss [rbp - 8], xmm0

    pxor xmm0, xmm0
    movss [rbp - 4], xmm0

    ; Texture
    sub rsp, 16
    mov rcx, rsp
    mov rax, [background]
    mov rdx, [background + 8]
    mov [rcx], rax
    mov [rcx + 8], rdx
    mov eax, [background + 16]
    mov [rcx + 16], eax

    ; Position
    mov rsi, [rbp - 8]
    movq xmm0, rsi

    ; Rotation
    pxor xmm1, xmm1

    ; Scale
    mov eax, 2.0
    movd xmm2, eax

    ; Color
    mov edi, -1

    call DrawTextureEx
    add rsp, 16

;   ========== BACKGROUND =============
    ; Vector2 Position
    movss xmm0, [backgroundScrolling]
    movss [rbp - 8], xmm0

    ; mov eax, 20.0
    ; movd xmm0, eax
    pxor xmm0, xmm0
    movss [rbp - 4], xmm0

    ; Texture
    sub rsp, 16
    mov rcx, rsp
    mov rax, [background]
    mov rdx, [background + 8]
    mov [rcx], rax
    mov [rcx + 8], rdx
    mov eax, [background + 16]
    mov [rcx + 16], eax

    ; Position
    mov rsi, [rbp - 8]
    movq xmm0, rsi

    ; Rotation
    pxor xmm1, xmm1

    ; Scale
    mov eax, 2.0
    movd xmm2, eax

    ; Color
    mov edi, -1

    call DrawTextureEx
    add rsp, 16

;   ========== BACKGROUND FORWARD =============
    movss xmm1, [backgroundScrolling]
    mov eax, [background + 4]
    cvtsi2ss xmm0, eax
    addss xmm0, xmm0
    addss xmm0, xmm1
    movss [rbp - 8], xmm0

    ; mov eax, 20.0
    ; movd xmm0, eax
    pxor xmm0, xmm0
    movss [rbp - 4], xmm0

    ; Texture
    sub rsp, 16
    mov rcx, rsp
    mov rax, [background]
    mov rdx, [background + 8]
    mov [rcx], rax
    mov [rcx + 8], rdx
    mov eax, [background + 16]
    mov [rcx + 16], eax

    ; Position
    mov rsi, [rbp - 8]
    movq xmm0, rsi

    ; Rotation
    pxor xmm1, xmm1

    ; Scale
    mov eax, 2.0
    movd xmm2, eax

    ; Color
    mov edi, -1

    call DrawTextureEx
    add rsp, 16

;   ========== MIDGROUND BACK =============
    mov eax, [midground + 4]
    cvtsi2ss xmm0, eax
    addss xmm0, xmm0

    mov eax, -0.0
    movd xmm1, eax
    xorps xmm0, xmm1

    movss xmm1, [midgroundScrolling]
    addss xmm0, xmm1

    movss [rbp - 8], xmm0

    mov eax, 20.0
    movd xmm0, eax
    movss [rbp - 4], xmm0

    ; Texture
    sub rsp, 16
    mov rcx, rsp
    mov rax, [midground]
    mov rdx, [midground + 8]
    mov [rcx], rax
    mov [rcx + 8], rdx
    mov eax, [midground + 16]
    mov [rcx + 16], eax

    ; Position
    mov rsi, [rbp - 8]
    movq xmm0, rsi

    ; Rotation
    pxor xmm1, xmm1

    ; Scale
    mov eax, 2.0
    movd xmm2, eax

    ; Color
    mov edi, -1

    call DrawTextureEx
    add rsp, 16

;   ========== MIDGROUND =============
    ; Vector2 Position
    movss xmm0, [midgroundScrolling]
    movss [rbp - 8], xmm0

    mov eax, 20.0
    movd xmm0, eax
    movss [rbp - 4], xmm0

    ; Texture
    sub rsp, 16
    mov rcx, rsp
    mov rax, [midground]
    mov rdx, [midground + 8]
    mov [rcx], rax
    mov [rcx + 8], rdx
    mov eax, [midground + 16]
    mov [rcx + 16], eax

    ; Position
    mov rsi, [rbp - 8]
    movq xmm0, rsi

    ; Rotation
    pxor xmm1, xmm1

    ; Scale
    mov eax, 2.0
    movd xmm2, eax

    ; Color
    mov edi, -1

    call DrawTextureEx
    add rsp, 16

;   ========== MIDGROUND FORWARD =============
    movss xmm1, [midgroundScrolling]
    mov eax, [midground + 4]
    cvtsi2ss xmm0, eax
    addss xmm0, xmm0
    addss xmm0, xmm1
    movss [rbp - 8], xmm0

    mov eax, 20.0
    movd xmm0, eax
    movss [rbp - 4], xmm0

    ; Texture
    sub rsp, 16
    mov rcx, rsp
    mov rax, [midground]
    mov rdx, [midground + 8]
    mov [rcx], rax
    mov [rcx + 8], rdx
    mov eax, [midground + 16]
    mov [rcx + 16], eax

    ; Position
    mov rsi, [rbp - 8]
    movq xmm0, rsi

    ; Rotation
    pxor xmm1, xmm1

    ; Scale
    mov eax, 2.0
    movd xmm2, eax

    ; Color
    mov edi, -1

    call DrawTextureEx
    add rsp, 16

;   ========== foreGROUND BACK =============
    mov eax, [foreground + 4]
    cvtsi2ss xmm0, eax
    addss xmm0, xmm0

    mov eax, -0.0
    movd xmm1, eax
    xorps xmm0, xmm1

    movss xmm1, [foregroundScrolling]
    addss xmm0, xmm1

    movss [rbp - 8], xmm0

    mov eax, 70.0
    movd xmm0, eax
    movss [rbp - 4], xmm0

    ; Texture
    sub rsp, 16
    mov rcx, rsp
    mov rax, [foreground]
    mov rdx, [foreground + 8]
    mov [rcx], rax
    mov [rcx + 8], rdx
    mov eax, [foreground + 16]
    mov [rcx + 16], eax

    ; Position
    mov rsi, [rbp - 8]
    movq xmm0, rsi

    ; Rotation
    pxor xmm1, xmm1

    ; Scale
    mov eax, 2.0
    movd xmm2, eax

    ; Color
    mov edi, -1

    call DrawTextureEx
    add rsp, 16

;   ========== foreGROUND =============
    ; Vector2 Position
    movss xmm0, [foregroundScrolling]
    movss [rbp - 8], xmm0

    mov eax, 70.0
    movd xmm0, eax
    movss [rbp - 4], xmm0

    ; Texture
    sub rsp, 16
    mov rcx, rsp
    mov rax, [foreground]
    mov rdx, [foreground + 8]
    mov [rcx], rax
    mov [rcx + 8], rdx
    mov eax, [foreground + 16]
    mov [rcx + 16], eax

    ; Position
    mov rsi, [rbp - 8]
    movq xmm0, rsi

    ; Rotation
    pxor xmm1, xmm1

    ; Scale
    mov eax, 2.0
    movd xmm2, eax

    ; Color
    mov edi, -1

    call DrawTextureEx
    add rsp, 16

;   ========== foreGROUND FORWARD =============
    movss xmm1, [foregroundScrolling]
    mov eax, [foreground + 4]
    cvtsi2ss xmm0, eax
    addss xmm0, xmm0
    addss xmm0, xmm1
    movss [rbp - 8], xmm0

    mov eax, 70.0
    movd xmm0, eax
    movss [rbp - 4], xmm0

    ; Texture
    sub rsp, 16
    mov rcx, rsp
    mov rax, [foreground]
    mov rdx, [foreground + 8]
    mov [rcx], rax
    mov [rcx + 8], rdx
    mov eax, [foreground + 16]
    mov [rcx + 16], eax

    ; Position
    mov rsi, [rbp - 8]
    movq xmm0, rsi

    ; Rotation
    pxor xmm1, xmm1

    ; Scale
    mov eax, 2.0
    movd xmm2, eax

    ; Color
    mov edi, -1

    call DrawTextureEx
    add rsp, 16
    add rsp, 16
    pop rbp
    ret

