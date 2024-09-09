#include <stdio.h>

int main()
{
    int numbers[5] = {1, 2, 3, 4, 5};
    char greeting[10] = "Hello";

    if (greeting[0] == 'H') 
        if (numbers[0] == 1) // Changed from '1' to 1 to match the integer type
            printf("Greeting starts with H and first number is 1");
        else
            printf("Greeting starts with H but first number is not 1");
    }
    else
        printf("Greeting does not start with H");

    return 0;
}
