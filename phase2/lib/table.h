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
    int line_number[100];
    int last_line_index;
    int exist;
};

// Function declarations
unsigned long hash(unsigned char *str);

int search_const_table(char* str);
void insert_const_table(char* name, char* type);
void printConstantTable();

int search_SymbolTable(char* str);
void insert_symbol_table(char* name, char* class);
void insert_symbol_table_type(char *str1, char *str2);
void insert_symbol_table_value(char *str1, char *str2);
void insert_symbol_table_arraydim(char *str1, char *dim);
void insert_symbol_table_funcparam(char *str1, char *param);
void insert_symbol_table_line(char *str1, int line);
void printSymbolTable();

#endif // TABLE_H
