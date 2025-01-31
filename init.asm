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

