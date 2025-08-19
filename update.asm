; @param rdi: camera
; @param rsi: player
_updateCamera:

    ; DEBUG
    ; movsd xmm0, [rsi + 16]
    ; movsd [rdi + 8], xmm0
    ; movss xmm0, [rdi + 20]

.checkMaxZoomLimit:
    movss       xmm1, [camZoomMax]
    comiss      xmm0, xmm1
    jbe         .checkMinZoomLimit

    movss       [rdi + 20], xmm1
    jmp         .return

.checkMinZoomLimit:
    movss       xmm1, [camZoomMin]
    comiss      xmm0, xmm1
    jae         .return

    movss       [rdi + 20], xmm1

.return:
    ret

; @param rdi, player
; @param xmm0, frameTime
_updatePlayer:
    mov         r15, rdi                    ; player
    mov         r14, [r15 + 8]              ; player->animState

    mov         eax, [r15 + 52]             ; player.status {state, direction}
    cmp         eax, [r14 + 12]             ; animState.status
    je          .clampVelocityX

    ; set animation states
    setAnimation r15, [r15 + 52], [r15 + 54]

.clampVelocityX:
    movss       xmm1, [r15 + 24]            ; player.velocity.x
    movss       xmm2, [r15 + 40]            ; player.topSpeed
    pxor        xmm3, xmm3                  ; 0.0
    subss       xmm3, xmm2                  ; -player.topSpeed

    ; clampss reg, min, max
    clampss xmm1, xmm3, xmm2
    movss       [r15 + 24], xmm1

    ; if (!player->isGrounded)
    cmp         byte [r15 + 60], 0          ; player.isGrounded
    jne         .updatePosition

    ; player.velocity.y += gravity * frameTime
    movss       xmm1, [r15 + 28]            ; player.velocity.y
    movss       xmm2, [gravity]             ; gravity
    mulss       xmm2, xmm0                  ; frameTime
    addss       xmm1, xmm2
    movss       [r15 + 28], xmm1            ; player.velocity.y

    pxor        xmm2, xmm2                  ; 0.0
    comiss      xmm1, xmm2                  ; player.velocity.y > 0.0
    jbe         .updatePosition

    cmp         word [r15 + 52], STATE_JUMP ; player.state
    jne         .updatePosition

    mov         word [r15 + 52], STATE_FALL

.updatePosition:
    ; player.position += player.velocity * frameTime
    movq        xmm1, [r15+24]              ; player.velocity {x, y}
    unpcklps    xmm0, xmm0                  ; {frameTime, frameTime, ..., ...}
    mulps       xmm1, xmm0
    movq        xmm2, [r15+16]              ; player.position {x, y}
    addps       xmm1, xmm2
    movq        [r15+16], xmm1

    ; player.position.y >= 0
    pxor        xmm2, xmm2                  ; 0.0
    movss       xmm1, [r15 + 20]            ; player.position.y
    comiss      xmm1, xmm2                  ; player.position.y >= 0.0
    jb          .playerInAir

    ; player landed
    movss       [r15 + 20], xmm2            ; player.position.y
    movss       [r15 + 28], xmm2            ; player.velocity.y
    mov         byte [r15 + 60], 1          ; player.isGrounded

    mov         ax, [r15 + 52]              ; player.state
    cmp         ax, STATE_FALL
    je          .setFallState
    cmp         ax, STATE_JUMP
    jne         .updateFrame

.setFallState:
    ; if player.velocity.x != 0.0
    movss       xmm1, [r15 + 24]            ; player.velocity.x
    pxor        xmm2, xmm2                  ; 0.0
    comiss      xmm1, xmm2
    je          .setIdleState

    mov         word [r15 + 52], STATE_RUN  ; player.state
    jmp         .updateFrame

.setIdleState:
    mov         word [r15 + 52], STATE_IDLE ; player.state
    jmp         .updateFrame

.playerInAir:
    mov         byte [r15 + 60], 0          ; player.isGrounded = false

.updateFrame:
    mov         r14, [r15]                  ; entity
    mov         r13, [r15 + 8]              ; animState

    movss       xmm3, [r14 + 48]            ; frameDuration
    addss       xmm3, xmm0                  ; + frameTime
    movss       [r14 + 48], xmm3

    mov         eax, 0x3f800000             ; 1.0f
    movd        xmm4, eax
    rcpss       xmm4, [r13 + 8]             ; fast 1.0 / frameRate
    comiss      xmm3, xmm4
    jae         .nextFrame
    ret

.nextFrame:
    mov     dword [r14 + 48], 0             ; reset frameDuration

    ; player.currentFrame + 1
    mov     eax, [r15 + 56]
    inc     eax
    mov     [r15 + 56], eax

    cmp     eax, [r13 + 4]                  ; > endFrame ?
    ja      .resetFrame
    ret

.resetFrame:
    mov     edx, [r13]                      ; startFrame
    mov     [r15 + 56], edx
    ret

