.include "data/game_data.asm"
.include "data/messages.asm"
.include "data/objects_id.asm"

.text
.globl main

main:
    # Inicializar matriz de colisiones
    jal initCollisionMatrix
    
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
    li $a0, 5
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