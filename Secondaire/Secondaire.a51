;Programme du microcontroleur de la carte secondaire

;D�claration des donn�es
LCD				data		P2
BF					bit			P2.7
RS					bit			P0.5 
RW				bit			P0.6
E					bit			P0.7
Laser				bit			P1.2			;Commande le laser
Sirene				bit			P1.3			;Commande la si ren�
LED				bit			P1.0			;LED de debug (Sert actuellement � indiquer l'�tat de la commande vers la carte principale)
Principal			bit			P3.1			;(J6.1) A l'�tat haut quand la voiture doit avancer
nb_tours			data		7Fh			;Compte le nombre de tours d�j� effectu�s
nb_D				data		7Eh			;Compte le nombre de touches sur la cible droite
nb_C				data		7Dh			;Compte le nombre de touches sur la cible centrale
nb_G				data		7Ch			;Compte le nombre de touches sur la cible gauche
msg_prec		data		7Bh			;Sauvegarde le dernier message re�u
FLAG_4			bit			F0				;Vaut 1 si le tiemr d'allumage du laser doit �tre r�initialis� � la reception d'un message
attente_4		bit			00h			;Vaut 1 si on est en premi�re moiti� de tour (donc on n'accepte pas de recevoir "0" avant d'avoir recu "4")
FLAG_D			bit			01h			;Vaut 1 si on a d�j� incr�ment� le compteur D pour ce tour
FLAG_C			bit			02h			;Vaut 1 si on a d�j� incr�ment� le compteur C pour ce tour
FLAG_G			bit			03h			;Vaut 1 si on a d�j� incr�ment� le compteur G pour ce tour

;Ressources de la routine Attente
Charge_H	    	equ 		03Ch
Charge_L			equ 		0B0h+08h		;Charge_L = N_L + Nr

;Codes utiles pour le contr�le du LCD
clear				equ		01h			;code d'effacement du LCD
shift_left		equ		14h			;code de d�calage de l'affichage vers la gauche
adr_D				equ		42h or 80h	;code d'acc�s � l'adresse de DDRAM du LCD dans laquelle ecrire le nombre de touches D
adr_C				equ		47h or 80h	;code d'acc�s � l'adresse de DDRAM du LCD dans laquelle ecrire le nombre de touches C
adr_G				equ		4Ch or 80h	;code d'acc�s � l'adresse de DDRAM du LCD dans laquelle ecrire le nombre de touches G
adr_tours		equ		0Dh or 80h	;code d'acc�s � l'adresse de DDRAM du LCD dans laquelle ecrire le nombre de tours
adr_ligne1		equ		00h or 80h	;code d'acc�s � l'adresse de DDRAM du LCD du premier carract�re de la premi�re ligne
adr_ligne2		equ		40h or 80h	;code d'acc�s � l'adresse de DDRAM du LCD du premier carract�re de la deuxi�me ligne
adr_fin_l1		equ		0Fh or 80h	;code d'acc�s � l'adresse de DDRAM du LCD du dernier carract�re de la premi�re ligne


;Saut de la table des vecteurs d'interruprions
					org		0000h
					LJMP		debut
					
					org		000Bh
					LJMP		IT_Timer0	;Interruption du Timer 0
					
					
					org		0030h
;d�finition des messages � afficher sur le LCD
ready_msg1:		DB			" ATTENTE SIGNAL ",0
ready_msg2:		DB			" BALISE  DEPART ",0
shutdown_msg1:DB		"TRAVAIL  TERMINE",0
shutdown_msg2:DB		"ARRET EN COURS ",4,0
template1:		DB			"NOMBRE TOURS:0  ",0
template2:		DB			"D:0  C:0  G:0   ",0
auteurs_msg1:	DB			0E4h,"C principal par Eloise ",26h," Gwendoline",1,1,1,0
auteurs_msg2:	DB			0E4h,"C secondaire par R",3,"mi ",26h," Baptiste ",1,1,1,1,1,1,0

;Programme principal du �C secondaire
debut:
					MOV		SP,#2Fh		;La pile se trouve dans la m�moire octets
					MOV		TMOD,#21h	;Timer 1 en mode 2 (compteur 8 bits autorecharg� pour UART) et timer 0 en mode 1 (Compteur 16 bits pour la routine d'attente)
					MOV		TH1,#0E6h	;Communication � 1200 Bds
					MOV		SCON,#50h	;Communication UART mode 1, r�ception autoris�e, pas de 9e bit
					MOV		TCON,#40h	;D�marrage du Timer 1, pas d'interruptions externes
					SETB		LED			;Allum�e � l'�tat bas
					CLR		Sirene		;Allum� au RESET
					CLR		Laser			;Allum� au RESET
					MOV		nb_tours,#"0"
					MOV		nb_D,#"0"
					MOV		nb_C,#"0"
					MOV		nb_G,#"0"
					LCALL		LCD_Init		;Initialisation de l'afficheur LCD
					;LCALL		Debug_UART	
					LCALL		Att_depart	;Attente du signal de d�part
					
;_____________________________RECEPTION UNIQUE DU MESSAGE________________________________________________________________
debut_recept:	
					MOV		A,msg_prec						
Att_RI:			JNB		RI,Att_RI					;Attente du flag de reception
					CLR		RI							;On replace le flag
					
debut_timer:	JNB		FLAG_4,fin_timer		;Si on doit r�initialiser le Timer0
					CLR		TR0						;On arr�te le Timer
					MOV		TL0,#(0B0h+3)			;1CM 
					MOV		TH0,#3Ch				;1CM  ;On pr�charge le timer
					SETB		TR0						;1CM  ;On d�mare le timer
fin_timer:			
					CJNE		A,SBUF,SI_pas_nv_msg	;Si le message re�u est le m�me que le pr�c�dent,
					SJMP		Att_RI					;on attend un autre message,
SI_pas_nv_msg:	
					MOV		A,SBUF					;et on le place dans A pour tester sa valeur
					ANL		A,#01111111b			;masque bit de parit�
					
SI_0:				CJNE		A,#"0",SI_4
					;Si on a recu "0"
					JB			attente_4,defaut		;si on a pass� la balise cible
					LCALL		Balise_depart
					SJMP		fin_SI
					
SI_4	:			CJNE		A,#"4",SI_C
					;Si on a recu "4"
					CLR		attente_4
					SETB		Laser						;on active si ren� et laser
					SETB		Sirene
					MOV		LCD,#adr_fin_l1 
					LCALL		LCD_CODE				;dernier carract�re de la premi�re ligne
					MOV		LCD,#00h				;Carract�re cloche
					LCALL		LCD_DATA					
					
					;On pr�charge le timer 0 pour 50 ms et on active son interruption
					SETB		FLAG_4
					CLR		TR0					;On arr�te le Timer
		      		MOV		TL0,#(0B0h+6)		;1CM
					MOV		TH0,#3Ch			;1CM  ;On pr�charge le timer
					CLR		TF0					;1CM  ;On pr�pare le flag
					MOV		IE,#82h				;2CM	;On autorise l'interruption Timer0
					SETB		TR0					;1CM  ;On d�mare le timer	
					
					SJMP		fin_SI
					
SI_C:				CJNE		A,#"C",SI_G
					;Si on a recu "C"
					JNB		FLAG_4,defaut		;Si le laser n'est pas allum�, on ne doit pas recevoir de "C"
					JB			FLAG_C,defaut		;Si on a deja incr�ment� le compteur dans ce tour, on ne le refait pas
					INC		nb_C
					SETB		FLAG_C
					MOV		LCD,#adr_C
					LCALL		LCD_CODE
					MOV		LCD,nb_C
					LCALL		LCD_DATA
					SJMP		fin_SI
					
SI_G:			CJNE		A,#"G",SI_D
					;Si on a recu "G"
					JNB		FLAG_4,defaut
					JB			FLAG_G,defaut
					INC		nb_G
					SETB		FLAG_G
					MOV		LCD,#adr_G
					LCALL		LCD_CODE
					MOV		LCD,nb_G
					LCALL		LCD_DATA					
					SJMP		fin_SI
					
SI_D:			CJNE		A,#"D",defaut
					;Si on a recu "D"
					JNB		FLAG_4,defaut
					JB			FLAG_D,defaut
					INC		nb_D
					SETB		FLAG_D					
					MOV		LCD,#adr_D
					LCALL		LCD_CODE
					MOV		LCD,nb_D
					LCALL		LCD_DATA
					SJMP		fin_SI
					
defaut:			MOV		A,msg_prec				;On a re�u un message invalide, donc on ne le sauvegarde pas. (ou on sauvegarde le message pr�c�dent)
															;(c�d le message sauvegard� dans l'instruction suivante est d�j� celui contenu dans msg_prec)

fin_SI:				MOV		msg_prec,A				;on sauvegarde le nouveau message a la place de l'ancien			
					LJMP		debut_recept			;On attend le prochain message;
;_____________________________FIN RECEPTION UNIQUE DU MESSAGE______________________________________________________________
					
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
					LCALL		Load_CGRAM	;Chargement des carract�res persos
fin_LCD_Init:	RET

;________________________________________________________
;Routine de d�finitions des carract�res persos dans la CGRAM du LCD
Load_CGRAM:
					MOV		LCD,#40h		;Premier carract�re
					LCALL		LCD_CODE
					;Cloche pour 00h
					MOV		LCD,#00h
					LCALL		LCD_DATA
					MOV		LCD,#04h
					LCALL		LCD_DATA
					MOV		LCD,#0Eh
					LCALL		LCD_DATA
					MOV		LCD,#0Ah
					LCALL		LCD_DATA
					MOV		LCD,#0Ah
					LCALL		LCD_DATA
					MOV		LCD,#1Fh
					LCALL		LCD_DATA
					MOV		LCD,#04h
					LCALL		LCD_DATA
					MOV		LCD,#00h
					LCALL		LCD_DATA
					
					;Coeur pour 01h
					MOV		LCD,#00h
					LCALL		LCD_DATA
					MOV		LCD,#0Ah
					LCALL		LCD_DATA
					MOV		LCD,#15h
					LCALL		LCD_DATA
					MOV		LCD,#11h
					LCALL		LCD_DATA
					MOV		LCD,#0Ah
					LCALL		LCD_DATA
					MOV		LCD,#04h
					LCALL		LCD_DATA
					MOV		LCD,#00h
					LCALL		LCD_DATA
					MOV		LCD,#00h
					LCALL		LCD_DATA
					
					;Sablier pour 02h
					MOV		LCD,#1Fh
					LCALL		LCD_DATA
					MOV		LCD,#11h
					LCALL		LCD_DATA
					MOV		LCD,#0Ah
					LCALL		LCD_DATA
					MOV		LCD,#04h
					LCALL		LCD_DATA
					MOV		LCD,#0Ah
					LCALL		LCD_DATA
					MOV		LCD,#15h
					LCALL		LCD_DATA
					MOV		LCD,#1Fh
					LCALL		LCD_DATA
					MOV		LCD,#00h
					LCALL		LCD_DATA
					
					;� pour 03h
					MOV		LCD,#02h
					LCALL		LCD_DATA
					MOV		LCD,#04h
					LCALL		LCD_DATA
					MOV		LCD,#0Eh
					LCALL		LCD_DATA
					MOV		LCD,#11h
					LCALL		LCD_DATA
					MOV		LCD,#1Fh
					LCALL		LCD_DATA
					MOV		LCD,#10h
					LCALL		LCD_DATA
					MOV		LCD,#0Eh
					LCALL		LCD_DATA
					MOV		LCD,#00h
					LCALL		LCD_DATA
					
					;Smiley pour 04h
					MOV		LCD,#00h
					LCALL		LCD_DATA
					MOV		LCD,#0Ah
					LCALL		LCD_DATA
					MOV		LCD,#0Ah
					LCALL		LCD_DATA
					MOV		LCD,#00h
					LCALL		LCD_DATA
					MOV		LCD,#11h
					LCALL		LCD_DATA
					MOV		LCD,#0Eh
					LCALL		LCD_DATA
					MOV		LCD,#06h
					LCALL		LCD_DATA
					MOV		LCD,#00h
					LCALL		LCD_DATA
					
					;Simple croche pour 05h
					MOV		LCD,#04h
					LCALL		LCD_DATA
					MOV		LCD,#06h
					LCALL		LCD_DATA
					MOV		LCD,#05h
					LCALL		LCD_DATA
					MOV		LCD,#04h
					LCALL		LCD_DATA
					MOV		LCD,#04h
					LCALL		LCD_DATA
					MOV		LCD,#0Ch
					LCALL		LCD_DATA
					MOV		LCD,#1Ch
					LCALL		LCD_DATA
					MOV		LCD,#18h
					LCALL		LCD_DATA
					
					;Double croche pour 06h
					MOV		LCD,#03h
					LCALL		LCD_DATA
					MOV		LCD,#0Dh
					LCALL		LCD_DATA
					MOV		LCD,#0Bh
					LCALL		LCD_DATA
					MOV		LCD,#0Dh
					LCALL		LCD_DATA
					MOV		LCD,#09h
					LCALL		LCD_DATA
					MOV		LCD,#0Bh
					LCALL		LCD_DATA
					MOV		LCD,#1Bh
					LCALL		LCD_DATA
					MOV		LCD,#18h
					LCALL		LCD_DATA
					
					RET


;___________________________________________	
;Routine permettant l'envoi d'une cha�ne de carract�res point�e par DPTR
;TODO: Pr�voir un d�filement pour les messages plus longs
LCD_msg:
					PUSH		Acc			;On sauvegarde l'accumulateur
					MOV		A,#0h
					MOVC		A,@A+DPTR  ;On place la valeur point�e par DPTR dans A
TQ_msg:		   	JZ			FTQ_msg		;Tant que cette valeur n'est pas NULL
					MOV		LCD,A             	
					LCALL		LCD_Data	;On envoie cette valeur dans le registre de donn�es du LCD
					INC		DPTR			;On pointe le carract�re suivant
					MOV		A,#0h	 
					MOVC		A,@A+DPTR  ;On place la valeur point�e par DPTR dans A
					SJMP		TQ_msg		;Et on r�it�re
FTQ_msg:		POP		Acc			;Puis on r�tablit l'accumulateur
					RET
										
;___________________________________________
;Routine d'envoi de donn�e (stock�e dans le LATCH du port P2) au registre de contr�le du LCD	
LCD_CODE:
					LCALL		LCD_BF		;On attend le Busy Flag
					CLR		RS          		;On acc�de au registre 0 (contr�le)
					CLR		RW          		;en ecriture
					SETB		E
					CLR		E          		 ;front decendant de E pour valider l'envoi
fin_LCD_CODE:	RET
;___________________________________________
;Routine d'envoi de donn�es (stock�e dans le LATCH du port P2) au registre d'affichage du LCD	
LCD_DATA:
					LCALL		LCD_BF		;On attend le Busy Flag
					SETB		RS          		;On acc�de au registre 1 (donn�es)
					CLR		RW          		;en ecriture
					SETB		E
					CLR		E           		;front descendant de E pour valider l'envoi
fin_LCD_DATA:	RET
;___________________________________________
;Routine d'attente d'�tat bas sur le Busy FLag du LCD		
LCD_BF: 
              			PUSH		LCD         		;On sauvegarde la valeur � �crire
					MOV		LCD,#0FFh	;On passe en mode Input (High Z)
					CLR		RS				;Acc�s au registre 0 (contr�le)
					SETB		RW          		;en lecture
RPT_BF:				
					CLR		E				
					SETB		E         		  	;Front montant de E pour valider la demande
JSQ_BF:			JB			BF,RPT_BF   	;Jusqu'� ce que le Busy Flag soit bas
					CLR		E         			;On met E au repos
					POP		LCD			;On replace la valeur � �crire
fin_LCD_BF:		RET

;___________________________________________	
;Routine d'attente de 50ms
;Utilise le Timer0 en mode 1 (compteur 16 bits)
;Modifie la valeur de C			
Attente: 
					PUSH		Acc			      		
					CLR		TR0                  				;On arr�te le Timer
					MOV		A,TL0					;1CM  
					ADD		A,#Charge_L			;1CM
		      		MOV		TL0,A					;1CM
			      	MOV		A,TH0					;1CM
			      	ADDC		A,#Charge_H		;1CM   
			      	MOV		TH0,A					;1CM  ;On pr�charge le timer
		   	   		CLR		TF0					;1CM  ;On pr�pare le flag
		      		SETB		TR0					;1CM  ;On d�mare le timer
Attendre_TF0:	JNB		TF0,Attendre_TF0			;On attend le flag					
					POP		Acc
fin_Attente:		RET

;______________________________________________________________________
;Routine d'attente d'1s appelant la routine Attente
Attente_1s:
					PUSH		Acc
					MOV		A,#20
ATT_1S_loop:	LCALL		Attente
					DJNZ		Acc,ATT_1S_loop
					POP		Acc
					RET
;____________________________________________________
;Routine d'attente du signal de d�part
Att_depart:		PUSH		Acc
					MOV		LCD,#adr_ligne1		;On se place au premier carract�re de la DDRAM
					LCALL		LCD_CODE
					MOV		DPTR,#ready_msg1		;Ligne 1
					LCALL		LCD_msg
					MOV		LCD,#adr_ligne2      ;On se place au premier carract�re de la 2e ligne
					LCALL		LCD_CODE
					MOV		DPTR,#ready_msg2     ;Ligne 2
					LCALL		LCD_msg
Att_RI_depart:	JNB		RI,Att_RI_depart		;On attend de recevoir qqch de la balise
					CLR		RI							;On replace le flag
					MOV		A,SBUF
					CJNE		A,#"0",Att_RI_depart	;Si on n'a pas re�u "0", on attend un autre message
					SETB		Principal				;Sinon (c�d on a re�u "0"), on d�marre
					CLR		LED
					MOV		msg_prec,A				;On sauvegarde ce message 
					MOV		LCD,#adr_ligne1
					LCALL		LCD_CODE
					MOV		DPTR,#template1
					LCALL		LCD_msg
					MOV		LCD,#adr_ligne2
					LCALL		LCD_CODE
					MOV		DPTR,#template2
					LCALL		LCD_msg
					
					SETB		attente_4
									
					POP		Acc
					RET
;___________________________________________
;Routine de comptage de tours, doit �tre appel�e lorsqu'un "0" est re�u pour la premi�re fois depuis quelques messages
Balise_depart:
					PUSH		Acc						;On sauvegarde l'accumulateur
					CLR		Principal   			;On s'arr�te
					SETB		LED
					INC		nb_tours					;On a fait un tour de plus
					;Affichage du compteur
					MOV		LCD,#adr_tours
					LCALL		LCD_CODE
					MOV		LCD,nb_tours
					LCALL		LCD_DATA	
						
					MOV		LCD,#adr_fin_l1
					LCALL		LCD_CODE					;dernier carract�re de la premi�re ligne
					MOV		LCD,#02h					;carract�re sablier
					LCALL		LCD_DATA
					
					LCALL		Attente_1s
SI_3_tours:		MOV		A,nb_tours				;Si on a fait 3 tours
					CJNE		A,#"3",SINON_3_tours
					MOV		LCD,#adr_ligne1		;On se place au premier carract�re de la DDRAM
					LCALL		LCD_CODE
					MOV		DPTR,#shutdown_msg1	;Ligne 1
					LCALL		LCD_msg
					MOV		LCD,#adr_ligne2      ;On se place au premier carract�re de la 2e ligne
					LCALL		LCD_Code
					MOV		DPTR,#shutdown_msg2  ;Ligne 2
					LCALL		LCD_msg
					MOV		PCON,#02h	;sudo shutdown now -m "On a termin�"
					RET						;Cette instruction est cens�e ne jamais �tre ex�cut�e (car apr�s un "shutdown")
SINON_3_tours:	SETB		Principal	;Sinon,on repart
					CLR		LED
					SETB		attente_4	;On n'ex�cutera pas cette routine avant d'avoir recu un "4"
					CLR		FLAG_D
					CLR		FLAG_C
					CLR		FLAG_G		
					
					MOV		LCD,#adr_fin_l1
					LCALL		LCD_CODE		;dernier carract�re de la premi�re ligne
					MOV		LCD,#" "
					LCALL		LCD_DATA    ;On efface le sablier
               			POP		Acc			;On restaure l'accumulateur 
               			RET
;_____________________________________________________________________
;Routine d'interruption du Timer 0
IT_Timer0:	
					CLR		Sirene
					CLR		Laser
					CLR		FLAG_4				;On ne veut plus relancer ce timer
					CLR		TR0					;On arr�te le timer0
					MOV		TH0,#00h
					MOV		TL0,#00h				;On remet le timer � 0 pour la routine Attente
					MOV		IE,#00h				;D�sactivation de l'interruption
					MOV		LCD,#adr_fin_l1
					LCALL		LCD_CODE				;dernier carract�re de la premi�re ligne
					MOV		LCD,#" "
					LCALL		LCD_DATA				;On efface la cloche
					MOV		msg_prec,#"1" 		;Si le prochain message re�u est "4", on rallume le laser
					RETI

					$if (0)					
;______________________________________________________________________
;Routine permettant d'afficher le message re�u par UART sur le LCD
Debug_UART:    
Att_RI_Debug:	JNB		RI,Att_RI_Debug	;On attend de recevoir qqch de la balise  
					CLR		RI
					MOV		LCD,#clear
					LCALL		LCD_CODE
					MOV		A,SBUF
					ANL		A,#7Fh				;Masque bit de parit�
					MOV		LCD,A
					LCALL		LCD_Data
					LCALL		Attente
					LCALL		Attente				;Attente 100 ms
					SJMP		Att_RI_Debug
					RET
					
;__________________________________________________________________________	
;Routine affichant un "0" sur le LCD � chaque fois qu'un "0" est recu p�r UART
;et affichant un "1" chaque fois qu'autre chose est recu									
Debug_UART2:	
Att_RI_Debug2:	JNB		RI,Att_RI_Debug2	;On attend de recevoir qqch de la balise  
					CLR		RI
					MOV		A,SBUF
					ANL		A,#7Fh				;Masque bit de parit�
					CJNE		A,#"0",PAS_ZERO
					MOV		LCD,#"0"
					LCALL		LCD_DATA
					SJMP		FIN_debug2
PAS_ZERO:		MOV		LCD,#"1"
					LCALL		LCD_Data
FIN_debug2:				
					SJMP		Att_RI_Debug2
					RET
					
					$endif
					end
