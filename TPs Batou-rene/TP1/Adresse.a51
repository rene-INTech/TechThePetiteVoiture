;Adresse
;created by Rémi and Baptiste
;23/10/2019
;version 0

Adr			data		P0
Val			data		P1
Capteur_H	data		P2
Capteur_T	data		P3
humidite		data		2Fh
temp_F		data		30h
temp_C		data		31h
Flag			equ		R1
Offset		equ		2Fh

				org		0000h
				
debut:
				MOV		humidite,Capteur_H
				MOV		temp_F,Capteur_T
				MOV		A,temp_F
				SUBB		A,#32
				MOV		B,#9
				DIV		AB 
				MOV		B,#5
				MUL		AB
				MOV		temp_C,A
				MOV		Flag,Adr
				MOV		A,Flag
				ADD		A,#Offset
				MOV		R0,A
				MOV		Val,@R0
fin:			SJMP		debut
				end
