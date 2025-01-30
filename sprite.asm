_LoadSpriteSheetData:
    lea rax, [spriteSheet]
    lea rdx, [warriorSheet]

    mov rdi, rax
    mov rsi, rdx
    call LoadTexture

    push rbp
    mov rbp, rsp
    sub rsp, 32

    mov dword [rbp - 4], 17                     ; Rows
    mov dword [rbp - 8], 6                      ; Columns
    
    mov eax, [rbp - 4]
    imul eax, [rbp - 8]
    mov [spriteSheet.frameCount], eax

    mov eax, [spriteSheet.texture.width]
    mov ecx, [rbp - 8]
    idiv ecx
    mov [rbp - 12], eax                         ; Width

    mov eax, [spriteSheet.texture.height]
    mov ecx, [rbp - 4]
    idiv ecx 
    mov [rbp - 16], eax                         ; Height

    mov eax, [spriteSheet.frameCount]
    cdqe
    sal rax, 4
    mov rdi, rax
    call malloc
    mov [spriteSheet.frames], rax

    mov dword [rbp - 20], 0                     ; Counter
    mov dword [rbp - 24], 0                     ; Row index

.L4:
    mov dword [rbp - 28], 0                     ; Column Index
    jmp .L2

.L3:
    mov eax, [rbp - 20]
    cdqe
    sal rax, 4
    mov rdx, rax

    mov rax, [spriteSheet.frames]
    add rax, rdx

    mov edx, [rbp - 28]
    imul edx, [rbp - 12]
    mov dword [rax], edx

    mov edx, [rbp - 24]
    imul edx, [rbp - 16]
    mov dword [rax + 4], edx

    mov edx, [rbp - 28]
    mov dword [rax + 8], edx

    mov edx, [rbp - 24]
    mov dword [rax + 12], edx

    add dword [rbp - 20], 1
    add dword [rbp - 28], 1

.L2:
    mov eax, [rbp - 28]
    cmp eax, [rbp - 8]
    jl .L3

    add dword [rbp - 24], 1

.L1:
    mov eax, [rbp - 24]
    cmp eax, [rbp - 4]
    jl .L4

    add rsp, 32
    pop rbp

    jmp _gameLoop

_FreeSpriteSheetData:
    mov rdi, [spriteSheet.frames]
    call free

