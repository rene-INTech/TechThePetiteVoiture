 ;Programme du microcontroleur de la carte secondaire
 
 
;D�claration des donn�es
LCD				data		P2
BF					bit		P2.7
RS    			bit		P0.5 
RW					bit		P0.6
E					bit		P0.7
Laser				bit		P1.2
Sirene			bit		P1.3


;Ressources de la routine Attente
Charge_H	    	equ 	   03Ch
Charge_L	    	equ 		0B0h+08h			;Charge_L = N_L + Nr	


;Saut de la table des vecteurs d'interruprions
					org		0000h
					SJMP		debut
					
					
					org		0030h
debut:
					MOV		SP,#2Fh		;La pile se trouve dans la m�moire octets
					MOV		TMOD,#21h	;Timer 1 en mode 2 (UART) et timer 0 en mode 1 (Compteur 16 bits)
					MOV		TH1,#0E6h	;Communication � 1200 Bds
					MOV		SCON,#50h	;Communication UART mode 1, r�ception autoris�e, pas de 9e bit
					MOV		TCON,#40h	;D�marrage du Timer 1, pas d'interruptions externes
					LCALL		LCD_Init		;Initialisation de l'afficheur LCD
fin:

;_______________________________________________
; Routine d'initialisation du LCD
; ressource: R0 compteur (variable locale)
LCD_Init:
					MOV		R0,#3
RPT_LCD_Init:	LCALL		Attente			;R�p�tition 3 fois
					CLR		RS
					CLR		RW
					MOV		LCD,#30h				;Triple commande d'initialisation
					SETB		E
					CLR		E
JSQ_LCD_Init:	DJNZ		R0,RPT_LCD_Init
					MOV		LCD,#38h				;2 lignes, carract�res 8x5
					LCALL		LCD_CODE
					MOV		LCD,#08h          ;Display Off
					LCALL		LCD_CODE
					MOV		LCD,#01h          ;Display Clear
					LCALL		LCD_CODE
					MOV		LCD,#06h				;Entry Mode Set
					LCALL		LCD_CODE
					MOV		LCD,#0Ch          ;Display On
					LCALL		LCD_CODE
fin_LCD_Init:	RET

;___________________________________________	
;Routine permettant l'envoi d'une cha�ne de carract�res point�e par DPTR
LCD_msg:
					PUSH		Acc
					MOV		A,#0h
					MOVC		A,@A+DPTR
TQ_msg:		   JZ			FTQ_msg
					MOV		LCD,A
					LCALL		LCD_Data
					INC		DPTR
					MOV		A,#0h	
					MOVC		A,@A+DPTR
					SJMP		TQ_msg
FTQ_msg:			POP		Acc
					RET
											
;___________________________________________
;Routine d'envoi de donn�e (stock�e dans le LATCH du port P2) au registre de contr�le du LCD	
LCD_CODE:
					LCALL		LCD_BF
					CLR		RS
					CLR		RW
					SETB		E
					CLR		E
fin_LCD_CODE:	RET
;___________________________________________
;Routine d'envoi de donn�es (stock�e dans le LATCH du port P2) au registre d'affichage du LCD	
LCD_DATA:
					LCALL		LCD_BF
					SETB		RS
					CLR		RW
					SETB		E
					CLR		E
fin_LCD_DATA:	RET
;___________________________________________
;Routine d'attente d'�tat bas sur le Busy FLag du LCD		
LCD_BF: 
              	PUSH		LCD
					MOV		LCD,#0FFh	;On passe en mode Input (High Z)
					CLR		RS
					SETB		RW
RPT_BF:				
					CLR		E
					SETB		E
JSQ_BF:			JB			BF,RPT_BF
					CLR		E
					POP		LCD
fin_LCD_BF:		RET

;___________________________________________	
;Routine d'attente de 50ms
;Utilise le Timer0 en mode 1 (compteur 16 bits)
;Modifie la valeur de C			
Attente: 
					PUSH		Acc			      
					CLR		TR0
					MOV		A,TL0					;1CM
					ADD		A,#Charge_L			;1CM
		      	MOV		TL0,A					;1CM
			      MOV		A,TH0					;1CM
			      ADDC		A,#Charge_H			;1CM
			      MOV		TH0,A					;1CM
		   	   CLR		TF0					;1CM
		      	SETB		TR0					;1CM
Attendre_TF0:	JNB		TF0,Attendre_TF0								
					POP		Acc
fin_Attente:	RET


					end
