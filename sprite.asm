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
    mov         rax, rbx                    ; texture.height
    shr         rax, 32
    idiv        r14d                        ; rows
    mov         r11d, eax                   ; frame.height

    ; load frame {width, height}
    cvtsi2ss    xmm2, r12d                  ; xmm2 {frame.width}
    cvtsi2ss    xmm3, r11d                  ; xmm3 {frame.height}

    ; allocation memory for all frames
    mov         rdi, rcx                    ; sprite.frameCount
    sal         rdi, 4                      ; sizeof Rectangle (16)

    ; overwrite {rax, rcx, rdx, rsi, rdi, rbp, rsp, r8, r9, r10, r11}
    call        malloc
    mov         [r15 + 24], rax             ; sprite.frames*
    mov         rbx, rax                    ; sprite.frames*

    ; initialize loop counters
    xor         ecx, ecx                    ; counter
    xor         r8d, r8d                    ; index row

.loop_row:
    cmp         r8d, r14d                   ; row >= rows
    jge         .done

    xor         r9d, r9d                    ; reset index column

    ; frame.y = row * frame.height
    mov         eax, r8d                    ; row
    imul        eax, r11d                   ; frame.height
    cvtsi2ss    xmm1, eax                   ; xmm1 {frame.y}

.loop_column:
    cmp         r9d, r13d                   ; column >= columns
    jge         .next_row

    ; frame.x = column * frame.width
    mov         eax, r9d                    ; column
    imul        eax, r12d                   ; frame.width
    cvtsi2ss    xmm0, eax                   ; xmm0 {frame.x}

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
    ; No stack allocation needed - use existing registers
    mov         r8, rdi                     ; sprite (preserve original)
    mov         ecx, [r8 + 32]              ; old frameCount

    ; Calculate new size directly in register
    lea         edx, [rcx + rcx]            ; new frameCount = old * 2
    mov         rdi, [r8 + 24]              ; current sprite.frames pointer
    mov         rsi, rdx
    shl         rsi, 4

    ; Preserve values we need after realloc in callee-saved registers
    mov         r10, r8                     ; sprite pointer
    mov         r11d, ecx                   ; old frameCount
    mov         r12d, edx                   ; new frameCount
    call        realloc

    ; Update sprite.frames pointer
    mov         [r10 + 24], rax

    ; Setup pointers using lea for efficiency
    mov         r8, rax                     ; source = base
    lea         r9, [rax + r11 * 8]
    lea         r9, [r9 + r11 * 8]

    ; Prepare flip mask once in xmm1 (flip width only)
    mov         eax, MASK_FLIP              ;
    movd        xmm1, eax
    pslldq      xmm1, 8

    ; Use remaining count directly in r11d
    test        r11d, r11d
    jz          .update_count

    ; Check for unroll opportunity
    cmp         r11d, 4
    jl          .process_single

.process_batch:
    ; Process 4 rectangles at once when count >= 4
    sub         r11d, 4

    ; Load and flip 4 rectangles in parallel
    movaps      xmm0, [r8]                 ; rect 0
    movaps      xmm2, [r8 + 16]            ; rect 1
    movaps      xmm4, [r8 + 32]            ; rect 2
    movaps      xmm6, [r8 + 48]            ; rect 3

    ; Apply horizontal flip (negate width)
    xorps       xmm0, xmm1
    xorps       xmm2, xmm1
    xorps       xmm4, xmm1
    xorps       xmm6, xmm1

    ; Store flipped rectangles
    movaps      [r9], xmm0
    movaps      [r9 + 16], xmm2
    movaps      [r9 + 32], xmm4
    movaps      [r9 + 48], xmm6

    ; Advance pointers by 64 bytes (4 * 16)
    add         r8, 64
    add         r9, 64

    ; Continue if we have 4+ rectangles left
    cmp         r11d, 4
    jge         .process_batch

.process_single:
    ; Handle remaining rectangles (0-3)
    test        r11d, r11d
    jz          .update_count

    movaps      xmm0, [r8]                 ; load rectangle
    xorps       xmm0, xmm1                 ; flip width
    movaps      [r9], xmm0                 ; store flipped

    add         r8, 16                      ; next source
    add         r9, 16                      ; next dest
    dec         r11d
    jnz         .process_single

.update_count:
    mov         [r10 + 32], r12d            ; update frameCount
    ret


