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
	add $t3, $t1, $t0	#calculate the byte to access in text1 and save the adress in $t3
	add $t4, $t2, $t0	#calculate the byte to access in text2 and save the adress in $t4
	lb $t5, ($t3)		#save into $t5 the value at a specyfic byte from $t3
	lb $t6, ($t4)		#save into $t6 the value at a specyfic byte from $t4
	
	seq $t3, $t5, $zero	#set $t3 to 1, if $t5 points to end char
	seq $t4, $t6, $zero	#set $t4 to 1, if $t6 points to end char
	and $t7, $t4, $t3 	#set $t7 to 1 if both $t3 or $t4 is 1
	
	li $t6, 0		#in case of branch, amount of processed chars will be stored in $t6
	li $t5, 0		#$t5 will store the amount of equal chars if we branch
	sub $t0, $t0, 1		#decrement by one, in order to read a previous byte next iteration
	
	beq $t7, 0, compare_chars	#if either one has reached text, be will be comparing
		
	j skip_both_empty		#else continue with the loop
	
	 
compare_chars:
	addi $t6, $t6, 1		#increment amount of processed chars in the string
	addi $sp, $sp, -1	#move the stack pointer to accomodate the next character
	add $t3, $t0, $t1	#save the adress of next byte from text1 into $t3
	add $t4, $t0, $t2	#save the adress of next byte from text2 into $t4
	lb $t7, ($t4)		#save the char at the adress in $t4 into $t7
	lb $t4, ($t3)		#save the char at the adress in $t5 into $t4
	beq $t4, $t7, are_equal	#if the chars are the same, branch
	sb $t8, ($sp)		#save the unequal char at the adress of $sp
continue:
	beq $t0, $zero, finished_comparing	#if iterator is 0, then we arrived at the beginning of the string
	sub $t0, $t0, 1				#decrement $t0 in order to move onto the next char
	j compare_chars				#continue executing the loop
	
are_equal:
	sb $t9, ($sp)		#save the equals char on new empty space on stack, adress of $sp
	addi $t5, $t5, 1		#increment the equals counter by 1
	j continue		#go back to the loop
	
finished_comparing:
	la $t0, return_text 		#save the adress of the first byte of return string
	move $t1, $t6			#save the max value of $t6 to show how many bytes of stack we used

processing_loop:
	lb $t7, ($sp)			#save into $t7 the current symbol form the stack
	sb $t7, ($t0)			#load the saved symbol form $t7 into an adress in our return string
	beq $t6, $zero, string_ready	#if we read all symbols from stack, we exit loop
	
	addi $sp, $sp, 1			#increase the stack pointer to the next byte
	subi $t6, $t6, 1			#decrement the remaining symbols counter by one
	addi $t0, $t0, 1			#increment the iterator of the return string by one
	j processing_loop		#continue processing
	
	
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
	move $a0, $t5
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
	
end:
	li $v0, 10			#exit program
	syscall

		
