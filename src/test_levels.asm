# ==================== TEST DE NIVELES ====================
testLevels:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Test nivel 1
    li $v0, 4
    la $a0, msgTest1
    syscall
    
    li $v0, 1
    lw $a0, currentLevel
    syscall
    
    # Cargar y mostrar bloques del nivel 1
    jal loadLevel
    
    li $v0, 4
    la $a0, msgTest2
    syscall
    
    li $v0, 1
    lw $a0, blocksRemaining
    syscall
    
    # Dibujar nivel 1
    jal drawAllBlocks
    
    # Pausa para ver nivel 1
    li $v0, 32
    li $a0, 3000
    syscall
    
    # Avanzar a nivel 2
    lw $t0, currentLevel
    addi $t0, $t0, 1
    sw $t0, currentLevel
    
    li $v0, 4
    la $a0, msgTest3
    syscall
    
    li $v0, 1
    lw $a0, currentLevel
    syscall
    
    # Cargar y mostrar nivel 2
    jal loadLevel
    jal clearScreen
    jal drawAllBlocks
    
    li $v0, 4
    la $a0, msgTest4
    syscall
    
    li $v0, 1
    lw $a0, blocksRemaining
    syscall
    
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra