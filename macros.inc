macro callWith object, function
{
    mov rdi, object
    call function
}

macro addAsset var, path
{
    var db "assets/", path, 0x0
}

macro addAnimation entity, state, direction, frameStart, frameEnd, fps
{
    mov rdi, entity

    mov sil, state
    mov dl, direction

    mov ecx, frameStart
    mov r8d, frameEnd

    mov eax, fps
    movd xmm0, eax
    call _addAnimationSprite
}

macro setAnimation object, state, direction
{
    mov rdi, object
    mov esi, state
    mov edx, direction
    call _setAnimationSprite
}

macro clampss reg, min, max
{
    minss reg, max
    maxss reg, min
}

macro isChangingDirection result, velocity, direction
{
    local .checkLeft, .return

    xorps xmm2, xmm2                ; xmm2 = 0.0
    mov result, 0

    ; check (velocity > 0.0 && direction == 1)
    ucomiss velocity, xmm2
    jbe .checkLeft

    cmp direction, DIRECTION_LEFT
    jne .checkLeft

    mov result, DIRECTION_RIGHT         ; result = DIRECTION_RIGHT

    jmp .return

.checkLeft:
    ; check (velocity < 0.0 && direction == 1)
    ucomiss xmm2, velocity
    jbe .return

    cmp direction, DIRECTION_RIGHT
    jne .return

    mov result, DIRECTION_RIGHT
    jmp .return

.return:
}

macro applyDeceleration player, frameTime
{
    local .apply, .return

    ; deceleration *= frameTime
    movss xmm1, [player + 36]       ; player.deceleration
    mulss xmm1, frameTime

    movss xmm2, [player + 24]       ; player.velocity.x

    ; fabs(player.velocity.x) & 0x7FFFFFFF
    mov eax, 0x7FFFFFFF
    movd xmm3, eax
    andps xmm2, xmm3

    ; if (fabs(player.velocity.x) <= deceleration)
    ucomiss xmm2, xmm1
    ja .apply

    ; player.velocity.x = 0.0
    mov dowrd [player + 24], 0.0
    jmp .return

.apply:
    ; sign = player.velocity.x > 0.0 ? 1.0 : -1.0
    xorps xmm3, xmm3
    ucomiss xmm2, xmm3

    mov eax, 0x3F800000             ; 1.0
    mov ecx, 0xBF800000             ; -1.0

    movd xmm3, eax
    movd xmm4, ecx

    cmovb xmm3, xmm4                ; if velociy.x < 0 -> -1.0

    ; player.velocity.x -= sign * deceleration
    mulss xmm3, xmm1
    subss xmm2, xmm3
    movss [player + 24], xmm2

.return:
}

macro ApplyDirectionRun
{
    ; (direction > 0) ? DIRECTION_RIGHT : DIRECTION_LEFT
    mov     eax, r14d
    mov     ecx, 1
    test    eax, eax
    cmovs   ecx, eax
    sar     ecx, 31
    lea     ecx, [ecx*2 + 1]
    mov     [r12 + 52], ecx

    ; player.velocity.x += direction * player.acceleration * frameTime
    cvtsi2ss xmm2, r14d             ; direction
    mulss xmm2, [r12 + 32]          ; player.acceleration
    mulss xmm2, xmm0                ; frameTime

    movss xmm1, [r12 + 24]          ; player.velocity.x
    addss xmm1, xmm2
    movss [r12 + 24], xmm1
}


; @param xmm0   : velocity
; @param dl     : direction
; @return al    : (0 or 1)
macro checkDirection velocity, direction
{
    local .pos, .neg, .ret

    xor al, al
    pxor xmm8, xmm8

    cmp direction, DIRECTION_LEFT
    je .pos

    cmp direction, DIRECTION_RIGHT
    je .neg

    jmp .ret

.pos:
    ; if velocity > 0.0
    comiss velocity, xmm8
    jbe .ret

    mov al, 1
    jmp .ret

.neg:
    ; if velocity < 0.0
    comiss xmm8, velocity
    jbe .ret

    mov al, 1

.ret:
}

; fabsf - computes absolute value of a float
; @param    arg - float in xmm register (modified in-place)
; @return   arg - absolute value (in same register)
macro fabsf arg
{
    mov eax, 0x7FFFFFFF             ; mask abs
    movd xmm8, eax
    andps arg, xmm8
}

macro negss arg
{
    mov eax, 0x80000000             ; mask negation
    movd xmm8, eax
    xorps arg, xmm8
}

macro signss arg
{
    local .negOne, .return

    pxor xmm8, xmm8

    comiss arg, xmm8
    jbe .negOne

    mov eax, 0x3f800000             ; 1.0
    movd arg, eax

    jmp .return

.negOne:
    mov eax, 0xbf800000             ; -1.0
    movd arg, eax

.return:
}

macro updateDirection direction
{
    local .setLeft, .done

    xor eax, eax
    cmp direction, eax
    jbe .setLeft

    mov eax, DIRECTION_RIGHT
    jmp .ret

.setLeft:
    mov eax, DIRECTION_LEFT

.done:
}

; Set low 32 bits of reg to value
macro setLow32 reg, value
{
    mov         r10, reg
    mov         r11, MASK_HIGH
    and         r10, r11
    or          r10d, value
    mov         reg, r10
}


; Set high 32 bits of reg to value
; macro setHigh32 reg, value
; {
;     mov         r10d, value
;     shl         r10, 32
;     mov         r11, reg
;     and         r11, 0xFFFFFFFF
;     or          r11, r10
;     mov         reg, r11
; }
macro setHigh32 reg64, value32 {
    local temp
    mov temp, value32
    shl temp, 32
    and reg64, 0xFFFFFFFF
    or reg64, temp
}

