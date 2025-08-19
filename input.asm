_inputCamera:
    call GetMouseWheelMove

    movss xmm1, [camZoomLevel]
    mulss xmm1, xmm0

    movss xmm0, [rdi + 20]
    addss xmm0, xmm1

    movd [rdi + 20], xmm0

    ret

_inputPlayer:
    mov         r12, rdi                    ; player

    mov         edi, KEY_UP
    call        IsKeyPressed
    mov         r13b, al

    mov         edi, KEY_RIGHT
    call        IsKeyDown
    movzx       r14d, al

    mov         edi, KEY_LEFT
    call        IsKeyDown
    movzx       r15d, al

    ; direction (right = 1, left = -1, none = 0)
    sub         r14d, r15d

    movss       xmm1, [r12 + 24]            ; player.velocity.x
    movss       xmm2, [r12 + 32]            ; player.acceleration
    movss       xmm3, [r12 + 36]            ; player.deceleration

    mulss       xmm2, xmm0                  ; player.acceleration * frameTime
    mulss       xmm3, xmm0                  ; player.deceleration * frameTime

    ; jump in STATE_IDLE and STATE_RUN states when grounded
    test        r13b, r13b                  ; if (isJump)
    jz          .checkState

    cmp         byte [r12 + 60], 0          ; player.isGrounded
    je          .checkState

    mov         ax, [r12 + 52]              ; player.state
    cmp         ax, STATE_IDLE
    je          .doJump
    cmp         ax, STATE_RUN
    jne         .checkState

.doJump:
    movss       xmm4, [r12 + 44]            ; player.jumpForce
    pxor        xmm5, xmm5
    subss       xmm5, xmm4                  ; -player.jumpForce
    movss       [r12 + 28], xmm5            ; player.velocity.y
    mov         word [r12 + 52], STATE_JUMP ; player.state
    mov         byte [r12 + 60], 0          ; player.isGrounded = false
    ret

.checkState:
    mov         ax, [r12 + 52]              ; player.state
    cmp         ax, STATE_IDLE
    je          .stateIdle
    cmp         ax, STATE_RUN
    je          .stateRun
    cmp         ax, STATE_JUMP
    je          .stateJump
    cmp         ax, STATE_FALL
    je          .stateFall
    cmp         ax, STATE_BREAK
    je          .stateBreak

.stateIdle:
    test        r14d, r14d                  ; if (direction)
    jz          .done

    mov         word [r12 + 52], STATE_RUN  ; player.state
    mov         [r12 + 54], r14w            ; player.direction

    ; player.velocity.x += direction * acceleration * frameTime
    cvtsi2ss    xmm4, r14d                  ; direction
    mulss       xmm4, xmm2
    addss       xmm1, xmm4
    movss       [r12 +  24], xmm1           ; player.velocity.x
    ret

.stateRun:
    test        r14d, r14d                  ; if (direction)
    jz          .stateRunNoInput

    ; if changing direction at high speed
    movss       xmm4, [r12 + 48]            ; player.breakThreshold
    movss       xmm5, xmm1                  ; player.velocity.x

    ; if direction chaning
    pxor        xmm6, xmm6                  ; 0.0
    comiss      xmm5, xmm6                  ; player.velocity.x > 0.0
    jbe         .checkNegativeLevel

    cmp         r14d, DIRECTION_LEFT        ; if (direction == LEFT)
    jne         .stateRunContinue
    jmp         .checkBreakThreshold

.checkNegativeLevel:
    comiss      xmm6, xmm5
    jbe         .stateRunContinue

    cmp         r14d, DIRECTION_RIGHT       ; if (direction == RIGHT)
    jne         .stateRunContinue

.checkBreakThreshold:
    ; if fabsf(player.velocity.x) > player.breakThreshold
    movss       xmm7, xmm5                  ; player.velocity.x
    fabsf       xmm7                        ; fabsf(player.velocity.x)
    comiss      xmm7, xmm4                  ; player.breakThreshold
    jbe         .stateRunContinue

    mov         word [r12 + 52], STATE_BREAK; player.state
    ret

.stateRunContinue:
    mov         [r12 + 54], r14w            ; player.direction

    ; player.velocity.x += direction * acceleration * frameTime
    cvtsi2ss    xmm4, r14d                  ; direction
    mulss       xmm4, xmm2                  ; player.acceleration
    addss       xmm1, xmm4
    movss       [r12 + 24], xmm1            ; player.velocity.x
    ret

.stateRunNoInput:
    ; no input (idle or break)
    ; if fabsf(player.velocity.x) > player.breakThreshold
    movss       xmm4, [r12 + 48]            ; player.breakThreshold
    movss       xmm5, xmm1                  ; player.velocity.x
    fabsf       xmm5                        ; fabsf(player.velocity.x)
    comiss      xmm5, xmm4                  ; player.breakThreshold
    jbe         .stateRunStop

    mov         word [r12 + 52], STATE_BREAK; player.state
    ret

.stateRunStop:
    mov         dword [r12 + 24], 0.0       ; reset player.velocity.x
    mov         word [r12 + 52], STATE_IDLE ; player.state
    ret

.stateJump:
    ; if plyaer.velocity.y >= 0.0 (falling)
    movss       xmm4, [r12 + 28]            ; player.velocity.y
    pxor        xmm5, xmm5                  ; 0.0
    comiss      xmm4, xmm5
    jb          .stateJumpCheckDirection    ; still going up ^_^

    mov         word [r12 + 52], STATE_FALL ; player.state

.stateJumpCheckDirection:
    test        r14d, r14d                  ; if (direction)
    jz          .done

    mov         [r12 + 54], r14w            ; player.direction

    ; player.velocity.x += direction * acceleration * frameTime
    cvtsi2ss    xmm4, r14d                  ; direction
    mulss       xmm4, xmm2                  ; player.acceleration
    addss       xmm1, xmm4
    movss       [r12 + 24], xmm1            ; player.velocity.x
    ret

.stateFall:
    ; if (player.isGrounded)
    cmp         byte [r12 + 60], 00         ; player.isGrounded
    je          .stateFallCheckDirection

    test        r14d, r14d
    jz          .stateFallToIdle

    mov         word [r12 + 52], STATE_RUN  ; player.state
    jmp         .stateFallCheckDirection

.stateFallToIdle:
    mov         word [r12 + 52], STATE_IDLE

.stateFallCheckDirection:
    test        r14d, r14d                  ; if (direction)
    jz          .done

    mov         [r12 + 54], r14w            ; player.direction

    ; player.velocity.x += direction * acceleration * frameTime
    cvtsi2ss    xmm4, r14d                  ; direction
    mulss       xmm4, xmm2                  ; player.acceleration
    addss       xmm1, xmm4
    movss       [r12 + 24], xmm1            ; player.velocity.x
    ret

.stateBreak:
    ; apply deceleration
    ; if fabsf(player.velocity.x) > player.breakThreshold
    movss       xmm4, xmm1                  ; player.velocity.x
    fabsf       xmm4                        ; fabsf(player.velocity.x)
    comiss      xmm4, xmm3                  ; player.deceleration
    jbe         .stateBreakStop

    ; apply deceleration with sign
    pxor        xmm5, xmm5                  ; 0.0
    comiss      xmm1, xmm5                  ; player.velocity.x > 0.0
    jbe         .stateBreakNegative

    subss       xmm1, xmm3                  ; player.velocity -= deceleration
    jmp         .stateBreakUpdate

.stateBreakNegative:
    addss       xmm1, xmm3                  ; player.velocity += deceleration
    jmp         .stateBreakUpdate

.stateBreakStop:
    pxor        xmm1, xmm1                  ; 0.0
    mov         word [r12 + 52], STATE_IDLE

.stateBreakUpdate:
    movss       [r12 + 24], xmm1            ; player.velocity.x

    test        r14d, r14d
    jz          .done

    pxor        xmm5, xmm5                  ; 0.0
    mov         al, 0

    ; if player.velocity.x > 0.0 && direction == DIRECTION_RIGHT
    comiss      xmm1, xmm5
    jbe         .checkNegativeBreak

    cmp         r14d, DIRECTION_RIGHT
    jne         .done
    mov         al, 1
    jmp         .stateBreakToRun

.checkNegativeBreak:
    ; if player.velocity.x < 0.0 && direction == DIRECTION_LEFT
    comiss      xmm5, xmm1
    jbe         .done

    cmp         r14d, DIRECTION_LEFT
    jne         .done
    mov         al, 1

.stateBreakToRun:
    test        al, al
    jz          .done

    mov         word [r12 + 52], STATE_RUN  ; player.state
    mov         [r12 + 54], r14w            ; player.direction

.done:
    ret

