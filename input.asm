; ============== PARAMETERS ==============
; [rbp -  8]        = Player*
; [rbp - 12]        = float frameTime
; [rbp - 16]        = float gravity

; ============== VARIABLES ===============
; [rbp - 20]        = int runDirection
; [rbp - 21]        = bool isJump
; [rbp - 22]        = bool keyLeftPressed
; [rbp - 23]        = bool keyRightPressed
; [rbp - 28]        = float newPosition.y
; [rbp - 32]        = float newPosition.x

_InputPlayer:
    push rbp
    mov rbp, rsp
    sub rsp, 48

    mov [rbp - 8], rdi
    movd [rbp - 12], xmm0
    movd [rbp - 16], xmm1

    mov dword [rbp - 20], 0

    ; Check if KEY_UP is pressed
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
    mov rdi, [rbp - 8]
    mov eax, [rdi + 40]

    cmp eax, STATE_IDLE
    je .stateIdle

    cmp eax, STATE_RUN
    je .stateRun

    cmp eax, STATE_JUMP
    je .stateJumpAndFall

    cmp eax, STATE_FALL
    je .stateJumpAndFall

    jmp .endCheckState

.stateIdle:
    cmp byte [rbp - 21], 0
    je .stateIdleToRun

;   player->status.state = STATE_JUMP
    mov dword [rdi + 40], STATE_JUMP

;   player->movement.velocity.y = player->movement.acceleration
    movss xmm0, [rdi + 32]
    movss [rdi + 28], xmm0

    jmp .endCheckState

.stateIdleToRun:
    cmp dword [rbp - 20], 0
    je .stateIdleToIdle

;   player->status.state = STATE_RUN
    mov dword [rdi + 40], STATE_RUN

;   player->status.direction = runDir > 0
    ; cmp dword [rbp - 20], 0
    setg al
    movzx edx, al
    mov [rdi + 44], edx

;   player->movement.velocity.x = runDir * player->movement.speed
    pxor xmm1, xmm1
    cvtsi2ss xmm1, [rbp - 20]

    movss xmm0, [rdi + 36]

    mulss xmm0, xmm1
    movss [rdi + 24], xmm0

    jmp .endCheckState

.stateIdleToIdle:
;   player->movement.velocity = 0
    pxor xmm0, xmm0
    movsd [rdi + 24], xmm0

    jmp .endCheckState

.stateRun:
    cmp byte [rbp - 21], 0
    je .stateRunToIdle

;   player->status.state = STATE_JUMP
    mov dword [rdi + 40], STATE_JUMP

;   player->movement.velocity.y = player->movement.acceleration
    movss xmm0, [rdi + 32]
    movss [rdi + 28], xmm0

    jmp .endCheckState

.stateRunToIdle:
    cmp dword [rbp - 20], 0
    jne .stateRunToRun

;   player->status.state = STATE_IDLE
    mov dword [rdi + 40], STATE_IDLE

;   player->movement.velocity.x = 0.0f
    pxor xmm0, xmm0
    movss [rdi + 24], xmm0

    jmp .endCheckState

.stateRunToRun:
;   player->status.direction = runDir > 0
    cmp dword [rbp - 20], 0
    setg al
    movzx edx, al
    mov [rdi + 28], edx

;   player->movement.velocity.x = runDir * player->movement.speed
    pxor xmm1, xmm1
    cvtsi2ss xmm1, [rbp - 20]
    movss xmm0, [rdi + 36]
    mulss xmm0, xmm1
    movss [rdi + 24], xmm0

    jmp .endCheckState

.stateJumpAndFall:
    cmp dword [rbp - 20], 0
    je .stateJumpToJumpOrFall

;   player->status.direction = runDir > 0
    cmp dword [rbp - 20], 0
    setg al
    movzx edx, al
    mov [rdi + 44], edx

;   player->movement.velocity.x = runDir * player->movement.speed
    pxor xmm1, xmm1
    cvtsi2ss xmm1, [rbp - 20]
    movss xmm0, [rdi + 36]
    mulss xmm0, xmm1
    movss [rdi + 24], xmm0

.stateJumpToJumpOrFall:
;   player->movement.velocity.x = runDir * player->movement.speed * frameTime
    pxor xmm1, xmm1
    cvtsi2ss xmm1, [rbp - 20]
    movss xmm0, [rdi + 36]
    mulss xmm0, xmm1
    mulss xmm0, [rbp - 12]
    movss [rdi + 24], xmm0

.checkIfPlayerJump:
    movss xmm0, [rdi + 28]
    pxor xmm1, xmm1
    comiss xmm0, xmm1
    jnb .playerStillJump

    jmp .endCheckState

.playerStillJump:
    mov eax, [rdi + 40]
    cmp eax, STATE_JUMP
    jne .endCheckState

    mov dword [rdi + 40], STATE_FALL

.endCheckState:
;   player->movement.velocity.y += gravity * frameTime
    movss xmm1, [rdi + 28]
    movss xmm0, [rbp - 16]
    mulss xmm0, [rbp - 12]
    addss xmm0, xmm1
    movss [rdi + 28], xmm0

    movss xmm1, [rbp - 12]

    movsd xmm0, [rdi + 24]
    call Vector2Scale

    movsd xmm1, [rdi + 16]
    call Vector2Add
    movsd [rbp - 32], xmm0

    movss xmm0, [rbp - 28]
    pxor xmm1, xmm1
    comiss xmm0, xmm1
    jbe .updatePosition

    pxor xmm0, xmm0
    movss [rbp - 28], xmm0

    pxor xmm0, xmm0
    movss [rdi + 28], xmm0

    mov eax, [rdi + 40]
    cmp eax, STATE_FALL
    je .setToIdle

    mov eax, [rdi + 40]
    cmp eax, STATE_JUMP
    jne .updatePosition

.setToIdle:
    mov dword [rdi + 40], STATE_IDLE

.updatePosition:
    mov rdx, [rbp - 32]
    mov [rdi + 16], rdx

.return:
    add rsp, 48
    pop rbp
    ret

