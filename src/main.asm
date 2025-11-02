.text
.globl main

.include "utils/macros.asm"

.include "data/game_data.asm"
.include "data/messages.asm"

.include "display/graphics.asm"
.include "display/blocks.asm"
.include "input/keyboard.asm"
.include "logic/physics.asm"
.include "logic/collisions.asm"

main:
    jal drawAllBlocks
    
mainLoop:
    jal clearPaddle
    jal clearBall
    jal checkInput
    jal moveBall
    jal drawPaddle
    jal drawBall
    
    lw $t0, blocksRemaining
    beqz $t0, gameWon
    
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
