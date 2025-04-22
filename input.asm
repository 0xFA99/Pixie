; ============== PARAMETERS ==============
; rdi       = Camera*

_inputCamera:
    ; Get mouse wheel value
    ; Multiply with zoom level
    call _getMouseWheelMove
    movss xmm1, [cameraZoomLevel]
    mulss xmm1, xmm0

    ; Sum the result with original camera zoom
    ; Save back into camera zoom
    movss xmm0, [rdi + 20]
    addss xmm0, xmm1

    ; Store back into camera zoom
    movd [rdi + 20], xmm0

    ret

; ============== PARAMETERS ==============
; rdi       = [ Reference ] Player*
; xmm0      = [ float ] frameTime
; xmm1      = [ float ] gravity

; ============== VARIABLES ===============
; r12       = [ Pointer ] Player*
; r13d      = [ int ] Direction
; r14b      = [ bool ] isJump

public _inputPlayer

_inputPlayer:
    mov r12, rdi        ; Player

    mov r13d, 0

    ; mov edi, 265        ; KEY_UP
    ; call _isKeyDown
    ; mov r14b, al

.checkKeyRight:
    mov edi, 262        ; KEY_RIGHT
    call _isKeyDown
    test al, al
    je .checkKeyLeft

    mov edi, 263        ; KEY_LEFT
    call _isKeyDown
    xor eax, 1
    test al, al
    je .checkKeyLeft

    ; Set Direction Right
    mov r13d, DIRECTION_RIGHT

    jmp .compareState

.checkKeyLeft:
    mov edi, 263        ; KEY_LEFT
    call _isKeyDown
    test al, al
    je .compareState

    mov edi, 262        ; KEY_RIGHT
    call _isKeyDown
    xor eax, 1
    test al, al
    je .compareState

    mov r13d, DIRECTION_LEFT

.compareState:
    ; Get player state
    mov eax, [r12 + 40]

    ; Compare state
    cmp eax, STATE_IDLE
    je .stateIdle

    cmp eax, STATE_RUN
    je .stateRun

    ; cmp eax, STATE_JUMP
    ; je .stateJump

    ; cmp eax, STATE_FALL
    ; je .stateFall

    ; jmp .applyGravity
    jmp .applyGravity

.stateIdle:
.idleToRun:
    ; Check if Player start to RUN
    cmp r13d, 0
    je .stayIdle

    ; Set player state to STATE_RUN
    mov dword [r12 + 40], STATE_RUN

    ; Set direction
    cmp r13d, 0
    setg al
    movzx edx, al
    shl edx, 1
    sub edx, 1
    mov [r12 + 44], edx

    ; Update Velocity ( direction * speed )
    movss xmm2, [r12 + 36]      ; Player.speed
    cvtsi2ss xmm3, r13d         ; Direction
    mulss xmm2, xmm3
    movd [r12 + 24], xmm2       ; Player.velocity.x

    jmp .applyGravity

.stayIdle:
    ; Set player velocity to 0
    pxor xmm2, xmm2
    movq [r12 + 24], xmm2

    jmp .applyGravity

.stateRun:
.runToIdle:
    ; Check if Player Idle
    cmp r13d, 0
    jne .stayRun
    
    ; Set state to STATE_IDLE
    mov dword [r12 + 40], STATE_IDLE

    ; Set velocity to 0
    mov dword [r12 + 24], 0.0

    jmp .applyGravity

.stayRun:
    ; Set Player Direction
    cmp r13d, 0
    setg al
    movzx edx, al
    shl edx, 1
    sub edx, 1
    mov [r12 + 44], edx

    ; Update Velocity ( direction * speed )
    movss xmm2, [r12 + 36]      ; Player.speed
    cvtsi2ss xmm3, r13d         ; Direction
    mulss xmm2, xmm3
    movd [r12 + 24], xmm2       ; Player.velocity.x

.applyGravity:
    ; frameTime * gravity
    mulss xmm0, xmm1

    ; Add with player velocity y
    addss xmm0, [r12 + 28]

    ; Store back into player velocity y
    movss [r12 + 28], xmm0

.return:
    ret

