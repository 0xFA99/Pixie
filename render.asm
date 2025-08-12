public _renderPlayer
; @param rdi, player
_renderPlayer:
    push rbp
    mov rbp, rsp

    mov r12, rdi                    ; Player*
    mov r13, [rdi]                  ; Player->entity

    ; @param 1 - Texture - DrawTexturePro
    ; Setup texture
    sub rsp, 32                     ; 24 bytes texture + 8 bytes padding
    movaps xmm0, [r13]              ; texture { id, width, height, mipmaps }
    movaps [rsp], xmm0
    mov eax, [r13 + 16]             ; texture.format
    mov [rsp + 16], eax

    ; player.frames[player.currentFrame]
    mov rdi, [r13 + 24]             ; player.frames*
    mov eax, [r12 + 54]             ; player.currentFrame
    sal rax, 4                      ; sizeof rectangle (16)
    add rdi, rax                    ; base + currentFrame

    ; @param 2 - Source Rectangle - DrawTexturePro
    ; get data of current frame
    movsd xmm0, [rdi]              ; source.frame { x, y }
    movsd xmm1, [rdi + 8]          ; source.frame { width, height }

    ; @param 3 - Destination Rectangle - DrawTexturePro
    movsd xmm2, [r12 + 16]         ; player.position { x, y }
    movsd xmm3, xmm1               ; source.frame { width, height }

    ; @param 4 - Offset
    pxor xmm4, xmm4                 ; { 0.0, 0.0 }

    ; @param 5 - Rotation
    pxor xmm5, xmm5                 ; 0.0

    ; @param 6 - Color
    mov edi, 0xFFFFFFFF             ; white

    call DrawTexturePro
    add rsp, 32

    pop rbp
    ret

