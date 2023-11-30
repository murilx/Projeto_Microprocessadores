# Registradores
# r2  -> Retorno da reminder (reminder da divisao)
# r4  -> Parametro recebido (valor a mostrar no display)
# r5  -> Parametro recebido (base numerica)
# r8 ->  Endereço base
# r9 ->  Endereço atual
# r10 -> Ponto de troca de conjunto de 7seg / Auxiliar
# r11 -> Inteiro da divisao / Posicao na TABLE de 7seg / Codigo 7seg do numero
# r12 -> Divisor para calcular a casa decimal
# r13 -> Base numerica
# r14 -> Contador
# r15 -> Valor a ser dividido

.equ SEG7_ADDR,   0x0023
.equ SEG7_ADDR2,  0x0033

/* Constantes */
#.include "constants"

.global seg7

seg7:

   # Prólogo
   addi sp, sp, -32              # Cria um frame de 8 bytes
   stw ra, 28(sp)
   stw r9, 24(sp)
   stw r10, 20(sp)
   stw r11, 16(sp)
   stw r12, 12(sp)
   stw r13, 8(sp)
   stw r14, 4(sp)
   stw r15, 0(sp)
   
   # Salva o valor a ser armazenado no 7 segmentos
   # Esse salvamento permitirá a troca de base no futuro
   movi r9, SEG7_VALUE
   stw r4, 0(r9)

   # Ajusta divisor para a base selecionada
   mov r13, r5
   movi r14, 7
   movi r12, 1

   BASE_GET:
      beq r14, r0, END_BASE_GET
         mul r12, r12, r13
         subi r14, r14, 1
         br BASE_GET

   END_BASE_GET:

   add r15, r4, r0
   
   addi r14, r0, 8
   addi r10, r0, 4
   addi r9, r8, SEG7_ADDR2       # Ajusta posicao da memoria do primeiro 7seg

   SEG7_LOOP:
   beq r14, r0, END_SEG7
      div r11, r15, r12          # Acha o valor da casa atual

      # Salva os parametros para o reminder
      add r6, r11, r0            # Valor calculado da casa
      add r7, r12, r0            # Casa atual
      add r5, r15, r0            # Valor cujo reminder vai ser calculado
      call reminder

      add r15, r2, r0            # Salva retorno do reminder no registrador
      slli r11, r11, 2           # Multiplica por 4
      addi r11, r11, TABLE       # Seta posição da "tradução" para 7-seg em TABLE
      ldw r11, 0(r11)            # Lê o valor da tabela
      stbio r11, 0(r9)           # Insere o valor no 7-seg
      divu r12, r12, r13         # Ajusta para a proxima casa decimal
      subi r14, r14, 1
      
      beq r14, r10, NEXT_SEG7
         subi r9, r9, 1          # Ajusta posicao da memoria do proximo 7seg
         br SEG7_LOOP
      
      NEXT_SEG7:
         addi r9, r8, SEG7_ADDR
         br SEG7_LOOP
   
   END_SEG7:
   # Escreve a base utilizada no inicio do 7 segmentos
      addi r9, r8, SEG7_ADDR2       # Ajusta posicao da memoria do primeiro 7seg
      movi r10, 8
      beq r13, r10, OCT_WRITE
      movi r10, 10
      beq r13, r10, DEC_WRITE
      movi r10, 16
      beq r13, r10, HEX_WRITE

      OCT_WRITE:
         movi r11, 0x5c
         stbio r11, 0(r9)           # Insere o valor no 7-seg
         br BASE_WRITE_END

      DEC_WRITE:
         movi r11, 0x5e
         stbio r11, 0(r9)           # Insere o valor no 7-seg
         br BASE_WRITE_END

      HEX_WRITE:
         movi r11, 0x74
         stbio r11, 0(r9)           # Insere o valor no 7-seg
         br BASE_WRITE_END

   BASE_WRITE_END:
      

   # Epilogo
   ldw r15, 0(sp)
   ldw r14, 4(sp)
   ldw r13, 8(sp)
   ldw r12, 12(sp)
   ldw r11, 16(sp)
   ldw r10, 20(sp)
   ldw r9, 24(sp)
   ldw ra, 28(sp)
   addi sp, sp, 32
   ret

reminder:
# r5  -> Parametro para reminder (Dividendo)
# r6  -> Parametro para reminder (Parte inteira da divisao)
# r7  -> Parametro para reminder (Divisor)
# r10 -> Dividendo
# r11 -> Parte inteira da divisao
# r12 -> Divisor da casa
# r13 -> Contador do branch
# r14 -> Resultado da soma

   # Prólogo
   addi sp, sp, -20              # Ajusta o stack pointer
   stw r10, 16(sp)
   stw r11, 12(sp)
   stw r12, 8(sp)
   stw r13, 4(sp)
   stw r14, 0(sp)

   mov r10, r5
   mov r11, r6
   mov r12, r7

   addi r13, r0, 1               # Inicializa contador do branch
   add r2, r0, r0                # Reminder
   add r14, r0, r0               # Resultado da soma

START_REM_LOOP:
   bgt r13, r11, END_REM_LOOP    # Loop para somar r11 vezes o r12
      addi r13, r13, 1
      add r14, r14, r12
      br START_REM_LOOP
END_REM_LOOP:

ble r12, r10, OK
    sub r2, r10, r0              # Se r12 < r10, reminder novo = r10
    br RET
OK:
    sub r2, r10, r14             # Acha o reminder do r10 por r12

RET:
   # Epilogo
   ldw r14, 0(sp)
   ldw r13, 4(sp)
   ldw r12, 8(sp)
   ldw r11, 12(sp)
   ldw r10, 16(sp)
   addi sp, sp, 20
   ret

 TABLE:
 .word 0x3f, 0x6, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x7, 0x7f, 0x6f, 0x77, 0x7c, 0x39, 0x5e, 0x79, 0x71, 0x74