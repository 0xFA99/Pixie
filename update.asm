; rdi = Camera*
; rsi = Player*
public _UpdateCamera
_UpdateCamera:
    push rbp
    mov rbp, rsp

    movss xmm0, [rsi + 16]

    mov rax, [rsi]
    mov rax, [rax + 24]
    movss xmm1, [rax + 8]

    mov eax, 2.0
    movd xmm2, eax

    divss xmm1, xmm2
    addss xmm0, xmm1
    movss [rdi + 8], xmm0

    pop rbp
    ret

; rdi = Player*
; xmm0 = float frameTime
public _UpdatePlayer.updatePlayerAnimation
_UpdatePlayer:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    mov [rbp - 8], rdi
    movss [rbp - 12], xmm0

    mov rax, [rbp - 8]
    mov rax, [rax + 40]
    mov [rbp - 20], rax

    mov rax, [rbp - 8]
    mov rax, [rax + 8]
    mov [rbp - 28], rax

    mov edx, [rbp - 20]
    mov rax, [rbp - 8]
    mov eax, [rax + 12]
    cmp edx, eax
    jne .setPlayerAnimation

    mov eax, [rbp - 16]
    mov rax, [rbp - 8]
    mov eax, [rax + 12]
    cmp edx, eax
    je .updatePlayerAnimation

.setPlayerAnimation:
    mov rdi, [rbp - 8]
    mov esi, [rbp - 20]
    mov edx, [rbp - 16]
    call _SetPlayerAnimation

.updatePlayerAnimation:
    ; Update Player Movement
    mov rax, [rbp - 8]

    movss xmm0, [rax + 16]
    movss xmm1, [rax + 24]
    mulss xmm1, [rbp - 12]
    addss xmm0, xmm1

    movss xmm1, [rax + 20]
    movss xmm2, [rax + 28]
    mulss xmm2, [rbp - 12]
    addss xmm1, xmm2

    movss [rax + 16], xmm0
    movss [rax + 20], xmm1

    ; Update Player Animation
    ; mov rax, [rbp - 8]
    ; movss xmm0, [rax + 52]
    ; movss [rbp - 16], xmm0  ; frameDuration
    mov rax, [rbp - 8]
    mov rax, [rax]
    add rax, 52
    mov [rbp - 16], rax

    mov rax, [rbp - 8]
    mov rax, [rax + 8]
    movss xmm0, [rax + 8]
    movss [rbp - 20], xmm0  ; player animation FPS

    ; movss xmm0, [rbp - 16]
    ; movss xmm1, [rbp - 12]
    ; addss xmm0, xmm1
    ; movss [rbp - 16], xmm0

    mov rax, [rbp - 16]
    movss xmm0, [rax]
    addss xmm0, [rbp - 12]

    mov eax, 1.0
    movd xmm0, eax
    movd [rbp - 24], xmm0   ; 1.0

    ; movss xmm0, [rbp - 16]
    ; movss xmm1, [rbp - 24]
    ; divss xmm1, [rbp - 20]
    ; comiss xmm0, xmm1
    mov rax, [rbp - 16]
    movss xmm0, [rax]
    movss xmm1, [rbp - 24]
    divss xmm1, [rbp - 20]
    comiss xmm0, xmm1
    jnb .loopAnimation

    jmp .return

.loopAnimation:
    pxor xmm0, xmm0
    movss [rbp - 16], xmm0

    mov rax, [rbp - 8]
    mov edx, [rax + 48]
    add edx, 1
    mov [rax + 48], edx

    mov rax, [rbp - 8]
    mov edx, [rax + 48]
    mov rax, [rax + 8]
    mov eax, [rax + 4]
    cmp edx, eax
    jle .return
    
    mov rax, [rbp - 8]
    mov rax, [rax + 8]
    mov edx, [rax]
    mov rax, [rbp - 8]
    mov [rax + 48], edx

.return:
    add rsp, 32
    pop rbp
    ret

