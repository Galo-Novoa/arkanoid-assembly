# =============================
# Lógica del juego
# =============================

.include "../data/constants.inc"

# buffers
    .data
color_buffer: .space 216*216*4
object_buffer: .space 216*216*4

# posición inicial
spade_x: .word 98
spade_y: .word 200

ball_x:  .word 104
ball_y:  .word 192
ball_vx: .word 1
ball_vy: .word -1

# bloques
blocks_start: .word 15, 15   # fila y columna inicial

# =============================
# mover paleta
# =============================
# mover_paleta(dx)
# Argumentos: $a0=delta
mover_paleta:
    lw $t0, spade_x
    add $t0, $t0, $a0
    # límites
    li $t1, EDGE_MARGIN
    ble $t0, $t1, set_min
    li $t1, SCREEN_WIDTH-EDGE_MARGIN-SPADE_SIZE_X
    bge $t0, $t1, set_max
    j end_mover
set_min:
    li $t0, EDGE_MARGIN
    j end_mover
set_max:
    li $t0, SCREEN_WIDTH-EDGE_MARGIN-SPADE_SIZE_X
end_mover:
    sw $t0, spade_x
    jr $ra

# =============================
# mover pelota
# =============================
mover_pelota:
    lw $t0, ball_x
    lw $t1, ball_y
    lw $t2, ball_vx
    lw $t3, ball_vy
    add $t0, $t0, $t2
    add $t1, $t1, $t3

    # colisión paredes
    li $t4, 0
    blt $t0, $t4, invert_vx
    li $t4, SCREEN_WIDTH-BALL_SIZE_X
    bgt $t0, $t4, invert_vx
    li $t4, 0
    blt $t1, $t4, invert_vy
    li $t4, SCREEN_HEIGHT-BALL_SIZE_Y
    bgt $t1, $t4, invert_vy
    j save_pos
invert_vx:
    neg $t2, $t2
    sw $t2, ball_vx
    j save_pos
invert_vy:
    neg $t3, $t3
    sw $t3, ball_vy
save_pos:
    sw $t0, ball_x
    sw $t1, ball_y
    jr $ra

