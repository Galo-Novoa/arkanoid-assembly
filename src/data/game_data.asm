.data
# ==================== CONFIGURACIÓN ====================
displayAddress: .word 0x10008000
screenWidth: .word 64
screenHeight: .word 64

# ==================== COLORES ====================
bgColor: .word 0x00000000
paddleColor: .word 0x00FFFFFF
ballColor: .word 0x00FF0000
blockColor1: .word 0x00FF00FF
blockColor2: .word 0x0000FFFF
blockColor3: .word 0x00FFFF00
blockColor4: .word 0x0000FF00

# ==================== PALETA ====================
paddleX: .word 26
paddleY: .word 56
paddleWidth: .word 12
paddleHeight: .word 3
paddleSpeed: .word 3

# ==================== PELOTA ====================
ballX: .word 32
ballY: .word 30
ballVelX: .word 1
ballVelY: .word -1

# ==================== BLOQUES ====================
blockWidth: .word 5
blockHeight: .word 2
blocksPerRow: .word 10
blockRows: .word 4
blockStartX: .word 2
blockStartY: .word 4

blocks: .word 1,1,1,1,1,1,1,1,1,1
        .word 1,1,1,1,1,1,1,1,1,1
        .word 1,1,1,1,1,1,1,1,1,1
        .word 1,1,1,1,1,1,1,1,1,1

blocksRemaining: .word 40

# ==================== SISTEMA ====================
score: .word 0
lives: .word 3