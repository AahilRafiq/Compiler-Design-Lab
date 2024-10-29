#include <stdio.h>

int sum(int a, int b)
{
	int x = a + b;
	return x;
}

void main()
{
	int a = 2;
	int b = 10;
	int ans = sum(b, a);
	printf("ans: %d", ans);
}