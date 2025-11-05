.data
# ==================== CONFIGURACIÓN ====================
displayAddress: .word 0x10010000
collisionMatrix: .word 0x10050000
screenWidth: .word 256
screenHeight: .word 256

# ==================== COLORES ====================
bgColor: .word 0x00000000
paddleColor: .word 0x00FFFFFF
ballColor: .word 0x00FF0000
blockColor1: .word 0x00FF00FF
blockColor2: .word 0x0000FFFF
blockColor3: .word 0x00FFFF00
blockColor4: .word 0x0000FF00

# ==================== PALETA ====================
paddleX: .word 112
paddleY: .word 240
paddleWidth: .word 32
paddleHeight: .word 4
paddleSpeed: .word 4

# ==================== PELOTA ====================
ballX: .word 128
ballY: .word 128
ballVelX: .word 1
ballVelY: .word -1

# ==================== BLOQUES ====================
blockWidth: .word 20
blockHeight: .word 8
blocksPerRow: .word 10
blockRows: .word 6
blockStartX: .word 18
blockStartY: .word 30

blocks: .word 1,1,1,1,1,1,1,1,1,1
        .word 1,1,1,1,1,1,1,1,1,1
        .word 1,1,1,1,1,1,1,1,1,1
        .word 1,1,1,1,1,1,1,1,1,1
        .word 1,1,1,1,1,1,1,1,1,1
        .word 1,1,1,1,1,1,1,1,1,1

blocksRemaining: .word 60

# ==================== SISTEMA ====================
score: .word 0
lives: .word 3