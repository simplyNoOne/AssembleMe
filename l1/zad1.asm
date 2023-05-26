
# $t0 bedzie rejestrem uzywanym do pobierania wyborow uzytkownika
# $t1 - t3 beda przechowywac 3 zmienne
# $t5 bedzie rejestrem zawierajacym koncowe wyniki operacji
# $t9 bedzie przechowywac 0 jesli do wyniku wypisujemy wynik int a 1, jesli float

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
	#div $t5, $t4, $t3
	
	mtc1 $t3, $f3
	mtc1 $t4, $f4
	
	div.s $f5, $f4, $f3
	
	
	li $t9, 1
	
	jal return_result

expression2:

	sub $t4, $t2, $t3
	mul $t5, $t4, $t1
	
#	mflo $t6
#	mfhi $t7
	
#	srl $t6, $t6, 16   # Shift the lower 32 bits in $lo right by 16 bits
#	sll $t7, $t7, 16   # Shift the upper 32 bits in $hi left by 16 bits
#	or $t5, $t7, $t6		#polacz bity $t6 i $t7 uzywajac or i zapisz w $t5
	
	li $t9, 0	#zapamietaj, ze wynik nie jest typu float
	
	jal return_result

expression3:

	mul $t4, $t1, $t2
	
#	mflo $t6
#	mfhi $t7
	
#	srl $t6, $t6, 16   # Shift the lower 32 bits in $lo right by 16 bits
#	sll $t7, $t7, 16   # Shift the upper 32 bits in $hi left by 16 bits
#	or $t4, $t7, $t6		#polacz bity $t6 i $t7 uzywajac or i zapisz w $t5
	
	mul $t3, $t3, 2		#pomnoz wartosc d razy 2
	
	sub $t5, $t4, $t3	#zapisz wynik odejmowania w $t5
	
	li $t9, 0		#uzyj rejestru 9, zeby zapamietac, ze wynik nie jest typu float

	jal return_result

division_by_zero:

	li $v0, 4			#poinformuj, ze nie mozna dzielic przez 0
	la $a0, result2
	syscall 
	
	li $v0, 4			# newline
	la $a0, newline
	syscall
	
	jal ask_if_continue
	
return_result:
	li $v0, 4			#wyswietl etykiete do wyniku
	la $a0, result1
	syscall
	
	beq $t9, 1, return_float		#jesli w $t9 jest 1, to znaczy ze wyswietlamy float, inaczej kontynuujemy z intami
	
	li $v0, 1			#ustaw wyswietlanie na int
	move $a0, $t5 			#zapisz wynik z $t5 do wyswietlenia
	syscall
	
	jal ask_if_continue		#przechodzimy do sprawdzenia czy wykonac ponownie
	
return_float:
	li $v0, 2			#ustaw wyswietlanie na float
	mov.s $f12, $f5			#przenies wynik do rejestru, z ktorego sa wyswietlane floaty
	syscall
	
	jal ask_if_continue
	
ask_if_continue:

	li $v0, 4 			#zaznacz, ze wypiszemy ascii
	la $a0, newline			#zrob nowa linie
	syscall

	li $v0, 4			#zaznacz, ze wypiszemy ascii 
	la $a0, ask_continue		#wyswietl pytanie czy kontynuowac
	syscall
	
	li $v0, 5			#pobierz wybor uzytkownika
	syscall
	move $t0, $v0   
	
	beq $t0, 1, main			# jesli uzytkownik wybierze 1, wroc na poczatek, inaczej nie rob nic, program sie konczy
	
	
	
	
	
	
	
    	
    	