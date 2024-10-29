#ifndef ICG_H
#define ICG_H

#include <stdio.h>
#include <string.h>
#define MAX 1000

struct icg
{
	char instr[100];
}icg[MAX];

int icg_index = 0;

void insert_icg(char *instr)
{
    strcpy(icg[icg_index].instr, instr);
    icg_index++;
}

void print_icg()
{
    printf("\nIntermediate Code Generated:\n");
    for(int i=0; i<icg_index; i++)
    {
        printf("%s\n", icg[i].instr);
    }
}



#endif // SUM_H
