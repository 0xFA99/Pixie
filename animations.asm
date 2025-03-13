; [rbp - 8],    rdi = entity*
; [rbp - 12],   esi = state
; [rbp - 16],   edx = direction
; [rbp - 20],   ecx = start
; [rbp - 24],   r8d = end
; [rbp - 28],   r9d = FPS

; [rbp - 36],   struct AnimationState*
public _AddAnimationState.addAnimation
_AddAnimationState:
    push rbp
    mov rbp, rsp

    sub rsp, 40

    mov [rbp - 8], rdi
    mov [rbp - 12], esi
    mov [rbp - 16], edx
    mov [rbp - 20], ecx
    mov [rbp - 24], r8d
    mov [rbp - 28], r9d

    mov rax, [rbp - 8]
    mov rax, [rax]
    mov eax, [rax + 48]
    cmp eax, 0
    jg .reAllocation

    ; Allocation memory for animationStates
    ; 20 bytes (struct AnimationState)
    mov edi, 20
    call malloc
    mov rdx, [rbp - 8]
    mov rdx, [rdx]
    mov [rdx + 40], rax

    ; Reset AnimationStateCount
    mov dword [rdx + 48], 0

    jmp .addAnimation

.reAllocation:
    mov rax, [rbp - 8]
    mov rax, [rax]
    lea rdx, [rax + 40]
    mov eax, [rax + 48]
    add eax, 1
    imul eax, 20
    cdqe
    mov rsi, rax
    mov rdi, rdx
    call realloc
    mov rdx, [rbp - 8]
    mov rdx, [rdx]
    mov [rdx + 40], rax

.addAnimation:
    mov rax, [rbp - 8]
    mov rax, [rax]
    mov rdx, [rax + 40]
    mov eax, [rax + 48]
    imul eax, 20
    cdqe
    add rdx, rax
    mov [rbp - 36], rdx

    ; Fill new Animation
    mov rax, [rbp - 36]

    ; startFrame
    mov edx, [rbp - 20]
    mov ecx, [rbp - 24]
    mov [rax], edx
    mov [rax + 4], ecx

    ; endFrame
    pxor xmm0, xmm0
    mov edx, [rbp - 28]
    cvtsi2ss xmm0, edx
    movss [rax + 8], xmm0

    ; state
    mov edx, [rbp - 12]
    mov [rax + 12], edx

    ; direction
    mov edx, [rbp - 16]
    mov [rax + 16], edx

    ; stateCount++
    mov rax, [rbp - 8]
    mov rax, [rax]
    mov dword [rax + 48], 1

.return:
    add rsp, 40

    pop rbp
    ret

; rdi = Player*
; esi = state
; edx = direction

; [rbp - 8], player*
; [rbp - 12], state
; [rbp - 16], direction
; [rbp - 20], index
; [rbp - 40], struct AnimationStates
public _SetPlayerAnimation
_SetPlayerAnimation:
    push rbp
    mov rbp, rsp

    sub rsp, 40

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
    mov eax, [rbp - 4]
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
    cdqe
    add rdx, rax

    mov rax, [rbp - 8]
    lea rax, [rax + 8]
    mov [rax], rdx

;   player->currentFrame = player->entity->animationStates[i].animationSequence.startFrameIndex;
    mov rax, [rbp - 8]
    mov rax, [rax]
    mov rdx, [rax + 40]
    mov eax, [rbp - 20]
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

    add rsp, 40
    pop rbp
    ret

