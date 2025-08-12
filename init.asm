; @param rdi, player
_initPlayer:
    mov         r12, rdi

    mov         edi, 50                     ; sizeof SpriteEntity
    call        malloc
    mov         [r12], rax                  ; player->entity

    mov         dword [r12 + 32], 1000.0    ; player.acceleration
    mov         dword [r12 + 36], 1500.0    ; player.deceleration
    mov         dword [r12 + 40], 400.0     ; player.topSpeed
    mov         dword [r12 + 44], 400.0     ; player.jumpForce
    mov         dword [r12 + 48], 300.0     ; player.breakThreshold
    mov         byte [r12 + 68], 1          ; player.isGrounded

    mov         rdi, [r12]                  ; player->entity
    mov         dword [rdi + 42], 0         ; entity->animStateCount
    ret

; @param rdi, camera
_initCamera:
    ; ScreenWidth / 2
    call        GetScreenWidth
    sar         rax, 1
    cvtsi2ss    xmm0, rax

    ; ScreenHeight / 2
    call        GetScreenHeight
    sar         rax, 1
    cvtsi2ss    xmm1, rax

    ; Setup camera.offset
    movd        [rdi], xmm0                 ; camera.offset.x
    movd        [rdi + 4], xmm1             ; camera.offset.y

    ; Setup camera.target
    mov         qword [rdi + 12], 0.0       ; camera.target {x, y}

    mov         dword [rdi + 16], 0.0       ; camera.rotation
    mov         dword [rdi + 20], 1.75      ; camera.zoom
    ret

