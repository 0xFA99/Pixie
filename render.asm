public _render
_render:
    push rbp
    mov rbp, rsp
    sub rsp, 16

    call BeginDrawing
    
    mov edi, 0xFF181818
    call ClearBackground

    lea rax, [player]
    mov rax, [rax]

    mov rdx, [rax]
    mov rcx, [rax + 8]
    mov [rsp], rdx
    mov [rsp + 8], rcx
    mov edx, [rax + 12]
    mov [rsp + 12], edx

    mov edi, 100
    mov esi, 100
    mov edx, 0xFFFFFFFF
    call DrawTexture

    call EndDrawing

    add rsp, 16
    mov rsp, rbp
    pop rbp
    ret

