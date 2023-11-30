/* Constantes */
.equ BUFFER_SIZE, 128

# Endereços de memória
.equ BADDR,       0x10000000
.equ UART_DATA,   0x1000
.equ UART_CTRL,   0x1004
.equ SEG7_ADDR,   0x0023
.equ SEG7_ADDR2,  0x0033
.equ SWITCH_ADDR, 0x0040
.equ LED_ADDR,    0x0000
.equ TEMP_STS,    0x2000
.equ TEMP_CTRL,   0x2004
.equ TEMP_S_LO,   0x2008
.equ TEMP_S_HI,   0x200C

# Códigos ASCII
.equ ENTER_CH, 0x0A
.equ SPACE_CH, 0x20
