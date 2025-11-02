

.include "utils/macros.asm"
.include "data/game_data.asm"
.include "data/messages.asm"

.text
.globl main

# MAIN DEBE ESTAR ANTES de cualquier otro .text
main:
    # Dibujar todos los bloques al inicio
    jal drawAllBlocks
    j mainLoop

mainLoop:
    # Borrar posiciones anteriores
    jal clearPaddle
    jal clearBall
    
    # Procesar entrada y física
    jal checkInput
    jal moveBall
    
    # Dibujar nuevas posiciones
    jal drawPaddle
    jal drawBall
    
    # Verificar victoria
    lw $t0, blocksRemaining
    beqz $t0, gameWon
    
    # Delay para controlar FPS
    li $v0, 32
    li $a0, 50
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