;Gene
;Created by Lamiaux Rémy and Ghirardi Baptiste
;20/11/2019
;version 1

Gene			bit			P3.0 
V0_Init_H   equ 			0FFh
V0_Init_L   equ 			038h+0Ah				;V0_Init_L = N_L + Nr
V1_Init_H   equ 			0FCh
V1_Init_L   equ 			0E0h+0Ah						
Etape			bit			0b

   			org			0000h
				SJMP			debut
				
				org			000Bh
				LJMP			INT_Timer0
				
				org			0030h
   			
debut: 
				MOV			SP,#0Fh
		      MOV			TMOD,#01h
		      MOV			IE,#10000010b
		      CLR			Gene
		      SETB			Etape
		      
		      MOV			A,TL0					
				ADD			A,#V1_Init_L		
		      MOV			TL0,A					
		      MOV			A,TH0					
		      ADDC			A,#V1_Init_H		
		      MOV			TH0,A					
		      CLR			TF0					
		      SETB			TR0					

fin:  	   SJMP			fin


INT_Timer0: 

SI:			JNB		   Etape,SINON
				MOV			R0,#V0_Init_L
		      MOV			R1,#V0_Init_H
		      CLR			Etape
		      SETB			Gene
FIN_SI:		SJMP			FIN_SINON      
SINON:
		      MOV			R0,#V1_Init_L
		      MOV			R1,#V1_Init_H
		      SETB			Etape
		      CLR			Gene
FIN_SINON:				
				PUSH			Acc				
				CLR			TR0					
				MOV			A,TL0					;1CM
				ADD			A,R0					;1CM
		      MOV			TL0,A					;1CM
		      MOV			A,TH0					;1CM
		      ADDC			A,R1					;1CM
		      MOV			TH0,A					;1CM
		      CLR			TF0					;1CM
		      POP			Acc					;2CM
		      SETB			TR0					;1CM
FIN_INT_Timer0:	
				RETI

				end


