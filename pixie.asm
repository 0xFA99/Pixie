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
    AddAnimationState player, STATE_IDLE, DIRECTION_RIGHT, 0, 5, 10
    AddAnimationState player, STATE_IDLE, DIRECTION_LEFT, 102, 107, 10

    ; Add Run State
    AddAnimationState player, STATE_RUN, DIRECTION_RIGHT, 6, 13, 10
    AddAnimationState player, STATE_RUN, DIRECTION_LEFT, 108, 115, 10

    ; Add Jump State
    AddAnimationState player, STATE_JUMP, DIRECTION_RIGHT, 41, 43, 10
    AddAnimationState player, STATE_JUMP, DIRECTION_LEFT, 143, 145, 10

    ; Add Fall State
    AddAnimationState player, STATE_FALL, DIRECTION_RIGHT, 46, 48, 10
    AddAnimationState player, STATE_FALL, DIRECTION_LEFT, 148, 150, 10

    lea rdi, [player]
    mov esi, STATE_IDLE
    mov edx, DIRECTION_RIGHT
    call _SetPlayerAnimation

    call _InitParallaxBackground

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

    call _UpdateParallax

    call BeginDrawing

    mov edi, 0xFF181818
    call ClearBackground

    call _RenderParallax

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
gameWindow          GameWindow
player              Player
camera              Camera
background          Texture
midground           Texture
foreground          Texture
backgroundScrolling dd 0.0
midgroundScrolling  dd 0.0
foregroundScrolling dd 0.0

section '.rodata'
cameraZoom          dd 0.05
gravity             dd 500.0
warriorSheet        db "assets/character/warrior.png", 0x00
background_file     db "assets/background/cyberpunk_street_background.png", 0x0
midground_file      db "assets/background/cyberpunk_street_midground.png", 0x0
foreground_file     db "assets/background/cyberpunk_street_foreground.png", 0x0

section '.note.GNU-stack'

