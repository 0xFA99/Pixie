_render:
    call BeginDrawing

    mov rdi, 0xFF181818
    call ClearBackground

    sub rsp, 16
    mov rcx, rsp

    ; Texture2D = texture
    mov rax, qword [spriteSheet.texture]
    mov rdx, qword [spriteSheet.texture + 8]

    mov [rcx], rax
    mov [rcx + 8], rdx

    mov eax, dword [spriteSheet.texture + 12]
    mov [rcx + 12], eax

    ; Rectangle = source
    mov rax, [spriteSheet.frames]
    movsd xmm0, [rax]
    movsd xmm1, [rax + 8]

    ; Rectangle = dest
    movsd xmm2, [playerPosition]
    movsd xmm3, [rax + 8]

    ; Vector2 = origin
    pxor xmm4, xmm4

    ; float = rotation
    pxor xmm5, xmm5

    ; Color = tint
    mov rdi, 0xFFFFFFFF

    call DrawTexturePro

    add rsp, 16

    call EndDrawing

