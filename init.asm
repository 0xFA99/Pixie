_initPlayer:
    mov r12, rdi

    mov edi, 48
    call malloc
    mov [r12], rax

    mov dword [r12 + 16], 0.0
    mov dword [r12 + 20], 300.0

    ret
