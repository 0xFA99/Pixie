; ======================
;        Raylib
; ======================
extrn 'InitWindow'          as _initWindow
extrn 'CloseWindow'         as _closeWindow
extrn 'SetTargetFPS'        as _setTargetFPS
extrn 'WindowShouldClose'   as _windowShouldClose
extrn 'BeginDrawing'        as _beginDrawing
extrn 'EndDrawing'          as _endDrawing
extrn 'ClearBackground'     as _clearBackground
extrn 'LoadTexture'         as _loadTexture
extrn 'DrawTextureEx'       as _drawTextureEx
extrn 'DrawTexturePro'      as _drawTexturePro
extrn 'GetScreenWidth'      as _getScreenWidth
extrn 'GetScreenHeight'     as _getScreenHeight
extrn 'BeginMode2D'         as _beginMode2D
extrn 'EndMode2D'           as _endMode2D
extrn 'GetMouseWheelMove'   as _getMouseWheelMove
extrn 'GetFrameTime'        as _getFrameTime
extrn 'IsKeyDown'           as _isKeyDown

extrn Vector2Scale
extrn Vector2Add

extrn printf
extrn malloc
extrn realloc
extrn free

STATE_IDLE                  equ 0
STATE_RUN                   equ 1
STATE_JUMP                  equ 2
STATE_FALL                  equ 3

DIRECTION_LEFT              equ -1
DIRECTION_RIGHT             equ 1

