# ==================== FUNCIONES RÁPIDAS ====================

# ==================== DIBUJAR PALETA RÁPIDO ====================
drawPaddleFast:
    lw $t0, displayAddress
    lw $t1, paddleX
    lw $t2, paddleY
    lw $t3, paddleWidth
    lw $t4, paddleHeight
    lw $t5, paddleColor
    
    li $t7, 0

drawPaddleFast_loopY:
    bge $t7, $t4, drawPaddleFast_end
    li $t8, 0

drawPaddleFast_loopX:
    bge $t8, $t3, drawPaddleFast_nextY
    
    add $t9, $t2, $t7
    add $s0, $t1, $t8
    
    # Calcular offset: (y * 256 + x) * 4
    sll $s1, $t9, 8      # y * 256
    add $s1, $s1, $s0    # + x
    sll $s1, $s1, 2      # * 4
    add $s1, $t0, $s1    # + dirección base
    
    sw $t5, 0($s1)
    
    addi $t8, $t8, 1
    j drawPaddleFast_loopX

drawPaddleFast_nextY:
    addi $t7, $t7, 1
    j drawPaddleFast_loopY

drawPaddleFast_end:
    jr $ra

# ==================== BORRAR PALETA RÁPIDO ====================
clearPaddleFast:
    lw $t0, displayAddress
    lw $t1, paddleX
    lw $t2, paddleY
    lw $t3, paddleWidth
    lw $t4, paddleHeight
    lw $t5, bgColor
    
    li $t7, 0

clearPaddleFast_loopY:
    bge $t7, $t4, clearPaddleFast_end
    li $t8, 0

clearPaddleFast_loopX:
    bge $t8, $t3, clearPaddleFast_nextY
    
    add $t9, $t2, $t7
    add $s0, $t1, $t8
    
    sll $s1, $t9, 8      # y * 256
    add $s1, $s1, $s0    # + x
    sll $s1, $s1, 2      # * 4
    add $s1, $t0, $s1    # + dirección base
    
    sw $t5, 0($s1)
    
    addi $t8, $t8, 1
    j clearPaddleFast_loopX

clearPaddleFast_nextY:
    addi $t7, $t7, 1
    j clearPaddleFast_loopY

clearPaddleFast_end:
    jr $ra

# ==================== DIBUJAR PELOTA RÁPIDO ====================
drawBallFast:
    lw $t0, displayAddress
    lw $t1, ballX
    lw $t2, ballY
    lw $t3, ballColor
    
    # Dibujar pelota de 6x6 píxeles
    li $t4, 0  # offset Y
    
draw_ball_y:
    li $t5, 0  # offset X
    
draw_ball_x:
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
    blt $t5, $t9, draw_ball_x
    
    addi $t4, $t4, 1
    li $t9, 6
    blt $t4, $t9, draw_ball_y
    
    jr $ra

# ==================== BORRAR PELOTA RÁPIDO ====================
clearBallFast:
    lw $t0, displayAddress
    lw $t1, ballX
    lw $t2, ballY
    lw $t3, bgColor
    
    # Borrar área de 6x6 píxeles
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