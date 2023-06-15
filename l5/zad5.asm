.data
	newline:			.asciiz "\n"
	prompt_player_symbol: 	.asciiz "\nWybierz swoj symbol (o lub x): "
	prompt_num_rounds: 	.asciiz "Podaj liczbe rund (1-5): "
	prompt_player_move: 	.asciiz "Podaj numer pola, na ktorym chcesz postawic znak: "
	error_msg: 		.asciiz "Nieprawidlowe dane. Sprobuj ponownie.\n"
	board_msg: 		.asciiz "Plansza:\n"
	template_board_layout:		.asciiz "1 2 3\n4 5 6\n7 8 9\n"
	board_layout:		.asciiz "1 2 3\n4 5 6\n7 8 9\n"
	result_msg: 		.asciiz "Wyniki:\n"
	player_win_msg: 		.asciiz 	"Gratulacje! Wygrales runde!\n"
	computer_win_msg: 	.asciiz "Komputer wygral runde.\n"
	tie_msg: 		.asciiz "Remis w rundzie.\n"
	board: 		
	.align 3 	
	.space 36 	# Plansza o rozmiarze 9 pól (9 * 4 bajty)
	

.text
main:
	# Inicjalizacja planszy
	la $t0, board		# Adres planszy
	li $t1, 0		# Licznik rund (początkowo 0)
	li $s2, 0		# Licznik zwycięstw gracza (początkowo 0)
	li $s3, 0		# Licznik zwycięstw komputera (początkowo 0)
	
	               

get_player_symbol:
	# Wybór symbolu przez gracza
	
	li $v0, 4
	la $a0, prompt_player_symbol
	syscall
    
	li $v0, 12
	syscall
	move $s0, $v0		# Znak gracza
    
	seq $t7, $s0, 'x'
	seq $t8, $s0, 'o'
	or $t8, $t8, $t7
	beqz $t8, get_player_symbol
	
	
	li $v0, 4
	la $a0, newline
	syscall
    
get_rounds:
	# Wybór liczby rund
	li $v0, 4
	la $a0, prompt_num_rounds
	syscall
	
	li $v0, 5
	syscall
	move $s1, $v0               # Liczba rund
	
	sge $t7, $s1, 1
	sle $t8, $s1, 5
	and $t8, $t8, $t7
	beqz $t8, get_rounds

game_loop:
	jal reset_board
	li $t4, 0		 # Zerowanie licznika ruchów
	li $t5, 0                   # Zerowanie licznika zajętych pól
	li $s6, 0		# Ustawienie rundy na niezakończoną 
	
	addu $t1, $t1, 1		# Zwiększenie liczby rund o 1
	
	li $v0, 4
	la $a0, result_msg           # Wyświetlanie wyników rund
	syscall

round_loop:
	
	li $v0, 4
	la $a0, board_msg            # Wyświetlanie planszy
	syscall
	li $v0, 4
	la $a0, board_layout            # Wyświetlanie planszy
	syscall
	
	jal player_move
	jal computer_move
	
	j round_loop

player_move:
	move $s7, $ra 
	li $v0, 4
	la $a0, prompt_player_move    # Podanie numeru pola przez gracza
	syscall
    
	li $v0, 5                   # Wczytanie numeru pola od gracza
	syscall
	move $t6, $v0               # Numer pola od gracza

	addiu $t6, $t6, -1	# Indeksowanie planszy od 0
	mul $t6, $t6, 4		# pomnóż przez 4, aby można było dodać do adresu
	addu $t7, $t0, $t6	# zapisz adres wybranego pola na planszy w $t7

	lw $t8, ($t7)		# Zapisanie wartości z pola w $t8
	bnez $t8, player_move	# Powtórzenie ruchu, jeśli pole jest zajęte ( if $t8 != 0)

	sw $s0, ($t7)		# Ustawienie znaku gracza na planszy
	jal draw_symbol		# zapisz graficzny znak użytkownika w polu
	
	addiu $t5, $t5, 1           # Zwiększenie licznika zajętych pól

	jal check_winner            # Sprawdzenie, czy gracz wygrał rundę
	beq $s6, 1,round_end      # jeśli w $s6 jest 1, to runda się zakończyła
	
	jr $s7                  # powrót do rozgrywki
	
computer_move:
	move $s7, $ra 
	jr $s7                  # powrót do rozgrywki
	
reset_board:
	la $t3, template_board_layout
	la $t2, board_layout
	li $t4, 18
	move $t9, $t0
	
reset_board_loop:
	
	lb $t6, ($t3)		#zapisz byte poprawnego layoutu do $t6
	beqz $t4, reset_data_loop
	sb $t6, ($t2)		#zapisz dobry byte do planszy pod odpowiednim adresem
	
	
	addu $t3, $t3, 1 	#zwiększ oba adresy o byte
	addu $t2, $t2, 1
	
	addu $t4, $t4, -1	#zmniejsz iterator o 1
	j reset_board_loop

reset_data_loop:
	beq $t4, 9, return_from_sub
	
	sw $zero, ($t9)		#wyzeruj informacje o polu planszy pod adresem $t9
	addu $t9, $t9, 4 	#zwiększ adres planszy o słowo
	
	addu $t4, $t4, 1 	#zwiększ iterator o 1
	j reset_data_loop

check_winner:
	blt $t5, 5, return_from_sub
	
	li $t4, 0		# zmienna pomocnicza do pętli rzędów
	li $t3, 0		# zmienna pomocnicza do pętli rzędów
	li $s6, 0		#ustaw rundę  na niezakończoną
check_row_loop:	
	beq $t4, 3, check_col_loop
	mul $t9, $t4, 12		#oblicz relatywny adres pierwszej komórki w rzędzie
	addu $t4, $t4, 1		#zwiększ iterator pętli o 1
	move $t8, $t9		#zduplikuj w celu obliczenia adresu drugiej komórki
	add $t8, $t8, 4		#zapisz relatywny adres drugiej komórki 
	add $t9, $t9, $t0	#oblicz absolutny adres pierwszej komórki
	add $t8, $t8, $t0	#oblicz absolutny adres drugiej komórki
	lw $t6, ($t9)		#załaduj wartość pierwszej komórki do $t6
	
	beq $t6, 0, check_row_loop
	lw $t7, ($t8)		#załaduj wartość drugiej komórki do $t7
	bne $t7, $t6, check_row_loop	#jeśli nie są takie same, to przejdź do sprawdzenia kolejnego rzędu
	
	add $t8, $t8, 4		#zapisz absolutny adres trzeciej komórki
	lw $t7, ($t8)		#załaduj wartość trzeciej komórki do $t7
	bne $t7, $t6, check_row_loop	#jeśli nie są takie same, to przejdź do sprawdzenia kolejnego rzędu
	
	li $s6, 1		#zapisz, że runda się zakończyła
	
	beq $t6, $s0, player_won_round	#jeśli znak w komórce pierwszej zgadza się ze znakiem gracza, wygrał rundę
	
	addu $s3, $s3, 1		#zwiększ zwycięstwa komputera o 1
	#li $s5, 2		#w przeciwnym przypadku zapisz, że komputer wygrał
	j return_from_sub
	
check_col_loop:
	#beq $t4, 3, check_diag_loop
	beq $t3, 3, return_from_sub
	mul $t9, $t3, 4		#oblicz relatywny adres pierwszej komórki w kolumnie
	addu $t3, $t3, 1		#zwiększ iterator pętli o 1
	move $t8, $t9		#zduplikuj w celu obliczenia adresu drugiej komórki
	add $t8, $t8, 12		#zapisz relatywny adres drugiej komórki 
	add $t9, $t9, $t0	#oblicz absolutny adres pierwszej komórki
	add $t8, $t8, $t0	#oblicz absolutny adres drugiej komórki
	lw $t6, ($t9)		#załaduj wartość pierwszej komórki do $t6
	
	beq $t6, 0, check_col_loop
	lw $t7, ($t8)		#załaduj wartość drugiej komórki do $t7
	bne $t7, $t6, check_col_loop	#jeśli nie są takie same, to przejdź do sprawdzenia kolejnego rzędu
	
	add $t8, $t8, 12		#zapisz absolutny adres trzeciej komórki
	#to zostaje
	lw $t7, ($t8)		#załaduj wartość trzeciej komórki do $t7
	bne $t7, $t6, check_col_loop	#jeśli nie są takie same, to przejdź do sprawdzenia kolejnej kolumny
	
	li $s6, 1		#zapisz, że runda się zakończyła
	
	beq $t6, $s0, player_won_round	#jeśli znak w komórce pierwszej zgadza się ze znakiem gracza, wygrał rundę
	
	addu $s3, $s3, 1		#zwiększ zwycięstwa komputera o 1
	#li $s5, 2		#w przeciwnym przypadku zapisz, że komputer wygrał
	j return_from_sub
	
	
player_won_round:
	#li $s5, 1		#zapisz, że gracz wygrał
	addu $s2, $s2, 1 	#zwiększ zwycięstwa gracza o 1
	j return_from_sub
	
return_from_sub:
	jr $ra

draw_symbol:
	move $t6, $v0		# Ponownie pobierz wybrane przez użytkownika pole
	addiu $t6, $t6, -1
	la $t9, board_layout		# załaduj adres planszy
	mul $t7, $t6, 2		# na planszy każdy znak znajduje się na co drugim polu
	add $t9, $t9, $t7
	sb $s0, ($t9)
	jr $ra

round_end:
	beq $t1, $s1, game_end
	
	
	
	jal results_after_round
    
	j game_loop

results_after_round:

	la $a0, result_msg           # Wyświetlanie wyników rund
	li $v0, 4
	syscall

	move $a0, $s2               # Wyświetlanie liczby zwycięstw gracza
	li $v0, 1
	syscall

	move $a0, $s3               # Wyświetlanie liczby zwycięstw komputera
	li $v0, 1
	syscall
	
	jr $ra

game_end:
	la $a0, board_layout           # Wyświetlanie wyników rund
    li $v0, 4
    syscall    

    li $v0, 10                  # Zakończenie programu
    syscall



