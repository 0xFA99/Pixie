; @param rdi: camera
; @param rsi: player
_updateCamera:

    ; movsd xmm0, [rsi + 16]
    ; movsd [rdi + 8], xmm0

    ; movss xmm0, [rdi + 20]

.checkMaxZoomLimit:
    movss xmm1, [cameraZoomMax]
    comiss xmm0, xmm1
    jbe .checkMinZoomLimit

    movss [rdi + 20], xmm1
    jmp .return

.checkMinZoomLimit:
    movss xmm1, [cameraZoomMin]
    comiss xmm0, xmm1
    jae .return

    movss [rdi + 20], xmm1

.return:
    ret

; @param rdi, player
; @param xmm0, frameTime
_updatePlayer:
    mov r15, rdi                    ; player

    mov r13, [r15 + 8]              ; player->animState

    mov eax, [r15 + 48]             ; player.state
    mov ecx, [r15 + 52]             ; player.direction

    ; compare player.state and anim.state
    cmp eax, [r13 + 16]             ; anim.state
    jne .setAnim

    ; compare player.direction and anim.direction
    cmp ecx, [r13 + 20]             ; anim.direction
    jne .setAnim

.clampVelocityX:
    ; save back player->entity
    mov r12, [r15]                  ; player->entity

    ; save back player->anim
    mov r13, [r15 + 8]              ; player->anim

    movss xmm1, [r15 + 24]          ; player.velocity.x
    movss xmm2, [r15 + 40]          ; player.topSpeed
    xorps xmm3, xmm3
    subss xmm3, xmm2                ; -player.topSpeed

    ; clampss reg, min, max
    clampss xmm1, xmm3, xmm2
    movss [r15 + 24], xmm1          ; player.velocity.x

    ; if player.isGrounded
    cmp byte [r15 + 60], 0          ; player.isGrounded
    jnz .updatePosition

    ; update player.velocity.y
    movss xmm1, [r15 + 28]          ; payer.velocity.y
    movss xmm2, [gravity]
    mulss xmm2, xmm0                ; frameTime
    addss xmm1, xmm2
    movss [r15 + 28], xmm1          ; player.velocity.y

    ; if player.velocity.y > 0.0
    xorps xmm2, xmm2                ; 0.0
    comiss xmm1, xmm2               ; player.velocity.y
    jbe .updatePosition

    ; check player.state == STATE_JUMP
    cmp dword [r15 + 48], STATE_JUMP
    jne .updatePosition

    mov dword [r15 + 48], STATE_FALL

.updatePosition:
    ; player.position += position + velocity * frameTime
    movss xmm1, [r15 + 24]          ; player.velocity.x
    movss xmm2, [r15 + 28]          ; player.velocity.y
    mulss xmm1, xmm0                ; frameTime
    mulss xmm2, xmm0                ; frameTime
    addss xmm1, [r15 + 16]          ; player.position.x
    addss xmm2, [r15 + 20]          ; player.position.y
    movss [r15 + 16], xmm1
    movss [r15 + 20], xmm2

    ; if player.position.y >= 0.0
    xorps xmm2, xmm2                ; 0.0
    movss xmm1, [r15 + 20]          ; player.position.y
    comiss xmm1, xmm2
    jb .playerOnAir

    movss [r15 + 20], xmm2          ; player.position.y = 0.0
    movss [r15 + 28], xmm2          ; player.velocity.y = 0.0
    mov byte [r15 + 60], 1          ; player.isGrouneded = true
    mov eax, [r15 + 48]

    ; state(STATE_JUMP -> 0), (STATE_FALL -> 1)
    sub eax, 2                      ; eax = state - 2
    cmp eax, 1                      ; if 0 or 1
    setbe cl                        ; cl = 1 if STATE_JUMP or STATE_FALL
    test cl, dl
    jz .updateFrame                 ; if != STATE_JUMP and STATE_FALL

    ; if player.velocity.x != 0.0
    movss xmm1, [r15 + 24]
    ucomiss xmm1, xmm2
    mov eax, STATE_IDLE
    mov ecx, STATE_RUN
    cmovne eax, ecx

    mov [r15 + 48], eax             ; player.state

    jmp .updateFrame

.playerOnAir:
    mov byte [r15 + 60], 0          ; player.isGrounded = false

.updateFrame:
    ; frameDuration += frameTime (xmm0)
    movss   xmm1, [r12 + 52]        ; entity->frameDuration
    addss   xmm1, xmm0
    movss   [r12 + 52], xmm1

    ; frameDuration >= 1.0 / frameRate
    mov eax, 1.0
    movd xmm2, eax

    ; Calculate 1.0 / frameRate
    rcpss   xmm2, [r13 + 8]         ; xmm2 = 1.0 / animState.frameRate
    comiss  xmm1, xmm2
    jb .ret

.nextFrame:
    xorps   xmm4, xmm4              ; 0.0f
    movss   [r12 + 52], xmm4        ; reset entity->frameDuration

    add     dword [r15 + 56], 1     ; player->currentFrame++

    mov     eax, [r13 + 4]          ; animStates.endFrame
    cmp     [r15 + 56], eax         ; if currentFrame > endFrame
    ja      .resetFrame             ; must reset to startFrame

.ret:
    ret

.resetFrame:
    mov     eax, [r13]              ; startFrame
    mov     [r15 + 56], eax         ; reset currentFrame
    ret

.setAnim:
    ; set player animation (required r12 + r14)
    setAnimation r15, [r15 + 48], [r15 + 52]

    jmp .clampVelocityX

