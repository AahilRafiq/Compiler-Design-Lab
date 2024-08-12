#ifndef HASHTABLE_H
#define HASHTABLE_H

#include <stdbool.h>

#define TABLE_SIZE 100

typedef struct HashItem HashItem;
typedef struct HashTable HashTable;

HashTable* create_table();
void insertItem(HashTable* table, const char* key, void* value);
void* getItem(HashTable* table, const char* key);
void remove_item(HashTable* table, const char* key);
void free_table(HashTable* table);

#endif // HASHTABLE_H