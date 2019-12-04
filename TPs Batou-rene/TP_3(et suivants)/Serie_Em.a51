;Serie_Em
;Created by Rémi Lamiaux and Baptiste Ghirardi
;29/11/2019
;version 1.0

BP			bit		P0.0
Donnee	data		P1

			org		0000h
			
debut:
			MOV		TH1,#0E6h
			MOV		SCON,#50h
			MOV		TMOD,#20h
			MOV		TCON,#40h

RPT:
att_BP0: JNB		BP,att_BP0
att_BP1: JB			BP,att_BP1
			MOV		A,Donnee
			ANL		A,#0Fh
			ORL		A,#30h
			MOV		SBUF,A
att_TI0: JNB		TI,att_TI0
			CLR		TI
JSQ:		SJMP		RPT
fin:

			end 
