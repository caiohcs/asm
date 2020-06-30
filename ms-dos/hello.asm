;; Assemble with "tasm.exe /zi hello.asm"
;; Link with "tlink.exe /v hello.obj"
;; Run with "hello.exe"
;; Debug with "td hello.exe"
	DOSSEG
	.MODEL	SMALL
	.STACK					; Empty stack.
	.RADIX	16				; Using HEX base.

	.DATA
msg	DB 	"Hello, word! $" 		; The print routine reads the dollar
						;  sign as the end of the string.

	.CODE
Main	PROC
	MOV	AX, @DATA			; Need to copy the data segment
	MOV	DS, AX				;  address to DS and ES.
	MOV	ES, AX
						; The print string routine
	MOV	DX, OFFSET msg			;  expects a string offset on DX.
	MOV	AH, 09H				; Calls the print string DOS 
	INT	21H 				;  interruption routine.
	
	MOV	AH, 4CH				; Calls the end of program DOS
	INT	21H				;  interruption routine.
Main	ENDP
	END	Main
