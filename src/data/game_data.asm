.data
# ==================== CONFIGURACIÓN ====================
displayAddress: .word 0x10010000
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
blockColorIndestructible: .word 0x00808080  # NUEVO: Gris para indestructibles

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

# ==================== SISTEMA DE NIVELES ====================
currentLevel: .word 1
totalLevels: .word 3

# ==================== NIVELES ====================

# Nivel 1: Básico (todos destructibles)
level1:
    .word 1,1,1,1,1,1,1,1,1,1
    .word 1,1,1,1,1,1,1,1,1,1
    .word 1,1,1,1,1,1,1,1,1,1
    .word 1,1,1,1,1,1,1,1,1,1
    .word 1,1,1,1,1,1,1,1,1,1
    .word 1,1,1,1,1,1,1,1,1,1

# Nivel 2: Laberinto (2 = indestructible)
level2:
    .word 2,1,1,1,1,1,1,1,1,2
    .word 1,2,0,0,1,1,0,0,2,1
    .word 1,0,2,1,1,1,1,2,0,1
    .word 1,0,1,2,1,1,2,1,0,1
    .word 1,2,0,0,1,1,0,0,2,1
    .word 2,1,1,1,1,1,1,1,1,2

# Nivel 3: Fortaleza
level3:
    .word 2,2,2,2,2,2,2,2,2,2
    .word 2,1,1,1,1,1,1,1,1,2
    .word 2,1,2,2,1,1,2,2,1,2
    .word 2,1,2,2,1,1,2,2,1,2
    .word 2,1,1,1,1,1,1,1,1,2
    .word 2,2,2,2,2,2,2,2,2,2

# Punteros a niveles
levelPointers: .word level1, level2, level3

# Bloques destructibles por nivel
levelDestructible: .word 60, 36, 24

# ==================== BLOQUES ====================
blockWidth: .word 20
blockHeight: .word 8
blocksPerRow: .word 10
blockRows: .word 6
blockStartX: .word 18
blockStartY: .word 30

# Array de bloques actual (se copia del nivel)
blocks: .space 240  # 60 palabras = 6x10 bloques

blocksRemaining: .word 60

# ==================== SISTEMA ====================
score: .word 0
lives: .word 3