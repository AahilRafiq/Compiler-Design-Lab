#include<stdio.h>

//correct test for better scope understanding with multiple while loops

int main()
{
	int a = 5;
	while(a>0)
	{
		printf("Hello world");
		a--;
	}

	a=4;
	while(a>0)
	{
		printf("%d",a);
		a--;
		int b;
		b= 4;
		while(b>0)
		{
			printf("%d", a*b);
			b--;
		}
	}
}
