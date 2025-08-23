; @func     _inputCamera
; @desc     spin mouse wheel, zoom like a cheap PowerPoint transition
; @param    rdi     -> camera
; @note     wheel goes brrr, zoom goes wrong

_inputCamera:
    mov         r12, rdi                    ; camera
    call        GetMouseWheelMove

    movss xmm1, [camZoomLevel]              ; "how hard to zoom?!"
    mulss xmm1, xmm0

    movss xmm0, [r12 + 20]                  ; camera.zoom
    addss xmm0, xmm1                        ; stack zoom on zoom !!

    movd [r12 + 20], xmm0                   ; commit war crime to memory
    ret

; @func     _inputPlayer
; @desc     abuse the WASD monkey, update state machine of pain
; @param    rdi     -> player
; @note     processes input like a broken keyboard warrior

_inputPlayer:
    mov         r12, rdi                    ; player

    ; fetch jump button, a.k.a. "go up and regret later"
    mov         edi, KEY_UP
    call        IsKeyPressed
    mov         r13b, al

    ; fetch right arrow, for running into walls
    mov         edi, KEY_RIGHT
    call        IsKeyDown
    movzx       r14d, al

    ; fetch left arrow, for running into the other wall
    mov         edi, KEY_LEFT
    call        IsKeyDown
    movzx       r15d, al

    ; direction = right - left (math, nobody asked for)
    sub         r14d, r15d

    ; load movement physics knobs
    movss       xmm1, [r12 + 24]            ; player.velocity.x
    movss       xmm2, [r12 + 32]            ; player.acceleration
    movss       xmm3, [r12 + 36]            ; player.deceleration

    mulss       xmm2, xmm0                  ; player.acceleration * frameTime
    mulss       xmm3, xmm0                  ; player.deceleration * frameTime

    ; jump check, only legal when grounded and not busy dying
    test        r13b, r13b
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
    subss       xmm5, xmm4                  ; -player.jumpForce, launch into regret
    movss       [r12 + 28], xmm5            ; player.velocity.y
    mov         word [r12 + 52], STATE_JUMP ; player.state, now flying yepee!!
    mov         byte [r12 + 60], 0          ; player.isGrounded = false
    ret

;   state machine of doom -----------------------------------------------------

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
    ; if velocity still spicy, go BREAK else nap
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


; _inputParallax:
;     push        rbp
;     mov         rbp, rsp
;
;     mov         r12, rdi
;
;     mov         edi, KEY_RIGHT
;     call        IsKeyDown
;     movzx       r14d, al
;
;     mov         edi, KEY_LEFT
;     call        IsKeyDown
;     movzx       edx, al
;
;     sub         edx, r14d
;     test        edx, 0
;     je          .done
;
;     cvtsi2ss    xmm8, edx                   ; direction
;
;     mov         r13, [r12]                  ; parallax.data (base)
;     mov         r14d, [r12 + 8]             ; parallax.count
;
;     xor         ecx, ecx                    ; index
;
; .loop:
;     mov         rdi, r13                    ; parallax.data
;     mov         eax, ecx                    ; parallax.count
;     shl         rax, 5                      ; sizeof ParallaxData (32)
;     add         rdi, rax
;
;     movss       xmm7, [rdi + 28]            ; speed
;     mulss       xmm7, xmm8
;
;     movss       xmm0, [rdi + 20]            ; position.x
;     addss       xmm0, xmm7
;
;     movss       xmm1, [rdi + 4]             ; texture.width
;     pxor        xmm2, xmm2
;     subss       xmm2, xmm1                  ; -texture.width
;
;     comiss      xmm0, xmm1
;     jae         .reset
;
;     comiss      xmm0, xmm2
;     jbe         .reset
;
;     jmp         .continue
;
; .reset:
;     mov         dword [rdi + 20], 0.0
;
; .continue:
;     inc         ecx
;
;     cmp         ecx, r14d
;     jl          .loop
;
; .done:
;     pop         rbp
;     ret

; inputParallax:
 ;    push    rbp
 ;    mov     rbp, rsp

 ;    mov     r12, rdi                ; parallax struct

 ;    ; get direction input (-1 = left, 0 = none, +1 = right)
 ;    mov     edi, KEY_RIGHT
 ;    call    IsKeyDown
 ;    movzx   r14d, al
 ;    mov     edi, KEY_LEFT
 ;    call    IsKeyDown
 ;    movzx   edx, al
 ;    sub     edx, r14d               ; edx = right - left
 ;    test    edx, edx
 ;    je      .done                    ; no movement, skip

 ;    cvtsi2ss xmm8, edx               ; direction float

 ;    mov     r13, [r12]               ; base parallax.data
 ;    mov     r14d, [r12 + 8]          ; count

 ;    xor     ecx, ecx                 ; index

; loop:
 ;    mov     rdi, r13
 ;    mov     eax, ecx
 ;    shl     rax, 5                    ; sizeof ParallaxData = 32
 ;    add     rdi, rax

 ;    movss   xmm7, [rdi + 28]         ; speed
 ;    mulss   xmm7, xmm8               ; apply direction
 ;    movss   xmm0, [rdi + 20]         ; position.x
 ;    addss   xmm0, xmm7               ; pos += speed*dir

 ;    ; load texture width * 2
 ;    movss   xmm1, [rdi + 4]          ; width
 ;    addss   xmm1, xmm1                ; width*2
 ;    pxor    xmm2, xmm2                ; 0.0
 ;    subss   xmm2, xmm1                ; -width*2

 ;    ; branch-based clamp
 ;    comiss  xmm0, xmm1
 ;    ja      .reset                    ; pos > width*2
 ;    comiss  xmm0, xmm2
 ;    jb      .reset                    ; pos < -width*2
 ;    jmp     .continue

; .; reset:
;  ;    movss   xmm0, xmm2                ; reset to -width*2
;  ;    movss   [rdi + 20], xmm0
;  ;    jmp     .continue
;
; .; continue:
;  ;    inc     ecx
;  ;    cmp     ecx, r14d
;  ;    jl      .loop
;
; .; done:
;  ;    pop     rbp
;  ;    ret

public _inputParallax

_inputParallax:
    push        rbp
    mov         rbp, rsp

    mov         r12, rdi

    mov         edi, KEY_RIGHT
    call        IsKeyDown
    movzx       r13d, al

    mov         edi, KEY_LEFT
    call        IsKeyDown
    movzx       r14d, al

    sub         r13d, r14d
    jz          .done

    ; right = 1
    ; left = -1
    cvtsi2ss    xmm8, r13d                  ; direction

    mov         rbx, [r12]                  ; parallax.data (base)
    mov         r14d, [r12 + 8]             ; parallax.count

    xor         ecx, ecx                    ; index

.loop:
    mov         eax, [r14d]                 ; parallax.count
    shl         rax, 5                      ; sizeof ParallaxData (32)
    lea         rdi, [rbx + rax]            ; parallax.data[parallax.count]

    movss       xmm0, [rdi + 28]            ; speed
    mulss       xmm0, xmm8                  ; speed * direction (-1, 1)

    movss       xmm1, [rdi + 20]            ; position.x
    addss       xmm1, xmm0

    movss       xmm2, [rdi + 4]             ; texture.width (pos)
    pxor        xmm3, xmm3
    subss       xmm3, xmm2                  ; -texture.width (neg)

    ; check limit
    comiss      xmm1, xmm2                  ; posX => width
    jb          .reset

    comiss      xmm1, xmm3
    ja          .reset

    jmp         .done

.reset:
    mov         dword [rdi + 4], 0.0        ; pos.x = 0

    inc         r14d                        ; count++
    cmp         r14d, 3                     ; back, mid, front
    jl          .loop

.done:
    pop         rbp
    ret

