format MS64 COFF

include 'macros.inc'
include 'consts.inc'

extrn malloc
extrn memset

extrn IsKeyPressed
extrn IsKeyDown
extrn DrawTexturePro

extrn gravity

section '.text' code readable executable

; rcx = player->entity
public _initPlayer
_initPlayer:
    push        rbx
    sub         rsp, 32                     ; shadow space

    mov         rbx, rcx                    ; rcx = &player (arg)

    mov         ecx, 424                    ; sizeof SpriteEntity
    call        malloc
    mov         [rbx], rax                  ; player->entity

    mov         rcx, rax                    ; player->entity
    xor         edx, edx                    ; 0 byte
    mov         r8d, 424                    ; 424 total bytes
    call        memset

    ; movement initialization
    mov         dword [rbx + 32], 1200.0    ; player.acceleration
    mov         dword [rbx + 36], 1800.0    ; player.deceleration
    mov         dword [rbx + 40], 450.0     ; player.topSpeed
    mov         dword [rbx + 44], 420.0     ; player.jumpForce
    mov         dword [rbx + 48], 300.0     ; player.breakThreshold
    mov         byte [rbx + 60], 1          ; player.isGrounded

    add         rsp, 32                     ; shadow space
    pop         rbx
    ret

public _renderPlayer
_renderPlayer:
    push        rdi
    push        r12
    push        r13

    sub         rsp, 96

    mov         r12, rcx
    mov         r13, [rcx]

    movaps      xmm0, [r13]                 ; texture {id, w, h, m}
    movaps      [rsp + 48], xmm0
    mov         eax, [r13 + 16]             ; texture.format
    mov         [rsp + 60], eax

    mov         rdi, [r13 + 20]             ; player.frames (base)
    mov         eax, [r12 + 56]             ; player.currentFrame
    sal         rax, 4                      ; sizeof Rectangle (16)
    add         rdi, rax                    ; base + currentFrame

    movaps      xmm0, [rdi]                 ; source frame
    movaps      [rsp + 64], xmm0            ; {pos.x, pos.y, width, height}

    movsd       xmm0, [r12 + 16]            ; player.position {x, y}
    movsd       xmm1, [rsp + 72]            ; frame {width, height}
    movsd       [rsp + 88], xmm1

    movss       xmm2, xmm1                  ; frame.width

    mov         eax,  0x40000000            ; 2.0
    movd        xmm3, eax
    divss       xmm2, xmm3                  ; frame.width / 2.0

    mov         edx, MASK_ABS
    movd        xmm3, edx
    andps       xmm2, xmm3
    subss       xmm0, xmm2
    movsd       [rsp + 80], xmm0            ; player.position {x, y}

    mov         dword [rsp + 40], 0xFFFFFFFF    ; color - white
    mov         qword [rsp + 32], 0             ; rotation
    xor         r9, r9                          ; offset {0.0, 0.0}
    lea         r8, [rsp + 80]                  ; rect dest*
    lea         rdx, [rsp + 64]                 ; rect source*
    lea         rcx, [rsp + 48]                 ; texture*
    call        DrawTexturePro

    add         rsp, 96

    pop         r13
    pop         r12
    pop         rdi
    ret


; rcx = player
; xmm1 = frameTime
public _inputPlayer
_inputPlayer:
    push        r12
    push        r13
    push        r14
    push        r15
    sub         rsp, 40                     ; push xmm6 and xmm7 + 8 padding
    movdqa      [rsp], xmm6
    movdqa      [rsp + 16], xmm7

    sub         rsp, 32                     ; 32 shadow space

    mov         r12, rcx
    movss       xmm0, xmm1                  ; swap frameTime :)

    mov         ecx, KEY_UP
    call        IsKeyPressed
    mov         r13b, al

    mov         ecx, KEY_RIGHT
    call        IsKeyDown
    movzx       r14d, al

    mov         ecx, KEY_LEFT
    call        IsKeyDown
    movzx       r15d, al

    sub         r14d, r15d                  ; direction (-1, 0, 1)

    movss       xmm1, [r12 + 24]            ; player.velocity.x
    movss       xmm2, [r12 + 32]            ; player.acceleration
    mulss       xmm2, xmm0                  ; player.acceleration * frameTime

    ; fabsf(player.velocity.x)
    movaps      xmm3, xmm1
    mov         eax, MASK_ABS               ; 0x7FFFFFFF
    movd        xmm7, eax
    andps       xmm3, xmm7

    test        r13b, r13b
    jz          .playerState

    cmp         byte [r12 + 60], 0
    je          .playerState

    mov         ax, [r12 + 52]
    cmp         ax, STATE_IDLE
    sete        dl
    cmp         ax, STATE_RUN
    sete        cl
    or          dl, cl
    test        dl, dl
    jz          .playerState

    movss       xmm5, [r12 + 44]            ; player.jumpForce
    pxor        xmm4, xmm4                  ; 0.0
    subss       xmm4, xmm5                  ; -player.jumpForce
    movss       [r12 + 28], xmm4            ; player.velocity.y

    mov         word [r12 + 52], STATE_JUMP ; player.state
    mov         byte [r12 + 60], 0          ; player.isGrounded

.playerState:
    mov         ax, [r12 + 52]              ; player.state
    cmp         ax, STATE_COUNT
    jge         .done

    movzx       eax, ax
    ; jmp         qword [.stateTable + rax*8]
    lea         r9, [.stateTable]
    jmp         qword [r9 + rax*8]

.stateTable:
    dq          .stateIdle
    dq          .stateRun
    dq          .stateJump
    dq          .stateFall
    dq          .stateBreak

; ================================ STATE: IDLE =================================
.stateIdle:
    test        r14d, r14d                  ; direction
    jz          .done

    mov         word [r12 + 52], STATE_RUN  ; player.state
    mov         [r12 + 54], r14w            ; player.direction

    ; player.velocity.x += direction * acceleration * frameTime
    cvtsi2ss    xmm4, r14d                  ; direction
    mulss       xmm4, xmm2                  ; direction * xmm2(acc * FT)

    addss       xmm1, xmm4                  ; velocity.x * xmm4
    movss       [r12 + 24], xmm1            ; player.velocity.x
    jmp         .done

; ================================= STATE: RUN =================================
.stateRun:
    test        r14d, r14d                  ; direction
    jz          .stateRun_noInput

    ; IsChangingDirection
    movss       xmm4, xmm1                  ; xmm4 = velocity.x
    pxor        xmm5, xmm5                  ; xmm5 = 0.0
    comiss      xmm4, xmm5
    jbe         .stateRun_checkNegative      ; vel <= 0 → cek sisi negatif

    cmp         r14d, DIRECTION_LEFT
    je          .stateRun_checkBreak
    jmp         .stateRun_keepRun

.stateRun_checkNegative:
    comiss      xmm4, xmm5
    jae         .stateRun_keepRun           ; vel >= 0 → bukan changingDir

    cmp         r14d, DIRECTION_RIGHT
    je          .stateRun_checkBreak

.stateRun_keepRun:
    mov         word [r12 + 52], STATE_RUN  ; player.state = RUN
    mov         [r12 + 54], r14w            ; player.direction = input dir

    cvtsi2ss    xmm4, r14d                  ; (float)direction
    mulss       xmm4, xmm2                  ; dir * accel*dt
    addss       xmm1, xmm4
    movss       [r12 + 24], xmm1            ; player.velocity.x
    jmp         .done

.stateRun_checkBreak:
    movss       xmm4, [r12 + 48]            ; breakThreshold
    comiss      xmm3, xmm4                  ; abs(velX) > breakThreshold
    jbe         .stateRun_keepRun

    mov         word [r12 + 52], STATE_BREAK
    jmp         .done

.stateRun_noInput:
    movss       xmm4, [r12 + 48]            ; breakThreshold
    comiss      xmm3, xmm4
    jbe         .stateRun_toIdle

    mov         word [r12 + 52], STATE_BREAK
    jmp         .done

.stateRun_toIdle:
    mov         dword [r12 + 24], 0.0
    mov         word [r12 + 52], STATE_IDLE
    jmp         .done

; ================================ STATE: JUMP =================================
.stateJump:
    movss       xmm4, [r12 + 28]            ; player.velocity.y
    pxor        xmm5, xmm5                  ; 0.0
    comiss      xmm4, xmm5
    jb          .stateJump_checkDirection

    mov         word [r12 + 52], STATE_FALL ; player.state

.stateJump_checkDirection:
    test        r14d, r14d
    jz          .done

    mov         [r12 + 54], r14w            ; player.direction

    ; player.velocity.x += directiono * acceleration * frameTime
    cvtsi2ss    xmm4, r14d                  ; direction
    mulss       xmm4, xmm2
    addss       xmm1, xmm4
    movss       [r12 + 24], xmm1            ; player.velocity.x
    jmp         .done

; ================================ STATE: FALL =================================
.stateFall:
    cmp         byte [r12 + 60], 0          ; player.isGrounded
    je          .stateFall_checkDirection

    cmp         r14d, STATE_RUN
    sete        al
    movzx       ax, al
    mov         [r12 + 52], ax              ; player.state

.stateFall_checkDirection:
    test        r14d, r14d
    jz          .done

    mov         [r12 + 54], r14w            ; player.direction

    ; player.velocity.x += directiono * acceleration * frameTime
    cvtsi2ss    xmm4, r14d                  ; direction
    mulss       xmm4, xmm2
    addss       xmm1, xmm4
    movss       [r12 + 24], xmm1            ; player.velocity.x
    jmp         .done

; ================================ STATE: BREAK ================================
.stateBreak:
    movss       xmm4, [r12 + 36]            ; player.deceleration
    mulss       xmm4, xmm0                  ; decelAmount = decel*dt

    ; if (absVelX <= decelAmount) → idle
    comiss      xmm3, xmm4
    ja          .stateBreak_applyDeceleration

    mov         dword [r12 + 24], 0.0       ; velX = 0.0
    mov         word [r12 + 52], STATE_IDLE ; state = IDLE
    jmp         .stateBreak_checkDirection

.stateBreak_applyDeceleration:
    mov         eax, 0xBF800000             ; -1.0f
    movd        xmm6, eax

    ; sign (velX > 0 ? +1.0 : -1.0)
    pxor        xmm5, xmm5                  ; 0.0
    comiss      xmm1, xmm5
    jbe         .stateBreak_updateVelocity

    mov         eax, 0x3F800000             ; +1.0f
    movd        xmm6, eax

.stateBreak_updateVelocity:
    mulss       xmm4, xmm6                  ; sign * decel
    subss       xmm1, xmm4                  ; velX -= sign*decel
    movss       [r12 + 24], xmm1

.stateBreak_checkDirection:
    test        r14d, r14d
    jz          .done

    ; !IsChangingDirection
    movss       xmm4, xmm1                  ; player.velocity.x
    pxor        xmm5, xmm5                  ; 0.0
    comiss      xmm4, xmm5                  ; velocity.x > 0.0
    jbe         .stateBreak_checkNegative

    cmp         r14d, DIRECTION_LEFT
    je          .done
    jmp         .stateBreak_toRun

.stateBreak_checkNegative:
    jb          .stateBreak_isNegative
    jmp         .stateBreak_toRun

.stateBreak_isNegative:
    cmp         r14d, DIRECTION_RIGHT
    je          .done

.stateBreak_toRun:
    mov         word [r12 + 52], STATE_RUN
    mov         [r12 + 54], r14w

.done:
    add         rsp, 32

    movdqa      xmm7, [rsp + 16]
    movdqa      xmm6, [rsp]
    add         rsp, 40

    pop         r15
    pop         r14
    pop         r13
    pop         r12

    ret


; rcx = player
public _updatePlayer
_updatePlayer:
    push        r13
    push        r14
    push        r15

    mov         r15, rcx                    ; player
    mov         r14, [rcx + 8]              ; player->animState

    mov         eax, [r15 + 52]             ; player{state, direction}
    cmp         eax, [r14 + 12]             ; animState{state, direction}
    je          .integratePhysic

    ; object, state, direction
    setSpriteAnimation r15, [r15 + 52], [r15 + 54]
    mov         r14, [r15 + 8]              ; player->animState

.integratePhysic:
    movss       xmm1, [r15 + 24]            ; velocity.x
    movss       xmm2, [r15 + 28]            ; velocity.y
    movss       xmm3, [r15 + 40]            ; topSpeed

    ; clamp velocity.x (-topSpeed, topSpeed)
    minss       xmm1, xmm3                  ; topSpeed
    pxor        xmm4, xmm4
    subss       xmm4, xmm3                  ; -topSpeed
    maxss       xmm1, xmm4
    movss       [r15 + 24], xmm1            ; store velocity.x

    mov         r13b, [r15 + 60]            ; isGrounded
    test        r13b, r13b
    jnz         .verletIntegration

    movd        xmm3, [gravity]
    mulss       xmm3, xmm0                  ; gravity * frameTime
    addss       xmm2, xmm3
    movss       [r15 + 28], xmm2            ; store velocity.y

    pxor        xmm3, xmm3
    comiss      xmm2, xmm3                  ; velocity.y > 0
    jbe         .verletIntegration

    cmp         word [r15 + 52], STATE_JUMP
    jne         .verletIntegration

    mov         word [r15 + 52], STATE_FALL

.verletIntegration:
    movss       xmm3, [r15 + 16]            ; position.x
    movss       xmm4, [r15 + 20]            ; position.y

    mulss       xmm1, xmm0                  ; velocity.x * frameTime
    addss       xmm3, xmm1
    movss       [r15 + 16], xmm3            ; store position.x

    mulss       xmm2, xmm0                  ; velocity.y * frameTime
    addss       xmm4, xmm2
    movss       [r15 + 20], xmm4            ; store position.y

    pxor        xmm5, xmm5
    comiss      xmm4, xmm5                  ; position.y >= 0
    jb          .groundCollision

    mov         dword [r15 + 20], 0.0       ; position.y = 0
    mov         dword [r15 + 28], 0.0       ; velocity.y = 0

    test        r13b, r13b                  ; isGrounded
    jnz         .updateAnimation

    mov         byte [r15 + 60], 1          ; isGrounded = true

    mov         ax, [r15 + 52]              ; state
    cmp         ax, STATE_FALL
    sete        dl
    cmp         ax, STATE_JUMP
    sete        cl
    or          dl, cl

    test        dl, dl
    jz          .updateAnimation

    comiss      xmm1, xmm5                  ; velocity.x != 0
    setne       al
    movzx       ax, al
    mov         [r15 + 52], ax              ; store state

    jmp         .updateAnimation

.groundCollision:
    test        r13b, r13b
    jz          .updateAnimation

    mov         byte [r15 + 60], 0          ; isGrounded = false

.updateAnimation:
    mov         r13, [r15]                  ; entity
    movss       xmm1, [r13 + 420]           ; frameDuration
    addss       xmm1, xmm0                  ; + frameTime
    movss       [r13 + 420], xmm1

    movss       xmm3, [r14 + 8]             ; frameRate
    mov         eax, 0x3f800000             ; 1.0
    movd        xmm2, eax
    rcpss       xmm2, xmm3                  ; 1/frameRate

    comiss      xmm1, xmm2
    jb          .done

    subss       xmm1, xmm2                  ; frameDuration -= frameInterval
    movss       [r13 + 420], xmm1

    inc         dword [r15 + 56]            ; currentFrame++

    mov         eax, [r14 + 4]              ; endFrame
    cmp         [r15 + 56], eax
    jle         .done

    mov         eax, [r14]                  ; startFrame
    mov         [r15 + 56], eax             ; currentFrame = startFrame

.done:
    pop         r15
    pop         r14
    pop         r13
    ret
