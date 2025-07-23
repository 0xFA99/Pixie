format ELF64

include 'macros.inc'
include 'header.inc'
include 'struct.inc'

section '.text' executable
public _start

include 'init.asm'
include 'sprite.asm'
include 'render.asm'

_start:
    ; Init Window
    mov edi, 800    ; Width
    mov esi, 450    ; Height
    mov edx, title
    call InitWindow

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

    ; Setup framebuffer
    call BeginDrawing

    callWith 0xFF181818, ClearBackground

    callWith player, _renderPlayer

    ; End framebuffer
    call EndDrawing

    jmp .gameLoop

.gameEnd:
    call CloseWindow

    mov eax, 60
    xor edi, edi
    syscall

section '.data' writeable

section '.bss' writeable
player          Player

section '.rodata'
title db "Pixie", 0x0

addAsset player_texture, "character/warrior.png"

section '.note.GNU-stack'

