/*------------------------------------ 
  -   tabla_simbolos.h               -
  -   Author: Manuel Reyes Sanchez   -
  -   EPS-UAM                        -
  ------------------------------------*/

#ifndef TABLA_SIMBOLOS_H
#define	TABLA_SIMBOLOS_H

#include "hash.h"
#include "tipos.h"

struct ambitos_s {
    hashtable_t *global;
    hashtable_t *local;
};

typedef struct ambitos_s ambitos_t;

/*Realizar para empezar o resetearlas*/
ambitos_t *iniciarTablaSimbolos();

/*Realizar al terminar de usar*/
void cerrarTablaSimbolos(ambitos_t *ambitos);

/*Consultar ambito*/
/*2 local, 1 global, 0 ninguno*/
int ambitoActual(ambitos_t *ambitos);

/*Crea ambito*/
bool abrirAmbito(ambitos_t *ambitos, char *key, int categoria, int tipoDato, int clase, int tamanoVector, int numParam, int numVarL, int posDe);

/*Cierra ambito*/
/*0 si no cierras nada, 1 si cierras local, 2 si cierras global*/
int cerrarAmbito(ambitos_t *ambitos);

/*Inserta el elemento*/
/*0 si no inserta, 1 si inserta en local, 2 si inserta en global*/
int insertarElem (ambitos_t *ambitos, char *key, int categoria, int tipoDato, int clase, int tamanoVector, int numParam, int numVarL, int posDe);

/*Busca un elemento, devolviendo el contenido*/
datos_ts *buscarElem (ambitos_t *ambitos, char *key);

/*Indica donde esta el elemento*/
/*local 1, global 0*/
int ambitoElem(ambitos_t *ambitos, char *key);

/*Indica si esta presente un elemento*/
bool existeElem (ambitos_t *ambitos, char *key);

/*Datos de la tabla global*/
hashtable_t * getGlobal(ambitos_t *ambitos);

/*Datos de la tabla local*/
hashtable_t * getLocal(ambitos_t *ambitos);

#endif	/* TABLA_SIMBOLOS_H */
