;Programme du microcontroleur de la carte secondaire
 
 
;Déclaration des données
LCD				data		P2
BF					bit		P2.7
RS    			bit		P0.5 
RW					bit		P0.6
E					bit		P0.7
Laser				bit		P1.2        ;Commande le laser
Sirene			bit		P1.3			;Commande la sirène
LED				bit		P1.0			;LED de debug (Sert actuellement à indiquer l'état de la commande vers la carte principale)
Principal		bit		P3.1			;(J6.1) A l'état haut quand la voiture doit avancer
nb_tours			data		7Fh			;Compte le nombre de tours déjà effectués
nb_D				data		7Eh			;Compte le nombre de touches sur la cible droite
nb_C				data		7Dh			;Compte le nombre de touches sur la cible centrale
nb_G				data		7Ch			;Compte le nombre de touches sur la cible gauche
msg_prec			data		7Bh			;Sauvegarde le dernier message reçu
FLAG_4			bit		F0

;Ressources de la routine Attente
Charge_H	    	equ 	   03Ch
Charge_L	    	equ 		0B0h+08h		;Charge_L = N_L + Nr	


;Saut de la table des vecteurs d'interruprions
					org		0000h
					SJMP		debut
					
					org		000Bh
					LJMP		IT_Timer0
					
					
					org		0030h
debut:
					MOV		SP,#2Fh		;La pile se trouve dans la mémoire octets
					MOV		TMOD,#21h	;Timer 1 en mode 2 (compteur 8 bits autorechargé pour UART) et timer 0 en mode 1 (Compteur 16 bits pour la routine d'attente)
					MOV		TH1,#0E6h	;Communication à 1200 Bds
					MOV		SCON,#50h	;Communication UART mode 1, réception autorisée, pas de 9e bit
					MOV		TCON,#40h	;Démarrage du Timer 1, pas d'interruptions externes
					SETB		LED			;Allumée à l'état bas
					CLR		Sirene
					CLR		Laser
					LCALL		LCD_Init		;Initialisation de l'afficheur LCD
					;LCALL		Debug_UART	
					LCALL		Att_depart	;Attente du signal de départ
					
;_____________________________RECEPTION UNIQUE DU MESSAGE________________________________________________________________
;Il faudra sûrement modifier ce code pour rendre la détection plus robuste
;Actuellemnt, il se contente d'appeler la routine associée quand on reçoit un message pour la première fois
debut_recept:						
Att_RI:			JNB		RI,Att_RI				;Attente du flag de reception
					
					JNB		FLAG_4,fin_timer
debut_timer:	CLR		TR0                     ;On arrête le Timer
					MOV		A,TL0					;1CM  
					ADD		A,#Charge_L			;1CM
		      	MOV		TL0,A					;1CM
			      MOV		A,TH0					;1CM
			      ADDC		A,#Charge_H			;1CM   
			      MOV		TH0,A					;1CM  ;On précharge le timer
		   	   CLR		TF0					;1CM  ;On prépare le flag
			    	SETB		TR0					;1CM  ;On démare le timer
fin_timer:					
					
					CLR		RI							;On replace le flag
					CJNE		A,SBUF,SI_pas_nv_msg	;Si le message reçu est le même que le précédent,
					SJMP		Att_RI					;on attend un autre message,
SI_pas_nv_msg:	
					MOV		A,SBUF					;et on le place dans A pour tester sa valeur
					ANL		A,#7Fh					;masque bit de parité
					CJNE		A,#"0",SI_non_0
					MOV		msg_prec,SBUF			;sinon, on sauvegarde ce nouveau message,
					MOV		LCD,#"0"
					LCALL		LCD_DATA
					LCALL		Balise_depart			;Si on a recu "0"
					SJMP		fin_SI
SI_non_0:		CJNE		A,#"4",SI_non_4
					MOV		msg_prec,SBUF			;sinon, on sauvegarde ce nouveau message,
					MOV		LCD,#"4"
					LCALL		LCD_DATA
					SETB		Laser
					SETB		Sirene
					
					SETB		FLAG_4
					CLR		TR0                     ;On arrête le Timer
					MOV		A,TL0					;1CM  
					ADD		A,#Charge_L			;1CM
		      	MOV		TL0,A					;1CM
			      MOV		A,TH0					;1CM
			      ADDC		A,#Charge_H			;1CM   
			      MOV		TH0,A					;1CM  ;On précharge le timer
		   	   CLR		TF0					;1CM  ;On prépare le flag
		   	   MOV		IE,#82h				;2CM	;On autorise l'interruption Timer0
			    	SETB		TR0					;1CM  ;On démare le timer	
					
					SJMP		fin_SI
SI_non_4:		CJNE		A,#"C",SI_non_C
					MOV		msg_prec,SBUF			;sinon, on sauvegarde ce nouveau message,
					MOV		LCD,#"C"
					LCALL		LCD_DATA
					SJMP		fin_SI
SI_non_C:		CJNE		A,#"G",SI_non_G
					;Si on a recu "G"
					MOV		msg_prec,SBUF			;sinon, on sauvegarde ce nouveau message,
					MOV		LCD,#"G"
					LCALL		LCD_DATA
					SJMP		fin_SI
SI_non_G:		CJNE		A,#"D",SI_non_D
					;Si on a recu "D"
					MOV		msg_prec,SBUF			;sinon, on sauvegarde ce nouveau message,
					MOV		LCD,#"D"
					LCALL		LCD_DATA
					SJMP		fin_SI
SI_non_D:		MOV		LCD,SBUF
					LCALL		LCD_DATA
					SJMP		fin_SI 					;Parce que je sais pas ce qu'on a recu

fin_SI:			LJMP		debut_recept			;On attend le prochain message;
;_____________________________FIN RECEPTION UNIQUE DU MESSAGE______________________________________________________________

					
fin:				SJMP		fin

;_______________________________________________
; Routine d'initialisation du LCD
; ressource: R0 compteur (variable locale)
LCD_Init:
					MOV		R0,#3
RPT_LCD_Init:	LCALL		Attente		;Répétition 3 fois
					CLR		RS
					CLR		RW
					MOV		LCD,#30h		;Triple commande d'initialisation
					SETB		E
					CLR		E
JSQ_LCD_Init:	DJNZ		R0,RPT_LCD_Init
					MOV		LCD,#38h		;bus 8 bits, Affichage 2 lignes, carractères 8x5
					LCALL		LCD_CODE
					MOV		LCD,#08h    ;Display Off, Cursor Off, Blink Off
					LCALL		LCD_CODE 
					MOV		LCD,#01h    ;Display Clear
					LCALL		LCD_CODE
					MOV		LCD,#06h		;Pas de défilement, Ecriture de gauche à droite
					LCALL		LCD_CODE
					MOV		LCD,#0Ch    ;Display On, Cursor Off, Blink Off
					LCALL		LCD_CODE
fin_LCD_Init:	RET

;____________________________________________________
;Routine d'attente du signal de départ
Att_depart:		PUSH		Acc
Att_RI_depart:	JNB		RI,Att_RI_depart		;On attend de recevoir qqch de la balise
					CLR		RI							;On replace le flag
					MOV		A,SBUF
					CJNE		A,#30h,Att_RI_depart	;Si on n'a pas reçu "0", on attend un autre message
					SETB		Principal				;Sinon (càd on a reçu "0"), on démarre
					CLR		LED
					MOV		msg_prec,A				;On sauvegarde ce message
					POP		Acc
					RET

;___________________________________________	
;Routine permettant l'envoi d'une chaîne de carractères pointée par DPTR
;TODO: Prévoir un défilement pour les messages plus longs
LCD_msg:
					PUSH		Acc			;On sauvegarde l'accumulateur
					MOV		A,#0h
					MOVC		A,@A+DPTR   ;On place la valeur pointée par DPTR dans A
TQ_msg:		   JZ			FTQ_msg     ;Tant que cette valeur n'est pas NULL
					MOV		LCD,A
					LCALL		LCD_Data    ;On envoie cette valeur dans le registre de données du LCD
					INC		DPTR			;On pointe le carractère suivant
					MOV		A,#0h	 
					MOVC		A,@A+DPTR   ;On place la valeur pointée par DPTR dans A
					SJMP		TQ_msg		;Et on réitère
FTQ_msg:			POP		Acc			;Puis on rétablit l'accumulateur
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


Attente_1s:
					PUSH		Acc
					MOV		A,#10
ATT_1S_loop:	LCALL		Attente
					DJNZ		Acc,ATT_1S_loop
					POP		Acc
					RET


;___________________________________________
;Routine de comptage de tours, doit être appelée lorsqu'un "0" est reçu pour la première fois depuis quelques messages

Balise_depart:
					PUSH		Acc			;On sauvegarde l'accumulateur
					CLR		Principal   ;On s'arrête
					SETB		LED
					INC		nb_tours		;On a fait un tour de plus
					MOV		A,#40		
Attente_2s:		LCALL		Attente     ;On attend 40x50 ms
					DJNZ		Acc,Attente_2s
SI_3_tours:		MOV		A,nb_tours	;Si on a fait 3 tours
					CJNE		A,#3,SINON_3_tours
					MOV		PCON,#02h	;sudo shutdown now -m "On a terminé"
					RET						;Cette instruction est censée ne jamais être exécutée
SINON_3_tours:	SETB		Principal	;Sinon,on repart
					CLR		LED
               POP		Acc			;On restaure l'accumulateur
               RET

;_____________________________________________________________________
IT_Timer0:	
					CLR		Sirene
					CLR		Laser
					CLR		FLAG_4
					CLR		TR0
					MOV		IE,#00h
					RETI
;____________________________________________
;Routine permettant d'afficher le message reçu par UART sur le LCD
Debug_UART:    
Att_RI_Debug:	JNB		RI,Att_RI_Debug	;On attend de recevoir qqch de la balise  
					CLR		RI
					MOV		LCD,#01h
					LCALL		LCD_CODE
					MOV		A,SBUF
					ANL		A,#7Fh				;Masque bit de parité
					MOV		LCD,A
					LCALL		LCD_Data
					LCALL		Attente
					LCALL		Attente				;Attente 100 ms
					SJMP		Att_RI_Debug
					RET
     
					end
