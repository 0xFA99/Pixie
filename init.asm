    ; Init Window
    mov eax, 800
    cvtsi2ss xmm0, eax
    movss [gameWindow.width], xmm0

    mov eax, 450
    cvtsi2ss xmm0, eax
    movss [gameWindow.height], xmm0

    movss xmm0, [gameWindow.width]
    cvtss2si edi, xmm0

    movss xmm0, [gameWindow.height]
    cvtss2si esi, xmm0

    lea edx, [gameWindow.title]

    call InitWindow

    ; Init Player
    push rbp
    mov rbp, rsp
    sub rsp, 32

    call GetScreenWidth
    sar eax, 1
    cvtsi2ss xmm0, eax
    movss [rbp - 4], xmm0

    call GetScreenHeight
    sar eax, 1
    cvtsi2ss xmm0, eax
    movss [rbp - 8], xmm0

    pxor xmm0, xmm0
    movss [rbp - 12], xmm0
    movss [rbp - 16], xmm0

    mov eax, 0xC3480000     ; -200
    movd xmm0, eax
    movss [rbp - 20], xmm0

    mov eax, 0x42c80000     ; 100
    movd xmm0, eax
    movss [rbp - 24], xmm0

    mov rax, [player.movement]

    movss xmm0, [rbp - 4]
    movss [rax], xmm0
    movss xmm0, [rbp - 8]
    movss [rax - 4], xmm0

    movss xmm0, [rbp - 12]
    movss [rax - 8], xmm0
    movss xmm0, [rbp - 16]
    movss [rax - 12], xmm0

    movss xmm0, [rbp - 20]
    movss [rax - 16], xmm0

    movss xmm0, [rbp - 24]
    movss [rax - 20], xmm0

    add rsp, 32
    pop rbp

    ; Init Camera2D
    mov eax, 2
    cvtsi2ss xmm1, eax
    pxor xmm0, xmm0

    call GetScreenWidth
    cvtsi2ss xmm0, eax
    divss xmm0, xmm1
    movss [camera2D.offset.x], xmm0

    call GetScreenHeight
    cvtsi2ss xmm0, eax
    divss xmm0, xmm1
    movss [camera2D.offset.y], xmm0

    pxor xmm0, xmm0
    movsd [camera2D.target], xmm0

    movss [camera2D.rotation], xmm0

    mov eax, 1
    cvtsi2ss xmm0, eax
    movss [camera2D.zoom], xmm0

    ; Camera zoom level
    mov eax, 0x3D4CCCCD
    movd xmm0, eax
    movss [cameraZoomLevel], xmm0

