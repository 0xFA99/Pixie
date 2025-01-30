_render:
    call BeginDrawing

    mov rdi, 0xFF181818
    call ClearBackground

    ; Try Draw Sprite
    ; texture, frame, position, origin, rotate, color

    ; Texture
    sub rsp, 16
    mov rcx, rsp

    mov rax, qword [spriteSheet.texture.id]
    mov rdx, qword [spriteSheet.texture.height]

    mov [rcx], rax
    mov [rcx + 8], rdx

    mov eax, dword [spriteSheet.texture.format]
    mov [rcx + 12], eax

    ; Frame
    mov rax, qword [spriteSheet.frames]
    movq xmm0, rax

    mov rax, qword [spriteSheet.frames.width]
    movq xmm1, rax
    
    ; Position
    pxor xmm2, xmm2
    movdqa xmm3, xmm2

    ; Offset
    movdqa xmm4, xmm2

    pxor xmm5, xmm5

    mov rdi, 0xFFFF0000

    call DrawTexturePro
    add rsp, 16

    call EndDrawing
