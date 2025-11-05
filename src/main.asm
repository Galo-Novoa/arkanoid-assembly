.include "data/game_data.asm"
.include "data/messages.asm"
.include "data/objects_id.asm"

.text
.globl main

main:
    # Inicializar matriz de colisiones
    jal initCollisionMatrix
    
    # DEBUG: Verificar que los bloques se registraron
    jal debugCheckBlocks
    
    # Registrar paleta inicial en matriz
    jal updatePaddleInMatrix
    
    # Dibujar todos los bloques al inicio
    jal drawAllBlocks

mainLoop:
    # ========== BORRAR ELEMENTOS ANTERIORES ==========
    jal clearPaddleFast
    jal clearBallFast
    
    # ========== PROCESAR ENTRADA ==========
    jal checkInput
    
    # ========== ACTUALIZAR PALETA EN MATRIZ ==========
    jal updatePaddleInMatrix
    
    # ========== DEBUG: VERIFICAR POSICIÓN ACTUAL ==========
    lw $a0, ballX
    lw $a1, ballY
    jal getObjectFromMatrix
    
    # Si hay algo en la posición actual, mostrar info
    beqz $v0, no_debug
    move $t9, $v0  # Guardar ID
    
    # Mostrar posición y objeto
    li $v0, 1
    lw $a0, ballX
    syscall
    li $v0, 11
    li $a0, ','
    syscall
    li $v0, 1
    lw $a0, ballY
    syscall
    li $v0, 11
    li $a0, ':'
    syscall
    li $v0, 1
    move $a0, $t9
    syscall
    li $v0, 11
    li $a0, '\n'
    syscall
    
no_debug:
    # ========== MOVER PELOTA Y VERIFICAR COLISIONES ==========
    jal moveBall

    # ========== DIBUJAR ELEMENTOS NUEVOS ==========
    jal drawPaddleFast
    jal drawBallFast

    # ========== VERIFICAR VICTORIA ==========
    lw $t0, blocksRemaining
    beqz $t0, gameWon

    # ========== DELAY ==========
    li $v0, 32
    li $a0, 15  # Más lento para debugging
    syscall

    j mainLoop

gameWon:
    li $v0, 4
    la $a0, msgWin
    syscall
    li $v0, 10
    syscall

.include "display/graphics.asm"
.include "display/blocks.asm"
.include "input/keyboard.asm"
.include "logic/collision_matrix.asm"
.include "logic/physics.asm"
.include "logic/collisions.asm"