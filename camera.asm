_initCamera:
    mov         rbx, rdi                    ; camera

    call        GetScreenWidth
    shr         rax, 1
    cvtsi2ss    xmm0, rax                   ; xmm0 = screenWidth / 2.0

    call        GetScreenHeight 
    shr         rax, 1
    cvtsi2ss    xmm1, rax                   ; xmm1 = screenHeight / 2.0

    movss       [rdi], xmm0
    movss       [rdi + 4], xmm1
    mov         dword [rdi + 20], 0x40000000
    ret

_updateCamera:
    mov         r12, rdi                    ; camera
    mov         r13, rsi                    ; player
    movss       xmm9, [r12 + 20]            ; camera.zoom
    
    mov         eax, 0x3dcccccd             ; 1.0
    movd        xmm8, eax
    
    mov         edi, KEY_Z
    call        IsKeyPressed
    test        al, al
    jz          .checkX

    addss       xmm9, xmm8                  ; camera.zoom += 1.0
    
.checkX:
    mov         edi, KEY_X 
    call        IsKeyPressed
    test        al, al
    jz          .checkC

    subss       xmm9, xmm8                  ; camera.zoom -= 1.0
    
.checkC:
    mov         edi, KEY_C
    call        IsKeyPressed
    test        al, al
    jz          .finish

    mov         eax, 0x40000000
    movd        xmm9, eax                   ; camera.zoom = 2.0
    
.finish:
    movss       [r12 + 20], xmm9            ; camera.zoom
    movsd       xmm0, [r13 + 16]            ; player.position {x, y}
    movsd       [r12 + 8], xmm0             ; camera.target {x, y}
    ret
