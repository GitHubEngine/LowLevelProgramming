#include <string.h>
#include <stdio.h>

const int size = 8193;
extern "C" char* DELDOTS(const char *);

int main()
{
	char string[size];
	printf_s("Enter string (max. length: %d) > ", size - 1);
	gets_s(string, size);
	char* res = DELDOTS(string);
	printf_s("Result > %s\n\n\n", res);
	return 0;
}
