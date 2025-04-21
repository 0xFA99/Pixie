; ============== PARAMETERS ==============
; rdi           = SpriteEntity
; rsi           = Texture file
; edx           = rows
; ecx           = columns

; ============== VARIABLES ===============
; [rbp -  4]    = width
; [rbp -  8]    = height
; [rbp - 12]    = index row
; [rbp - 16]    = index column

_loadSpriteEntity:
    push rbp
    mov rbp, rsp

    ; Backup arguments
    mov r12, rdi                    ; SpriteEntity
    mov r13, rsi                    ; Texture file
    mov r14d, edx                   ; rows
    mov r15d, ecx                   ; columns

    call _loadTexture

    ; frameCount = rows * columns
    mov eax, r14d
    imul eax, r15d
    mov [r12 + 28], eax             ; SpriteEntity.frameCount

    ; Allocate stack space for local variables
    sub rsp, 16
 
    ; Calculate frame width: textureWidth / columns
    xor edx, edx
    mov eax, [r12 + 4]              ; texture.width
    idiv r15d
    mov [rbp - 4], eax              ; Save frame width

    ; Calculate frame height: textureHeight / rows
    xor edx, edx
    mov eax, [r12 + 8]              ; texture.height
    idiv r14d
    mov [rbp - 8], eax              ; Save frame height

    ; Allocate memory for Rectangle array: frameCount * 16 bytes
    mov edi, [r12 + 28]
    imul edi, 16
    call malloc
    mov [r12 + 20], rax             ; SpriteEntity.SpriteSheet.frames

    ; Initialize loop counters
    xor ecx, ecx                    ; counter
    mov dword [rbp - 12], 0         ; index row

.loop1:
    cmp dword [rbp - 12], r14d
    jge .return                     ; if row >= rows, exit loop

    ; Reset index column
    mov dword [rbp - 16], 0

.loop2:
    cmp dword [rbp - 16], r15d
    jge .next_row                   ; if colum >= columns, next row

    ; Calculate Rectangle frame

    ; Get X: index column * width
    mov eax, [rbp - 16]
    imul eax, [rbp - 4]
    cvtsi2ss xmm0, eax              ; xmm0 = x

    ; Get Y: index row * height
    mov eax, [rbp - 12]
    imul eax, [rbp - 8]
    cvtsi2ss xmm1, eax              ; xmm1 = y

    ; Load width and height
    cvtsi2ss xmm2, [rbp - 4]        ; xmm2 = width
    cvtsi2ss xmm3, [rbp - 8]        ; xmm3 = height

    ; Pack into xmm0 = { x, y, width, height }
    unpcklps xmm0, xmm1             ; xmm0 = { x, y }
    unpcklps xmm2, xmm3             ; xmm2 = { width, height }
    shufps xmm0, xmm2, 01000100b    ; xmm0 = { x, y, width, height }

    ; Get pointer to frames[counter]
    mov rdi, [r12 + 20]             ; base adress
    mov eax, ecx
    imul eax, 16
    cdqe
    add rdi, rax

    ; Store all 4 floats at once
    movups [rdi], xmm0

    ; Increase counter and index column
    inc ecx
    add dword [rbp - 16], 1
    jmp .loop2

.next_row:
    add dword [rbp - 12], 1
    jmp .loop1

.return:
    add rsp, 16
    pop rbp
    ret

; ============== PARAMETERS ==============
; rdi           = SpriteEntity

_addFlipTexture:
    ; Save SpriteEntity address to r12
    mov r12, rdi

    ; Get frameCount and store in r13d
    mov r13d, [r12 + 28]

    ; Calculate new frameCount (frameCount * 2)
    ; Store result in r14d
    mov eax, r13d
    add eax, eax
    mov r14d, eax

    ; Reallocate frames with new frameCount
    mov eax, r14d                   ; new frameCount
    imul eax, 16
    cdqe
    mov rsi, rax
    mov rdi, [r12 + 20]             ; frames*
    call realloc
    mov [r12 + 20], rax

    ; Initialize index for looping
    mov r15d, 0

    ; Copy and modify all frame data

.loop:
    ; Check if index >= frameCount
    cmp r15d, r13d
    jge .return

    ; Load 2 frames (original and flipped) into xmm0
    mov rdi, [r12 + 20]
    mov eax, r15d
    imul eax, 16
    cdqe
    add rdi, rax
    movaps xmm0, [rdi]              ; Load original frame

    ; Load new frame[index + frameCount] into rdi
    mov rdi, [r12 + 20]
    mov eax, r15d
    add eax, r13d
    imul eax, 16
    cdqe
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
    ; Update frameCount with new frameCount
    mov [r12 + 28], r14d

    ret

