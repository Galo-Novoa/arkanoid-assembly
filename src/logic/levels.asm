# ==================== CARGAR NIVEL ====================
loadLevel:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Obtener puntero al nivel actual
    lw $t0, currentLevel
    addi $t0, $t0, -1          # índice base 0
    sll $t0, $t0, 2            # *4 (tamaño palabra)
    
    la $t1, levelPointers
    add $t1, $t1, $t0
    lw $t2, 0($t1)             # t2 = puntero al nivel
    
    # Obtener número de bloques destructibles
    la $t3, levelDestructible
    add $t3, $t3, $t0
    lw $t4, 0($t3)             # t4 = bloques destructibles
    sw $t4, blocksRemaining
    
    # Copiar nivel al array de bloques
    la $t5, blocks             # destino
    li $t6, 60                 # 60 bloques total
    
copyLevel_loop:
    beqz $t6, copyLevel_end
    lw $t7, 0($t2)             # cargar bloque del nivel
    sw $t7, 0($t5)             # guardar en array de bloques
    
    addiu $t2, $t2, 4
    addiu $t5, $t5, 4
    addiu $t6, $t6, -1
    j copyLevel_loop

copyLevel_end:
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra

# ==================== SIGUIENTE NIVEL ====================
nextLevel:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    
    lw $t0, currentLevel
    lw $t1, totalLevels
    
    # Verificar si es el último nivel
    bge $t0, $t1, gameComplete
    
    # Incrementar nivel
    addi $t0, $t0, 1
    sw $t0, currentLevel
    
    # Cargar nuevo nivel
    jal loadLevel
    
    # Mensaje de nuevo nivel
    li $v0, 4
    la $a0, msgNewLevel
    syscall
    
    li $v0, 1
    lw $a0, currentLevel
    syscall
    
    # Pausa breve
    li $v0, 32
    li $a0, 2000
    syscall
    
    j nextLevel_end

gameComplete:
    li $v0, 4
    la $a0, msgGameComplete
    syscall
    
    li $v0, 10
    syscall

nextLevel_end:
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra