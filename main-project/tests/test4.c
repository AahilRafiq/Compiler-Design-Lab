#include <stdio.h>

int main()
{
    int num = 3

    // Using a for loop to print squares of numbers from 1 to 'num'
    
	;printf("Squares of numbers from 1 to %d:\n", num);
    for (int i = 1; i <= num; i++) {
        printf("%d ", i * i);
    }
    printf("\n");

    // Using a while loop to calculate and print the sum of numbers from 1 to 'num'
    int sum = 0;
    int j = 1;
    while (j <= num) {
        sum += j;
        j++;
    }
    printf("Sum of numbers from 1 to %d: %d\n", num, sum);

    return 0;
}
