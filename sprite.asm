_LoadSpriteSheet:
    push rbp
    mov rbp, rsp

    sub rsp, 72

    mov [rbp - 8], rdi      ; warriorSheet
    mov [rbp - 12], esi     ; rows
    mov [rbp - 16], edx     ; column

    ; [rbp - 20] = width
    ; [rbp - 24] = height
    ; [rbp - 28] = counter
    ; [rbp - 32] = index row
    ; [rbp - 36] = index column

    ; [rbp - 72] = struct SpriteSheet - texture.id
    ; [rbp - 48] = struct SpriteSheet - *frames
    ; [rbp - 40] = struct SpriteSheet - frameCount

    lea rdi, [rbp - 72]
    mov rsi, [rbp - 8]
    call LoadTexture

    ; if texture.id 0
    cmp dword [rbp - 72], 0
    je .printErrorLoadTexture

    ; frameCount = rows * column
    mov eax, [rbp - 12]
    imul eax, [rbp - 16]
    mov [rbp - 40], eax

    ; width = texture.width / columns
    mov eax, [rbp - 68]
    mov ecx, [rbp - 16]
    idiv ecx
    mov [rbp - 20], eax

    ; height = texture.height / rows
    mov eax, [rbp - 64]
    mov ecx, [rbp - 12]
    idiv ecx
    mov [rbp - 24], ecx

    ; frames = malloc
    mov eax, [rbp - 40]
    cdqe
    sal rax, 4                      ; 16 bytes
    mov rdi, rax
    call malloc
    mov [rbp - 48], rax
   
   ; if frame == NULL
   cmp qword [rbp - 48], 0
   je .printErrorAllocation

    mov dword [rbp - 28], 0         ; counter
    mov dword [rbp - 32], 0         ; index row

    jmp .L1

.L4:
    mov dword [rbp - 36], 0         ; index column
    jmp .L2

.L3:
    mov eax, [rbp - 28]
    cdqe
    sal rax, 4
    mov rdx, rax

    mov rax, [rbp - 48]
    add rax, rdx

    mov edx, [rbp - 36]
    imul edx, [rbp - 20]
    cvtsi2ss xmm0, edx
    movss [rax], xmm0

    mov edx, [rbp - 32]
    imul edx, [rbp - 24]
    cvtsi2ss xmm0, edx
    movss [rax + 4], xmm0

    mov edx, [rbp - 20]
    cvtsi2ss xmm0, edx
    movss [rax + 8], xmm0

    mov edx, [rbp - 24]
    cvtsi2ss xmm0, edx
    movss [rax + 12], xmm0

    add dword [rbp - 28], 1         ; counter++
    add dword [rbp - 36], 1         ; column++

.L2:
    mov eax, [rbp - 36]
    cmp eax, [rbp - 16]             ; column < clumn
    jl .L3

    add dword [rbp - 32], 1         ; row++

.L1:
    mov eax, [rbp - 32]
    cmp eax, [rbp - 12]             ; row < rows
    jl .L4

    ; Return
    lea rcx, [rbp + 56]

    mov rax, [rbp - 72]
    mov rdx, [rbp - 64]
    mov [rcx], rax
    mov [rcx + 8], rdx

    mov eax, [rbp - 56]
    mov [rcx + 16], eax             ; texture

    mov rax, [rbp - 48]
    mov [rcx + 20], rax             ; frames*

    mov eax, [rbp - 40]
    mov [rcx + 36], eax             ; frameCount

.return:
    add rsp, 72

    mov rsp, rbp
    pop rbp
    ret

.printErrorLoadTexture:
    lea edi, [stringFormat]
    lea esi, [failedLoadTexture]
    call printf

    jmp .return

.printErrorAllocation:
    lea edi, [stringFormat]
    lea esi, [failedAllocationMemory]
    call printf

    jmp .return

