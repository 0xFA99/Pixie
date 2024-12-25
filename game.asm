format ELF64

include 'struct.inc'

section '.text' executable

extrn InitWindow
extrn WindowShouldClose
extrn CloseWindow
extrn SetTargetFPS
extrn BeginDrawing
extrn EndDrawing
extrn BeginMode2D
extrn EndMode2D
extrn ClearBackground
extrn IsKeyDown
extrn DrawRectangleRec

public _start

_start:
    ; Init Window
    mov eax, 800
    cvtsi2ss xmm0, eax
    movss [windowSize.x], xmm0

    mov eax, 450
    cvtsi2ss xmm0, eax
    movss [windowSize.y], xmm0

    movss xmm0, [windowSize.x]
    cvtss2si edi, xmm0

    movss xmm0, [windowSize.y]
    cvtss2si esi, xmm0
    mov edx, windowTitle
    call InitWindow

    mov edi, 60
    call SetTargetFPS

    ; Init Player
    mov eax, 400
    cvtsi2ss xmm0, eax
    movss DWORD [player.position.x], xmm0

    mov eax, 280
    cvtsi2ss xmm0, eax
    movss DWORD [player.position.y], xmm0

    mov eax, 2
    cvtsi2ss xmm0, eax
    movss DWORD [player.speed], xmm0

    mov BYTE [player.canJump], 0

    ; Init Player Rectangle
    movss [playerRect.x], xmm0
    movss [playerRect.y], xmm0

    mov eax, 40
    cvtsi2ss xmm0, eax
    movss [playerRect.width], xmm0
    movss [playerRect.height], xmm0

    ; Init Camera
    movss xmm0, [player.position.x]
    movss [camera.target.x], xmm0

    movss xmm0, [player.position.y]
    movss [camera.target.y], xmm0

    mov eax, 2
    cvtsi2ss xmm1, eax

    movss xmm0, [windowSize.x]
    divss xmm0, xmm1
    movss [camera.offset.x], xmm0

    movss xmm0, [windowSize.y]
    divss xmm0, xmm1
    movss [camera.offset.y], xmm0

    pxor xmm0, xmm0
    movss [camera.rotation], xmm0

    mov eax, 1
    cvtsi2ss xmm0, eax
    movss [camera.zoom], xmm0

_GameLoop:
    call WindowShouldClose
    test rax, rax
    jnz _GameEnd

    jmp _HandleInput

_Render:
    call BeginDrawing

    mov rdi, 0xFF181818
    call ClearBackground

    ; Camera
    sub rsp, 0x20
    mov rcx, rsp
    mov rax, [camera]
    mov rdx, [camera + 8]
    mov [rcx], rax
    mov [rcx + 8], rdx
    mov rax, [camera + 16]
    mov [rcx + 16], rax
    call BeginMode2D
    add rsp, 0x20

    ; Draw
    mov eax, 20
    cvtsi2ss xmm0, eax
    movss xmm1, [player.position.x]
    subss xmm1, xmm0
    movss [playerRect.x], xmm1

    mov eax, 40
    cvtsi2ss xmm0, eax
    movss xmm1, [player.position.y]
    subss xmm1, xmm0
    movss [playerRect.y], xmm1

    mov rax, [playerRect]
    movq xmm0, rax
    mov rax, [playerRect + 8]
    movq xmm1, rax
    mov edi, 0xFFFFFFFF
    call DrawRectangleRec

    call EndMode2D

    call EndDrawing 

    jmp _GameLoop

_GameEnd:
    call CloseWindow

    mov eax, 60
    mov edi, 0
    syscall

_HandleInput:
     _PlayerInput: 
         movss xmm1, [player.speed]

         _PlayerUp:
             mov edi, 265
             call IsKeyDown
             test al, al
             je _PlayerDown

             movss xmm0, [player.position.y]
             subss xmm0, xmm1
             movss [player.position.y], xmm0
      
         _PlayerDown:
             mov edi, 264
             call IsKeyDown
             test al, al
             je _PlayerLeft

             movss xmm0, [player.position.y]
             addss xmm0, xmm1
             movss [player.position.y], xmm0

         _PlayerLeft:
             mov edi, 263
             call IsKeyDown
             test al, al
             je _PlayerRight

             movss xmm0, [player.position.x]
             subss xmm0, xmm1
             movss [player.position.x], xmm0

         _PlayerRight:
             mov edi, 262
             call IsKeyDown
             test al, al
             je _Render

             movss xmm0, [player.position.x]
             addss xmm0, xmm1
             movss [player.position.x], xmm0

     jmp _Render

section '.data' writeable

windowSize Vector2
camera Camera2D
player Player
playerRect Rectangle

windowTitle: db "Pixie", 0x00

section '.note.GNU-stack'
