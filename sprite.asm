_loadSpriteSheet:
    push rbp
    mov rbp, rsp

    ; backup arguments
    mov r12, rdi                    ; sprite
    mov r13, rsi                    ; texture
    mov r14d, edx                   ; rows
    mov r15d, ecx                   ; columns
    call LoadTexture

    ; sprite->frameCount = rows * columns
    mov eax, r14d
    imul eax, r15d
    mov [r12 + 28], eax

    ; Allocate 16 bytes stack for local variable
    sub rsp, 16

    ; frame.width = texture.width / columns
    xor edx, edx
    mov eax, [r12 + 4]              ; texture.width
    idiv r15d
    mov [rbp - 4], eax              ; [rbp - 4] frame.width

    ; frame.height = texture/height/ rows
    xor edx, edx
    mov eax, [r12 + 8]              ; texture.height
    idiv r14d
    mov [rbp - 8], eax              ; [rbp - 8] frame.height

    mov edi, [r12 + 28]             ; sprite.frameCount
    imul edi, 16                    ; sizeof Rectangle
    call malloc
    mov [r12 + 20], rax             ; sprite.frames*

    ; Initialize loop counters
    xor ecx, ecx                    ; counter
    mov dword [rbp - 12], 0         ; index row

.loop_x:
    cmp dword [rbp - 12], r14d      ; row >= rows
    jge .return                     ; exit loop

    ; Reset column
    mov dword [rbp - 16], 0

.loop_y:
    cmp dword [rbp - 16], r15d      ; column >= columns
    jge .next_row

    ; Calculate frame
    ; frame.x = column * width
    mov eax, [rbp - 16]
    imul eax, [rbp - 4]
    cvtsi2ss xmm0, eax              ; xmm0 = x

    ; frame.y = row * height
    mov eax, [rbp - 12]
    imul eax, [rbp - 8]
    cvtsi2ss xmm1, eax              ; xmm1 = y

    ; load width and height 
    cvtsi2ss xmm2, [rbp - 4]        ; xmm2 = width
    cvtsi2ss xmm3, [rbp - 8]        ; xmm3 = height

    ; Pack into xmm0 = { x, y, width, height }
    unpcklps xmm0, xmm1             ; xmm0 = { x, y }
    unpcklps xmm2, xmm3             ; xmm2 = { width, height }
    shufps xmm0, xmm2, 01000100b    ; xmm0 = { x, y, width, height }

    ; Get pointer to frames[counter]
    mov rdi, [r12 + 20]             ; base address
    mov eax, ecx
    shl rax, 4
    add rdi, rax

    ; Store frame data
    movaps [rdi], xmm0

    ; Increase counter and index column
    inc ecx
    add dword [rbp - 16], 1
    jmp .loop_y

.next_row:
    add dword [rbp - 12], 1
    jmp .loop_x

.return:
    add rsp, 16
    pop rbp
    ret

_addFlipSheet:
    ; Save SpriteEntity address to r12
    mov r12, rdi

    ; Get frameCount and store in r13d
    mov r13d, [r12 + 28]
  
    ; Calculate new frameCount (frameCount * 2)

    ; Store resultt in r14d
    mov eax, r13d
    add eax, eax
    mov r14d, eax

    ; Realloc frames with new frameCount
    shl rax, 4
    mov rsi, rax
    mov rdi, [r12 + 20]             ; frames*
    call realloc
    mov [r12 + 20], rax

    ; Initialize index for looping
    mov r15d, 0

.loop:
    ; Check if index >= frameCount
    cmp r15d, r13d
    jge .return

    ; Load 2 frames (original and flipped) into xmm0
    mov rdi, [r12 + 20]
    mov eax, r15d
    shl rax, 4
    add rdi, rax
    movaps xmm0, [rdi]              ; Load original frame

    ; Load new frame[index + frameCount] into rdi
    mov rdi, [r12 + 20]
    mov eax, r15d
    add eax, r13d
    shl rax, 4
    add rdi, rax

    ; Flip the width: negate the value in xmm0
    xorps xmm1, xmm1
    mov eax, -0.0
    movd xmm1, eax
    pslldq xmm1, 8
    xorps xmm0, xmm1

    ; Store updated frame values into the new frame
    movaps [rdi], xmm0

    ; Increase index
    inc r15d

    jmp .loop

.return:
    ; Update old frameCount with new frameCount
    mov [r12 + 28], r14d
    ret

