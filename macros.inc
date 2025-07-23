macro callWith object, function
{
    mov rdi, object
    call function
}

macro addAsset var, path
{
    var db "assets/", path, 0x0
}
