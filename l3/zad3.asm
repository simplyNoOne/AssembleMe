.data
	text1: 	.space 81 		#empty buffer for chars, 1 byte for each, text 1 will be here
	text2: 	.space 81		#empty buffer for chars, 1 byte for each, text 2 will be here
	#the buffers store 81 instead of 80, because the last one is terminating char, user can only enter 80
	prompt1: .asciiz "Podaj text 1 (max 80 znakow): "
	prompt2: .asciiz "Podaj text 2 (max 80 znakow): "
	
	return_text: .space 81		#here the resulting combitanion of chars (- and *) will be stored, 1 byte for each
	return_info: .asciiz "Wynik porownania (-: pasuje, *: nie pasuje):"
	number_info: .asciiz "Liczba pasujacych znakow: "
	stack_info: .asciiz "Liczba byte'ow zaalokowana na stacku w czasie wykonania: "
	newline: .asciiz "\n"
	divider: .asciiz "------------------------------------"
.text
main:
	
	li $v0, 4		#show prompt no1, 4 in $v0 sygnalizes writing a string on screen
	la $a0, prompt1
	syscall
	
	li $v0, 8		#prepare to read string
	la $a0, text1		#declare, that the text will be saved in text1
	li $a1, 81		#save the next 81 characters, the last one being null, so user can only enter 80
	syscall
	
	li $v0, 4		#show prompt no2, 4 in $v0 sygnalizes writing a string on screen
	la $a0, prompt2
	syscall
	
	li $v0, 8		#prepare to read string
	la $a0, text2		#declare, that the text will be saved in text2
	li $a1, 81
	syscall
	
prep_for_reading:
	li $t0, 80		#save the starting shift of adresses (we start from the last)
	la $t1, text1		#save the adress of the first byte of text1 in $t1
	la $t2, text2		#save the adress of the first byte of text2 in $t2
	
	li $t8, '*'		#store the unequal character to save on stack
	li $t9, '-'		#store the equal character to save on stack
skip_both_empty:
	add $t3, $t1, $t0
	add $t4, $t2, $t0
	lb $t5, ($t3)		#save into $t3 the value at a specyfic byte of text1
	lb $t6, ($t4)		#save into $t3 the value at a specyfic byte of text1
	
	seq $t3, $t5, $zero	#set to 1, if $t3 points to end char, after that all will be valid text
	seq $t4, $t6, $zero
	xor $t7, $t4, $t3
	li $t6, 0		#in case of branch, amount of processed chars will be stored in $t6
	beq $t7, 1, prep_for_single_skip
	li $t7, 0		#$t7 will store the amount of equal chars if we branch
	beq $t3, 0, compare_chars	#if $t3 is equal to one, then both strings are at end and we can begin comparing
	sub $t0, $t0, 1		#decrement by one, in order to read a previous byte next iteration
	j skip_both_empty
	
	
prep_for_single_skip:
	add $t3, $t0, $t2
	lb $t4, ($t3)
	beq $t4, $zero, skip_single		#if text2 is already at end, then skip to skipping over text1

	add $t1, $t2, $zero				#else move text2 into text1 for it to be skipped over
	
skip_single:
	addi $t6, $t6, 1
	sub $t0, $t0, 1				#decrement in order to move onto the next char
					#save the symbol for not matching string on the stack
	add $t3, $t0, $t1
	lb $t4, ($t3)	
	bne $t4, $zero, second_end_found
	addi $sp, $sp, -1			#move the stack pointer down by one byte in order to make space for char
	sb $t8, ($sp)				#save the non matching char into the stack
	j skip_single
	
second_end_found:
	 	 
	 la $t1, text1		#set $t1 back to the adress of text1
	 li $t7, 0		#$t7 will store the amount of equal chars
	 
	 
compare_chars:
	addi $t6, $t6, 1		#increment amount of processed chars, it will produce one increment too many
	addi $sp, $sp, -1
	add $t3, $t0, $t1
	add $t4, $t0, $t2
	lb $t5, ($t4)
	lb $t4, ($t3)
	beq $t4, $t5, are_equal
	sb $t8, ($sp)			#save the unequal char at the adress of $sp
continue:
	beq $t0, $zero, finished_comparing	#if iterator is 0, then we arrived at the beginning of the string
	sub $t0, $t0, 1				#decrement $t0 in order to move onto the next char
	j compare_chars
	
are_equal:
	sb $t9, ($sp)			#save the equals char on new empty space on stack, adress of $sp
	addi $t7, $t7, 1
	j continue
	
finished_comparing:
	la $t0, return_text 		#save the adress of the first byte of return string
	sub $t6, $t6, 1			#decrement stack usage by one, because one increment of $t6 is excessive
	move $t1, $t6			#save the max value of $t6 to show how many bytes of stack we used

processing_loop:
	
	lb $t5, ($sp)			#save into the string the current symbol form the stack
	sb $t5, ($t0)
	beq $t6, $zero, string_ready	#if we read all symbols from stack, we exit loop
	addi $sp, $sp, 1			#increate the pointer to the next byte
	subi $t6, $t6, 1
	addi $t0, $t0, 1
	j processing_loop
	
	
string_ready:
	li $t0, 0 			#add the end character at the end of return string
	
	li $v0, 4
	la $a0, divider			#print the divider line
	syscall
	
	li $v0, 4
	la $a0, newline			#newline
	syscall
	
	li $v0, 4
	la $a0, return_info		#print prompt before return string
	syscall
	
	li $v0, 4
	la $a0, newline			#newline
	syscall
	
	li $v0, 4
	la $a0, return_text		#print return string
	syscall
	
	li $v0, 4
	la $a0, newline			#newline
	syscall
	
	li $v0, 4			#print prompt before number of equals
	la $a0, number_info
	syscall
	
	li $v0, 1			#display the number of matching chars
	move $a0, $t7
	syscall
	
	li $v0, 4
	la $a0, newline			#newline
	syscall
	
	li $v0, 4			#print prompt before stack usage
	la $a0, stack_info
	syscall
	
	li $v0, 1			#display the number of used bytes on stack
	move $a0, $t1
	syscall
	
	
	
	
	
	
	
	