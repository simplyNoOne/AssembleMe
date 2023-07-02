
.data 
	zero: 			.float 0.0
	sign:			.float 1.0
	increase:		.float 2.0
	multip:			.float 4.0
	
	prompt:		.asciiz "Podaj dokladnosc przyblizenia: "		#prompt do pobrania dokladnosci
	answer_info:	.asciiz "Obliczone przyblizenia: "		#info przed podaniem wyniku
	
.text

main:
	li $v0, 4	#wyswietlinie prosby o podanie dokladnosci
	la $a0, prompt
	syscall
	
	li $v0, 5	#informacja o zapisaniu liczby typu int
	syscall
	
	move $t0, $v0	#zapisanie pobranej liczby(dokładność) do $t5
	
	blt $t0, 1, main #jeśli wartość mniejsza od 1, pobierz ponownie, nie może być dokładność 0
	
	
start_function:
	l.s $f1, zero
	l.s $f2, sign		#znak skladnika
	l.s $f4, sign		# wartosc mianownika 
	l.s $f10, increase	#o ile zwiekszy się wartość w kolejnej iteracji
	l.s $f11, multip		#ile razy pomnożymy powstałą sumę
	li $t1, 0		#liczba obliczonych składnikow
	
	addi $sp, $sp, -4	#przesunięcie sp, żeby zrobić miejsce an adres
	la $t7, function_finished
	sw $t7, ($sp)		#zapisanie adresu funkcji powrotu po zakończeniu funckji
	
	addi $sp, $sp, -4	#przesunięcie stack pointera, aby zrobić miejsce na float 
	swc1 $f1, ($sp)		#zapisanie zerowego składnika, który nie wpłynie na sumę 
	
	
	
loop:
	div.s  $f1, $f2, $f4		# Obliczenie kolejnego składnika sumy i zapisanie w $f1
	
	addi $sp, $sp, -4	#przesunięcie sp, żeby zrobić miejsce an adres
	la $t7, continue_loop	#wczytanie adresu powrotu
	sw $t7, ($sp)		#zapisanie adresu funkcji powrotu po zakończeniu funckji
	
	addi $sp, $sp, -4	#przesunięcie stack pointera, aby zrobić miejsce na float 
	swc1 $f1, ($sp)		#zapisanie aktualnego składnika na stacku 
	
	add.s $f4, $f4, $f10	# Zwiększenie mianownika o 2
	neg.s $f2, $f2		# Zmiana znaku składnika sumy(na zmianę dodajemy i odejmujemy)
	addiu $t1, $t1, 1	# Inkrementacja liczby obliczonych składnków

        blt $t1, $t0, loop	# Powtarzanie, jeśli liczba kolejnych składników jest mniejsza niż żądana

#jeśli osiągnięto oczekiwaną dokładność
	addi $sp, $sp, -4	#przesunięcie stack pointera, aby zrobić miejsce na float 
	sw $zero, ($sp)		#zapisanie początkowej sumy (czyli zero) na końcu stacku 
	
#to tutaj będziemy przechodzić wychodząc z rekurencji
continue_loop:
	lwc1 $f6, ($sp)		#załadowanie ze stosu poprzedniej sumy
	addi $sp, $sp, 4 	#przesunięcie stack pointera, odczytać kolejny składnik
	
	lwc1 $f5, ($sp)		#załadowanie kolejnego składnika do dodania
	addi $sp, $sp, 4 	#przesunięcie sp, żeby uzyskać adres powrotu	
	
	add.s $f4, $f5, $f6	#dodanie do poprzedniej sumy pobranego składnika i zapisanie w $f4
	
	lw $t7, ($sp)		#zczytanie adresu funkcji powrotu
	swc1 $f4, ($sp)		#zapisanie aktualnej sumy (z $f4) na końcu stosu
	
	jr $t7			#przejście do adresu powrotu
	
function_finished:
	lwc1 $f6, ($sp)		#załadowanie ze stosu sumy końcowej
	addi $sp, $sp, 4 	#przesunięcie sp, żeby nic nie zostało na stosie
	
	mul.s $f12, $f6, $f11	# Przemnożenie zawartości $f6 przez 4 i zapisanie w $f12
    	
    	li $v0, 4		#Wyświetlienie info poprzedzającego wynik
    	la $a0, answer_info
    	syscall
    	
    	li $v0, 2		#poinformowanie o wyświetlaniu float (z rejestru $f12)
	syscall
	
end:
	li $v0, 10		#koniec programu
	syscall
	
#wygląda na to, że pamięć na stacku kończy się przy dokładności przekraczającej 500tys
