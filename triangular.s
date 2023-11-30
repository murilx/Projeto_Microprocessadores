# Registradores
# r2 -> Retorno da funcao (Triangular de n)
# r4 ->  Parametro da funcao (n)
# r8 ->  Endereço base
# r9 ->  Contador
# r10 -> n+1
# r11 -> n*(n+1)
  
  .global triangular
  
  # Calcula a soma triangular de um numero por Tn = n*(n+1)/2
  triangular:
    # Prólogo
    addi sp, sp, -12
    stw r9, 8(sp) 
    stw r10, 4(sp)
    stw r11, 0(sp)
  
    addi r9, r4, 1                # Inicializa r9 (contador) (n+1)
    mov r10, r4                   # r10 recebe r4 (n)
    mov r11, r0                   # r11 recebe 0 (inicializa a soma triangular)
    START_TRI_LOOP:
      beq r9, r0, END_TRI_LOOP    # Loop para somar r9 vezes o r10 (n*(n+1))
        subi r9, r9, 1
        add r11, r11, r10
        br START_TRI_LOOP
    END_TRI_LOOP:
      srli r2, r11, 1             # r2 recebe r11 dividido por 2

    # Epilogo
    ldw r11, 0(sp)
    ldw r10, 4(sp)
    ldw r9, 8(sp)
    addi sp, sp, 12
    ret