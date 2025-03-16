; rdi = Player*

; [rbp - 8], Player*
; [rbp - 12], int runDir
; [rbp - 13], bool isJump

; [rbp - 20], frameTime
; [rbp - 24], gravity
; [rbp - 32], Vector2 newPos
; [rbp - 36], 255.0f
_InputPlayer:
    push rbp
    mov rbp, rsp
    sub rsp, 48

    mov [rbp - 8], rdi

    movss [rbp - 20], xmm0
    movss [rbp - 24], xmm1

    mov dword [rbp - 12], 0
    mov edi, 265
    call IsKeyDown
    mov [rbp - 13], al

;   if (IsKeyDown(262)) runDir = 1;
    mov edi, 262
    call IsKeyDown
    test al, al
    je .setDirectionLeft
    mov dword [rbp - 12], 1

.setDirectionLeft:
;   if (IsKeyDown(263)) runDir = -1; 
    mov edi, 263
    call IsKeyDown
    test al, al
    je .startCheckState
    mov dword [rbp - 12], -1

.startCheckState:
    mov rax, [rbp - 8]
    mov eax, [rax + 40]

    cmp eax, 3
    jg .endCheckState

    cmp eax, 2
    jge .stateFall

    test eax, eax
    je .stateIdle

    cmp eax, 1
    je .stateRun
    
    jmp .endCheckState

.stateIdle:
    cmp byte [rbp - 5], 0
    je .stateIdleToRun

;   player->status.state = STATE_JUMP
    mov rax, [rbp - 8]
    mov dword [rax + 40], STATE_JUMP

;   player->movement.velocity.y = player->movement.acceleration;
    mov rax, [rbp - 8]
    movss xmm0, [rax + 32]
    movss [rax + 28], xmm0

    jmp .endCheckState

.stateIdleToRun:
    cmp dword [rbp - 12], 0
    je .stateIdleToIdle

;   player->status.state = STATE_RUN
    mov rax, [rbp - 8]
    mov dword [rax + 40], STATE_RUN

;   player->status.direction = runDir > 0
    cmp dword [rbp - 12], 0
    setg al
    movzx edx, al
    mov rax, [rbp - 8]
    mov [rax + 44], edx

;   player->movement.velocity.x = runDir * player->movement.speed;
    pxor xmm1, xmm1
    cvtsi2ss xmm1, [rbp - 12]
    mov rax, [rbp - 8]
    movss xmm0, [rax + 36]
    mulss xmm0, xmm1
    movss [rax + 24], xmm0

    jmp .endCheckState

.stateIdleToIdle:
;   player->movement.velocity.x = 0.0f;
;   player->movement.velocity.y = 0.0f;
    pxor xmm0, xmm0
    mov rax, [rbp - 8]
    movsd [rax + 24], xmm0

    jmp .endCheckState
    
.stateRun:
    cmp byte [rbp - 13], 0
    je .stateRunToIdle

;   player->status.state = STATE_JUMP
    mov rax, [rbp - 8]
    mov dword [rax + 40], STATE_JUMP

; player->movement.velocity.y = player->movement.acceleration;
    mov rax, [rbp - 8]
    movss xmm0, [rax + 32]
    movss [rax + 28], xmm0

    jmp .endCheckState

.stateRunToIdle:
    cmp dword [rbp - 12], 0
    jne .stateRunToRun

;   player->status.state = STATE_IDLE
    mov rax, [rbp - 8]
    mov dword [rax + 40], STATE_IDLE

;   player->movement.velocity.x = 0.0f;
    mov rax, [rbp - 8]
    pxor xmm0, xmm0
    movss [rax + 24], xmm0

    jmp .endCheckState

.stateRunToRun:
;   player->status.direction = runDir > 0;
    cmp dword [rbp - 12], 0
    setg al
    movzx edx, al
    mov rax, [rbp - 8]
    mov [rax + 44], edx

;   player->movement.velocity.x = runDir * player->movement.speed
    pxor xmm1, xmm1
    cvtsi2ss xmm1, [rbp - 12]
    mov rax, [rbp - 8]
    movss xmm0, [rax + 36]
    mulss xmm0, xmm1
    movss [rax + 24], xmm0

    jmp .endCheckState

.stateFall:
;   if (runDir != 0) {
    cmp dword [rbp - 12], 0
    je .stateFall2

;   player->status.direction = runDir > 0;
    cmp dword [rbp - 12], 0
    setg al
    movzx edx, al
    mov rax, [rbp - 8]
    mov [rax + 44], edx

;   player->movement.velocity.x = runDir * player->movement.speed;
    pxor xmm1, xmm1
    cvtsi2ss xmm1, [rbp - 12]
    mov rax, [rbp - 8]
    movss xmm0, [rax + 36]
    mulss xmm0, xmm1
    movss [rax + 24], xmm0

    jmp .stateFall3

.stateFall2:
;   player->movement.velocity.x = runDir * player->movement.speed * frameTime;
    pxor xmm1, xmm1
    cvtsi2ss xmm1, [rbp - 12]
    mov rax, [rbp - 8]
    movss xmm0, [rax + 36]
    mulss xmm0, xmm1
    mulss xmm0, [rbp - 20]
    movss [rax + 24], xmm0

.stateFall3:
;   if (player->movement.velocity.y >= 0 && player->status.state == STATE_JUMP) {
;   param 1
    mov rax, [rbp - 8]
    movss xmm0, [rax + 28]
    pxor xmm1, xmm1
    comiss xmm0, xmm1
    jnp .stateFall4

.stateFall4:
;   param 2
    mov rax, [rbp - 8]
    mov edx, [rax + 40]
    cmp edx, STATE_JUMP
    jne .endCheckState
    mov dword [rax + 40], STATE_FALL

.endCheckState:
;   player->movement.velocity.y += gravity * frameTime;
    mov rax, [rbp - 8]
    movss xmm1, [rax + 28]
    movss xmm0, [rbp - 24]
    mulss xmm0, [rbp - 20]
    addss xmm0, xmm1
    movss [rax + 28], xmm0

;   struct Vector2 newPos = Vector2Add(
;       player->movement.position,
;       Vector2Scale(player->movement.velocity, frameTime)
;   )
    movss xmm0, [rbp - 20]
    mov rax, [rbp - 8]
    mov rax, [rax + 24]
    movaps xmm1, xmm0
    movq xmm0, rax
    call Vector2Scale
    movq rdx, xmm0
    mov rax, [rbp - 8]
    mov rax, [rax + 16]
    movq xmm1, rdx
    movq xmm0, rax
    call Vector2Add
    movq rax, xmm0
    mov [rbp - 32], rax

;   if (newPos.y > 255.0f) {
;   255.0f
    mov eax, 0.0
    movd xmm0, eax
    movss [rbp - 36], xmm0

    movss xmm0, [rbp - 28]
    comiss xmm0, [rbp - 36]
    jbe .newPosition

;   newPos.y = 255.0f
    movss xmm0, [rbp - 36]
    movss [rbp - 28], xmm0

;   player->movement.velocity = 0.0f
    mov rax, [rbp - 8]
    pxor xmm0, xmm0
    movss [rax + 28], xmm0

;   if (player->status.state == STATE_FALL || player->status.state == STATE_JUMP) {
    mov rax, [rbp - 8]
    mov eax, [rax + 40]
    cmp eax, STATE_FALL
    je .setStateToIdle

    mov rax, [rbp - 8]
    mov eax, [rax + 40]
    cmp eax, STATE_JUMP
    jne .newPosition

.setStateToIdle:
;   player->status.state = STATE_IDLE;
    mov rax, [rbp - 8]
    mov dword [rax + 40], STATE_IDLE

.newPosition:
    mov rax, [rbp - 8]
    mov rdx, [rbp - 32]
    mov [rax + 16], rdx

.return:
    add rsp, 48
    pop rbp
    ret

