; @param rdi: camera
; @param rsi: player
_updateCamera:

    movsd xmm0, [rsi + 16]
    movsd [rdi + 8], xmm0

    movss xmm0, [rdi + 20]

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
    jne .clampVelocityX

    ; compare player.direction and anim.direction
    cmp ecx, [r13 + 20]             ; anim.direction
    jne .clampVelocityX

    ; set player animation (required r12 - r14)
    setAnimation  r15, [r15 + 48], [r15 + 52]

    ; save back player->entity
    mov r12, [r15]                  ; player->entity

    ; save back player->anim
    mov r13, [r15 + 8]              ; player->anim

.clampVelocityX:
    movss xmm1, [r15 + 52]          ; player.velocity.x
    movss xmm2, [r15 + 40]          ; player.topSpeed
    xorps xmm3, xmm3
    subss xmm3, xmm2                ; -player.topSpeed

    ; clampss reg, min, max
    clampss xmm1, xmm3, xmm2
    movss [r15 + 52], xmm1          ; player.velocity.x

    ; check if player isGrounded
    mov al, [r15 + 60]              ; player.isGrounded
    test al, al
    jnz .updatePosition

    ; update player.velocity.y
    movss xmm1, [gravity]
    mulss xmm1, xmm0
    movss [r15 + 56], xmm1          ; player.velocity.y

    ; check player.velocity.y > 0.0
    xorps xmm1, xmm1
    comiss xmm0, xmm1
    jb .updatePosition

    ; check player.state == STATE_JUMP
    cmp dword [r15 + 48], STATE_JUMP
    jne .updatePosition

    mov dword [r15 + 48], STATE_FALL

.updatePosition:
    movss xmm1, [r15 + 52]
    movss xmm2, [r15 + 56]
    mulss xmm1, xmm0
    mulss xmm2, xmm0
    addss xmm1, [r15 + 24]
    addss xmm2, [r15 + 28]
    movss [r15 + 24], xmm1
    movss [r15 + 28], xmm2

    ; check if player.position >= 0.0
    xorps xmm2, xmm2                ; xmm2 = 0.0
    movss xmm1, [r15 + 20]
    jb .playerOnAir

    movss [r15 + 20], xmm2          ; player.position.y = 0.0
    movss [r15 + 28], xmm2          ; player.velocity.y = 0.0
    mov byte [r15 + 60], 1          ; player.isGrounded = true

    ; check if player.state == STATE_FALL
    cmp dword [r15 + 48], STATE_FALL
    jne .updateFrame

    ; check if player.state == STATE_JUMP
    cmp dword [r15 + 48], STATE_JUMP
    jne .updateFrame

    ; check if player.velocity.x != 0.0
    movss xmm1, [r15 + 52]          ; player.velocity.x
    ucomiss xmm1, xmm2
    mov eax, STATE_IDLE             ; if velocity == 0, STATE_IDLE
    mov ecx, STATE_RUN
    cmovne eax, ecx                 ; if velocity != 0, STATE_RUN
    mov [r15 + 48], eax             ; player.state = eax

    jmp .updateFrame

.playerOnAir:
    mov byte [r15 + 60], 0          ; player.isGrounded = false

.updateFrame:
    ; update entity.frameDuration
    movss xmm1, [r12 + 52]          ; entity.frameDuration
    addss xmm1, xmm0                ; frameTime
    movss [r12 + 52], xmm1

    mov eax, 1.0
    movd xmm2, eax

    movss xmm1, [r12 + 52]          ; entity.frameDuration
    movss xmm3, [r13 + 8]           ; animState.frameRate
    rcpss xmm2, xmm3                ; 1.0 / frameRate
    comiss xmm1, xmm2
    jae .nextFrame

    ret

.nextFrame:
    xorps xmm2, xmm2
    movss [r12 + 52], xmm2          ; entity.frameDuration = 0.0
    add dword [r15 + 56], 1         ; player.currentFrame++

    ; check player.currentFrame > endFrame
    mov eax, [r15 + 56]             ; player.currentFrame
    cmp eax, [r13 + 4]              ; animState.endFrame
    ja .resetFrame

    ret

.resetFrame:
    mov eax, [r13]                  ; animState.startFrame
    mov [r12 + 56], eax             ; player.startFrame

    ret

