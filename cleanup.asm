; rdi = player*
_freePlayer:
    mov r12, rdi

    ; Clean spriteSheet.frames
    mov rdi, [r12]
    mov rdi, [rdi + 20]
    call free

    ; Clean animations
    mov rdi, [r12]
    mov rdi, [rdi + 32]
    call free

    ; Clean player entity
    mov rdi, [r12]
    call free

    ret

; rdi = Parallax*
_freeParallax:
    mov r12, rdi

    mov rdi, [r12]
    call free 

    mov dword [r12 + 8], 0

    ret
