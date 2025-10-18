
format ELF64

include 'include/consts.inc'

extrn LoadTexture

extrn malloc
extrn realloc

section '.text' executable

; rdi     -> sprite entity
; rsi     -> texture
; edx     -> rows
; ecx     -> columns
public _loadSpriteSheet
_loadSpriteSheet:
    push        rbx
    push        r12
    push        r13
    push        r14
    push        r15

    ; backup arguments
    mov         r15, rdi                    ; sprite
    mov         r14d, edx                   ; rows
    mov         r13d, ecx                   ; columns

    ; load texture, nukes registers on return :)
    call        LoadTexture

    ; sprite.frameCount = rows * columns
    mov         eax, r14d                   ; rows
    imul        eax, r13d                   ; columns
    mov         ecx, eax                    ; sprite.frameCount (backup)
    mov         [r15 + 28], eax             ; sprite.frameCount

    mov         rbx, [r15 + 4]              ; texture {width, height}

    ; frame.width = texture.width / columns
    xor         rdx, rdx
    mov         eax, ebx                    ; texture.width
    idiv        r13d                        ; columns
    mov         r12d, eax                   ; frame.width

    ; frame.height = texture.height / rows
    xor         rdx, rdx
    mov         rax, rbx                    ; texture.height
    shr         rax, 32
    idiv        r14d                        ; rows
    mov         ebx, eax                    ; frame.height

    ; allocation memory for all frames
    mov         rdi, rcx                    ; sprite.frameCount
    sal         rdi, 4                      ; sizeof Rectangle (16)
    call        malloc
    mov         [r15 + 20], rax             ; sprite.frames*
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
    pop         r15
    pop         r14
    pop         r13
    pop         r12
    pop         rbx
    ret



; rdi     -> sprite entity
public _addFlipSheet
_addFlipSheet:
    push        rbx
    push        r12
    push        r13
    push        r14
    push        r15

    mov         r15, rdi                    ; sprite
    mov         r14d, [r15 + 28]            ; old frameCount

    ; new frameCount = old frameCount * 2
    lea         r13d, [r14d * 2]            ; new frameCount

    mov         rdi, [r15 + 20]             ; entity.sprites (base address)

    ; expand the sprite sheet
    mov         rsi, r13                    ; new frameCount
    shl         rsi, 4                      ; sizeof Rectangle (16)
    call        realloc
    mov         [r15 + 20], rax             ; update sprite.sheet

    ; prepare source - destination pointers
    mov         rbx, rax                    ; entity.sprites (base address)

    mov         r12d, r14d                  ; old frameCount
    shl         r12, 4                      ; sizeof Rectangle (16)
    lea         r12, [rbx + r12]            ; base address + old frameCount

    ; prepare flip mask in xmm1 for horizontal flipping
    mov         eax, MASK_NEG               ; 0x80000000
    movd        xmm1, eax                   ; xmm1 = {-0.0, 0.0, 0.0, 0.0}
    pslldq      xmm1, 8                     ; xmm1 = {0.0, 0.0, -0.0, 0.0}

.loop:
    ; load rectangle from source
    movaps      xmm0, [rbx]                 ; xmm0 = {x, y, width, height}

    ; apply horizontal flip by negating width
    xorps       xmm0, xmm1                  ; xmm0 = {x, y, -width, height}

    ; store flipped rectangle into destination
    movaps      [r12], xmm0

    ; advance to next rectangle in source & destination
    lea         rbx, [rbx + 16]             ; next source
    lea         r12, [r12 + 16]             ; next destination

    dec         r14d                        ; index--
    jnz         .loop

    mov         [r15 + 28], r13d            ; update frameCount

    pop         r15
    pop         r14
    pop         r13
    pop         r12
    pop         rbx
    ret



; rdi   = entity
; si    = state
; dx    = direction
; ecx   = start
; r8d   = end
; xmm0  = frameTime
public _addSpriteAnimation
_addSpriteAnimation:
    push        r12
    push        r13

    mov         r12, rdi                    ; entity ptr
    mov         eax, [r12 + 416]            ; animationStateCount
    cmp         eax, ANIMATION_STATES_CAP
    jae         .done

    ; calculate offset for animationStates[count]
    mov         r13d, eax                   ; parallax.count
    shl         r13, 4                      ; sizeof AnimState (16)
    lea         r13, [r12 + r13 + 32]       ; base + index + 32

    ; set animation data
    mov         [r13], ecx                  ; start
    mov         [r13 + 4], r8d              ; end
    movss       [r13 + 8], xmm0             ; frameRate
    mov         [r13 + 12], si              ; state
    mov         [r13 + 14], dx              ; direction

    ; check lookup bounds
    cmp         si, ANIMATION_LOOKUP_CAP
    jge         .skipLookup

    ; calc lookup index
    cmp         dx, DIRECTION_RIGHT
    sete        al
    movzx       eax, al                     ; col = direction
    movzx       r8d, si                     ; row = state
    lea         r8, [rax + r8*2]            ; col + row * nCol
    mov         [r12 + r8*8 + 288], r13     ; base + offset + r8 * 8

.skipLookup:
    inc         dword [r12 + 416]           ; count++

.done:
    pop         r13
    pop         r12
    ret



; rdi   = player
; si    = state
; dx    = direction
public _setSpriteAnimation
_setSpriteAnimation:
    push        r12
    push        r13
    push        r14

    cmp         si, ANIMATION_LOOKUP_CAP
    jge         .done

    mov         r12, rdi                    ; player
    mov         r13, [r12]                  ; player->entity

    cmp         dx, DIRECTION_RIGHT
    sete        al
    movzx       eax, al                     ; col = direction
    movzx       r8d, si                     ; row = state
    lea         r8, [rax + r8*2]            ; col + row * nCol
    lea         r14, [r13 + r8*8 + 288]     ; base + offset + r8*8

    mov         r14, [r14]                  ; LOAD pointer from lookup table
    test        r14, r14                    ; test pointer content (not address)
    jz          .done

    mov         [r12 + 8], r14              ; store animation pointer to player

    mov         eax, [r14]                  ; get first frame (startFrame)
    mov         [r12 + 56], eax             ; store currentFrame
    mov         [r12 + 52], si              ; store state
    mov         [r12 + 54], dx              ; store direction

.done:
    pop         r14
    pop         r13
    pop         r12
    ret



section '.note.GNU-stack'

