format ELF64

include 'macros.inc'
include 'struct.inc'
include 'header.inc'

section '.text' executable
public _start

include 'init.asm'
include 'sprite.asm'
include 'animations.asm'
include 'parallax.asm'
include 'input.asm'
include 'update.asm'
include 'render.asm'

_start:
    ; Initialize Raylib
    mov         rdi, 960
    mov         rsi, 540
    mov         rdx, title
    call        InitWindow

    mov         rdi, camera
    call        _initCamera

    mov         rdi, player
    call        _initPlayer

    mov         rdi, [player]
    mov         rsi, player_texture
    mov         rdx, 17
    mov         rcx, 6
    call        _loadSpriteSheet

    mov         rdi, [player]
    call        _addFlipSheet

    ; @params: object, state, direction, start, end, speed
    ; Animation State (Idle)
    addAnimation [player], STATE_IDLE, DIRECTION_RIGHT, 0, 5, 10.0
    addAnimation [player], STATE_IDLE, DIRECTION_LEFT, 102, 107, 10.0

    ; Animation State (Run)
    addAnimation [player], STATE_RUN, DIRECTION_RIGHT, 6, 13, 10.0
    addAnimation [player], STATE_RUN, DIRECTION_LEFT, 108, 115, 10.0

    ; Animation State (Jump)
    addAnimation [player], STATE_JUMP, DIRECTION_RIGHT, 41, 43, 10.0
    addAnimation [player], STATE_JUMP, DIRECTION_LEFT, 143, 145, 10.0

    ; Animation State (Fall)
    addAnimation [player], STATE_FALL, DIRECTION_RIGHT, 46, 48, 10.0
    addAnimation [player], STATE_FALL, DIRECTION_LEFT, 148, 150, 10.0

    ; Animation State (Break)
    addAnimation [player], STATE_BREAK, DIRECTION_RIGHT, 76, 76, 10.0
    addAnimation [player], STATE_BREAK, DIRECTION_LEFT, 178, 178, 10.0

    ; Set player animation
    setAnimation player, STATE_IDLE, DIRECTION_RIGHT

    ; Init Parallax
    ; @params: parallax*, file*, posX, posY, speed
    addParallax parallax, parallax_background,      0, -200, 0.1
    addParallax parallax, parallax_cloud_1,         0, -200, 0.1
    addParallax parallax, parallax_cloud_2,         0, -200, 0.1
    addParallax parallax, parallax_cloud_3,         0, -200, 0.1
    addParallax parallax, parallax_props_clouds,    0, -200, 0.1
    addParallax parallax, parallax_back_forest_1,   0, -200, 0.1
    addParallax parallax, parallax_back_forest_2,   0, -200, 0.1
    addParallax parallax, parallax_back_tree_1,     0, -200, 0.1
    addParallax parallax, parallax_back_tree_2,     0, -200, 0.1

    ; Set target FPS
    mov         rdi, 60
    call        SetTargetFPS

    jmp         .gameLoop

.gameLoop:
    call        WindowShouldClose
    test        al, al
    jnz         .gameEnd

    call        GetFrameTime
    movss       [frameTime], xmm0

    mov         rdi, player
    call        _inputPlayer

    movss       xmm0, [frameTime]
    mov         rdi, player
    call        _updatePlayer

    mov         rdi, camera
    call        _inputCamera

    mov         rdi, camera
    mov         rsi, player
    call        _updateCamera

    ; mov         rdi, parallax
    ; call        _inputParallax

    mov         rdi, [parallax]
    cvtss2sd    xmm0, [rdi + 20]
    mov         rdi, d
    mov         eax, 1
    call        printf

    call        BeginDrawing
    mov         rdi, 0xFF181818
    call        ClearBackground

    sub         rsp, 32                     ; 24 camera struct + 8 padding
    movaps      xmm0, [camera]              ; camera {offset(x, y), target(x, y)}
    movaps      xmm1, [camera + 16]         ; camera {rot, zoom, trash, trash}
    movaps      [rsp], xmm0
    movaps      [rsp + 16], xmm1
    call        BeginMode2D
    add         rsp, 32

    mov         rdi, parallax
    mov         eax, 1.0
    movd        xmm8, eax
    call        _renderParallax

    mov         rdi, player
    call        _renderPlayer

    call        EndMode2D

    call        EndDrawing
    jmp         .gameLoop

.gameEnd:
    call        CloseWindow
    mov         eax, 60
    xor         edi, edi
    syscall

section '.data' writeable
frameTime       dd 0x00000000               ;   0.0
gravity         dd 0x44750000               ; 980.0

section '.bss' writeable align 16
align 16
camera          Camera
player          Player
parallax        Parallax

section '.rodata'
camZoomLevel    dd 0x3d4ccccd               ;  0.05
camZoomMin      dd 0x3f000000               ;  0.50
camZoomMax      dd 0x40400000               ;  3.00

; Character Texture
addAsset        player_texture, "character/warrior.png"

; Parallax Texture
addAsset        parallax_background, "parallax/background.png"
addAsset        parallax_cloud_1, "parallax/Cloud_1.png"
addAsset        parallax_cloud_2, "parallax/Cloud_2.png"
addAsset        parallax_cloud_3, "parallax/Cloud_3.png"
addAsset        parallax_props_clouds, "parallax/props_clouds.png"
addAsset        parallax_back_forest_1, "parallax/Back_Forest_1.png"
addAsset        parallax_back_forest_2, "parallax/Back_Forest_2.png"
addAsset        parallax_back_tree_1, "parallax/Back_tree_1.png"
addAsset        parallax_back_tree_2, "parallax/Back_tree_2.png"

title           db "Pixie", 0x0

d               db "%f", 0xa, 0x0

section '.note.GNU-stack'

