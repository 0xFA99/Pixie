
_InitPlayer:
    push rbp
    mov rbp, rsp

    sub rsp, 8
  
    mov [rbp - 8], rdi

    mov edi, 56
    call malloc
    test rax, rax
    je .printErrorAllocation

    mov rdx, rax

    mov rax, [rbp - 8]
    mov [rax], rdx          ; SpriteEntity*

    mov qword [rax + 8], 0  ; Animation*

    pxor xmm0, xmm0
    movsd [rax + 16], xmm0  ; movement.position
    movsd [rax + 24], xmm0  ; movement.velocity

    mov edx, -200.0f
    movd xmm0, edx
    movss [rax + 32], xmm0  ; movement.acceleration

    mov edx, 100.0f
    movd xmm0, edx
    movss [rax + 36], xmm0  ; movement.speed

.return:
    add rsp, 8

    pop rbp
    ret

.printErrorAllocation:
    lea edi, [stringFormat]
    lea esi, [failedAllocationMemory]
    call printf

    jmp .return
