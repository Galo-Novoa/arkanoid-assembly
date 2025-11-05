.include "data/game_data.asm"
.include "data/messages.asm"

.text
.globl main

main:
    # Inicialización - cargar y dibujar nivel 1
    jal loadLevel
    
    # DEBUG: Mostrar nivel actual
    li $v0, 4
    la $a0, msgDebugLevel
    syscall
    li $v0, 1
    lw $a0, currentLevel
    syscall
    li $v0, 4
    la $a0, msgDebugBlocks
    syscall
    li $v0, 1
    lw $a0, blocksRemaining
    syscall
    
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

    # ========== VERIFICAR VICTORIA DEL NIVEL ==========
    lw $t0, blocksRemaining
    beqz $t0, levelComplete

    # ========== DELAY ==========
    li $v0, 32
    li $a0, 8  # Reducido de 20ms a 8ms para mejor fluidez
    syscall

    j mainLoop

levelComplete:
    # Mostrar mensaje de nivel completado
    li $v0, 4
    la $a0, msgWin
    syscall
    
    li $v0, 4
    la $a0, msgScore
    syscall
    
    li $v0, 1
    lw $a0, score
    syscall
    
    # Pausa antes de siguiente nivel
    li $v0, 32
    li $a0, 2000
    syscall
    
    # Cargar siguiente nivel
    jal nextLevel
    
    # Redibujar pantalla con nuevo nivel
    jal clearScreen
    jal drawAllBlocks
    
    j mainLoop

# Los archivos con implementaciones VAN DESPUÉS de main
.include "display/graphics.asm"
.include "display/blocks.asm"
.include "logic/levels.asm"
.include "input/keyboard.asm"
.include "logic/physics.asm"
.include "logic/collisions.asm"