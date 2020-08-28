.386
.MODEL FLAT, C
.DATA
	A DD 1000.0
	B DD 0.7

.CODE
	func PROC
		PUSH EBP
		MOV EBP, ESP 
		SUB ESP, 12

		MOV EAX, 2
		MOV [EBP - 4], EAX
		MOV EAX, 3
		MOV [EBP - 8], EAX

		FLD B
		FLD A
		
		FPREM

		FINIT
		;								ST(0)			ST(1)
		FLD DWORD PTR [EBP + 8]		;	x
		FCOS						;	cos(x)
		FST ST(1)					;	cos(x)			cos(x)
		FMULP						;	cos^2(x)
		FIMUL DWORD PTR [EBP - 8]	;	3*cos^2(x)
		FIDIV DWORD PTR [EBP - 4]	;	3*cos^2(x)/2
		FIDIV DWORD PTR [EBP - 4]	;	3*cos^2(x)/4
		FSTP DWORD PTR [EBP - 12]	;	Save value in [EBP - 12]

		;								ST(0)			ST(1)
		FLD DWORD PTR [EBP + 8]		;	x
		FSIN						;	sin(x)
		FST ST(1)					;	sin(x)			sin(x)
		FMULP						;	sin^2(x)
		FIMUL DWORD PTR [EBP - 4]	;	2*sin^2(x)
		FIDIV DWORD PTR [EBP - 8]	;	2*sin^2(x)/3
	
		FLD DWORD PTR [EBP - 12]	;	ST(0) = 2*sin^2(x)/3	ST(1) = 3*cos^2(x)/4
		FSUBP						;	ST(0) = 2*sin^2(x)/3 - 3*cos^2(x)/4
		
		MOV ESP, EBP
		POP EBP
		RET
	func ENDP



	dichotomy PROC
		PUSH EBP
		MOV EBP, ESP
		SUB ESP, 16
		; [EBP - 4] - c = (a + b) / 2
		; [EBP - 8] - f(c)
		; [EBP - 12] - f(a)
		; [EBP - 16] - f(b)

		; number of iterations = 0
		XOR EBX, EBX

		FINIT
		; number of iterations += 1
BEGIN:	INC EBX

		; constant = 2
		MOV EAX, 2
		MOV [EBP - 4], EAX

		; c = (a + b) / 2
		FLD A
		FLD B
		FADDP
		FIDIV DWORD PTR [EBP - 4]
		FSTP DWORD PTR [EBP - 4]

		; Calculate f(c)
		PUSH [EBP - 4]
		CALL func
		FSTP DWORD PTR [EBP - 8]

		; Calculate f(a)
		PUSH A
		CALL func
		FSTP DWORD PTR [EBP - 12]

		; Calculate f(b)
		PUSH B
		CALL func
		FSTP DWORD PTR [EBP - 16]

		; Compare f(c) with 0
		FLDZ
		FLD DWORD PTR [EBP - 8]
		FCOMPP
		FSTSW AX 
		SAHF

		JE EXIT		; f(c) = 0
		JA ABOV0	; f(c) > 0
		JMP LESS0	; f(c) < 0

		; Compare f(a) with 0
LESS0:	FLDZ
		FLD DWORD PTR [EBP - 12]
		FCOMPP
		FSTSW AX 
		SAHF

		JB ALESS0
		; if (f(a) > 0) then b = c
		MOV EAX, [EBP - 4]
		MOV B, EAX
		JMP CHECK

		; if (f(a) < 0) then a = c
ALESS0:	MOV EAX, [EBP - 4]
		MOV A, EAX
		JMP CHECK


		; Compare f(a) with 0
ABOV0:	FLDZ
		FLD DWORD PTR [EBP - 12]
		FCOMPP
		FSTSW AX 
		SAHF

		JAE AABOV0
		; if (f(a) < 0) then b = c
		MOV EAX, [EBP - 4]
		MOV B, EAX
		JMP CHECK

		; if (f(a) > 0) then a = c
AABOV0: MOV EAX, [EBP - 4]
		MOV A, EAX
		JMP CHECK

		; Find (b - a)
CHECK:	FLD A
		FLD B
		FSUBP
		FABS
		; Compare (b - a) with eps
		FLD DWORD PTR [EBP + 8]
		FCOMPP
		FSTSW AX 
		SAHF

		JA EXIT
		JMP BEGIN

		; return number of iterations
EXIT:	MOV EAX, EBX
		; return x
		MOV EDX, [EBP - 4]
		MOV EBX, [EBP + 12]
		MOV [EBX], EDX

		MOV ESP, EBP
		POP EBP
		RET
	dichotomy ENDP
END