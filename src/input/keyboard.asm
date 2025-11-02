# ==================== ENTRADA DE TECLADO ====================
checkInput:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    
    lw $t0, 0xffff0000
    andi $t0, $t0, 0x1
    beqz $t0, input_end
    
    lw $t1, 0xffff0004
    
    li $t2, 97
    beq $t1, $t2, moveLeft
    li $t2, 65
    beq $t1, $t2, moveLeft
    
    li $t2, 100
    beq $t1, $t2, moveRight
    li $t2, 68
    beq $t1, $t2, moveRight
    
    j input_end

moveLeft:
    lw $t3, paddleX
    lw $t4, paddleSpeed
    sub $t3, $t3, $t4
    bltz $t3, input_end
    sw $t3, paddleX
    j input_end

moveRight:
    lw $t3, paddleX
    lw $t4, paddleSpeed
    add $t3, $t3, $t4
    lw $t4, screenWidth
    lw $t5, paddleWidth
    sub $t4, $t4, $t5
    bgt $t3, $t4, input_end
    sw $t3, paddleX

input_end:
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra