# ==================== COLISIÓN CON PALETA ====================
checkPaddleCollision:
    lw $t0, ballX
    lw $t1, ballY
    lw $t2, paddleX
    lw $t3, paddleY
    lw $t4, paddleWidth
    lw $t5, paddleHeight
    
    # Verificar rango Y
    blt $t1, $t3, noPaddleCol
    add $t6, $t3, $t5
    bge $t1, $t6, noPaddleCol
    
    # Verificar rango X
    blt $t0, $t2, noPaddleCol
    add $t6, $t2, $t4
    bge $t0, $t6, noPaddleCol
    
    # ¡COLISIÓN! Calcular posición relativa
    sub $v1, $t0, $t2
    li $v0, 1
    jr $ra

noPaddleCol:
    li $v0, 0
    li $v1, 0
    jr $ra

# ==================== COLISIÓN CON BLOQUES ====================
checkBlockCollision:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    addiu $sp, $sp, -4
    sw $s0, 0($sp)
    addiu $sp, $sp, -4
    sw $s1, 0($sp)
    addiu $sp, $sp, -4
    sw $s2, 0($sp)
    addiu $sp, $sp, -4
    sw $s3, 0($sp)
    
    lw $s0, ballX
    lw $s1, ballY
    
    li $t0, 0
    lw $t1, blockRows

checkBlock_row:
    bge $t0, $t1, noBlockCol
    li $t2, 0
    lw $t3, blocksPerRow

checkBlock_col:
    bge $t2, $t3, checkBlock_nextRow
    
    # Calcular índice en array: (fila * 10 + col) * 4
    mul $t4, $t0, 10
    add $t4, $t4, $t2
    sll $t4, $t4, 2
    
    la $t5, blocks
    add $t5, $t5, $t4
    lw $t6, 0($t5)
    
    # Si el bloque ya está destruido (0), saltar
    beqz $t6, checkBlock_next
    
    # Calcular posición del bloque
    lw $t7, blockStartX
    mul $t8, $t2, 6
    add $s2, $t7, $t8
    
    lw $t7, blockStartY
    mul $t8, $t0, 3
    add $s3, $t7, $t8
    
    # Verificar colisión X
    blt $s0, $s2, checkBlock_next
    lw $t8, blockWidth
    add $t9, $s2, $t8
    bge $s0, $t9, checkBlock_next
    
    # Verificar colisión Y
    blt $s1, $s3, checkBlock_next
    lw $t8, blockHeight
    add $t9, $s3, $t8
    bge $s1, $t9, checkBlock_next
    
    # ¡COLISIÓN CON BLOQUE!
    sw $zero, 0($t5)
    
    lw $t6, blocksRemaining
    addi $t6, $t6, -1
    sw $t6, blocksRemaining
    
    lw $t6, score
    addi $t6, $t6, 10
    sw $t6, score
    
    # Borrar el bloque visualmente
    move $a0, $t2
    move $a1, $t0
    jal eraseBlock
    
    # Invertir velocidad Y (rebote)
    lw $t6, ballVelY
    sub $t6, $zero, $t6
    sw $t6, ballVelY
    
    j blockCol_end

checkBlock_next:
    addi $t2, $t2, 1
    j checkBlock_col

checkBlock_nextRow:
    addi $t0, $t0, 1
    j checkBlock_row

noBlockCol:
blockCol_end:
    lw $s3, 0($sp)
    addiu $sp, $sp, 4
    lw $s2, 0($sp)
    addiu $sp, $sp, 4
    lw $s1, 0($sp)
    addiu $sp, $sp, 4
    lw $s0, 0($sp)
    addiu $sp, $sp, 4
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra