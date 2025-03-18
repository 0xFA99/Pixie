format ELF64

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
    mov edi, 800
    mov esi, 450
    lea edx, [gameWindow.title]
    call InitWindow

    lea edi, [player]
    call _InitPlayer

    lea edi, [camera]
    lea esi, [player]
    call _InitCamera

    sub rsp, 48
    lea rdi, [warriorSheet]
    mov esi, 17                 ; rows
    mov edx, 6                  ; column
    call _LoadSpriteSheet

    ; Dereference SpriteSheet
    lea rax, [player]
    mov rax, [rax]

    ; Get Return SpriteSheet
    ; SpriteSheet.texture
    mov rdx, [rsp]
    mov rcx, [rsp + 8]
    mov [rax], rdx
    mov [rax + 8], rcx
    mov rdx, [rsp + 16]
    mov [rax + 16], rdx

    ; SpriteSheet.frames
    ; SpriteSheet.frameCount
    mov rdx, [rsp + 20]
    mov rcx, [rsp + 28]
    mov [rax + 24], rdx
    mov [rax + 32], rcx

    add rsp, 48

    lea rdi, [player]
    call _AddFlipSpriteSheet

    ; Add Idle State
    lea rdi, [player]
    mov esi, STATE_IDLE
    mov edx, DIRECTION_RIGHT
    mov ecx, 0
    mov r8d, 5
    mov r9d, 10
    call _AddAnimationState

    lea rdi, [player]
    mov esi, STATE_IDLE
    mov edx, DIRECTION_LEFT
    mov ecx, 102
    mov r8d, 107
    mov r9d, 10
    call _AddAnimationState

    ; Add Run State
    lea rdi, [player]
    mov esi, STATE_RUN
    mov edx, DIRECTION_RIGHT
    mov ecx, 6
    mov r8d, 13
    mov r9d, 10
    call _AddAnimationState

    lea rdi, [player]
    mov esi, STATE_RUN
    mov edx, DIRECTION_LEFT
    mov ecx, 108
    mov r8d, 113
    mov r9d, 10
    call _AddAnimationState

    ; Add Jump State
    lea rdi, [player]
    mov esi, STATE_JUMP
    mov edx, DIRECTION_RIGHT
    mov ecx, 41
    mov r8d, 43
    mov r9d, 10
    call _AddAnimationState

    lea rdi, [player]
    mov esi, STATE_JUMP
    mov edx, DIRECTION_LEFT
    mov ecx, 143
    mov r8d, 145
    mov r9d, 10
    call _AddAnimationState

    ; Add Fall State
    lea rdi, [player]
    mov esi, STATE_FALL
    mov edx, DIRECTION_RIGHT
    mov ecx, 46
    mov r8d, 48
    mov r9d, 10
    call _AddAnimationState

    lea rdi, [player]
    mov esi, STATE_FALL
    mov edx, DIRECTION_LEFT
    mov ecx, 148
    mov r8d, 150
    mov r9d, 10
    call _AddAnimationState

    lea rdi, [player]
    mov esi, STATE_IDLE
    mov edx, DIRECTION_RIGHT
    call _SetPlayerAnimation

    mov edi, 60
    call SetTargetFPS

.gameLoop:
    call WindowShouldClose
    test al, al
    jnz .gameEnd

    lea rdi, [player]
    call GetFrameTime
    movss xmm1, [gravity]
    call _InputPlayer

    lea rdi, [player]
    call GetFrameTime
    call _UpdatePlayer

    lea rdi, [camera]
    lea rsi, [player]
    call _UpdateCamera

    call BeginDrawing

    mov edi, 0xFF181818
    call ClearBackground

    sub rsp, 16
    lea rax, [camera]
    mov rdx, [rax]
    mov rcx, [rax + 8]
    mov [rsp], rdx
    mov [rsp + 8], rcx
    mov rdx, [rax + 16]
    mov [rsp + 16], rdx
    call BeginMode2D
    add rsp, 16

    lea rdi, [player]
    call _RenderPlayer

    call EndMode2D
    call EndDrawing
    jmp .gameLoop

.gameEnd:
    call CloseWindow

    mov eax, 60
    xor edi, edi
    syscall

section '.data' writeable

gameWindow      GameWindow
player          Player
camera          Camera

section '.rodata'
cameraZoom      dd 0.05
gravity         dd 500.0
warriorSheet    db "warrior.png", 0x00
background_file db "cyberpunk_street_background.png", 0x0
midground_file  db "cyberpunk_street_midground.png", 0x0
foreground_file db "cyberpunk_street_foreground.png", 0x0

section '.note.GNU-stack'

