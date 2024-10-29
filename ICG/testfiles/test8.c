#include <stdio.h>

void fun2(int n){
	printf("called function 2");
}
void fun1(int n)
{
	printf("called function 1");
	fun2(3);
}

void main()
{
	fun1(3);
}
