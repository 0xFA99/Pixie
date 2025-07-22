format ELF64

include 'macros.inc'
include 'header.inc'

section '.text' executable
public _start

_start:
    ; Init Window
    mov edi, 800    ; Width
    mov esi, 450    ; Height
    mov edx, title
    call InitWindow

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

section '.rodata'
title db "Pixie", 0x0

section '.note.GNU-stack'

