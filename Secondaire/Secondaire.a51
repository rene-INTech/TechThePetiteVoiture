;Programme du microcontroleur de la carte secondaire
 
 
;D�claration des donn�es
LCD				data		P2
BF					bit		P2.7
RS    			bit		P0.5 
RW					bit		P0.6
E					bit		P0.7
Laser				bit		P1.2        ;Commande le laser
Sirene			bit		P1.3			;Commande la sir�ne
Principal		bit		P3.1			;(J6.1) A l'�tat haut quand la voiture doit avancer
nb_tours			data		7Fh			;Compte le nombre de tours d�j� effectu�s
nb_D				data		7Eh			;Compte le nombre de touches sur la cible droite
nb_C				data		7Dh			;Compte le nombre de touches sur la cible centrale
nb_G				data		7Ch			;Compte le nombre de touches sur la cible gauche


;Ressources de la routine Attente
Charge_H	    	equ 	   03Ch
Charge_L	    	equ 		0B0h+08h		;Charge_L = N_L + Nr	


;Saut de la table des vecteurs d'interruprions
					org		0000h
					SJMP		debut
					
					
					org		0030h
debut:
					MOV		SP,#2Fh		;La pile se trouve dans la m�moire octets
					MOV		TMOD,#21h	;Timer 1 en mode 2 (compteur 8 bits autorecharg� pour UART) et timer 0 en mode 1 (Compteur 16 bits pour la routine d'attente)
					MOV		TH1,#0E6h	;Communication � 1200 Bds
					MOV		SCON,#50h	;Communication UART mode 1, r�ception autoris�e, pas de 9e bit
					MOV		TCON,#40h	;D�marrage du Timer 1, pas d'interruptions externes
					LCALL		LCD_Init		;Initialisation de l'afficheur LCD

;Attente du signal de d�part
Att_RI:			JNB		RI,Att_RI	;On attend de recevoir qqch de la balise
					CLR		RI				;On replace le flag
					MOV		A,SBUF
					CJNE		A,#30h,Att_RI;Si on n'a pas re�u "0", on attend un autre message
					SETB		Principal	;Sinon (c�d on a re�u "0"), on d�marre
;Fin de l'attente du signal de d�part
					
					;TODO : Attendre un message, s'il est diff�rent du pr�c�dent, agir en cons�quence
					
fin:				SJMP		fin

;_______________________________________________
; Routine d'initialisation du LCD
; ressource: R0 compteur (variable locale)
LCD_Init:
					MOV		R0,#3
RPT_LCD_Init:	LCALL		Attente		;R�p�tition 3 fois
					CLR		RS
					CLR		RW
					MOV		LCD,#30h		;Triple commande d'initialisation
					SETB		E
					CLR		E
JSQ_LCD_Init:	DJNZ		R0,RPT_LCD_Init
					MOV		LCD,#38h		;bus 8 bits, Affichage 2 lignes, carract�res 8x5
					LCALL		LCD_CODE
					MOV		LCD,#08h    ;Display Off, Cursor Off, Blink Off
					LCALL		LCD_CODE 
					MOV		LCD,#01h    ;Display Clear
					LCALL		LCD_CODE
					MOV		LCD,#06h		;Pas de d�filement, Ecriture de gauche � droite
					LCALL		LCD_CODE
					MOV		LCD,#0Ch    ;Display On, Cursor Off, Blink Off
					LCALL		LCD_CODE
fin_LCD_Init:	RET

;___________________________________________	
;Routine permettant l'envoi d'une cha�ne de carract�res point�e par DPTR
;TODO: Pr�voir un d�filement pour les messages plus longs
LCD_msg:
					PUSH		Acc			;On sauvegarde l'accumulateur
					MOV		A,#0h
					MOVC		A,@A+DPTR   ;On place la valeur point�e par DPTR dans A
TQ_msg:		   JZ			FTQ_msg     ;Tant que cette valeur n'est pas NULL
					MOV		LCD,A
					LCALL		LCD_Data    ;On envoie cette valeur dans le registre de donn�es du LCD
					INC		DPTR			;On pointe le carract�re suivant
					MOV		A,#0h	 
					MOVC		A,@A+DPTR   ;On place la valeur point�e par DPTR dans A
					SJMP		TQ_msg		;Et on r�it�re
FTQ_msg:			POP		Acc			;Puis on r�tablit l'accumulateur
					RET
											
;___________________________________________
;Routine d'envoi de donn�e (stock�e dans le LATCH du port P2) au registre de contr�le du LCD	
LCD_CODE:
					LCALL		LCD_BF		;On attend le Busy Flag
					CLR		RS          ;On acc�de au registre 0 (contr�le)
					CLR		RW          ;en ecriture
					SETB		E
					CLR		E           ;front decendant de E pour valider l'envoi
fin_LCD_CODE:	RET
;___________________________________________
;Routine d'envoi de donn�es (stock�e dans le LATCH du port P2) au registre d'affichage du LCD	
LCD_DATA:
					LCALL		LCD_BF		;On attend le Busy Flag
					SETB		RS          ;On acc�de au registre 1 (donn�es)
					CLR		RW          ;en ecriture
					SETB		E
					CLR		E           ;front descendant de E pour valider l'envoi
fin_LCD_DATA:	RET
;___________________________________________
;Routine d'attente d'�tat bas sur le Busy FLag du LCD		
LCD_BF: 
              	PUSH		LCD         ;On sauvegarde la valeur � �crire
					MOV		LCD,#0FFh	;On passe en mode Input (High Z)
					CLR		RS				;Acc�s au registre 0 (contr�le)
					SETB		RW          ;en lecture
RPT_BF:				
					CLR		E				
					SETB		E           ;Front montant de E pour valider la demande
JSQ_BF:			JB			BF,RPT_BF   ;Jusqu'� ce que le Busy Flag soit bas
					CLR		E           ;On met E au repos
					POP		LCD			;On replace la valeur � �crire
fin_LCD_BF:		RET

;___________________________________________	
;Routine d'attente de 50ms
;Utilise le Timer0 en mode 1 (compteur 16 bits)
;Modifie la valeur de C			
Attente: 
					PUSH		Acc			      		
					CLR		TR0                     ;On arr�te le Timer
					MOV		A,TL0					;1CM  
					ADD		A,#Charge_L			;1CM
		      	MOV		TL0,A					;1CM
			      MOV		A,TH0					;1CM
			      ADDC		A,#Charge_H			;1CM   
			      MOV		TH0,A					;1CM  ;On pr�charge le timer
		   	   CLR		TF0					;1CM  ;On pr�pare le flag
		      	SETB		TR0					;1CM  ;On d�mare le timer
Attendre_TF0:	JNB		TF0,Attendre_TF0			;On attend le flag					
					POP		Acc
fin_Attente:	RET

;___________________________________________
;Routine de comptage de tours, doit �tre appel�e lorsqu'un "0" est re�u pour la premi�re fois depuis quelques messages

Balise_depart:
					PUSH		Acc			;On sauvegarde l'accumulateur
					CLR		Principal   ;On s'arr�te
					INC		nb_tours		;On a fait un tour de plus
					MOV		A,#100		
Attente_10s:	LCALL		Attente     ;On attend 100x50 ms
					DJNZ		Acc,Attente_10s
SI_3_tours:		MOV		A,nb_tours	;Si on a fait 3 tours
					CJNE		A,#3,SINON_3_tours
					LJMP		fin			;On a termin�
SINON_3_tours:	SETB		Principal	;Sinon,on repart
               POP		Acc			;On restaure l'accumulateur
               RET

;____________________________________________
;Routine permettant d'afficher le message re�u par UART sur le LCD
Debug_UART:    
Att_RI_Debug:	JNB		RI,Att_RI_Debug	;On attend de recevoir qqch de la balise  
					CLR		RI    
					MOV		LCD,SBUF
					LCALL		LCD_Data
					RET
     
					end
