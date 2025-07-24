; @param rdi, player
_initPlayer:
    mov r12, rdi

    mov edi, 48
    call malloc
    mov [r12], rax                  ; player->entity

    xor rax, rax
    mov [r12 + 8], rax              ; player.position { x, y }

    mov [r12 + 16], eax             ; player.currentFrame

    ret

; @param rdi, camera
_initCamera:
    mov r12, rdi

    ; ScreenWidth / 2
    call GetScreenWidth
    sar rax, 1
    cvtsi2ss xmm0, rax

    ; ScreenHeight / 2
    call GetScreenHeight
    sar rax, 1
    cvtsi2ss xmm1, rax

    ; Setup camera.offset
    movd [rdi], xmm0
    movd [rdi + 4], xmm1

    ; Set camera.rotation
    mov dword [rdi + 16], 0.0
    
    ; Set camera.zoom
    mov dword [rdi + 20], 1.75

    ret
