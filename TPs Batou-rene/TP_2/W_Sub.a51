;W_Sub
;created by Remi Lamiaux and Baptiste Ghirardi 
;13/11/2019
;version 1

W1_L			data		7Fh
W1_H			data		7Eh
W2_L			data		7Dh
W2_H			data		7Ch
RES_L			equ		R0
RES_H			equ		R1

				org		0000h
				
debut:
				MOV		A,W1_L
				CLR 		C
				SUBB		A,W2_L
				MOV		RES_L,A
				MOV		A,W1_H
				SUBB		A,W2_H
				MOV		RES_H,A
fin:			SJMP		debut

				end
