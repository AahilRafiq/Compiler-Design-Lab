// table.h

#ifndef TABLE_H
#define TABLE_H

// Structure definitions
struct ConstantTable {
    char constant_name[100];
    char constant_type[100];
    int exist;
};

struct SymbolTable {
    char symbol_name[100];
    char symbol_type[100];
    char array_dimensions[100];
    char class[100];
    char value[100];
    char parameters[100];
    int line_number;
    int exist;
};

// Function declarations
unsigned long hash(unsigned char *str);

int search_ConstantTable(char* str);
void insert_ConstantTable(char* name, char* type);
void printConstantTable();

int search_SymbolTable(char* str);
void insert_SymbolTable(char* name, char* class);
void insert_SymbolTable_type(char *str1, char *str2);
void insert_SymbolTable_value(char *str1, char *str2);
void insert_SymbolTable_arraydim(char *str1, char *dim);
void insert_SymbolTable_funcparam(char *str1, char *param);
void insert_SymbolTable_line(char *str1, int line);
void printSymbolTable();

#endif // TABLE_H
