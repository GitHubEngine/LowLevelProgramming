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

NUMSTR DB 8 dup (?)
NUM DW ?
LEN DD ?
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

		; Получение дескриптора вывода
		PUSH -11
		CALL GetStdHandle@4
		MOV DOUT, EAX

		; Система счисления - восьмеричная
		MOV DI, 8

		; Обработка первого числа
BEGIN:	PUSH OFFSET STR1
		CALL lstrlenA@4

		; Вывод приглашения для ввода
		PUSH 0
		PUSH OFFSET LEN
		PUSH EAX
		PUSH OFFSET STR1
		PUSH DOUT
		CALL WriteConsoleA@20

		; Чтение введенной строки
		PUSH 0
		PUSH OFFSET LEN
		PUSH 8
		PUSH OFFSET NUMSTR
		PUSH DIN
		CALL ReadConsoleA@20

		; Подготовка к обработке строки
		SUB LEN, 2
		MOV ESI, OFFSET NUMSTR
		XOR BX, BX
		XOR AX, AX

		; Проверка минуса
		MOV BL, [ESI]
		CMP BL, '-'
		JNE F1
		MOV FLAG, 1
		SUB LEN, 1
		INC ESI

F1:		MOV ECX, LEN
		; Перевод числа в строку
CONV1:	MOV BL, [ESI]
		SUB BL, '0'
		CMP BL, 0
		JB ERROR
		CMP BL, 7
		JA ERROR
		MUL DI
		ADD AX, BX
		INC ESI
		LOOP CONV1

		; Добавление минуса после получения числа
		CMP FLAG, 1
		JNE F2
		NEG AX
F2:		ADD RES, AX
		MOV FLAG, 0

		; Обработка второго числа
		PUSH OFFSET STR2
		CALL lstrlenA@4

		; Вывод приглашения для ввода
		PUSH 0
		PUSH OFFSET LEN
		PUSH EAX
		PUSH OFFSET STR2
		PUSH DOUT
		CALL WriteConsoleA@20

		; Чтение введенной строки
		PUSH 0
		PUSH OFFSET LEN
		PUSH 8
		PUSH OFFSET NUMSTR
		PUSH DIN
		CALL ReadConsoleA@20

		; Подготовка к обработке строки
		SUB LEN, 2
		MOV ESI, OFFSET NUMSTR
		XOR BX, BX
		XOR AX, AX

		; Проверка минуса
		MOV BL, [ESI]
		CMP BL, '-'
		JNE F3
		MOV FLAG, 1
		INC ESI
		SUB LEN, 1

F3:		MOV ECX, LEN
		; Перевод числа в строку
CONV2:	MOV BL, [ESI]
		SUB BL, '0'
		CMP BL, 0
		JB ERROR
		CMP BL, 7
		JA ERROR
		MUL DI
		ADD AX, BX
		INC ESI
		LOOP CONV2

		; Добавление минуса после получения числа
		CMP FLAG, 1
		JNE F4
		NEG AX
F4:		ADD RES, AX
		MOV FLAG, 0

		; Перевод результата в строку
		MOV AX, RES
		MOV DI, 10
		MOV LEN, 0

		; Учитывание минуса при выводе строки
		JNS CONV3
		NEG AX
		MOV FLAG, 1

		; Добавление цифр числа в стек
CONV3:	DIV DI
		PUSH DX
		XOR DX, DX
		ADD LEN, 1
		CMP AX, 0
		JA CONV3

		; Подготовка для вывода строки
		MOV ESI, OFFSET NUMSTR
		MOV ECX, LEN
		CMP FLAG, 1
		JNE CONV4
		MOV BX, '-'
		MOV [ESI], BX
		INC ESI

		; Вывод строки
CONV4:	POP BX
		ADD BX, '0'
		MOV [ESI], BX
		INC ESI
		LOOP CONV4

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