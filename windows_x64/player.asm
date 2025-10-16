format MS64 COFF

include 'macros.inc'
include 'consts.inc'

extrn malloc
extrn memset

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

    sub         rsp, 112

    mov         r12, rcx
    mov         r13, [rcx]

    movaps      xmm0, [r13]
    movaps      [rsp + 48], xmm0
    mov         eax, [r13 + 16]
    mov         [rsp + 60], eax

    mov         rdi, [r13 + 20]
    mov         eax, [r12 + 56]
    sal         rax, 4
    add         rdi, rax

    movaps      xmm0, [rdi]
    movaps      [rsp + 64], xmm0

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

    mov         qword [rsp + 96], 0.0       ; offset {0.0, 0.0}

    mov         dword [rsp + 40], 0xFFFFFFFF    ; color - white
    mov         qword [rsp + 32], 0             ; rotation
    lea         r9, [rsp + 96]                  ; offset*
    lea         r8, [rsp + 80]                  ; rect dest*
    lea         rdx, [rsp + 64]                 ; rect source*
    lea         rcx, [rsp + 48]                 ; texture*
    call        DrawTexturePro

    add         rsp, 112

    pop         r13
    pop         r12
    pop         rdi
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
