stringFormat db "%s", 0xa, 0x00
numberFormat1 db "FrameTime 1 = %f", 0xa, 0x00
numberFormat2 db "FrameTime 2 = %f", 0xa, 0x00
numberFormatD db "%d", 0xa, 0x00

idlestr db "Idle...", 0xa, 0x00
runstr db "Run...", 0xa, 0x00

; Texture
textureId       db "Texture Id: %d", 0xa, 0x00
textureWidth    db "Texture Width: %d", 0xa, 0x00
textureHeight   db "Texture Height: %d", 0xa, 0x00
textureMipmaps  db "Texture Mipmaps: %d", 0xa, 0x00
textureFormat   db "Texture Format: %d", 0xa, 0x00

; frame
frameX          db "Frame X: %f", 0xa, 0x00
frameY          db "Frame Y: %f", 0xa, 0x00
frameWidth      db "Frame Width: %f", 0xa, 0x00
frameHeight     db "Frame Height: %f", 0xa, 0x00

; position
positionX       db "Position X: %f", 0xa, 0x00
positionY       db "Position Y: %f", 0xa, 0x00
positionWidth   db "Position Width: %f", 0xa, 0x00
positionHeight  db "Position Height: %f", 0xa, 0x00

failedLoadTexture db "[ERROR] Failed load texture", 0x00
failedAllocationMemory db "[ERROR] Failed Allocation Memory", 0x00

spriteSheetEmpty db "[WARNING] Spritesheet is empty", 0x00

hallo db "[INFO] Hallo", 0x00
