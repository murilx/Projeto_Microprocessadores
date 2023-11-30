/* Constantes */
.include "constants.s"

/* Escreve um caracter no terminal do Altera Monitor */
.global PUTC_UART
PUTC_UART:
    # Prólogo
    addi sp, sp, -12                     # Cria um frame de 8 bytes
    stw r9, 8(sp) 
    stw r10, 4(sp)
    stw ra, 0(sp)

    # Código principal    
    ldwio r9, UART_CTRL(r8)
    andhi r9, r9, 0xffff                # Verifica por espaço para escrita
    beq r9, r0, END_PUTC                # Caso não haja espaço, ignora o caracter
    stwio r4, UART_DATA(r8)             # Envia o caracter

    END_PUTC:
        # Epilogo
        ldw ra, 0(sp)
        ldw r10, 4(sp)
        ldw r9, 8(sp)
        addi sp, sp, 12
        ret


/* Escreve uma string no terminal do Altera Monitor */
.global PUTS_UART
PUTS_UART:
    # Prólogo
    addi sp, sp, -8 # Cria um frame de 4 bytes
    stw r9, 4(sp)
    stw ra, 0(sp)

    # Armazena a posição de memória da string recebida por argumento em outro registrador
    mov r9, r4 

    PUTS_LOOP:
        ldb r4, 0(r9)
        beq r4, r0, END_PUTS
        call PUTC_UART
        addi r9, r9, 1
        br PUTS_LOOP

    END_PUTS:
        # Epilogo
        ldw ra, 0(sp)
        ldw r9, 4(sp)
        addi sp, sp, 8
        ret