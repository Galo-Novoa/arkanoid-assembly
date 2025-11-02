# ==================== MOVER PELOTA ====================
moveBall:
    push_ra()
    
    # ========== MOVIMIENTO HORIZONTAL ==========
    lw $t0, ballX
    lw $t1, ballVelX
    add $t0, $t0, $t1
    
    # Rebote en paredes laterales
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
    
    # ========== MOVIMIENTO VERTICAL ==========
    lw $t0, ballY
    lw $t1, ballVelY
    add $t0, $t0, $t1
    
    # Rebote en techo
    bltz $t0, bounceY
    
    # Verificar si cayó al fondo (perder vida)
    lw $t2, screenHeight
    addi $t2, $t2, -1
    bgt $t0, $t2, lostBall
    
    sw $t0, ballY
    
    # Verificar colisión con paleta
    jal checkPaddleCollision
    beqz $v0, checkBlocks
    
    # REBOTE CON ÁNGULO SEGÚN ZONA DE LA PALETA
    move $t8, $v1
    
    # Invertir velocidad Y (rebote hacia arriba)
    lw $t1, ballVelY
    sub $t1, $zero, $t1
    sw $t1, ballVelY
    
    # Calcular zona (dividir paleta en 5 zonas)
    lw $t9, paddleWidth
    
    # Zona 1: Extremo izquierdo (0-1) -> velX = -2
    li $t0, 2
    blt $t8, $t0, zone1
    
    # Zona 2: Izquierda (2-4) -> velX = -1
    li $t0, 5
    blt $t8, $t0, zone2
    
    # Zona 3: Centro (5-6) -> velX = 0
    li $t0, 7
    blt $t8, $t0, zone3
    
    # Zona 4: Derecha (7-9) -> velX = 1
    li $t0, 10
    blt $t8, $t0, zone4
    
    # Zona 5: Extremo derecho (10-11) -> velX = 2
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
    # +1 punto por rebote
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
    # Perder una vida
    lw $t0, lives
    addi $t0, $t0, -1
    sw $t0, lives
    
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
    
    li $v0, 10
    syscall

respawn:
    # Mostrar vidas restantes
    li $v0, 4
    la $a0, msgLives
    syscall
    
    li $v0, 1
    lw $a0, lives
    syscall
    
    # Resetear posiciones
    li $t0, 32
    sw $t0, ballX
    li $t0, 30
    sw $t0, ballY
    li $t0, 1
    sw $t0, ballVelX
    li $t0, -1
    sw $t0, ballVelY
    
    # Centrar paleta
    li $t0, 26
    sw $t0, paddleX
    
    # Pausa de 2 segundos
    li $v0, 32
    li $a0, 2000
    syscall
    
    j moveBall_end

checkBlocks:
    jal checkBlockCollision

moveBall_end:
    pop_ra()
    jr $ra