# =============================
# Rutinas auxiliares
# =============================

.include "/home/galo/Desktop/Repos/arkanoid-assembly/data/constants.asm"

# draw_pixel(x, y, color)
# Argumentos: $a0=x, $a1=y, $a2=color
draw_pixel:
    # Calculamos offset = y * SCREEN_WIDTH + x
    mul $t0, $a1, SCREEN_WIDTH
    add $t0, $t0, $a0
    sll $t0, $t0, 2            # cada pixel 4 bytes
    la $t1, color_buffer
    add $t1, $t1, $t0
    sw $a2, 0($t1)
    jr $ra

# clear_screen(color)
# Argumentos: $a0=color
clear_screen:
    la $t0, color_buffer
    li $t1, SCREEN_WIDTH*SCREEN_HEIGHT
clear_loop:
    sw $a0, 0($t0)
    addi $t0, $t0, 4
    addi $t1, $t1, -1
    bnez $t1, clear_loop
    jr $ra

# delay(frame_count)
# Argumentos: $a0=frame_count
delay:
    move $t0, $a0
delay_loop:
    addi $t0, $t0, -1
    bnez $t0, delay_loop
    jr $ra

