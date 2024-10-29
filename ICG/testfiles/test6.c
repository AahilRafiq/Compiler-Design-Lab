#include <stdio.h>

int main()
{
    int i;
    for (i = 0; i < 5; i++)
    {
        printf("for loop printing\n");
    }

    while (i > 0)
    {

        printf("while loop printing\n");
        i = i - 1;
    }

    do
    {
        printf("do while loop printing\n");
        i = i - 1;
    } while (i > 10);
}