GetDescriptors macro din, dout
	push -10
	call GetStdHandle@4
	mov din, eax

	push -11
	call GetStdHandle@4
	mov dout, eax 
endm

PrintString macro dout, string, lens
	push offset string
	call lstrlenA@4

	push 0
	push offset lens
	push eax
	push offset string
	push dout
	call WriteConsoleA@20
endm

ReadSymbol macro din, buffer, symbol, lens
	push 0
	push offset lens
	push lens
	push offset buffer
	push din
	call ReadConsoleA@20

	mov eax, offset buffer
	mov bl, [eax]
	mov symbol, bl
endm

ReadString macro din, buffer, lens
	push 0
	push offset lens
	push lens
	push offset buffer
	push din
	call ReadConsoleA@20
endm

CharCount macro string, symbol
local begin, exit, false

		; initialization
		xor eax, eax
		mov esi, offset string
		mov bl, symbol

		; while loop
begin:	mov dl, [esi]
		cmp dl, 10
		je exit			; if dl == '\n' then exit
		cmp dl, bl
		jne false		; if (dl == bl) then (ax = ax + 1) else (pass)
		inc eax
false:	inc esi
		jmp begin
exit:
endm
