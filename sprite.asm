; @func     initSpriteSheet
; @desc     Bind texture to sprite and define frame grid layout
; @param    rdi     -> sprite entity
; @param    rsi     -> texture
; @param    edx     -> rows count
; @param    ecx     -> columns count
; @feat     Turns a boring texture into a  frame-splitting war machine
; @note     Breaks if you pass garbage, but so do you
_loadSpriteSheet:
    push        rbp
    mov         rbp, rsp

    ; backup arguments
    mov         r15, rdi                    ; sprite
    mov         r14d, edx                   ; rows
    mov         r13d, ecx                   ; columns

    ; overwrite {rcx, rdx, rsi, rdi, r8, r9, r11}
    call        LoadTexture

    ; sprite.frameCount = rows * columns
    mov         eax, r14d                   ; rows
    imul        eax, r13d                   ; columns
    mov         ecx, eax                    ; sprite.frameCount (backup)
    mov         [r15 + 32], eax             ; sprite.frameCount

    mov         rbx, [r15 + 4]              ; texture {width, height}

    ; frame.width = texture.width / columns
    ; xor         rdx, rdx                  ; im sure the rdx is 0 :P
    mov         eax, ebx                    ; texture.width
    idiv        r13d                        ; columns
    mov         r12d, eax                   ; frame.width

    ; frame.height = texture.height / rows
    xor         rdx, rdx
    ; mov         eax, ebx                  ; texture.height
    mov         rax, rbx                    ; texture.height
    shr         rax, 32
    idiv        r14d                        ; rows
    mov         ebx, eax                    ; frame.height

    ; allocation memory for all frames
    mov         edi, ecx                    ; @param_1, sprite.frameCount
    sal         rdi, 4                      ; sizeof Rectangle (16)

    ; overwrite {rax, rcx, rdx, rsi, rdi, rbp, rsp, r8, r9, r10, r11}
    call        malloc
    mov         [r15 + 24], rax             ; sprite.frames*
    mov         r11d, ebx                   ; frame.height
    mov         rbx, rax                    ; sprite.frames*

    ; initialize loop counters
    xor         ecx, ecx                    ; counter
    xor         r8d, r8d                    ; index row

.loop_row:
    cmp         r8d, r14d                   ; row >= rows
    jge         .done

    xor         r9d, r9d                    ; reset index column

.loop_column:
    cmp         r9d, r13d                   ; column >= columns
    jge         .next_row

    ; frame.x = column * frame.width
    mov         eax, r9d                    ; column
    imul        eax, r12d                   ; frame.width
    cvtsi2ss    xmm0, eax                   ; xmm0 {frame.x}

    ; frame.y = row * frame.height
    mov         eax, r8d                    ; row
    imul        eax, r11d                   ; frame.height
    cvtsi2ss    xmm1, eax                   ; xmm1 {frame.y}

    ; load frame {width, height}
    cvtsi2ss    xmm2, r12d                  ; xmm2 {frame.width}
    cvtsi2ss    xmm3, r11d                  ; xmm3 {frame.height}

    ; pack xmm0 {x, y, width, height}
    unpcklps    xmm0, xmm1                  ; xmm0 {x, y}
    unpcklps    xmm2, xmm3                  ; xmm2 {width, height}
    shufps      xmm0, xmm2, 01000100b       ; xmm0 {x, y, width, height}

    ; store to sprite.frames[counter]
    mov         eax, ecx                    ; counter
    shl         rax, 4                      ; sizeof Rectangle (16)
    lea         rdi, [rbx + rax]            ; sprite.frames[counter]

    ; store all data {x, y, width, height}
    movaps      [rdi], xmm0

    ; increase counter and index column
    inc         ecx                         ; counter++
    inc         r9d                         ; index column++
    jmp         .loop_column

.next_row:
    inc         r8d                         ; index row++
    jmp         .loop_row

.done:
    pop         rbp
    ret

_addFlipSheet:
    mov         r10, rdi                    ; sprite
    mov         r11d, [r10 + 32]            ; old frameCount
    lea         r12d, [r11d*2]              ; new frameCount

    ; realloc sprite.sheet to (newFrameCount << 4) bytes
    mov         rdi, [r10 + 24]             ; old sprite pointer
    mov         esi, r12d                   ; newFrameCount
    shl         esi, 4

    ; overwrite {rax, rcx, rdx, rsi, rdi, r8, r9}
    call        realloc
    mov         [r10 + 24], rax             ; update sprite.sheet

    ; prepare src/dst pointers
    mov         rbx, rax
    mov         r8, rbx
    mov         eax, r11d
    shl         rax, 4
    lea         r8, [r8 + rax]

    ; prepare flip mask in xmm1 once
    mov         eax, MASK_FLIP
    movd        xmm1, eax
    pslldq      xmm1, 8                     ; shift to upper qword

.loop:
    movaps      xmm0, [rbx]
    xorps       xmm0, xmm1
    movaps      [r8], xmm0

    lea         rbx, [rbx + 16]
    lea         r8, [r8 + 16]
    dec         r11d
    jnz         .loop

    mov         [r10 + 32], r12d            ; update frameCount
    ret

