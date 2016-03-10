/*------------------------------------ 
  -   alfa.c                         -
  -   Author: Manuel Reyes Sanchez   -
  -   EPS-UAM                        -
  ------------------------------------*/
 
#include <stdio.h>
#include <stdlib.h>
#include "tipos.h"
#include "tabla_simbolos.h"

ambitos_t *ts;

int main(int argc, char *argv[]){
     
    extern FILE* yyin;
    extern FILE* yyout;
    extern FILE* resultado;
    ts = iniciarTablaSimbolos();
 
    if(argc != 3){
        printf("El numero de argumentos de entrada es incorrecto");
        return ERR;
    }
    yyin=fopen(argv[1],"r");
    yyout=fopen("debug.txt","w");
    resultado=fopen(argv[2],"w");
    
    if(yyin==NULL){
        printf("Error abriendo el fichero de entrada\n"); 
        return ERR;
    }  
    if(yyout==NULL) printf("Error abriendo el fichero de debug\n"); 
    if(resultado==NULL){
        printf("Error abriendo el fichero de salida\n"); 
        return ERR;
    }
 
    yyparse();
     
    fclose(yyin);
    fclose(yyout);
    fclose(resultado);  
    cerrarTablaSimbolos(ts);
    return OK;     
}
