 ;W_Comp_Pause created by Remi Lamiaux and Baptiste Ghirardi 
;15/11/2019
;version 1

W1_L			data		7Fh
W1_H			data		7Eh
W2_L			data		7Dh
W2_H			data		7Ch
INF			bit		P3.7
SUP			bit		P3.6
Res_Rt		bit		F0
W_IN			data		P1
Masque		equ		00000011b



				org		0000h
				SJMP		debut
				
				org		0003h
				LJMP		INTech
				
				org		0030h
				
debut:
				MOV		TCON,#00000001b
				MOV		IE,#10000001b
				CLR		INF
				CLR		SUP
		
fin:			SJMP		fin


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
				
INTech:
				MOV		W2_L,W_IN
				MOV		A,W_IN
				RR			A
				RR			A
				MOV		W2_H,A
				RR			A
				RR			A
				MOV		W1_L,A
				RR			A
				RR			A
				MOV		W1_H,A
								
				ANL		W2_L,#Masque
				ANL		W2_H,#Masque
				ANL		W1_L,#Masque
				ANL		W1_H,#Masque
				;Comparaison
				MOV		R0,#W1_H
            MOV		R1,#W2_H
				LCALL		Comp
				MOV		C,Res_Rt
				MOV		INF,C
				CPL		C
				MOV		SUP,C
				LCALL		Pause
				CLR		INF
				CLR		SUP
Fin_INTech:	RETI


;Permet d'attendre environ 5s. Utilise R0, R1, et R2.
Pause:
				MOV		R0,#27h
Rpt_t0:		MOV		R1,#0FFh
Rpt_t1:		MOV		R2,#0FFh
Rpt_t2:		DJNZ		R2,Rpt_t2
				DJNZ		R1,Rpt_t1
				DJNZ		R0,Rpt_t0
fin_Pause:			RET
				

				end  
