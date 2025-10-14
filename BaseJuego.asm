.data
    # Configuración del display bitmap
    displayAddress: .word 0x10008000
    pixelColor: .word 0x00FF0000    # Color rojo (rectángulo)
    ballColor: .word 0x00FFFFFF     # Color blanco (píxel/bola)
    bgColor: .word 0x00000000       # Color negro (fondo)
    
    # Colores de bloques (diferentes niveles)
    blockColor1: .word 0x00FF00FF   # Magenta
    blockColor2: .word 0x0000FFFF   # Cyan
    blockColor3: .word 0x00FFFF00   # Amarillo
    blockColor4: .word 0x0000FF00   # Verde
    
    # Posición del rectángulo (esquina superior izquierda)
    posX: .word 30                  # Posición X inicial (centro)
    posY: .word 14                  # Posición Y inicial (centro)
    
    # Dimensiones del rectángulo
    rectWidth: .word 4              # Ancho del rectángulo
    rectHeight: .word 4             # Alto del rectángulo
    
    # Dimensiones del display (configuración común: 64x64 o 128x128)
    screenWidth: .word 64
    screenHeight: .word 64
    
    # Posición del píxel que rebota
    ballX: .word 32
    ballY: .word 20
    
    # Velocidad del píxel
    ballVelX: .word 1
    ballVelY: .word -1
    
    # Semilla para números aleatorios
    randomSeed: .word 12345
    
    # Mensajes
    gameOverMsg: .asciiz "\n\n¡GAME OVER! Perdiste todas las vidas.\n"
    winMsg: .asciiz "\n\n¡FELICITACIONES! ¡Destruiste todos los bloques!\n"
    finalScoreMsg: .asciiz "Puntuación final: "
    livesMsg: .asciiz "Vidas: "
    lostLifeMsg: .asciiz "\n¡Perdiste una vida! "
    
    # Puntuación
    score: .word 0
    lives: .word 3
    
    # Configuración de bloques
    blockWidth: .word 6
    blockHeight: .word 3
    blocksPerRow: .word 10
    blockRows: .word 4
    blockStartX: .word 2
    blockStartY: .word 4
    blockSpacingX: .word 1
    blockSpacingY: .word 1
    
    # Array de bloques (1 = existe, 0 = destruido)
    # 10 bloques por fila x 4 filas = 40 bloques
    blocks: .word 1,1,1,1,1,1,1,1,1,1
            .word 1,1,1,1,1,1,1,1,1,1
            .word 1,1,1,1,1,1,1,1,1,1
            .word 1,1,1,1,1,1,1,1,1,1
    
    blocksRemaining: .word 40

.text
.globl main

main:
    # Inicialización
    li $v0, 4
    
    # Dibujar bloques iniciales
    jal drawAllBlocks
    
mainLoop:
    # Borrar píxel anterior
    jal clearPixel
    
    # Borrar bola anterior
    jal clearBall
    
    # Leer entrada del teclado
    jal checkInput
    
    # Mover la bola
    jal moveBall
    
    # Dibujar píxel en nueva posición
    jal drawPixel
    
    # Dibujar bola
    jal drawBall
    
    # Verificar si ganó (todos los bloques destruidos)
    lw $t0, blocksRemaining
    beqz $t0, gameWon
    
    # Pequeña pausa
    li $v0, 32
    li $a0, 50
    syscall
    
    # Continuar el bucle
    j mainLoop
    
gameWon:
    # Mensaje de victoria
    li $v0, 4
    la $a0, winMsg
    syscall
    
    li $v0, 4
    la $a0, finalScoreMsg
    syscall
    
    li $v0, 1
    lw $a0, score
    syscall
    
    # Terminar programa
    li $v0, 10
    syscall

# Función para dibujar el rectángulo
drawPixel:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    lw $t7, posY           # Y inicial
    lw $t8, rectHeight     # Altura
    add $t8, $t8, $t7      # Y final
    
drawPixel_loopY:
    bge $t7, $t8, drawPixel_end    # Si Y >= Y_final, terminar
    
    lw $t9, posX           # X inicial
    lw $s0, rectWidth      # Ancho
    add $s0, $s0, $t9      # X final
    
drawPixel_loopX:
    bge $t9, $s0, drawPixel_nextY  # Si X >= X_final, siguiente fila
    
    # Calcular dirección: base + (y * ancho + x) * 4
    lw $t0, displayAddress
    lw $t3, screenWidth
    
    mul $t4, $t7, $t3      # y * ancho
    add $t4, $t4, $t9      # + x
    sll $t4, $t4, 2        # * 4 (bytes por píxel)
    
    # Dirección final
    add $t5, $t0, $t4
    
    # Dibujar píxel
    lw $t6, pixelColor
    sw $t6, 0($t5)
    
    addi $t9, $t9, 1       # Incrementar X
    j drawPixel_loopX
    
drawPixel_nextY:
    addi $t7, $t7, 1       # Incrementar Y
    j drawPixel_loopY
    
drawPixel_end:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Función para borrar el rectángulo
clearPixel:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    lw $t7, posY           # Y inicial
    lw $t8, rectHeight     # Altura
    add $t8, $t8, $t7      # Y final
    
clearPixel_loopY:
    bge $t7, $t8, clearPixel_end    # Si Y >= Y_final, terminar
    
    lw $t9, posX           # X inicial
    lw $s0, rectWidth      # Ancho
    add $s0, $s0, $t9      # X final
    
clearPixel_loopX:
    bge $t9, $s0, clearPixel_nextY  # Si X >= X_final, siguiente fila
    
    # Calcular dirección: base + (y * ancho + x) * 4
    lw $t0, displayAddress
    lw $t3, screenWidth
    
    mul $t4, $t7, $t3      # y * ancho
    add $t4, $t4, $t9      # + x
    sll $t4, $t4, 2        # * 4 (bytes por píxel)
    
    # Dirección final
    add $t5, $t0, $t4
    
    # Borrar píxel (pintar de negro)
    lw $t6, bgColor
    sw $t6, 0($t5)
    
    addi $t9, $t9, 1       # Incrementar X
    j clearPixel_loopX
    
clearPixel_nextY:
    addi $t7, $t7, 1       # Incrementar Y
    j clearPixel_loopY
    
clearPixel_end:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Función para verificar entrada del teclado
checkInput:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Verificar si hay tecla presionada
    lw $t0, 0xffff0000
    andi $t0, $t0, 0x0001
    beqz $t0, checkInput_end
    
    # Leer carácter
    lw $t1, 0xffff0004
    
    # Verificar tecla 'a' o 'A' (izquierda)
    li $t2, 97          # 'a'
    beq $t1, $t2, moveLeft
    li $t2, 65          # 'A'
    beq $t1, $t2, moveLeft
    
    # Verificar tecla 'd' o 'D' (derecha)
    li $t2, 100         # 'd'
    beq $t1, $t2, moveRight
    li $t2, 68          # 'D'
    beq $t1, $t2, moveRight
    
    j checkInput_end

moveLeft:
    # Mover a la izquierda (decrementar X)
    lw $t3, posX
    beqz $t3, checkInput_end    # No mover si está en el borde
    addi $t3, $t3, -1
    sw $t3, posX
    j checkInput_end

moveRight:
    # Mover a la derecha (incrementar X)
    lw $t3, posX
    lw $t4, screenWidth
    lw $t5, rectWidth
    sub $t4, $t4, $t5      # Límite = ancho_pantalla - ancho_rect
    bge $t3, $t4, checkInput_end    # No mover si está en el borde
    addi $t3, $t3, 1
    sw $t3, posX
    j checkInput_end

checkInput_end:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Función para dibujar la bola
drawBall:
    lw $t0, displayAddress
    lw $t1, ballX
    lw $t2, ballY
    lw $t3, screenWidth
    
    # Calcular offset: (y * ancho + x) * 4
    mul $t4, $t2, $t3
    add $t4, $t4, $t1
    sll $t4, $t4, 2
    
    # Dirección final
    add $t5, $t0, $t4
    
    # Dibujar bola
    lw $t6, ballColor
    sw $t6, 0($t5)
    
    jr $ra

# Función para borrar la bola
clearBall:
    lw $t0, displayAddress
    lw $t1, ballX
    lw $t2, ballY
    lw $t3, screenWidth
    
    # Calcular offset
    mul $t4, $t2, $t3
    add $t4, $t4, $t1
    sll $t4, $t4, 2
    
    # Dirección final
    add $t5, $t0, $t4
    
    # Borrar bola
    lw $t6, bgColor
    sw $t6, 0($t5)
    
    jr $ra

# Función para mover la bola
moveBall:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Actualizar posición X
    lw $t0, ballX
    lw $t1, ballVelX
    add $t0, $t0, $t1
    
    # Verificar colisión con bordes izquierdo/derecho
    bltz $t0, moveBall_bounceX    # Si X < 0
    lw $t2, screenWidth
    addi $t2, $t2, -1
    bgt $t0, $t2, moveBall_bounceX    # Si X > ancho-1
    
    # Verificar colisión con el rectángulo (borde izquierdo y derecho)
    lw $t3, posX
    lw $t4, rectWidth
    add $t4, $t4, $t3              # X_final del rectángulo
    lw $t5, ballY
    lw $t6, posY
    lw $t7, rectHeight
    add $t7, $t7, $t6              # Y_final del rectángulo
    
    # Verificar si la bola está en el rango Y del rectángulo
    blt $t5, $t6, moveBall_noCollisionX
    bge $t5, $t7, moveBall_noCollisionX
    
    # Verificar colisión con lado izquierdo del rectángulo
    beq $t0, $t3, moveBall_bounceX
    
    # Verificar colisión con lado derecho del rectángulo
    addi $t4, $t4, -1
    beq $t0, $t4, moveBall_bounceX
    
moveBall_noCollisionX:
    sw $t0, ballX
    j moveBall_updateY
    
moveBall_bounceX:
    # Invertir velocidad X y generar componente aleatorio
    lw $t1, ballVelX
    neg $t1, $t1
    
    # Añadir pequeña variación aleatoria
    jal random
    andi $v0, $v0, 0x1
    beqz $v0, moveBall_noRandomX
    
    # 50% de probabilidad de cambiar velocidad Y también
    lw $t8, ballVelY
    neg $t8, $t8
    sw $t8, ballVelY
    
moveBall_noRandomX:
    sw $t1, ballVelX
    
    # Corregir posición
    lw $t0, ballX
    bltz $t0, moveBall_fixLeft
    lw $t2, screenWidth
    addi $t2, $t2, -1
    bgt $t0, $t2, moveBall_fixRight
    j moveBall_updateY
    
moveBall_fixLeft:
    li $t0, 0
    sw $t0, ballX
    j moveBall_updateY
    
moveBall_fixRight:
    lw $t2, screenWidth
    addi $t2, $t2, -1
    sw $t2, ballX
    
moveBall_updateY:
    # Actualizar posición Y
    lw $t0, ballY
    lw $t1, ballVelY
    add $t0, $t0, $t1
    
    # Verificar colisión con bordes superior/inferior
    bltz $t0, moveBall_bounceY    # Si Y < 0
    lw $t2, screenHeight
    addi $t2, $t2, -1
    bgt $t0, $t2, moveBall_bounceY    # Si Y > alto-1
    
    # Verificar colisión con bloques
    sw $t0, ballY    # Guardar temporalmente nueva posición
    jal checkBlockCollision
    beqz $v0, moveBall_noBlockCollision
    
    # Hubo colisión con bloque, rebotar
    lw $t1, ballVelY
    neg $t1, $t1
    sw $t1, ballVelY
    j moveBall_end
    
moveBall_noBlockCollision:
    # Verificar colisión con el rectángulo (borde superior e inferior)
    lw $t0, ballY
    lw $t3, ballX
    lw $t4, posX
    lw $t5, rectWidth
    add $t5, $t5, $t4              # X_final del rectángulo
    lw $t6, posY
    lw $t7, rectHeight
    add $t7, $t7, $t6              # Y_final del rectángulo
    
    # Verificar si la bola está en el rango X del rectángulo
    blt $t3, $t4, moveBall_noCollisionY
    bge $t3, $t5, moveBall_noCollisionY
    
    # Verificar colisión con lado superior del rectángulo
    beq $t0, $t6, moveBall_bounceY
    
    # Verificar colisión con lado inferior del rectángulo
    addi $t7, $t7, -1
    beq $t0, $t7, moveBall_bounceY
    
moveBall_noCollisionY:
    j moveBall_end
    
moveBall_bounceY:
    # Verificar si está rebotando en el fondo (borde inferior)
    lw $t2, screenHeight
    addi $t2, $t2, -1
    lw $t0, ballY
    bge $t0, $t2, moveBall_checkBottom
    
    # Si no es el fondo, rebotar normalmente (borde superior u otros)
    j moveBall_normalBounceY
    
moveBall_checkBottom:
    # Verificar si la bola está sobre el rectángulo
    lw $t3, ballX
    lw $t4, posX
    lw $t5, rectWidth
    add $t5, $t5, $t4              # X_final del rectángulo
    
    # Verificar rango X
    blt $t3, $t4, moveBall_gameOver    # Bola no está sobre el rectángulo
    bge $t3, $t5, moveBall_gameOver    # Bola no está sobre el rectángulo
    
    # Verificar si el rectángulo está cerca del fondo
    lw $t6, posY
    lw $t7, rectHeight
    add $t7, $t7, $t6              # Y_final del rectángulo
    lw $t2, screenHeight
    addi $t2, $t2, -2              # Margen de colisión
    
    blt $t7, $t2, moveBall_gameOver    # Rectángulo muy arriba, no puede salvar
    
    # ¡Rebote exitoso! Incrementar puntuación
    lw $t8, score
    addi $t8, $t8, 1
    sw $t8, score
    
    # Rebotar normalmente
    j moveBall_normalBounceY
    
moveBall_gameOver:
    # Perder una vida
    lw $t8, lives
    addi $t8, $t8, -1
    sw $t8, lives
    
    # Verificar si quedan vidas
    bgtz $t8, moveBall_respawn
    
    # No quedan vidas, terminar juego
    li $v0, 4
    la $a0, gameOverMsg
    syscall
    
    # Mostrar puntuación
    li $v0, 4
    la $a0, finalScoreMsg
    syscall
    
    li $v0, 1
    lw $a0, score
    syscall
    
    # Terminar programa
    li $v0, 10
    syscall
    
moveBall_respawn:
    # Mostrar mensaje de vida perdida
    li $v0, 4
    la $a0, lostLifeMsg
    syscall
    
    li $v0, 4
    la $a0, livesMsg
    syscall
    
    li $v0, 1
    lw $a0, lives
    syscall
    
    # Reiniciar posición de la bola
    li $t0, 32
    sw $t0, ballX
    li $t0, 20
    sw $t0, ballY
    
    # Reiniciar velocidad
    li $t0, 1
    sw $t0, ballVelX
    li $t0, -1
    sw $t0, ballVelY
    
    # Reiniciar posición de la paleta
    li $t0, 30
    sw $t0, posX
    
    # Pausa antes de continuar
    li $v0, 32
    li $a0, 2000
    syscall
    
    # Saltar al final para continuar el juego
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
    
moveBall_normalBounceY:
    # Invertir velocidad Y y generar componente aleatorio
    lw $t1, ballVelY
    neg $t1, $t1
    
    # Añadir pequeña variación aleatoria
    jal random
    andi $v0, $v0, 0x1
    beqz $v0, moveBall_noRandomY
    
    # 50% de probabilidad de cambiar velocidad X también
    lw $t8, ballVelX
    neg $t8, $t8
    sw $t8, ballVelX
    
moveBall_noRandomY:
    sw $t1, ballVelY
    
    # Corregir posición
    lw $t0, ballY
    bltz $t0, moveBall_fixTop
    lw $t2, screenHeight
    addi $t2, $t2, -1
    bgt $t0, $t2, moveBall_fixBottom
    j moveBall_end
    
moveBall_fixTop:
    li $t0, 0
    sw $t0, ballY
    j moveBall_end
    
moveBall_fixBottom:
    lw $t2, screenHeight
    addi $t2, $t2, -1
    sw $t2, ballY
    
moveBall_end:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Función para dibujar todos los bloques
drawAllBlocks:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    li $s0, 0    # Fila actual
    lw $s1, blockRows
    
drawAllBlocks_rowLoop:
    bge $s0, $s1, drawAllBlocks_end
    
    li $s2, 0    # Columna actual
    lw $s3, blocksPerRow
    
drawAllBlocks_colLoop:
    bge $s2, $s3, drawAllBlocks_nextRow
    
    # Verificar si el bloque existe
    mul $t0, $s0, $s3    # fila * bloques_por_fila
    add $t0, $t0, $s2    # + columna
    sll $t0, $t0, 2      # * 4 para offset
    la $t1, blocks
    add $t1, $t1, $t0
    lw $t2, 0($t1)
    
    beqz $t2, drawAllBlocks_skip
    
    # Dibujar el bloque
    move $a0, $s2
    move $a1, $s0
    jal drawBlock
    
drawAllBlocks_skip:
    addi $s2, $s2, 1
    j drawAllBlocks_colLoop
    
drawAllBlocks_nextRow:
    addi $s0, $s0, 1
    j drawAllBlocks_rowLoop
    
drawAllBlocks_end:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Función para dibujar un bloque
# $a0 = columna, $a1 = fila
drawBlock:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Calcular posición del bloque
    lw $t0, blockStartX
    lw $t1, blockWidth
    lw $t2, blockSpacingX
    add $t3, $t1, $t2    # ancho total (bloque + espacio)
    mul $t4, $a0, $t3
    add $t4, $t4, $t0    # X inicial del bloque
    
    lw $t0, blockStartY
    lw $t1, blockHeight
    lw $t2, blockSpacingY
    add $t3, $t1, $t2    # alto total (bloque + espacio)
    mul $t5, $a1, $t3
    add $t5, $t5, $t0    # Y inicial del bloque
    
    # Seleccionar color según la fila
    la $t6, blockColor1
    beq $a1, 0, drawBlock_gotColor
    la $t6, blockColor2
    li $t7, 1
    beq $a1, $t7, drawBlock_gotColor
    la $t6, blockColor3
    li $t7, 2
    beq $a1, $t7, drawBlock_gotColor
    la $t6, blockColor4
    
drawBlock_gotColor:
    lw $t6, 0($t6)
    
    # Dibujar el rectángulo del bloque
    move $s4, $t5    # Y inicial
    lw $s5, blockHeight
    add $s5, $s5, $t5    # Y final
    
drawBlock_loopY:
    bge $s4, $s5, drawBlock_end
    
    move $s6, $t4    # X inicial
    lw $s7, blockWidth
    add $s7, $s7, $t4    # X final
    
drawBlock_loopX:
    bge $s6, $s7, drawBlock_nextY
    
    # Calcular dirección
    lw $t0, displayAddress
    lw $t1, screenWidth
    mul $t2, $s4, $t1
    add $t2, $t2, $s6
    sll $t2, $t2, 2
    add $t0, $t0, $t2
    
    # Dibujar píxel
    sw $t6, 0($t0)
    
    addi $s6, $s6, 1
    j drawBlock_loopX
    
drawBlock_nextY:
    addi $s4, $s4, 1
    j drawBlock_loopY
    
drawBlock_end:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Función para verificar colisión con bloques
# Retorna: $v0 = 1 si hubo colisión, 0 si no
checkBlockCollision:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    lw $t0, ballX
    lw $t1, ballY
    
    li $s0, 0    # Fila actual
    lw $s1, blockRows
    
checkBlock_rowLoop:
    bge $s0, $s1, checkBlock_noCollision
    
    li $s2, 0    # Columna actual
    lw $s3, blocksPerRow
    
checkBlock_colLoop:
    bge $s2, $s3, checkBlock_nextRow
    
    # Verificar si el bloque existe
    mul $t2, $s0, $s3
    add $t2, $t2, $s2
    sll $t2, $t2, 2
    la $t3, blocks
    add $t3, $t3, $t2
    lw $t4, 0($t3)
    
    beqz $t4, checkBlock_skipBlock
    
    # Calcular posición del bloque
    lw $t5, blockStartX
    lw $t6, blockWidth
    lw $t7, blockSpacingX
    add $t8, $t6, $t7
    mul $t8, $s2, $t8
    add $t8, $t8, $t5    # X inicial
    add $t9, $t8, $t6    # X final
    
    lw $t5, blockStartY
    lw $t6, blockHeight
    lw $t7, blockSpacingY
    add $s4, $t6, $t7
    mul $s4, $s0, $s4
    add $s4, $s4, $t5    # Y inicial
    add $s5, $s4, $t6    # Y final
    
    # Verificar si la bola está dentro del bloque
    blt $t0, $t8, checkBlock_skipBlock
    bge $t0, $t9, checkBlock_skipBlock
    blt $t1, $s4, checkBlock_skipBlock
    bge $t1, $s5, checkBlock_skipBlock
    
    # ¡Colisión! Destruir bloque
    sw $zero, 0($t3)
    
    # Borrar bloque de la pantalla
    move $a0, $s2
    move $a1, $s0
    jal eraseBlock
    
    # Incrementar puntuación
    lw $t4, score
    addi $t4, $t4, 10
    sw $t4, score
    
    # Decrementar bloques restantes
    lw $t4, blocksRemaining
    addi $t4, $t4, -1
    sw $t4, blocksRemaining
    
    # Retornar colisión
    li $v0, 1
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
    
checkBlock_skipBlock:
    addi $s2, $s2, 1
    j checkBlock_colLoop
    
checkBlock_nextRow:
    addi $s0, $s0, 1
    j checkBlock_rowLoop
    
checkBlock_noCollision:
    li $v0, 0
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Función para borrar un bloque
# $a0 = columna, $a1 = fila
eraseBlock:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Calcular posición del bloque
    lw $t0, blockStartX
    lw $t1, blockWidth
    lw $t2, blockSpacingX
    add $t3, $t1, $t2
    mul $t4, $a0, $t3
    add $t4, $t4, $t0
    
    lw $t0, blockStartY
    lw $t1, blockHeight
    lw $t2, blockSpacingY
    add $t3, $t1, $t2
    mul $t5, $a1, $t3
    add $t5, $t5, $t0
    
    # Borrar el rectángulo
    move $s4, $t5
    lw $s5, blockHeight
    add $s5, $s5, $t5
    
eraseBlock_loopY:
    bge $s4, $s5, eraseBlock_end
    
    move $s6, $t4
    lw $s7, blockWidth
    add $s7, $s7, $t4
    
eraseBlock_loopX:
    bge $s6, $s7, eraseBlock_nextY
    
    lw $t0, displayAddress
    lw $t1, screenWidth
    mul $t2, $s4, $t1
    add $t2, $t2, $s6
    sll $t2, $t2, 2
    add $t0, $t0, $t2
    
    lw $t6, bgColor
    sw $t6, 0($t0)
    
    addi $s6, $s6, 1
    j eraseBlock_loopX
    
eraseBlock_nextY:
    addi $s4, $s4, 1
    j eraseBlock_loopY
    
eraseBlock_end:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Generador de números pseudo-aleatorios (Linear Congruential Generator)
random:
    lw $t0, randomSeed
    li $t1, 1103515245
    li $t2, 12345
    mul $t0, $t0, $t1
    add $t0, $t0, $t2
    sw $t0, randomSeed
    move $v0, $t0
    jr $ra