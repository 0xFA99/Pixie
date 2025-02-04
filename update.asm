_UpdateCamera:
    movsd xmm0, [playerPosition]

    mov rax, [spriteSheet.frames]
    movsd xmm1, [rax + 8]

    mov eax, 0x40000000
    movd xmm2, eax
    shufps xmm2, xmm2, 0
    divps xmm1, xmm2

    addps xmm0, xmm1

    movsd [camera2D.target], xmm0

.cameraZoom:
    call GetMouseWheelMove
    movss xmm1, [cameraZoomLevel]
    mulss xmm1, xmm0
    movss xmm0, [camera2D.zoom]
    addss xmm0, xmm1
    movss [camera2D.zoom], xmm0

.cameraZoomMax:
    mov eax, 0x40400000               ; 3.0
    movd xmm1, eax
    movss xmm0, [camera2D.zoom]
    comiss xmm0, xmm1
    jbe .cameraZoomMin

    movss [camera2D.zoom], xmm1

.cameraZoomMin:
    mov eax, 0xBDCCCCCD             ; 0.1
    movd xmm0, eax
    movss xmm1, [camera2D.zoom]
    comiss xmm0, xmm1
    jb _render

    movss [camera2D.zoom], xmm0

