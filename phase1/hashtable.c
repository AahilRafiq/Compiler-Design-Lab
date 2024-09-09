#include "hashtable.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#define TABLE_SIZE 50000

typedef struct {
    char* key;
    void* value;
    bool is_occupied;
} HashItem;

typedef struct {
    HashItem* items;
    int size;
} HashTable;

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
    table->items = (HashItem*)calloc(TABLE_SIZE, sizeof(HashItem));
    return table;
}

void insertItem(HashTable* table, const char* key, void* value) {
    unsigned int index = hash(key);
    
    while (table->items[index].is_occupied) {
        if (strcmp(table->items[index].key, key) == 0) {
            table->items[index].value = value;
            return;
        }
        index = (index + 1) % TABLE_SIZE;
    }
    
    table->items[index].key = strdup(key);
    table->items[index].value = value;
    table->items[index].is_occupied = true;
}

void* getItem(HashTable* table, const char* key) {
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
        }
    }
    free(table->items);
    free(table);
}