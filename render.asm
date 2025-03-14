; rdi = Player*
public _RenderPlayer
_RenderPlayer:
    push rbp
    mov rbp, rsp
    sub rsp, 80

    mov [rbp - 8], rdi

    ; Texture 20 bytes
    mov rax, [rbp - 8]
    mov rax, [rax]

    mov rdx, [rax]
    mov rcx, [rax + 8]
    mov [rbp - 28], rdx
    mov [rbp - 20], rcx
    mov eax, [rax + 16]
    mov [rbp - 12], eax

    ; Frame 16 bytes
    mov rax, [rbp - 8]
    mov rax, [rax]
    mov rdx, [rax + 24]

    mov rax, [rbp - 8]
    mov eax, [rax + 48]
    imul eax, 16
    cdqe
    add rax, rdx

    movsd xmm0, [rax]
    movsd xmm1, [rax + 8]
    movsd [rbp - 44], xmm0
    movsd [rbp - 36], xmm1

    ; Position 16 bytes
    mov rax, [rbp - 8]
    movsd xmm0, [rax + 16]
    movsd [rbp - 60], xmm0

    movss xmm0, [rbp - 32]
    movss [rbp - 48], xmm0

    movss xmm0, [rbp - 36]
    movss [rbp - 52], xmm0

    ; Vector 8 bytes
    pxor xmm0, xmm0
    movsd [rbp - 68], xmm0

    sub rsp, 32
    mov rcx, rsp

    ; texture
    mov rax, [rbp - 28]
    mov rdx, [rbp - 20]
    mov [rcx], rax
    mov [rcx + 8], rdx
    mov eax, [rbp - 12]
    mov [rcx + 16], eax
   
    ; frame
    movsd xmm0, [rbp - 44]
    movsd xmm1, [rbp - 36]

    ; position
    movsd xmm2, [rbp - 60]
    movsd xmm3, [rbp - 52]

    ; offset
    movsd xmm4, [rbp - 68]

    ; rotation
    pxor xmm5, xmm5

    ; Color = 0xFFFFFFFF
    mov edi, -1

    call DrawTexturePro
    add rsp, 32

    add rsp, 80
    pop rbp
    ret

