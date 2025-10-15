
format MS64 COFF

include 'macros.inc'
include 'consts.inc'

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
extrn _setSpriteAnimation
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

    ; @params: object, state, direction, start, end, speed
    ; Animation State (Idle)
    addSpriteAnimation [player], STATE_IDLE, DIRECTION_RIGHT, 0, 5, 12.0
    addSpriteAnimation [player], STATE_IDLE, DIRECTION_LEFT, 102, 107, 12.0

    ; Animation State (Run)
    addSpriteAnimation [player], STATE_RUN, DIRECTION_RIGHT, 6, 13, 15.0
    addSpriteAnimation [player], STATE_RUN, DIRECTION_LEFT, 108, 115, 15.0

    ; Animation State (Jump)
    addSpriteAnimation [player], STATE_JUMP, DIRECTION_RIGHT, 41, 43, 8.0
    addSpriteAnimation [player], STATE_JUMP, DIRECTION_LEFT, 143, 145, 8.0

    ; Animation State (Fall)
    addSpriteAnimation [player], STATE_FALL, DIRECTION_RIGHT, 46, 48, 8.0
    addSpriteAnimation [player], STATE_FALL, DIRECTION_LEFT, 148, 150, 8.0

    ; Animation State (Break)
    addSpriteAnimation [player], STATE_BREAK, DIRECTION_RIGHT, 76, 76, 10.0
    addSpriteAnimation [player], STATE_BREAK, DIRECTION_LEFT, 178, 178, 10.0

    setSpriteAnimation player, STATE_RUN, DIRECTION_RIGHT

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

