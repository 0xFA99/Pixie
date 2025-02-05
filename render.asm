_render:
    call BeginDrawing

    mov rdi, 0xFF181818
    call ClearBackground

    sub rsp, 0x20
    mov rcx, rsp

    mov rax, [camera2D]
    mov rdx, [camera2D + 8]
    mov [rcx], rax
    mov [rcx + 8], rdx

    mov rax, [camera2D + 16]
    mov [rcx + 16], rax

    call BeginMode2D
    add rsp, 0x20

    sub rsp, 16
    mov rcx, rsp

    ; Texture2D = texture
    mov rax, qword [player.entity.spriteSheet.texture]
    mov rdx, qword [player.entity.spriteSheet.texture + 8]

    mov [rcx], rax
    mov [rcx + 8], rdx

    mov eax, dword [player.entity.spriteSheet.texture + 12]
    mov [rcx + 12], eax

    ; Rectangle = source
    mov rax, [player.entity.spriteSheet.frames]
    movsd xmm0, [rax]
    movsd xmm1, [rax + 8]

    ; Rectangle = dest
    movsd xmm2, [player.movement]
    movsd xmm3, [rax + 8]

    ; Vector2 = origin
    pxor xmm4, xmm4

    ; float = rotation
    pxor xmm5, xmm5

    ; Color = tint
    mov rdi, 0xFFFFFFFF

    call DrawTexturePro

    add rsp, 16

    call EndMode2D
    call EndDrawing

