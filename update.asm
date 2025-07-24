; @param rdi: camera
; @param rsi: player
_updateCamera:

    movsd xmm0, [rsi + 8]
    movsd [rdi + 8], xmm0

    movss xmm0, [rdi + 20]

.checkMaxZoomLimit:
    movss xmm1, [cameraZoomMax]
    comiss xmm0, xmm1
    jbe .checkMinZoomLimit

    movss [rdi + 20], xmm1
    jmp .return

.checkMinZoomLimit:
    movss xmm1, [cameraZoomMin]
    comiss xmm0, xmm1
    jae .return

    movss [rdi + 20], xmm1

.return:
    ret
