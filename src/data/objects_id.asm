# ==================== IDs DE OBJETOS ====================
# Bloques normales (1 golpe)
OBJ_EMPTY:          .word 0
OBJ_BLOCK_RED:      .word 1
OBJ_BLOCK_YELLOW:   .word 2
OBJ_BLOCK_BLUE:     .word 3
OBJ_BLOCK_GREEN:    .word 4
OBJ_BLOCK_MAGENTA:  .word 5
OBJ_BLOCK_WHITE:    .word 6

# Bloques blindados (2 golpes)
OBJ_BLOCK_RED_ARMORED:    .word 7
OBJ_BLOCK_YELLOW_ARMORED: .word 8
OBJ_BLOCK_BLUE_ARMORED:   .word 9
OBJ_BLOCK_GREEN_ARMORED:  .word 10
OBJ_BLOCK_MAGENTA_ARMORED:.word 11
OBJ_BLOCK_WHITE_ARMORED:  .word 12

# Bloque indestructible
OBJ_BLOCK_INDESTRUCTIBLE: .word 13

# Objetos móviles
OBJ_BALL:           .word 14
OBJ_PADDLE:         .word 15

# Power-ups
OBJ_POWERUP_ENLARGE:    .word 16
OBJ_POWERUP_SHRINK:     .word 17
OBJ_POWERUP_MULTIBALL:  .word 18

LIFE_ICON: .word 19

# Paredes y límites
OBJ_WALL:           .word 20