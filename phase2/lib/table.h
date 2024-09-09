#ifndef TABLE_H
#define TABLE_H
#define MAX_TABLE_SIZE 1000000

struct table_entry {
    char *name;
    char *class;
    char *type;
    int scope_level;
    int line_no;
    int dimension;
} typedef table_entry;

int hashfn(char *name);

struct hash_table {
    table_entry* table[MAX_TABLE_SIZE];
} typedef hash_table;

hash_table *init_table();

void insert_entry(hash_table *ht , table_entry entry);

table_entry *get_entry(hash_table *ht, char *name);

void print_table(hash_table *ht);

#endif