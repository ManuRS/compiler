/*------------------------------------ 
  -   alfa.y                         -
  -   Author: Manuel Reyes Sanchez   -
  -   EPS-UAM                        -
  ------------------------------------*/

/*SECCION DE DEFINICIONES*/
%{
#include<stdio.h>
#include "tipos.h"
#include "tabla_simbolos.h"
#include "genCodigo.h"
extern FILE * yyout;
extern FILE * resultado;
extern int err, fila, columna, yyleng;
extern ambitos_t *ts;
extern int etiqueta;
void yyeror(char *s);
int yylex();
int tipo_actual, clase_actual, tamanio_vector_actual=0;
int num_parametros_actual=0, en_explist=0;
int num_variables_locales_actual=0, pos_variable_local_actual=1, pos_parametro_actual=0;
int flag_return = 0, tipo_funcion;
int error_clase_vector = 0;
int num_parametros_llamada_actual = 0;
int debug = 1;
%}
%code requires {
    typedef struct  {
        char lexema[MAX_LONG_ID+1];         /* guarda el lexema de los identificadores */
        int tipo;                           /* (TIPO_ENTERO, TIPO_LOGICO) guarda el tipo de una expresión */
        int valor_entero;                   /* guarda el valor de una constante entera */
        int es_direccion;                   /* (true, false) indica si un símbolo representa una dirección de memoria o es un valor constante */
        int etiqueta;                       /* para gestión de sentencias condicionales e iterativas, usdo en generacion de codigo*/
    }tipo_atributos;
}
%union{
    tipo_atributos atributos;
}

/*Palabras reservadas*/
%token TOK_MAIN
%token TOK_INT
%token TOK_BOOLEAN
%token TOK_ARRAY
%token TOK_FUNCTION
%token TOK_IF
%token TOK_ELSE
%token TOK_WHILE
%token TOK_SCANF
%token TOK_PRINTF
%token TOK_RETURN

/*Símbolos*/
%token TOK_PUNTOYCOMA
%token TOK_COMA
%token TOK_PARENTESISIZQUIERDO
%token TOK_PARENTESISDERECHO
%token TOK_CORCHETEIZQUIERDO
%token TOK_CORCHETEDERECHO
%token TOK_LLAVEIZQUIERDA
%token TOK_LLAVEDERECHA
%token TOK_ASIGNACION
%token TOK_ASIGNACIONMAS
%token TOK_MAS
%token TOK_MENOS
%token TOK_DIVISION
%token TOK_ASTERISCO
%token TOK_AND
%token TOK_OR
%token TOK_NOT
%token TOK_IGUAL
%token TOK_DISTINTO
%token TOK_MENORIGUAL
%token TOK_MAYORIGUAL
%token TOK_MENOR
%token TOK_MAYOR

/*Identificadores*/
%token <atributos> TOK_IDENTIFICADOR

/*Constantes*/
%token <atributos> TOK_CONSTANTE_ENTERA
%token TOK_TRUE
%token TOK_FALSE

/*Error*/
%token TOK_ERROR

/*Resolver conflictos*/
%left TOK_MAS TOK_MENOS TOK_OR
%left TOK_ASTERISCO TOK_DIVISION TOK_AND
%right MENOSU TOK_NOT

/*No terminales con atributos semanticos*/
%type <atributos> identificador
%type <atributos> exp
%type <atributos> comparacion
%type <atributos> idpf
%type <atributos> fn_name
%type <atributos> constante
%type <atributos> clase_vector
%type <atributos> fn_declaration
%type <atributos> elemento_vector
%type <atributos> idf_llamada_funcion
%type <atributos> if_exp
%type <atributos> if_exp_sentencias
%type <atributos> while
%type <atributos> while_exp
%type <atributos> condicional
%type <atributos> bucle

/*Axioma*/
%start programa

/*SECCION DE REGLAS*/
%%

programa: TOK_MAIN TOK_LLAVEIZQUIERDA declaraciones escritura_TS funciones escritura_main sentencias TOK_LLAVEDERECHA {
    fprintf(yyout,";R1:\t<programa> ::= main { <declaraciones> <funciones> <sentencias> }\n");
    gc_fin();
};

escritura_TS: {
    gc_ets();
};

escritura_main: {
    gc_main();
}

declaraciones: declaracion {fprintf(yyout,";R2:\t<declaraciones> ::= <declaracion>\n");};
|              declaracion declaraciones {fprintf(yyout,";R3:\t<declaraciones> ::= <declaracion> <declaraciones>\n");};

declaracion: clase identificadores TOK_PUNTOYCOMA { fprintf(yyout,";R4:\t<declaracion> ::= <clase> <identificadores> ;\n");
                                                    num_variables_locales_actual++;
                                                  };

clase: clase_escalar {fprintf(yyout,";R5:\t<clase> ::= <clase_escalar>\n");
                            if(debug==1) printf("Un escalar\n");
                            clase_actual = ESCALAR;
                      };
|      clase_vector {fprintf(yyout,";R7:\t<clase> ::= <clase_vector>\n");
                            if(debug==1) printf("Un vector\n");
                            clase_actual = VECTOR;
                     };

clase_escalar: tipo {fprintf(yyout,";R9:\t<clase_escalar> ::= <tipo>\n");
             tamanio_vector_actual = 1;
};

tipo: TOK_INT {fprintf(yyout,";R10:\t<tipo> ::= int\n");
                  tipo_actual = INT;
                  clase_actual = ESCALAR;
              };
|     TOK_BOOLEAN {fprintf(yyout,";R11:\t<tipo> ::= boolean\n");
                      tipo_actual = BOOLEAN;
                      clase_actual = ESCALAR;
                  };

clase_vector: TOK_ARRAY tipo TOK_CORCHETEIZQUIERDO TOK_CONSTANTE_ENTERA TOK_CORCHETEDERECHO 
  {  fprintf(yyout,";R15:\t<clase_vector> ::= array <tipo> [ <constante_entera> ]\n");  
     tamanio_vector_actual = $4.valor_entero;
     if ((tamanio_vector_actual < 1 ) || (tamanio_vector_actual > MAX_TAMANIO_VECTOR)) error_clase_vector = 1;
     if (getLocal(ts) != NULL){
            fprintf(stderr, "****Error semantico en lin %d: Variable local de tipo no escalar. \n", fila);
            return ERR;
     }
  };

identificadores: identificador {fprintf(yyout,";R18:\t<identificadores> ::= <identificador>\n");};
|                identificador TOK_COMA identificadores {fprintf(yyout,";R19:\t<identificadores> ::= <identificador> , <identificadores>\n");};

funciones: funcion funciones {fprintf(yyout,";R20:\t<funciones> ::= <funcion> <funciones>\n");};
|          {fprintf(yyout,";R21:\t<funciones> ::=\n");};

fn_name : TOK_FUNCTION tipo TOK_IDENTIFICADOR {

        if (existeElem(ts, $3.lexema)==TRUE){
            fprintf(stderr, "****Error semantico en lin %d: Declaracion duplicada. \n", fila);
            return ERR;                          
        } 
        
        if (abrirAmbito(ts, $3.lexema, FUNCION, tipo_actual, clase_actual, 0, 0, 0, 0) == FALSE){
            fprintf(yyout, "****Error de la ts al abrir ambito. \n");
            return ERR;                                                
        }
        
        num_variables_locales_actual = 0;
        pos_variable_local_actual = 1;
        num_parametros_actual = 0;
        pos_parametro_actual = 0;
        flag_return = 0;
        tipo_funcion = tipo_actual;
        strcpy($$.lexema, $3.lexema);
};

fn_declaration : fn_name TOK_PARENTESISIZQUIERDO parametros_funcion  TOK_PARENTESISDERECHO TOK_LLAVEIZQUIERDA declaraciones_funcion {
	    
	    hashtable_t *local = getLocal(ts);
	    datos_ts * datos = ht_get(local, $1.lexema);
	    hashtable_t *global = getGlobal(ts);
	    datos_ts * datos2 = ht_get(global, $1.lexema);

	    if (datos==NULL || datos2==NULL){
	        fprintf(yyout, "****Error, dato no en tabla local/global (fn_declaration)");
            return ERR; 
	    }
	    
	    datos->numParam = num_parametros_actual;
	    datos->numVarL = num_variables_locales_actual;
	    datos2->numParam = num_parametros_actual;
	    datos2->numVarL = num_variables_locales_actual;
	    
	    gc_cuerpo_cabecera_funcion($1.lexema, num_variables_locales_actual);
        
        strcpy($$.lexema, $1.lexema);

        if(debug==1) printf("Declarada funcion con %d parametros\n", num_parametros_actual);
};

funcion : fn_declaration sentencias TOK_LLAVEDERECHA {
         fprintf(yyout,";R22:\t<funcion> ::= function <tipo> <identificador> ( <parametros_funcion> ) { <declaraciones_funcion> <sentencias> }\n");
         if(flag_return==0){
            fprintf(stderr, "****Error semantico en lin %d: Funcion %s sin sentencia de retorno.\n", fila, $1.lexema);
            return ERR;   
         }
         if(cerrarAmbito(ts)==0){
            fprintf(yyout, "****Error de la ts al cerrar ambito. \n");
         }
};

parametros_funcion: parametro_funcion resto_parametros_funcion {fprintf(yyout,";R23:\t<parametros_funcion> ::= <parametro_funcion> <resto_parametros_funcion>\n");};
|                   {fprintf(yyout,";R24:\t<parametros_funcion> ::=\n");};

resto_parametros_funcion: TOK_PUNTOYCOMA parametro_funcion resto_parametros_funcion {fprintf(yyout,";R25:\t<resto_parametros_funcion> ::= ; <parametro_funcion> <resto_parametros_funcion>\n");};
|                         {fprintf(yyout,";R26:\t<resto_parametros_funcion> ::= \n");};

parametro_funcion: tipo idpf {  fprintf(yyout,";R27:\t<parametro_funcion> ::= <tipo> <identificador>\n");
                                if (existeElem(ts, $2.lexema)==TRUE){
                                    fprintf(stderr, "****Error semantico en lin %d: Declaracion duplicada. \n", fila);
                                    return ERR;                          
                                }
                                if (clase_actual != ESCALAR){
                                    if(debug==1) printf("La clase actual es:%d\n", clase_actual);
                                    fprintf(stderr, "****Error semantico en lin %d: Parametro de funcion de tipo no escalar. \n", fila);
                                    return ERR;                          
                                }
                                if (insertarElem (ts, $2.lexema, PARAMETRO, tipo_actual, clase_actual, tamanio_vector_actual, num_parametros_actual, -1, pos_parametro_actual) != 0){
                                    pos_parametro_actual++;
                                    num_parametros_actual++;
                                }
                                else{
                                    fprintf(yyout, "****Error de la ts en parametro funcion.\n");
                                    return ERR;
                                }
                            };

idpf: TOK_IDENTIFICADOR { strcpy($$.lexema, $1.lexema);/*Esta es la regla identificador*/};

declaraciones_funcion: declaraciones {fprintf(yyout,";R28:\t<declaraciones_funcion> ::= <declaraciones>\n");};
|                      {fprintf(yyout,";R29:\t<declaraciones_funcion> ::=\n");};

sentencias: sentencia {fprintf(yyout,";R30:\t<sentencias> ::= <sentencia>\n");};
|           sentencia sentencias {fprintf(yyout,";R31:\t<sentencias> ::= <sentencia> <sentencias>\n");};

sentencia: sentencia_simple TOK_PUNTOYCOMA {fprintf(yyout,";R32:\t<sentencia> ::= <sentencia_simple> ;\n");};
|          bloque {fprintf(yyout,";R33:\t<sentencia> ::= <bloque>\n");};

sentencia_simple: asignacion {fprintf(yyout,";R34:\t<sentencia_simple> ::= <asignacion>\n");};
|                 lectura {fprintf(yyout,";R35:\t<sentencia_simple> ::= <lectura>\n");};
|                 escritura {fprintf(yyout,";R36:\t<sentencia_simple> ::= <escritura>\n");};
|                 retorno_funcion {fprintf(yyout,";R38:\t<sentencia_simple> ::= <retorno_funcion>\n");};

bloque: condicional {fprintf(yyout,";R40:\t<bloque> ::= <condicional>\n");};
|       bucle {fprintf(yyout,";R41:\t<bloque> ::= <bucle>\n");};

asignacion: TOK_IDENTIFICADOR TOK_ASIGNACION exp {
                        fprintf(yyout,";R43:\t<asignacion> ::= <identificador> = <exp>\n");
                        if(existeElem (ts, $1.lexema)==FALSE){
                            fprintf(stderr,"****Error semantico en lin %d: Acceso a variable no declarada (%s).\n", fila, $1.lexema);
                            return ERR; 
                        }
                        /*Comprobaciones semanticas*/
                        datos_ts * datos = buscarElem (ts, $1.lexema);
                        if((datos->clase==VECTOR) || (datos->categoria==FUNCION)){
                            fprintf(stderr,"****Error semantico en lin %d: Asignacion incompatible.\n", fila);
                            return ERR;
                        }
                        if(datos->tipoDato != $3.tipo){                       
                            fprintf(stderr,"****Error semantico en lin %d: Asignacion incompatible.\n", fila);
                            return ERR; 
                        }

                        if(ambitoElem(ts, $1.lexema)==0){              
                            gc_asig_identificador($3.es_direccion, $1.lexema);                       
                        }
                        else{
                            /*Generacion de codigo*/
                            fprintf(resultado,"pop dword eax\n");
		                    if($3.es_direccion==1){
			                    fprintf(resultado,"mov dword eax, [eax]\n");		
		                    }
		                    if (datos->categoria == PARAMETRO){
		                        fprintf(resultado,"mov dword [ebp+4+4*%d], eax\n", num_parametros_actual - datos->posDe);
		                    }
		                    else{
		                        fprintf(resultado,"mov dword [ebp-4*%d], eax\n",datos->posDe);
		                    }
		                    fprintf (resultado, "\n");
                        }                       
};

|           TOK_IDENTIFICADOR TOK_ASIGNACIONMAS exp {
                        fprintf(yyout,";R43b:\t<asignacion> ::=+ <identificador> = <exp>\n");
                        if(existeElem (ts, $1.lexema)==FALSE){
                            fprintf(stderr,"****Error semantico en lin %d: Acceso a variable no declarada (%s).\n", fila, $1.lexema);
                            return ERR; 
                        }
                        /*Comprobaciones semanticas*/
                        datos_ts * datos = buscarElem (ts, $1.lexema);
                        if((datos->clase==VECTOR) || (datos->categoria==FUNCION)){
                            fprintf(stderr,"****Error semantico en lin %d: Asignacion incompatible.\n", fila);
                            return ERR;
                        }
                        if(datos->tipoDato != $3.tipo){                       
                            fprintf(stderr,"****Error semantico en lin %d: Asignacion incompatible.\n", fila);
                            return ERR; 
                        }

                        if(ambitoElem(ts, $1.lexema)==0){              
                            gc_asig_identificador2($3.es_direccion, $1.lexema);                       
                        }
                        else{
                            /*Generacion de codigo*/
                            /*Local*/
                            fprintf(resultado,"pop dword eax\n");
		                    if($3.es_direccion==1){
			                    fprintf(resultado,"mov dword eax, [eax]\n");		
		                    }
		                    if (datos->categoria == PARAMETRO){		                        
		                        //fprintf(resultado,"mov dword [ebp+4+4*%d], eax\n", num_parametros_actual - datos->posDe);
		                        fprintf(resultado,"add dword [ebp+4+4*%d], eax\n", num_parametros_actual - datos->posDe);
		                    }
		                    else{
		                        //fprintf(resultado,"mov dword [ebp-4*%d], eax\n",datos->posDe);
		                        fprintf(resultado,"add dword [ebp-4*%d], eax\n",datos->posDe);
		                    }
		                    fprintf (resultado, "\n");
                        }
};

|           elemento_vector TOK_ASIGNACION exp {
                        fprintf(yyout,";R44:\t<asignacion> ::= <elemento_vector> = <exp>\n");
                        gc_asig_elementovector($3.es_direccion);
};

elemento_vector: TOK_IDENTIFICADOR TOK_CORCHETEIZQUIERDO exp TOK_CORCHETEDERECHO {
                        fprintf(yyout,";R48:\t<elemento_vector> ::= <identificador> [ <exp> ]\n");
                        if(existeElem (ts, $1.lexema)==FALSE){
                            fprintf(stderr,"****Error semantico en lin %d: Acceso a variable no declarada (%s).\n", fila, $1.lexema);
                            return ERR; 
                        }
                        /*Comprobaciones semanticas*/
                        datos_ts * datos = buscarElem (ts, $1.lexema);
                        if(datos->clase!=VECTOR){
                            fprintf(stderr,"**** Error semantico en lin %d: Intento de indexacion de una variable que no es de tipo vector.\n", fila);
                            return ERR;
                        }
                        if($3.tipo != INT){
                            fprintf(stderr,"****Error semantico en lin %d: El indice en una operacion de indexacion tiene que ser de tipo entero. \n", fila);
                            return ERR;
                        }
                        if(datos->tipoDato != $3.tipo){                       
                            fprintf(stderr,"****Error semantico en lin %d: Asignacion incompatible.\n", fila);
                            return ERR; 
                        } 
                        gc_index_vector($3.es_direccion, en_explist, $1.lexema, datos->tamanoVector);
                        $$.tipo = datos->tipoDato;
                        $$.es_direccion = 1;
};

if_exp: TOK_IF TOK_PARENTESISIZQUIERDO exp TOK_PARENTESISDERECHO TOK_LLAVEIZQUIERDA {
                        if ($3.tipo != BOOLEAN){                       
                            fprintf(stderr,"****Error semantico en lin %d: Condicional con condicion de tipo int. \n", fila);
                            return ERR;                      
                        }
                        /*generacion de codigo*/
                        $$.etiqueta=etiqueta++;
	                    fprintf(resultado,"pop eax\n");
	                    if ($3.es_direccion==1){
		                    fprintf(resultado,"mov eax, [eax]\n");
	                    }
	                    fprintf(resultado,"cmp eax, 0\n");
	                    fprintf(resultado,"je near fin_si%d\n",$$.etiqueta);
	                    fprintf (resultado, "\n");
};

if_exp_sentencias: if_exp sentencias TOK_LLAVEDERECHA {
	                    /*generacion de codigo*/
	                    etiqueta++;
	                    fprintf(resultado,"jmp near fin_sino%d\n",$1.etiqueta);
	                    fprintf(resultado,"fin_si%d:\n",$1.etiqueta);
	                    fprintf (resultado, "\n");
};

while: TOK_WHILE TOK_PARENTESISIZQUIERDO{
                        /*generacion de codigo*/
	                    $$.etiqueta = etiqueta++;
	                    fprintf(resultado,"inicio_while%d:\n",$$.etiqueta);
	                    fprintf (resultado, "\n");
};

while_exp: while exp TOK_PARENTESISDERECHO TOK_LLAVEIZQUIERDA {
                        if ($2.tipo != BOOLEAN){                       
                            fprintf(stderr,"****Error semantico en lin %d: Bucle con condicion de tipo int. \n", fila);
                            return ERR;                      
                        }
                        /*generacion de codigo*/
                        $$.etiqueta=$1.etiqueta;
	                    fprintf(resultado,"pop eax\n");
	                    if ($2.es_direccion == 1){
		                    fprintf(resultado,"mov eax, [eax]\n");
	                    }
	                    fprintf(resultado,"cmp eax, 0\n");
	                    fprintf(resultado,"je near fin_while%d\n", $$.etiqueta);
	                    fprintf (resultado, "\n");                      
};

condicional: if_exp sentencias TOK_LLAVEDERECHA{
                        fprintf(yyout,";R50:\t<condicional> ::= if ( <exp> ) { <sentencias> }\n");
                        /*generacion de codigo*/
                        fprintf(resultado,"fin_si%d:\n\n",$1.etiqueta);
};

|            if_exp_sentencias TOK_ELSE TOK_LLAVEIZQUIERDA sentencias TOK_LLAVEDERECHA {
                        fprintf(yyout,";R51:\t<condicional> ::= if ( <exp> ) { <sentencias> } else { <sentencias> }\n");
                        /*generacion de codigo*/
                        fprintf(resultado,"fin_sino%d:\n\n",$1.etiqueta);
};

bucle: while_exp sentencias TOK_LLAVEDERECHA {
                        fprintf(yyout,";R52:\t<bucle> ::= while ( <exp> ) { <sentencias> }\n");
                        /*generacion de codigo*/
                        fprintf(resultado,"jmp near inicio_while%d\n",$1.etiqueta);
	                    fprintf(resultado,"fin_while%d:\n\n",$1.etiqueta);
};

lectura: TOK_SCANF TOK_IDENTIFICADOR {
                        fprintf(yyout,";R54:\t<lectura> ::= scanf <identificador>\n");
                        if(existeElem (ts, $2.lexema)==FALSE){
                            fprintf(stderr,"****Error semantico en lin %d: Acceso a variable no declarada (%s).\n",fila, $2.lexema);
                            return ERR; 
                        }
                        /*Comprobaciones semanticas*/
                        datos_ts * datos = buscarElem (ts, $2.lexema);
                        if(datos->clase!=ESCALAR){
                            fprintf(stderr, "****Error semantico en lin %d: Parametro de funcion de tipo no escalar. \n", fila);
                            return ERR;
                        }
                        if(datos->categoria==FUNCION){
                            fprintf(yyout, "****Error semantico, identificador incorrecto.\n");
                            return ERR;
                        }
                        /*Generacion de codigo*/
                        if(ambitoElem(ts, $2.lexema)==0){
                            fprintf(resultado, "push dword _%s\n", $2.lexema);
                        } 
                        else{
                            if(datos->categoria==PARAMETRO){
			                    fprintf(resultado,"lea eax, [ebp+4+4*(%d)]\n",num_parametros_actual - datos->posDe);
			                    fprintf(resultado,"push dword eax\n");
		                    }
		                    else{		                    
			                    fprintf(resultado,"lea eax, [ebp-4*%d]\n",datos->posDe);
			                    fprintf(resultado,"push dword eax\n");
		                    }
                        }
                        fprintf (resultado, "\n");
                        gc_lectura(datos->tipoDato, $2.lexema);
};

escritura: TOK_PRINTF exp {
                        fprintf(yyout,";R56:\t<escritura> ::= printf <exp>\n");
                        gc_escritura($2.es_direccion, $2.tipo);
};

retorno_funcion: TOK_RETURN exp {fprintf(yyout,";R61:\t<retorno_funcion> ::= return <exp>\n");
                        if($2.tipo != tipo_funcion){
                            fprintf(stderr, "****Error semantico en lin %d: Asignacion incompatible. \n", fila);
                            //return ERR;                     
                        }

                        if (ambitoActual(ts) != 2){
                            fprintf(stderr, "****Error semantico en lin %d: Sentencia de retorno fuera del cuerpo de una función. \n", fila);
                            return ERR;
                        }
                        flag_return = 1;
                        gc_cuerpo_acaba_funcion ($2.es_direccion);
};

exp: exp TOK_MAS exp {fprintf(yyout,";R72:\t<exp> ::= <exp> + <exp>\n");
                        if($1.tipo != INT || $3.tipo != INT){                      
                            fprintf(stderr, "****Error semantico en lin %d: Operacion aritmetica con operandos boolean.\n", fila);
                            return ERR;                      
                        }
			            gc_suma_enteros($1.es_direccion, $3.es_direccion);
                        $$.tipo = $1.tipo;
                        $$.es_direccion = 0;
};
|    exp TOK_MENOS exp {fprintf(yyout,";R73:\t<exp> ::= <exp> - <exp>\n");
                        if($1.tipo != INT || $3.tipo != INT){                      
                            fprintf(stderr, "****Error semantico en lin %d: Operacion aritmetica con operandos boolean.\n", fila);
                            return ERR;                      
                        }
			            gc_resta_enteros($1.es_direccion, $3.es_direccion);
                        $$.tipo = $1.tipo;
                        $$.es_direccion = 0;
};
|    exp TOK_DIVISION exp {fprintf(yyout,";R74:\t<exp> ::= <exp> / <exp>\n");
                        if($1.tipo != INT || $3.tipo != INT){                      
                            fprintf(stderr, "****Error semantico en lin %d: Operacion aritmetica con operandos boolean.\n", fila);
                            return ERR;                      
                        }
                        gc_dividir_enteros($1.es_direccion, $3.es_direccion);
                        $$.tipo = $1.tipo;
                        $$.es_direccion = 0;
};
|    exp TOK_ASTERISCO exp {fprintf(yyout,";R75:\t<exp> ::= <exp> * <exp>\n");
                        if($1.tipo != INT || $3.tipo != INT){                      
                            fprintf(stderr, "****Error semantico en lin %d: Operacion aritmetica con operandos boolean.\n", fila);
                            return ERR;                      
                        }
                        gc_multiplicar_enteros($1.es_direccion, $3.es_direccion);
                        $$.tipo = $1.tipo;
                        $$.es_direccion = 0;
};
|    TOK_MENOS exp %prec MENOSU {fprintf(yyout,";R76:\t<exp> ::= - <exp>\n");
                        if($2.tipo != INT){                      
                            fprintf(stderr, "****Error semantico en lin %d: Operacion aritmetica con operandos boolean.\n", fila);
                            return ERR;                      
                        }
                        gc_negativo_enteros($2.es_direccion);
                        $$.tipo = $2.tipo;
                        $$.es_direccion = 0;
};

|    exp TOK_AND exp {fprintf(yyout,";R77:\t<exp> ::= <exp> && <exp>\n");
                        if($1.tipo != BOOLEAN || $3.tipo != BOOLEAN){                      
                            fprintf(stderr, "****Error semantico en lin %d: Operacion logica con operandos int. \n", fila);
                            return ERR;                      
                        }
                        gc_and_bool($1.es_direccion, $3.es_direccion);
                        $$.tipo = $1.tipo;
                        $$.es_direccion = 0;
};

|    exp TOK_OR exp {fprintf(yyout,";R78:\t<exp> ::= <exp> || <exp>\n");
                        if($1.tipo != BOOLEAN || $3.tipo != BOOLEAN){                      
                            fprintf(stderr, "****Error semantico en lin %d: Operacion logica con operandos int. \n", fila);
                            return ERR;                      
                        }
                        gc_or_bool($1.es_direccion, $3.es_direccion);
                        $$.tipo = $1.tipo;
                        $$.es_direccion = 0;
};
|    TOK_NOT exp {fprintf(yyout,";R79:\t<exp> ::= ! <exp>\n");
                        if($2.tipo != BOOLEAN){                      
                            fprintf(stderr, "****Error semantico en lin %d: Operacion logica con operandos int. \n", fila);
                            return ERR;                      
                        }
                        gc_not_bool($2.es_direccion);
                        $$.tipo = $2.tipo;
                        $$.es_direccion = 0;

};
|    TOK_IDENTIFICADOR {fprintf(yyout,";R80:\t<exp> ::= <identificador>\n");
                        if(existeElem (ts, $1.lexema)==FALSE){
                            fprintf(stderr,"****Error semantico en lin %d: Acceso a variable no declarada (%s).\n", fila,$1.lexema);
                            return ERR; 
                        }
                        /*Comprobaciones semanticas*/
                        datos_ts * datos = buscarElem (ts, $1.lexema);
                        if(datos->categoria==FUNCION){
                            fprintf(stderr, "****Error semantico en lin %d: Asignacion incompatible.\n", fila);
                            return ERR;
                        }
                        if(datos->clase==VECTOR){
                            if(debug==1) printf("key=%s\n", datos->key);
                            fprintf(stderr, "****Error semantico en lin %d: Variable local de tipo no escalar. \n", fila);
                            return ERR;
                        }
                        
                        $$.tipo = datos->tipoDato;
                                              
                        /*Generacion de codigo*/
                        if(ambitoElem(ts, $1.lexema)==0){
                        		if (en_explist==0) fprintf(resultado, "push dword _%s\n", $1.lexema);
		                        else fprintf(resultado, "push dword [_%s]\n", $1.lexema);
		                        $$.es_direccion = 1;                    
                        }
                        else{
		                        if(datos->categoria == PARAMETRO || en_explist==1) fprintf(resultado, "push dword [ebp+4+4*%d]\n",num_parametros_actual - datos->posDe);
		                        else fprintf(resultado, "push dword [ebp-4*%d]\n",datos->posDe);
		                        $$.es_direccion = 0; 
		                                               
                        }
                        fprintf (resultado, "\n");
};
|    constante {fprintf(yyout,";R81:\t<exp> ::= <constante>\n");
                        $$.tipo = $1.tipo;
                        $$.es_direccion = $1.es_direccion;

};
|    TOK_PARENTESISIZQUIERDO exp TOK_PARENTESISDERECHO {fprintf(yyout,";R82:\t<exp> ::= ( <exp> )\n");
                        $$.tipo = $2.tipo;
                        $$.es_direccion = $2.es_direccion;
};
|    TOK_PARENTESISIZQUIERDO comparacion TOK_PARENTESISDERECHO {fprintf(yyout,";R83:\t<exp> ::= ( <comparacion> )\n");
                        $$.tipo = $2.tipo;
                        $$.es_direccion = $2.es_direccion;
};
|    elemento_vector {fprintf(yyout,";R85:\t<exp> ::= <elemento_vector>\n");
                        $$.tipo = $1.tipo;
                        $$.es_direccion = $1.es_direccion;
};
|    idf_llamada_funcion TOK_PARENTESISIZQUIERDO lista_expresiones TOK_PARENTESISDERECHO {
                        fprintf(yyout,";R88:\t<exp> ::= <identificador> ( <lista_expresiones> )\n");
                        
                        if(existeElem (ts, $1.lexema)==FALSE){
                            fprintf(stderr,"****Error semantico en lin %d: Acceso a variable no declarada (%s).\n", fila,$1.lexema);
                            return ERR; 
                        }                     

                        datos_ts * datos = buscarElem (ts, $1.lexema);          
                        
                        if (datos->categoria!=FUNCION){
		                    fprintf(stderr, "**** Error semantico en lin %d: Categoria incompatible para la llamada a funcion\n",fila);
		                    return ERR;
	                    }
                                  
                        if(num_parametros_llamada_actual != datos->numParam){                  
                            fprintf(stderr,"****Error semantico en lin %d: Numero incorrecto de parametros en llamada a funcion.\n", fila);
                            return ERR; 
                        } 
                        en_explist = 0;
                        
                        $$.tipo = datos->tipoDato;
                        $$.es_direccion=0;
                        
                        gc_llamada_funcion($1.lexema, num_parametros_actual);
};

idf_llamada_funcion: TOK_IDENTIFICADOR {
                        if(existeElem (ts, $1.lexema)==FALSE){
                            fprintf(stderr,"****Error semantico en lin %d: Acceso a variable no declarada (%s).\n", fila, $1.lexema);
                            return ERR; 
                        }
                        
                        /*Comprobaciones semanticas*/
                        
                        datos_ts * datos = buscarElem (ts, $1.lexema);
                        if(datos->categoria!=FUNCION){
                            fprintf(stderr, "****Error semantico en lin %d: Identificador no de tipo funcion.\n", fila);
                            return ERR;
                        }
                        
                        if(en_explist == 1){                       
                            fprintf(stderr,"****Error semantico en lin %d: No esta permitido el uso de llamadas a funciones como parametros de otras funciones.\n", fila);
                            return ERR; 
                        }
                        
                        num_parametros_llamada_actual = 0;
                        en_explist = 1;
                        strcpy($$.lexema, $1.lexema);
};


lista_expresiones: exp resto_lista_expresiones {fprintf(yyout,";R89:\t<lista_expresiones> ::= <exp> <resto_lista_expresiones>\n");
                        num_parametros_llamada_actual++;
};
|                  {fprintf(yyout,";R90:\t<lista_expresiones> ::=\n");};

resto_lista_expresiones: TOK_COMA exp resto_lista_expresiones {fprintf(yyout,";R91:\t<resto_lista_expresiones> ::= , <exp> <resto_lista_expresiones>\n");
                        num_parametros_llamada_actual++;
};
|                        {fprintf(yyout,";R92:\t<resto_lista_expresiones> ::=\n");};

comparacion: exp TOK_IGUAL exp {fprintf(yyout,";R93:\t<comparacion> ::= <exp> == <exp>\n");
                        if($1.tipo != INT || $3.tipo != INT){                      
                            fprintf(stderr, "****Error semantico en lin %d: Comparacion con operandos boolean. \n", fila);
                            return ERR;                      
                        }
                        gc_igual_cmp ($1.es_direccion, $3.es_direccion);
                        $$.tipo = BOOLEAN;
                        $$.es_direccion = 0;
};
|            exp TOK_DISTINTO exp {fprintf(yyout,";R94:\t<comparacion> ::= <exp> != <exp>\n");
                        if($1.tipo != INT || $3.tipo != INT){                      
                            fprintf(stderr, "****Error semantico en lin %d: Comparacion con operandos boolean. \n", fila);
                            return ERR;                      
                        }
                        gc_distinto_cmp ($1.es_direccion, $3.es_direccion);
                        $$.tipo = BOOLEAN;
                        $$.es_direccion = 0;
};
|            exp TOK_MENORIGUAL exp {fprintf(yyout,";R95:\t<comparacion> ::= <exp> <= <exp>\n");
                        if($1.tipo != INT || $3.tipo != INT){                      
                            fprintf(stderr, "****Error semantico en lin %d: Comparacion con operandos boolean. \n", fila);
                            return ERR;                      
                        }
                        gc_menorigual_cmp ($1.es_direccion, $3.es_direccion);
                        $$.tipo = BOOLEAN;
                        $$.es_direccion = 0;
};
|            exp TOK_MAYORIGUAL exp {fprintf(yyout,";R96:\t<comparacion> ::= <exp> >= <exp>\n");
                        if($1.tipo != INT || $3.tipo != INT){                      
                            fprintf(stderr, "****Error semantico en lin %d: Comparacion con operandos boolean. \n", fila);
                            return ERR;                      
                        }
                        gc_mayorigual_cmp ($1.es_direccion, $3.es_direccion);
                        $$.tipo = BOOLEAN;
                        $$.es_direccion = 0;
};
|            exp TOK_MENOR exp {fprintf(yyout,";R97:\t<comparacion> ::= <exp> < <exp>\n");
                        if($1.tipo != INT || $3.tipo != INT){                      
                            fprintf(stderr, "****Error semantico en lin %d: Comparacion con operandos boolean. \n", fila);
                            return ERR;                      
                        }
                        gc_menor_cmp ($1.es_direccion, $3.es_direccion);
                        $$.tipo = BOOLEAN;
                        $$.es_direccion = 0;
};
|            exp TOK_MAYOR exp {fprintf(yyout,";R98:\t<comparacion> ::= <exp> > <exp>\n");
                        if($1.tipo != INT || $3.tipo != INT){                      
                            fprintf(stderr, "****Error semantico en lin %d: Comparacion con operandos boolean. \n", fila);
                            return ERR;                      
                        }
                        gc_mayor_cmp ($1.es_direccion, $3.es_direccion);
                        $$.tipo = BOOLEAN;
                        $$.es_direccion = 0;
};

constante: constante_logica {fprintf(yyout,";R99:\t<constante> ::= <constante_logica>\n");
                        $$.tipo = BOOLEAN;
                        $$.es_direccion = 0;
};
|          constante_entera {fprintf(yyout,";R100:\t<constante> ::= <constante_entera>\n");
                        $$.tipo = INT;
                        $$.es_direccion = 0;
};

constante_logica: TOK_TRUE {fprintf(yyout,";R102:\t<constante_logica> ::= true\n");
                        /* generación de código */
                        fprintf(resultado, "\tpush dword 1\n");
                        fprintf (resultado, "\n");
};
|                 TOK_FALSE {fprintf(yyout,";R103:\t<constante_logica> ::= false\n");
                        /* generación de código */
                        fprintf(resultado, "\tpush dword 0\n");
                        fprintf (resultado, "\n");

};

constante_entera: TOK_CONSTANTE_ENTERA {fprintf(yyout,";R104:\t<constante_entera> ::= TOK_CONSTANTE_ENTERA\n");
                        /* generación de código */
                        fprintf(resultado, "\tpush dword %d\n", $1.valor_entero);
                        fprintf (resultado, "\n");
};

identificador: TOK_IDENTIFICADOR {
                                    if(error_clase_vector == 1){
                                        fprintf(stderr, "****Error semantico en lin %d: El tamanyo del vector %s excede los limites permitidos (1,64). \n", fila, $1.lexema);
                                        return ERR;
                                    }
                                     
                                    fprintf(yyout,";R108:\t<identificador> ::= TOK_IDENTIFICADOR\n");
                                    if(existeElem(ts, $1.lexema) == TRUE){
                                       fprintf(stderr,"****Error semantico en lin %d: Declaracion duplicada. \n", fila);
                                       return ERR;                                                                 
                                    }
                                    if (insertarElem (ts, $1.lexema, VARIABLE, tipo_actual, clase_actual, tamanio_vector_actual, num_parametros_actual, num_variables_locales_actual, pos_variable_local_actual) != 0){
                                        pos_variable_local_actual++;
                                        num_variables_locales_actual++;                                  
                                 };
}

%% /*SECCION DE FUNCIONES DEL USUARIO*/

yyerror(char * s) {
    if(err==0){
        columna-=yyleng;
        fprintf(stderr, "****Error sintactico en [lin %d, col %d]\n", fila, columna);
    }
}
