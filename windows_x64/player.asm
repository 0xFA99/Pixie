format MS64 COFF

include 'consts.inc'

extrn malloc
extrn memset

extrn DrawTexturePro

section '.text' code readable executable

; rcx = player->entity
public _initPlayer
_initPlayer:
    push        rbx
    sub         rsp, 32                     ; shadow space

    mov         rbx, rcx                    ; rcx = &player (arg)

    mov         ecx, 424                    ; sizeof SpriteEntity
    call        malloc
    mov         [rbx], rax                  ; player->entity

    mov         rcx, rax                    ; player->entity
    xor         edx, edx                    ; 0 byte
    mov         r8d, 424                    ; 424 total bytes
    call        memset

    ; movement initialization
    mov         dword [rbx + 32], 1200.0    ; player.acceleration
    mov         dword [rbx + 36], 1800.0    ; player.deceleration
    mov         dword [rbx + 40], 450.0     ; player.topSpeed
    mov         dword [rbx + 44], 420.0     ; player.jumpForce
    mov         dword [rbx + 48], 300.0     ; player.breakThreshold
    mov         byte [rbx + 60], 1          ; player.isGrounded

    add         rsp, 32                     ; shadow space
    pop         rbx
    ret

public _renderPlayer
_renderPlayer:
    push        r12
    push        r13

    sub         rsp, 104

    mov         r12, rcx
    mov         r13, [rcx]

    movaps      xmm0, [r13]
    movaps      [rsp + 48], xmm0
    mov         eax, [r13 + 16]
    mov         [rsp + 60], eax

    mov         rdi, [r13 + 20]
    mov         eax, [r12 + 56]
    sal         rax, 4
    add         rdi, rax

    movaps      xmm0, [rdi]
    movaps      [rsp + 64], xmm0

    movsd       xmm0, [r12 + 16]            ; player.position {x, y}
    movsd       xmm1, [rsp + 72]            ; frame {width, height}
    movsd       [rsp + 88], xmm1

    movss       xmm2, xmm1                  ; frame.width

    mov         eax,  0x40000000            ; 2.0
    movd        xmm3, eax
    divss       xmm2, xmm3                  ; frame.width / 2.0

    mov         edx, MASK_ABS
    movd        xmm3, edx
    andps       xmm2, xmm3
    subss       xmm0, xmm2
    movsd       [rsp + 80], xmm0            ; player.position {x, y}

    mov         qword [rsp + 96], 0.0       ; offset {0.0, 0.0}

    mov         dword [rsp + 40], 0xFFFFFFFF    ; color - white
    mov         qword [rsp + 32], 0             ; rotation
    lea         r9, [rsp + 96]                  ; offset*
    lea         r8, [rsp + 80]                  ; rect dest*
    lea         rdx, [rsp + 64]                 ; rect source*
    lea         rcx, [rsp + 48]                 ; texture*
    call        DrawTexturePro

    add         rsp, 104

    pop         r13
    pop         r12
    ret

