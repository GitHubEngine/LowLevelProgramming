#include <string.h>
#include <stdio.h>

extern "C" char* DELDOTS(char *, int);

int main()
{
	char string[] = "a.b.c.klj.";

	int length = strlen(string);
	char* res = DELDOTS(string, length);

	printf_s(res);
	return 0;
}
