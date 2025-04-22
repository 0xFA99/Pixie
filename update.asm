; rdi       = Camera*
; rsi       = Player*
_updateCamera:
    mov r12, [rsi]

    ; Get Player Position
    movsd xmm0, [rsi + 16]

    mov rsi, [rsi]
    mov rsi, [rsi + 20]
    movss xmm1, [rsi + 8]
    mov eax, 0.5
    movd xmm2, eax
    mulss xmm1, xmm2

    addss xmm0, xmm1

    ; Update camera target with player position
    movsd [rdi + 8], xmm0

    ; Get current camera zoom
    movss xmm0, [rdi + 20]

.checkMaxZoomLimit:
    ; Check camera max zoom limit
    movss xmm1, [cameraZoomMax]
    comiss xmm0, xmm1
    jbe .checkMinZoomLimit

    ; If camera zoom more than max limit
    ; set to max limit
    movss [rdi + 20], xmm1
    jmp .return

.checkMinZoomLimit:
    ; Check camera min zoom limit
    movss xmm1, [cameraZoomMin]
    comiss xmm0, xmm1
    jae .return

    ; If camera zoom less than min limit
    ; set to min limit
    movss [rdi + 20], xmm1

.return:
    ret

; @params
; rdi       = Player*
; xmm0      = frameTime

_updatePlayer:
    ; Because r12 - r14 used in setAnimationState
    ; Save player address to r15 for safety
    mov r15, rdi

    ; ==========================================
    movss xmm3, xmm0

    movss xmm1, xmm3
    movsd xmm0, [r15 + 24]
    call Vector2Scale

    movsd xmm1, [r15 + 16]
    call Vector2Add

    pshufd xmm0, xmm0, 11100001b
    pxor xmm1, xmm1
    comiss xmm0, xmm1
    jb .set 

    ; ==========================================

    ; Save player->entity
    mov rdx, [r15]

    ; Save player->animation
    mov rsi, [r15 + 8]

    ; Set player animation based of state and direction
    mov eax, [rsi + 12]     ; AnimationState->state
    mov ecx, [rsi + 16]     ; AnimationState->direction

    cmp eax, [r15 + 40]     ; Compare state
    je .updatePosition

    mov ecx, [r15 + 44]     ; Compare direction
    je .updatePosition

    ; Set Player AnimationState
    setAnimationState r15, [r15 + 40], [r15 + 44]

    ; Save back player animation to rsi
    mov rsi, [r15 + 8]

    ; Save back player entity to rdx
    mov rdx, [r15]

.updatePosition:
    ; Update player position x
    movss xmm1, [r15 + 16]  ; position.x
    movss xmm2, [r15 + 24]  ; velocity.x
    mulss xmm2, xmm0        ; frameTime
    addss xmm1, xmm2

    ; Save back to player position x
    movss [r15 + 16], xmm1

    ; Update player position y
    movss xmm1, [r15 + 20]  ; position.y
    movss xmm2, [r15 + 28]  ; velocity.y
    mulss xmm2, xmm0        ; frameTime
    addss xmm1, xmm2

    ; Save back to player position y
    movss [r15 + 20], xmm1

    ; Get value of entity.frameDuration
    movss xmm1, [rdx + 44]

    ; Sum frameDuration with frameTime
    addss xmm1, xmm0
    movss [rdx + 44], xmm1

    ; Get value of animation.frameRate
    movss xmm2, [rsi + 8]

    ; Compare frameDuration with FPS
    ; FPS (1.0 / frameRate)
    mov eax, 1.0
    movd xmm3, eax

    divss xmm3, xmm2
    comiss xmm1, xmm3
    jb .calculateNewPosition

    ; Reset frameDuration
    pxor xmm1, xmm1
    movd [rdx + 44], xmm1

    ; Update currentFrame to next frame
    add dword [r15 + 48], 1

    ; Compare if currentFrame is lastFrame
    mov eax, [r15 + 48]
    cmp eax, [rsi + 4]
    jle .calculateNewPosition

    ; Set currentFrame to startFrame
    mov eax, [rsi]
    mov [r15 + 48], eax

.calculateNewPosition:
    ; Get Player velocity
    movss xmm1, xmm0
    movsd xmm0, [r15 + 24]
    call Vector2Scale

    ; Get Player positions
    movsd xmm1, [r12 + 16]
    call Vector2Add

    ; Check new position y if more than 0
    pshufd xmm0, xmm0, 11100001b        ; Swap x and y
    pxor xmm1, xmm1
    comiss xmm0, xmm1
    jbe .setPosition

    ; Reset new position y to 0.0
    movss xmm0, xmm1

    ; Reset Player position y to 0.0
    movd [r15 + 28], xmm1

    ; Check if player.state is STATE_FALL or STATE_JUMP
    mov dword [r15 + 40], STATE_FALL
    jne .setPosition

    mov dword [r15 + 40], STATE_JUMP
    jne .setPosition

    ; Set State to STATE_IDLE
    mov dword [r15 + 40], STATE_IDLE

.setPosition:
    ; Update new position
    pshufd xmm0, xmm0, 11100001b 
    movq [r15 + 16], xmm0

    ret

