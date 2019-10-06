.386
.MODEL FLAT, C
.DATA
	A DD 0.0
	B DD 1.5707963
	

.CODE
	func PROC
		PUSH EBP
		MOV EBP, ESP 
		SUB ESP, 12

		MOV EAX, 2
		MOV [EBP - 4], EAX
		MOV EAX, 3
		MOV [EBP - 8], EAX

		FINIT
		;							ST(0)			ST(1)
		FLD DWORD PTR [EBP + 8]  ;	x
		FSIN					  ;	sin(x)
		FST ST(1)				  ;	sin(x)			sin(x)
		FMULP					  ;	sin^2(x)
		FIMUL DWORD PTR [EBP - 4] ;	2*sin^2(x)
		FIDIV DWORD PTR [EBP - 8] ;	2*sin^2(x)/3
		FSTP DWORD PTR [EBP - 12] ;	Save value in [EBP - 16]

		;							ST(0)			ST(1)
		FLD DWORD PTR [EBP + 8]	  ;	x
		FCOS					  ; cos(x)
		FST ST(1)				  ;	cos(x)			cos(x)
		FMULP					  ; cos^2(x)
		FIMUL DWORD PTR [EBP - 8] ; 3*cos^2(x)
		FIDIV DWORD PTR [EBP - 4] ;	3*cos^2(x)/2
		FIDIV DWORD PTR [EBP - 4] ; 3*cos^2(x)/4
		
		FLD DWORD PTR [EBP - 12]; ST(0) = 2*sin^2(x)/3	ST(1) = 3*cos^2(x)/4
		FSUB ST, ST(1)			; ST(0) = 2*sin^2(x)/3 - 3*cos^2(x)/4
		MOV ESP, EBP
		POP EBP
		RET
	func ENDP



	dichotomy PROC
		PUSH EBP
		MOV EBP, ESP
		SUB ESP, 4

		MOV EAX, 2
		MOV [EBP - 4], EAX

		FINIT
		; c = (a + b) / 2
		FLD A
		FLD B
		FADDP
		FIDIV DWORD PTR [EBP - 4]
		FSTP DWORD PTR [EBP - 4]

		PUSH [EBP - 4]
		CALL func

		MOV ESP, EBP
		POP EBP
		RET
	dichotomy ENDP
END