# Registradores
# r2 ->  Retorno da funcao (read_switches)
# r8 ->  Endereço base

.equ SWITCH_ADDR, 0x0040

.global read_switches
  		
  read_switches:

  ldwio r2, SWITCH_ADDR(r8)
  andi r2, r2, 0xff		    # Só considera os 8 bits menos significativos (SW_0 - SW_7)

  ret