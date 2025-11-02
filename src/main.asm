.include "data/game_data.asm"
.include "data/messages.asm"

.text
.globl main

main:
    # Dibujar todos los bloques al inicio
    jal drawAllBlocks

mainLoop:
    # ========== BORRAR ELEMENTOS ANTERIORES ==========
    jal clearPaddleFast
    jal clearBallFast
    
    # ========== PROCESAR ENTRADA Y FÍSICA ==========
    jal checkInput
    jal moveBall

    # ========== DIBUJAR ELEMENTOS NUEVOS ==========
    jal drawPaddleFast
    jal drawBallFast

    # ========== VERIFICAR VICTORIA ==========
    lw $t0, blocksRemaining
    beqz $t0, gameWon

    # ========== DELAY MÁS RÁPIDO ==========
    li $v0, 32
    li $a0, 16  # 16ms para ~60 FPS
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

# Los archivos con implementaciones VAN DESPUÉS de main
.include "display/graphics.asm"
.include "display/blocks.asm"
.include "input/keyboard.asm"
.include "logic/physics.asm"
.include "logic/collisions.asm"