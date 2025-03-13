; rdi = struct SpriteEntity*
; esi = enum state
; edx = enum direction
; ecx = int start
; r8d = int end
; r9d = int FPS

; public _AddAnimationState
; _AddAnimationState:
;     push rbp
;     mov rbp, rsp
;     sub rsp, 64
; 
;     mov qword [rbp - 40], rdi
;     mov dword [rbp - 44], esi
;     mov dword [rbp - 48], edx
;     mov dword [rbp - 52], ecx
;     mov dword [rbp - 56], r8d
;     mov dword [rbp - 60], r9d
; 
;     mov rax, [rbp - 40]
;     mov rax, [rax]
;     mov rax, [rax + 40]
;     test rax, rax
;     jne .reAllocation
; 
;     ; Allocated 20 bytes (sizeof AnimationState)
;     mov edi, 20
;     call malloc
;     mov rdx, [rbp - 40]
;     mov rdx, [rdx]
;     mov [rdx + 40], rax
; 
;     ; AnimationStateCount = 0
;     ; mov rax, [rdx + 8]
;     ; mov dword [rax + 48], 4
; 
;     jmp .addAnimation
;     
; .return:
;     add rsp, 64
; 
;     pop rbp
;     ret
; 
; .reAllocation:
;     mov rax, [rbp - 40]
;     mov rax, [rax]
;     mov rdx, [rax + 40]
;     mov eax, [rax + 48]
;     add eax, 1
;     imul eax, 20
;     cdqe
;     mov rsi, rax
;     mov rdi, rdx
;     call realloc
;     mov rdx, [rbp - 40]
;     mov rdx, [rdx]
;     mov [rdx + 40], rax
; 
; .addAnimation:
;     mov rax, [rbp - 40]
;     mov rax, [rax]
;     mov rdx, [rax + 40]
;     mov eax, [rax + 48]
;     imul eax, 20
;     cdqe
;     ; add rdx, rax
;     ; mov [rbp - 16], rdx
;     mov rax, rdx
; 
;     ; mov rax, [rbp - 16]
;     mov edx, [rbp - 52]
;     mov ecx, [rbp - 56]
;     mov [rax], edx
;     mov [rax + 4], ecx
;     pxor xmm0, xmm0
;     cvtsi2ss xmm0, [rbp - 60]
;     movss [rax + 8], xmm0
; 
;     mov edx, [rbp - 44]
;     mov [rax + 12], edx
;     mov edx, [rbp - 48]
;     mov [rax + 16], edx
; 
;     mov rax, [rbp - 40]
;     mov rax, [rax]
;     add dword [rax + 48], 1
; 
;     jmp .return

; [rbp - 8],    rdi = entity*
; [rbp - 12],   esi = state
; [rbp - 16],   edx = direction
; [rbp - 20],   ecx = start
; [rbp - 24],   r8d = end
; [rbp - 28],   r9d = FPS

; [rbp - 36],   struct AnimationState*
public _AddAnimationState
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

    ; if animationStateCount >= 0
    mov rax, [rbp - 8]
    mov rax, [rax]
    mov eax, [rax + 48]
    cmp eax, 0
    je .reAllocation

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
    mov rdx, [rax + 40]
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
_SetPlayerAnimation:
    push rbp
    mov rbp, rsp

    sub rsp, 40

    ; mov [rbp - 40], rdi
    ; mov [rbp - 44], esi
    ; mov [rbp - 48], edx

    mov [rbp - 8], rdi
    mov [rbp - 12], esi
    mov [rbp - 16], edx

    mov dword [rbp - 20], 0 ; index

    ; mov dword [rbp - 4], 0  ; index

    jmp .L1

.L3:
    ; mov rax, [rbp - 40]
    ; mov rax, [rax]
    ; mov rdx, [rax + 40]
    ; mov eax, [rbp - 4]
    ; imul eax, 20
    ; cdqe
    ; add rdx, rax

    ; mov rax, [rdx]
    ; mov rcx, [rdx + 8]
    ; mov [rbp - 32], rax
    ; mov [rbp - 24], rcx
    ; mov eax, [rdx + 16]
    ; mov [rbp - 16], eax
    
    ; mov rax, [rbp - 40]
    ; mov rax, [rax]
    ; mov rdx, [rax + 40]
    ; mov eax, [rbp - 4]
    ; imul eax, 20
    ; cdqe
    ; add rdx, rax

    ; mov rax, [rdx]
    ; mov rcx, [rdx + 8]
    ; mov [rbp - 32], rax
    ; mov [rbp - 24], rcx
    ; mov eax, [rcx + 16]
    ; mov [rbp - 16], eax

    ; mov eax, [rbp - 20]
    ; cmp [rbp - 44], eax
    ; jne .L2

    ; mov eax, [rbp - 16]
    ; mov [rbp - 48], eax
    ; jne .L2

    ; mov rax, [rbp - 40]
    ; mov rax, [rax]
    ; mov rdx, [rax + 40]
    ; mov eax, [rbp - 4]
    ; imul eax, 20
    ; cdqe
    ; add rdx, rax

    ; mov rax, [rbp - 40]
    ; mov [rax + 8], rdx      ; player->animation
   
    ; mov rax, [rbp - 40]
    ; mov rdx, [rax + 40]
    ; mov eax, [rbp - 4]
    ; imul eax, 20
    ; cdqe
    ; add rdx, rax
    ; mov ecx, [rdx]
    ; mov rax, [rbp - 40]
    ; mov [rax + 48], ecx     ; player->currentFrame

    ; mov rax, [rbp - 40]
    ; mov edx, [rbp - 44]
    ; mov [rax + 40], edx     ; player->state
    ; mov edx, [rbp - 48]
    ; mov [rax + 44], edx     ; player->direction

.L2:
    add dword [rbp - 20], 1

.L1:
    mov rax, [rbp - 8]
    mov rax, [rax]
    mov eax, [rax + 48]
    cmp [rbp - 20], eax
    jl .L3

    add rsp, 40
    pop rbp
    ret

