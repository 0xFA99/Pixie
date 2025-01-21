section '.text' executable

public HandleInput

HandleInput:
    call CameraInput
    call PlayerInput

    ret

CameraInput:
    movss xmm1, [cameraZoomLevel]

    CheckCameraZoomIn:
        mov edi, 90
        call IsKeyDown
        test al, al
        je CheckCameraZoomOut

        movss xmm0, [camera.zoom]
        addss xmm0, xmm1

        movss xmm2, [cameraZoomMax]
        comiss xmm0, xmm2
        jbe ApplyCameraZoomIn

        movss xmm0, xmm2

        ApplyCameraZoomIn:
            movss [camera.zoom], xmm0
            jmp PlayerInput

    CheckCameraZoomOut:
        mov rdi, 88
        call IsKeyDown
        test al, al
        je PlayerInput

        movss xmm0, [camera.zoom]
        subss xmm0, xmm1

        movss xmm2, [cameraZoomMin]
        comiss xmm0, xmm2
        jae ApplyCameraZoomOut

        movss xmm0, xmm2

        ApplyCameraZoomOut:
            movss [camera.zoom], xmm0

            ret

PlayerInput:
    movss xmm1, [player.speed]

    PlayerMoveUp:
        mov edi, 265
        call IsKeyDown
        test al, al
        je PlayerMoveDown

        movss xmm0, [player.position.y]
        subss xmm0, xmm1
        movss [player.position.y], xmm0

    PlayerMoveDown:
        mov edi, 264
        call IsKeyDown
        test al, al
        je PlayerMoveLeft

        movss xmm0, [player.position.y]
        addss xmm0, xmm1
        movss [player.position.y], xmm0

    PlayerMoveLeft:
        mov edi, 263
        call IsKeyDown
        test al, al
        je PlayerMoveRight

        movss xmm0, [player.position.x]
        subss xmm0, xmm1
        movss [player.position.x], xmm0

    PlayerMoveRight:
        mov edi, 262
        call IsKeyDown
        test al, al
        ret

        movss xmm0, [player.position.x]
        addss xmm0, xmm1
        movss [player.position.x], xmm0

    ret

