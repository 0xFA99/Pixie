; ============== PARAMETERS ==============
; [rbp -  8]    = Player*
; [rbp - 12]    = int state
; [rbp - 16]    = int direction
; [rbp - 20]    = int start
; [rbp - 24]    = int end
; [rbp - 28]    = int FPS

; ============== VARIABLES ===============
; [rbp - 36]    = AnimationState*

_AddAnimationState:
    push rbp
    mov rbp, rsp

    sub rsp, 48

    mov [rbp - 8], rdi
    mov [rbp - 12], esi
    mov [rbp - 16], edx
    mov [rbp - 20], ecx
    mov [rbp - 24], r8d
    mov [rbp - 28], r9d

    mov rax, [rbp - 8]
    mov rax, [rax]
    mov eax, [rax + 48]
    test eax, eax
    jg .reAllocation

    mov edi, 20
    call malloc
    mov rdx, [rbp - 8]
    mov rdx, [rdx]
    mov [rdx + 40], rax

    mov dword [rdx + 48], 0

    jmp .fillAnimationData

.reAllocation:
    mov rax, [rbp - 8]
    mov rax, [rax]
    mov rdi, [rax + 40]
    mov eax, [rax + 48]
    add eax, 1
    imul eax, 20
    cdqe
    mov rsi, rax
    call realloc
    mov rdx, [rbp - 8]
    mov rdx, [rdx]
    mov [rdx + 40], rax

.fillAnimationData:
    mov rax, [rbp - 8]
    mov rax, [rax]
    mov rcx, [rax + 40]
    mov eax, [rax + 48]
    cdqe
    imul eax, 20
    add rax, rcx
    mov [rbp - 36], rax

    mov rax, [rbp - 36]
    mov edx, [rbp - 20]
    mov [rax], edx
    mov edx, [rbp - 24]
    mov [rax + 4], edx
    pxor xmm0, xmm0
    cvtsi2ss xmm0, [rbp - 28]
    movss [rax + 8], xmm0
    mov edx, [rbp - 12]
    mov [rax + 12], edx
    mov edx, [rbp - 16]
    mov [rax + 16], edx

    mov rax, [rbp - 8]
    mov rax, [rax]
    mov edx, [rax + 48]
    add edx, 1
    mov [rax + 48], edx

    add rsp, 48
    pop rbp
    ret

; ============== PARAMETERS ==============
; [rbp -  8]    = Player*
; [rbp - 12]    = int state
; [rbp - 16]    = int direction

; ============== VARIABLES ===============
; [rbp - 20]    = int index
; [rbp - 40]    = struct AnimationStates

_SetPlayerAnimation:
    push rbp
    mov rbp, rsp
    sub rsp, 48

    mov [rbp - 8], rdi
    mov [rbp - 12], esi
    mov [rbp - 16], edx

    mov dword [rbp - 20], 0 ; index

    jmp .L1

.L3:
;   player->entity->animationStates[i];
    mov rax, [rbp - 8]
    mov rax, [rax]
    mov rdx, [rax + 40]
    mov eax, [rbp - 20]
    imul eax, 20
    cdqe
    add rdx, rax

;   struct AnimationState animationState = player->entity->animationStates[i];
    mov rax, [rdx]
    mov rcx, [rdx + 8]
    mov [rbp - 28], rax 
    mov [rbp - 36], rcx
    mov eax, [rdx + 16]
    mov [rbp - 40], eax

;   if (animationState.state == state && animationState.direction == direction) {
    mov eax, [rbp - 32]
    cmp [rbp - 12], eax
    jne .L2

    mov eax, [rbp - 40]
    cmp [rbp - 16], eax
    jne .L2

;   player->animation = &player->entity->animationStates[i];
    mov rax, [rbp - 8]
    mov rax, [rax]
    mov rdx, [rax + 40]
    mov eax, [rbp - 20]
    imul eax, 20
    cdqe
    add rdx, rax

    mov rax, [rbp - 8]
    mov [rax + 8], rdx

;   player->currentFrame = player->entity->animationStates[i].animationSequence.startFrameIndex;
    mov rax, [rbp - 8]
    mov rax, [rax]
    mov rdx, [rax + 40]
    mov eax, [rbp - 20]
    imul eax, 20
    cdqe
    add rdx, rax
    mov ecx, [rdx]

    mov rax, [rbp - 8]
    mov [rax + 48], ecx

;   player->status.state = state;
    mov edx, [rbp - 12]
    mov [rax + 40], edx

;   player->status.direction = direction
    mov edx, [rbp - 16]
    mov [rax + 44], edx

.L2:
    add dword [rbp - 20], 1

.L1:
;   for (int i = 0; i < player->entity->animationStateCount; i++) {
    mov rax, [rbp - 8]
    mov rax, [rax]
    mov eax, [rax + 48]
    cmp [rbp - 20], eax
    jl .L3

    add rsp, 48
    pop rbp
    ret

