.data
	newline: .asciiz "\n"
	first_prompt: .asciiz "Wpisz S aby szyfrowac i D aby deszyfrowac: "
	wrong_choice: .asciiz "Nie istnieje taki wybor, sprobuj ponownie"
	enter_key: .asciiz "Podaj klucz: "
	invalid_key: .asciiz "Klucz moze zawierac tylko cyfry od 1 do 8"
	enter_value: .asciiz "Podaj wiadomosc na ktorej wykona sie operacja: "
	value: .space 51
	message: .space 50
	key: .space 9
	permutation: .space 8
	return: .space 56
	result: .space 50
	result_info: .asciiz "Wynik operacji: "


.text
main:
	jal prompt_operation

prompt_operation:

	li $v0, 4			#informujemy że będziemy wyświetlać ascii
	la $a0, first_prompt		#ładujemy zawartość do wyświetlenia do $a0
	syscall 				#wykonujemy operacje
	    		
    	
    	li $v0, 12			# Pobranie znaku od użytkownika
    	syscall
	move $t0, $v0			# zapisanie znaku w $t0
    
	li $t1, 's'			#załadowanie liter do porównania
	li $t2, 'S'
	beq $t0, $t1, cipher_start	#jeśli porównywana litera pasuje, przejdź do operacji
	beq $t0, $t2, cipher_start
	
	li $t1, 'd'			#załadowanie liter do porównania
	li $t2, 'D'
	beq $t0, $t1, cipher_start
	beq $t0, $t2, cipher_start
	
	li $v0, 4			#newline
	la $a0, newline	
	syscall 
	
	li $v0, 4			#informujemy że nie ma takiego wyboru i pytamy ponownie
	la $a0, wrong_choice		
	syscall
	
	li $v0, 4			#newline
	la $a0, newline	
	syscall 		
	
	jal prompt_operation		# jeśli podano zły wybór pobież ponownie
	
		
	
cipher_start:
	jal get_key
	
cipher_main:

	la $t0, key
	la $t1, permutation		#zapisz adres powstałej permutacji w $t1
	li $t4, 49			#iterator
	
permutation_loop:
	lb $t2, ($t0)
	beqz $t2, permutation_ready 	# jeśli zero, to ciąg się skończył, wyjdź z pętli
	beq $t4, 9, permutation_ready
	sub $t2, $t2, 49			#przekonwertuj wartość ascii na int
	
	add $t5, $t1, $t2		#przesuń adres o ilośc bitów zapisanych w $t2
	sb $t4, ($t5)			#zapisz odpowiednią cyfrę na pozycji $t5
	
	addiu $t0, $t0, 1		#zwiększ indexy iteracji
	addiu $t4, $t4, 1
	j permutation_loop		#wróc do początku pętli
	
permutation_ready:
	
	la $t0, message			#zapisz adres message do $t0
	la $t1, permutation		#zapisz adres szyfru do $t1
	la $t9, return			#zapisz adres w którym pojawi się wynik do $t9
	li $t8, 1			#index pozycji w szyfrze
	li $t7, 0			#przesunięcie cyklu
	

cipher_loop:
	lb $t2, ($t0)			#zapisz obecną literę do przestawienia w rejestrze $t2
	lb $t3, ($t1)			#zapisz nową pozycję litery w oparciu o szyfr do $t3
	
	beqz $t2 cleanup			#jeśli skończył się ciąg, to upewnij się, że wyświetli się całość
	
	sub $t3, $t3, 49			#przekonwertuj wartośc ascii na int
	add $t6, $t3, $t7
	add $t6, $t6, $t9
	sb $t2, ($t6)
	
	
	addiu $t0, $t0, 1		#inkrementuj wartości w pętli o 1
	addiu $t1, $t1, 1
	addiu $t8, $t8, 1
	
	beq $t8, 9, increase_cycle	# zwiększ liczbę okresów
	
	j cipher_loop		# kontynuuj pętlę
	
	
increase_cycle:
	li $t8, 1		#zresetuj index do początkowej wartości
	add $t7, $t7, 8		#przesuń okres o długość klucza (8)
	la $t1, permutation 	#ustaw wskaźnik miejsca w permutacji z powrotem na początek
	j cipher_loop
	
cleanup:
	lb $t3, ($t1)
	sub $t3, $t3, 49			#przekonwertuj wartośc ascii na int
	add $t6, $t3, $t7
	add $t6, $t6, $t9
	li $t2, '*'			#wpisz we wszystkie pozostałe miejsca gwiazdki
	sb $t2, ($t6)
	
	addiu $t1, $t1, 1	#zwiększ indexy
	addiu $t8, $t8, 1
	
	beq $t8, 9, cut_stars	# pousuwaj gwiazdki
	
	j cleanup		# kontynuuj wpisywanie gwiazdek
	
cut_stars:

	la $t5, result		#ustaw adres ostatecznego wyniku do $t5
	la $t0, return		#zapisz ciąg z gwiazdkami w $t0
	
cut_loop:
	lb $t1, ($t0)    		#załaduj znak z adresu odpowiadającego $t0
    	beqz $t1, show_result   		# jeśli doszliśmy do końca wiadomości, pokaż wynik
	
    	blt $t1, 'A', remove_star	# jeśli znak jest gwiazdką to go usuń
    	bgt $t1, 'Z', remove_star
    	
    	sb $t1, ($t5)		#zapisz znak do ciągu docelowego


    	addiu $t0, $t0, 1 	 # Zwiększ adresy o 1 aby przejsć do kolejnego elementu
    	addiu $t5, $t5, 1
    	j cut_loop           	 # Wróć do początku pętli 
    	
remove_star:
	addiu $t0, $t0, 1 	 # Zwiększ adresy o 1 aby przejsć do kolejnego elementu
	j cut_loop

show_result:

	li $v0, 4			#poinformuj o wyswietlaniu wyniku
	la $a0, result_info	
	syscall 
	
	li $v0, 4			#newline
	la $a0, newline	
	syscall 
	
	li $v0, 4			#pokaż wynik
	la $a0, result	
	syscall 
	
	j end
get_key:

	li $v0, 4			#newline
	la $a0, newline	
	syscall 

	li $v0, 4			#wyświetlamy prompt do wpisania klucza
	la $a0, enter_key		
	syscall
	
	li $v0, 8			#ustaw tryb pobierania ciągów
	la $a0, key			# ustaw gdzie zapisać ciąg znaków
	la $a1, 9			#zapisz do $a1 liczbę znaków do pobrania( musi być o 1 większa, bo znak end) 
	syscall
	
	la $t0, key
	
key_loop:
    	lb $t1, ($t0)   			# załaduj byte znajdujący się pod tym adresem
    	beqz $t1, positive_key_check    #jeśli doszliśmy do końca ciągu, wyjdź z pętli

	
    	blt $t1, '1', not_a_number	#jeśli wartość ascii jest poza tym zakresem to nie jest liczbą
    	bgt $t1, '8', not_a_number


    	addiu $t0, $t0, 1 	 	# przejdź do kolejnego znaku w ciągu przez zwiększenie adresu o 1
    	j key_loop           		 #wróć do początku pętli

	
not_a_number:				# działanie jeśli klucz zawiera coś poza liczbą 1-8

	li $v0, 4			#newline
	la $a0, newline	
	syscall 

	li $v0, 4			#wyświetl info ze klucz jest zly
	la $a0, invalid_key		
	syscall
	
	li $v0, 4			#newline
	la $a0, newline	
	syscall 
	
	jal get_key			# ponownie pobierz klucz
	
positive_key_check:

	li $v0, 4			#newline
	la $a0, newline	
	syscall 
	
	jal get_message			# przejdź do zczytywania wiadomosci
	
get_message:
	
	li $v0, 4			#wyświetl prompt do wpisania wiadomosci
	la $a0, enter_value		
	syscall
	
	li $v0, 8			#ustaw tryb pobierania ciągów
	la $a0, value			# ustaw gdzie zapisać ciąg znaków
	la $a1, 51			#zapisz do $a1 liczbę znaków do pobrania
	syscall
	
	la $t0, value			# zapisz adres etykiety value do $t0
	la $t3, message			# zapisz adres nowej wiadomości do $t3
	
message_loop:
    	lb $t1, ($t0)    		#załaduj znak z adresu odpowiadającego $t0
    	beqz $t1, message_normalized   # jeśli doszliśmy do końca wiadomości, wyjdź z pętli
	
    	blt $t1, 'A', remove	# jeśli znak nie jest dużą literą to go usuń
    	bgt $t1, 'Z', remove
    	
    	sb $t1, ($t3)		#zapisz znak do ciągu docelowego


    	addiu $t0, $t0, 1 	 # Zwiększ adresy o 1 aby przejsć do kolejnego elementu
    	addiu $t3, $t3, 1
    	j message_loop            # Wróć do początku pętli 
    	
remove:				# usuń znak przez jego pominięcie
	addiu $t0, $t0, 1	
	j message_loop		# wróć do pętli

message_normalized:
	jal cipher_main		#przejdź do szyfrowania
	
end:
