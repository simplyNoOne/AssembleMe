.data
input:  .space 80
label:  .asciiz "\nWylosowane numery:  "

.text
main:

    # Wyświetlenie zapytania
    li $v0, 4		# Wywołanie systemowe dla drukowania łańcucha         
    la $a0, label	# Adres łańcucha (etykieta label)
    syscall

    # Wczytanie ciągu znakowego
    li $v0, 8		# Wywołanie systemowe dla wczytania łańcucha     
    la $a0, input	# Adres bufora (etykieta input)    
    li $a1, 80		# Ilość znaków do wczytania
    syscall
          
    # Przekształcenie ciągu liczb
    li $t0, 48		# Wartość ASCII '0'
    li $t1, 57		# Wartość ASCII '9'
    la $t2, input	# Ciąg wejściowy
    add $t3, $t2, $zero	# t3 staje się wskaźnikiem na odpowiedni bit ciągu, i nie powinno zostać zmienione w czasie iteracji
    addi $t8, $t2, 80	# Adres ostatniego znaku ciągu, nie można zmieniać wartości
    
compare:
    # Sprawdzamy, czy nie wyjść z pętli
    beq $t8, $t3, print	# Wydrukuj wynik, jeśli sprawdzono 80 bitów
    
    # Porównujemy znak z zakresem ASCII cyfr
    lb $t9, ($t3)	# Wczytujemy wartość z tego adresu, aby ją porównać
    slt $t5, $t9, $t0	# t5 = 1, jeśli znak jest mniejszy niż '0'
    slt $t6, $t1, $t9	# t6 = 1, jeśli znak jest większy niż '9'

    # Sprawdzamy, czy znak jest cyfrą
    or $t7, $t5, $t6	# t7 = 1, jeśli t5 lub t6 jest 1 (znak jest mniejszy niż '0' lub większy niż '9')

    # Jeśli $t7 wynosi 1, znak nie jest poprawną liczbą całkowitą
    beqz $t7, is_int 	# Skok, jeśli t7 wynosi zero (znak jest poprawną liczbą całkowitą)
    j increment		# Jeśli to nie cyfra, to zwiększamy wartość wskaźnika
    
increment:
    addi $t3, $t3, 1	# Zwiększamy wartość t3 o 1, po to aby w kolejnym wykonaniu pętli porównać następny znak
    j compare		# Wywołujemy funkcję compare ponownie, i tak tworzy się pętla
    
is_int:
    li $t7, '*'		# Znak zastępujący liczbę
    sb $t7, ($t3)	# Zapisujemy znak w pamięci, w miejscu t3, czyli ostatnio sprawdzanego adresu
    j increment		# Po zamienieniu wartości zwiększamy wskaźnik
       
print:    
    # Wyświetlenie labela i przekształconego ciągu
    li $v0, 4 		# Wywołanie systemowe dla wydrukowania łańcucha 
    la $a0, label	# Adres łańcucha (etykieta label) 
    syscall
    
    li $v0, 4		# Wywołanie systemowe dla wydrukowania zmodyfikowanego łańcucha 
    la $a0, input 	# Adres łańcucha (etykieta input) 
    syscall
    
    
    
