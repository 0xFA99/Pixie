_inputCamera:
    call GetMouseWheelMove

    movss xmm1, [cameraZoomLevel]
    mulss xmm1, xmm0

    movss xmm0, [rdi + 20]
    addss xmm0, xmm1

    movd [rdi + 20], xmm0

    ret

