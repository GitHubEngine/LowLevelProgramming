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
	sym_str db "Enter the symbol: ", 0
	string_str db "Enter the strings: (Ctrl + Z for exit)", 10, 13, 0
	format db "String number: %d, number of symbols: %d", 10, 13, 0

	buffer db 256 dup(?)
	symbol db ?
	str_count dw 0

	din dd ?
	dout dd ?
	lens dd ?

.code
	main proc
	GetDescriptors din, dout

	PrintString dout, sym_str, lens
	ReadSymbol din, symbol, lens
	
	PrintString dout, string_str, lens

	; 4. read string
	; 5. if string starts with Ctrl + Z then exit
	; 6. else process string 
	; 7. print number of symbols in the string and number of the string for each string

	main endp
	end main