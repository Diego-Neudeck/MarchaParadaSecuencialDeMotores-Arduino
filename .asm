;
; ejercicio2.asm
;
; Created: 16/9/2019 11:07:14
; Author : Diego Neudeck

;----------recien despues de los 12s que se aprieta prender, se puede apagar-----------
;------------------el encendido de los motores es activo en alto-----------------------
;--------------------------------------------------------------------------------------

		.include "m2560def.inc"
;definiciones----------------------------------------------
		.def aux1=R16
		.def aux2=R17
		.def aux3=R18
		.def enciende=R19
		.def apaga=R20
		.def A=R21
		.def B=R22
		.def C=R23

;conf entrada salida---------------------------------------
		.org 0x0000
;configuracion de puerto-----------------------------------
		ldi aux1, 0x00
		out DDRA, aux1			;uno de los puertos de A como entrada
		out PUD, aux1
		ldi aux1, 0x03
		out PORTA, aux1			;activo res pull up interna
		ldi aux1, 0x0F
		out DDRB, aux1			;configuro 4 puertos de B como salida
		clr aux1
		out PORTB,aux1			;inicializo las salidas en cero

;----------------------------------------------------------
;--------------------PROGRAMA PRINCIPAL--------------------
;----------------------------------------------------------

LOOP1:	ldi aux1,0x02
		in enciende, PINA				;el bits 0 es la entrada que enciende
		in apaga, PINA					;el bits 1 es la entrada que apaga
		cp aux1, enciende
		breq on0
p1:		ldi aux2,0x01
		cp aux2, apaga
		breq off0
		rjmp LOOP1
on0:	call on
		rjmp p1	
off0:	call off
		rjmp LOOP1

;----------------------subrrutina------------------------

;retardo de 3s-------------------------------------------

RETAR:	ldi A,255
LOOP2:	ldi B,255
LOOP3:	ldi C,245
LOOP4:	dec C
		brne LOOP4
		dec B
		brne LOOP3
		dec A
		brne LOOP2
		ret

;retardo 10us---------------------------------------------

RETAR2:	ldi A,5
LOOP5:	ldi B,9
LOOP6:	dec B
		brne LOOP6
		dec A
		brne LOOP5
		ret

;apago los motores----------------------------------------

off:	call RETAR2
		ldi aux2,0x01
		in apaga, PINA
		cp apaga,aux2			;si la entrada de apagado
		brne chau				;esta en alto vuelvo a programa principal
		ldi aux1,0x00
		in aux2,PINB
		cp aux1,aux2
		breq chau
		ldi aux1, 0x07
		out PORTB,aux1			;apago motor 4
		call RETAR
		ldi aux1, 0x03
		out PORTB,aux1         ;apago motor 3
		call RETAR
		ldi aux1, 0x01
		out PORTB,aux1			;apago motor 2
		call RETAR
		ldi aux1, 0x00
		out PORTB,aux1			;apago motor 1
		call RETAR
chau:	ret

;prendo los motores-----------------------------------------------------

on:		call RETAR2				;hago un retardo de 10us
		ldi aux1,0x02	
		in enciende,PINA		;comparo de nuevo la entrada
		cp aux1,enciende		;asi veo si esta en bajo y prendo los mot
		brne retum				;si ya no esta en bajo, vuelvo a prog principal
		ldi aux1, 0x0F			;voy a ver si esta prendido los motores
		in aux2, PINB
		cp aux1,aux2
		breq retum				;si los motores estan prendido, salgo de on
		ldi aux1,0x01
		out PORTB,aux1			;prendo el motor 1
		call RETAR
		ldi aux1,0x03
		out PORTB,aux1			;prendo el motor 2
		call RETAR
		ldi aux1,0x07
		out PORTB,aux1			;prendo el motor 3
		call RETAR
		ldi aux1,0x0F
		out PORTB,aux1			;prendo el motor 4
		call RETAR
retum:	ret


