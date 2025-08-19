format ELF64

include 'macros.inc'
include 'header.inc'
include 'struct.inc'

section '.text' executable
public _start

include 'init.asm'
include 'sprite.asm'
include 'animations.asm'
include 'input.asm'
include 'update.asm'
include 'render.asm'

_start:
    mov         edi, 800                    ; Width
    mov         esi, 450                    ; Height
    mov         edx, title
    call        InitWindow

    callWith    camera, _initCamera
    callWith    player, _initPlayer

    ; Player - Load SpriteSheet
    mov         rdi, [player]               ; player->entity
    mov         rsi, player_texture         ; texture
    mov         edx, 17                     ; rows
    mov         ecx, 6                      ; columns
    call        _loadSpriteSheet

    callWith    [player], _addFlipSheet

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

    ; Set Player animation
    setAnimation player, STATE_RUN, DIRECTION_LEFT

    ; Set 60 as target FPS
    callWith    60, SetTargetFPS

.gameLoop:
    ; Check if window closed
    call        WindowShouldClose
    test        al, al
    jnz         .gameEnd

    ; get delta time
    call        GetFrameTime
    movss       [frameTime], xmm0

    movss       xmm0, [frameTime]
    callWith    player, _inputPlayer

    movss       xmm0, [frameTime]
    callWith    player, _updatePlayer

    ; callWith camera, _inputCamera

    ; mov rsi, player
    ; callWith camera, _updateCamera

    call        BeginDrawing
    callWith    0xFF181818, ClearBackground

    sub         rsp, 32                     ; 24 camera struct + 8 padding
    movaps      xmm0, [camera]              ; camera {offset(x, y), target(x, y)}
    movaps      xmm1, [camera + 16]         ; camera {rot, zoom, trash, trash}
    movaps      [rsp], xmm0
    movaps      [rsp + 16], xmm1
    call        BeginMode2D
    add         rsp, 32

    callWith    player, _renderPlayer

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

section '.rodata'
camZoomLevel    dd 0x3d4ccccd               ;  0.05
camZoomMin      dd 0x3f000000               ;  0.50
camZoomMax      dd 0x40400000               ;  3.00

title           db "Pixie", 0x0

addAsset        player_texture, "character/warrior.png"

section '.note.GNU-stack'

