 ;CTR_4b
 ;created by Rémi and Baptiste
 ;23/10/2019
 ;version 0
 
 BP					bit					P0.0
 MINET				bit					P0.1
 Aff					data					P3
 
 						org					0000h
debut:
						MOV					Aff,#0h
rpt:
att_bp1:				JNB					BP,att_bp1
att_bp0:				JB						BP,att_bp0
SI:					JNB					MINET,SINON
						INC					Aff
FSI:					SJMP					FSINON
SINON:				DEC					Aff
FSINON:
fin:					SJMP					rpt
						end 		
