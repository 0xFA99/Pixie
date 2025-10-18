format MS64 COFF

include 'include/consts.inc'

extrn malloc
extrn realloc
extrn LoadTexture

section '.text' code readable executable

; rcx -> spriteSheet
; rdx -> texture
; r8d -> rows
; r9d -> columns
public _loadSpriteSheet
_loadSpriteSheet:
    push        rbx
    push        rdi
    push        r11
    push        r12
    push        r13
    push        r14
    push        r15
    sub         rsp, 32                     ; 32 shadow space

    mov         r15, rcx                    ; sprite
    mov         r14d, r8d                   ; rows
    mov         r13d, r9d                   ; columns
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
    sal         rcx, 4                      ; sizeof Rectangle(16)
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

    xor         r9d, r9d                    ; index column = 0

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
    unpcklps    xmm0, xmm1
    unpcklps    xmm2, xmm3
    shufps      xmm0, xmm2, 01000100b

    mov         eax, ecx
    shl         rax, 4
    lea         rdi, [rbx + rax]

    movaps      [rdi], xmm0

    inc         ecx
    inc         r9d
    jmp         .loop_column

.next_row:
    inc         r8d
    jmp         .loop_row

.done:
    add         rsp, 32
    pop         r15
    pop         r14
    pop         r13
    pop         r12
    pop         r11
    pop         rdi
    pop         rbx
    ret


public _addFlipSheet
_addFlipSheet:
    push        rbx
    push        r12
    push        r13
    push        r14
    push        r15

    sub         rsp, 32

    mov         r15, rcx                    ; sprite
    mov         r14d, [r15 + 28]            ; old frameCount
    lea         r13d, [r14d * 2]            ; new frameCount

    mov         rcx, [r15 + 20]             ; sprite.frames*
    mov         rdx, r13                    ; new frameCount
    shl         rdx, 4                      ; sizeof Rectangle (16)
    call        realloc
    mov         [r15 + 20], rax             ; store back sprite.frames*

    mov         rbx, rax                    ; base address

    mov         r12d, r14d                  ; old frameCount
    shl         r12, 4                      ; sizeof Rectangle (16)
    lea         r12, [rbx + r12]            ; base address + old frameCount

    pxor        xmm1, xmm1

    mov         eax, MASK_NEG               ; 0x80000000
    movd        xmm1, eax                   ; xmm1 = {-0.0, 0.0, 0.0, 0.0}
    pslldq      xmm1, 8                     ; xmm1 = {0.0, 0.0, -0.0, 0.0}

.loop:
    movaps      xmm0, [rbx]                 ; xmm0 = {x, y, width, height}

    xorps       xmm0, xmm1                  ; xmm0 = {x, y, -width, height}

    movaps      [r12], xmm0                 ; store rect to destination

    lea         rbx, [rbx + 16]             ; next rect source
    lea         r12, [r12 + 16]             ; next rect destination

    dec         r14d                        ; index--
    jnz         .loop

    mov         [r15 + 28], r13d            ; update frameCount

    add         rsp, 32

    pop         r15
    pop         r14
    pop         r13
    pop         r12
    pop         rbx
    ret



; rcx           = entity
; dx            = state
; r8w           = direction
; r9d           = start
; [rsp + 32]    = end
; [rsp + 40]    = frameTime
public _addSpriteAnimation
_addSpriteAnimation:
    push        r12
    push        r13

    mov         r12, rcx                    ; entity
    mov         eax, [r12 + 416]            ; animationStateCount

    cmp         eax, ANIMATION_STATES_CAP
    jae         .done

    ; calculate offset for animationStates[count]
    mov         r13d, eax                   ; parallax.count
    shl         r13, 4                      ; sizeof AnimState (16)
    lea         r13, [r13 + r12 + 32]       ; base + index + 32

    ; set animation data
    mov         [r13], r9d                  ; start
    mov         eax, [rsp + 56]             ; end
    movss       xmm0, [rsp + 64]            ; frameTime
    mov         [r13 + 4], eax
    movss       [r13 + 8], xmm0
    mov         [r13 + 12], dx              ; state
    mov         [r13 + 14], r8w             ; direction

    cmp         dx, ANIMATION_LOOKUP_CAP
    jge         .skipLookup

    cmp         r8w, DIRECTION_RIGHT
    sete        al
    movzx       eax, al
    movzx       r8d, dx
    lea         r8, [rax + r8*2]
    mov         [r12 + r8*8 + 288], r13

.skipLookup:
    inc         dword [r12 + 416]           ; count++

.done:
    pop         r13
    pop         r12
    ret


; rcx = object
; dx = state
; r8w = direction
public _setSpriteAnimation
_setSpriteAnimation:
    push        rdi
    push        r12
    push        r13
    push        r14

    cmp         dx, ANIMATION_LOOKUP_CAP
    jge         .done

    mov         r12, rcx                    ; player
    mov         r13, [r12]                  ; player->entity

    cmp         r8w, DIRECTION_RIGHT
    sete        al
    movzx       eax, al
    movzx       edi, dx
    lea         rdi, [rax + rdi*2]
    lea         r14, [r13 + rdi*8 + 288]

    mov         r14, [r14]
    test        r14, r14
    jz          .done

    mov         [r12 + 8], r14

    mov         eax, [r14]
    mov         [r12 + 56], eax             ; current frame
    mov         [r12 + 52], dx              ; state
    mov         [r12 + 54], r8w              ; direction

.done:
    pop         r14
    pop         r13
    pop         r12
    pop         rdi
    ret

