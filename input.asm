_inputCamera:
    call GetMouseWheelMove

    movss xmm1, [cameraZoomLevel]
    mulss xmm1, xmm0

    movss xmm0, [rdi + 20]
    addss xmm0, xmm1

    movd [rdi + 20], xmm0

    ret

_inputPlayer:
    mov r12, rdi

    ; if KEY_UP active
    mov edi, KEY_UP
    call IsKeyPressed
    mov r13b, al

    ; if KEY_RIGHT active
    mov edi, KEY_RIGHT
    call IsKeyDown
    movzx r14d, al

    ; if KEY_LEFT active
    mov edi, KEY_LEFT
    call IsKeyDown
    movzx r15d, al

    ; direction = right - left
    sub r14d, r15d

    movss xmm1, [r12 + 24]          ; player.velocity.x

    ; switch (player.state)
    mov eax, [r12 + 48]             ; player.state
    cmp eax, STATE_IDLE
    je .stateIdle

    cmp eax, STATE_RUN
    je .stateRun

    cmp eax, STATE_JUMP
    je .stateJump

    cmp eax, STATE_FALL
    je .stateFall

    ret

.stateIdle:
    ; if (isJump && player.isGrounded)
    mov al, r13b                    ; isJump
    and al, [r12 + 60]              ; player.isGrounded
    test al, al
    jz .stateIdleDirection

    mov eax, 0x80000000             ; -0.0
    movd xmm2, eax

    movd xmm3, [r12 + 44]           ; player.jumpStrength
    xorps xmm3, xmm2                ; -player.jumpStrength
    movss [r12 + 28], xmm3          ; player.velocity.y

    mov dword [r12 + 48], STATE_JUMP
    mov byte [r12 + 60], 0          ; player.isJump = false

.stateIdleDirection:
    ; if (direction)
    test r14d, r14d
    jz .return

    mov dword [r12 + 48], STATE_RUN

    ApplyDirectionRun                     ; macro.inc

    ret

.stateRun:
    ; if (isJump && player.isGrounded)
    mov al, r13b                    ; isJump
    and al, [r12 + 60]              ; player.isGrounded
    test al, al
    jz .stateRunDirection

    mov eax, 0x80000000             ; -0.0
    movd xmm2, eax

    movd xmm3, [r12 + 44]           ; player.jumpStrength
    xorps xmm3, xmm2                ; -player.jumpStrength
    movss [r12 + 28], xmm3          ; player.velocity.y

    mov dword [r12 + 48], STATE_JUMP
    mov byte [r12 + 60], 0          ; player.isJump = false

.stateRunDirection:
    ; if (direction)
    test r14d, r14d
    jz .stateRunIdle

    ApplyDirectionRun               ; macro.inc

    ret

.stateRunIdle:
    mov dword [r12 + 48], STATE_IDLE
    mov dword [r12 + 24], 0.0       ; player.velocity.x
    ret

.stateJump:
    ; if player.velocity.y >= 0.0
    movss xmm2, [r12 + 28]          ; player.velocity.y
    xorps xmm3, xmm3
    comiss xmm2, xmm3
    jb .stateJumpDirection

    mov dword [r12 + 48], STATE_FALL

.stateJumpDirection:
    test r14d, r14d
    jz .return

    ApplyDirectionRun               ; macro.inc

    ret

.stateFall:
    cmp byte [r12 + 60], 0
    je .stateFallDirection

    movzx eax, r13b
    setnz al
    mov [r12 + 48], eax

.stateFallDirection:
    test r14d, r14d
    jz .return

    ApplyDirectionRun               ; macro.inc
    ret

.return:
    ret

