_inputCamera:
    call GetMouseWheelMove

    movss xmm1, [camZoomLevel]
    mulss xmm1, xmm0

    movss xmm0, [rdi + 20]
    addss xmm0, xmm1

    movd [rdi + 20], xmm0

    ret

; _inputPlayer:
;     mov r12, rdi
;
;     ; if KEY_UP active
;     mov edi, KEY_UP
;     call IsKeyPressed
;     mov r13b, al
;
;     ; if KEY_RIGHT active
;     mov edi, KEY_RIGHT
;     call IsKeyDown
;     movzx r14d, al
;
;     ; if KEY_LEFT active
;     mov edi, KEY_LEFT
;     call IsKeyDown
;     movzx r15d, al
;
;     ; direction = right - left
;     sub r14d, r15d
;
;     ; switch (player.state)
;     mov eax, [r12 + 48]             ; player.state
;     cmp eax, STATE_IDLE
;     je .stateIdle
;
;     cmp eax, STATE_RUN
;     je .stateRun
;
;     cmp eax, STATE_JUMP
;     je .stateJump
;
;     cmp eax, STATE_FALL
;     je .stateFall
;
;     ret
;
; .stateIdle:
;     ; if (isJump && player.isGrounded)
;     mov al, r13b                    ; isJump
;     and al, [r12 + 60]              ; player.isGrounded
;     test al, al
;     jz .stateIdleDirection
;
;     mov eax, 0x80000000             ; -0.0
;     movd xmm1, eax
;
;     movd xmm2, [r12 + 44]           ; player.jumpStrength
;     xorps xmm2, xmm1                ; -player.jumpStrength
;     movss [r12 + 28], xmm2          ; player.velocity.y
;
;     mov dword [r12 + 48], STATE_JUMP
;     mov byte [r12 + 60], 0          ; player.isJump = false
;
; .stateIdleDirection:
;     ; if (direction)
;     test r14d, r14d
;     jz .return
;
;     mov dword [r12 + 48], STATE_RUN
;
;     ApplyDirectionRun                     ; macro.inc
;
;     ret
;
; .stateRun:
;     ; if (isJump && player.isGrounded)
;     mov al, r13b                    ; isJump
;     and al, [r12 + 60]              ; player.isGrounded
;     test al, al
;     jz .stateRunDirection
;
;     mov eax, 0x80000000             ; -0.0
;     movd xmm1, eax
;
;     movd xmm2, [r12 + 44]           ; player.jumpStrength
;     xorps xmm2, xmm1                ; -player.jumpStrength
;     movss [r12 + 28], xmm2          ; player.velocity.y
;
;     mov dword [r12 + 48], STATE_JUMP
;     mov byte [r12 + 60], 0          ; player.isJump = false
;
; .stateRunDirection:
;     ; if (direction)
;     test r14d, r14d
;     jz .stateRunBreakOrIdle
;
;     movss xmm1, [r12 + 24]          ; player.velocity.x
;
;     ; fabsf(velocity)
;     mov eax, 0x7FFFFFFF
;     movd xmm2, eax
;     movss xmm4, xmm1
;     andps xmm4, xmm2               ; xmm4 = fabsf(velocity
;
;     ; if fabsf < BREAK_THRESHOLD, skip
;     mov eax, BREAK_THRESHOLD
;     movd xmm3, eax
;     comiss xmm4, xmm3
;     jbe .stateRunApplyDirection
;
;     ; velocity sign
;     xorps xmm2, xmm2
;     movss xmm4, xmm1
;     comiss xmm4, xmm2
;     setg al                        ; velocity > 0
;     setl ah                        ; velocity < 0
;
;     cmp r14d, DIRECTION_LEFT
;     sete cl
;     and al, cl
;
;     cmp r14d, DIRECTION_RIGHT
;     sete ch
;     and ah, ch
;
;     or al, ah
;     test al, al
;     jz .stateRunApplyDirection
;
;     mov dword [r12 + 48], STATE_BREAK
;     ret
;
; .stateRunApplyDirection:
;     ApplyDirectionRun               ; macro.inc
;
;     ret
;
; .stateRunBreakOrIdle:
;     ; mov dword [r12 + 48], STATE_IDLE
;     ; mov dword [r12 + 24], 0.0       ; player.velocity.x
;     movss xmm4, xmm1                ; player.velocity.x
;
;     mov eax, 0x7FFFFFFF             ; mask abs
;     movd xmm2, eax
;     andps xmm4, xmm2                ; fabsf(player.velocity.x)
;
;     mov eax, BREAK_THRESHOLD
;     movd xmm2, eax
;     comiss xmm4, xmm2
;     seta al
;     movzx ecx, al
;
;     ; State: Idle / Break
;     mov eax, STATE_IDLE
;     mov edx, STATE_BREAK
;     test ecx, ecx
;     cmovnz eax, edx
;     mov [r12 + 48], eax
;
;     movss xmm3, xmm1
;     test ecx, ecx
;     jne .keepVelocity
;
;     xorps xmm3, xmm3
;
; .keepVelocity:
;     movss [r12 + 24], xmm3
;     ret
;
; .stateJump:
;     ; if player.velocity.y >= 0.0
;     movss xmm1, [r12 + 28]          ; player.velocity.y
;     xorps xmm2, xmm2
;     comiss xmm1, xmm2
;     jb .stateJumpDirection
;
;     mov dword [r12 + 48], STATE_FALL
;
; .stateJumpDirection:
;     test r14d, r14d
;     jz .return
;
;     ApplyDirectionRun               ; macro.inc
;
;     ret
;
; .stateFall:
;     cmp byte [r12 + 60], 0
;     je .stateFallDirection
;
;     movzx eax, r13b
;     setnz al
;     mov [r12 + 48], eax
;
; .stateFallDirection:
;     test r14d, r14d
;     jz .return
;
;     ApplyDirectionRun               ; macro.inc
;     ret
;
; .return:
;     ret



_inputPlayer:
    mov r12, player

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

    cmp eax, STATE_BREAK
    je .stateBreak

    ret

.stateIdle:
    ; if (isJump && player.isGrounded)
    mov al, r13b                    ; isJump
    and al, [r12 + 60]              ; player.isGrounded
    test al, al
    jz .stateIdleDirection

    ; negation player.jumpStrength
    movd xmm1, [r12 + 44]           ; player.jumpStrength
    negss xmm1                      ; -player.jumpStrength

    ; player.velocity.y = -player.jumpStrength
    movss [r12 + 28], xmm1          ; player.velocity.y

    ; update player.state
    mov dword [r12 + 48], STATE_JUMP
    mov byte [r12 + 60], 0          ; player.isGrounded

.stateIdleDirection:
    test r14d, r14d                 ; if (direction)
    jz .ret

    ; update player.state
    mov dword [r12 + 48], STATE_RUN

    ; (direction > 0) ? DIRECTION_RIGHT : DIRECTION_LEFT
    ; mov eax, r14d
    ; mov ecx, 1
    ; test eax, eax
    ; cmovs ecx, eax
    ; sar ecx, 31
    ; lea ecx, [ecx * 2 + 1]
    ; mov [r12 + 52], ecx

    updateDirection r14d
    mov [r12 + 52], eax

    ; player.velocity.x += direction * acceleration * frameTime
    cvtsi2ss xmm1, r14d             ; (float)direction
    mulss xmm1, [r12 + 32]          ; player.acceleration
    mulss xmm1, xmm0                ; frameTime
    movss xmm2, [r12 + 24]          ; player.velocity.x
    addss xmm2, xmm1
    movss [r12 + 24], xmm2

    ret

.stateRun:
    ; if (isJump && player.isGrounded)
    mov al, r13b                    ; isJump
    and al, [r12 + 60]              ; player.isGrounded
    test al, al
    jz .stateRunDirection

    ; negation player.jumpStrength
    movd xmm1, [r12 + 44]           ; player.jumpStrength
    negss xmm1                      ; -player.jumpStrength

    ; player.velocity.y = -player.jumpStrength
    movss [r12 + 28], xmm1          ; player.velocity.y

    ; update player.state
    mov dword [r12 + 48], STATE_JUMP
    mov byte [r12 + 60], 0          ; player.isGrounded

.stateRunDirection:
    test r14d, r14d                 ; if (direction)
    jz .stateRunBreak

    ; CHECK DIRECTION
    ; @param 1 - velocity
    ; @param 2 - direction
    checkDirection xmm1, r14d
    test al, al
    jz .stateRunApplyDirection

    movss xmm1, [r12 + 24]          ; player.velocity.x
    fabsf xmm1                      ; fabsf(player.velocity.x)

    mov eax, BREAK_THRESHOLD
    movd xmm2, eax
    comiss xmm1, xmm2
    jbe .stateRunApplyDirection

    mov dword [r12 + 48], STATE_BREAK
    ret

.stateRunApplyDirection:
    ; UPDATE DIRECTION
    ; (direction > 0) ? DIRECTION_RIGHT : DIRECTION_LEFT
    ; mov eax, r14d
    ; mov ecx, 1
    ; test eax, eax
    ; cmovs ecx, eax
    ; sar ecx, 31
    ; lea ecx, [ecx * 2 + 1]
    ; mov [r12 + 52], ecx

    updateDirection r14d
    mov [r12 + 52], eax

    ; player.velocity.x += direction * acceleration * frameTime
    cvtsi2ss xmm1, r14d             ; (float)direction
    mulss xmm1, [r12 + 32]          ; player.acceleration
    mulss xmm1, xmm0                ; frameTime
    movss xmm2, [r12 + 24]          ; player.velocity.x
    addss xmm2, xmm1
    movss [r12 + 24], xmm2
    ret

.stateRunBreak:
    movss xmm1, [r12 + 24]          ; player.velocity.x
    fabsf xmm1                      ; fabsf(player.velocity.x)

    ; ; TODO))
    ; ; throw this in the struct,
    ; ; if im feelin motivated
    mov eax, BREAK_THRESHOLD
    movd xmm2, eax
    comiss xmm1, xmm2
    jbe .stateRunIdle

    mov dword [r12 + 48], STATE_BREAK
    ret

.stateRunIdle:
    pxor xmm1, xmm1
    movss [r12 + 24], xmm2
    ; mov dword [r12 + 24], 0.0       ; player.velocity.x
    mov dword [r12 + 48], STATE_IDLE
    ret

.stateJump:
    ; if player.velocity.y >= 0.0
    movss xmm1, [r12 + 28]            ; player.velocity.y
    pxor xmm2, xmm2
    comiss xmm1, xmm2
    jb .stateJumpDirection

    mov dword [r12 + 48], STATE_FALL
    ret

.stateJumpDirection:
    ; UPDATE DIRECTION
    ; (direction > 0) ? DIRECTION_RIGHT : DIRECTION_LEFT
    ; mov eax, r14d
    ; mov ecx, 1
    ; test eax, eax
    ; cmovs ecx, eax
    ; sar ecx, 31
    ; lea ecx, [ecx * 2 + 1]
    ; mov [r12 + 52], ecx

    updateDirection r14d
    mov [r12 + 52], eax

    ; player.velocity.x += direction * acceleration * frameTime
    cvtsi2ss xmm1, r14d             ; (float)direction
    mulss xmm1, [r12 + 32]          ; player.acceleration
    mulss xmm1, xmm0                ; frameTime
    movss xmm2, [r12 + 24]          ; player.velocity.x
    addss xmm2, xmm1
    movss [r12 + 24], xmm2
    ret

.stateFall:
    mov al, [r12 + 60]              ; player.isGrounded
    test al, al
    jz .stateFallDirection

    ; player.state = direction ? STATE_RUN : STAE_IDLE
    test r14d, r14d
    setnz al
    movzx eax, al
    mov [r12 + 48], eax
    ret

.stateFallDirection:
    test r14d, r14d
    jz .ret

    ; UPDATE DIRECTION
    ; (direction > 0) ? DIRECTION_RIGHT : DIRECTION_LEFT
    ; mov eax, r14d
    ; mov ecx, 1
    ; test eax, eax
    ; cmovs ecx, eax
    ; sar ecx, 31
    ; lea ecx, [ecx * 2 + 1]
    ; mov [r12 + 52], ecx

    updateDirection r14d
    mov [r12 + 52], eax

    ; player.velocity.x += direction * acceleration * frameTime
    cvtsi2ss xmm1, r14d             ; (float)direction
    mulss xmm1, [r12 + 32]          ; player.acceleration
    mulss xmm1, xmm0                ; frameTime
    movss xmm2, [r12 + 24]          ; player.velocity.x
    addss xmm2, xmm1
    movss [r12 + 24], xmm2
    ret

.stateBreak:
    movss xmm1, [r12 + 36]          ; player.deceleration
    mulss xmm1, xmm0                ; frameTime

    movss xmm2, [r12 + 24]          ; player.velocity.x (1)
    movss xmm3, xmm2                ; player.velocity.x (2)

    movss xmm4, xmm3                ; player.velocity.x (3)
    fabsf xmm4                      ; fabsf(player.velocity.x)
    comiss xmm4, xmm1               ; fabs <= deceleration
    ja .stateBreakSign

    mov dword [r12 + 24], 0.0
    jmp .stateBreak2Idle

.stateBreakSign:
    movss xmm4, xmm3
    signss xmm4                     ; xmm4 = sign
    mulss xmm4, xmm1                ; xmm4 = sign * deceleration
    subss xmm3, xmm4                ; player.velocity.x -= xmm4
    movss [r12 + 24], xmm3

.stateBreak2Idle:
    ; if player.velocity.x == 0.0
    pxor xmm3, xmm3
    comiss xmm2, xmm3
    jne .stateBreakDirection

    mov dword [r12 + 48], STATE_IDLE
    ret

.stateBreakDirection:
    test r14d, r14d
    jz .ret

    checkDirection xmm2, r14d
    test al, al
    jz .ret

    ; (direction > 0) ? DIRECTION_RIGHT : DIRECTION_LEFT
    ; mov eax, r14d
    ; mov ecx, 1
    ; test eax, eax
    ; cmovs ecx, eax
    ; sar ecx, 31
    ; lea ecx, [ecx * 2 + 1]
    ; mov [r12 + 52], ecx

    updateDirection r14d
    mov [r12 + 52], eax

    mov dword [r12 + 48], STATE_RUN

.ret:
    ret

