format ELF64

include 'include/consts.inc'
include 'include/macros.inc'

extrn InitWindow
extrn CloseWindow
extrn SetTargetFPS
extrn WindowShouldClose
extrn BeginDrawing
extrn EndDrawing
extrn ClearBackground
extrn GetFrameTime

extrn _loadSpriteSheet
extrn _addFlipSheet
extrn _initCamera
extrn _updateCamera
extrn _initPlayer
extrn _inputPlayer
extrn _updatePlayer
extrn _renderPlayer
extrn _updateParallax
extrn _renderParallax

section '.text' executable

public _start
_start:
    ; Initialize Raylib
    mov         edi, [screenWidth]
    mov         esi, [screenHeight]
    lea         rdx, [title]
    call        InitWindow

    lea         rdi, [player]
    call        _initPlayer

    mov         rdi, [player]
    mov         rsi, player_texture
    mov         rdx, 17
    mov         rcx, 6
    call        _loadSpriteSheet

    mov         rdi, [player]
    call        _addFlipSheet

    lea         rdi, [camera]
    call        _initCamera

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


    ; Set player animation
    setSpriteAnimation player, STATE_IDLE, DIRECTION_RIGHT

    ; [INFO] Parallax
    ; @params: parallax*, file*, posX, posY, speed
    addParallax parallax, parallax_background,      -200.0,     0.02
    addParallax parallax, parallax_cloud_1,         -200.0,     0.03
    addParallax parallax, parallax_cloud_2,         -200.0,     0.04
    addParallax parallax, parallax_cloud_3,         -200.0,     0.05
    addParallax parallax, parallax_props_clouds,    -200.0,     0.06
    addParallax parallax, parallax_back_forest_1,   -200.0,     0.10
    addParallax parallax, parallax_back_forest_2,   -200.0,     0.15
    addParallax parallax, parallax_back_tree_1,     -200.0,     0.25
    addParallax parallax, parallax_back_tree_2,     -200.0,     0.35



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

    movss       xmm0, [frameTime]
    lea         rdi, [player]
    call        _inputPlayer

    movss       xmm0, [frameTime]
    lea         rdi, [player]
    call        _updatePlayer

    lea         rdi, [camera]
    lea         rsi, [player]
    call        _updateCamera

    lea         rdi, [parallax]
    movss       xmm0, dword [player + 24]
    movss       xmm1, dword [player + 16]
    movss       xmm2, [frameTime]
    call        _updateParallax

    call        BeginDrawing

    mov         rdi, 0xFF181818
    call        ClearBackground

    startScissorMode

    lea         rdi, [camera]
    startCamera rdi

    lea         rdi, [parallax]
    call        _renderParallax

    lea         rdi, [player]
    call        _renderPlayer

    endCamera
    endScissorMode

    call        EndDrawing
    jmp         .gameLoop

.gameEnd:
    call        CloseWindow
    mov         eax, 60
    xor         edi, edi
    syscall



public gravity
public targetZoom

section '.data' writeable
frameTime       dd 0x00000000               ;   0.0
gravity         dd 0x44750000               ; 980.0
targetZoom      dd 0x3fe66666

section '.bss' writeable align 16
align 16
player          rq 8                        ;  64
camera          rq 3                        ;  24
padding         rq 1
parallax        rq 65                       ; 520

section '.rodata'
camZoomLevel    dd 0x3d4ccccd               ;  0.05
camZoomMin      dd 0x3fe66666               ;  1.8
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

screenWidth     dd 800
screenHeight    dd 400
title           db "Pixie", 0x0

section '.note.GNU-stack'

