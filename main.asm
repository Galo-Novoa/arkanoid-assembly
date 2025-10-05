.data
    # Configuración del display bitmap
    displayAddress: .word 0x10008000
    pixelColor: .word 0x00FF0000    # Color rojo
    bgColor: .word 0x00000000       # Color negro (fondo)
    
    # Posición del píxel
    posX: .word 32                  # Posición X inicial (centro)
    posY: .word 16                  # Posición Y inicial (centro)
    
    # Dimensiones del display (configuración común: 64x64 o 128x128)
    screenWidth: .word 64
    screenHeight: .word 64

.text
.globl main

main:
    # Inicialización
    li $v0, 4
    
mainLoop:
    # Borrar píxel anterior
    jal clearPixel
    
    # Leer entrada del teclado
    jal checkInput
    
    # Dibujar píxel en nueva posición
    jal drawPixel
    
    # Pequeña pausa
    li $v0, 32
    li $a0, 50
    syscall
    
    # Continuar el bucle
    j mainLoop

# Función para dibujar el píxel
drawPixel:
    # Calcular dirección: base + (y * ancho + x) * 4
    lw $t0, displayAddress
    lw $t1, posX
    lw $t2, posY
    lw $t3, screenWidth
    
    # Calcular offset: (y * ancho + x) * 4
    mul $t4, $t2, $t3      # y * ancho
    add $t4, $t4, $t1      # + x
    sll $t4, $t4, 2        # * 4 (bytes por píxel)
    
    # Dirección final
    add $t5, $t0, $t4
    
    # Dibujar píxel
    lw $t6, pixelColor
    sw $t6, 0($t5)
    
    jr $ra

# Función para borrar el píxel
clearPixel:
    # Calcular dirección: base + (y * ancho + x) * 4
    lw $t0, displayAddress
    lw $t1, posX
    lw $t2, posY
    lw $t3, screenWidth
    
    # Calcular offset
    mul $t4, $t2, $t3
    add $t4, $t4, $t1
    sll $t4, $t4, 2
    
    # Dirección final
    add $t5, $t0, $t4
    
    # Borrar píxel (pintar de negro)
    lw $t6, bgColor
    sw $t6, 0($t5)
    
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
    addi $t4, $t4, -1
    bge $t3, $t4, checkInput_end    # No mover si está en el borde
    addi $t3, $t3, 1
    sw $t3, posX
    j checkInput_end

checkInput_end:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra