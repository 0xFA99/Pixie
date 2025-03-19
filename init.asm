; ============== PARAMETERS ==============
; [rbp - 8]     =  Player*

_InitPlayer:
    push rbp
    mov rbp, rsp

    sub rsp, 8
    mov [rbp - 8], rdi

    mov edi, 56
    call malloc
    mov rdx, [rbp - 8]
    mov [rdx], rax

    pxor xmm0, xmm0
    movsd [rdx + 16], xmm0  ; movement.position
    movsd [rdx + 24], xmm0  ; movement.velocity

    mov eax, -200.0
    movd xmm0, eax
    movss [rdx + 32], xmm0  ; movement.acceleration

    mov eax, 100.0
    movd xmm0, eax
    movss [rdx + 36], xmm0  ; movement.speed

    mov rax, [rdx]
    pxor xmm0, xmm0
    movss [rax + 52], xmm0

    add rsp, 8

    pop rbp
    ret

; ============== PARAMETERS ==============
; rdi   = Camera*
; rsi   = Player*

_InitCamera:
    push rbp
    mov rbp, rsp

    ; Camera Offset
    call GetScreenWidth
    sar rax, 1
    cvtsi2ss xmm0, rax

    call GetScreenHeight
    sar rax, 1
    cvtsi2ss xmm1, rax
    movss [rdi], xmm0
    movss [rdi + 4], xmm1

    ; Camera Target
    ; movsd xmm0, [rsi + 16]
    ; movsd [rdi + 12], xmm0

    movss xmm0, [rsi + 12]
    movss [rdi + 8], xmm0

    mov eax, -70.0
    movd xmm0, eax
    movss [rdi + 12], xmm0

    ; Camera Rotation
    pxor xmm0, xmm0
    movss [rdi + 16], xmm0

    ; Camera Zoom
    ; mov eax, 1
    ; cvtsi2ss xmm0, eax
    ; movss [rdi + 20], xmm0

    mov eax, 1.5
    movd xmm0, eax
    movss [rdi + 20], xmm0

    pop rbp
    ret

_InitParallaxBackground:
    push rbp
    mov rbp, rsp

    lea rdi, [background]
    lea rsi, [background_file]
    call LoadTexture

    lea rdi, [midground]
    lea rsi, [midground_file]
    call LoadTexture

    lea rdi, [foreground]
    lea rsi, [foreground_file]
    call LoadTexture

    pop rbp
    ret

