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
extrn LoadImage
extrn UnloadImage
extrn LoadTexture
extrn UnloadTexture
extrn DrawTexture

public _start

_start:
    ; Init Window
    mov eax, 800
    cvtsi2ss xmm0, eax
    movss [windowSize.x], xmm0

    mov eax, 600
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
    movss DWORD [player.position.x], xmm0   ; Player Position X

    mov eax, 280
    cvtsi2ss xmm0, eax
    movss DWORD [player.position.y], xmm0   ; Player Position Y

    pxor xmm0, xmm0
    movss DWORD [player.speed], xmm0        ; Player Speed

    mov BYTE [player.canJump], 0            ; Player Jump

    ; Init Player Rectangle
    movss xmm0, [player.position.x]
    mov eax, 20
    cvtsi2ss xmm1, eax
    subss xmm0, xmm1
    movss [playerRect.x], xmm0

    movss xmm0, [player.position.y]
    mov eax, 40
    cvtsi2ss xmm1, eax
    subss xmm0, xmm1
    movss [playerRect.y], xmm0

    movss [playerRect.width], xmm1
    movss [playerRect.height], xmm1

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

    ; Load Image
    ; lea rax, [image]
    ; lea rdx, [dogImage]
    ; mov rdi, rax
    ; mov rsi, rdx
    ; call LoadImage

    ; Init Texture
    ; lea rsi, [texture]
    ; sub rsp, 0x20
    ; mov rcx, rsp
    ; mov rax, [image]
    ; mov rdx, [image + 8]
    ; mov [rcx], rax
    ; mov [rcx + 8], rdx
    ; mov rax, [image + 16]
    ; mov [rcx + 16], rax
    ; mov rdi, rsi
    ; call UnloadImage
    ; add rsp, 0x20 

    ; Unload Image
    ; sub rsp, 0x20
    ; mov rcx, rsp
    ; mov rax, [image]
    ; mov rdx, [image + 8]
    ; mov [rcx], rax
    ; mov [rcx + 8], rdx
    ; mov rax, [image + 16]
    ; mov [rcx + 16], rax
    ; call UnloadImage
    ; add rsp, 0x20

_GameLoop:
    call WindowShouldClose
    test rax, rax
    jnz _GameEnd

    ; jmp _HandleInput

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

    ; movss xmm0, [playerRect.x]
    ; cvtss2si eax, xmm0
    ; mov edi, eax

    ; movss xmm0, [playerRect.y]
    ; cvtss2si eax, xmm0
    ; mov esi, eax
    ; mov edx, 50
    ; mov ecx, 50
    ; mov r8d, 0xFFFFFFFF
    ; call DrawRectangle

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

    ; sub rsp, 0x20
    ; mov rcx, rsp
    ; mov rax, [texture]
    ; mov rdx, [texture + 8]
    ; mov [rcx], rax
    ; mov [rcx + 8], rdx
    ; mov eax, [texture + 16]
    ; mov [rcx + 16], eax
    ; call UnloadTexture
    ; add rsp, 0x20

    call CloseWindow

    mov eax, 60
    mov edi, 0
    syscall

; _HandleInput:
; 
;     pxor xmm0, xmm0
;     pxor xmm1, xmm1
; 
;     _CameraInput: 
; 
;         _CameraZoomIn:
;             mov edi, 90 ; Key Z
;             call IsKeyDown
;             test al, al
;             je _CameraZoomOut
; 
;             movss xmm1, [cameraZoomLevel]
;             movss xmm0, [camera.zoom]
; 
;             addss xmm1, xmm0
; 
;             movss [camera.zoom], xmm1
; 
;         _CameraZoomOut:
;             mov edi, 88 ; Key X
;             call IsKeyDown
;             test al, al
;             je _PlayerInput
; 
;             movss xmm1, [cameraZoomLevel]
;             movss xmm0, [camera.zoom]
; 
;             subss xmm0, xmm1
; 
;             movss [camera.zoom], xmm0
;    
;     _PlayerInput: 
; 
;         movss xmm1, [player.speed]
; 
;         _PlayerUp:
;             mov edi, 265
;             call IsKeyDown
;             test al, al
;             je _PlayerDown
; 
;             movss xmm0, [player.position.y]
;             subss xmm0, xmm1
;             movss [player.position.y], xmm0
; 
;             jmp _CheckCollusion
;      
;         _PlayerDown:
;             mov edi, 264
;             call IsKeyDown
;             test al, al
;             je _PlayerLeft
; 
;             movss xmm0, [player.position.y]
;             addss xmm0, xmm1
;             movss [player.position.y], xmm0
; 
;             jmp _CheckCollusion
; 
;         _PlayerLeft:
;             mov edi, 263
;             call IsKeyDown
;             test al, al
;             je _PlayerRight
; 
;             movss xmm0, [player.position.x]
;             subss xmm0, xmm1
;             movss [player.position.x], xmm0
; 
;             jmp _CheckCollusion
; 
;         _PlayerRight:
;             mov edi, 262
;             call IsKeyDown
;             test al, al
;             je _CheckCollusion
; 
;             movss xmm0, [player.position.x]
;             addss xmm0, xmm1
;             movss [player.position.x], xmm0
; 
; _CheckCollusion:
; 
;     pxor xmm0, xmm0
; 
;     _BorderLeft:
;         movss xmm1, [player.position.x]
;         comiss xmm0, xmm1
;         jbe _BorderTop
;         
;         movss [player.position.x], xmm0
;     
;     _BorderTop:
;         movss xmm1, [player.position.y]
;         comiss xmm0, xmm1
;         jbe _Render
; 
;         movss [player.position.y], xmm0
;    
;     _BorderRight:
;         movss xmm0, [player.position.x]
;         movss xmm1, []
;         movss xmm1, [windowSize.x]
;         comiss xmm0, xmm1
;         jge _Render
; 
;     _BorderDown:
;         movss xmm0
;         jmp _Render

section '.data' writeable

windowSize Vector2
camera Camera2D
player Player
playerRect Rectangle
image Image
texture Texture2D

cameraZoomLevel: dd 0.2
windowTitle: db "Game", 0x00
dogImage: db "dog.png", 0x00

section '.note.GNU-stack'
