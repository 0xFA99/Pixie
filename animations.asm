; ============== PARAMETERS ==============
; r12           = Player*
; r13d          = frameRate
; [rbp - 4]     = direction
; [rbp - 8]     = state
; [rbp - 12]    = end Index
; [rbp - 16]    = start Index

_addAnimationState:
    push rbp
    mov rbp, rsp

    sub rsp, 16

    mov [rbp - 4], edx
    mov [rbp - 8], esi
    mov [rbp - 12], r8d
    mov [rbp - 16], ecx

    mov r12, rdi            ; Player->entity
    movd r13d, xmm0         ; frameRate

    ; Get AnimationStateCount
    mov eax, [r12 + 40]
    test eax, eax
    jg .reAllocate

    ; New Allocation
    mov edi, 20
    call malloc
    mov [r12 + 32], rax
    jmp .addAnimation

.reAllocate:
    inc eax                 ; AnimationStateCount++
    imul eax, 20
    cdqe
    mov rsi, rax
    mov rdi, [r12 + 32]
    call realloc
    mov [r12 + 32], rax

.addAnimation:
    ; Get pointer to new AnimationState slot
    mov rdi, [r12 + 32]
    mov eax, [r12 + 40]
    imul eax, 20
    cdqe
    add rdi, rax

    ; Move state and direction
    mov rax, [rbp - 16]
    mov [rdi], rax

    ; Move speed
    mov dword [rdi + 8], r13d

    ; Move start and end Index
    mov rax, [rbp - 8]
    mov [rdi + 12], rax
    
    ; Increment Animation State Count
    add dword [r12 + 40], 1
    
.return:
    add rsp, 16
    pop rbp
    ret

; ============== PARAMETERS ==============
; rdi           = Player
; esi           = state
; edx           = direction

_setAnimationState:
    ; Save Player address into r12
    mov r12, rdi

    ; Get frameCount for extend frames
    mov rdi, [r12]
    mov r13d, [rdi + 40]    ; frameCount

    mov ecx, 0  ; Set counter to 0

    jmp .loop1

.loop2:
    ; Get reference of AnimationState[counter]
    mov rdi, [r12]
    mov rdi, [rdi + 32]
    mov eax, ecx
    imul eax, 20
    cdqe
    add rdi, rax

    ; Get state and direction of animationState[counter]
    cmp esi, [rdi + 12]    ; state
    jne .continue

    cmp edx, [rdi + 16]    ; direction
    jne .continue

    ; if state and direction equal
    ; set player animationState
    mov [r12 + 8], rdi

    mov eax, [rdi]
    mov [r12 + 48], eax     ; Set startFrame
    mov [r12 + 40], esi     ; Set state
    mov [r12 + 44], edx     ; Set direction

    jmp .return

.continue:
    inc ecx

.loop1:
    cmp ecx, r13d
    jl .loop2

.return:
    ret

