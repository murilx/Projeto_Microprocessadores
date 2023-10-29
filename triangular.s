# Registradores
# r2 -> Retorno da funcao (Triangular de n)
# r4 ->  Parametro da funcao (n)
# r8 ->  Endereço base
# r9 ->  Contador
# r10 -> n+1
# r11 -> n*(n+1)
  
  .global triangular

  #call stack_save

  # Calcula a soma triangular de um numero por Tn = n*(n+1)/2
  triangular:
    addi r9, r0, 1          # Inicializa r9 (contador)
    addi r10, r4, 1         # r10 recebe r4 + 1 (n+1)
    mov r11, r10            # r11 recebe r10 (inicializa a soma triangular)
    START_LOOP:
      beq r9, r4, END_LOOP    # Loop para somar r4 vezes o r10 (n*(n+1))
        addi r9, r9, 1
        add r11, r11, r10
        br START_LOOP
    END_LOOP:
      srli r2, r11, 1         # r2 recebe r11 dividido por 2

    #call stack_recovery

    ret