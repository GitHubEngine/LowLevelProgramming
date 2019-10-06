#include <string.h>
#include <stdio.h>

extern "C" int dichotomy(float eps, float& x);

int main()
{
	float x = 0;
	int res = dichotomy(0.001, x);
	printf_s("Result: %6f", x);
	return 0;
}