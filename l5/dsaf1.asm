.data
board: .word 0, 0, 0, 0, 0, 0, 0, 0, 0
results: .word 0, 0
user_symbol: .asciiz " "
opponent_symbol: .asciiz " "
round_number_prompt: .asciiz "Podaj liczbę rund (1-5): "
user_symbol_prompt: .asciiz "Wybierz swój symbol (o - kółko, x - krzyżyk): "
user_move_prompt: .asciiz "Podaj numer pola (1-9): "
opponent_move: .asciiz "Komputer wybiera pole: "
invalid_input_error: .asciiz "Błędne dane wejściowe. Spróbuj ponownie.\n"
board_layout:
    .asciiz " 1 | 2 | 3 \n"
    .asciiz "---+---+---\n"
    .asciiz " 4 | 5 | 6 \n"
    .asciiz "---+---+---\n"
    .asciiz " 7 | 8 | 9 \n"
round_results_header: .asciiz "Wyniki rund:\n"
user_wins_message: .asciiz "Wygrałeś/aś rundę!\n"
opponent_wins_message: .asciiz "Przegrałeś/aś rundę!\n"
draw_message: .asciiz "Remis w rundzie!\n"
total_results_header: .asciiz "Wyniki rywalizacji:\n"
exit_message: .asciiz "Koniec programu.\n"

.text
.globl main

main:
    # Inicjalizacja danych
    li $s0, 5  # Liczba rund
    la $t1, results
    sw $zero, 0($t1)  # Wyzerowanie wyników

    # Pobranie liczby rund od użytkownika
    li $v0, 4
    la $a0, round_number_prompt
    syscall
    li $v0, 5
    syscall
    move $s0, $v0

main_loop:
    # Reset planszy
    la $t1, board
    li $t2, 0
    li $t3, 9
reset_board:
    sw $zero, ($t1)
    addiu $t1, $t1, 4
    addiu $t2, $t2, 1
    bgtz $t3, reset_board

    # Wybór symbolu użytkownika
    li $v0, 4
    la $a0, user_symbol_prompt
    syscall
    li $v0, 12
    syscall
    move $t6, $v0
    beq $t6, 111, set_user_symbol
    beq $t6, 120, set_user_symbol
    j invalid_input_user_symbol

set_user_symbol:
    beq $t6, 111, set_opponent_symbol_x
    li $t8, 0
    j set_opponent_symbol

set_opponent_symbol_x:
    li $t8, 1

set_opponent_symbol:
    la $t1, user_symbol
    sw $t6, ($t1)

    # Rozgrywka
    li $s1, 0  # Numer rundy

play_round:
    # Wyświetlenie planszy
    li $v0, 4
    la $a0, board_layout
    syscall

    # Ruch użytkownika
    li $v0, 4
    la $a0, user_move_prompt
    syscall
    li $v0, 5
    syscall
    move $t7, $v0
    jal validate_user_move

    # Aktualizacja planszy
    la $t1, board
    add $t2, $zero, $t7
    sll $t2, $t2, 2
    add $t1, $t1, $t2
    la $t2, user_symbol
    lw $t3, ($t2)
    sw $t3, ($t1)

    # Sprawdzenie warunków wygranej użytkownika
    jal check_user_win_conditions
    beqz $t9, computer_move

    # Użytkownik wygrał rundę
    jal user_wins_round
    j next_round

computer_move:
    # Ruch komputera
    jal make_computer_move

    # Aktualizacja planszy
    la $t1, board
    add $t2, $zero, $s3
    sll $t2, $t2, 2
    add $t1, $t1, $t2
    la $t2, opponent_symbol
    lw $t3, ($t2)
    sw $t3, ($t1)

    # Wyświetlenie ruchu komputera
    li $v0, 4
    la $a0, opponent_move
    syscall
    li $v0, 1
    move $a0, $s3
    syscall

    # Sprawdzenie warunków wygranej komputera
    jal check_opponent_win_conditions
    beqz $t9, check_draw

    # Komputer wygrał rundę
    jal opponent_wins_round
    j next_round

check_draw:
    # Sprawdzenie remisu
    la $t1, board
    li $t2, 0
    li $t3, 9
check_draw_loop:
    lw $t4, ($t1)
    bnez $t4, next_field_check_draw
    addiu $t2, $t2, 1
    addiu $t1, $t1, 4
    addiu $t3, $t3, -1
    bgtz $t3, check_draw_loop

    beqz $t2, game_end

    # Remis w rundzie
    jal draw_round
    j next_round

next_field_check_draw:
    addiu $t1, $t1, 4
    j check_draw_loop

game_end:
    # Zapisanie wyniku rundy
    beqz $t9, user_wins
    j next_round

user_wins:
    la $t1, results
    lw $t2, 0($t1)
    addiu $t2, $t2, 1
    sw $t2, 0($t1)
    j next_round

next_round:
    addiu $s1, $s1, -1
    bgtz $s1, main_loop

    # Wyświetlenie wyników rywalizacji
    li $v0, 4
    la $a0, total_results_header
    syscall

    la $t1, results
    lw $t2, 0($t1)
    lw $t3, 4($t1)
    li $v0, 1
    move $a0, $t2
    syscall
    li $v0, 4
    la $a0, user_wins_message
    syscall
    li $v0, 1
    move $a0, $t3
    syscall
    li $v0, 4
    la $a0, opponent_wins_message
    syscall
    j exit_program

validate_user_move:
    bltz $t7, invalid_user_move
    bgtz $t7, invalid_user_move
    li $t9, 0
    jr $ra

invalid_user_move:
    li $t9, 1
    jr $ra

check_user_win_conditions:
    # Sprawdzenie wygranej użytkownika w wierszach
    la $t1, board
    li $t2, 0
    li $t3, 3
check_user_rows:
    add $t4, $t1, $t2
    lw $t5, ($t4)
    bne $t5, $t3, next_row_check_user
    addiu $t2, $t2, 4
    addiu $t3, $t3, 1
    bgtz $t3, check_user_rows

    # Wygrana użytkownika w wierszach
    li $t9, 1
    jr $ra

next_row_check_user:
    addiu $t2, $t2, 4
    j check_user_rows

check_opponent_win_conditions:
    # Sprawdzenie wygranej komputera w wierszach
    la $t1, board
    li $t2, 0
    li $t3, 3
check_opponent_rows:
    add $t4, $t1, $t2
    lw $t5, ($t4)
    bne $t5, $t8, next_row_check_opponent
    addiu $t2, $t2, 4
    addiu $t3, $t3, 1
    bgtz $t3, check_opponent_rows

    # Wygrana komputera w wierszach
    li $t9, 1
    jr $ra

next_row_check_opponent:
    addiu $t2, $t2, 4
    j check_opponent_rows

make_computer_move:
    # Ruch komputera - przykładowa strategia: wstawienie znaku na pierwsze wolne pole
    la $t1, board
    li $t2, 0
make_computer_move_loop:
    lw $t3, ($t1)
    beqz $t3, set_computer_move
    addiu $t2, $t2, 1
    addiu $t1, $t1, 4
    bgtz $t2, make_computer_move_loop

    j game_end

set_computer_move:
    move $s3, $t2
    jr $ra

user_wins_round:
    li $v0, 4
    la $a0, user_wins_message
    syscall
    jr $ra

opponent_wins_round:
    li $v0, 4
    la $a0, opponent_wins_message
    syscall
    jr $ra

draw_round:
    li $v0, 4
    la $a0, draw_message
    syscall
    jr $ra

invalid_input_user_symbol:
    li $v0, 4
    la $a0, invalid_input_error
    syscall
    j set_user_symbol

exit_program:
    li $v0, 4
    la $a0, exit_message
    syscall

    li $v0, 10
    syscall
