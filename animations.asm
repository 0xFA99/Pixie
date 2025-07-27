; @param rdi, entity
; @param esi, state
; @param edx, direction
; @param ecx, start
; @param r8d, end
; @param xmm0, fps

_addAnimationSprite:
    push    rbp
    mov     rbp, rsp

    mov r12, rdi                    ; entity
    mov r13d, esi                   ; state
    mov r14d, edx                   ; direction
    movd r15d, xmm0                  ; FPS

    sub rsp, 16
    mov [rbp - 8], ecx              ; frameEnd
    mov [rbp - 4], r8d              ; frameStart

    ; check entity->animStateCount != 0
    mov eax, [r12 + 48]
    test eax, eax
    jnz .reAlloc

    ; alloc new anim sprite
    mov rdi, 32                     ; sizeof animState
    call malloc
    mov [r12 + 40], rax             ; entity->animState*

    jmp .addAnim

.reAlloc:
    inc eax                         ; animStateCount++
    sal rax, 5                      ; sizeof animStates (32)

    mov rsi, rax                    ; realloc - @param 2 - size
    mov rdi, [r12 + 40]             ; realloc - @param 1 - ptr
    call realloc
    mov [r12 + 40], rax             ; entity->animState*

.addAnim:
    mov rdi, [r12 + 40]             ; entity->animStates
    mov eax, [r12 + 48]             ; entity.animStateCount
    sal rax, 5                      ; sizeof animStates (32)
    add rdi, rax                    ; entity->animStates[animStateCount]

    mov rax, [rbp - 8]              ; { startFrame, endFrame }
    mov [rdi], rax
    mov [rdi + 12], r15d            ; FPS

    mov [rdi + 16], r13d            ; state
    mov [rdi + 20], r14d            ; direction

    add dword [r12 + 48], 1         ; entity->animStateCount++

    add rsp, 16
    pop rbp
    ret

; @param rdi, player
; @param esi, state
; @param edx, direction
_setAnimationSprite:
    ; save player address into r12
    mov r12, rdi

    ; get frameCount for extend frames
    mov rdi, [r12]                  ; player->entity
    mov r13d, [rdi + 48]            ; animStateCount

    ; index 0
    mov ecx, 0

    jmp .loop1

.loop2:
    ; get reference of animState[counter]
    mov rdi, [r12]                  ; player->entity
    mov rdi, [rdi + 40]             ; sprite.frameCount
    mov eax, ecx
    sal rax, 5                      ; sizeof animState (32)
    add rdi, rax

    cmp esi, [rdi + 16]             ; state
    jne .continue

    cmp edx, [rdi + 20]             ; direction
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

