.386
.model flat, stdcall

extern GetStdHandle@4: proc
extern WriteConsoleA@20: proc
extern ReadConsoleA@20: proc
extern wsprintfA: proc
extern lstrlenA@4: proc
extern CharToOemA@8: proc

include macros.inc

.data
	sym_s db "Enter the symbol: ", 0
	invite_s db "Enter the strings: (Ctrl + Z for exit)", 10, 13, 0
	format db "String number: %d, number of symbols '%c': %d", 10, 13, 0

	buffer db 256 dup(?)
	symbol db ?
	str_count dd 0
	char_count_buffer dd 1000 dup(?)

	din dd ?
	dout dd ?
	lens dd ?

.code
	main proc
		GetDescriptors din, dout

		PrintString dout, sym_s, lens
		ReadSymbol din, buffer, symbol, lens
	
		PrintString dout, invite_s, lens

		mov edi, offset char_count_buffer
		mov lens, 256

begin:	ReadString din, buffer, lens
		mov lens, 256
		mov eax, offset buffer
		mov bl, [eax]
		cmp bl, 26		; if string starts with Ctrl + Z then exit
		je exit

		CharCount buffer, symbol
		mov [edi], eax
		inc edi
		inc str_count
		jmp begin

		; Preparing for printing results
exit:	mov edi, offset char_count_buffer
		xor ebx, ebx
		inc ebx			; ebx = 1

		; Print result
l:		xor eax, eax
		mov al, [edi]
		push eax
		push dword ptr[symbol]
		push ebx
		push offset format
		push offset buffer
		call wsprintfA	

		PrintString dout, buffer, lens
		inc ebx
		inc edi
		cmp ebx, str_count
		jle l
		
		main endp
		end main