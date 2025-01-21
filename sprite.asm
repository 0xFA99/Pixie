    ; Load SpriteSheet

    ; Load Texture
    lea rax, [spriteSheet]
    lea rdx, [warriorSheet]

    mov rdi, rax
    mov rsi, rdx
    call LoadTexture

    mov eax, 6
    imul eax, 17
    mov [spriteSheet.frameCount], eax

    sub rsp, 8
    mov rcx, rsp

    movss xmm0, [spriteSheet.texture.width]
    mov eax, 6
    cvtsi2ss xmm1, eax
    divss xmm0, xmm1
    movss [rcx], xmm0

    movss xmm0, [spriteSheet.texture.height]
    mov eax, 17
    cvtsi2ss xmm1, eax
    divss xmm0, xmm1
    movss [rcx + 8], xmm0

    add rsp, 8

    ; Unload Texture
    sub rsp, 0x20
    mov rcx, rsp

    mov rax, [spriteSheet]
    mov rdx, [spriteSheet + 8]

    mov [rcx], rax
    mov [rcx + 8], rdx

    mov eax, [spriteSheet + 16]
    mov [rcx + 16], eax

    call UnloadTexture
    add rsp, 0x20

