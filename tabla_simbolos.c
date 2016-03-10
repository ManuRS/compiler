/*------------------------------------ 
  -   tabla_simbolos.c               -
  -   Author: Manuel Reyes Sanchez   -
  -   EPS-UAM                        -
  ------------------------------------*/

#include "tabla_simbolos.h"

ambitos_t *iniciarTablaSimbolos() {
    ambitos_t *ambitos = NULL;

    /* Allocate the table itself. */
    if ((ambitos = malloc(sizeof ( ambitos_t))) == NULL) {
        cerrarTablaSimbolos(ambitos);
        return NULL;
    }

    /* Allocate pointers to the head nodes. */
    if ((ambitos->global = malloc(sizeof ( hashtable_t *))) == NULL) {
        cerrarTablaSimbolos(ambitos);
        return NULL;
    }

    ambitos->global = ht_create(1000);
    if(ambitos->global == NULL){
        cerrarTablaSimbolos(ambitos);
        return NULL;
    }
    ambitos->local = NULL;

    return ambitos;
}

void cerrarTablaSimbolos(ambitos_t *ambitos) {
    if (ambitos->local != NULL){
        ht_destroy(ambitos->local);
        ambitos->local=NULL;
    }
    if (ambitos->global != NULL){
        ht_destroy(ambitos->global);
        ambitos->global=NULL;
    }
    free (ambitos);
}

int ambitoActual(ambitos_t *ambitos){
    if (ambitos->local != NULL){
        return 2;
    }
    if (ambitos->global != NULL){
       return 1;
    }
    return 0;
}

bool abrirAmbito(ambitos_t *ambitos, char *key, int categoria, int tipoDato, int clase, int tamanoVector, int numParam, int numVarL, int posDe) {

    if (ambitos->local == NULL) {

        if (existeElem(ambitos, key) == true)
            return false; /*El elemento ya esta en la tabla global*/

        /*Insertamos elem en la global*/
        if (insertarElem(ambitos, key, categoria, tipoDato, clase, tamanoVector, numParam, numVarL, posDe) == false)
            return false;

        /*Creamos local*/
        ambitos->local = ht_create(1000);

        /*Insertamos elem en la local*/
        if (insertarElem(ambitos, key, categoria, tipoDato, clase, tamanoVector, numParam, numVarL, posDe) == false)
            return false;

        return true;
    }
    return false; /*Ya existe un ambito local*/

}

/*0 si no cierras nada, 1 si cierras local, 2 si cierras global*/
int cerrarAmbito(ambitos_t *ambitos) {

    if (ambitos->local != NULL) {
        /*Destruyo ambito local*/
        ht_destroy(ambitos->local);
        ambitos->local=NULL;
        return 2;
    }

    if (ambitos->global != NULL) {
        /*Destruyo ambito global*/
        ht_destroy(ambitos->global);
        ambitos->global=NULL;
        return 1;
    }

    return 0;
}

/*De esta funcion cambiara lo que se envia*/
int insertarElem (ambitos_t *ambitos, char *key, int categoria, int tipoDato, int clase, int tamanoVector, int numParam, int numVarL, int posDe) {

    if (ambitos->local != NULL) {
        /*Insertamos en el local*/
        if (ht_set(ambitos->local, key, categoria, tipoDato, clase, tamanoVector, numParam, numVarL, posDe) == ERR)
            return 0;
        //printf("Insercion en local\n");
        return 1;
    }
    else if (ambitos->global != NULL) {
        /*Insertamos en el global*/
        if (ht_set(ambitos->global, key, categoria, tipoDato, clase, tamanoVector, numParam, numVarL, posDe) == ERR)
            return 0;
        //printf("Insercion en global\n");
        return 2;
    }
    else return 0; /*No hay ambitos*/

}

/*De esta funcion cambiara lo que devuelve, sus cambios se propagan*/
datos_ts *buscarElem (ambitos_t *ambitos, char *key) {
    datos_ts *elem;

    if (ambitos->local != NULL) {
        /*Buscamos en el local*/
        elem = ht_get(ambitos->local, key);
        if (elem != NULL)
            return elem;
    }

    if (ambitos->global != NULL) {
        /*Buscamos en el global*/
        elem = ht_get(ambitos->global, key);
        if (elem != NULL)
            return elem;
    }
    
    else{
        printf("No busque en ninguna\n");
        return NULL; /*No hay ambitos*/
    }
  
}

int ambitoElem(ambitos_t *ambitos, char *key){
    datos_ts *elem;

    if (ambitos->local != NULL) {
        /*Buscamos en el local*/
        elem = ht_get(ambitos->local, key);
        if (elem != NULL)
            return 1;
    }

    if (ambitos->global != NULL) {
        /*Buscamos en el global*/
        elem = ht_get(ambitos->global, key);
        if (elem != NULL)
            return 0;
    }
    
    else{
        printf("No busque en ninguna\n");
        return -1; /*No hay ambitos*/
    }
  
}

bool existeElem(ambitos_t *ambitos, char *key) {
    datos_ts *elem;
    elem = buscarElem(ambitos, key);
    if(elem != NULL){  
        return true;
    }

    return false; /*No hay ambitos*/
}

hashtable_t * getGlobal(ambitos_t *ambitos){
    return ambitos->global;
}

hashtable_t * getLocal(ambitos_t *ambitos){
    return ambitos->local;
}
