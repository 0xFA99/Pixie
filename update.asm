; ============== PARAMETERS ==============
; rdi = Camera*
; rsi = Player*

_UpdateCamera:
    push rbp
    mov rbp, rsp

    movss xmm0, [rsi + 16]

    mov rax, [rsi]
    mov rax, [rax + 24]
    movss xmm1, [rax + 8]

    mov eax, 2.0
    movd xmm2, eax

    divss xmm1, xmm2
    addss xmm0, xmm1
    movss [rdi + 8], xmm0

    call GetMouseWheelMove
    movss xmm1, [cameraZoom]
    mulss xmm1, xmm0
    movss xmm0, [rdi + 20]
    addss xmm0, xmm1
    movss [rdi + 20], xmm0

.cameraZoomMax:
    mov eax, 3.0
    movd xmm1, eax
    movss xmm0, [rdi + 20]
    comiss xmm0, xmm1
    jbe .cameraZoomMin

    movss [rdi + 20], xmm1

.cameraZoomMin:
    mov eax, 0.1
    movd xmm0, eax
    movss xmm1, [rdi + 20]
    comiss xmm0, xmm1
    jb .return

    movss [rdi + 20], xmm0

.return:
    pop rbp
    ret

_UpdatePlayer:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    mov [rbp - 8], rdi
    movd [rbp - 16], xmm0

;   struct PlayerStatus status = player->status;
    mov rax, [rbp - 8]
    mov rdx, [rax + 40]
    mov [rbp - 24], rdx

;   struct AnimationState *animation = player->animation;
    mov rax, [rbp - 8]
    mov rdx, [rax + 8]
    mov [rbp - 32], rdx

;   if (status.state != animation->state || status.direction != animation->direction)
;       SetPlayerAnimation(player, status.state, status.direction);
    mov edx, [rbp - 24]
    mov rax, [rbp - 32]
    mov eax, [rax + 12]
    cmp edx, eax                ; status.state != animation->state
    jne .setPlayerAnimation

    mov edx, [rbp - 20]
    mov rax, [rbp - 32]
    mov eax, [rax + 16]
    cmp edx, eax
    je .updatePlayerAnimation

.setPlayerAnimation:
    mov rdi, [rbp - 8]
    mov esi, [rbp - 24]
    mov edx, [rbp - 20]
    call _SetPlayerAnimation

.updatePlayerAnimation:
    mov rax, [rbp - 8]          ; player*

;   player->movement.position.x + player->movement.velocity.x * frameTime
    movss xmm1, [rax + 16]      ; player->movement.position.x
    movss xmm0, [rax + 24]      ; player->movement.velocity.x
    mulss xmm0, [rbp - 16]      ; frameTime
    addss xmm1, xmm0

;   player->movement.position.y + player->movement.velocity.y * frameTime
    movss xmm2, [rax + 20]      ; player.movement.position.y 
    movss xmm0, [rax + 28]      ; player.movement.velocity.y
    mulss xmm0, [rbp - 16]      ; frameTime
    addss xmm0, xmm2

    movss [rax + 16], xmm1
    movss [rax + 20], xmm0

;   float *frameDuration = &player->entity->frameDuration;
    mov rax, [rax]
    add rax, 52
    mov [rbp - 24], rax

;   float playerAnimFPS = player->animation->animationSequence.frameRate;
    mov rax, [rbp - 8]
    mov rax, [rax + 8]
    movss xmm0, [rax + 8]
    movss [rbp - 28], xmm0

;   *frameDuration += frameTime;
    mov rax, [rbp - 24]
    movss xmm0, [rax]
    addss xmm0, [rbp - 16]
    movss [rax], xmm0

    ; 1.0f 0x3F800000
    mov eax, 0x3F800000
    movd xmm0, eax
    movss [rbp - 32], xmm0

;   if (*frameDuration >= 1.0f / playerAnimFPS) {
    mov rax, [rbp - 24]
    movss xmm0, [rax]

    movss xmm1, [rbp - 32]
    divss xmm1, [rbp - 28]
    comiss xmm0, xmm1
    jnb .loopAnimation

    jmp .return

.loopAnimation:
;   *frameDuration = 0.0f;
    pxor xmm0, xmm0
    mov rax, [rbp - 24]
    movss [rax], xmm0

;   player->currentFrame++;
    mov rax, [rbp - 8]
    mov edx, [rax + 48]
    add edx, 1
    mov [rax + 48], edx

;   if (player->currentFrame > player->animation->animationSequence.endFrame) {
    mov edx, [rax + 48]
    mov rax, [rax + 8]
    mov eax, [rax + 4]
    cmp edx, eax
    jle .return

;   player->currentFrame = player->animation->animationSequence.startFrame;
    mov rax, [rbp - 8]
    mov rax, [rax + 8]
    mov edx, [rax]
    mov rax, [rbp - 8]
    mov [rax + 48], edx

.return:
    add rsp, 32
    pop rbp
    ret

_UpdateBackground:
    push rbp
    mov rbp, rsp

.checkRightKey:
    mov edi, 262
    call IsKeyDown
    test al, al
    je .checkLeftKey

    mov eax, 0.5
    movd xmm1, eax
    movss xmm0, [backgroundScrolling]
    subss xmm0, xmm1
    movss [backgroundScrolling], xmm0

    mov eax, 1.0
    movd xmm1, eax
    movss xmm0, [midgroundScrolling]
    subss xmm0, xmm1
    movss [midgroundScrolling], xmm0

    mov eax, 2.0
    movd xmm1, eax
    movss xmm0, [foregroundScrolling]
    subss xmm0, xmm1
    movss [foregroundScrolling], xmm0

.checkLeftKey:
    mov edi, 263
    call IsKeyDown
    test al, al
    je .checkLimitBackgroundLeft

    mov eax, 0.5
    movd xmm1, eax
    movss xmm0, [backgroundScrolling]
    addss xmm0, xmm1
    movss [backgroundScrolling], xmm0

    mov eax, 1.0
    movd xmm1, eax
    movss xmm0, [midgroundScrolling]
    addss xmm0, xmm1
    movss [midgroundScrolling], xmm0

    mov eax, 2.0
    movd xmm1, eax
    movss xmm0, [foregroundScrolling]
    addss xmm0, xmm1
    movss [foregroundScrolling], xmm0

; .checkLimits:
;     cvtsi2ss xmm0, [foreground + 4]
;     addss xmm0, xmm0
;     mov eax, -0.0
;     movd xmm1, eax
;     xorps xmm0, xmm1
; 
;     movss xmm1, [foregroundScrolling]
;     comiss xmm0, xmm1
;     jb .checkBackgroundRightLimit
; 
;     pxor xmm0, xmm0
;     movss [foregroundScrolling], xmm0
; 
; .checkBackgroundRightLimit:
;     cvtsi2ss xmm0, [foreground + 4]
;     addss xmm0, xmm0
;     movss xmm1, [foregroundScrolling]
;     comiss xmm1, xmm0
;     jb .return
; 
;     pxor xmm0, xmm0
;     movss [foregroundScrolling], xmm0


.checkLimitBackgroundLeft:
    cvtsi2ss xmm0, [background + 4]
    addss xmm0, xmm0
    mov eax, -0.0
    movd xmm1, eax
    xorps xmm0, xmm1

    movss xmm1, [backgroundScrolling]
    comiss xmm0, xmm1
    jb .checkLimitMidgroundLeft

    pxor xmm0, xmm0
    movss [backgroundScrolling], xmm0

.checkLimitMidgroundLeft:
    cvtsi2ss xmm0, [midground + 4]
    addss xmm0, xmm0
    mov eax, -0.0
    movd xmm1, eax
    xorps xmm0, xmm1

    movss xmm1, [midgroundScrolling]
    comiss xmm0, xmm1
    jb .checkLimitForegroundLeft

    pxor xmm0, xmm0
    movss [midgroundScrolling], xmm0

    pxor xmm0, xmm0
    movss [backgroundScrolling], xmm0

.checkLimitForegroundLeft:
    cvtsi2ss xmm0, [foreground + 4]
    addss xmm0, xmm0
    mov eax, -0.0
    movd xmm1, eax
    xorps xmm0, xmm1

    movss xmm1, [foregroundScrolling]
    comiss xmm0, xmm1
    jb .checkLimitBackgroundRight

    pxor xmm0, xmm0
    movss [foregroundScrolling], xmm0

    pxor xmm0, xmm0
    movss [foregroundScrolling], xmm0

.checkLimitBackgroundRight:
    cvtsi2ss xmm0, [background + 4]
    addss xmm0, xmm0
    movss xmm1, [backgroundScrolling]
    comiss xmm1, xmm0
    jb .checkLimitMidgroundRight
    
    pxor xmm0, xmm0
    movss [backgroundScrolling], xmm0

.checkLimitMidgroundRight:
    cvtsi2ss xmm0, [midground + 4]
    addss xmm0, xmm0
    movss xmm1, [midgroundScrolling]
    comiss xmm1, xmm0
    jb .checkLimitForegroundRight
    
    pxor xmm0, xmm0
    movss [foregroundScrolling], xmm0

.checkLimitForegroundRight:
    cvtsi2ss xmm0, [foreground + 4]
    addss xmm0, xmm0
    movss xmm1, [foregroundScrolling]
    comiss xmm1, xmm0
    jb .return
    
    pxor xmm0, xmm0
    movss [foregroundScrolling], xmm0

.return:
    pop rbp
    ret

