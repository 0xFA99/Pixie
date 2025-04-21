format ELF64

include 'header.inc'
include 'struct.inc'
include 'macros.inc'

section '.text' executable

public _start

include 'init.asm'
include 'sprite.asm'
include 'animations.asm'
include 'input.asm'
include 'update.asm'
include 'render.asm'
include 'cleanup.asm'

_start:
    ; Initialize Game Window
    mov edi, 800                    ; Window width
    mov esi, 450                    ; Window height
    mov edx, title                  ; Window title
    call _initWindow

    ; Initialize Camera
    callWith camera, _initCamera

    ; Initialize Player Object
    callWith player, _initPlayer

    ; Load Player Sprite Sheet
    mov rdi, [player]               ; Player entity pointer
    mov rsi, player_file_texture
    mov edx, 17                     ; Number of rows
    mov ecx, 6                      ; Number of columns
    call _loadSpriteEntity

    ; Add Flipped Texture ( for left-facing sprites )
    callWith [player], _addFlipTexture

    ; Define Player Animation States
    ; @params: entity, state, direction, startFrame, endFrame, speed

    ; Idle Animation
    addAnimationState [player], STATE_IDLE, DIRECTION_RIGHT, 0, 5, 10.0
    addAnimationState [player], STATE_IDLE, DIRECTION_LEFT, 102, 107, 10.0

    ; Run Animation
    addAnimationState [player], STATE_RUN, DIRECTION_RIGHT, 6, 13, 10.0
    addAnimationState [player], STATE_RUN, DIRECTION_LEFT, 108, 115, 10.0

    ; Jump Animation
    addAnimationState [player], STATE_JUMP, DIRECTION_RIGHT, 41, 43, 10.0
    addAnimationState [player], STATE_JUMP, DIRECTION_LEFT, 143, 145, 10.0

    ; Fall Animation
    addAnimationState [player], STATE_FALL, DIRECTION_RIGHT, 46, 48, 10.0
    addAnimationState [player], STATE_FALL, DIRECTION_LEFT, 148, 150, 10.0

    ; Set Initial Animation State (Idle Right)
    setAnimationState player, STATE_IDLE, DIRECTION_LEFT

    ; Setup Parallax Layers
    ; @params: parallax*, file*, x, y, scroll_speed
    addParallax parallax, parallax_layer1, 0,   0,    0.1
    addParallax parallax, parallax_layer2, 0,   25,   0.5
    addParallax parallax, parallax_layer3, 0,   65,   1.0

    ; Set Frame Rate (60 FPS)
    callWith 60, _setTargetFPS

.gameLoop:
    ; Check if window should close
    call _windowShouldClose
    test al, al
    jnz .gameEnd

    ; Get Frame Time (delta time)
    call _getFrameTime
    movd [frameTime], xmm0

    ; Handle Input Camera
    callWith camera, _inputCamera

    ; Handle Input Player
    mov rdi, player
    movd xmm0, [frameTime]
    movd xmm1, [gravity]
    call _inputPlayer

    ; Update Camera Logic
    mov rdi, camera
    mov rsi, player
    call _updateCamera

    ; Update Player Logic
    mov rdi, player
    movd xmm0, [frameTime]
    call _updatePlayer

    ; Begin Frame Rendering
    call _beginDrawing

    ; Set background color
    callWith 0xFF181818, _clearBackground

    ; Enter 2D Drawing Mode (with camera transform)
    ; 24 bytes Camera + 8 Padding
    sub rsp, 32
    movq xmm0, [camera]
    movq xmm1, [camera + 8]
    movq xmm2, [camera + 16]
    movd xmm3, [camera + 24]
    movq [rsp], xmm0
    movq [rsp + 8], xmm1
    movq [rsp + 16], xmm2
    movd [rsp + 24], xmm3
    call _beginMode2D
    add rsp, 32

    ; Render Parallax
    callWith parallax, _renderParallax

    ; Render Player
    callWith player, _renderPlayer

    ; End 2D Drawing Mode
    call _endMode2D

    ; Finish Drawing Frame
    call _endDrawing

    jmp .gameLoop

.gameEnd:
    call _closeWindow

    ; Clean up allocated resources( Good Habit :D )
    callWith player, _freePlayer
    callWith parallax, _freeParallax

    ; Exit Program
    mov eax, 60             ; syscall: exit
    xor edi, edi            ; status code: 0
    syscall

section '.data' writeable
frameTime           dd 0.0
gravity             dd 500.0

section '.bss' writeable
player              Player
camera              Camera
parallax            Parallax

section '.rodata'
title               db "Pixie", 0x0

player_file_texture db "assets/character/warrior.png", 0x0
parallax_layer1     db "assets/background/cyberpunk_street_background.png", 0x0
parallax_layer2     db "assets/background/cyberpunk_street_midground.png", 0x0
parallax_layer3     db "assets/background/cyberpunk_street_foreground.png", 0x0

cameraZoomLevel     dd 0.05
cameraZoomMin       dd 0.5
cameraZoomMax       dd 3.0

section '.note.GNU-stack'

