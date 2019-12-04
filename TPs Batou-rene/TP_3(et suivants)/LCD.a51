;LCD
;Created by Rémy Lamiaux and Baptiste Ghirardi
;27/11/2019
;version 1.0

BF					bit					P2.7
RS    			bit					P1.5 
RW					bit					P1.6
E					bit					P1.7
LCD				data					P2



;Ressources de la routine Attente
Charge_H	    	equ 			      03Ch
Charge_L	    	equ 		       	0B0h+08h				;Charge_L = N_L + Nr	

					org					0000h
					SJMP					debut
;On définit ligne1 et ligne2, repérés par les étiquettes ligne1: et ligne2:.					
ligne1:			DB						'*** BONJOUR  ***',0
ligne2:			DB						'*** ISE 2019 ***',0


debut:
					MOV					SP,#2Fh
					MOV					TMOD,#10h
					LCALL					LCD_Init
					MOV					DPTR,#ligne1
					LCALL					LCD_msg
					MOV					LCD,#0C0h
					LCALL					LCD_Code
					MOV					DPTR,#ligne2
					LCALL					LCD_msg
fin: 				SJMP					fin

;_______________________________________________
; Routine d'initialisation
; ressource: R0 compteur (variable locale)
LCD_Init:
					MOV					R0,#3
RPT_LCD_Init:	LCALL					Attente
					CLR					RS
					CLR					RW
					MOV					LCD,#30h				;Triple commande d'initialisation
					SETB					E
					CLR					E
JSQ_LCD_Init:	DJNZ					R0,RPT_LCD_Init
					MOV					LCD,#38h				;2 lignes, carractères 8x5
					LCALL					LCD_CODE
					MOV					LCD,#08h          ;Display Off
					LCALL					LCD_CODE
					MOV					LCD,#01h          ;Display Clear
					LCALL					LCD_CODE
					MOV					LCD,#06h				;Entry Mode Set
					LCALL					LCD_CODE
					MOV					LCD,#0Ch          ;Display On
					LCALL					LCD_CODE
fin_LCD_Init:	RET

;___________________________________________	
LCD_msg:
					PUSH					Acc
					MOV					A,#0h
					MOVC					A,@A+DPTR
TQ_msg:		   JZ						FTQ_msg
					MOV					LCD,A
					LCALL					LCD_Data
					INC					DPTR
					MOV					A,#0h	
					MOVC					A,@A+DPTR
					SJMP					TQ_msg
FTQ_msg:			POP					Acc
					RET
											
;___________________________________________	
LCD_CODE:
					LCALL					LCD_BF
					CLR					RS
					CLR					RW
					SETB					E
					CLR					E
fin_LCD_CODE:	RET
;___________________________________________	
LCD_DATA:
					LCALL					LCD_BF
					SETB					RS
					CLR					RW
					SETB					E
					CLR					E
fin_LCD_DATA:	RET
;___________________________________________		
LCD_BF:
					PUSH					LCD
					MOV					LCD,#0FFh
					CLR					RS
					SETB					RW
RPT_BF:				
					CLR					E
					SETB					E
JSQ_BF:			JB						BF,RPT_BF
					CLR					E
					POP					LCD
fin_LCD_BF:		RET
;___________________________________________	
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
					end
