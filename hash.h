/********************************************/
/* Funciones que implementan una tabla hash */
/********************************************/
#ifndef HASH_H
#define HASH_H
 
#define _XOPEN_SOURCE 500 /* Enable certain library functions (strdup) on linux. See feature_test_macros(7) */
#define OK 0
#define ERR -1

typedef int bool;
#define true 1
#define false 0
  
#include <stdlib.h>
#include <stdio.h>
#include <limits.h>
#include <string.h>
#include "tipos.h"

struct entry_s {
    char *key;
    struct hash_datos_ts *datos;
    struct entry_s *next;
};
  
typedef struct entry_s entry_t;

struct hash_datos_ts {
    char *key;
    int categoria;
    int tipoDato;
    int clase;
    int tamanoVector;
    int numParam;
    int numVarL;
    int posDe;
};
  
typedef struct hash_datos_ts datos_ts;
  
struct hashtable_s {
    int size;
    struct entry_s **table;
};
  
typedef struct hashtable_s hashtable_t;
  
/*Crea la tabla hash*/
hashtable_t *ht_create(int size);

/*Funciones auxiliares*/
int ht_hash(hashtable_t *hashtable, char *key);
entry_t *ht_newpair(char *key, int categoria, int tipoDato, int clase, int tamanoVector, int numParam, int numVarL, int posDe);

/*Introudce nuevo dato en la tabla*/
int ht_set(hashtable_t *hashtable, char *key, int categoria, int tipoDato, int clase, int tamanoVector, int numParam, int numVarL, int posDe);

/*Conseguir el dato de la tabla*/
datos_ts *ht_get(hashtable_t *hashtable, char *key);

/*Destruye la tabla hash*/
void ht_destroy(hashtable_t *t);

#endif  /* HASH_H */
