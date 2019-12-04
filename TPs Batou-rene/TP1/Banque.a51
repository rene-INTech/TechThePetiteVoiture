;Banque
;created by Remi Lamiaux and Baptiste Ghirardi 
;23/10/2019
;version 0.0

humidite			equ			R0 				
temperature		equ			R0
flag				bit			08h           						;dernier capteur ayant envoyé des informations
val				data			P1					
capteur_h		data			P2										;donnée humidité
capteur_t		data			P3										;donnée température
adr				bit			80h 									;adresse du capteur

					org			0000h		
                                                                         ;2
debut:
					CLR			RS0									;on se place dans la banque 0 								2
					MOV			humidite,capteur_h				;adressage direct                                     2
					SETB			RS0                           ;on se place dans la banque 1                         2
					MOV			temperature,capteur_t			;adressage direct                                     2
					MOV			C,adr									;adressage direct                                     2
					MOV			flag,C								;adressage direct                                     2
					MOV			RS0,C									;adressage direct                                     2
					MOV			val,R0								;adressage direct                                     2
					
				
				
fin:				SJMP			debut				;boucler à l'infini                                                  3
					end                                                                                                               
