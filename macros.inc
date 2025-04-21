macro addParallax parallax, texture_file, posX, posY, speed
{
    mov rdi, parallax
    mov rsi, texture_file
    mov edx, posX
    mov ecx, posY
    mov eax, speed
    movd xmm0, eax
    call _initParallax
}

macro callWith object, function
{
    mov rdi, object
    call function
}

macro addAnimationState object, state, direction, startIndex, endIndex, FPS
{
    mov rdi, object
    mov esi, state
    mov edx, direction
    mov ecx, startIndex
    mov r8d, endIndex
    mov eax, FPS
    movd xmm0, eax
    call _addAnimationState
}

macro setAnimationState object, state, direction
{
    mov rdi, object
    mov esi, state
    mov edx, direction
    call _setAnimationState
}
