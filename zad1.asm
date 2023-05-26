.data:
	instruction: .asciiz "Podaj numer wyrazenia, ktore chesz obliczyc: "
	expression_prompt: .asciiz "Dostepne wyrazenia:"
	ex1: .asciiz "1. a = (c - b)/d"
	ex2: .asciiz "2. a = (c - d)*b"
	ex3: .asciiz "3. a = b*c - 2d"
	prompt_values: .asciiz "Podaj wartosci zmiennych: "
	newline: .asciiz "\n"
	var_b: .asciiz "b = "
	var_c: .asciiz "c = "
	var_d: .asciiz "d = "
	result1: .asciiz "Twoj wynik to: "	
	result2: .asciiz "Nie mozna dzielic przez 0!"
	ask_continue: .asciiz "Czy kontynuowac? (0. - Nie, 1. - Tak): "
	
.text:

main:
	
	jal prompt_the_user
	
	li $v0, 4                      # Wypisz prompt dla numeru wyrażenia
	la $a0, ask_continue
  	syscall
	
	
prompt_the_user:
	li $v0, 4                      # Wypisz prompt dla numeru wyrażenia
	la $a0, expression_prompt
    	syscall
    	
    	li $v0, 4                      # Wypisz prompt dla numeru wyrażenia
	la $a0, newline
	syscall
	
	li $v0, 4                     
	la $a0, ex1
	syscall
	
	li $v0, 4                      # Wypisz prompt dla numeru wyrażenia
	la $a0, newline
	syscall
	
	li $v0, 4                     
	la $a0, ex2
	syscall
	
	li $v0, 4                      # Wypisz prompt dla numeru wyrażenia
	la $a0, newline
	syscall
	
	li $v0, 4                     
	la $a0, ex3
	syscall
	
	li $v0, 4
	la $a0, newline
	syscall
	
	li $v0, 4                     
	la $a0, instruction
	syscall
	
	li $v0, 5
	syscall
	move $t0, $v0 
	
	 
	li $v0, 4			# kaz wpisac zmienne    
	la $a0, prompt_values
	syscall
	
	li $v0, 4			# newline
	la $a0, newline
	syscall
	
	li $v0, 4                     
	la $a0, var_b
	syscall
	
	li $v0, 5			 # Wczytaj wartosc b
	syscall
	move $t1, $v0   
	
	li $v0, 4                     
	la $a0, var_c
	syscall
	
	li $v0, 5			 # Wczytaj wartosc c
	syscall
	move $t2, $v0   
	
	li $v0, 4                     
	la $a0, var_d
	syscall
	
	li $v0, 5			 # Wczytaj wartosc d
	syscall
	move $t3, $v0   
	
	beq $t0, 1, expression1
	beq $t0, 2, expression2
	beq $t0, 3, expression3
	
	
expression1:
	
	beq $t3, 0, division_by_zero
	
	sub $t4, $t2, $t1
	div $t5, $t4, $t3

expression2:


expression3:

division_by_zero:

	li $v0, 4			#poinformuj, ze nie mozna dzielic przez 0
	la $a0, result2
	syscall 
	
	li $v0, 4			# newline
	la $a0, newline
	syscall
	
	
ask_if_continue:
	li $v0, 4			#zapytaj, czy kontynuowac 
	la $a0, ask_continue
	syscall
	
	li $v0, 5
	syscall
	move $t0, $v0   
	
	beq $t0, 1, main			# jesli uzytkownik wybierze 1, wroc na poczatek, inaczej nie rob nic
	
	
	
	
    	
    	