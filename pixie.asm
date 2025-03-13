format ELF64

include 'header.inc'
include 'struct.inc'
include 'string.inc'

section '.text' executable

public _start
public _DEBUG

include 'init.asm'
include 'sprite.asm'
include 'animations.asm'
include 'render.asm'

_start:
    mov edi, 800
    mov esi, 450
    lea edx, [gameWindow.title]
    call InitWindow

    lea edi, [player]
    call _InitPlayer

    lea eax, [player]
    movss xmm0, [rax + 32]
    movss xmm1, [rax + 36]

    sub rsp, 48
    lea rdi, [warriorSheet]
    mov esi, 17                 ; rows
    mov edx, 6                  ; column
    call _LoadSpriteSheet

    lea rax, [player]
    mov rax, [rax]

    mov rdx, [rsp]
    mov rcx, [rsp + 8]
    mov [rax], rdx
    mov [rax + 8], rcx

    mov rdx, [rsp + 16]
    mov [rax + 16], rdx

    mov rdx, [rsp + 24]
    mov rcx, [rsp + 32]
    mov [rax + 24], rdx
    mov [rax + 32], rcx

    add rsp, 48

    lea rdi, [player]
    call _AddFlipSpriteSheet

_DEBUG:
    lea rdi, [player]
    mov esi, STATE_IDLE
    mov edx, DIRECTION_RIGHT
    mov ecx, 0
    mov r8d, 5
    mov r9d, 10
    call _AddAnimationState

    ; lea rdi, [player]
    ; mov esi, STATE_IDLE
    ; mov edx, DIRECTION_RIGHT
    ; call _SetPlayerAnimation

    mov edi, 60
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

