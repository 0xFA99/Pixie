_render:
    push rbp
    mov rbp, rsp

    call BeginDrawing
    
    mov edi, 0xFF181818
    call ClearBackground

    call EndDrawing

    mov rsp, rbp
    pop rbp
    ret

