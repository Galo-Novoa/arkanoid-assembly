.data
    # ==================== CONFIGURACIÓN ====================
    displayAddress: .word 0x10008000
    screenWidth: .word 64
    screenHeight: .word 64
    
    # ==================== COLORES ====================
    bgColor: .word 0x00000000       # Negro
    paddleColor: .word 0x00FFFFFF   # Blanco brillante
    ballColor: .word 0x00FF0000     # Rojo
    blockColor1: .word 0x00FF00FF   # Magenta
    blockColor2: .word 0x0000FFFF   # Cyan
    blockColor3: .word 0x00FFFF00   # Amarillo
    blockColor4: .word 0x0000FF00   # Verde
    
    # ==================== PALETA (TAMAÑO REDUCIDO) ====================
    paddleX: .word 26               # Centrada (64/2 - 12/2 = 26)
    paddleY: .word 56               # Cerca del fondo
    paddleWidth: .word 12           # Ancho moderado (antes era 24)
    paddleHeight: .word 3           # Altura moderada (antes era 4)
    paddleSpeed: .word 3            # Velocidad de movimiento
    
    # ==================== PELOTA ====================
    ballX: .word 32
    ballY: .word 30
    ballVelX: .word 1
    ballVelY: .word -1
    
    # ==================== BLOQUES ====================
    blockWidth: .word 5
    blockHeight: .word 2
    blocksPerRow: .word 10
    blockRows: .word 4
    blockStartX: .word 2
    blockStartY: .word 4
    
    blocks: .word 1,1,1,1,1,1,1,1,1,1
            .word 1,1,1,1,1,1,1,1,1,1
            .word 1,1,1,1,1,1,1,1,1,1
            .word 1,1,1,1,1,1,1,1,1,1
    
    blocksRemaining: .word 40
    
    # ==================== SISTEMA ====================
    score: .word 0
    lives: .word 3
    
    # ==================== MENSAJES ====================
    msgGameOver: .asciiz "\n=== GAME OVER ===\n"
    msgWin: .asciiz "\n=== VICTORIA ===\n"
    msgScore: .asciiz "Puntuacion final: "
    msgLives: .asciiz "\nVidas restantes: "

.text
.globl main

main:
    # Dibujar todos los bloques al inicio
    jal drawAllBlocks
    
mainLoop:
    # Borrar posiciones anteriores
    jal clearPaddle
    jal clearBall
    
    # Procesar entrada y física
    jal checkInput
    jal moveBall
    
    # Dibujar nuevas posiciones
    jal drawPaddle
    jal drawBall
    
    # Verificar victoria
    lw $t0, blocksRemaining
    beqz $t0, gameWon
    
    # Delay para controlar FPS
    li $v0, 32
    li $a0, 50
    syscall
    
    j mainLoop

gameWon:
    li $v0, 4
    la $a0, msgWin
    syscall
    
    li $v0, 4
    la $a0, msgScore
    syscall
    
    li $v0, 1
    lw $a0, score
    syscall
    
    li $v0, 10
    syscall

# ==================== DIBUJAR PALETA ====================
drawPaddle:
    lw $t0, displayAddress
    lw $t1, paddleX
    lw $t2, paddleY
    lw $t3, paddleWidth
    lw $t4, paddleHeight
    lw $t5, paddleColor
    
    li $t7, 0                       # Contador Y

drawPaddle_loopY:
    bge $t7, $t4, drawPaddle_end
    li $t8, 0                       # Contador X

drawPaddle_loopX:
    bge $t8, $t3, drawPaddle_nextY
    
    # Calcular posición actual
    add $t9, $t2, $t7               # Y actual
    add $s0, $t1, $t8               # X actual
    
    # Calcular offset: (y * 64 + x) * 4
    sll $s1, $t9, 6                 # Y * 64
    add $s1, $s1, $s0               # + X
    sll $s1, $s1, 2                 # * 4
    add $s1, $t0, $s1               # + dirección base
    
    # Dibujar píxel
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
    
    # Calcular offset
    sll $t5, $t2, 6                 # Y * 64
    add $t5, $t5, $t1               # + X
    sll $t5, $t5, 2                 # * 4
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

# ==================== MOVER PELOTA ====================
moveBall:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
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
    sub $t1, $zero, $t1             # Invertir velocidad
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
    
    # ===== NUEVO: REBOTE CON ÁNGULO SEGÚN ZONA DE LA PALETA =====
    # v1 contiene la posición relativa en la paleta (0 a paddleWidth-1)
    move $t8, $v1
    
    # Invertir velocidad Y (rebote hacia arriba)
    lw $t1, ballVelY
    sub $t1, $zero, $t1
    sw $t1, ballVelY
    
    # Calcular zona (dividir paleta en 5 zonas)
    lw $t9, paddleWidth             # Ancho total de paleta (12)
    
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
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# ==================== COLISIÓN CON PALETA ====================
# Retorna: v0 = 1 si hay colisión, 0 si no
#          v1 = posición relativa en la paleta (0 a paddleWidth-1)
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
    sub $v1, $t0, $t2               # v1 = ballX - paddleX (0 a paddleWidth-1)
    li $v0, 1
    jr $ra

noPaddleCol:
    li $v0, 0
    li $v1, 0
    jr $ra

# ==================== COLISIÓN CON BLOQUES ====================
checkBlockCollision:
    addi $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s0, 12($sp)
    sw $s1, 8($sp)
    sw $s2, 4($sp)
    sw $s3, 0($sp)
    
    lw $s0, ballX
    lw $s1, ballY
    
    li $t0, 0                       # Fila actual
    lw $t1, blockRows

checkBlock_row:
    bge $t0, $t1, noBlockCol
    li $t2, 0                       # Columna actual
    lw $t3, blocksPerRow

checkBlock_col:
    bge $t2, $t3, checkBlock_nextRow
    
    # Calcular índice en array: (fila * 10 + col) * 4
    sll $t4, $t0, 3                 # fila * 8
    sll $t5, $t0, 1                 # fila * 2
    add $t4, $t4, $t5               # fila * 10
    add $t4, $t4, $t2               # + col
    sll $t4, $t4, 2                 # * 4 (bytes)
    
    la $t5, blocks
    add $t5, $t5, $t4
    lw $t6, 0($t5)
    
    # Si el bloque ya está destruido (0), saltar
    beqz $t6, checkBlock_next
    
    # Calcular posición del bloque
    lw $t7, blockStartX
    sll $t8, $t2, 2                 # col * 4
    sll $t9, $t2, 1                 # col * 2
    add $t8, $t8, $t9               # col * 6
    add $s2, $t7, $t8               # X del bloque
    
    lw $t7, blockStartY
    add $t8, $t0, $t0               # fila * 2
    add $t8, $t8, $t0               # fila * 3
    add $s3, $t7, $t8               # Y del bloque
    
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
    sw $zero, 0($t5)                # Destruir bloque
    
    lw $t6, blocksRemaining
    addi $t6, $t6, -1
    sw $t6, blocksRemaining
    
    lw $t6, score
    addi $t6, $t6, 10               # +10 puntos
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
    lw $s2, 4($sp)
    lw $s1, 8($sp)
    lw $s0, 12($sp)
    lw $ra, 16($sp)
    addi $sp, $sp, 20
    jr $ra

# ==================== ENTRADA DE TECLADO ====================
checkInput:
    lw $t0, 0xffff0000
    andi $t0, $t0, 0x1
    beqz $t0, input_end
    
    lw $t1, 0xffff0004
    
    # Tecla 'A' o 'a' - Izquierda
    li $t2, 97                      # 'a'
    beq $t1, $t2, moveLeft
    li $t2, 65                      # 'A'
    beq $t1, $t2, moveLeft
    
    # Tecla 'D' o 'd' - Derecha
    li $t2, 100                     # 'd'
    beq $t1, $t2, moveRight
    li $t2, 68                      # 'D'
    beq $t1, $t2, moveRight
    
    j input_end

moveLeft:
    lw $t3, paddleX
    lw $t4, paddleSpeed
    sub $t3, $t3, $t4               # Mover izquierda
    bltz $t3, input_end             # No salir del borde
    sw $t3, paddleX
    j input_end

moveRight:
    lw $t3, paddleX
    lw $t4, paddleSpeed
    add $t3, $t3, $t4               # Mover derecha
    
    lw $t4, screenWidth
    lw $t5, paddleWidth
    sub $t4, $t4, $t5               # Límite derecho
    bgt $t3, $t4, input_end         # No salir del borde
    
    sw $t3, paddleX

input_end:
    jr $ra

# ==================== DIBUJAR TODOS LOS BLOQUES ====================
drawAllBlocks:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    li $s0, 0                       # Fila
    lw $s1, blockRows

drawBlocks_row:
    bge $s0, $s1, drawBlocks_end
    li $s2, 0                       # Columna
    lw $s3, blocksPerRow

drawBlocks_col:
    bge $s2, $s3, drawBlocks_nextRow
    
    # Calcular índice
    sll $t0, $s0, 3
    sll $t1, $s0, 1
    add $t0, $t0, $t1
    add $t0, $t0, $s2
    sll $t0, $t0, 2
    
    la $t1, blocks
    add $t1, $t1, $t0
    lw $t2, 0($t1)
    
    beqz $t2, drawBlocks_skip
    
    move $a0, $s2
    move $a1, $s0
    jal drawBlock

drawBlocks_skip:
    addi $s2, $s2, 1
    j drawBlocks_col

drawBlocks_nextRow:
    addi $s0, $s0, 1
    j drawBlocks_row

drawBlocks_end:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# ==================== DIBUJAR UN BLOQUE ====================
drawBlock:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Calcular posición X
    lw $t0, blockStartX
    sll $t1, $a0, 2
    sll $t2, $a0, 1
    add $t1, $t1, $t2
    add $t4, $t0, $t1
    
    # Calcular posición Y
    lw $t0, blockStartY
    add $t1, $a1, $a1
    add $t1, $t1, $a1
    add $t5, $t0, $t1
    
    # Seleccionar color según fila
    la $t6, blockColor1
    beqz $a1, drawBlock_color
    la $t6, blockColor2
    li $t7, 1
    beq $a1, $t7, drawBlock_color
    la $t6, blockColor3
    li $t7, 2
    beq $a1, $t7, drawBlock_color
    la $t6, blockColor4

drawBlock_color:
    lw $t6, 0($t6)
    
    lw $t0, displayAddress
    lw $t2, blockWidth
    lw $t3, blockHeight
    
    li $s4, 0                       # Contador Y

drawBlock_loopY:
    bge $s4, $t3, drawBlock_end
    li $s5, 0                       # Contador X

drawBlock_loopX:
    bge $s5, $t2, drawBlock_nextY
    
    add $s6, $t5, $s4
    add $s7, $t4, $s5
    
    sll $t7, $s6, 6
    add $t7, $t7, $s7
    sll $t7, $t7, 2
    add $t7, $t0, $t7
    
    sw $t6, 0($t7)
    
    addi $s5, $s5, 1
    j drawBlock_loopX

drawBlock_nextY:
    addi $s4, $s4, 1
    j drawBlock_loopY

drawBlock_end:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# ==================== BORRAR UN BLOQUE ====================
eraseBlock:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    lw $t0, blockStartX
    sll $t1, $a0, 2
    sll $t2, $a0, 1
    add $t1, $t1, $t2
    add $t4, $t0, $t1
    
    lw $t0, blockStartY
    add $t1, $a1, $a1
    add $t1, $t1, $a1
    add $t5, $t0, $t1
    
    lw $t0, displayAddress
    lw $t2, blockWidth
    lw $t3, blockHeight
    lw $t6, bgColor
    
    li $s4, 0

eraseBlock_loopY:
    bge $s4, $t3, eraseBlock_done
    li $s5, 0

eraseBlock_loopX:
    bge $s5, $t2, eraseBlock_nextY
    
    add $s6, $t5, $s4
    add $s7, $t4, $s5
    
    sll $t7, $s6, 6
    add $t7, $t7, $s7
    sll $t7, $t7, 2
    add $t7, $t0, $t7
    
    sw $t6, 0($t7)
    
    addi $s5, $s5, 1
    j eraseBlock_loopX

eraseBlock_nextY:
    addi $s4, $s4, 1
    j eraseBlock_loopY

eraseBlock_done:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra