format ELF64

include 'header.inc'
include 'struct.inc'

section '.text' executable
public _start

_start:

include 'init.asm'

    mov edi, 60
    call SetTargetFPS

include 'sprite.asm'

_gameLoop:
    call WindowShouldClose
    test al, al
    jnz _gameEnd

include 'render.asm'

    jmp _gameLoop

_gameEnd:
	call _FreeSpriteSheetData
    call CloseWindow

    mov eax, 60
    mov edi, 0
    syscall

section '.data' writeable
gameWindow GameWindow
spriteSheet SpriteSheet

warriorSheet db "warrior.png"

section '.note.GNU-stack'
