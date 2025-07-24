format ELF64

include 'macros.inc'
include 'header.inc'
include 'struct.inc'

section '.text' executable
public _start

include 'init.asm'
include 'sprite.asm'
include 'input.asm'
include 'update.asm'
include 'render.asm'

_start:
    ; Init Window
    mov edi, 800    ; Width
    mov esi, 450    ; Height
    mov edx, title
    call InitWindow

    callWith camera, _initCamera

    callWith player, _initPlayer

    ; Player - Load SpriteSheet
    mov rdi, [player]               ; player->entity
    mov rsi, player_texture         ; texture
    mov edx, 17                     ; rows
    mov ecx, 6                      ; columns
    call _loadSpriteSheet

    callWith [player], _addFlipSheet

    ; Set 60 as target FPS
    callWith 60, SetTargetFPS

.gameLoop:
    ; Check if window closed
    call WindowShouldClose
    test al, al
    jnz .gameEnd

    callWith camera, _inputCamera

    mov rsi, player
    callWith camera, _updateCamera

    ; Setup framebuffer
    call BeginDrawing

    callWith 0xFF181818, ClearBackground

    sub rsp, 32
    movups xmm0, [camera]
    movups xmm1, [camera + 16]
    movups [rsp], xmm0
    movups [rsp + 16], xmm1
    mov rdi, rsp
    call BeginMode2D
    add rsp, 32

    callWith player, _renderPlayer

    call EndMode2D

    ; End framebuffer
    call EndDrawing

    jmp .gameLoop

.gameEnd:
    call CloseWindow

    mov eax, 60
    xor edi, edi
    syscall

section '.data' writeable
gravity         dd 500.0

section '.bss' writeable
camera          Camera
player          Player

section '.rodata'
title db "Pixie", 0x0

cameraZoomLevel dd 0.05
cameraZoomMin   dd 0.5
cameraZoomMax   dd 3.0

addAsset player_texture, "character/warrior.png"

section '.note.GNU-stack'

