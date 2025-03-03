_render:
    push rbp
    mov rbp, rsp
    sub rsp, 16

    call BeginDrawing
    
    mov edi, 0xFF181818
    call ClearBackground

    mov rax, [player]
    mov rdx, [player + 8]
    mov [rsp], rax
    mov [rsp + 8], rdx

    mov eax, [player + 12]
    mov [rsp + 12], eax

    mov edi, 100
    mov esi, 100
    mov edx, 0xFFFFFFFF
    call DrawTexture

    call EndDrawing

    add rsp, 16
    mov rsp, rbp
    pop rbp
    ret

