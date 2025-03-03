; rdi = const char *file
; esi = int rows
; edx = int columns

; [rbp + 16] = struct SpriteSheet - texture
; [rbp + 40] = struct SpriteSheet - *frames
; [rbp + 48] = struct SpriteSheet - frameCount

; [rbp - 8]  = const char *file
; [rbp - 12] = int rows
; [rbp - 16] = int columns
; [rbp - 20] = width
; [rbp - 24] = height
; [rbp - 28] = counter
; [rbp - 32] = index row
; [rbp - 36] = index column
_LoadSpriteSheet:
    push rbp
    mov rbp, rsp
    sub rsp, 48

    mov qword [rbp - 8], rdi
    mov dword [rbp - 12], esi
    mov dword [rbp - 16], edx

    mov rsi, rdi
    lea rdi, [rbp + 16]
    call LoadTexture

    cmp dword [rbp + 16], 0
    je .printErrorLoadTexture

    ; frameCount = rows * columns
    mov eax, [rbp - 12]
    imul eax, [rbp - 16]
    mov dword [rbp + 48], eax

    ; width = texture.width / columns
    mov eax, [rbp + 20]
    mov ecx, [rbp - 16]
    idiv ecx
    mov [rbp - 20], eax

    ; height = texture.height / rows
    mov eax, [rbp + 24]
    mov ecx, [rbp - 12]
    idiv ecx
    mov [rbp - 24], ecx

    mov eax, [rbp + 48]
    cdqe
    sal rax, 4
    mov rdi, rax
    call malloc
    mov [rbp + 40], rax    

    cmp qword [rbp + 40], 0
    je .printErrorAllocation

    mov dword [rbp - 28], 0
    mov dword [rbp - 32], 0

    jmp .L1

.L4:
    mov dword [rbp - 36], 0
    jmp .L2

.L3:
    mov eax, [rbp - 28]
    cdqe
    sal rax, 4
    mov rdx, rax

    mov rax, [rbp + 40]
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

    add dword [rbp - 28], 1
    add dword [rbp - 36], 1

.L2:
    mov eax, [rbp - 36]
    cmp eax, [rbp - 16]
    jl .L3

    add dword [rbp - 32], 1

.L1:
    mov eax, [rbp - 32]
    cmp eax, [rbp - 12]
    jl .L4

.return:
    add rsp, 48

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

; rdi = SpriteSheet*
; -------------------------
; [rbp - 8]     SpriteSheet*
; [rbp - 12]    new frames
; [rbp - 16]    index i
_AddFlipSpriteSheet:
    push rbp
    mov rbp, rsp
    sub rsp, 48

    mov [rbp - 8], rdi

    cmp dword [rbp - 8], 0
    je .printSpriteSheetEmpty

    mov rax, [rbp - 8]
    mov edx, [rax + 32]
    mov dword [rbp - 12], edx       ; ori frames
    add edx, edx
    mov dword [rbp - 16], edx       ; new frames

    mov eax, edx
    cdqe
    sal rax, 4
    mov rsi, rax
    mov rax, [rbp - 8]
    mov rdi, [rax + 24]
    call realloc
    mov rcx, [rbp - 8]
    mov [rcx + 24], rax

    cmp qword [rcx + 24], 0
    je .printErrorAllocation

    mov dword [rbp - 20], 0         ; index i

    jmp .L1

.L2:
    mov eax, [rbp - 20]
    cdqe
    sal rax, 4
    mov rdx, rax
    mov rax, [rbp - 8]
    mov rax, [rax + 24]
    add rax, rdx

    movsd xmm0, [rax]
    movsd [rbp - 28], xmm0

    movss xmm0, [rax + 8]
    movss [rbp - 32], xmm0

    movss xmm0, [rax + 12]
    movss [rbp - 36], xmm0

    mov eax, [rbp - 12]
    add eax, [rbp - 20]
    cdqe
    sal rax, 4
    mov rdx, rax
    mov rax, [rbp - 8]
    mov rax, [rax + 24]
    add rax, rdx

    movsd xmm0, [rbp - 28]
    movsd [rax], xmm0

    movss xmm0, [rbp - 32]
    mov edx, -0.0f
    movd xmm1, edx
    xorps xmm0, xmm1
    movss [rax + 8], xmm0

    movss xmm0, [rbp - 36]
    movss [rax + 12], xmm0

    add dword [rbp - 20], 1

.L1:
    mov eax, [rbp - 20]
    cmp eax, [rbp - 12]
    jl .L2
 
.return:
    add rsp, 48

    pop rbp
    ret

.printErrorAllocation:
    lea edi, [stringFormat]
    lea esi, [failedAllocationMemory]
    call printf

    jmp .return

.printSpriteSheetEmpty:
    lea edi, [stringFormat]
    lea esi, [spriteSheetEmpty]
    call printf

    jmp .return

