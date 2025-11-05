.text
# ==================== INICIALIZAR MATRIZ DE COLISIONES ====================
initCollisionMatrix:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Limpiar toda la matriz a OBJ_EMPTY
    lw $t0, collisionMatrix
    li $t1, 0
    li $t2, 65536        # 256x256 bytes
    
clear_matrix_loop:
    sb $zero, 0($t0)     # Guardar 0 (OBJ_EMPTY)
    addiu $t0, $t0, 1
    addiu $t1, $t1, 1
    blt $t1, $t2, clear_matrix_loop
    
    # Registrar paredes
    jal registerWalls
    
    # Registrar bloques iniciales
    jal registerAllBlocksInMatrix
    
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra

# ==================== REGISTRAR PAREDES ====================
registerWalls:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Pared izquierda (x=0-1)
    li $a0, 0
    li $a1, 0
    li $a2, 2
    li $a3, 256
    lw $t0, OBJ_WALL
    jal fillRectInMatrix
    
    # Pared derecha (x=254-255)
    li $a0, 254
    li $a1, 0
    li $a2, 2
    li $a3, 256
    lw $t0, OBJ_WALL
    jal fillRectInMatrix
    
    # Techo (y=0-1)
    li $a0, 0
    li $a1, 0
    li $a2, 256
    li $a3, 2
    lw $t0, OBJ_WALL
    jal fillRectInMatrix
    
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra

# ==================== REGISTRAR TODOS LOS BLOQUES EN MATRIZ ====================
registerAllBlocksInMatrix:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    
    li $s0, 0                    # Fila
    lw $s1, blockRows
    
register_blocks_matrix_row:
    bge $s0, $s1, register_blocks_matrix_end
    li $s2, 0                    # Columna
    lw $s3, blocksPerRow
    
register_blocks_matrix_col:
    bge $s2, $s3, register_blocks_matrix_next_row
    
    # Verificar si bloque existe en array blocks
    mul $t0, $s0, 10
    add $t0, $t0, $s2
    sll $t0, $t0, 2
    la $t1, blocks
    add $t1, $t1, $t0
    lw $t2, 0($t1)
    
    beqz $t2, register_blocks_matrix_skip
    
    # Calcular posición del bloque (sin separación)
    lw $t3, blockStartX
    mul $t4, $s2, 20            # 20px ancho, sin espacio
    add $t4, $t3, $t4           # X inicial
    
    lw $t3, blockStartY
    mul $t5, $s0, 8             # 8px alto, sin espacio
    add $t5, $t3, $t5           # Y inicial
    
    # Determinar ID según fila (color) y tipo
    move $a0, $s0
    jal getBlockIDFromRow
    move $a2, $v0               # ID del bloque
    
    # Registrar bloque en matriz
    move $a0, $t4               # X
    move $a1, $t5               # Y
    lw $a3, blockWidth
    lw $t6, blockHeight
    move $t0, $a2               # objectID
    jal fillRectInMatrix
    
register_blocks_matrix_skip:
    addi $s2, $s2, 1
    j register_blocks_matrix_col

register_blocks_matrix_next_row:
    addi $s0, $s0, 1
    j register_blocks_matrix_row

register_blocks_matrix_end:
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra

# ==================== OBTENER ID DE BLOQUE SEGÚN FILA ====================
getBlockIDFromRow:
    # $a0 = fila
    # Retorna: $v0 = ID del bloque
    
    li $v0, 1                   # Por defecto: OBJ_BLOCK_RED
    
    li $t0, 0
    beq $a0, $t0, get_block_id_end
    li $t0, 1
    beq $a0, $t0, block_yellow
    li $t0, 2
    beq $a0, $t0, block_blue
    li $t0, 3
    beq $a0, $t0, block_green
    li $t0, 4
    beq $a0, $t0, block_magenta
    li $v0, 6                   # OBJ_BLOCK_WHITE
    j get_block_id_end
    
block_yellow:
    li $v0, 2
    j get_block_id_end
block_blue:
    li $v0, 3
    j get_block_id_end
block_green:
    li $v0, 4
    j get_block_id_end
block_magenta:
    li $v0, 5
    
get_block_id_end:
    jr $ra

# ==================== LLENAR RECTÁNGULO EN MATRIZ ====================
# $a0 = x, $a1 = y, $a2 = width, $a3 = height, $t0 = objectID
fillRectInMatrix:
    addiu $sp, $sp, -20        # Reservar espacio para 4 registros + ra
    sw $ra, 0($sp)
    sw $s4, 4($sp)
    sw $s5, 8($sp)
    sw $s6, 12($sp)
    sw $s7, 16($sp)
    
    move $s4, $a0               # x
    move $s5, $a1               # y
    move $s6, $a2               # width
    move $s7, $a3               # height
    # $t0 ya tiene objectID, lo guardamos en $t9 temporalmente
    move $t9, $t0
    
    li $t1, 0                   # Offset Y
    
fill_rect_y:
    bge $t1, $s7, fill_rect_end
    li $t2, 0                   # Offset X
    
fill_rect_x:
    bge $t2, $s6, fill_rect_next_y
    
    add $a0, $s4, $t2           # X = x + offset_x
    add $a1, $s5, $t1           # Y = y + offset_y
    
    # Verificar límites de pantalla (0-255)
    bltz $a0, fill_rect_skip
    li $t3, 256
    bge $a0, $t3, fill_rect_skip
    bltz $a1, fill_rect_skip
    bge $a1, $t3, fill_rect_skip
    
    move $a2, $t9               # objectID (de $t9)
    jal setObjectInMatrix
    
fill_rect_skip:
    addi $t2, $t2, 1
    j fill_rect_x

fill_rect_next_y:
    addi $t1, $t1, 1
    j fill_rect_y

fill_rect_end:
    lw $s7, 16($sp)
    lw $s6, 12($sp)
    lw $s5, 8($sp)
    lw $s4, 4($sp)
    lw $ra, 0($sp)
    addiu $sp, $sp, 20
    jr $ra

# ==================== GUARDAR OBJETO EN MATRIZ ====================
# $a0 = x, $a1 = y, $a2 = objectID
setObjectInMatrix:
    # Verificar límites primero
    bltz $a0, set_object_end
    bltz $a1, set_object_end
    li $t0, 255
    bgt $a0, $t0, set_object_end
    bgt $a1, $t0, set_object_end
    
    lw $t0, collisionMatrix
    
    # Calcular offset: y * 256 + x
    sll $t1, $a1, 8             # y * 256
    add $t1, $t1, $a0           # + x
    
    # Verificar que el offset esté dentro del rango
    li $t2, 65535
    bgt $t1, $t2, set_object_end
    
    add $t0, $t0, $t1
    sb $a2, 0($t0)
    
set_object_end:
    jr $ra

# ==================== LEER OBJETO DE MATRIZ ====================
# $a0 = x, $a1 = y
# Retorna: $v0 = objectID
getObjectFromMatrix:
    # Verificar límites primero
    bltz $a0, get_object_invalid
    bltz $a1, get_object_invalid
    li $t0, 255
    bgt $a0, $t0, get_object_invalid
    bgt $a1, $t0, get_object_invalid
    
    lw $t0, collisionMatrix
    
    # Calcular offset: y * 256 + x (sin usar multiplicación que cause overflow)
    sll $t1, $a1, 8             # y * 256
    add $t1, $t1, $a0           # + x
    
    # Verificar que el offset esté dentro del rango
    li $t2, 65535
    bgt $t1, $t2, get_object_invalid
    
    add $t0, $t0, $t1
    lb $v0, 0($t0)
    jr $ra

get_object_invalid:
    li $v0, 0                   # Retornar OBJ_EMPTY para coordenadas inválidas
    jr $ra

# ==================== VERIFICAR COLISIONES USANDO MATRIZ ====================
checkCollisionsWithMatrix:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    
    lw $a0, ballX
    lw $a1, ballY
    
    # Verificar límites primero
    bltz $a0, collision_wall
    li $t0, 256
    bge $a0, $t0, collision_wall
    bltz $a1, collision_wall
    bge $a1, $t0, lost_ball
    
    jal getObjectFromMatrix
    
    # $v0 contiene el ID en la posición de la pelota
    beqz $v0, no_collision_matrix
    
    # Verificar tipo de colisión
    li $t0, 20                  # OBJ_WALL
    beq $v0, $t0, collision_with_wall_matrix
    
    li $t0, 15                  # OBJ_PADDLE
    beq $v0, $t0, collision_with_paddle_matrix
    
    # Es algún tipo de bloque (1-13)
    li $t0, 1
    blt $v0, $t0, no_collision_matrix
    li $t0, 13
    ble $v0, $t0, collision_with_block_matrix
    
no_collision_matrix:
    li $v0, 0
    j check_collisions_end

collision_wall:
    li $v0, 1
    j check_collisions_end

lost_ball:
    li $v0, 4                   # Pérdida de pelota
    j check_collisions_end

collision_with_wall_matrix:
    li $v0, 1
    j check_collisions_end

collision_with_paddle_matrix:
    li $v0, 2
    j check_collisions_end

collision_with_block_matrix:
    move $v0, $v0               # $v0 contiene el ID del bloque
    li $v1, 3                   # Tipo de colisión: bloque
    
check_collisions_end:
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra

# ==================== ACTUALIZAR PALETA EN MATRIZ ====================
updatePaddleInMatrix:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Limpiar área completa de paleta (y=240-247)
    li $a0, 0
    li $a1, 240
    li $a2, 256
    li $a3, 8  # Cambiado de 4 a 8
    li $t0, 0                   # OBJ_EMPTY
    jal fillRectInMatrix
    
    # Dibujar paleta en nueva posición
    lw $a0, paddleX
    lw $a1, paddleY
    lw $a2, paddleWidth
    lw $a3, paddleHeight
    lw $t0, OBJ_PADDLE
    jal fillRectInMatrix
    
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra

# ==================== VERIFICAR COLISIONES EN TRAYECTORIA ====================
checkCollisionsOnTrajectory:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    
    lw $t0, ballX
    lw $t1, ballY
    lw $t2, ballVelX
    lw $t3, ballVelY
    
    # Verificar posición actual + 1 paso en X
    add $a0, $t0, $t2
    move $a1, $t1
    jal getObjectFromMatrix
    bnez $v0, collision_detected_traj
    
    # Verificar posición actual + 1 paso en Y
    move $a0, $t0
    add $a1, $t1, $t3
    jal getObjectFromMatrix
    bnez $v0, collision_detected_traj
    
    # Verificar posición actual + 1 paso diagonal
    add $a0, $t0, $t2
    add $a1, $t1, $t3
    jal getObjectFromMatrix
    bnez $v0, collision_detected_traj
    
    li $v0, 0
    j check_trajectory_end

collision_detected_traj:
    # $v0 contiene el ID del objeto colisionado
    move $v1, $v0
    
    # Determinar tipo de colisión
    beqz $v0, no_collision_traj
    li $t0, 20                  # OBJ_WALL
    beq $v0, $t0, wall_collision_traj
    li $t0, 15                  # OBJ_PADDLE  
    beq $v0, $t0, paddle_collision_traj
    
    # Si es un bloque (1-13)
    li $t0, 1
    blt $v0, $t0, no_collision_traj
    li $t0, 13
    ble $v0, $t0, block_collision_traj
    
    li $v0, 0
    j check_trajectory_end

wall_collision_traj:
    li $v0, 1
    j check_trajectory_end

paddle_collision_traj:
    li $v0, 2
    j check_trajectory_end

block_collision_traj:
    li $v0, 3
    j check_trajectory_end

no_collision_traj:
    li $v0, 0

check_trajectory_end:
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra

    # ==================== DEBUG: VERIFICAR BLOQUES ====================
debugCheckBlocks:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Verificar posición de un bloque conocido (primer bloque)
    li $a0, 20   # X de primer bloque
    li $a1, 30   # Y de primer bloque
    jal getObjectFromMatrix
    
    # Mostrar resultado
    move $t9, $v0
    
    li $v0, 11
    li $a0, 'B'
    syscall
    li $v0, 11
    li $a0, 'L'
    syscall
    li $v0, 11
    li $a0, 'O'
    syscall
    li $v0, 11
    li $a0, 'C'
    syscall
    li $v0, 11
    li $a0, 'K'
    syscall
    li $v0, 11
    li $a0, ':'
    syscall
    li $v0, 1
    move $a0, $t9
    syscall
    li $v0, 11
    li $a0, '\n'
    syscall
    
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra