# ==================== MACROS ====================
.macro push_ra
    addi $sp, $sp, -4
    sw $ra, 0($sp)
.end_macro

.macro pop_ra
    lw $ra, 0($sp)
    addi $sp, $sp, 4
.end_macro

.macro push_reg %reg
    addi $sp, $sp, -4
    sw %reg, 0($sp)
.end_macro

.macro pop_reg %reg
    lw %reg, 0($sp)
    addi $sp, $sp, 4
.end_macro
