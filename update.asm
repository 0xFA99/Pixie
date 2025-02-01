    ; Update Camera
    movsd xmm0, [playerPosition]
    movsd [camera2D.target], xmm0

