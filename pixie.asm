format ELF64

include 'header.inc'
include 'struct.inc'
include 'string.inc'

section '.text' executable

public _start

include 'sprite.asm'
include 'render.asm'

_start:
    mov edi, 800
    mov esi, 450
    lea edx, [gameWindow.title]
    call InitWindow

    sub rsp, 48                 ; old rbp [8] + return struct SpriteSheet [40]

    lea rdi, [warriorSheet]
    mov esi, 17                 ; rows
    mov edx, 6                  ; column
    call _LoadSpriteSheet


    add rsp, 48

    call SetTargetFPS

_gameLoop:
    call WindowShouldClose
    test al, al
    jnz _gameEnd

    call _render

    jmp _gameLoop

_gameEnd:
    call CloseWindow

    mov eax, 60
    xor edi, edi
    syscall

section '.data' writeable

gameWindow      GameWindow
warriorSheet    db "warrior.png", 0x00

section '.note.GNU-stack'

