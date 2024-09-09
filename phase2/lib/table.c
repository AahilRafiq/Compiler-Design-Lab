#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>
#define MAX_TABLE_SIZE 1000000
#define MAX_NAME_LENGTH 100
#define MAX_TYPE_LENGTH 100

struct table_entry
{
    char *name;
    char *class;
    char *type;
    int line_no;
    int scope_level;
    int dimension;
} typedef table_entry;

int hashfn(char *name)
{
    int hash = 0;
    for (int i = 0; name[i] != '\0'; i++)
    {
        hash += name[i];
    }
    return hash % MAX_TABLE_SIZE; 
}

struct hash_table
{
    table_entry **table;
} typedef hash_table;

hash_table *init_table()
{
    hash_table *table = (hash_table *)malloc(sizeof(hash_table));
    if (!table) return NULL;  
    table->table = (table_entry **)malloc(MAX_TABLE_SIZE * sizeof(table_entry*));
    if (!table->table) {  
        free(table);
        return NULL;
    }
    for (int i = 0; i < MAX_TABLE_SIZE; i++)
    {
        table->table[i] = NULL;
    }
    return table;
}

void insert_entry(hash_table *ht, table_entry entry)
{
    int hash = hashfn(entry.name);

    // WARNING : this assumes that table never fills
    while (ht->table[hash] != NULL)
        hash = (hash + 1) % MAX_TABLE_SIZE;

    table_entry *e = (table_entry *)malloc(sizeof(table_entry));
    if (!e) return;
    *e = entry;
    e->name = strdup(entry.name);
    e->type = strdup(entry.type); 
    e->class = strdup(entry.class);
    ht->table[hash] = e;
}

table_entry *get_entry(hash_table *ht, char *name)
{
    int hash = hashfn(name);
    int original_hash = hash; 

    do {
        if (ht->table[hash] == NULL) return NULL;  
        if (strcmp(ht->table[hash]->name, name) == 0)
            return ht->table[hash];
        hash = (hash + 1) % MAX_TABLE_SIZE;
    } while (hash != original_hash);  

    return NULL;  
}

void free_table(hash_table *ht)
{
    for (int i = 0; i < MAX_TABLE_SIZE; i++) {
        if (ht->table[i]) {
            free(ht->table[i]->name);
            free(ht->table[i]->type);
            free(ht->table[i]);
        }
    }
    free(ht->table);
    free(ht);
}

void print_table(hash_table *ht)
{
    printf("--------------------------------------------------------------------------------------------------------------\n");
    printf("| %-10s | %-20s | %-20s | %-20s | %-10s | %-10s | %-10s |\n", "No.", "Name", "Class", "Type", "Scope Level", "Line Number", "Dimension");
    printf("--------------------------------------------------------------------------------------------------------------\n");

    int count = 0;
    int entry_no = 1; // Entry numbering starts from 1

    for (int i = 0; i < MAX_TABLE_SIZE; i++)
    {
        if (ht->table[i] != NULL)
        {
            printf("| %-10d | %-20s | %-20s | %-20s | %-10d | %-10d | %-10d |\n", 
                    entry_no, 
                    ht->table[i]->name, 
                    ht->table[i]->class,    // New 'class' field
                    ht->table[i]->type, 
                    ht->table[i]->scope_level, 
                    ht->table[i]->line_no, 
                    ht->table[i]->dimension);
            printf("--------------------------------------------------------------------------------------------------------------\n");
            entry_no++; // Increment for next entry
            count++;
        }
    }
    printf("Total entries: %d\n", count);
}

