 ;Programme du microcontroleur de la carte secondaire
 
 
;Déclaration des données
LCD				data		P2
BF					bit		P2.7
RS    			bit		P0.5 
RW					bit		P0.6
E					bit		P0.7
Laser				bit		P1.2
Sirene			bit		P1.3
nb_tours			data		7Fh
nb_D				data		7Eh
nb_C				data		7Dh
nb_G				data		7Ch


;Ressources de la routine Attente
Charge_H	    	equ 	   03Ch
Charge_L	    	equ 		0B0h+08h		;Charge_L = N_L + Nr	


;Saut de la table des vecteurs d'interruprions
					org		0000h
					SJMP		debut
					
					
					org		0030h
debut:
					MOV		SP,#2Fh		;La pile se trouve dans la mémoire octets
					MOV		TMOD,#21h	;Timer 1 en mode 2 (compteur 8 bits autorechargé pour UART) et timer 0 en mode 1 (Compteur 16 bits pour la routine d'attente)
					MOV		TH1,#0E6h	;Communication à 1200 Bds
					MOV		SCON,#50h	;Communication UART mode 1, réception autorisée, pas de 9e bit
					MOV		TCON,#40h	;Démarrage du Timer 1, pas d'interruptions externes
					LCALL		LCD_Init		;Initialisation de l'afficheur LCD

					
					
fin:				SJMP		fin

;_______________________________________________
; Routine d'initialisation du LCD
; ressource: R0 compteur (variable locale)
LCD_Init:
					MOV		R0,#3
RPT_LCD_Init:	LCALL		Attente			;Répétition 3 fois
					CLR		RS
					CLR		RW
					MOV		LCD,#30h			;Triple commande d'initialisation
					SETB		E
					CLR		E
JSQ_LCD_Init:	DJNZ		R0,RPT_LCD_Init
					MOV		LCD,#38h			;bus 8 bits, Affichage 2 lignes, carractères 8x5
					LCALL		LCD_CODE
					MOV		LCD,#08h       ;Display Off, Cursor Off, Blink Off
					LCALL		LCD_CODE
					MOV		LCD,#01h       ;Display Clear
					LCALL		LCD_CODE
					MOV		LCD,#06h			;Pas de défilement, Ecriture de gauch à droite
					LCALL		LCD_CODE
					MOV		LCD,#0Ch       ;Display On, Cursor Off, Blink Off
					LCALL		LCD_CODE
fin_LCD_Init:	RET

;___________________________________________	
;Routine permettant l'envoi d'une chaîne de carractères pointée par DPTR
LCD_msg:
					PUSH		Acc				;On sauvegarde l'accumulateur
					MOV		A,#0h
					MOVC		A,@A+DPTR      ;On place la valeur pointée par DPTR dans A
TQ_msg:		   JZ			FTQ_msg        ;Tant que cette valeur n'est pas NULL
					MOV		LCD,A
					LCALL		LCD_Data       ;On envoie cette valeur dans le registre de données du LCD
					INC		DPTR				;On pointe le carractère suivant
					MOV		A,#0h	
					MOVC		A,@A+DPTR      ;On place la valeur pointée par DPTR dans A
					SJMP		TQ_msg			;Et on réitère
FTQ_msg:			POP		Acc				;Puis on rétablit l'accumulateur
					RET
											
;___________________________________________
;Routine d'envoi de donnée (stockée dans le LATCH du port P2) au registre de contrôle du LCD	
LCD_CODE:
					LCALL		LCD_BF		;On attend le Busy Flag
					CLR		RS          ;On accède au registre 0 (contrôle)
					CLR		RW          ;en ecriture
					SETB		E
					CLR		E           ;front decendant de E pour valider l'envoi
fin_LCD_CODE:	RET
;___________________________________________
;Routine d'envoi de données (stockée dans le LATCH du port P2) au registre d'affichage du LCD	
LCD_DATA:
					LCALL		LCD_BF		;On attend le Busy Flag
					SETB		RS          ;On accède au registre 1 (données)
					CLR		RW          ;en ecriture
					SETB		E
					CLR		E           ;front descendant de E pour valider l'envoi
fin_LCD_DATA:	RET
;___________________________________________
;Routine d'attente d'état bas sur le Busy FLag du LCD		
LCD_BF: 
              	PUSH		LCD         ;On sauvegarde la valeur à écrire
					MOV		LCD,#0FFh	;On passe en mode Input (High Z)
					CLR		RS				;Accès au registre 0 (contrôle)
					SETB		RW          ;en lecture
RPT_BF:				
					CLR		E				
					SETB		E           ;Front montant de E pour valider la demande
JSQ_BF:			JB			BF,RPT_BF   ;Jusqu'à ce que le Busy Flag soit bas
					CLR		E           ;On met E au repos
					POP		LCD			;On replace la valeur à écrire
fin_LCD_BF:		RET

;___________________________________________	
;Routine d'attente de 50ms
;Utilise le Timer0 en mode 1 (compteur 16 bits)
;Modifie la valeur de C			
Attente: 
					PUSH		Acc			      		
					CLR		TR0                     ;On arrête le Timer
					MOV		A,TL0					;1CM  
					ADD		A,#Charge_L			;1CM
		      	MOV		TL0,A					;1CM
			      MOV		A,TH0					;1CM
			      ADDC		A,#Charge_H			;1CM   
			      MOV		TH0,A					;1CM  ;On précharge le timer
		   	   CLR		TF0					;1CM  ;On prépare le flag
		      	SETB		TR0					;1CM  ;On démare le timer
Attendre_TF0:	JNB		TF0,Attendre_TF0			;On attend le flag					
					POP		Acc
fin_Attente:	RET


					end
