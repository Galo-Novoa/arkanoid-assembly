# ==================== MOVER PELOTA ====================
moveBall:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    
    # ========== VERIFICAR LÍMITES VERTICALES PRIMERO ==========
    lw $t0, ballY
    lw $t1, ballVelY
    add $t2, $t0, $t1
    
    # Verificar si cayó al fondo
    li $t3, 255
    bgt $t2, $t3, handle_lost_ball
    
    # ========== VERIFICAR COLISIONES EN TRAYECTORIA ==========
    jal checkCollisionsOnTrajectory
    
    # $v0 = tipo de colisión, $v1 = ID del objeto
    beqz $v0, check_backup_collision  # Si no hay colisión, verificar sistema de respaldo
    
    # Manejar colisión según tipo
    li $t0, 1
    beq $v0, $t0, handle_wall_collision
    
    li $t0, 2
    beq $v0, $t0, handle_paddle_collision
    
    li $t0, 3
    beq $v0, $t0, handle_block_collision
    
    j check_backup_collision

check_backup_collision:
    # Sistema de respaldo: verificar colisiones tradicionales
    jal checkPaddleCollision
    beqz $v0, check_blocks_backup
    j handle_paddle_collision

check_blocks_backup:
    jal checkBlockCollision
    
    j move_ball_normal

handle_lost_ball:
    jal lostBall
    j moveBall_end

move_ball_normal:
    # ========== VERIFICAR LÍMITES ANTES DE MOVER ==========
    lw $t0, ballX
    lw $t1, ballVelX
    add $t2, $t0, $t1
    
    # Verificar límites horizontales
    bltz $t2, bounce_x
    li $t3, 255
    bgt $t2, $t3, bounce_x
    
    lw $t0, ballY
    lw $t1, ballVelY
    add $t2, $t0, $t1
    
    # Verificar límites verticales (techo)
    bltz $t2, bounce_y
    j move_ball_do_move

bounce_x:
    # Rebote horizontal
    lw $t0, ballVelX
    sub $t0, $zero, $t0
    sw $t0, ballVelX
    j move_ball_do_move

bounce_y:
    # Rebote vertical (techo)
    lw $t0, ballVelY
    sub $t0, $zero, $t0
    sw $t0, ballVelY
    j move_ball_do_move

handle_wall_collision:
    # Rebote en pared
    lw $t0, ballVelX
    sub $t0, $zero, $t0
    sw $t0, ballVelX
    j move_ball_after_collision

handle_paddle_collision:
    # Rebote con paleta - usar el sistema de matriz
    lw $t0, ballVelY
    li $t1, -1
    sw $t1, ballVelY
    
    # Aplicar ángulo según posición en la paleta
    jal calculatePaddleBounceAngle
    
    # Mover la pelota ligeramente hacia arriba para evitar colisión múltiple
    lw $t0, ballY
    addi $t0, $t0, -2
    sw $t0, ballY
    
    j move_ball_after_collision

handle_block_collision:
    # Colisión con bloque - rebotar y destruir bloque
    lw $t0, ballVelY
    sub $t0, $zero, $t0
    sw $t0, ballVelY
    
    # Destruir el bloque
    move $a0, $v1               # ID del bloque
    jal destroyBlockInMatrix
    
    j move_ball_after_collision

move_ball_do_move:
    # Verificar límites antes de mover X
    lw $t0, ballX
    lw $t1, ballVelX
    add $t2, $t0, $t1
    
    # Si se sale de los límites, ajustar
    bltz $t2, adjust_x_left
    li $t3, 255
    bgt $t2, $t3, adjust_x_right
    j move_x_ok

adjust_x_left:
    li $t2, 0
    j move_x_ok

adjust_x_right:
    li $t2, 255

move_x_ok:
    sw $t2, ballX
    
    # Verificar límites antes de mover Y
    lw $t0, ballY
    lw $t1, ballVelY
    add $t2, $t0, $t1
    
    # Si se sale de los límites, ajustar
    bltz $t2, adjust_y_top
    li $t3, 255
    bgt $t2, $t3, adjust_y_bottom
    j move_y_ok

adjust_y_top:
    li $t2, 0
    j move_y_ok

adjust_y_bottom:
    li $t2, 255

move_y_ok:
    sw $t2, ballY
    
    j move_ball_after_move

move_ball_after_collision:
    # Después de colisión, mover la pelota (pero con nueva velocidad)
    lw $t0, ballX
    lw $t1, ballVelX
    add $t0, $t0, $t1
    sw $t0, ballX
    
    lw $t0, ballY
    lw $t1, ballVelY
    add $t0, $t0, $t1
    sw $t0, ballY

move_ball_after_move:
    # ========== ACTUALIZAR PELOTA EN MATRIZ ==========
    jal updateBallInMatrix

moveBall_end:
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra

# ==================== CALCULAR REBOTE CON PALETA ====================
calculatePaddleBounceAngle:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    
    lw $t0, ballX
    lw $t1, paddleX
    sub $t2, $t0, $t1          # Posición relativa en la paleta
    
    # Dividir paleta en zonas (para 35px de ancho)
    lw $t3, paddleWidth
    
    li $t4, 7    # Zona 1: 0-7px
    blt $t2, $t4, zone1
    li $t4, 14   # Zona 2: 7-14px
    blt $t2, $t4, zone2
    li $t4, 21   # Zona 3: 14-21px
    blt $t2, $t4, zone3
    li $t4, 28   # Zona 4: 21-28px
    blt $t2, $t4, zone4
    j zone5      # Zona 5: 28-35px

zone1:
    li $t0, -2
    sw $t0, ballVelX
    j paddle_angle_done

zone2:
    li $t0, -1
    sw $t0, ballVelX
    j paddle_angle_done

zone3:
    li $t0, 0
    sw $t0, ballVelX
    j paddle_angle_done

zone4:
    li $t0, 1
    sw $t0, ballVelX
    j paddle_angle_done

zone5:
    li $t0, 2
    sw $t0, ballVelX

paddle_angle_done:
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra

# ==================== ACTUALIZAR PELOTA EN MATRIZ ====================
updateBallInMatrix:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    
    # LIMPIAR posición anterior de la pelota (6x6 área)
    jal clearPreviousBallPosition
    
    # Registrar nueva posición (6x6 área)
    lw $a0, ballX
    lw $a1, ballY
    li $a2, 6                   # width
    li $a3, 6                   # height
    lw $t0, OBJ_BALL
    jal fillRectInMatrix
    
update_ball_end:
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra

# ==================== LIMPIAR POSICIÓN ANTERIOR DE PELOTA ====================
clearPreviousBallPosition:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Calcular posición anterior (antes del movimiento)
    lw $t0, ballX
    lw $t1, ballVelX
    sub $a0, $t0, $t1          # X anterior
    
    lw $t0, ballY
    lw $t1, ballVelY
    sub $a1, $t0, $t1          # Y anterior
    
    # Limpiar área anterior (6x6)
    li $a2, 6                   # width
    li $a3, 6                   # height
    li $t0, 0                   # OBJ_EMPTY
    jal fillRectInMatrix
    
clear_prev_end:
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra

# ==================== DESTRUIR BLOQUE EN MATRIZ ====================
destroyBlockInMatrix:
    # $a0 = ID del bloque a destruir
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Buscar el bloque en la matriz y marcarlo como vacío
    lw $t0, collisionMatrix
    li $t1, 0                   # Contador
    
search_destroy_loop:
    bge $t1, 65536, search_destroy_end
    
    lb $t2, 0($t0)             # Leer ID actual
    beq $t2, $a0, found_destroy  # Si coincide, encontramos el bloque
    
    addiu $t0, $t0, 1
    addiu $t1, $t1, 1
    j search_destroy_loop

found_destroy:
    # Marcar como vacío
    sb $zero, 0($t0)
    
    # Actualizar contadores
    lw $t3, blocksRemaining
    addi $t3, $t3, -1
    sw $t3, blocksRemaining
    
    lw $t3, score
    addi $t3, $t3, 10
    sw $t3, score

search_destroy_end:
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra

# ==================== PERDER PELOTA ====================
lostBall:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    
    lw $t0, lives
    addi $t0, $t0, -1
    sw $t0, lives
    
    # Mostrar vidas restantes
    li $v0, 4
    la $a0, msgLives
    syscall
    
    li $v0, 1
    lw $a0, lives
    syscall
    
    li $v0, 11
    li $a0, '\n'
    syscall
    
    bgtz $t0, respawn
    
    # Game Over
    li $v0, 4
    la $a0, msgGameOver
    syscall
    
    li $v0, 4
    la $a0, msgScore
    syscall
    
    li $v0, 1
    lw $a0, score
    syscall
    
    li $v0, 11
    li $a0, '\n'
    syscall
    
    li $v0, 10
    syscall

respawn:
    # Resetear posiciones
    li $t0, 128
    sw $t0, ballX
    li $t0, 120
    sw $t0, ballY
    li $t0, 1
    sw $t0, ballVelX
    li $t0, -1
    sw $t0, ballVelY
    
    # Pausa breve
    li $v0, 32
    li $a0, 1000
    syscall
    
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra