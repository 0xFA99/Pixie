; rdi = Player*

; [rbp - 8], Player*
; [rbp - 12], int runDir
; [rbp - 13], bool isJump

; [rbp - 20], frameTime
; [rbp - 24], gravity
; [rbp - 32], Vector2 newPos
; [rbp - 36], 255.0f

; [rbp - 20], runDir
; [rbp - 21], isJump

_InputPlayer:
    push rbp
    mov rbp, rsp
    sub rsp, 48

    mov [rbp - 8], rdi
    movd [rbp - 12], xmm0
    movd [rbp - 16], xmm1

    mov dword [rbp - 20], 0

    mov edi, 265                ; KEY_UP
    call IsKeyDown
    mov [rbp - 21], al

    mov edi, 262                ; KEY_RIGHT
    call IsKeyDown
    test al, al
    je .turnLeft

    mov dword [rbp - 20], 1

.turnLeft:
    mov edi, 263                ; KEY_LEFT
    call IsKeyDown
    test al, al
    je .startCheckState

    mov dword [rbp - 20], -1

.startCheckState:
    ; lea rdi, [numberFormatD]
    ; mov esi, [rbp - 20]
    ; call printf

    mov rax, [rbp - 8]
    mov eax, [rax + 40]

    cmp eax, STATE_IDLE
    je .stateIdle

    cmp eax, STATE_RUN
    je .stateRun

    jmp .return

.stateIdle:
    ; lea rdi, [idlestr]
    ; call printf

    cmp byte [rbp - 21], 0
    je .stateIdleToRun

;   player->status.state = STATE_JUMP
    mov rax, [rbp - 8]
    mov dword [rax + 40], STATE_JUMP

;   player->movement.velocity.y = player->movement.acceleration
    mov rax, [rbp - 8]
    movss xmm0, [rax + 32]
    movss [rax + 28], xmm0

    jmp .endCheckState

.stateIdleToRun:
    cmp dword [rbp - 20], 0
    je .stateIdleToIdle

;   player->status.state = STATE_RUN
    mov rax, [rbp - 8]
    mov dword [rax + 40], STATE_RUN

;   player->status.direction = runDir > 0
    cmp dword [rbp - 20], 0
    setg al
    movzx edx, al
    mov rax, [rbp - 8]
    mov [rax + 44], edx

;   player->movement.velocity.x = runDir * player->movement.speed
    pxor xmm1, xmm1
    cvtsi2ss xmm1, [rbp - 20]
    mov rax, [rbp - 8]
    movss xmm0, [rax + 36]
    mulss xmm0, xmm1
    movss [rax + 24], xmm0

    jmp .endCheckState

.stateIdleToIdle:
;   player->movement.velocity = 0
    pxor xmm0, xmm0
    mov rax, [rbp - 8]
    movsd [rax + 24], xmm0

    jmp .endCheckState

.stateRun:
    ; lea rdi, [runstr]
    ; call printf

    cmp byte [rbp - 21], 0
    je .stateRunToIdle

;   player->status.state = STATE_JUMP
    mov rax, [rbp - 8]
    mov dword [rax + 40], STATE_JUMP

;   player->movement.velocity.y = player->movement.acceleration
    mov rax, [rbp - 8]
    movss xmm0, [rax + 32]
    movss [rax + 28], xmm0

    jmp .endCheckState

.stateRunToIdle:
    cmp dword [rbp - 20], 0
    jne .stateRunToRun

;   player->status.state = STATE_IDLE
    mov rax, [rbp - 8]
    mov dword [rax + 40], STATE_IDLE

;   player->movement.velocity.x = 0.0f
    pxor xmm0, xmm0
    mov rax, [rbp - 8]
    movss [rax + 24], xmm0

    jmp .endCheckState

.stateRunToRun:
;   player->status.direction = runDir > 0
    cmp dword [rbp - 20], 0
    setg al
    movzx edx, al
    mov rax, [rbp - 8]
    mov [rax + 28], edx

;   player->movement.velocity.x = runDir * player->movement.speed
    pxor xmm1, xmm1
    cvtsi2ss xmm1, [rbp - 20]
    mov rax, [rbp - 8]
    movss xmm0, [rax + 38]
    mulss xmm0, xmm1
    movss [rax + 24], xmm0

    jmp .endCheckState

.endCheckState:

.return:
    add rsp, 48
    pop rbp
    ret

