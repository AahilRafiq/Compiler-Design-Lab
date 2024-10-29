#include <stdio.h>
int sq(int num)
{
	int num = 3;
	int sq = num * num;
	return sq;
}

int main()
{
	int num = 3;
	int ans = sq(num);
	printf("answer: %d", ans);

	return 0;
}