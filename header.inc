; ======================
;        Raylib
; ======================
extrn SetTargetFPS
extrn InitWindow
extrn CloseWindow
extrn WindowShouldClose
extrn GetScreenWidth
extrn GetScreenHeight
extrn GetFrameTime
extrn BeginDrawing
extrn EndDrawing
extrn BeginMode2D
extrn EndMode2D
extrn ClearBackground
extrn LoadTexture
extrn DrawTexture
extrn DrawTexturePro
extrn IsKeyDown

; ======================
;        RayMath 
; ======================
extrn Vector2Add
extrn Vector2Scale

; ======================
;        STDLIB 
; ======================
extrn printf
extrn malloc
extrn realloc
extrn getchar

; ======================
;         PIXIE 
; ======================
STATE_IDLE      equ 0
STATE_RUN       equ 1
STATE_JUMP      equ 2
STATE_FALL      equ 3

DIRECTION_LEFT  equ 0
DIRECTION_RIGHT equ 1

