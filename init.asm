
_InitPlayer:
    push rbp
    mov rbp, rsp

    sub rsp, 16
  
    mov [rsp + 8], rdi

    mov rdi, 56
    call malloc
    mov [rsp + 8], rax
    cmp dword [rsp + 8], 0
    je .printErrorAllocation

    mov rax, [rsp + 8]
    pxor xmm0, xmm0
    movsd [rax + 16], xmm0  ; 16, 20
    movsd [rax + 24], xmm0  ; 24, 28

    mov edx, -200.0f
    movd xmm0, edx
    movss [rax + 32], xmm0

    mov edx, 100.0f
    movd xmm0, edx
    movss [rax + 36], xmm0

.return:
    add rsp, 16

    pop rbp
    ret

.printErrorAllocation:
    lea edi, [stringFormat]
    lea esi, [failedAllocationMemory]
    call printf

    jmp .return
