# ==================== FUNCIONES RÁPIDAS ====================

# ==================== DIBUJAR PALETA RÁPIDO CON SPRITE ====================
drawPaddleFast:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    
    lw $t0, displayAddress
    lw $t1, paddleX
    lw $t2, paddleY
    la $t3, paddle_sprite      # Dirección del sprite
    
    # Tamaño del sprite (35x9)
    li $t4, 35                 # ancho
    li $t5, 9                  # alto
    
    li $t7, 0                  # contador filas

drawPaddleFast_loopY:
    bge $t7, $t5, drawPaddleFast_end
    li $t8, 0                  # contador columnas

drawPaddleFast_loopX:
    bge $t8, $t4, drawPaddleFast_nextY
    
    # Calcular posición en pantalla
    add $t9, $t2, $t7          # Y + offset_y
    add $s0, $t1, $t8          # X + offset_x
    
    # Calcular offset en display: (y * 256 + x) * 4
    sll $s1, $t9, 8            # y * 256
    add $s1, $s1, $s0          # + x
    sll $s1, $s1, 2            # * 4
    add $s1, $t0, $s1          # + dirección base
    
    # Calcular posición en sprite: (y * sprite_width + x) * 4
    mul $s2, $t7, 35           # y * 35
    add $s2, $s2, $t8          # + x
    sll $s2, $s2, 2            # * 4
    add $s2, $t3, $s2          # + dirección sprite
    
    # Cargar color del sprite
    lw $s3, 0($s2)
    
    # Solo dibujar si no es transparente (negro)
    li $s4, 0x000000
    beq $s3, $s4, drawPaddleFast_skip
    
    # Dibujar pixel
    sw $s3, 0($s1)

drawPaddleFast_skip:
    addi $t8, $t8, 1
    j drawPaddleFast_loopX

drawPaddleFast_nextY:
    addi $t7, $t7, 1
    j drawPaddleFast_loopY

drawPaddleFast_end:
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra

# ==================== BORRAR PALETA RÁPIDO ====================
clearPaddleFast:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    
    lw $t0, displayAddress
    lw $t1, paddleX
    lw $t2, paddleY
    lw $t3, bgColor
    
    # Tamaño del sprite (35x9)
    li $t4, 35                 # ancho
    li $t5, 9                  # alto
    
    li $t7, 0                  # contador filas

clearPaddleFast_loopY:
    bge $t7, $t5, clearPaddleFast_end
    li $t8, 0                  # contador columnas

clearPaddleFast_loopX:
    bge $t8, $t4, clearPaddleFast_nextY
    
    # Calcular posición en pantalla
    add $t9, $t2, $t7          # Y + offset_y
    add $s0, $t1, $t8          # X + offset_x
    
    # Calcular offset en display: (y * 256 + x) * 4
    sll $s1, $t9, 8            # y * 256
    add $s1, $s1, $s0          # + x
    sll $s1, $s1, 2            # * 4
    add $s1, $t0, $s1          # + dirección base
    
    # Borrar pixel
    sw $t3, 0($s1)
    
    addi $t8, $t8, 1
    j clearPaddleFast_loopX

clearPaddleFast_nextY:
    addi $t7, $t7, 1
    j clearPaddleFast_loopY

clearPaddleFast_end:
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra

# ==================== DIBUJAR PELOTA CON SPRITE ====================
drawBallFast:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    
    lw $t0, displayAddress
    lw $t1, ballX
    lw $t2, ballY
    la $t3, ball_sprite         # Dirección del sprite
    
    # Tamaño del sprite (6x6)
    li $t4, 6                  # ancho
    li $t5, 6                  # alto
    
    li $t7, 0                  # contador filas

draw_ball_sprite_y:
    bge $t7, $t5, draw_ball_sprite_end
    li $t8, 0                  # contador columnas

draw_ball_sprite_x:
    bge $t8, $t4, draw_ball_sprite_next_y
    
    # Calcular posición en pantalla
    add $t9, $t2, $t7          # Y + offset_y
    add $s0, $t1, $t8          # X + offset_x
    
    # Calcular offset en display: (y * 256 + x) * 4
    sll $s1, $t9, 8            # y * 256
    add $s1, $s1, $s0          # + x
    sll $s1, $s1, 2            # * 4
    add $s1, $t0, $s1          # + dirección base
    
    # Calcular posición en sprite: (y * 6 + x) * 4
    mul $s2, $t7, 6            # y * 6
    add $s2, $s2, $t8          # + x
    sll $s2, $s2, 2            # * 4
    add $s2, $t3, $s2          # + dirección sprite
    
    # Cargar color del sprite
    lw $s3, 0($s2)
    
    # Solo dibujar si no es transparente (negro)
    li $s4, 0x000000
    beq $s3, $s4, draw_ball_sprite_skip
    
    # Dibujar pixel
    sw $s3, 0($s1)

draw_ball_sprite_skip:
    addi $t8, $t8, 1
    j draw_ball_sprite_x

draw_ball_sprite_next_y:
    addi $t7, $t7, 1
    j draw_ball_sprite_y

draw_ball_sprite_end:
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra

# ==================== BORRAR PELOTA RÁPIDO ====================
clearBallFast:
    lw $t0, displayAddress
    lw $t1, ballX
    lw $t2, ballY
    lw $t3, bgColor
    
    # Borrar área de 6x6 píxeles (tamaño del sprite)
    li $t4, 0  # offset Y
    
clear_ball_y:
    li $t5, 0  # offset X
    
clear_ball_x:
    add $t6, $t2, $t4  # Y + offset
    add $t7, $t1, $t5  # X + offset
    
    # Calcular offset: (y * 256 + x) * 4
    sll $t8, $t6, 8      # y * 256
    add $t8, $t8, $t7    # + x
    sll $t8, $t8, 2      # * 4
    add $t8, $t0, $t8    # + dirección base
    
    sw $t3, 0($t8)
    
    addi $t5, $t5, 1
    li $t9, 6
    blt $t5, $t9, clear_ball_x
    
    addi $t4, $t4, 1
    li $t9, 6
    blt $t4, $t9, clear_ball_y
    
    jr $ra