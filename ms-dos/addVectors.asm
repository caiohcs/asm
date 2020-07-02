;;;*********************************************************************
;;; 			Adds two vectors of three positive elements,
;;; 			  each element can have up to 3 digits.
;;; 			Each element is inserted via keyboard.
;;;*********************************************************************
	
	DOSSEG
	.MODEL	SMALL
	.STACK
	.RADIX	10				; Using base 10.

;;;********************************* DATA ********************************
	
	.DATA
	msg1	DB 	"Insert three numbers for the first vector:$"
	msg2	DB 	"Insert three numbers for the second vector:$"
	msg3	DB 	"The sum of the two vectors is:$"
	msgCR	DB	0AH, 0DH, '$' 		; Used to break line.
	strA1	DB 	06H,00H,6 dup (00H)	; Will store the element A[0] as an ASCII string.
	strA2	DB 	06H,00H,6 dup (00H)	; Will store the element A[1] as an ASCII string.
	strA3	DB 	06H,00H,6 dup (00H)	; Will store the element A[2] as an ASCII string.
	strB1	DB 	06H,00H,6 dup (00H) 	; Will store the element B[0] as an ASCII string.
	strB2	DB 	06H,00H,6 dup (00H) 	; Will store the element B[1] as an ASCII string.
	strB3	DB 	06H,00H,6 dup (00H) 	; Will store the element B[2] as an ASCII string.
	strRES1	DB 	5 dup (00H),'$'		; Will store the element RES[0] as an ASCII string.
	strRES2	DB 	5 dup (00H),'$'		; Will store the element RES[1] as an ASCII string.
	strRES3	DB 	5 dup (00H),'$'		; Will store the element RES[2] as an ASCII string.
	tmpaddr	DW	0000H			; Temporary variable for addresses.
	vecA	DW	3 dup (0000H)		; Will store A[0] - A[2] in binary form.
	vecB	DW	3 dup (0000H)		; Will store A[0] - A[2] in binary form.
	vecRES	DW	3 dup (0000H)		; Will store RES[0] - RES[2] in binary form.
	ten	DW	000AH			; Constant 10.
	res	DW	0000H			; Temporary value for results.
	tmpmul	DW	0001H			; Temporary value for multiplications on string 2 bin conversions.
 	
;;;******************************* MACROS *******************************

Breakline MACRO					
	MOV	DX, OFFSET msgCR		; Break line (i.e. <ENTER>)
	MOV	AH, 09H
	INT	21H
ENDM

	
ReadStrFromKbd MACRO strOffset
	MOV	DX, OFFSET strOffset		; Reads a string from keyboard and stores the string
	MOV	AH, 0AH				;  at DS:[strOffset].
	INT	21H
	Breakline
ENDM

	
PrintStr MACRO msg
	MOV	DX, OFFSET msg			; Prints a string located at DS:[msg], ended by the char '$'.
	MOV	AH, 09H
	INT	21H
	Breakline
ENDM

	
String2Number MACRO num, str
	MOV	DS:[tmpaddr], OFFSET num	; Puts the arguments in the appropriate locations before calling
	MOV	BX, OFFSET str			;  the procedure Str2Num.
	ADD	BX, 01H
	CALL	Str2Num				; Calls the procedure that converts an ASCII string to binary.
ENDM						; The first element of the string must be the number of characters.

	
Number2String MACRO str, num
	MOV	BX, OFFSET num			; Puts the arguments in the appropriate locations before calling
	MOV	DS:[tmpaddr], OFFSET str	;  the procedure Num2Str.
	CALL	Num2Str				; Calls the procedure that converts a binary number
ENDM						;  to an ASCII string.

;;;********************************** CODE *******************************
	
	.CODE

;;;******************************* Str2Num *******************************
;;;	Receives a string starting with offset stored in BX ended by 0DH (CR).
;;;	Stores the result at offset stored in tmpaddr.
;;;	The first element of the string must be the number of characters.
Str2Num	PROC
	XOR	CH, CH
	MOV	CL, DS:[BX]			; Puts the number of chars in CX.
	INC	BX				; Now BX points to the first character.
	MOV	SI, CX				; Puts the number of chars in SI.
	DEC	SI				; Now SI points to the last char.
	MOV	DX, 0001H
	MOV	DS:[tmpmul], DX			; Initialize the variable tmpmul with 1.
	MOV	AX, DX				; Initializes AX with 1.
	XOR	DX, DX
	MOV	DS:[res], DX			; Initialize the variable res with 0.
	
						; The following loop iterates the string in reverse order
						;  converting each ASCII char to binary then
						;  it multiplies the corresponding digit by 1, 10, 100, 1000 etc. 
						; The variable res will accumulate the sum of the digits.
						; The variable tmpmul will hold the powers of 10: 1, 10, 100 etc.
ConvStr2Num:
	XOR	DX, DX
	MOV	DL, DS:[BX + SI]
	SUB	DL, '0'
	MUL	DX
	ADD	DS:[res], AX
	MOV	AX, DS:[tmpmul]
	MUL	DS:[ten]
	MOV	DS:[tmpmul], AX
	DEC	SI
	LOOP	ConvStr2Num
ENDstr2Num:
	MOV	SI, DS:[tmpaddr]
	MOV	AX, DS:[res]
	MOV	WORD PTR DS:[SI], AX
	RET	
Str2Num	ENDP

;;;******************************* Num2Str *******************************
;;;	Receives a 16-bits number with offset stored in BX, converts it to
;;; 	 an ASCII string representation, then stores the string at offset
;;;	 stored in tmpaddr.
Num2Str	PROC
	XOR	SI, SI
	XOR	CX, CX
	MOV	AX, DS:[BX]			; Puts the number in AX.
	MOV	BX, DS:[tmpaddr]		; BX now points to the first char of the string.
	MOV	DL, 0AH				; Puts 10 in DL.

						; The following loop divides the number by 10 at each interation
						;  to get each digit. Since we get the digits at reverse order,
						;  we push them in the stack, so that we can push them latter
						;  to fix the order of the digits.
ConvNum2Str:
	CMP	AX, 0000H
	JE	ENDConvNum2str
	IDIV	DL
	PUSH	AX
	XOR	AH, AH
	INC	SI
	JMP	ConvNum2Str
ENDConvNum2str:
	MOV	CX, SI
	XOR	SI, SI
ReversNum2str:					; Retrieves the digits from the stack and coverts them to ASCII.
	POP	AX
	ADD	AH, '0'
	MOV	DS:[BX + SI], AH
	INC	SI
	LOOP	ReversNum2str
	RET
Num2Str	ENDP
;;;******************************* Main *******************************
	
Main	PROC
	MOV	AX, @DATA			; Copy data segment addr to DS.
	MOV	DS, AX
	
	PrintStr msg1

	ReadStrFromKbd strA1
	ReadStrFromKbd strA2
	ReadStrFromKbd strA3

	PrintStr msg2

	ReadStrFromKbd strB1
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
AddVecs:					; Loop to add the two vectors
	MOV	BX, offset vecA
	MOV	AX, DS:[BX + SI]
	MOV	BX, offset vecB
	ADD	AX, DS:[BX + SI]
	MOV	BX, offset vecRES
	MOV	DS:[BX + SI], AX
	ADD	SI, 0002H
	LOOP	AddVecs

	Number2String strRES1, vecRES
	Number2String strRES2, vecRES+02H
	Number2String strRES3, vecRES+04H
	
	PrintStr msg3
	
	PrintStr strRES1
	PrintStr strRES2
	PrintStr strRES3
	
	MOV	AH, 4CH				; Calls the end of program DOS
	INT	21H				;  interruption routine.
Main	ENDP
	END	Main
