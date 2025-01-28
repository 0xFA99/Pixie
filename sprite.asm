    ; Load SpriteSheet

_LoadSpriteSheetData:
    lea rax, [spriteSheet]
    lea rdx, [warriorSheet]

    mov rdi, rax
    mov rsi, rdx
    call LoadTexture

    mov eax, 6
    imul eax, 17
    mov [spriteSheet.frameCount], eax

    push rbp
    mov rbp, rsp
    sub rsp, 20

    mov eax, [spriteSheet.texture.width]
    xor ecx, ecx
    mov ecx, 6                              ; Columns Sheet
    idiv ecx
    mov [rbp - 4], eax                      ; width

    mov eax, [spriteSheet.texture.height]
    mov ecx, 17                             ; Rows Sheet
    idiv ecx
    mov [rbp - 8], eax                      ; height

    mov eax, [spriteSheet.frameCount]
    imul eax, 16                            ; Rectangle bytes
    mov edi, eax 
    call malloc
    mov [spriteSheet.frames], rax

    mov dword [rbp - 12], 0                 ; Count Index
    mov dword [rbp - 16], 0                 ; row index

.L4:
    mov dword [rbp - 20], 0                 ; Column Index
    jmp .L2

.L3:
    mov eax, [rbp - 12]
    cdqe
    sal eax, 4
    mov rdx, rax
    mov rax, [spriteSheet.frames]
    add rdx, rax

    mov eax, [rbp - 20]
    imul eax, [rbp - 4]

    mov dword [rdx.x], eax

    add dword [rbp - 12], 1
    add dword [rbp - 20], 1

.L2:
    mov eax, [rbp - 20]
    cmp eax, [rbp - 4]
    jl .L3
    add dword [rbp - 4], 1

.L1:
    mov eax, [rbp - 16]
    cmp eax, [rbp - 8]
    jl .L4

    add rsp, 20
    pop rbp

