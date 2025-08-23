; @func     _addAnimationSprite
; @desc     inject new animState into entity like shoving junk in a closet
; @param    rdi     -> entity
; @param    si      -> state
; @param    dx      -> direction
; @param    ecx     -> start frame
; @param    r8d     -> end frame
; @param    xmm8    -> fps

_addAnimationSprite:
    push        rbp
    mov         rbp, rsp

    mov         r12, rdi                    ; entity, the unlucky bastard

    ; Store startFrame and endFrame in r13
    mov         r13d, ecx                   ; r13 = start
    shl         r13, 32                     ; r13 = {start, ...}
    or          r13, r8                     ; r13 = {start, end}

    ; store state and direction in r14
    mov         r14w, si                    ; r14d = state
    shl         r14d, 16                    ; r14d = {state, ...}
    or          r14w, dx                    ; r14d = {state, direction}

    ; if entity.animationStateCount == 0
    mov         r15d, [r12 + 40]            ; entity.animationStateCount
    test        r15d, r15d
    jnz         .reallocAnimationState

    xor         r11, r11
    mov         rdi, 16                     ; sizeof animState
    call        malloc
    mov         [r12 + 32], rax             ; entity->animState
    jmp         .addAnimationState

.reallocAnimationState:
    ; grow array like a tumor
    mov         rsi, r15                    ; entity.animationStateCount
    inc         rsi                         ; entity.animationStateCount + 1
    shl         rsi, 4                      ; sizeof animState (16)
    mov         rdi, [r12 + 32]             ; animState* (base address)
    call        realloc
    mov         [r12 + 32], rax             ; animState* (base address)

.addAnimationState:
    ; point to the new slot
    mov         rsi, r15                    ; entity.animStateCount
    shl         rsi, 4                      ; sizeof animStates (16)
    lea         rbx, [rax + rsi]            ; entity.animStates[animStateCount]

    ; dump start/end frames, good luck keeping track
    mov         rax, r13                    ; rax = {startFrame, endFrame}
    shr         rax, 32
    mov         [rbx], eax                  ; startFrame
    mov         [rbx + 4], r13d             ; endFrame

    ; shove fps into memory like it matters
    movd        [rbx + 8], xmm8             ; frameTime

    ; store state/dir separately, cause why not
    mov         eax, r14d                   ; eax = {state, direction}
    shr         eax, 16
    mov         [rbx + 12], ax              ; state
    mov         [rbx + 14], r14w            ; direction

    ; increment counter
    inc         r15d                        ; entity.animationStateCount - 1
    mov         [r12 + 40], r15d

    pop         rbp
    ret

; @func     _setAnimationSprite
; @desc     crawl through animStates until you find one that doesnt hate you
; @param    rdi     -> player
; @param    si      -> state
; @param    dx      -> direction

_setAnimationSprite:
    mov         r12, rdi                    ; player
    mov         r13, [r12]                  ; player->entity

    mov         r14d, [r13 + 40]            ; entity.animStateCount
    mov         rbx, [r13 + 32]             ; entity.animStates (base address)

.loop:
    cmp         si, [rbx + 12]              ; compare state
    jne         .continue

    cmp         dx, [rbx + 14]              ; compare direction
    jne         .continue

    ; slap this animState on the player
    mov         [r12 + 8], rbx              ; player->animState
    mov         eax, [rbx]                  ; animSeq.startFrame
    mov         [r12 + 56], eax             ; player.currentFrame
    mov         [r12 + 54], dx              ; player.direction
    mov         [r12 + 52], si              ; player.state
    ret

.continue:
    add         rbx, 16                     ; next animState

    dec         r14d                        ; animStateCount--
    jnz         .loop

