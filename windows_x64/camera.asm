format MS64 COFF

extrn GetScreenWidth
extrn GetScreenHeight

section '.text' code readable executable

; rcx = camera*
public _initCamera
_initCamera:
    push        rbx
    sub         rsp, 32                     ; shadow space

    mov         rbx, rcx                    ; camera*

    call        GetScreenWidth              ; screen width
    shr         rax, 1                      ; screen width / 2
    cvtsi2ss    xmm0, rax                   ; int to float

    call        GetScreenHeight             ; screen height
    shr         rax, 1                      ; screen height / 2
    cvtsi2ss    xmm1, rax                   ; int to float

    movss       [rbx], xmm0                 ; camera.offset.x
    movss       [rbx + 4], xmm1             ; camera.offset.y
    mov         dword [rbx + 20], 0x40000000; camera.zoom = 2.0

    add         rsp, 32
    pop         rbx
    ret

