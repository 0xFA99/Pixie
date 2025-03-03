format ELF64

include 'header.inc'
include 'struct.inc'
include 'string.inc'

section '.text' executable

public _start
public _DEBUG

include 'init.asm'
include 'sprite.asm'
include 'render.asm'

_start:
    mov edi, 800
    mov esi, 450
    lea edx, [gameWindow.title]
    call InitWindow

    lea rdi, [player]
    call _InitPlayer

_DEBUG:
    sub rsp, 48
    lea rdi, [warriorSheet]
    mov esi, 17                 ; rows
    mov edx, 6                  ; column
    call _LoadSpriteSheet
    mov rax, [rsp]
    mov rdx, [rsp + 8]
    mov [player], rax
    mov [player + 8], rdx
    mov rax, [rsp + 16]
    mov [player + 16], rax
    mov rax, [rsp + 24]
    mov rdx, [rsp + 32]
    mov [player + 24], rax
    mov [player + 32], rdx
    add rsp, 48

    lea rdi, [player]
    call _AddFlipSpriteSheet

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
player          Player
warriorSheet    db "warrior.png", 0x00

section '.note.GNU-stack'

