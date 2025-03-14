; ======================
;        Raylib
; ======================
extrn SetTargetFPS
extrn InitWindow
extrn CloseWindow
extrn WindowShouldClose
extrn GetScreenWidth
extrn GetScreenHeight
extrn BeginDrawing
extrn EndDrawing
extrn ClearBackground
extrn LoadTexture
extrn DrawTexture
extrn DrawTexturePro

; ======================
;        STDLIB 
; ======================
extrn printf
extrn malloc
extrn realloc

; ======================
;         PIXIE 
; ======================
STATE_IDLE      equ 0
STATE_RUN       equ 1
STATE_JUMP      equ 2
STATE_FALL      equ 3

DIRECTION_LEFT  equ 0
DIRECTION_RIGHT equ 1

