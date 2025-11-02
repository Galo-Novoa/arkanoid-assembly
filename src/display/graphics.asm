.text
# ==================== DIBUJAR PALETA ====================
drawPaddle:
    lw $t0, displayAddress
    lw $t1, paddleX
    lw $t2, paddleY
    lw $t3, paddleWidth
    lw $t4, paddleHeight
    lw $t5, paddleColor
    
    li $t7, 0

drawPaddle_loopY:
    bge $t7, $t4, drawPaddle_end
    li $t8, 0

drawPaddle_loopX:
    bge $t8, $t3, drawPaddle_nextY
    
    add $t9, $t2, $t7
    add $s0, $t1, $t8
    
    sll $s1, $t9, 6
    add $s1, $s1, $s0
    sll $s1, $s1, 2
    add $s1, $t0, $s1
    
    sw $t5, 0($s1)
    
    addi $t8, $t8, 1
    j drawPaddle_loopX

drawPaddle_nextY:
    addi $t7, $t7, 1
    j drawPaddle_loopY

drawPaddle_end:
    jr $ra

# ==================== BORRAR PALETA ====================
clearPaddle:
    lw $t0, displayAddress
    lw $t1, paddleX
    lw $t2, paddleY
    lw $t3, paddleWidth
    lw $t4, paddleHeight
    lw $t5, bgColor
    
    li $t7, 0

clearPaddle_loopY:
    bge $t7, $t4, clearPaddle_end
    li $t8, 0

clearPaddle_loopX:
    bge $t8, $t3, clearPaddle_nextY
    
    add $t9, $t2, $t7
    add $s0, $t1, $t8
    
    sll $s1, $t9, 6
    add $s1, $s1, $s0
    sll $s1, $s1, 2
    add $s1, $t0, $s1
    
    sw $t5, 0($s1)
    
    addi $t8, $t8, 1
    j clearPaddle_loopX

clearPaddle_nextY:
    addi $t7, $t7, 1
    j clearPaddle_loopY

clearPaddle_end:
    jr $ra

# ==================== DIBUJAR PELOTA ====================
drawBall:
    lw $t0, displayAddress
    lw $t1, ballX
    lw $t2, ballY
    lw $t3, ballColor
    
    sll $t5, $t2, 6
    add $t5, $t5, $t1
    sll $t5, $t5, 2
    add $t5, $t0, $t5
    
    sw $t3, 0($t5)
    jr $ra

# ==================== BORRAR PELOTA ====================
clearBall:
    lw $t0, displayAddress
    lw $t1, ballX
    lw $t2, ballY
    lw $t3, bgColor
    
    sll $t5, $t2, 6
    add $t5, $t5, $t1
    sll $t5, $t5, 2
    add $t5, $t0, $t5
    
    sw $t3, 0($t5)
    jr $ra