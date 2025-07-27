; @param rdi, player
_initPlayer:
    mov r12, rdi

    mov edi, 56                     ; sizeof SpriteEntity
    call malloc
    mov [r12], rax                  ; player->entity

    mov qword [r12 + 8], 0.0        ; player.position { x, y }
    mov dword [r12 + 56], 0         ; player.currentFrame
    mov dword [r12 + 32], 1000.0    ; player.acceleration
    mov dword [r12 + 36], 1500.0    ; player.deceleration
    mov dword [r12 + 40], 400.0     ; player.topSpeed
    mov dword [r12 + 44], 400.0     ; player.jumpStrength
    mov byte [r12 + 60], 1          ; player.isGrounded

    mov rdi, [r12]
    mov dword [rdi + 48], 0         ; entity->animStateCount

    ret

; @param rdi, camera
_initCamera:
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

    mov dword [rdi + 16], 0.0       ; camera.rotation
    mov dword [rdi + 20], 1.75      ; camera.zoom

    ret

