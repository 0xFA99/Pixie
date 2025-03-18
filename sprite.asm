; ============== PARAMETERS ==============
; [rbp -  8]    = file
; [rbp - 12]    = rows
; [rbp - 16]    = columns

; ============= SPRITESHEET ==============
; [rbp - 20]    = Texture.format
; [rbp - 24]    = Texture.mipmaps
; [rbp - 28]    = Texture.height
; [rbp - 32]    = Texture.width
; [rbp - 36]    = Texture.id
; [rbp - 44]    = Frames*
; [rbp - 48]    = FrameCount

; ============== VARIABLES ===============
; [rbp - 52]    = width
; [rbp - 56]    = height
; [rbp - 60]    = counter
; [rbp - 64]    = index row
; [rbp - 68]    = index column

_LoadSpriteSheet:
    push rbp
    mov rbp, rsp
    sub rsp, 80

    mov [rbp - 8], rdi
    mov [rbp - 12], esi
    mov [rbp - 16], edx

    lea rdi, [rbp - 36]
    mov rsi, [rbp - 8]
    call LoadTexture

    ; FrameCount = rows * columns
    mov eax, [rbp - 12]
    imul eax, [rbp - 16]
    mov [rbp - 48], eax

    ; Texture.width / columns
    mov eax, [rbp - 32]
    mov ecx, [rbp - 16]
    xor edx, edx
    idiv ecx
    mov [rbp - 52], eax

    ; Texture.height / rows
    mov eax, [rbp - 28]
    mov ecx, [rbp - 12]
    xor edx, edx
    idiv ecx
    mov [rbp - 56], eax

    ; malloc(sizeof(Rectangle) * FrameCount)
    ; Store into frames*
    mov eax, [rbp - 48]
    imul eax, 16
    mov rdi, rax
    call malloc
    mov [rbp - 44], rax

    mov dword [rbp - 64], 0

.L4:
    mov dword [rbp - 68], 0
    jmp .L2

.L3:
    ; Frame.x = column * width
    mov edx, [rbp - 68]
    imul edx, [rbp - 52]
    cvtsi2ss xmm0, edx

    ; Frame.y = row * height
    mov edx, [rbp - 64]
    imul edx, [rbp - 56]
    cvtsi2ss xmm1, edx

    ; Frame.width = width
    mov edx, [rbp - 52]
    cvtsi2ss xmm2, edx

    ; Frame.height = height
    mov edx, [rbp - 56]
    cvtsi2ss xmm3, edx

    mov rdx, [rbp - 44]
    mov eax, [rbp - 60]
    imul eax, 16
    cdqe
    add rax, rdx

    movss [rax], xmm0
    movss [rax + 4], xmm1
    movss [rax + 8], xmm2
    movss [rax + 12], xmm3
    
    add dword [rbp - 60], 1
    add dword [rbp - 68], 1
    
.L2:
    mov eax, [rbp - 68]
    cmp eax, [rbp - 16]
    jl .L3

    add dword [rbp - 64], 1

.L1:
    mov eax, [rbp - 64]
    cmp eax, [rbp - 12]
    jl .L4

    ; Return SpriteSheet
    ; Texture
    mov rax, [rbp - 36]
    mov rdx, [rbp - 28]
    mov rcx, [rbp - 20]
    mov [rbp + 16], rax
    mov [rbp + 24], rdx
    mov [rbp + 32], rcx

    ; Frames*
    mov rax, [rbp - 44]
    mov [rbp + 36], rax

    ; FrameCount
    mov rax, [rbp - 48]
    mov [rbp + 44], rax

    add rsp, 80
    pop rbp
    ret

; ============== PARAMETERS ==============
; [rbp - 8]     = Player*

; ============== VARIABLES ===============
; [rbp - 12]    = Original FrameCount
; [rbp - 16]    = New FrameCount
; [rbp - 20]    = Index
; [rbp - 36]    = Temporary Rectangle

_AddFlipSpriteSheet:
    push rbp
    mov rbp, rsp
    sub rsp, 48

    mov [rbp - 8], rdi

    mov rax, [rbp - 8]
    mov rax, [rax]
    mov eax, [rax + 32]
    mov [rbp - 12], eax

    add eax, eax
    mov [rbp - 16], eax

    mov rax, [rbp - 8]
    mov rax, [rax]
    mov rdi, [rax + 24]
    mov eax, [rbp - 16]
    imul eax, 16
    cdqe
    mov rsi, rax
    call realloc
    mov rdx, [rbp - 8]
    mov rdx, [rdx]
    mov [rdx + 24], rax

    mov dword [rbp - 20], 0

    jmp .L1

.L2:
    ; Temporary Rectangle
    ; Rectangle = spritesheet->frames[i]
    mov rax, [rbp - 8]
    mov rax, [rax]
    mov rdx, [rax + 24]
    mov eax, [rbp - 20]
    imul eax, 16
    cdqe
    add rax, rdx
    movsd xmm0, [rax]
    movsd xmm1, [rax + 8]
    movsd [rbp - 36], xmm0
    movsd [rbp - 28], xmm1

    ; Copy position(x, y) of temporary rectangle
    ; to new frame
    mov rax, [rbp - 8]
    mov rax, [rax]
    mov rdx, [rax + 24]
    mov eax, [rbp - 12]
    add eax, [rbp - 20]
    imul eax, 16
    cdqe
    add rdx, rax

    ; Copy Rectangle.x
    movsd xmm0, [rbp - 36]
    movsd [rdx], xmm0

    ; Copy Rectangle.width [Negative]
    movss xmm0, [rbp - 28]
    mov eax, -0.0
    movd xmm1, eax
    xorps xmm0, xmm1
    movss [rdx + 8], xmm0

    ; Copy Rectangle.height
    movss xmm0, [rbp - 24]
    movss [rdx + 12], xmm0

    add dword [rbp - 20], 1

.L1:
    mov eax, [rbp - 20]
    cmp eax, [rbp - 12]
    jl .L2

    ; Change original to new frameCount
    mov rax, [rbp - 8]
    mov rax, [rax]
    mov edx, [rbp - 16]
    mov [rax + 32], edx

    add rsp, 48
    pop rbp
    ret

