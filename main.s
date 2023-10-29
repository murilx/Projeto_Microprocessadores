# Gabriel Crescencio
# Murilo Magiolo Geraldini
# Ramon Varela Gonzalez

## Registradores:
#   r8  -> Enderço base dos periféricos
#   r9  -> Registrador UART DATA
#   r10 -> Auxiliar
#   r11 -> Auxiliar
#   r12 -> Indice do buffer | Auxiliar

## Constantes
.equ BADDR,       0x10000000
.equ UART_DATA,   0x1000
.equ UART_CTRL,   0x1004
.equ SEG7_ADDR,   0x0020
.equ SWITCH_ADDR, 0x0040
.equ LED_ADDR,    0x0000 

# Códigos ASCII
.equ ENTER_CH, 0x0A
.equ ZERO_CH,  0x30
.equ ONE_CH,   0x31
.equ TWO_CH,   0x32

## Rotina de Tratamento de Interrupção 
.org 0x20

## Rotina principal 
.global _start
_start:
    movi r12, 0                     # Inicializa o indíce do buffer como 0
    movia r8, BADDR

    MAIN_READ:
        ldwio r9, UART_DATA(r8)
        andi r10, r9, 0x8000        # Pega o bit RVALID do registrador UART DATA
        beq r10, r0, MAIN_READ      # Caso não tenha novos dados válidos, volta pro começo

    # Armazenar a entrada de usuário em um buffer
    movi r11, ENTER_CH
    andi r10, r9, 0xff              # Pega os bits DATA do registrador UART DATA
    beq r10, r11, PARSING           # Caso o caracter seja enter, a entrada do usuário terminou

    movia r11, BUFFER
    add r11, r11, r12               # Próximo valor livre da memória
    stb r10, 0(r11)                 # Armazena o caracter na memória
    addi r12, r12, 1                # Atualiza o indice para a próxima região de memória:w
    br MAIN_READ                    # Volta para esperar o próximo caracter

    PARSING:
        movia r11, BUFFER
        ldb r10, 0(r11)                 # Pega o primeiro caracter do comando
        movi r12, ZERO_CH
        beq r10, r12, MAIN_LED          # Primeiro caracter = 0, o comando é de led
        movi r12, ONE_CH                
        beq r10, r12, MAIN_TRIANGLE     # Primeiro caracter = 1, o comando é número triangular 
        movi r12, TWO_CH
        beq r10, r12, MAIN_CRONOMETER   # Primeiro caracter = 2, o comando é de cronometro
        br INVALID_CMD                  # Primeiro caracter diferente desses, o comando é inválido
        
    MAIN_LED:
        addi r11, r11, 1
        ldb r10, 0(r11)
        movi r12, ZERO_CH               # Segundo caracter = 0, comando de piscagem
        beq r10, r12, LED_BLINK_START
        movi r12, ONE_CH                # Segundo caracter = 1, comando de cancelamento de piscagem
        beq r10, r12, LED_BLINK_CANCEL
        br INVALID_CMD                  # Segundo caracter diferente desses, o comando é inválido
        
        LED_BLINK_START:
            # call led_pisca
            movi r15, 1
            br END_PARSING

        LED_BLINK_CANCEL:
            # call led_apaga
            movi r15, 2
            br END_PARSING

    MAIN_TRIANGLE:
        addi r11, r11, 1
        ldb r10, 0(r11)
        movi r12, ZERO_CH               # Segundo caracter = 0, comando de calculo de número triangular 
        beq r10, r12, CALC_TRIANGLE
        br INVALID_CMD                  # Segundo caracter != 1, o comando é inválido 

        CALC_TRIANGLE:
            call read_switches
            mov r4, r2
            call triangular
            mov r4, r2
            call seg7
            movi r15, 3
            br END_PARSING

    MAIN_CRONOMETER:
        addi r11, r11, 1
        ldb r10, 0(r11)
        movi r12, ZERO_CH               # Segundo caracter = 0, comando de iniciar cronometro
        beq r10, r12, CRONOMETER_START
        movi r12, ONE_CH                # Segundo caracter = 1, comando de finalizar cronometro 
        beq r10, r12, CRONOMETER_CANCEL
        br INVALID_CMD                  # Segundo caracter != 1 ou 2, o comando é inválido 
        
        CRONOMETER_START:
            # call cronometro_inicio
            movi r15, 4
            br END_PARSING

        CRONOMETER_CANCEL:
            # call cronometro_fim
            movi r15, 5
            br END_PARSING

    INVALID_CMD:
    END_PARSING:
        movi r12, 0                     # Reinicia o índice para 0
        br MAIN_READ                    # Volta para esperar o próximo caracter


BUFFER:
.skip 0x20

    