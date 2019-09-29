.386 
.MODEL FLAT, STDCALL

EXTERN GetStdHandle@4: PROC
EXTERN WriteConsoleA@20: PROC
EXTERN CharToOemA@8: PROC
EXTERN ReadConsoleA@20: PROC
EXTERN ExitProcess@4: PROC
EXTERN lstrlenA@4: PROC

.DATA
    STR1 DB "Введите число 1: ", 13, 10, 0
    STR2 DB "Введите число 2: ", 13, 10, 0
    ERRSTR DB "Ошибка! Неправильно введено число", 13, 10, 0
    RESSTR DB "Результат: ", 0

    NUMSTR DB 10 dup (?)
    LEN DD ?
    NUM DW ?
    RES DW 0

    DIN DD ?
    DOUT DD ?

	FLAG DB 0

.CODE
    MAIN PROC
    
		; Перекодировка первой строки
		MOV EAX, OFFSET STR1
		PUSH EAX
		PUSH EAX
		CALL CharToOemA@8

		; Перекодировка второй строки
		MOV EAX, OFFSET STR2
		PUSH EAX
		PUSH EAX
		CALL CharToOemA@8

		; Перекодировка строки ошибки
		MOV EAX, OFFSET ERRSTR
		PUSH EAX
		PUSH EAX
		CALL CharToOemA@8

		; Перекодировка строки результата
		MOV EAX, OFFSET RESSTR
		PUSH EAX
		PUSH EAX
		CALL CharToOemA@8

		; Получение дескриптора ввода
		PUSH -10
		CALL GetStdHandle@4
		MOV DIN, EAX

		; Получение дискриптора вывода
		PUSH -11
		CALL GetStdHandle@4
		MOV DOUT, EAX
    
		; Система счисления - восьмеричная
		XOR EDI, EDI
		MOV EDI, 8

		; Обработка первого числа
BEGIN:	PUSH OFFSET STR1
		CALL lstrlenA@4

		PUSH 0
		PUSH OFFSET LEN
		PUSH EAX
		PUSH OFFSET STR1
		PUSH DOUT
		CALL WriteConsoleA@20

		PUSH 0
		PUSH OFFSET LEN
		PUSH 8
		PUSH OFFSET NUMSTR
		PUSH DIN
		CALL ReadConsoleA@20

		SUB LEN, 2
		MOV ECX, LEN
		MOV ESI, OFFSET NUMSTR
		XOR BX, BX    
		XOR AX, AX

CON1:		MOV BL, [ESI]

			CMP BL, '-'
			JNE M
			MOV FLAG, 1
			JMP M1

M:			SUB BL, '0'
			CMP BL, 0
			JB ERROR
			CMP BL, 7
			JA ERROR
			MUL DI
			ADD AX, BX
M1:			INC ESI
		LOOP CON1

		CMP FLAG, 1
		JNE F
		NEG AX
F:		ADD RES, AX
		MOV FLAG, 0

		; Обработка второго числа
		PUSH OFFSET STR2
		CALL lstrlenA@4

		PUSH 0
		PUSH OFFSET LEN
		PUSH EAX
		PUSH OFFSET STR2
		PUSH DOUT
		CALL WriteConsoleA@20

		PUSH 0
		PUSH OFFSET LEN
		PUSH 8
		PUSH OFFSET NUMSTR
		PUSH DIN
		CALL ReadConsoleA@20


		SUB LEN, 2
		MOV ECX, LEN
		MOV ESI, OFFSET NUMSTR
		XOR BX, BX    
		XOR AX, AX

CON2:		MOV BL, [ESI]

			CMP BL, '-'
			JNE M2
			MOV FLAG, 1
			JMP M3

M2:			SUB BL, '0'
			CMP BL, 0
			JB ERROR
			CMP BL, 7
			JA ERROR
			MUL DI
			ADD AX, BX
M3:			INC ESI
		LOOP CON2

		CMP FLAG, 1
		JNE F2
		NEG AX
F2:		ADD RES, AX
		MOV FLAG, 0

		; Перевод результата в строку
		MOV AX, RES
		MOV DI, 10
		MOV LEN, 0
	
		JNS CON3
		NEG AX
		MOV FLAG, 1


CON3:		DIV DI
			PUSH DX
			XOR DX, DX
			ADD LEN, 1
			CMP AX, 0
		JA CON3

		MOV ESI, OFFSET NUMSTR
		MOV ECX, LEN

		CMP FLAG, 1
		JNE CON4
		MOV BL, '-'
		MOV [ESI], BL
		INC ESI

CON4:		POP BX
			ADD BX, '0'
			MOV [ESI], BX
			INC ESI
		LOOP CON4

		; Вывод результата
		PUSH OFFSET RESSTR
		CALL lstrlenA@4

		PUSH 0
		PUSH OFFSET LEN
		PUSH EAX
		PUSH OFFSET RESSTR
		PUSH DOUT
		CALL WriteConsoleA@20

		PUSH OFFSET NUMSTR
		CALL lstrlenA@4

		PUSH 0
		PUSH OFFSET LEN
		PUSH EAX
		PUSH OFFSET NUMSTR
		PUSH DOUT
		CALL WriteConsoleA@20


		MOV ECX, 03FFFFFFFH
		L1: LOOP L1

		PUSH 0
		CALL ExitProcess@4

		; Ошибка введения числа
		ERROR:
			PUSH OFFSET ERRSTR
			CALL lstrlenA@4

			PUSH 0
			PUSH OFFSET LEN
			PUSH EAX
			PUSH OFFSET ERRSTR
			PUSH DOUT
			CALL WriteConsoleA@20

			JMP BEGIN

		MAIN ENDP
		END MAIN
