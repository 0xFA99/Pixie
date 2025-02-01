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

    ; Init Player Position
    call GetScreenWidth
    sar eax, 1
    cvtsi2ss xmm0, eax
    movss [playerPosition], xmm0

    call GetScreenHeight
    sar eax, 1
    cvtsi2ss xmm0, eax
    movss [playerPosition + 4], xmm0

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

