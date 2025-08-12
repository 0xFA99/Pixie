extrn InitWindow
extrn CloseWindow
extrn SetTargetFPS
extrn WindowShouldClose
extrn BeginDrawing
extrn EndDrawing
extrn ClearBackground
extrn LoadTexture
extrn DrawTexturePro
extrn GetScreenWidth
extrn GetScreenHeight
extrn GetMouseWheelMove
extrn BeginMode2D
extrn EndMode2D
extrn GetFrameTime
extrn IsKeyDown
extrn IsKeyPressed

extrn malloc
extrn realloc
extrn printf

STATE_IDLE      equ  0
STATE_RUN       equ  1
STATE_JUMP      equ  2
STATE_FALL      equ  3
STATE_BREAK     equ  4

DIRECTION_LEFT  equ -1
DIRECTION_RIGHT equ  1

KEY_RIGHT       equ 262
KEY_LEFT        equ 263
KEY_UP          equ 265

MASK_HIGH       equ 0xFFFFFFFF00000000
MASK_LOW        equ 0x00000000FFFFFFFF
MASK_FLIP       equ 0x80000000

