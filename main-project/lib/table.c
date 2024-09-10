#include "table.h"
#include <stdio.h>
#include <string.h>

struct ConstantTable const_T[1000];
struct SymbolTable sym_T[1000];
extern int yylineno;
unsigned long hash(unsigned char *str);

int search_const_table(char *str) {
    unsigned long temp_val = hash((unsigned char *)str);
    int val = temp_val % 1000;

    if (const_T[val].exist == 0) {
        return 0;
    } else if (strcmp(const_T[val].constant_name, str) == 0) {
        return 1;
    } else {
        for (int i = val + 1; i != val; i = (i + 1) % 1000) {
            if (strcmp(const_T[i].constant_name, str) == 0) {
                return 1;
            }
        }
        return 0;
    }
}

void insert_const_table(char *name, char *type) {
    if (search_const_table(name)) {
        return;
    } else {
        unsigned long temp_val = hash((unsigned char *)name);
        int val = temp_val % 1000;

        if (const_T[val].exist == 0) {
            strcpy(const_T[val].constant_name, name);
            strcpy(const_T[val].constant_type, type);
            const_T[val].exist = 1;
            return;
        }

        for (int i = val + 1; i != val; i = (i + 1) % 1000) {
            if (const_T[i].exist == 0) {
                strcpy(const_T[i].constant_name, name);
                strcpy(const_T[i].constant_type, type);
                const_T[i].exist = 1;
                break;
            }
        }
    }
}

void printConstantTable() {
    printf("%-20s | %-20s\n", "CONSTANT", "TYPE");
    printf("%s\n", "----------------------------------------------");

    for (int i = 0; i < 1000; ++i) {
        if (const_T[i].exist == 0) {
            continue;
        }
        printf("%-20s | %-20s\n", const_T[i].constant_name, const_T[i].constant_type);
    }
}


int search_SymbolTable(char *str) {
    unsigned long temp_val = hash((unsigned char *)str);
    int val = temp_val % 1000;

    if (sym_T[val].exist == 0) {
        return 0;
    } else if (strcmp(sym_T[val].symbol_name, str) == 0) {
        sym_T[val].line_number[sym_T[val].last_line_index++] = yylineno;
        return 1;
    } else {
        for (int i = val + 1; i != val; i = (i + 1) % 1000) {
            if (strcmp(sym_T[i].symbol_name, str) == 0) {
                sym_T[i].line_number[sym_T[i].last_line_index++] = yylineno;
                return 1;
            }
        }
        return 0;
    }
}

void insert_symbol_table(char *name, char *class) {
    if (search_SymbolTable(name)) {
        return;
    } else {
        unsigned long temp_val = hash((unsigned char *)name);
        int val = temp_val % 1000;

        if (sym_T[val].exist == 0) {
            strcpy(sym_T[val].symbol_name, name);
            strcpy(sym_T[val].class, class);

            for(int i=0 ; i<100 ; i++) sym_T[val].line_number[i] = -1;

            sym_T[val].line_number[0] = yylineno; 
            sym_T[val].last_line_index = 1;

            sym_T[val].exist = 1;
            return;
        }

        for (int i = val + 1; i != val; i = (i + 1) % 1000) {
            if (sym_T[i].exist == 0) {
                strcpy(sym_T[i].symbol_name, name);
                strcpy(sym_T[i].class, class);

                for(int i=0 ; i<100 ; i++) sym_T[i].line_number[i] = -1;

                sym_T[i].line_number[0] = yylineno; 
                sym_T[i].last_line_index = 1;

                sym_T[i].exist = 1;
                break;
            }
        }
    }
}

void insert_symbol_table_type(char *str1, char *str2) {
    for (int i = 0; i < 1000; i++) {
        if (strcmp(sym_T[i].symbol_name, str1) == 0) {
            strcpy(sym_T[i].symbol_type, str2);
        }
    }
}

void insert_symbol_table_value(char *str1, char *str2) {
    for (int i = 0; i < 1000; i++) {
        if (strcmp(sym_T[i].symbol_name, str1) == 0) {
            strcpy(sym_T[i].value, str2);
        }
    }
}

unsigned long hash(unsigned char *str) {
    unsigned long hash = 5381;
    int c;
    while ((c = *str++)) {
        hash = ((hash << 5) + hash) + c; 
    }
    return hash;
}

void insert_symbol_table_arraydim(char *str1, char *dim) {
    for (int i = 0; i < 1000; i++) {
        if (strcmp(sym_T[i].symbol_name, str1) == 0) {
            strcpy(sym_T[i].array_dimensions, dim);
        }
    }
}

void insert_symbol_table_funcparam(char *str1, char *param) {
    for (int i = 0; i < 1000; i++) {
        if (strcmp(sym_T[i].symbol_name, str1) == 0) {
            strcat(sym_T[i].parameters, " ");
            strcat(sym_T[i].parameters, param);
        }
    }
}

void insert_symbol_table_line(char *str1, int line) {
    for (int i = 0; i < 1000; i++) {
        if (strcmp(sym_T[i].symbol_name, str1) == 0) {
            
            sym_T[i].line_number[sym_T[i].last_line_index] = line;
        }
    }
}



#include <stdio.h>

void printSeparator() {
    printf("+------------+--------------------+------------+------------+------------+------------+------------+\n");
}


void printSymbolTable() {
    printSeparator();
    printf("| %-10s | %-18s | %-10s | %-10s | %-10s | %-10s | %-10s |\n",
           "SYMBOL", "CLASS", "TYPE", "VALUE", "DIMENSIONS", "PARAMETERS", "LINE NO");
    printSeparator();

    for (int i = 0; i < 1000; ++i) {
        if (sym_T[i].symbol_name[0] == '\0') {
            continue;  // Skip empty entries
        }

        printf("| %-10s | %-18s | %-10s | %-10s | %-10s | %-10s | ",
               sym_T[i].symbol_name, sym_T[i].class, sym_T[i].symbol_type, sym_T[i].value,
               sym_T[i].array_dimensions, sym_T[i].parameters);

        // Print line numbers
        for (int j = 0; j < sym_T[i].last_line_index; j++) {
            printf("%d", sym_T[i].line_number[j]);
            if (j < sym_T[i].last_line_index - 1) {
                printf(",");
            }
        }
        printf(" |\n");
    }
    printSeparator();
}

