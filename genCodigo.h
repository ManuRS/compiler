/*------------------------------------ 
  -   genCodigo.h                    -
  -   Author: Manuel Reyes Sanchez   -
  -   EPS-UAM                        -
  ------------------------------------*/

#ifndef GENCODIGO_H
#define GENCODIGO_H

void gc_ets ();

void gc_fin();

/////////////////////////////////////////////////////////////////////////////////////////////////////////

void gc_suma_enteros(int es_direccion_op1, int es_direccion_op2);

void gc_resta_enteros(int es_direccion_op1, int es_direccion_op2);

void gc_dividir_enteros(int es_direccion_op1, int es_direccion_op2);

void gc_multiplicar_enteros(int es_direccion_op1, int es_direccion_op2);

void gc_negativo_enteros(int es_direccion_op1);

/////////////////////////////////////////////////////////////////////////////////////////

void gc_and_bool (int es_direccion_op1, int es_direccion_op2);

void gc_or_bool (int es_direccion_op1, int es_direccion_op2);

void gc_not_bool (int es_direccion_op1);

////////////////////////////////////////////////////////////////////////////////////////////////////

void gc_igual_cmp (int es_direccion_op1, int es_direccion_op2);

void gc_distinto_cmp (int es_direccion_op1, int es_direccion_op2);

void gc_menorigual_cmp (int es_direccion_op1, int es_direccion_op2);

void gc_mayorigual_cmp (int es_direccion_op1, int es_direccion_op2);

void gc_menor_cmp (int es_direccion_op1, int es_direccion_op2);

void gc_mayor_cmp (int es_direccion_op1, int es_direccion_op2);

/////////////////////////////////////////////////////////////////////////////////

void gc_index_vector(int es_direccion_op1, int en_explist, char *key, int tam);

void gc_asig_identificador(int es_direccion_op1, char *key);

void gc_asig_identificador2(int es_direccion_op1, char *key);

void gc_asig_elementovector(int es_direccion_op1);

/////////////////////////////////////////////////////////////////////////////////

void gc_lectura(int tipo, char *texto);

void gc_escritura(int es_direccion_op1, int tipo);

void gc_llamada_funcion(char *texto, int n);

void gc_cuerpo_cabecera_funcion(char * texto, int n);

void gc_cuerpo_acaba_funcion(int es_direccion_op1);

void gc_main ();

#endif 
