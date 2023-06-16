
.data
	newline:			.asciiz "\n"
	prompt_player_symbol: 	.asciiz "\nWybierz swoj symbol (o lub x): "
	prompt_num_rounds: 	.asciiz "Podaj liczbe rund (1-5): "
	prompt_player_move: 	.asciiz "Podaj numer pola, na ktorym chcesz postawic znak: "
	error_msg: 		.asciiz "Nieprawidlowe dane. Sprobuj ponownie.\n"
	board_msg: 		.asciiz "Plansza:\n"
	round_no_msg:		.asciiz "Runda "
	round_follow:		.asciiz ":\t\t"
	template_board_layout:		.asciiz "1 2 3\n4 5 6\n7 8 9\n"
	board_layout:		.asciiz "1 2 3\n4 5 6\n7 8 9\n"
	result_msg: 		.asciiz "Wynik rundy:\n"
	won_msg: 		.asciiz 	"Gratulacje! Wygrales runde!\n"
	lost_msg: 		.asciiz "Komputer wygral runde.\n"
	draw_msg: 		.asciiz "Remis w rundzie.\n"
	board: 		
	.align 3 	
	.space 36 	# Plansza o rozmiarze 9 pól (9 * 4 bajty)
	

.text
main:
	# Inicjalizacja planszy
	la $t0, board		# Adres planszy
	li $t1, 0		# Licznik rund (początkowo 0)
	li $s2, 0		# stan aktualnej wygranej(początkowo 0)
	
	
	               

get_player_symbol:
	# Wybór symbolu przez gracza
	
	li $v0, 4
	la $a0, prompt_player_symbol
	syscall
    
	li $v0, 12
	syscall
	move $s0, $v0		# Znak gracza
	li $s5, 'x'		# załóż że komputer gra x
    
	seq $t7, $s0, 'x'
	seq $t8, $s0, 'o'
	or $t8, $t8, $t7
	beqz $t8, get_player_symbol
	
	li $v0, 4
	la $a0, newline
	syscall
	
	bnez $t7, change_computer_symbol		# w razie, gdyby trzeba zmienić znak komputera
	
	j get_rounds
	
change_computer_symbol:
	li $s5, 'o'
    
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
	li $s2, 0		# ustawienie rundy na nierozstrzygniętą
	
	addu $t1, $t1, 1		# Zwiększenie liczby rund o 1
	

round_loop:
	
	li $v0, 4
	la $a0, board_msg            # Wyświetlanie promptu przed planszą
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
	move $s4, $s0
	move $a3, $v0		#odzyskaj podany przez użytkownika symbol
	jal draw_symbol		# zapisz graficzny znak użytkownika w polu
	
	addiu $t5, $t5, 1	# Zwiększenie licznika zajętych pól

	jal check_winner 	# Sprawdzenie, czy runda rozstrzygnięta
	beq $s6, 1, round_end	# jeśli w $s6 jest 1, to runda się zakończyła
	beq $t5, 9, round_end	#jeśli wykonano już 9 ruchów, to runda się kończy
	
	jr $s7                  # powrót do rozgrywki
	
computer_move:
	move $s7, $ra
	
	
	
	
	
	
	
check_row_computer:	
	li $t2, 0		# zmienna do pętli
row_loop:
	beq $t2, 3, check_col_computer
	
	mul $t9, $t2, 12		#oblicz relatywny adres pierwszej komórki w rzędzie
	add $t9, $t9, $t0	#oblicz absolutny adres pierwszej komórki
	addu $t2, $t2, 1		#zwiększ iterator pętli o 1
	
	li $t8, 0		# wew iterator
	li $t3, 0		#ustaw sumę zajętych na 0
inner_row_loop:
	beq $t8, 3, inner_row_end
	lw $t6, ($t9)		#załaduj wartość komórki do $t6
	beq $t6, $s0, player_sign_row
	bnez $t6, comp_sign_row
	move $s3, $t8
row_inner_continue:
	addu $t9, $t9, 4		#zwiększ adres o krok
	addu $t8, $t8, 1 
	j inner_row_loop
	
inner_row_end:
	bne $t3, 2, row_loop
	add $t9, $t9, -12	#wroć do adresu pierwszej komórki
	move $t8, $s3
	mul $s3, $s3, 4
	add $t9, $t9, $s3
	
	sw $s5, ($t9)		# Ustawienie znaku komputera na planszy
	move $s4, $s5
	move $t9, $t2
	add $t9, $t9, -1
	mul $t9, $t9, 3
	add $t9, $t9, $t8
	add $t9, $t9, 1
	move $a3, $t9
	move $t3, $ra
	jal draw_symbol		# zapisz graficzny znak użytkownika w polu
	move $ra, $t3
	j return_from_sub

player_sign_row:
	addu $t3, $t3, 1
	j row_inner_continue
	
comp_sign_row:
	addu $t3, $t3, -1
	j row_inner_continue

check_col_computer:
		li $t2, 0		# zmienna do pętli
col_loop:
	beq $t2, 3, return_from_sub
	
	mul $t9, $t2, 4		#oblicz relatywny adres pierwszej komórki w rzędzie
	add $t9, $t9, $t0	#oblicz absolutny adres pierwszej komórki
	addu $t2, $t2, 1		#zwiększ iterator pętli o 1
	
	li $t8, 0		# wew iterator
	li $t3, 0		#ustaw sumę zajętych na 0
inner_col_loop:
	beq $t8, 3, inner_col_end
	lw $t6, ($t9)		#załaduj wartość komórki do $t6
	beq $t6, $s0, player_sign_col
	bnez $t6, comp_sign_col
	move $s3, $t8
col_inner_continue:
	addu $t9, $t9, 12		#zwiększ adres o krok
	addu $t8, $t8, 1 
	j inner_col_loop
	
inner_col_end:
	bne $t3, 2, col_loop
	add $t9, $t9, -36	#wroć do adresu pierwszej komórki
	move $t8, $s3
	mul $s3, $s3, 12
	add $t9, $t9, $s3
	
	sw $s5, ($t9)		# Ustawienie znaku komputera na planszy
	move $s4, $s5
	move $t9, $t2
	mul $t8, $t8, 3
	add $t9, $t9, $t8
	move $a3, $t9
	move $t3, $ra
	jal draw_symbol		# zapisz graficzny znak użytkownika w polu
	move $ra, $t3
	j return_from_sub

player_sign_col:
	addu $t3, $t3, 1
	j col_inner_continue
	
comp_sign_col:
	addu $t3, $t3, -1
	j col_inner_continue

check_diag_computer:
	beq $t2, 16, return_from_sub	# jeśli skończyliśmy sprawdzać, kontynuuj grę
	li $t3, 16
	sub $t3, $t3, $t2		# $t3 będzie naszym przemieszczeniem między komórkami
	
	add $t9, $t2, $t0		#zapisz adres pierwszej komórki w $t6
	add $t8, $t9, $t3		# oblicz adres drugiej komórki - pierwsza plus przesunięcie
	
	addu $t2, $t2, 8
	
	lw $t6, ($t9)		#załaduj wartość pierwszej komórki do $t6
	
	beq $t6, 0, check_diag_loop	#jeśli w pierwszej komórce nic nie ma, sprawdź drugą przekątną
	lw $t7, ($t8)		#załaduj wartość drugiej komórki do $t7
	bne $t7, $t6, check_diag_loop	#jeśli nie są takie same, to przejdź do sprawdzenia kolejnej przekątnej
	
	add $t8, $t8, $t3		#zapisz absolutny adres trzeciej komórki
	
	lw $t7, ($t8)		#załaduj wartość trzeciej komórki do $t7
	bne $t7, $t6, check_diag_loop	#jeśli nie są takie same, to przejdź do sprawdzenia kolejnej przekątnej
	
	j end_of_check
	
	
	
	
	
	
	
	
	
	
	#logic
	
	
	addiu $t5, $t5, 1	#Zwiększenie licznika zajętych pól
	
	jal check_winner 	# Sprawdzenie, czy runda rozstrzygnięta
	beq $s6, 1,round_end	# jeśli w $s6 jest 1, to runda się zakończyła (jest zwycięzca)
	beq $t5, 9, round_end	#jeśli wykonano już 9 ruchów, to runda się kończy
	  
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
	li $t3, 0		# zmienna pomocnicza do pętli kolumn
	li $t2, 0		# zmienna do pętli przekątnych
	li $s6, 0		# ustaw rundę  na niezakończoną
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
	
end_of_check:	
	li $s6, 1		#zapisz, że runda się zakończyła
	beq $t6, $s0, player_won_round	#jeśli znak w komórce pierwszej zgadza się ze znakiem gracza, wygrał rundę
	 	
	li $s2, -1		#w przeciwnym przypadku zapisz, że komputer wygrał
	j return_from_sub
	
check_col_loop:
	beq $t3, 3, check_diag_loop
	
	mul $t9, $t3, 4		#oblicz relatywny adres pierwszej komórki w kolumnie
	addu $t3, $t3, 1		#zwiększ iterator pętli o 1
	move $t8, $t9		#zduplikuj w celu obliczenia adresu drugiej komórki
	add $t8, $t8, 12		#zapisz relatywny adres drugiej komórki 
	add $t9, $t9, $t0	#oblicz absolutny adres pierwszej komórki
	add $t8, $t8, $t0	#oblicz absolutny adres drugiej komórki
	lw $t6, ($t9)		#załaduj wartość pierwszej komórki do $t6
	
	beq $t6, 0, check_col_loop
	lw $t7, ($t8)		#załaduj wartość drugiej komórki do $t7
	bne $t7, $t6, check_col_loop	#jeśli nie są takie same, to przejdź do sprawdzenia kolejnego kolumny
	
	add $t8, $t8, 12		#zapisz absolutny adres trzeciej komórki
	lw $t7, ($t8)		#załaduj wartość trzeciej komórki do $t7
	bne $t7, $t6, check_col_loop	#jeśli nie są takie same, to przejdź do sprawdzenia kolejnej kolumny
	
	j end_of_check
	
check_diag_loop:
	beq $t2, 16, return_from_sub	# jeśli skończyliśmy sprawdzać, kontynuuj grę
	li $t3, 16
	sub $t3, $t3, $t2		# $t3 będzie naszym przemieszczeniem między komórkami
	
	add $t9, $t2, $t0		#zapisz adres pierwszej komórki w $t6
	add $t8, $t9, $t3		# oblicz adres drugiej komórki - pierwsza plus przesunięcie
	
	addu $t2, $t2, 8
	
	lw $t6, ($t9)		#załaduj wartość pierwszej komórki do $t6
	
	beq $t6, 0, check_diag_loop	#jeśli w pierwszej komórce nic nie ma, sprawdź drugą przekątną
	lw $t7, ($t8)		#załaduj wartość drugiej komórki do $t7
	bne $t7, $t6, check_diag_loop	#jeśli nie są takie same, to przejdź do sprawdzenia kolejnej przekątnej
	
	add $t8, $t8, $t3		#zapisz absolutny adres trzeciej komórki
	
	lw $t7, ($t8)		#załaduj wartość trzeciej komórki do $t7
	bne $t7, $t6, check_diag_loop	#jeśli nie są takie same, to przejdź do sprawdzenia kolejnej przekątnej
	
	j end_of_check
	
player_won_round:
	li $s2, 1		#zapisz, że gracz wygrał
	j return_from_sub
	
return_from_sub:
	jr $ra

draw_symbol:
	move $t6, $a3		# Ponownie pobierz wybrane pole
	addiu $t6, $t6, -1
	la $t9, board_layout		# załaduj adres planszy
	mul $t7, $t6, 2		# na planszy każdy znak znajduje się na co drugim polu
	add $t9, $t9, $t7
	sb $s4, ($t9)
	jr $ra

round_end:

	addi $sp, $sp, -4	#przesuń stack pointer o słowo
	sw $s2, ($sp)		#zapisz wynik rundy
	
	jal results_after_round
	
	beq $t1, $s1, game_end	#jeśli liczba zagranych rund jest równa oczewkiwanej liczbie, przejdź do podsumowania

	j game_loop

results_after_round:

	li $v0, 4
	la $a0, board_msg		#info że wyświetlimy wyniki  
	syscall
	li $v0, 4
	la $a0, board_layout		# Wyświetlanie planszy po raz ostatni
	syscall

	la $a0, result_msg 		# Wyświetlanie wyników rund
	li $v0, 4
	syscall

round_winner:
	beqz $s2, draw
	beq $s2, 1, won
	b lost
	
continue_res:
	li $v0, 4
	syscall
		
	jr $ra

draw:
	la $a0, draw_msg
	j continue_res
won:
	la $a0, won_msg
	j continue_res
lost:
	la $a0, lost_msg
	j continue_res
	
game_end:
	 addu $t1, $t1, -1	#zaczynamy indeksowanie rund od liczba - 1
	 li $t9, 1		#numer rundy dla którego podajemy wyniki
	 
end_loop:
	
	
	move $t8, $t1		#skopiuj liczbę pozostałych rund
	mul $t8, $t8, 4		#oblicz relatywny adres przesunięcia
	add $t8, $t8, $sp	#oblicz absolutny adres wyniku rundy na stacku bez przesuwania $sp
	
	lw $s2, ($t8)		#zapisz wartość z adresu w $t8 do $s2- jest to wynik rundy
	
	li $v0, 4
	la $a0, round_no_msg	#wyświelt nagłówek runda
	syscall
	
	li $v0, 1
	move $a0, $t9		#Wyświetl numer rundy
	syscall
	
	li $v0, 4
	la $a0, round_follow	# zrób miejsce na wynik
	syscall
	
	jal round_winner
	
	beqz $t1, end
	
	addu $t9, $t9, 1
	addu $t1, $t1, -1
	
	j end_loop
	
end:
	li $v0, 10                  # Zakończenie programu
	syscall



