; rdi       = Camera*
; rsi       = Player*
_updateCamera:
    mov r12, [rsi]

    ; Get Player Position
    mov rax, [rsi + 16]

    ; Update camera target with player position
    mov [rdi + 8], rax

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

public _updatePlayer.debug
_updatePlayer:
    ; Because r12 - r14 used in setAnimationState
    ; Save player address to r15 for safety
    mov r15, rdi

    ; Save player->entity
    mov rdx, [r15]

    ; Save player->animation
    mov rsi, [r15 + 8]

    ; Set player animation based of state and direction
    mov eax, [rsi + 12]     ; AnimationState->state
    mov ecx, [rsi + 16]     ; AnimationState->direction

    cmp eax, [r15 + 40]     ; Compare state
    jne .continue

    mov ecx, [r15 + 44]     ; Compare direction
    je .continue

    ; Set Player AnimationState
    setAnimationState r15, [r15 + 40], [r15 + 44]

    ; Save back player animation to rsi
    mov rsi, [r15 + 8]

    ; Save back player entity to rdx
    mov rdx, [r15]

.continue:
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
    jb .return 

    ; Reset frameDuration
    pxor xmm1, xmm1
    movd [rdx + 44], xmm1

    ; Update currentFrame to next frame
    add dword [r15 + 48], 1

    ; Compare if currentFrame is lastFrame
    mov eax, [r15 + 48]
    cmp eax, [rsi + 4]
    jle .return

    ; Set currentFrame to startFrame
    mov eax, [rsi]
    mov [r15 + 48], eax

.return:
    ; Save frameTime to xmm3
    ; movss xmm3, xmm0

    ; Get Player velocity
    ; movsd xmm0, [r15 + 24]
    ; movss xmm1, xmm3
    ; call Vector2Scale

    ; Get Player positions
    ; movsd xmm1, [r12 + 16]
    ; call Vector2Add

    ; Save new Position into xmm2
    ; movq xmm2, xmm0

    ; TODO: Check Gravity and ground

    ; Store new position to Player
.debug:
    ; movq [r12 + 16], xmm2

    ret

