
format MS64 COFF

extrn InitWindow
extrn WindowShouldClose
extrn SetTargetFPS
extrn BeginMode2D
extrn EndMode2D
extrn BeginDrawing
extrn ClearBackground
extrn EndDrawing
extrn CloseWindow

extrn _initCamera
extrn _loadSpriteSheet
extrn _addFlipSheet
extrn _addSpriteAnimation
extrn _initPlayer
extrn _renderPlayer

section '.text' code readable executable
public main
main:
    sub         rsp, 40                     ; 8 padding + 32 shadow space

    mov         ecx, 800                    ; window width
    mov         edx, 450                    ; window height
    lea         r8, [g_title]               ; window title
    call        InitWindow

    lea         rcx, [camera]               ; camera*
    call        _initCamera

    lea         rcx, [player]               ; player*
    call        _initPlayer

    mov         rcx, [player]               ; player->sprite
    lea         rdx, [g_warrior]            ; texture
    mov         r8d, 17                     ; rows
    mov         r9d, 6                      ; columns
    call        _loadSpriteSheet

    mov         rcx, [player]               ; player->sprite
    call        _addFlipSheet

    ; sub         rsp, 16
    ; mov         rcx, [player]               ; player->sprite
    ; mov         dx, 10
    ; mov         r8w, 20
    ; mov         r9d, 30
    ; mov         dword [rsp + 32], 40
    ; mov         dword [rsp + 40], 50
    ; call        _addSpriteAnimation
    ; add         rsp, 16

    mov         ecx, 60
    call        SetTargetFPS

.loop:
    call        WindowShouldClose
    test        al, al
    jnz         .gameEnd

    call        BeginDrawing
    mov         ecx, 0xFF181818
    call        ClearBackground

    sub         rsp, 32                     ; 24 camera + 8 padding
    lea         rax, [camera]               ; camera base address
    movaps      xmm0, [rax]                 ; offset{x,y}, target{x,y}
    mov         rdx, [rax + 16]             ; rotation, zoom
    movaps      [rsp + 32], xmm0
    mov         [rsp + 48], rdx
    lea         rcx, [rsp + 32]
    call        BeginMode2D
    add         rsp, 32

    mov         dword [player + 56], 1      ; TEST...
    lea         rcx, [player]               ; player*
    call        _renderPlayer

    call        EndMode2D

    call        EndDrawing
    jmp         .loop

.gameEnd:
    call        CloseWindow
    add         rsp, 40
    ret

section '.data' data readable writeable
frameTime       dd 0x00000000
gravity         dd 0x44750000

section '.bss' data readable writeable align 16
align 16
player          rq 8
camera          rq 3
padding         rq 1
parallax        rq 65

section '.rdata' data readable
g_title         db "Pixie", 0x0
g_warrior       db "warrior.png", 0x0

