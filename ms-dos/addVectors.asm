;;;*********************************************************************
;;; 			Adds two vectors of three elements
;;;*********************************************************************
	
	DOSSEG
	.MODEL	SMALL
	.STACK					; Empty stack.
	.RADIX	16				; Using HEX base.
	
;;;******************************* MACROS *******************************

Breakline MACRO
	MOV	DL, 0AH
	MOV	AH, 02H
	INT	21H
	MOV	DL, 0DH
	MOV	AH, 02H
	INT	21H
ENDM

ReadStrFromKbd MACRO strOffset
	MOV	DX, OFFSET strOffset		; Reads a string and stores the string
	MOV	AH, 0AH				;  in strOffset.
	INT	21H
	Breakline
ENDM

PrintStr MACRO msg
	MOV	DX, OFFSET msg			; Prints a string.
	MOV	AH, 09H
	INT	21H
	Breakline
ENDM

String2Number MACRO num, str
	MOV	DS:[tmpaddr], OFFSET num 	; Converts the string str to a number
	MOV	BP, OFFSET str			;  stored at num
	ADD	BP, 02H
	CALL	Str2Num
ENDM
	
Number2String MACRO str, num
	MOV	BP, OFFSET num			; Converts a number stored at vecRES[0] to
	MOV	DS:[tmpaddr], OFFSET str	;  a string stored at strRES1.
	CALL	Num2Str
ENDM

;;;********************************* DATA ********************************
	
	.DATA
	msg1	DB 	"Insert three numbers for the first vector:$"
	msg2	DB 	"Insert three numbers for the second vector:$"
	msg3	DB 	"The sum of the two vectors is:$"
	strA1	DB 	06H,00H,6 dup (00H)
	strA2	DB 	06H,00H,6 dup (00H)
	strA3	DB 	06H,00H,6 dup (00H)
	strB1	DB 	06H,00H,6 dup (00H)
	strB2	DB 	06H,00H,6 dup (00H)
	strB3	DB 	06H,00H,6 dup (00H)
	strRES1	DB 	5 dup (00H),'$'
	strRES2	DB 	5 dup (00H),'$'
	strRES3	DB 	5 dup (00H),'$'
	tmpaddr	DW	0000H
	vecA	DW	3 dup (0000H)
	vecB	DW	3 dup (0000H)
	vecRES	DW	3 dup (0000H)
	ten	DW	0AH
	res	DW	00H
	tmpmul	DW	01H
	
;;;********************************** CODE *******************************
	
	.CODE

;;;******************************* Str2Num *******************************
;;;	Receives a string starting with offset stored in BP ended by 0DH (CR).
;;;	Stores the result at offset stored in tmpaddr.
Str2Num	PROC
;;;		 Calculating the size of the string:
	XOR	SI, SI
CalcStrSize:	
	CMP	BYTE PTR DS:[BP + SI], 0DH
	JE	EndCalcStrSize
	INC	SI
	JMP	CalcStrSize
EndCalcStrSize:					; Now SI is holding the num of chars in the string.
	MOV	CX, SI
;;; 		Starts converting the string to a number:
	MOV	DX, 0001H
	MOV	DS:[tmpmul], DX
	XOR	DX, DX
	MOV	DS:[res], DX
	DEC	SI
ConvStr2Num:
	XOR	BX, BX
	MOV	BL, DS:[BP + SI]
	SUB	BL, '0'
	DEC	SI
	MOV	AX, DS:[tmpmul]
	MUL	BX
	ADD	DS:[res], AX
	MOV	AX, DS:[tmpmul]
	MUL	DS:[ten]
	MOV	DS:[tmpmul], AX
	LOOP	ConvStr2Num
ENDstr2Num:
	MOV	SI, DS:[tmpaddr]
	MOV	AX, DS:[res]
	MOV	WORD PTR DS:[SI], AX
	RET	
Str2Num	ENDP

;;;******************************* Num2Str *******************************
;;;	Receives a 16-bits number with offset stored in BP.
;;;	Stores the result at offset stored in tmpaddr.
Num2Str	PROC
	XOR	SI, SI
	XOR	CX, CX
	MOV	AX, DS:[BP]
	MOV	BP, DS:[tmpaddr]
	MOV	BL, 0AH
ConvNum2Str:
	CMP	AX, 0000H
	JE	ENDConvNum2str
	IDIV	BL
	PUSH	AX
	XOR	AH, AH
	INC	SI
	JMP	ConvNum2Str
ENDConvNum2str:
	MOV	CX, SI
	XOR	SI, SI
ReversNum2str:
	POP	AX
	ADD	AH, '0'
	MOV	DS:[BP + SI], AH
	INC	SI
	LOOP	ReversNum2str
	RET
Num2Str	ENDP	
;;;******************************* Main *******************************
	
Main	PROC
	MOV	AX, @DATA			; Copy data segment addr to DS.
	MOV	DS, AX
	
	PrintStr msg1				; Prints msg1.

	ReadStrFromKbd strA1			; Reads strings from keyboard.
	ReadStrFromKbd strA2
	ReadStrFromKbd strA3

	PrintStr msg2				; Prints msg2.

	ReadStrFromKbd strB1			; Reads strings from keyboard.
	ReadStrFromKbd strB2
	ReadStrFromKbd strB3
	
	String2Number vecA, strA1
	String2Number vecA+02H, strA2
	String2Number vecA+04H, strA3

	String2Number vecB, strB1
	String2Number vecB+02H, strB2
	String2Number vecB+04H, strB3	

	MOV	SI, 0000H
	MOV	CX, 0003H
AddVecs:
	MOV	BP, offset vecA
	MOV	AX, DS:[BP + SI]
	MOV	BP, offset vecB
	ADD	AX, DS:[BP + SI]
	MOV	BP, offset vecRES
	MOV	DS:[BP + SI], AX
	ADD	SI, 0002H
	LOOP	AddVecs

	Number2String strRES1, vecRES
	Number2String strRES2, vecRES+02H
	Number2String strRES3, vecRES+04H
	
	PrintStr msg3				; Prints msg3.
	
	PrintStr strRES1			; Prints strRES1.
	PrintStr strRES2			; Prints strRES2.
	PrintStr strRES3			; Prints strRES3.
	
	MOV	AH, 4CH				; Calls the end of program DOS
	INT	21H				;  interruption routine.
Main	ENDP
	END	Main
