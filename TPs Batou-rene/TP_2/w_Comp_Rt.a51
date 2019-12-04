;W_Comp_Rt
;created by Remi Lamiaux and Baptiste Ghirardi 
;13/11/2019
;version 1

W1_L			data		7Fh
W1_H			data		7Eh
W2_L			data		7Dh
W2_H			data		7Ch
RES			bit		P3.7
Res_Rt		bit		F0

				org		0000h
				
debut:		MOV		R0,#W1_H
            MOV		R1,#W2_H
				LCALL		Comp
				MOV		C,Res_Rt
				MOV		RES,C
fin:			SJMP		debut


;Compare 2 nombres
;Paramètres: Adresses des octets de poids fort des nombres a comparer dans R0 et R1
;Retourne: 1 si ((R0))<((R1)) et 0 sinon, dans F0
Comp:
				PUSH		Acc
				MOV		A,@R0
				CLR 		C
				SUBB		A,@R1
Si:			JNZ		finSi
				INC		R0
				INC		R1
            MOV		A,@R0
            CLR		C
            SUBB		A,@R1
finSi:		MOV		Res_Rt,C
FinComp:		POP		Acc
				RET

				end 
