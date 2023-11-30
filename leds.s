/* Constantes */
.include "constants.s"


/* Registradores:
    r4  -> Argumento: indice do buffer
    r9  -> Caracter do número a ser transformado
    r10 -> Número do led a ser ligado
    r11 -> Valores de comparação

    retorna:
        O número do led
        -1 caso entrada inválida
*/
led_get:
    # Prólogo
    addi sp, sp, -12
    stw r9, 8(sp)
    stw r10, 4(sp)
    stw r11, 0(sp)

    mov r10, r0                     # Zera o valor do registrador

    GET_NUMBERS:
        addi r4, r4, 1              # Próximo caracter do buffer
        ldb r9, 0(r4)               # Caracter atual
        
        # Verifica se o número é maior que 18
        movi r11, 17
        bgt r10, r11, INVALID_INPUT

        # Ignora espaços em branco
        movi r11, SPACE_CH
        beq r9, r11, GET_NUMBERS

        # Verifica se chegou ao final do argumento
        beq r9, r0, GET_END

        # Verifica se o caracter é um número
        addi r9, r9, -48           # Subtrai 0x30 para converter de caracter para número
        movi r11, 9
        bgt r9, r11, INVALID_INPUT
        movi r11, 0
        blt r9, r11, INVALID_INPUT

        muli r10, r10, 10           # Move o número uma casa para comportar a próxima unidade
        add r10, r10, r9            # Armazena o resultado em r10
        mov r2, r10                 # Armazena o resultado parcial no registrador de retorno
        br GET_NUMBERS 

    INVALID_INPUT:
        movi r2, -1
        br GET_END
    
    GET_END:
        ldw r11, 0(sp)
        ldw r10, 4(sp)
        ldw r9, 8(sp)
        addi sp, sp, 12
        ret

/* Registradores:
    r4  -> Argumento: indice do buffer
    r5  -> Argumento: 0 = set | 1 = unset
    r9  -> Caracter do número a ser transformado
    r10 -> Número do led a ser ligado
    r11 -> Valores de comparação | Insere o novo valor em ACTIVE_LEDS
    r12 -> Valores de ACTIVE_LEDS
    r13 -> Endereço de ACTIVE_LEDS
*/
.global led_set
led_set:
    # Prólogo
    addi sp, sp, -24
    stw r9, 20(sp)
    stw r10, 16(sp)
    stw r11, 12(sp)
    stw r12, 8(sp)
    stw r13, 4(sp)    
    stw ra, 0(sp)

    mov r10, r4  # Armazena a posição do buffer que inicia o argumento (Necessário para mensagem de erro) 
    call led_get
    movi r11, -1
    beq r11, r2, LED_BLINK_INVALID_INPUT

    # Marca a posição do led selecionado como 1
    mov r10, r2
    movi r11, 1
    sll r11, r11, r10
        
    # Recupera o vetor de leds da memória
    movia r13, ACTIVE_LEDS 
    ldw r12, 0(r13)

    # Define se vai ativar e desativar o LED
    beq r5, r0, SET
    
    UNSET:
        and r9, r11, r12
        beq r9, r0, LED_BLINK_END  # Caso o led já esteja apagado não faz nada

        # Adiciona o LED no vetor de leds ativos
        sub r12, r12, r11
        stw r12, 0(r13)
        br LED_BLINK_END

    SET: 
        and r9, r11, r12
        bne r9, r0, LED_BLINK_END  # Caso o led já esteja ativo não faz nada

        # Adiciona o LED no vetor de leds ativos
        add r12, r12, r11
        stw r12, 0(r13)
        br LED_BLINK_END

    LED_BLINK_INVALID_INPUT:
        # Escreve a mensagem de erro
        movia r4, INVALID_ARGUMENT_MGS
        call PUTS_UART

        # Escreve qual o valor do argumento invalido
        mov r4, r10
        addi r4, r4, 1
        call PUTS_UART

        # Adiciona '\n' no final
        movia r4, ENTER_CH
        call PUTC_UART

    LED_BLINK_END:
        # Epilogo
        ldw ra, 0(sp)
        ldw r13, 4(sp)    
        ldw r12, 8(sp)
        ldw r11, 12(sp)
        ldw r10, 16(sp)
        ldw r9, 20(sp)
        addi sp, sp, 24
        ret

/* Registradores:
    r4  -> Argumento: indice do buffer
    r5  -> Argumento: 0 = set | 1 = unset
    r9  -> Caracter do número a ser transformado
    r10 -> Número do led a ser ligado
    r11 -> Valores de comparação | Insere o novo valor em ACTIVE_LEDS
    r12 -> Valores de ACTIVE_LEDS
    r13 -> Endereço de ACTIVE_LEDS
*/
/*
.global led_set_range
led_set_range:
    # Prólogo
    addi sp, sp, -24
    stw r9, 20(sp)
    stw r10, 16(sp)
    stw r11, 12(sp)
    stw r12, 8(sp)
    stw r13, 4(sp)    
    stw ra, 0(sp)

    call skip_spaces
    mov r10, r4  # Armazena a posição do buffer que inicia o argumento (Necessário para mensagem de erro) 
    call led_get
    movi r11, -1
    beq r11, r2, LED_BLINK_INVALID_INPUT

    call skip_spaces
    mov r10, r4  # Armazena a posição do buffer que inicia o argumento (Necessário para mensagem de erro) 
    call led_get
    movi r11, -1
    beq r11, r2, LED_BLINK_INVALID_INPUT


    # Marca a posição do led selecionado como 1
    mov r10, r2
    movi r11, 1
    sll r11, r11, r10
        
    # Recupera o vetor de leds da memória
    movia r13, ACTIVE_LEDS 
    ldw r12, 0(r13)

    # Define se vai ativar e desativar o LED
    beq r5, r0, SET
    
    UNSET:
        and r9, r11, r12
        beq r9, r0, LED_BLINK_END  # Caso o led já esteja apagado não faz nada

        # Adiciona o LED no vetor de leds ativos
        sub r12, r12, r11
        stw r12, 0(r13)
        br LED_BLINK_END

    SET: 
        and r9, r11, r12
        bne r9, r0, LED_BLINK_END  # Caso o led já esteja ativo não faz nada

        # Adiciona o LED no vetor de leds ativos
        add r12, r12, r11
        stw r12, 0(r13)
        br LED_BLINK_END

    LED_BLINK_INVALID_INPUT:
        # Escreve a mensagem de erro
        movia r4, INVALID_ARGUMENT_MGS
        call PUTS_UART

        # Escreve qual o valor do argumento invalido
        mov r4, r10
        addi r4, r4, 1
        call PUTS_UART

        # Adiciona '\n' no final
        movia r4, ENTER_CH
        call PUTC_UART

    LED_BLINK_END:
        # Epilogo
        ldw ra, 0(sp)
        ldw r13, 4(sp)    
        ldw r12, 8(sp)
        ldw r11, 12(sp)
        ldw r10, 16(sp)
        ldw r9, 20(sp)
        addi sp, sp, 24
        ret
*/

.global led_all
led_all:
    #Prólogo
    addi sp, sp, -12
    stw r12, 8(sp)
    stw r13, 4(sp)
    stw ra, 0(sp)

    mov r12, r4                 # Recupera argumento recebido
    movia r13, ACTIVE_LEDS      # Lê a posição de memória dos leds
    stw r12, 0(r13)             # Adiciona todos os LEDs no vetor de leds ativos

    # Epilogo
    ldw ra, 0(sp)
    ldw r13, 4(sp)
    ldw r12, 8(sp)
    addi sp, sp, 12
    ret

.global led_none
led_none:
    #Prólogo
    addi sp, sp, -12
    stw r12, 8(sp)
    stw r13, 4(sp)
    stw ra, 0(sp)

    mov r12, r0                 # Recupera argumento recebido
    movia r13, ACTIVE_LEDS      # Lê a posição de memória dos leds
    stw r12, 0(r13)             # Adiciona todos os LEDs no vetor de leds ativos

    # Epilogo
    ldw ra, 0(sp)
    ldw r13, 4(sp)
    ldw r12, 8(sp)
    addi sp, sp, 12
    ret

.global led_on
led_on:
    # Prólogo
    addi sp, sp, -8
    stw r9, 4(sp)
    stw r10, 0(sp)

    movia r9, ACTIVE_LEDS
    ldw r10, 0(r9)                   # Carrega os leds que devem piscar
    stwio r10, LED_ADDR(r8)          # Acende os leds necessários

    # Epilogo
    ldw r10, 0(sp)
    ldw r9, 4(sp)
    addi sp, sp, 8
    ret
    