 
.include "data/constants.inc"
.include "utils/utils.asm"
.include "logic/game_logic.asm"

.text
.globl main
main:

    # clear buffers
    li $a0, COLOR_BLACK
    jal clear_screen

main_loop:
    # leer teclado (pseudo rutina)
    # si izq, jal mover_paleta con -2
    # si der, jal mover_paleta con +2

    jal mover_pelota

    # dibujar paleta
    lw $t0, spade_x
    lw $t1, spade_y
    li $t2, COLOR_BLUE
    # dibujar paleta 20x8
    li $t3, 0
paleta_loop_y:
    li $t4, 0
paleta_loop_x:
    add $a0, $t0, $t4
    add $a1, $t1, $t3
    move $a2, $t2
    jal draw_pixel
    addi $t4, $t4, 1
    blt $t4, SPADE_SIZE_X, paleta_loop_x
    addi $t3, $t3, 1
    blt $t3, SPADE_SIZE_Y, paleta_loop_y

    # dibujar pelota
    lw $t0, ball_x
    lw $t1, ball_y
    li $t2, COLOR_RED
    li $t3, 0
ball_loop_y:
    li $t4, 0
ball_loop_x:
    add $a0, $t0, $t4
    add $a1, $t1, $t3
    move $a2, $t2
    jal draw_pixel
    addi $t4, $t4, 1
    blt $t4, BALL_SIZE_X, ball_loop_x
    addi $t3, $t3, 1
    blt $t3, BALL_SIZE_Y, ball_loop_y

    # delay
    li $a0, FRAME_DELAY
    jal delay

    j main_loop

