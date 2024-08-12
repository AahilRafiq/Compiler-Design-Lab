%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>

int yylineno;

#define TABLE_SIZE 10000

// Move struct definitions to the top
struct Token {
    char *name;
    char *type;
    int lineno;
};

struct HashItem {
    char* key;
    struct Token* value;
    bool is_occupied;
};

struct HashTable {
    struct HashItem* items;
    int size;
};

typedef struct HashTable HashTable;

// Function prototypes
HashTable* create_table();
void insert(HashTable* table, const char* key, struct Token* value);
void* get(HashTable* table, const char* key);
void remove_item(HashTable* table, const char* key);
void free_table(HashTable* table);
void print_hashtable(HashTable* table);

// Global variable declaration (without initialization)
HashTable* hashtable;

%}

/* Definitions */
DIGIT       [0-9]
LETTER      [a-zA-Z_]
ID          {LETTER}({LETTER}|{DIGIT})*
INTEGER     {DIGIT}+
FLOAT       {DIGIT}+"."{DIGIT}+([Ee][+-]?{DIGIT}+)?
CHAR        '(\\.|[^\\'])'
STRING      \"(\\.|[^\\"\n])*\"
COMMENT     "//".*
MCOMMENT    "/*"([^*]|"*"+[^*/])*"*"+"/"
%%

    /******** KEYWORDS ******/
"auto"|"break"|"case"|"char"|"const"|"continue"|"default"|"do"|"double"|"else"|"enum"|"extern"|"float"|"for"|"goto"|"if"|"int"|"long"|"register"|"return"|"short"|"signed"|"sizeof"|"static"|"struct"|"switch"|"typedef"|"union"|"unsigned"|"void"|"volatile"|"while" {
    printf("KEYWORD: %s at line : %d\n", yytext, yylineno);
    struct Token* token = (struct Token*)malloc(sizeof(struct Token));
    token->name = strdup(yytext);
    token->type = "KEYWORD";
    token->lineno = yylineno;
    insert(hashtable, yytext, token);
    yylineno++;
}

{ID}        { 
    printf("IDENTIFIER: %s at line : %d\n", yytext, yylineno);
    struct Token* token = (struct Token*)malloc(sizeof(struct Token));
    token->name = strdup(yytext);
    token->type = "IDENTIFIER";
    token->lineno = yylineno;
    insert(hashtable, yytext, token);
    yylineno++;
}

{INTEGER}   { 
    printf("INTEGER: %s at line : %d\n", yytext, yylineno);
    struct Token* token = (struct Token*)malloc(sizeof(struct Token));
    token->name = strdup(yytext);
    token->type = "INTEGER";
    token->lineno = yylineno;
    insert(hashtable, yytext, token);
    yylineno++;
}

{FLOAT}     { 
    printf("FLOAT: %s at line : %d\n", yytext, yylineno);
    struct Token* token = (struct Token*)malloc(sizeof(struct Token));
    token->name = strdup(yytext);
    token->type = "FLOAT";
    token->lineno = yylineno;
    insert(hashtable, yytext, token);
    yylineno++;
}

{CHAR}      { 
    printf("CHAR: %s at line : %d\n", yytext, yylineno);
    struct Token* token = (struct Token*)malloc(sizeof(struct Token));
    token->name = strdup(yytext);
    token->type = "CHAR";
    token->lineno = yylineno;
    insert(hashtable, yytext, token);
    yylineno++;
}

{STRING}    { 
    printf("STRING: %s at line : %d\n", yytext, yylineno);
    struct Token* token = (struct Token*)malloc(sizeof(struct Token));
    token->name = strdup(yytext);
    token->type = "STRING";
    token->lineno = yylineno;
    insert(hashtable, yytext, token);
    yylineno++;
}

    /******** OPERATORS ******/
"+"|"-"|"*"|"/"|"%"|"++"|"--"|"=="|"!="|">"|"<"|">="|"<="|"&&"|"||"|"!"|"&"|"|"|"^"|"~"|"<<"|">>" {
    printf("OPERATOR: %s at line : %d\n", yytext, yylineno);
    struct Token* token = (struct Token*)malloc(sizeof(struct Token));
    token->name = strdup(yytext);
    token->type = "OPERATOR";
    token->lineno = yylineno;
    insert(hashtable, yytext, token);
    yylineno++;
}

    /******** ASSIGNMENT ******/
"="|"+="|"-="|"*="|"/="|"%="|"<<="|">>="|"&="|"^="|"|=" {
    printf("ASSIGNMENT: %s at line : %d\n", yytext, yylineno);
    struct Token* token = (struct Token*)malloc(sizeof(struct Token));
    token->name = strdup(yytext);
    token->type = "ASSIGNMENT";
    token->lineno = yylineno;
    insert(hashtable, yytext, token);
    yylineno++;
}

    /******** PUNCTUATORS ******/
"("|")"|"{"|"}"|"["|"]"|";"|","|"."|"->" {
    printf("PUNCTUATOR: %s at line : %d\n", yytext, yylineno);
    struct Token* token = (struct Token*)malloc(sizeof(struct Token));
    token->name = strdup(yytext);
    token->type = "PUNCTUATOR";
    token->lineno = yylineno;
    insert(hashtable, yytext, token);
    yylineno++;
}

    /******* COMMENTS *******/ 
{COMMENT}   { printf("COMMENT at line : %d\n", yylineno++); }
{MCOMMENT}  { printf("MULTILINE COMMENT at line : %d\n", yylineno++); }

[ \t\v\n\f] ;
. ;

%%

int yywrap() {
    return 1;
}

// Hash table implementation

unsigned int hash(const char* key) {
    unsigned int hash = 0;
    for (int i = 0; key[i] != '\0'; i++) {
        hash = 31 * hash + key[i];
    }
    return hash % TABLE_SIZE;
}

HashTable* create_table() {
    HashTable* table = (HashTable*)malloc(sizeof(HashTable));
    table->size = TABLE_SIZE;
    table->items = (struct HashItem*)calloc(TABLE_SIZE, sizeof(struct HashItem));
    return table;
}

void insert(HashTable* table, const char* key, struct Token* value) {
    unsigned int index = hash(key);
    
    while (table->items[index].is_occupied) {
        if (strcmp(table->items[index].key, key) == 0) {
            free(table->items[index].value->name);
            free(table->items[index].value);
            table->items[index].value = value;
            return;
        }
        index = (index + 1) % TABLE_SIZE;
    }
    
    table->items[index].key = strdup(key);
    table->items[index].value = value;
    table->items[index].is_occupied = true;
}

void* get(HashTable* table, const char* key) {
    unsigned int index = hash(key);
    
    while (table->items[index].is_occupied) {
        if (strcmp(table->items[index].key, key) == 0) {
            return table->items[index].value;
        }
        index = (index + 1) % TABLE_SIZE;
    }
    
    return NULL;
}

void remove_item(HashTable* table, const char* key) {
    unsigned int index = hash(key);
    
    while (table->items[index].is_occupied) {
        if (strcmp(table->items[index].key, key) == 0) {
            free(table->items[index].key);
            free(table->items[index].value->name);
            free(table->items[index].value);
            table->items[index].key = NULL;
            table->items[index].value = NULL;
            table->items[index].is_occupied = false;
            return;
        }
        index = (index + 1) % TABLE_SIZE;
    }
}

void free_table(HashTable* table) {
    for (int i = 0; i < TABLE_SIZE; i++) {
        if (table->items[i].is_occupied) {
            free(table->items[i].key);
            free(table->items[i].value->name);
            free(table->items[i].value);
        }
    }
    free(table->items);
    free(table);
}

void print_hashtable(HashTable* table) {
    const char* types[] = {"IDENTIFIER", "INTEGER", "FLOAT", "CHAR", "STRING", "KEYWORD", "OPERATOR", "ASSIGNMENT", "PUNCTUATOR"};
    int num_types = sizeof(types) / sizeof(types[0]);

    for (int t = 0; t < num_types; t++) {
        printf("\n--- %s ---\n", types[t]);
        for (int i = 0; i < TABLE_SIZE; i++) {
            if (table->items[i].is_occupied && strcmp(table->items[i].value->type, types[t]) == 0) {
                printf("%s (line %d)\n", table->items[i].value->name, table->items[i].value->lineno);
            }
        }
    }
}

int main() {
    hashtable = create_table();
    yyin = fopen("source.c", "r");
    yylex();
    fclose(yyin);

    print_hashtable(hashtable);
    free_table(hashtable);
    return 0;
}