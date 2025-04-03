; ============== PARAMETERS ==============
; [rbp -  8]        = Player*
; [rbp - 12]        = float frameTime
; [rbp - 16]        = float gravity

; ============== VARIABLES ===============
; [rbp - 20]        = int runDirection
; [rbp - 21]        = bool isJump
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
    mov edi, 265
    call IsKeyDown
    mov [rbp - 21], al

.setRightDirection:
    ; Check if KEY_RIGHT is pressed
    mov edi, 262
    call IsKeyDown
    test al, al
    je .setLeftDirection

    ; Check if KEY_LEFT is not pressed
    mov edi, 263
    call IsKeyDown
    xor eax, 1
    test al, al
    je .setLeftDirection

    ; if true, set to DIRECTION_RIGHT
    mov dword [rbp - 20], DIRECTION_RIGHT 

.setLeftDirection:
    ; Check if KEY_LEFT is pressed.
    mov edi, 263
    call IsKeyDown
    test al, al
    je .startCheckState

    ; Check if KEY_RIGHT is not pressed
    mov edi, 262
    call IsKeyDown
    xor eax, 1
    test al, al
    je .startCheckState

    ; If true, set to DIRECTION_LEFT
    mov dword [rbp - 20], -1

.startCheckState:
    ; Get current player state
    mov rdi, [rbp -  8]
    mov eax, [rdi + 40]

    ; Compare every state
    cmp eax, STATE_IDLE
    je .stateIdle

    cmp eax, STATE_RUN
    je .stateRun

    cmp eax, STATE_JUMP
    je .stateJump

    cmp eax, STATE_FALL
    je .stateFall

    jmp .endCheckState

.stateIdle:
    ; Check if player want to jump.
    cmp byte [rbp - 21], 0
    je .stateIdleToRun

    ; Change player state to STATE_JUMP
    mov dword [rdi + 40], STATE_JUMP

    ; Add player velocity for jump
    movss xmm0, [rdi + 32]
    movss [rdi + 28], xmm0

    jmp .endCheckState

.stateIdleToRun:
    ; Check if player idle
    cmp dword [rbp - 20], 0
    je .stateStayIdle

    ; Change player state to STATE_RUN
    mov dword [rdi + 40], STATE_RUN

    ; Set direction
    cmp dword [rbp - 20], 0
    setg al
    movzx edx, al
    mov [rdi + 44], edx

    ; Add velocity.x to player for run
    ; runDirection * player.speed
    pxor xmm1, xmm1
    cvtsi2ss xmm1, [rbp - 20]
    movss xmm0, [rdi + 36]
    mulss xmm0, xmm1
    movss [rdi + 24], xmm0

    jmp .endCheckState

.stateStayIdle:
    ; Change velocity to 0
    pxor xmm0, xmm0
    movss [rdi + 24], xmm0

    jmp .endCheckState

.stateRun:
    ; Check if player want to jump
    cmp byte [rbp - 21], 0
    je .stateRunToIdle

    ; Set player state to STATE_JUMP
    mov dword [rdi + 40], STATE_JUMP

    ; Add velocity.y to player for jump
    movss xmm0, [rdi + 32]
    movss [rdi + 28], xmm0

    jmp .endCheckState

.stateRunToIdle:
    ; Check if state stay run or not
    cmp dword [rbp - 20], 0
    jne .stateStayRun

    ; Set player state to STATE_IDLE
    mov dword [rdi + 40], STATE_IDLE

    ; Set velocity to 0
    pxor xmm0, xmm0
    movss [rdi + 24], xmm0

    jmp .endCheckState

.stateStayRun:
    ; Check Player Direction
    cmp dword [rbp - 20], 0
    setg al
    movzx edx, al
    mov [rdi + 28], edx

    ; Add velocity.x to player for run
    ; runDirection * player.speed
    pxor xmm1, xmm1
    cvtsi2ss xmm1, [rbp - 20]
    movss xmm0, [rdi + 36]
    mulss xmm0, xmm1
    movss [rdi + 24], xmm0

    jmp .endCheckState

.stateJump:
.stateFall:
    ; Check if player is idle or move
    cmp dword [rbp - 20], 0
    je .checkStillOnAir

    ; Set direction 
    cmp dword [rbp - 20], 0
    setg al
    movzx edx, al
    mov [rdi + 44], edx

    ; Add player velocity
    pxor xmm1, xmm1
    cvtsi2ss xmm1, [rbp - 20]
    movss xmm0, [rdi + 36]
    mulss xmm0, xmm1
    movss [rdi + 24], xmm0

.checkStillOnAir:
    ; Check velocity more than 0.0
    movss xmm0, [rdi + 28]
    pxor xmm1, xmm1
    comiss xmm0, xmm1
    jb .playerOnTheGround

    ; Check if state still STATE_JUMP
    cmp dword [rdi + 40], STATE_JUMP
    jne .endCheckState

.playerOnTheGround:
    ; Set state to STATE_FALL
    mov dword [rdi + 40], STATE_FALL

.endCheckState:
    ; Add gravity * frameTime to velocity.y
    movss xmm1, [rdi + 28]
    movss xmm0, [rbp - 16]
    mulss xmm0, [rbp - 12]
    addss xmm0, xmm1
    movss [rdi + 28], xmm0

    ; Scaling player velocity with frameTime
    movss xmm1, [rbp - 12]
    movsd xmm0, [rdi + 24]
    call Vector2Scale

    ; Add scaling result to player position
    ; Store the result into newPosition
    movsd xmm1, [rdi + 16]
    call Vector2Add
    movsd [rbp - 32], xmm0

    ; Check if newPosition.y more than 0.0
    movss xmm0, [rbp - 28]
    pxor xmm1, xmm1
    comiss xmm0, xmm1
    jbe .updatePlayerPosition

    ; Set newPosition.y to 0.0
    pxor xmm0, xmm0
    movss [rbp - 28], xmm0

    ; Set player velocity.y to 0.0
    movss [rdi + 28], xmm0

    ; Check if state is STATE_FALL
    ; or state is STAT_JUMP
    ; change to STATE_IDLE
    cmp dword [rdi + 40], STATE_FALL
    je .changeToIdle

    cmp dword [rdi + 40], STATE_JUMP
    jne .updatePlayerPosition

.changeToIdle:
    mov dword [rdi + 40], STATE_IDLE

.updatePlayerPosition:
    movsd xmm0, [rbp - 32]
    movsd [rdi + 16], xmm0

    add rsp, 48
    pop rbp
    ret

