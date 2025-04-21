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
    ; Init Window
    mov edi, 800    ; Width
    mov esi, 450    ; Height
    mov edx, title
    call _initWindow

    ; Init Camera
    callWith camera, _initCamera

    ; Init Player
    callWith player, _initPlayer

    ; Load SpriteSheet for player
    mov rdi, [player]
    mov rsi, player_file_texture
    mov edx, 17     ; rows
    mov ecx, 6      ; columns
    call _loadSpriteEntity

    ; Add flip texture for player
    callWith [player], _addFlipTexture

    ; Add AnimationState for player
    ; @params: object, state, direction, start, end, speed
    ; Animation State (Idle)
    addAnimationState [player], STATE_IDLE, DIRECTION_RIGHT, 0, 5, 10.0
    addAnimationState [player], STATE_IDLE, DIRECTION_LEFT, 102, 107, 10.0

    ; Animation State (Run)
    addAnimationState [player], STATE_RUN, DIRECTION_RIGHT, 6, 13, 10.0
    addAnimationState [player], STATE_RUN, DIRECTION_LEFT, 108, 115, 10.0

    ; Animation State (Jump)
    addAnimationState [player], STATE_JUMP, DIRECTION_RIGHT, 41, 43, 10.0
    addAnimationState [player], STATE_JUMP, DIRECTION_LEFT, 143, 145, 10.0

    ; Animation State (Fall)
    addAnimationState [player], STATE_FALL, DIRECTION_RIGHT, 46, 48, 10.0
    addAnimationState [player], STATE_FALL, DIRECTION_LEFT, 148, 150, 10.0

    ; Set Player animation
    setAnimationState player, STATE_IDLE, DIRECTION_RIGHT

    ; Init Parallax
    ; @params: parallax*, file*, posX, posY, speed
    addParallax parallax, parallax_layer1, 0,   0,    0.1
    addParallax parallax, parallax_layer2, 0,   25,   0.5
    addParallax parallax, parallax_layer3, 0,   65,   1.0

    ; Set 30 as target FPS
    callWith 30, _setTargetFPS

.gameLoop:
    ; Check if window closed
    call _windowShouldClose
    test al, al
    jnz .gameEnd

    ; Get frame time
    call _getFrameTime
    movd [frameTime], xmm0

    ; Input Event
    ; Handle Input Camera
    callWith camera, _inputCamera

    ; Handle Input Player
    mov rdi, player
    movd xmm0, [frameTime]
    movd xmm1, [gravity]
    call _inputPlayer

    ; DEBUG
    lea rdi, [debug_str]
    mov esi, [player + 40]
    call printf

    ; Update Player
    mov rdi, player
    movd xmm0, [frameTime]
    call _updatePlayer

    ; Update Event
    ; callWith camera, _updateCamera
    mov rdi, camera
    mov rsi, player
    call _updateCamera

    ; Setup framebuffer
    call _beginDrawing

    ; Set background color
    callWith 0xFF181818, _clearBackground

    ; Enter 2D Mode
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

    ; End 2D Mode
    call _endMode2D

    ; End framebuffer
    call _endDrawing

    jmp .gameLoop

.gameEnd:
    call _closeWindow

    ; Cleanup memory ( Good Habit :D )
    callWith player, _freePlayer
    callWith parallax, _freeParallax

    ; Call exit syscall
    mov eax, 60
    xor edi, edi
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

cameraZoomLevel     dd 0.05
cameraZoomMin       dd 0.5
cameraZoomMax       dd 3.0

player_file_texture db "assets/character/warrior.png", 0x0
parallax_layer1     db "assets/background/cyberpunk_street_background.png", 0x0
parallax_layer2     db "assets/background/cyberpunk_street_midground.png", 0x0
parallax_layer3     db "assets/background/cyberpunk_street_foreground.png", 0x0

debug_str           db "State: %d", 0xa, 0x0

section '.note.GNU-stack'

