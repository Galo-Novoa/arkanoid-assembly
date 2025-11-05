# ==================== DIBUJAR TODOS LOS BLOQUES ====================
drawAllBlocks:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    
    li $s0, 0 # fila actual
    lw $s1, blockRows # filas totales

drawBlocks_row:
    bge $s0, $s1, drawBlocks_end # if fila >= filas_totales, terminar
    li $s2, 0 # columna actual
    lw $s3, blocksPerRow # columnas totales

drawBlocks_col:
    bge $s2, $s3, drawBlocks_nextRow # if col >= cols_totales, siguiente fila
    
    # Calcular índice
    mul $t0, $s0, 10    # fila * bloques_por_fila (10)
    add $t0, $t0, $s2   # + columna
    sll $t0, $t0, 2     # * 4 (tamaño de palabra)
    
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
    addiu $sp, $sp, 4
    jr $ra

# ==================== DIBUJAR UN BLOQUE ====================
drawBlock:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Calcular posición X (sin separación entre bloques)
    lw $t0, blockStartX
    mul $t1, $a0, 20      # 20px ancho, sin espacio
    add $t4, $t0, $t1
    
    # Calcular posición Y (sin separación entre bloques)
    lw $t0, blockStartY
    mul $t1, $a1, 8       # 8px alto, sin espacio
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
    li $t7, 3
    beq $a1, $t7, drawBlock_color
    la $t6, blockColor1
    li $t7, 4
    beq $a1, $t7, drawBlock_color
    la $t6, blockColor2

drawBlock_color:
    lw $t6, 0($t6)
    
    lw $t0, displayAddress
    lw $t2, blockWidth
    lw $t3, blockHeight
    
    li $s4, 0

drawBlock_loopY:
    bge $s4, $t3, drawBlock_end
    li $s5, 0

drawBlock_loopX:
    bge $s5, $t2, drawBlock_nextY
    
    add $s6, $t5, $s4
    add $s7, $t4, $s5
    
    # Calcular offset: (y * 256 + x) * 4
    sll $t7, $s6, 8      # y * 256
    add $t7, $t7, $s7    # + x
    sll $t7, $t7, 2      # * 4
    add $t7, $t0, $t7    # + dirección base
    
    sw $t6, 0($t7)
    
    addi $s5, $s5, 1
    j drawBlock_loopX

drawBlock_nextY:
    addi $s4, $s4, 1
    j drawBlock_loopY

drawBlock_end:
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra

# ==================== BORRAR UN BLOQUE ====================
eraseBlock:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Calcular posición X (sin separación entre bloques)
    lw $t0, blockStartX
    mul $t1, $a0, 20      # 20px ancho, sin espacio
    add $t4, $t0, $t1
    
    # Calcular posición Y (sin separación entre bloques)
    lw $t0, blockStartY
    mul $t1, $a1, 8       # 8px alto, sin espacio
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
    
    sll $t7, $s6, 8      # y * 256
    add $t7, $t7, $s7    # + x
    sll $t7, $t7, 2      # * 4
    add $t7, $t0, $t7    # + dirección base
    
    sw $t6, 0($t7)
    
    addi $s5, $s5, 1
    j eraseBlock_loopX

eraseBlock_nextY:
    addi $s4, $s4, 1
    j eraseBlock_loopY

eraseBlock_done:
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra