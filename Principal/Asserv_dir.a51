;Asservissement direction
Droit				bit			P1.6
Gauche			bit			P1.7

;V1: précharge du compteur à l'état haut
Dir1_init_H   	equ 			0FAh						;TODO: à ajuster
Dir1_init_L   	equ 			024h+10					;V0_Init_L = N_L + Nr	TODO: à ajuster
Dir0_init_H  	equ 			0FCh						;TODO: à ajuster
Dir0_init_L   	equ 			018h+10					;TODO: à ajuster
Mot1_init_H		equ			0FAh
Mot1_init_L		equ			0ECh+10					;1.3ms
Mot0_init_H		equ			0C0h
Mot0_init_L		equ			0B8h+2

PAS_dir			equ			10
PAS_mot			equ			10

Min_dir1_H		equ			0FCh

Min_dir1_L		equ			018h+10
Max_dir1_H		equ			0F8h
Max_dir1_L		equ			030h+10
Min_dir0_H		equ			0FEh
Min_dir0_L		equ			00Ch+10
Max_dir0_H		equ			0FAh
Max_dir0_L		equ			024h+10
Centre_dir1_H	equ			0FAh
Centre_dir1_L	equ			024h+10
Centre_dir0_H	equ			0FCh
Centre_dir0_L	equ         018h+10
Min_mot1_L		equ			0Ah+10						;TODO
Min_mot1_H		equ			0FBh						;TODO
Max_mot1_L		equ			088h+10
Max_mot1_H		equ			0FAh
Stop_mot1_H		equ			0FBh
Stop_mot1_L		equ			00Ah
Stop_mot0_H		equ			0C0h
Stop_mot0_L		equ			09Ah



Dir1_L			data			7Fh
Dir1_H			data			7Eh
Dir0_L			data			7Dh
Dir0_H			data			7Ch
Mot0_L			data			7Bh
Mot0_H			data			7Ah
Mot1_L			data			79h
Mot1_H			data			78h
Etape				data			77h

Compteur_tick	data			76h
Compteur_20ms	data			75h
Use_To_Comp		data			74h

                                               	
MODIF				bit			00h						;modification autorisée si MODIF à 1

Dir				bit			P1.4
Mot				bit			P1.5




;Table des vecteurs d'IT
   				org			0000h
					SJMP			debut
					
					
					org			003h
					LJMP			IT0_tick
					
					org			000Bh
					LJMP			INT_Timer0
				
					org			0030h

;________________________________________________________	
;Programme Principal   			
debut: 		
				MOV			SP,#2Fh		
				LCALL			Init
rpt:

si:			JNB			MODIF,fsi
				CLR			MODIF
				LCALL			Asserv_dir
fsi:

			
jsq:			SJMP			rpt

fin:


;________________________________________________________	
;Routine d'initialisation
Init:
		      MOV			TMOD,#011h
		      MOV			IE,#10000011b
		      SETB			IT0
		      CLR			P3.0
		      CLR			P3.1
		      

;Initialisation des valeurs de précharge du timer
		      MOV			Dir0_L,#Dir0_Init_L
		      MOV			Dir0_H,#Dir0_Init_H
		      MOV			Dir1_L,#Dir1_Init_L
		      MOV			Dir1_H,#Dir1_Init_H
		      MOV			Mot0_L,#Mot0_Init_L
		      MOV			Mot0_H,#Mot0_Init_H
		      MOV			Mot1_L,#Mot1_Init_L
		      MOV			Mot1_H,#Mot1_Init_H
		      
;On commence par l'étape 1, pour laquelle Dir est à 0
		      CLR			Dir
		      CLR			Mot
		      CLR			MODIF
		      MOV			Etape,#1
		      
;On initialise Compteur_20ms pour ne pas compter le premier passage par l'étape 1
		      
		      MOV			Compteur_20ms,#0FFh
		      MOV			Compteur_tick,#0
		      
;Initialisation et démarrage du timer0		
		      MOV			TL0,#Dir1_Init_L					
		      MOV			TH0,#Dir1_Init_H					
		      CLR			TF0
		      SETB 			Dir					
		      SETB			TR0	
FIN_Init:	RET


;Routine d'interruption du Timer 0
INT_Timer0: 
				PUSH			Acc
				MOV 			A,Etape
CaseEtape2:	CJNE	      A,#1,CaseEtape1
				INC			Etape
				MOV			R2,Dir0_L
		      MOV			R1,Dir0_H
		      CLR			Dir
				SJMP			FinEtape      
CaseEtape1:	CJNE	      A,#4,CaseEtape4
				MOV			Etape,#1
		      MOV			R2,Dir1_L
		      MOV			R1,Dir1_H
		      INC			Compteur_20ms
		      SETB			Dir
		      
				SJMP			FinEtape      
CaseEtape4:	CJNE	      A,#3,CaseEtape3
				INC			Etape
				MOV			R2,Mot0_L
		      MOV			R1,Mot0_H
		      SETB			MODIF 
		      CLR			Mot
		      
				SJMP			FinEtape      
CaseEtape3:	CJNE	      A,#2,FinEtape
				INC			Etape
		      MOV			R2,Mot1_L
		      MOV			R1,Mot1_H
		      SETB			Mot
FinEtape:								
				CLR			TR0					
				MOV			A,TL0					;1CM
				ADD			A,R2					;1CM
		      MOV			TL0,A					;1CM
		      MOV			A,TH0					;1CM
		      ADDC			A,R1					;1CM
		      MOV			TH0,A					;1CM
		      CLR			TF0					;1CM
		      SETB			TR0					;1CM
		      POP			Acc					;2CM

FIN_INT_Timer0:	
 				RETI

;Routine d'asservissement en direction: si trop à droite décrément de 0.1ms si trop à gauche incrément de 0.1ms
Asserv_dir:
Si_gauche:	JNB 			Gauche,FSi_gauche

				MOV			A,Dir1_L
				ADD			A,#PAS_dir
				MOV			Dir1_L,A
				MOV			A,Dir1_H
				ADDC			A,#0
				MOV			Dir1_H,A	
				
				MOV			R0,#Dir1_H
				MOV			R3,#Min_dir1_H
				MOV			R4,#Min_dir1_L
				
				LCALL			COMP
				
Si_sup:		JNC			Sinon_sup

				MOV			A,Dir0_L
				CLR			C
				SUBB			A,#PAS_dir
				MOV			Dir0_L,A
				MOV			A,Dir0_H
				SUBB			A,#0
				MOV			Dir0_H,A
				LJMP			FSi_gauche
				
Sinon_sup:
				MOV			Dir1_L,#Min_dir1_L
				MOV			Dir1_H,#Min_dir1_H
				MOV			Dir0_L,#Max_dir0_L
				MOV			Dir0_H,#Max_dir0_H

Finsi_sup:	LJMP			Finsi_inf_sup
				
FSi_gauche:	

Si_droit:	JNB			Droit,FSi_droit
	
				MOV			A,Dir1_L
				CLR			C
				SUBB			A,#PAS_dir
				MOV			Dir1_L,A
				MOV			A,Dir1_H
				SUBB			A,#0
				MOV			Dir1_H,A

				MOV			R0,#Dir1_H
				MOV			R3,#Max_dir1_H
				MOV			R4,#Max_dir1_L
				
				LCALL			COMP
				
Si_inf:		JC				Sinon_inf
				
				MOV			A,Dir0_L
				ADD			A,#PAS_dir
				MOV			Dir0_L,A
				MOV			A,Dir0_H
				ADDC			A,#0
				MOV			Dir0_H,A							

				LJMP			FSi_droit
				
Sinon_inf:
				MOV			Dir1_L,#Max_dir1_L
				MOV			Dir1_H,#Max_dir1_H
				MOV			Dir0_L,#Min_dir0_L
				MOV			Dir0_H,#Min_dir0_H 
				
FSi_droit:

Si_centre:	JB				Gauche,FSI_centre
				JB				Droit,FSI_centre
				
				MOV			Dir1_L,#Centre_dir1_L
				MOV			Dir1_H,#Centre_dir1_H
				MOV			Dir0_L,#Centre_dir0_L
				MOV			Dir0_H,#Centre_dir0_H
				
FSI_centre:
Finsi_inf_sup:
				RET
				

;routine comparaison
COMP:
				PUSH 	Acc
				CLR 	C				 
				MOV 	A,@R0		
				SUBB 	A,R3	
Si_Inf_comp:
				JNZ 	Finsi_Inf_comp
				INC 	R0
				MOV 	A,@R0		
				SUBB 	A,R4	
Finsi_Inf_comp:
				POP	Acc
Fin_Comp:
				RET	
				


;Routine d'interruption externe levée dès bande noire
IT0_tick:
		
Fin_IT0_tick:
				RETI	
						
				end
				





 






































