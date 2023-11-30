.global cronometer_update 
cronometer_update:
  # Prólogo
  addi sp, sp, -12
  stw r9, 8(sp)
  stw r10, 4(sp)
  stw ra, 0(sp)

  movia r9, CRONOMETER_STATE
  ldw r10, 0(r9)
  andi r9, r10, 1
  beq r9, r0, UPDATE_END          # Se o bit 1 é 0, o cronometro não está ativo
  srli r10, r10, 16               # Desloca os bits para que o valor do cornometro esteja na parte menos significativa 
  movui r9, 0xffff
  beq r10, r9, SKIP_ADD           # Caso o cronometro esteja no valor máximo, não soma
  addi r10, r10, 1                # Soma 1 ao valor atual do cronometro
  SKIP_ADD:
  mov r4, r10                     # Coloca o valor do cronometro como parâmetro
  mov r5, r16                     # Base do display
  call seg7                       # Mostra o valor do cronometro no 7 segmentos

  # Salva os valores atualizados na memória
  movia r9, CRONOMETER_STATE
  slli r10, r10, 16
  addi r10, r10, 1                # Coloca bit 0 = 1 (valor foi apagado quando o registrador foi deslocado para a direita)
  stw r10, 0(r9)

  # Epilogo
  UPDATE_END:
    ldw ra, 0(sp)
    ldw r10, 4(sp)
    ldw r9, 8(sp)
    addi sp, sp, 12
    ret