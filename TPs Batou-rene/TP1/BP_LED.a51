;BP_LED
;Créé par Rémi et Baptiste
;23/10/2019

BP				bit		P0.0
Aff			bit		P3.0

				org		0000h
				
debut:
att_bp1:		JNB		BP,att_bp1
att_bp0:		JB			BP,att_bp0
				CPL		Aff
fin:			SJMP		debut
				end 
