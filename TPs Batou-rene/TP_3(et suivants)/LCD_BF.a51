;LCD_BF
;Created by Rémy Lamiaux and Baptiste Ghirardi
;27/11/2019
;version 1.0

BF					bit					P2.7
RSelect			bit					P1.5 
RW					bit					P1.6
E					bit					P1.7


					org					0000h
					
debut:
					LCALL					LCD_BF
fin: 				SJMP					debut
			
LCD_BF:
					MOV					P1,#0FFh
					CLR					RSelect
					SETB					RW
RPT_BF:				
					CLR					E
					SETB					E
JSQ_BF:			JB						BF,RPT_BF
					CLR					E
fin_LCD_BF:		RET

					end
