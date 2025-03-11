; rdi = struct SpriteEntity*
; esi = enum state
; edx = enum direction
; ecx = int start
; r8d = int end
; r9d = int FPS
_AddAnimationState:
    push rbp
    mov rbp, rsp

    sub rsp, 64

    mov qword [rbp - 40], rdi
    mov dword [rbp - 44], esi
    mov dword [rbp - 48], edx
    mov dword [rbp - 52], ecx
    mov dword [rbp - 56], r8d
    mov dword [rbp - 60], r9d

    mov rax, [rbp - 40]
    mov rax, [rax + 40]
    test rax, rax
    jne .reAllocation

    mov edi, 20
    call malloc
    mov rdx, [rbp - 40]
    mov [rdx + 40], rax
    mov dword [rdx + 48], 0

    jmp .addAnimation
    
.return:
    add rsp, 64

    pop rbp
    ret

.reAllocation:
    mov rax, [rbp - 40]
    mov ecx, [rax + 48]
    add ecx, 1
    imul ecx, 20
    mov rsi, rcx
    mov rdi, rax
    call realloc
    mov [rbp - 8], rax
    mov rax, [rbp - 40]
    mov rdx, [rbp - 8]
    mov [rax + 40], rdx

.addAnimation:
    mov rax, [rbp - 40]
    mov rcx, [rax + 40]
    mov eax, [rax + 48]
    cdqe
    lea rax, [rax * 5]
    sal rax, 2
    add rax, rcx
    mov [rbp - 16], rax
    pxor xmm0, xmm0
    cvtsi2ss xmm0, [rbp - 60]

    mov edx, [rbp - 52]
    mov [rax], edx
    mov edx, [rbp - 56]
    mov [rax + 4], edx
    movss [rax + 8], xmm0
    mov edx, [rbp - 44]
    mov [rax + 12], edx
    mov edx, [rbp - 48]
    mov [rax + 16], edx

    lea edx, [eax + 1]
    mov [rax + 48], edx

    jmp .return

_SetPlayerAnimation:
    push rbp
    mov rbp, rsp
    
    mov [rbp - 40], rdi
    mov [rbp - 44], esi
    mov [rbp - 48], edx

    mov dword [rbp - 4], 0

    jmp .L1

.L3:
    mov rax, [rbp - 40]
    mov rax, [rax]
    mov rcx, [rax + 48]
    mov eax, [rbp - 4]
    cdqe
    lea rax, [rax * 5]
    sal rax, 2
    add rcx, rax

    mov rax, [rcx]
    mov [rbp - 32], rax
    mov rax, [rcx + 8]
    mov [rbp - 24], rax
    mov eax, [rcx + 16]
    mov [rbp - 16], eax

    mov eax, [rbp - 20]
    cmp [rbp - 44], eax
    jne .L2

    cmp eax, [rbp - 16]
    cmp eax, [rbp - 48]
    jne .L2

    mov rax, [rbp - 40]
    mov rax, [rax]
    mov rcx, [rax + 40]
    mov eax, [rbp - 4]
    cdqe
    lea rax, [rax * 5]
    sal rax, 2
    lea rdx, [rcx + rax]
    mov rax, [rbp - 40]
    mov [rax + 8], rdx

    mov rax, [rbp - 40]
    mov rdx, [rax]
    mov rcx, [rdx + 40]
    mov eax, [rbp - 4]
    cdqe
    lea rax, [rax * 5]
    sal rax, 5
    add rax, rcx

    mov edx, [rax]
    mov rax, [rbp - 40]
    mov [rax + 48], edx
    mov ecx, [rbp - 44]
    mov edi, [rbp - 48]
    mov [rax + 40], ecx
    mov [rax + 44], edi

.L2:
    add dword [rbp - 4], 1

.L1:
    mov rax, [rbp - 40]
    ; mov rax, [rax]
    mov eax, [rax + 48]
    cmp [rbp - 4], eax
    jl .L3

    pop rbp
    ret

