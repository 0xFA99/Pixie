; ============== PARAMETERS ==============
; rdi       = player*

_initPlayer:
    ; Save player address to r12
    mov r12, rdi

    ; Allocation SpriteEntity to player
    mov edi, 48
    call malloc
    mov [r12], rax

    ; Set player position
    mov dword [r12 + 16], 0.0       ; Position.x
    mov dword [r12 + 20], 300.0     ; Position.y

    ; Set player velocity
    movq [r12 + 24], xmm0

    ; Set -200.0 as default player acceleration
    ; Acceleration for jump
    mov dword [r12 + 32], -200.0

    ; Set 100.0 as default player speed
    ; Speed for run
    mov dword [r12 + 36], 100.0

    ; Initialize Animation State count
    mov rdi, [r12]
    mov dword [rdi + 40], 0

    ; Initialize frameDuration
    mov dword [rdi + 44], 0.0

    ret

; ============== PARAMETERS ==============
; rdi       = camera

_initCamera:
    ; Get Screen Width / 2
    call _getScreenWidth
    sar rax, 1
    cvtsi2ss xmm0, rax

    ; Get Screen Height / 2
    call _getScreenHeight
    sar rax, 1
    cvtsi2ss xmm1, rax

    ; Store into camera.offset
    movd [rdi], xmm0
    movd [rdi + 4], xmm1

    ; Store into camera.target
    movq xmm0, [rdi]
    movq [rdi + 8], xmm0

    ; Set camera rotation
    xorps xmm0, xmm0
    movd [rdi + 16], xmm0

    ; Set camera zoom
    mov dword [rdi + 20], 1.75

    ret

; ============== PARAMETERS ==============
; rdi       = paralax*
; rsi       = texture_file*
; edx       = position.x
; ecx       = position.y
; xmm0      = speed

_initParallax:
    push rbp
    mov rbp, rsp

    mov r12, rdi
    mov r13, rsi
    mov r14d, edx
    mov r15d, ecx

    ; Check if parallax.data is NULL
    mov rax, [r12]
    test rax, rax
    jnz .reAllocation

    ; Allocation new data
    ; 32 bytes (sizeof ParallaxData)
    mov edi, 32
    call malloc
    mov [r12], rax

    jmp .fillData

.reAllocation:
    mov rdi, [r12]          ; parallax*
    mov eax, [r12 + 8]      ; parallax.count
    inc eax
    imul eax, 32
    cdqe
    mov rsi, rax
    call realloc
    mov [r12], rax

.fillData:
    ; Get reference parallax.data[count]
    mov rdi, [r12]
    mov eax, [r12 + 8]
    imul eax, 32
    cdqe
    add rdi, rax

    ; Set speed
    movss [rdi + 28], xmm0
    
    ; Set position
    mov [rdi + 20], r14d
    mov [rdi + 24], r15d

    ; Load Texture
    mov rsi, r13
    call _loadTexture

    ; Increase parallax.count
    add dword [r12 + 8], 1

    pop rbp
    ret

