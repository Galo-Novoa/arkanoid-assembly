.text
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
    jal drawBlockWithSprite

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

# ==================== DIBUJAR BLOQUE CON SPRITE ====================
drawBlockWithSprite:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Calcular posición X
    lw $t0, blockStartX
    mul $t1, $a0, 20      # 20px ancho
    add $t4, $t0, $t1     # X inicial
    
    # Calcular posición Y
    lw $t0, blockStartY
    mul $t1, $a1, 8       # 8px alto
    add $t5, $t0, $t1     # Y inicial
    
    # Determinar tipo de bloque según fila
    move $a0, $a1         # fila como parámetro
    jal getBlockIDFromRow
    move $a2, $v0         # ID del bloque
    
    # Dibujar sprite del bloque
    move $a0, $t4         # X
    move $a1, $t5         # Y
    move $a2, $v0         # blockID
    jal drawBlockSprite
    
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra

# ==================== DIBUJAR SPRITE DE BLOQUE ====================
# $a0 = posX, $a1 = posY, $a2 = blockID
drawBlockSprite:
    addiu $sp, $sp, -20
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    
    move $s0, $a0         # posX
    move $s1, $a1         # posY
    move $s2, $a2         # blockID
    
    # Obtener dirección del sprite desde la tabla
    la $t0, block_sprites_table
    addi $t1, $s2, -1     # blockID - 1 (porque la tabla empieza en ID 1)
    sll $t1, $t1, 2       # * 4 (tamaño de palabra)
    add $t0, $t0, $t1
    lw $s3, 0($t0)        # $s3 = dirección del sprite
    
    lw $t0, displayAddress
    li $t4, 20            # ancho del sprite (20px)
    li $t5, 8             # alto del sprite (8px)
    
    li $t7, 0             # contador filas

draw_block_sprite_y:
    bge $t7, $t5, draw_block_sprite_end
    li $t8, 0             # contador columnas

draw_block_sprite_x:
    bge $t8, $t4, draw_block_sprite_next_y
    
    # Calcular posición en pantalla
    add $t9, $s1, $t7     # Y + offset_y
    add $s4, $s0, $t8     # X + offset_x
    
    # Calcular offset en display: (y * 256 + x) * 4
    sll $s5, $t9, 8       # y * 256
    add $s5, $s5, $s4     # + x
    sll $s5, $s5, 2       # * 4
    add $s5, $t0, $s5     # + dirección base
    
    # Calcular posición en sprite: (y * 20 + x) * 4
    mul $s6, $t7, 20      # y * 20
    add $s6, $s6, $t8     # + x
    sll $s6, $s6, 2       # * 4
    add $s6, $s3, $s6     # + dirección sprite
    
    # Cargar color del sprite
    lw $s7, 0($s6)
    
    # Solo dibujar si no es negro (transparente)
    li $t1, 0x000000
    beq $s7, $t1, draw_block_sprite_skip
    
    # Dibujar pixel
    sw $s7, 0($s5)

draw_block_sprite_skip:
    addi $t8, $t8, 1
    j draw_block_sprite_x

draw_block_sprite_next_y:
    addi $t7, $t7, 1
    j draw_block_sprite_y

draw_block_sprite_end:
    lw $s3, 16($sp)
    lw $s2, 12($sp)
    lw $s1, 8($sp)
    lw $s0, 4($sp)
    lw $ra, 0($sp)
    addiu $sp, $sp, 20
    jr $ra

# ==================== BORRAR UN BLOQUE ====================
eraseBlock:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Calcular posición X
    lw $t0, blockStartX
    mul $t1, $a0, 20      # 20px ancho
    add $t4, $t0, $t1
    
    # Calcular posición Y
    lw $t0, blockStartY
    mul $t1, $a1, 8       # 8px alto
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

# ==================== DIBUJAR BLOQUE ESPECÍFICO (para power-ups, etc.) ====================
# $a0 = posX, $a1 = posY, $a2 = blockID
drawSpecificBlock:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    
    jal drawBlockSprite
    
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra