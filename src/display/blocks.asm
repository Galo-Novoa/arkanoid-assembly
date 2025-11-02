
.text
# ==================== DIBUJAR TODOS LOS BLOQUES ====================
drawAllBlocks:
    push_ra()
    
    li $s0, 0
    lw $s1, blockRows

drawBlocks_row:
    bge $s0, $s1, drawBlocks_end
    li $s2, 0
    lw $s3, blocksPerRow

drawBlocks_col:
    bge $s2, $s3, drawBlocks_nextRow
    
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
    pop_ra()
    jr $ra

# ==================== DIBUJAR UN BLOQUE ====================
drawBlock:
    push_ra()
    
    lw $t0, blockStartX
    sll $t1, $a0, 2
    sll $t2, $a0, 1
    add $t1, $t1, $t2
    add $t4, $t0, $t1
    
    lw $t0, blockStartY
    add $t1, $a1, $a1
    add $t1, $t1, $a1
    add $t5, $t0, $t1
    
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
    
    li $s4, 0

drawBlock_loopY:
    bge $s4, $t3, drawBlock_end
    li $s5, 0

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
    pop_ra()
    jr $ra

# ==================== BORRAR UN BLOQUE ====================
eraseBlock:
    push_ra()
    
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
    pop_ra()
    jr $ra
