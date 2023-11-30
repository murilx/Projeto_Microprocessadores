/*
Membros:
Gabriel Crescencio
Murilo Magiolo Geraldini
Ramon Varela Gonzalez
*/

/* Rotina de Tratamento de Interrupção 

Registradores:
    r8 -> Endereço base
    r9 -> Auxiliar
*/
.org 0x20
# Prólogo
addi sp, sp, -8                     # Cria um frame de 8 bytes
stw r9, 4(sp) 
stw r10, 0(sp)

rdctl et, ipending                  # Verifica interrupções 
beq et, r0, OTHER_EXCEPTIONS        # Caso não tenha interrupção, trata outras exceções
subi ea, ea, 4                      # Decrementa 4 de ea (necessário em caso de interrupção) 

andi r9, et, 1                      # Verifica se a interrupção foi causada pelo temporizador (IRQ0)
bne r9, r0, EXT_IRQ0                # Trata interrupção do temporizador
br RTI_END                          # Caso não seja nenhuma interrupção esperada, vai para o final

EXT_IRQ0:
    movia r9, TEMP_COUNTER 
    ldw r10, 0(r9)                  # Valor atual do contador 
    addi r10, r10, 1                # Adiciona 1 ao contador
    stw r10, 0(r9)                  # Armazena o novo valor do contador
    andi r10, r10, 1                # Verifica se o contador é par ou impar
    beq r10, r0, EVEN_COUNTER 

    # Impar
    call led_on                     # Led aceso
    call cronometer_update          # Cronometro +1
    stwio r0, TEMP_STS(r8)          # Escreve TO (Timeout) para 0
    br RTI_END

    # Par: Led apagado
    EVEN_COUNTER:
    stwio r0, LED_ADDR(r8)          # Apaga todos os leds
    stwio r0, TEMP_STS(r8)          # Escreve TO (Timeout) para 0
    br RTI_END

OTHER_EXCEPTIONS:
    br RTI_END

RTI_END:
    # Epilogo
    ldw r10, 0(sp)
    ldw r9, 4(sp)
    addi sp, sp, 8
    eret

/* Includes */
.include "constants.s"

/* Rotina Principal 

Registradores:
    r8  -> Enderço base dos periféricos
    r16 -> Valor da base numerica do 7 segmentos
    r17 -> Auxiliar
    r18 -> Valores que são carregados ou que serão armazenados na memória | Salva resultado de mascara
    r19 -> Posições da memória (BUFFER, CRONOMETER_STATE)
    r20 -> Caracter no parser
    r21 -> Indice do buffer
*/
.global _start
_start:
    movia sp, 0x007FFFFC            # Inicializa a stack no maior endereço da SDRAM
    movi r20, 0                     # Inicializa o indíce do buffer como 0
    movia r8, BADDR
    movi r16, 10

    # Zera registradores usados
    mov r21, r0

    # Habilita interrupção
    movi r17, 1
    wrctl status, r17                # PIE = 1
    wrctl ienable, r17               # Temporizador (IRQ0)

    # Determina o intervalo que o temporizador gerará interrupção
    # Valor da contagem é 500ms (50MHz/2 = 25000000)
    movi r17, 0x17D
    stwio r17, TEMP_S_HI(r8)
    movi r17, 0x7840
    stwio r17, TEMP_S_LO(r8)

    # Habilita interrupção do temporizador (ITO = 1) e inicializa a contagem (START = 1)
    movi r17, 7 
    stwio r17, TEMP_CTRL(r8)          

    # Escreve o prompt para o usuário
    PROMPT_WRITE:
        movia r4, TEXT_PROMPT 
        call PUTS_UART

    MAIN_READ:
        ldwio r17, UART_DATA(r8)
        andi r18, r17, 0x8000       # Pega o bit RVALID do registrador UART DATA
        beq r18, r0, MAIN_READ      # Caso não tenha novos dados válidos, volta pro começo

    # Armazenar a entrada de usuário em um buffer
    movi r20, ENTER_CH
    andi r18, r17, 0xff             # Pega os bits DATA do registrador UART DATA
    mov r4, r18                     # Coloca o caracter como argumento
    call PUTC_UART                  # Escreve o caracter no terminal
    beq r18, r20, PARSING           # Caso o caracter seja enter, a entrada do usuário terminou

    # Verifica se ainda há espaço no buffer para armazenar dados
    movi r20, BUFFER_SIZE
    beq r20, r21, MAIN_READ

    movia r19, BUFFER
    add r19, r19, r21               # Próximo valor livre da memória
    stb r18, 0(r19)                 # Armazena o caracter na memória
    addi r21, r21, 1                # Atualiza o indice para a próxima região de memória
    br MAIN_READ                    # Volta para esperar o próximo caracter

    PARSING:
        # Zera o próximo caracter do buffer
        movia r19, BUFFER
        add r19, r19, r21
        stb r0, 0(r19)

        movia r19, BUFFER
        ldb r18, 0(r19)                 # Pega o primeiro caracter do comando
        addi r18, r18, -48              # Converte de caracter para número
        movi r20, 0
        beq r18, r20, MAIN_LED          # Primeiro caracter = 0, o comando é de led
        movi r20, 1                
        beq r18, r20, MAIN_TRIANGLE     # Primeiro caracter = 1, o comando é número triangular 
        movi r20, 2
        beq r18, r20, MAIN_CRONOMETER   # Primeiro caracter = 2, o comando é de cronometro
        movi r20, 3
        beq r18, r20, MAIN_BASE         # Primeiro caracter = 3, o comando é de base
        movi r20, ENTER_CH
        beq r18, r20, END_PARSING       # Primeiro caracter = '\n' não faz nada
        br NOT_FOUND_CMD                # Primeiro caracter diferente desses, o comando é inválido
    
    MAIN_LED:
        addi r19, r19, 1
        ldb r18, 0(r19)
        addi r18, r18, -48              # Converte de caracter para número
        movi r20, 0                     # Segundo caracter = 0, comando de piscar
        beq r18, r20, LED_BLINK_START
        movi r20, 1                     # Segundo caracter = 1, comando de cancelamento de piscar
        beq r18, r20, LED_BLINK_CANCEL
        movi r20, 2                     # Segundo caracter = 2, comando de piscar todos os leds
        beq r18, r20, LED_BLINK_ALL
        movi r20, 3                     # Segundo caracter = 3, comando de cancelamento piscar de todos os leds
        beq r18, r20, LED_BLINK_NONE
        br NOT_FOUND_CMD                # Segundo caracter diferente desses, o comando é inválido
        
        LED_BLINK_START:
            mov r4, r19                 # Passa a posição atual do buffer como argumento
            movi r5, 0                  # Ativa o led
            call led_set
            br END_PARSING

        LED_BLINK_CANCEL:
            mov r4, r19                 # Passa a posição atual do buffer como argumento
            movi r5, 1                  # Desativa o led
            call led_set
            br END_PARSING

        LED_BLINK_ALL:
            movia r4, 0x3FFFF           # Passa o conjunto de leds completo como argumento
            call led_all
            br END_PARSING

        LED_BLINK_NONE:
            call led_none
            br END_PARSING

    MAIN_TRIANGLE:
        addi r19, r19, 1
        ldb r18, 0(r19)
        addi r18, r18, -48              # Converte de caracter para número
        movi r20, 0                     # Segundo caracter = 0, comando de calculo de número triangular 
        beq r18, r20, CALC_TRIANGLE
        movi r20, 1                     # Segundo caracter = 1, comando de mostrar o valor dos switches
        beq r18, r20, SHOW_SWITCHES
        br NOT_FOUND_CMD                # Segundo caracter != 1, o comando é inválido 

        CALC_TRIANGLE:
            # Verifica se não caracteres extras (comando invalido)
            addi r19, r19, 1
            ldb r18, 0(r19)
            bne r18, r0, NOT_FOUND_CMD

            call read_switches
            mov r4, r2
            call triangular
            mov r4, r2
            mov r5, r16                 # Base do display
            call seg7
            br END_PARSING

        SHOW_SWITCHES:
            # Verifica se não caracteres extras (comando invalido)
            addi r19, r19, 1
            ldb r18, 0(r19)
            bne r18, r0, NOT_FOUND_CMD

            call read_switches
            mov r4, r2
            mov r5, r16                 # Base do display
            call seg7
            br END_PARSING

    MAIN_CRONOMETER:
        addi r19, r19, 1
        ldb r18, 0(r19)
        addi r18, r18, -48                # Converte de caracter para número
        movi r20, 0                       # Segundo caracter = 0, comando de iniciar cronometro
        beq r18, r20, CRONOMETER_START
        movi r20, 1                       # Segundo caracter = 1, comando de finalizar cronometro 
        beq r18, r20, CRONOMETER_CANCEL
        movi r20, 2                       # Segundo caracter = 2, comando de pausar cronometro
        beq r18, r20, CRONOMETER_PAUSE
        br NOT_FOUND_CMD                  # Segundo caracter != 1 ou 2, o comando é inválido 
        
        CRONOMETER_START:
            # Verifica se não caracteres extras (comando invalido)
            addi r19, r19, 1
            ldb r18, 0(r19)
            bne r18, r0, NOT_FOUND_CMD

            # Inicia o cronometro (Marcar o bit 0 como 1)
            movia r19, CRONOMETER_STATE
            movi r21, 1
            stb r21, 0(r19)
            br END_PARSING

        CRONOMETER_CANCEL:
            # Verifica se não caracteres extras (comando invalido)
            addi r19, r19, 1
            ldb r18, 0(r19)
            bne r18, r0, NOT_FOUND_CMD

            # Para e zera o valor do cronometro
            movia r19, CRONOMETER_STATE
            stw r0, 0(r19)
            br END_PARSING

        CRONOMETER_PAUSE:
            # Verifica se não caracteres extras (comando invalido)
            addi r19, r19, 1
            ldb r18, 0(r19)
            bne r18, r0, NOT_FOUND_CMD

            # Inicia o cronometro (Marcar o bit 0 como 1)
            movia r19, CRONOMETER_STATE
            stb r0, 0(r19)
            br END_PARSING

    # Seleção e conversão de base numérica do display de 7 segmentos
    MAIN_BASE:
        addi r19, r19, 1
        ldb r18, 0(r19)
        addi r18, r18, -48              # Converte de caracter para número
        movi r20, 0                     # Segundo caracter = 0, comando de base octal 
        beq r18, r20, OCT_BASE
        movi r20, 1                     # Segundo caracter = 1, comando de base decimal 
        beq r18, r20, DEC_BASE
        movi r20, 2                     # Segundo caracter = 2, comando de base hexadecimal 
        beq r18, r20, HEX_BASE
        br NOT_FOUND_CMD                # Segundo caracter != 1, o comando é inválido

        OCT_BASE:
            addi r16, r0, 8
            movia r17, SEG7_VALUE
            ldw r4, 0(r17)
            mov r5, r16
            call seg7
            br END_PARSING

        DEC_BASE:
            addi r16, r0, 10
            movia r17, SEG7_VALUE
            ldw r4, 0(r17)
            mov r5, r16
            call seg7
            br END_PARSING

        HEX_BASE:
            addi r16, r0, 16
            movia r17, SEG7_VALUE
            ldw r4, 0(r17)
            mov r5, r16
            call seg7
            br END_PARSING

    NOT_FOUND_CMD:
        # Escreve a mensagem em NOT_FOUND_CMD_MSG
        movia r4, NOT_FOUND_CMD_MSG
        call PUTS_UART
        
        # Escreve qual comando não foi encontrado
        movia r4, BUFFER
        call PUTS_UART

        # Adiciona um '\n' no final
        movi r4, ENTER_CH
        call PUTC_UART

    END_PARSING:
        movi r21, 0                     # Reinicia o índice para 0
        br PROMPT_WRITE                 # Volta para esperar o próximo caracter


BUFFER:
.skip BUFFER_SIZE

/* Área da memória que indica o estado atual do programa
    bit 0 -> Cronometro (1 = ativo, 0 = desativo)
    bit 16-31 -> Valor atual do cronometro
*/
.global CRONOMETER_STATE
CRONOMETER_STATE:
.skip 4 

/* Contador do temporizador 
    Par (último bit = 0):  led apaga
    Impar (último bit = 1) led acende, cronometro + 1
*/
TEMP_COUNTER:
.skip 4

/* Leds ativos: 
    bit n -> LED n (0 = não piscar, 1 = piscar)
*/
.global ACTIVE_LEDS
ACTIVE_LEDS:
.skip 4

# Posição de memória onde será salvo o valor do 7 segmentos
.global SEG7_VALUE
SEG7_VALUE:
.skip 4

.data
TEXT_PROMPT:
.asciz "Entre com um Comando: "

NOT_FOUND_CMD_MSG:
.asciz "Comando nao encontrado: "

.global INVALID_ARGUMENT_MGS
INVALID_ARGUMENT_MGS:
.asciz "Argumento invalido: "

.end

