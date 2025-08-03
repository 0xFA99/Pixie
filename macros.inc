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
    mov esi, state
    mov edx, direction
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
    xorps xmm3, xmm3
    movss [player + 24], xmm3
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
    addss xmm1, xmm2                ; player.velocity.x
    movss [r12 + 24], xmm1
}
