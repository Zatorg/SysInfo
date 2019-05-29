	.text
main:
add		t6, zero, 14
add     t1, zero, 0x200			# Speicheradresse beginn
add		t2, zero, 2			# Iteration Nummer
add		t3, zero, 1			# F1 init
add		t4, zero, 1			# F2 init
sw		t3, 0(t1)
add		t1, t1, 4
sw		t4, 0(t1)

loop:
add		t2, t2, 1
add		t1, t1, 4
add		t5, zero, t4		# Hilfsvariable
add		t4, t4, t3
add		t3, zero, t5
sw		t4, 0(t1)
bne		t2, t6, loop

add    a0, zero, 0			# exit code 0
add    a7, zero, 93			# sycall 93: exit
scall
