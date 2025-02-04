;Gene_Rcy
;Created by Lamiaux R�my and Ghirardi Baptiste
;20/11/2019
;version 1

;V1: pr�charge du compteur � l'�tat haut
V1_Init_H   equ 			0FFh
V1_Init_L   equ 			038h+0Ah				;V0_Init_L = N_L + Nr
;V0: pr�charge du compteur � l'�tat bas
V0_Init_H   equ 			0FCh
V0_Init_L   equ 			0E0h+0Ah
PAS			equ			20
Vmin_L		equ			03Fh
Vmin_H		equ			0FCh
Vmax_L		equ			0D7h
Vmax_H		equ			0FFh
;Ressources de la routine Attente
Charge_H	   equ 			03Ch
Charge_L	   equ 			0B0h+08h				;Charge_L = N_L + Nr	

V1_L			data			7Dh
V1_H			data			7Ch
V0_L			data			7Fh
V0_H			data			7Eh
				
Etape			bit			0b

DOWN			bit			P1.0 
UP				bit			P1.1
Gene			bit			P3.0
MODIF			bit			F0						;modification autoris�e si MODIF � 1

;Table des vecteurs d'IT
   			org			0000h
				SJMP			debut
				
				org			000Bh
				LJMP			INT_Timer0
				
				org			0030h

;________________________________________________________	
;Programme Principal   			
debut: 				
				LCALL			Init
rpt:

si:			JNB			Etape,fsi_DOWN
si_UP:		JNB			UP,fsi_UP
				
				MOV			A,V1_L
				CLR			C
				SUBB			A,#PAS
				MOV			V1_L,A
				MOV			A,V1_H
				SUBB			A,#0
				MOV			V1_H,A
				
				MOV			A,V0_L
				ADD			A,#PAS
				MOV			V0_L,A
				MOV			A,V0_H
				ADDC			A,#0
				MOV			V0_H,A
				
				SETB			MODIF
fsi_UP:

si_DOWN:		JNB			DOWN,fsi_DOWN
			
				MOV			A,V0_L
				CLR			C
				SUBB			A,#PAS
				MOV			V0_L,A
				MOV			A,V0_H
				SUBB			A,#0
				MOV			V0_H,A
				
				MOV			A,V1_L
				ADD			A,#PAS
				MOV			V1_L,A
				MOV			A,V1_H
				ADDC			A,#0
				MOV			V1_H,A
				
				SETB			MODIF
fsi_DOWN:

si_MODIF:	JNB			MODIF,fsi_MODIF		;condition v�rifi�e si MODIF vaut 1
				MOV			A,#20
boucle_x20: LCALL       Attente
				DEC			A
				JNZ			boucle_x20
fin_boucle_x20:
				CLR			MODIF
fsi_MODIF:

				
jsq:			SJMP			rpt

fin:


;________________________________________________________	
;Routine d'initialisation
Init:
				MOV			SP,#0Fh
		      MOV			TMOD,#011h
		      MOV			IE,#10000010b
		      CLR			MODIF
		      
		      ;Initialisation des valeurs de pr�charge du timer
		      MOV			V0_L,#V0_Init_L
		      MOV			V0_H,#V0_Init_H
		      MOV			V1_L,#V1_Init_L
		      MOV			V1_H,#V1_Init_H
		      
		      ;On commence par l'�tape 1, pour laquelle Gene est � 0
		      CLR			Gene
		      CLR			Etape
		      
		      ;Initialisation et d�marrage du timer0		
		      MOV			TL0,#V0_Init_L					
		      MOV			TH0,#V0_Init_H					
		      CLR			TF0					
		      SETB			TR0	
FIN_Init:	RET



;________________________________________________________				
;Routine d'attente de 50ms			
Attente: 
				PUSH			Acc		
debut_Attente: 	      
				CLR			TR1
				MOV			A,TL1					;1CM
				ADD			A,#Charge_L			;1CM
		      MOV			TL1,A					;1CM
		      MOV			A,TH1					;1CM
		      ADDC			A,#Charge_H			;1CM
		      MOV			TH1,A					;1CM
		      CLR			TF1					;1CM
		      SETB			TR1					;1CM
Attendre:	JNB			TF1,Attendre								
				POP			Acc
fin_Attente:RET
;________________________________________________________	
;Routine d'interruption du Timer 0
INT_Timer0: 
SI_T0:		JNB	      Etape,SINON_T0
				MOV			R0,V0_L
		      MOV			R1,V0_H
		      CLR			Etape
		      CLR			Gene
FIN_SI_T0:	SJMP			FIN_SINON_T0      
SINON_T0:
		      MOV			R0,V1_L
		      MOV			R1,V1_H
		      SETB			Etape
		      SETB			Gene
FIN_SINON_T0:				
				PUSH			Acc				
				CLR			TR0					
				MOV			A,TL0					;1CM
				ADD			A,R0					;1CM
		      MOV			TL0,A					;1CM
		      MOV			A,TH0					;1CM
		      ADDC			A,R1					;1CM
		      MOV			TH0,A					;1CM
		      CLR			TF0					;1CM
		      POP			Acc					;2CM
		      SETB			TR0					;1CM
FIN_INT_Timer0:	
				RETI
				
				end

;________________________________________________________	
;Routine de comparaison
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

