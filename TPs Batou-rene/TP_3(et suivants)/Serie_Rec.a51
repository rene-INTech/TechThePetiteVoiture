;Serie_Rec
;Created by Rémi Lamiaux and Baptiste Ghirardi
;29/11/2019
;version 1.0

BF					bit					P2.7
RS    			bit					P1.5 
RW					bit					P1.6
E					bit					P1.7
NEW				bit					F0						;Vaut 1 si on doit effacer l'écran
LCD				data					P2

;Ressources de la routine Attente
Charge_H	    	equ 			      03Ch
Charge_L	    	equ 		       	0B0h+08h				;Charge_L = N_L + Nr	

					org					0000h
					SJMP					debut
					
					org					0030h
			
debut:
					MOV					TH1,#0E6h
					MOV					SCON,#50h
					MOV					TMOD,#21h
					MOV					TCON,#40h
					MOV					SP,#2Fh
					LCALL					LCD_Init
RPT:
att_RI1: 		JNB					RI,att_RI1
					CLR					RI
					MOV					A,SBUF
SI_NEW:			JNB					NEW,fin_SI_NEW
					MOV					LCD,#01h          ;Display Clear
					LCALL					LCD_CODE
					CLR					NEW
fin_SI_NEW:
SI_tmp:			CJNE					A,#0Dh,SINON_tmp
					SETB					NEW
fin_SI_tmp:		SJMP					fin_SINON_tmp
SINON_tmp:
					MOV					LCD,A
					LCALL					LCD_DATA
fin_SINON_tmp:
			
JSQ:				SJMP					RPT
fin:		



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
				CLR			TR0
				MOV			A,TL0					;1CM
				ADD			A,#Charge_L			;1CM
		      MOV			TL0,A					;1CM
		      MOV			A,TH0					;1CM
		      ADDC			A,#Charge_H			;1CM
		      MOV			TH0,A					;1CM
		      CLR			TF0					;1CM
		      SETB			TR0					;1CM
Attendre:	JNB			TF0,Attendre								
				POP			Acc
fin_Attente:RET

			end  
