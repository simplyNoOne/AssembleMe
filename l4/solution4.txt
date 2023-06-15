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
	
	
start_function:
	l.s $f1, zero
	l.s $f2, sign		#znak skladnika
	l.s $f4, sign		# wartosc mianownika 
	l.s $f10, increase	#o ile zwiekszy się wartość w kolejnej iteracji
	l.s $f11, multip		#ile razy pomnożymy powstałą sumę
	li $t1, 0		#liczba obliczonych składnikow
	addi $sp, $sp, -4	#przesunięcie stack pointera, aby zrobić miejsce na float 
	swc1 $f1, ($sp)		#zapisanie aktualnej sumy na stacku 
	
	
	
loop:
	div.s  $f1, $f2, $f4		# Obliczenie kolejnego składnika sumy i zapisanie w $f1
	
	lwc1 $f6, ($sp)			#załadowanie ze stosu aktualnej sumy
	add.s $f8, $f6, $f1		#dodanie do sumy obliczonej wartości i zapisanie w $f8
	swc1 $f8, ($sp)			#zapisanie zawartości $f8 na stacku

	
	add.s $f4, $f4, $f10		# Zwiększenie mianownika o 2
	neg.s $f2, $f2			# Zmiana znaku składnika sumy(na zmianę dodajemy i odejmujemy)
	addiu $t1, $t1, 1		# Inkrementacja liczby obliczonych składnków

        blt $t1, $t0, loop		# Powtarzanie, jeśli liczba kolejnych składników jest mniejsza niż żądana

result:
	lwc1 $f8, ($sp)		# Pobranie wyniku z wierzchołka stosu i zapisanie w $f8
	mul.s $f12, $f8, $f11	# Przemnożenie zawartości $f8 przez 4 i zapisanie w $f12
    	
    	li $v0, 4		#Wyświetlienie info poprzedzającego wynik
    	la $a0, answer_info
    	syscall
    	
    	li $v0, 2		#poinformowanie o wyświetlaniu float (z rejestru $f12)
	syscall
	
	
end:
	li $v0, 10		#koniec programu
	syscall
	
	