# Registradores
# r4 ->  Parametro da funcao (valor triangular)
# r8 ->  Endereço base
# r9 ->  Auxiliar
# r10 -> Auxiliar
# r11 -> Auxiliar
# r12 -> 
# r13 ->   

  .equ SEG7_ADDR,  0x0020
  .equ SEG7_ADDR2, 0x0030
  .global seg7

  seg7:

     addi r4, r0, 0x30DF

    # HEX0
    andi r9, r4, 0xf            # Captura os 4 bits menos significativos do parametro (1º dig hex)
    slli r9, r9, 2              # Multiplica por 4
    addi r9, r9, TABLE          # Seta posição da "tradução" para 7-seg
    ldw r10, 0(r9)              # Lê o valor da tabela
    addi r11, r8, SEG7_ADDR # Ajusta posicao da memoria do primeiro 7seg
    stbio r10, 0(r11)           # Set o valor no 7-seg

    # HEX1
    andi r9, r4, 0xf0            # Captura os próximos 4 bits menos significativos do parametro (2º dig hex)
    srli r9, r9, 4
    slli r9, r9, 2              # Multiplica por 4
    addi r9, r9, TABLE          # Seta posição da "tradução" para 7-seg
    ldw r10, 0(r9)              # Lê o valor da tabela
    addi r11, r11, 1            # Ajusta posicao da memoria do proximo 7seg
    stbio r10, 0(r11)           # Set o valor no 7-seg

    # HEX2
    andi r9, r4, 0xf00            # Captura os próximos 4 bits menos significativos do parametro (3º dig hex)
    srli r9, r9, 8
    slli r9, r9, 2              # Multiplica por 4
    addi r9, r9, TABLE          # Seta posição da "tradução" para 7-seg
    ldw r10, 0(r9)              # Lê o valor da tabela
    addi r11, r11, 1            # Ajusta posicao da memoria do proximo 7seg
    stbio r10, 0(r11)           # Set o valor no 7-seg

    # HEX3
    andi r9, r4, 0xf000            # Captura os próximos 4 bits menos significativos do parametro (4º dig hex)
    srli r9, r9, 12
    slli r9, r9, 2              # Multiplica por 4
    addi r9, r9, TABLE          # Seta posição da "tradução" para 7-seg
    ldw r10, 0(r9)              # Lê o valor da tabela
    addi r11, r11, 1            # Ajusta posicao da memoria do proximo 7seg
    stbio r10, 0(r11)           # Set o valor no 7-seg

    # HEX4
    andi r9, r4, 0xf            # Captura os próximos 4 bits menos significativos do parametro (5º dig hex)
    srli r9, r9, 16
    slli r9, r9, 2              # Multiplica por 4
    addi r9, r9, TABLE          # Seta posição da "tradução" para 7-seg
    ldw r10, 0(r9)              # Lê o valor da tabela
    addi r11, r11, 1            # Ajusta posicao da memoria do proximo 7seg
    stbio r10, 0(r11)           # Set o valor no 7-seg

    # HEX5
    andi r9, r4, 0xf0            # Captura os próximos 4 bits menos significativos do parametro (6º dig hex)
    srli r9, r9, 20
    slli r9, r9, 2              # Multiplica por 4
    addi r9, r9, TABLE          # Seta posição da "tradução" para 7-seg
    ldw r10, 0(r9)              # Lê o valor da tabela
    #addi r11, r0, SEG7_ADDR2            # Ajusta posicao da memoria do quinto 7seg
    #addi r10, r0, 0x40	# Ajusta o valor para exibir '-'    
    addi r11, r11, 1            # Ajusta posicao da memoria do proximo 7seg
    stbio r10, 0(r11)           # Set o valor no 7-seg

    # HEX6
    andi r9, r4, 0xf00            # Captura os próximos 4 bits menos significativos do parametro (7º dig hex)
    srli r9, r9, 24
    slli r9, r9, 2              # Multiplica por 4
    addi r9, r9, TABLE          # Seta posição da "tradução" para 7-seg
    ldw r10, 0(r9)              # Lê o valor da tabela
    addi r11, r11, 1            # Ajusta posicao da memoria do proximo 7seg
    stbio r10, 0(r11)           # Set o valor no 7-seg


    # HEX7
    andi r9, r4, 0xf000            # Captura os próximos 4 bits menos significativos do parametro (8º dig hex)
    srli r9, r9, 28
    slli r9, r9, 2              # Multiplica por 4
    addi r9, r9, TABLE          # Seta posição da "tradução" para 7-seg
    ldw r10, 0(r9)              # Lê o valor da tabela
    addi r11, r11, 1            # Ajusta posicao da memoria do proximo 7seg
    stbio r10, 0(r11)           # Set o valor no 7-seg

    addi r9, r9, TABLE          # Seta posição da "tradução" para 7-seg
    ldw r10, 0(r9)              # Lê o valor da tabela
    addi r11, r11, 1            # Ajusta posicao da memoria do proximo 7seg
    stbio r10, 0(r11)           # Set o valor no 7-seg

  
    #ret
END:
    br END


 TABLE:
 .word 0x3f, 0x6, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x7, 0x7f, 0x6f, 0x77, 0x7c, 0x39, 0x5e, 0x79, 0x71, 0x40