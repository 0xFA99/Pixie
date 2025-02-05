_LoadSpriteSheetData:
    lea rax, [player.entity.spriteSheet]
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
    mov [player.entity.spriteSheet.frameCount], eax

    mov eax, [player.entity.spriteSheet.texture.width]
    mov ecx, [rbp - 8]
    idiv ecx
    mov [rbp - 12], eax                         ; Width

    mov eax, [player.entity.spriteSheet.texture.height]
    mov ecx, [rbp - 4]
    idiv ecx 
    mov [rbp - 16], eax                         ; Height

    mov eax, [player.entity.spriteSheet.frameCount]
    cdqe
    sal rax, 4
    mov rdi, rax
    call malloc
    mov [player.entity.spriteSheet.frames], rax

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

    mov rax, [player.entity.spriteSheet.frames]
    add rax, rdx

    mov edx, [rbp - 28]
    imul edx, [rbp - 12]
    cvtsi2ss xmm0, edx
    movss [rax], xmm0

    mov edx, [rbp - 24]
    imul edx, [rbp - 16]
    cvtsi2ss xmm0, edx
    movss [rax + 4], xmm0

    mov edx, [rbp - 12]
    cvtsi2ss xmm0, edx
    movss [rax + 8], xmm0

    mov edx, [rbp - 16]
    cvtsi2ss xmm0, edx
    movss [rax + 12], xmm0

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

_AddFlipSpriteSheetData:
    push rbp
    mov rbp, rsp
    sub rsp, 40

    mov eax, [player.entity.spriteSheet.frameCount]
    mov [rbp - 4], eax

    add eax, eax
    mov [rbp - 8], eax

    cdqe
    sal rax, 4
    mov rdx, rax
    mov rax, [player.entity.spriteSheet.frames]

    mov rdi, rax
    mov rsi, rdx
    call realloc
    mov [player.entity.spriteSheet.frames], eax

    mov dword [rbp - 12], 0
    jmp .L1

.L2:
    mov eax, [rbp - 12]
    cdqe
    sal rax, 4
    mov rdx, rax
    mov rax, [player.entity.spriteSheet.frames]
    add rax, rdx

    movsd xmm0, [rax]
    movsd [rbp - 20], xmm0

    movss xmm0, [rax + 8]
    movss [rbp - 28], xmm0

    movss xmm0, [rax + 12]
    movss [rbp - 32], xmm0

    mov eax, [rbp - 4]
    add eax, [rbp - 12]
    cdqe
    sal rax, 4
    mov rdx, rax
    mov rax, [player.entity.spriteSheet.frames]
    add rax, rdx

    movsd xmm0, [rbp - 20]
    movsd [rax], xmm0

    movss xmm0, [rbp - 28]
    mov edx, 0x80000000             ; -0.0 (Negative Zero)
    movd xmm1, edx
    xorps xmm0, xmm1
    movss [rax + 8], xmm0

    movss xmm0, [rbp - 32]
    movss [rax + 12], xmm0

    add dword [rbp - 12], 1

.L1:
    mov eax, dword [rbp - 12]
    cmp eax, dword [rbp - 4]
    jl .L2

    add rsp, 40
    pop rbp

    jmp _gameLoop

_FreeSpriteSheetData:
    mov rdi, [player.entity.spriteSheet.frames]
    call free
	ret

