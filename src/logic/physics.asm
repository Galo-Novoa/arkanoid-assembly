.text
# ==================== MOVER PELOTA ====================
moveBall:
    push_ra()
    
    lw $t0, ballX
    lw $t1, ballVelX
    add $t0, $t0, $t1
    
    bltz $t0, bounceX
    lw $t2, screenWidth
    addi $t2, $t2, -1
    bgt $t0, $t2, bounceX
    j saveX

bounceX:
    lw $t1, ballVelX
    sub $t1, $zero, $t1
    sw $t1, ballVelX
    
    bltz $t0, fixLeft
    lw $t2, screenWidth
    addi $t0, $t2, -1
    j saveX

fixLeft:
    li $t0, 0

saveX:
    sw $t0, ballX
    
    lw $t0, ballY
    lw $t1, ballVelY
    add $t0, $t0, $t1
    
    bltz $t0, bounceY
    lw $t2, screenHeight
    addi $t2, $t2, -1
    bgt $t0, $t2, lostBall
    
    sw $t0, ballY
    jal checkPaddleCollision
    beqz $v0, checkBlocks
    
    move $t8, $v1
    lw $t1, ballVelY
    sub $t1, $zero, $t1
    sw $t1, ballVelY
    
    lw $t9, paddleWidth
    li $t0, 2
    blt $t8, $t0, zone1
    li $t0, 5
    blt $t8, $t0, zone2
    li $t0, 7
    blt $t8, $t0, zone3
    li $t0, 10
    blt $t8, $t0, zone4
    j zone5

zone1:
    li $t0, -2
    sw $t0, ballVelX
    j paddleBounce_done

zone2:
    li $t0, -1
    sw $t0, ballVelX
    j paddleBounce_done

zone3:
    li $t0, 0
    sw $t0, ballVelX
    j paddleBounce_done

zone4:
    li $t0, 1
    sw $t0, ballVelX
    j paddleBounce_done

zone5:
    li $t0, 2
    sw $t0, ballVelX

paddleBounce_done:
    lw $t2, score
    addi $t2, $t2, 1
    sw $t2, score
    j checkBlocks

bounceY:
    lw $t1, ballVelY
    sub $t1, $zero, $t1
    sw $t1, ballVelY
    li $t0, 0
    sw $t0, ballY
    j checkBlocks

lostBall:
    lw $t0, lives
    addi $t0, $t0, -1
    sw $t0, lives
    bgtz $t0, respawn
    
    li $v0, 4
    la $a0, msgGameOver
    syscall
    li $v0, 4
    la $a0, msgScore
    syscall
    li $v0, 1
    lw $a0, score
    syscall
    li $v0, 10
    syscall

respawn:
    li $v0, 4
    la $a0, msgLives
    syscall
    li $v0, 1
    lw $a0, lives
    syscall
    
    li $t0, 32
    sw $t0, ballX
    li $t0, 30
    sw $t0, ballY
    li $t0, 1
    sw $t0, ballVelX
    li $t0, -1
    sw $t0, ballVelY
    
    li $t0, 26
    sw $t0, paddleX
    
    li $v0, 32
    li $a0, 2000
    syscall
    
    j moveBall_end

checkBlocks:
    jal checkBlockCollision

moveBall_end:
    pop_ra()
    jr $ra
