
format MS64 COFF

include 'include/macros.inc'
include 'include/consts.inc'

extrn InitWindow
extrn WindowShouldClose
extrn SetTargetFPS
extrn BeginMode2D
extrn EndMode2D
extrn BeginDrawing
extrn ClearBackground
extrn EndDrawing
extrn CloseWindow
extrn GetFrameTime

extrn _initCamera
extrn _updateCamera
extrn _loadSpriteSheet
extrn _addFlipSheet
extrn _initPlayer
extrn _inputPlayer
extrn _updatePlayer
extrn _renderPlayer
extrn _updateParallax
extrn _renderParallax

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
    lea         rdx, [player_texture]       ; texture
    mov         r8d, 17                     ; rows
    mov         r9d, 6                      ; columns
    call        _loadSpriteSheet

    mov         rcx, [player]               ; player->sprite
    call        _addFlipSheet

    ; @params: object, state, direction, start, end, speed
    ; Animation State (Idle)
    addSpriteAnimation [player], STATE_IDLE, DIRECTION_RIGHT, 0, 5, 9.0
    addSpriteAnimation [player], STATE_IDLE, DIRECTION_LEFT, 102, 107, 9.0

    ; Animation State (Run)
    addSpriteAnimation [player], STATE_RUN, DIRECTION_RIGHT, 6, 13, 12.0
    addSpriteAnimation [player], STATE_RUN, DIRECTION_LEFT, 108, 115, 12.0

    ; Animation State (Jump)
    addSpriteAnimation [player], STATE_JUMP, DIRECTION_RIGHT, 41, 43, 6.5
    addSpriteAnimation [player], STATE_JUMP, DIRECTION_LEFT, 143, 145, 6.5

    ; Animation State (Fall)
    addSpriteAnimation [player], STATE_FALL, DIRECTION_RIGHT, 46, 48, 6.5
    addSpriteAnimation [player], STATE_FALL, DIRECTION_LEFT, 148, 150, 6.5

    ; Animation State (Break)
    addSpriteAnimation [player], STATE_BREAK, DIRECTION_RIGHT, 76, 76, 8.0
    addSpriteAnimation [player], STATE_BREAK, DIRECTION_LEFT, 178, 178, 8.0

    setSpriteAnimation player, STATE_IDLE, DIRECTION_RIGHT

    ; @params: parallax*, file*, posY, speed
    addParallax parallax, parallax_background,      -200.0,     0.02
    addParallax parallax, parallax_cloud_1,         -200.0,     0.03
    addParallax parallax, parallax_cloud_2,         -200.0,     0.04
    addParallax parallax, parallax_cloud_3,         -200.0,     0.05
    addParallax parallax, parallax_props_clouds,    -200.0,     0.06
    addParallax parallax, parallax_back_forest_1,   -200.0,     0.10
    addParallax parallax, parallax_back_forest_2,   -200.0,     0.15
    addParallax parallax, parallax_back_tree_1,     -200.0,     0.25
    addParallax parallax, parallax_back_tree_2,     -200.0,     0.35

    mov         ecx, 60
    call        SetTargetFPS

.loop:
    call        WindowShouldClose
    test        al, al
    jnz         .gameEnd

    call        GetFrameTime
    movss       [frameTime], xmm0

    movss       xmm1, [frameTime]
    lea         rcx, [player]
    call        _updatePlayer

    lea         rcx, [camera]
    lea         rdx, [player]
    call        _updateCamera

    lea         rcx, [parallax]
    movss       xmm1, dword [player + 24]         ; velocity.x
    movss       xmm2, dword [player + 16]         ; position.x
    movss       xmm3, [frameTime]
    call        _updateParallax

    movss       xmm1, [frameTime]
    lea         rcx, [player]
    call        _inputPlayer

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

    lea         rcx, [parallax]
    call        _renderParallax

    lea         rcx, [player]               ; player*
    call        _renderPlayer

    call        EndMode2D

    call        EndDrawing
    jmp         .loop

.gameEnd:
    call        CloseWindow
    add         rsp, 40
    ret


public gravity

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

addAsset        player_texture, "character/warrior.png"
addAsset        parallax_background, "parallax/background.png"
addAsset        parallax_cloud_1, "parallax/Cloud_1.png"
addAsset        parallax_cloud_2, "parallax/Cloud_2.png"
addAsset        parallax_cloud_3, "parallax/Cloud_3.png"
addAsset        parallax_props_clouds, "parallax/props_clouds.png"
addAsset        parallax_back_forest_1, "parallax/Back_Forest_1.png"
addAsset        parallax_back_forest_2, "parallax/Back_Forest_2.png"
addAsset        parallax_back_tree_1, "parallax/Back_tree_1.png"
addAsset        parallax_back_tree_2, "parallax/Back_tree_2.png"

