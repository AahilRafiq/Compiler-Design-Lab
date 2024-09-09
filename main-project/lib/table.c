// table.c

#include "table.h"
#include <stdio.h>
#include <string.h>

// Define the tables
struct ConstantTable CT[1000];
struct SymbolTable ST[1000];

// Hash function to generate hash values for the strings
unsigned long hash(unsigned char *str) {
    unsigned long hash = 5381;
    int c;
    while ((c = *str++)) {
        hash = ((hash << 5) + hash) + c; // hash * 33 + c
    }
    return hash;
}

// Search in the Constant Table
int search_ConstantTable(char *str) {
    unsigned long temp_val = hash((unsigned char *)str);
    int val = temp_val % 1000;

    if (CT[val].exist == 0) {
        return 0;
    } else if (strcmp(CT[val].constant_name, str) == 0) {
        return 1;
    } else {
        for (int i = val + 1; i != val; i = (i + 1) % 1000) {
            if (strcmp(CT[i].constant_name, str) == 0) {
                return 1;
            }
        }
        return 0;
    }
}

// Insert into the Constant Table
void insert_ConstantTable(char *name, char *type) {
    if (search_ConstantTable(name)) {
        return;
    } else {
        unsigned long temp_val = hash((unsigned char *)name);
        int val = temp_val % 1000;

        if (CT[val].exist == 0) {
            strcpy(CT[val].constant_name, name);
            strcpy(CT[val].constant_type, type);
            CT[val].exist = 1;
            return;
        }

        for (int i = val + 1; i != val; i = (i + 1) % 1000) {
            if (CT[i].exist == 0) {
                strcpy(CT[i].constant_name, name);
                strcpy(CT[i].constant_type, type);
                CT[i].exist = 1;
                break;
            }
        }
    }
}

// Print the Constant Table
void printConstantTable() {
    printf("%20s | %20s\n", "CONSTANT", "TYPE");
    for (int i = 0; i < 1000; ++i) {
        if (CT[i].exist == 0)
            continue;

        printf("%20s | %20s\n", CT[i].constant_name, CT[i].constant_type);
    }
}

// Search in the Symbol Table
int search_SymbolTable(char *str) {
    unsigned long temp_val = hash((unsigned char *)str);
    int val = temp_val % 1000;

    if (ST[val].exist == 0) {
        return 0;
    } else if (strcmp(ST[val].symbol_name, str) == 0) {
        return 1;
    } else {
        for (int i = val + 1; i != val; i = (i + 1) % 1000) {
            if (strcmp(ST[i].symbol_name, str) == 0) {
                return 1;
            }
        }
        return 0;
    }
}

// Insert into the Symbol Table
void insert_SymbolTable(char *name, char *class) {
    if (search_SymbolTable(name)) {
        return;
    } else {
        unsigned long temp_val = hash((unsigned char *)name);
        int val = temp_val % 1000;

        if (ST[val].exist == 0) {
            strcpy(ST[val].symbol_name, name);
            strcpy(ST[val].class, class);
            ST[val].line_number = 0; // Modify as needed
            ST[val].exist = 1;
            return;
        }

        for (int i = val + 1; i != val; i = (i + 1) % 1000) {
            if (ST[i].exist == 0) {
                strcpy(ST[i].symbol_name, name);
                strcpy(ST[i].class, class);
                ST[i].exist = 1;
                break;
            }
        }
    }
}

// Update Symbol Table entries
void insert_SymbolTable_type(char *str1, char *str2) {
    for (int i = 0; i < 1000; i++) {
        if (strcmp(ST[i].symbol_name, str1) == 0) {
            strcpy(ST[i].symbol_type, str2);
        }
    }
}

void insert_SymbolTable_value(char *str1, char *str2) {
    for (int i = 0; i < 1000; i++) {
        if (strcmp(ST[i].symbol_name, str1) == 0) {
            strcpy(ST[i].value, str2);
        }
    }
}

void insert_SymbolTable_arraydim(char *str1, char *dim) {
    for (int i = 0; i < 1000; i++) {
        if (strcmp(ST[i].symbol_name, str1) == 0) {
            strcpy(ST[i].array_dimensions, dim);
        }
    }
}

void insert_SymbolTable_funcparam(char *str1, char *param) {
    for (int i = 0; i < 1000; i++) {
        if (strcmp(ST[i].symbol_name, str1) == 0) {
            strcat(ST[i].parameters, " ");
            strcat(ST[i].parameters, param);
        }
    }
}

void insert_SymbolTable_line(char *str1, int line) {
    for (int i = 0; i < 1000; i++) {
        if (strcmp(ST[i].symbol_name, str1) == 0) {
            ST[i].line_number = line;
        }
    }
}

// Print the Symbol Table
void printSymbolTable() {
    printf("%10s | %18s | %10s | %10s | %10s | %10s | %10s\n",
           "SYMBOL", "CLASS", "TYPE", "VALUE", "DIMENSIONS", "PARAMETERS", "LINE NO");
    for (int i = 0; i < 1000; ++i) {
        if (ST[i].exist == 0)
            continue;
        printf("%10s | %18s | %10s | %10s | %10s | %10s | %d\n",
               ST[i].symbol_name, ST[i].class, ST[i].symbol_type, ST[i].value,
               ST[i].array_dimensions, ST[i].parameters, ST[i].line_number);
    }
}
