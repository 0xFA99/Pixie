_renderPlayer:
    push rbp
    mov rbp, rsp

    mov r12, rdi                    ; Player*
    mov r13, [rdi]                  ; Player->entity

    ; Setup texture
    sub rsp, 32                     ; 20 bytes texture + 12 bytes padding
    movaps xmm0, [r13]              ; texture { id, width, height, mipmaps }
    movaps [rsp], xmm0
    mov eax, [r13 + 16]             ; texture.format
    mov [rsp + 16], eax

    ; reference of currentFrame
    mov rdi, [r13 + 20]
    mov eax, [r12 + 8]              ; player.currentFrame
    sal rax, 4
    add rdi, rax

    ; rectangle frame
    movq xmm0, [rdi]
    movq xmm1, [rdi + 8]

    ; player coordinate
    movsd xmm2, [r12 + 16]          ; player.position
    movsd xmm3, [rdi + 8]           ; texture.width
    subps xmm2, xmm2                ; position - width

    ; size of frame
    movq xmm3, [rdi + 8]

    ; if frame.width is negative
    pxor xmm4, xmm4
    comiss xmm2, xmm4
    jnb .skipFlip

    ; change to positive
    pxor xmm2, xmm4

.skipFlip:
    ; Offset
    pxor xmm4, xmm4

    ; Rotation
    pxor xmm5, xmm5

    ; Color 
    mov edi, -1
    call DrawTexturePro
    add rsp, 32

    pop rbp
    ret

