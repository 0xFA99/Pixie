; @param rdi, entity
; @param esi, state
; @param edx, direction
; @param ecx, start
; @param r8d, end
; @param xmm0, fps

; _addAnimationSprite:
;     push        rbp
;     mov         rbp, rsp
;
;     mov         r12, rdi                    ; entity
;     movd        r13d, xmm0                  ; FPS
;
;     ; sub         rsp, 16
;     ; mov         [rbp - 12], edx             ; direction
;     ; mov         [rbp - 16], esi             ; state
;     ; mov         [rbp - 8], ecx              ; frameEnd
;     ; mov         [rbp - 4], r8d              ; frameStart
;
;     sub         rsp, 16
;     ; mov         [rsp], dl                   ; direction
;     ; mov         [rsp + 1], sil              ; state
;     ; movd        dword [rsp + 4], xmm0       ; frameTime
;     ; mov         [rsp + 8], ecx              ; frameEnd
;     ; mov         [rsp + 12], r8d             ; frameStart
;
;     ; mov         [rbp], ecx
;     ; mov         [rbp + 4], r8d
;     ; movd        [rbp + 8], xmm0
;     ; ; mov         dword [rbp + 12], 0.0
;     ; mov         [rbp + 16], sil
;     ; mov         [rbp + 17], dl
;
;     mov         [rbp + 4], r8d              ; frameStart
;     mov         [rbp], ecx                  ; frameEnd
;
;     movd        [rbp + 8], xmm0             ; frameTime
;
;     mov         [rbp + 12], dl              ; direction
;     mov         [rbp + 13], sil             ; state
;
;     movaps      xmm0, [rbp]
;     mov         ax, [rbp + 17]
;
;     sub         rsp, 16
;     movaps      [rsp], xmm0
;     mov         [rbp + 12], ax
;
;     ; check entity->animStateCount != 0
;     mov         eax, [r12 + 42]             ; entity->animStateCount
;     test        eax, eax
;     jnz         .reAlloc
;
;     ; alloc new anim sprite
;     mov         rdi, 18                     ; sizeof animState
;     call        malloc
;     mov         [r12 + 36], rax             ; entity->animState*
;     jmp         .addAnim
;
; .reAlloc:
;     inc         eax                         ; animStateCount++
;     lea         rax, [rax*8 + rax]          ; sizeof animStates (18)
;     shl         rax, 1
;     mov         rsi, rax                    ; realloc - @param 2 - size

;     mov         rdi, [r12 + 36]             ; realloc - @param 1 - ptr
;     call        realloc
;     mov         [r12 + 36], rax             ; entity->animState*
;
; .addAnim:
;     mov         rdi, [r12 + 36]             ; entity->animStates
;     mov         eax, [r12 + 42]             ; entity.animStateCount
;     lea         rax, [rax*8 + rax]          ; sizeof animStates (18)
;     shl         rax, 1
;     add         rdi, rax                    ; entity->animStates[animStateCount]
;
;     mov         rax, [rbp - 8]              ; { endFrame, startFrame }
;     mov         rdx, [rbp - 16]             ; { direction, state }
;     mov         [rdi], rax
;     mov         [rdi + 8], r13d             ; frameTime
;     mov         [rdi + 16], rdx
;
;     add         dword [r12 + 42], 1         ; entity->animStateCount++
;
;     add         rsp, 16
;     pop         rbp
;     ret




; @param rdi, entity
; @param sil, state
; @param dl, direction
; @param ecx, start
; @param r8d, end
; @param xmm0, fps

public _addAnimationSprite

_addAnimationSprite:
    push        rbp
    mov         rbp, rsp

    mov         r12, rdi                    ; entity

    mov         r13d, ecx                   ; r13 = { start }
    shl         r13d, 32                    ; r13 = { start, ... }
    or          r13d, r8d                   ; r13 = { start, end }

    mov         r14b, sil                   ; r14w = { state }
    shl         r14b, 8                     ; r14w = { state , ... }
    or          r14b, dl                    ; r14w = { status, direction }

    mov         r15d, [r12 + 42]            ; entity.animationSateCount
    test        r15d, r15d
    jnz         .reallocAnimationState

    ; realloc new Animation
    mov         rdi, 14                     ; sizeof animState
    call        malloc
    mov         [r12 + 36], rax             ; entity->animState
    jmp         .addAnimationState

.reallocAnimationState:
    mov         esi, r15d
    inc         esi
    imul        rsi, 14
    mov         rdi, [r12 + 36]
    call        realloc
    mov         [r12 + 36], rax

.addAnimationState:
    mov         rbx, rax                    ; base address
    imul        r15d, 14                    ; entity.animStateCount
    lea         rbx, [rbx + r15]

    mov         [rbx], r13                  ; startFrame, endFrame
    movd        [rbx + 8], xmm0             ; frameRate
    mov         [rbx + 12], r14w            ; state, direction

    inc         r15d
    mov         [r12 + 42], r15d

    pop         rbp
    ret

; @param rdi, player
; @param esi, state
; @param edx, direction
_setAnimationSprite:
    ; save player address into r12
    mov         r12, rdi

    ; get frameCount for extend frames
    mov         rdi, [r12]                  ; player->entity
    mov         r13d, [rdi + 42]            ; entity.animStateCount

    xor         ecx, ecx                    ; index 0
    jmp         .loop1

.loop2:
    ; get reference of entity.animStates[counter]
    mov         rdi, [r12]                  ; player->entity
    mov         rdi, [rdi + 36]             ; entity.animStates
    mov         eax, ecx                    ; index
    lea         rax, [rax*8 + rax]          ; sizeof animStates (18)
    shl         rax, 1
    add         rdi, rax

    cmp         esi, [rdi + 16]             ; state
    jne .continue

    cmp         edx, [rdi + 20]             ; direction
    jne .continue

    ; set player->animState
    mov [r12 + 8], rdi              ; player->animState

    mov eax, [rdi]                  ; animSeq.startFrame
    mov [r12 + 56], eax             ; player.currentFrame
    mov [r12 + 48], esi             ; player.state
    mov [r12 + 52], edx             ; player.direction

    jmp .return

.continue:
    inc ecx

.loop1:
    cmp ecx, r13d
    jl .loop2

.return:
    ret

