/*------------------------------------ 
  -   genCodigo.c                    -
  -   Author: Manuel Reyes Sanchez   -
  -   EPS-UAM                        -
  ------------------------------------*/

#include <stdio.h>
#include <string.h>
#include "tabla_simbolos.h"
#include "hash.h"
#include "tipos.h"

extern ambitos_t *ts;
extern FILE * resultado;

int etiqueta = 0;

void locales(){
    int i = 0;
    hashtable_t *global = getGlobal(ts);
    entry_t *nodo;
    fprintf (resultado, "segment .bss\n");
    fprintf (resultado, "__back resd 1\n");
    
    for (i=0; i<global->size; i++){
        nodo = global->table[i];
        while(nodo!=NULL){
            if (nodo->datos->clase==ESCALAR)fprintf (resultado, "_%s resd 1\n", nodo->datos->key);
            else fprintf (resultado, "_%s resd %d\n", nodo->datos->key, nodo->datos->tamanoVector);
            nodo=nodo->next;
        }
    }
    fprintf (resultado, "\n");
}


void data(){
    fprintf (resultado, "segment .data\n");
    fprintf (resultado, "mensaje_1 db '****Error ejecucion: Indice fuera de rango.', 0\n");
    fprintf (resultado, "mensaje_2 db '****Error ejecucion: Division por cero.', 0\n");
    fprintf (resultado, "\n");
}

void cabecera(){
    fprintf (resultado, "segment .text\n");
    fprintf (resultado, "global main\n");
    fprintf (resultado, "extern scan_int, scan_boolean\n");
    fprintf (resultado, "extern print_int, print_boolean, print_string, print_blank, print_endofline\n");
    fprintf (resultado, "\n");
}

void gc_ets (){
    data();
    locales();
    cabecera();
}

void gc_main(){
	fprintf(resultado,"main: \n");
	fprintf(resultado,"push dword eax\n");
	fprintf(resultado,"push dword ebx\n");
	fprintf(resultado,"push dword ecx\n");
	fprintf(resultado,"push dword edx\n");
	fprintf(resultado,"mov dword [__back], esp\n");
    fprintf (resultado, "\n");
}

void gc_fin(){
    fprintf (resultado, "jmp near fin\n");
    fprintf (resultado, "error_1: push dword mensaje_1\n");
    fprintf (resultado, "call print_string\n");
    fprintf (resultado, "add esp, 4\n");
    fprintf (resultado,"call print_endofline\n");
    fprintf (resultado, "jmp near fin\n");
    fprintf (resultado, "error_2: push dword mensaje_2\n");
    fprintf (resultado, "call print_string\n");
    fprintf (resultado, "add esp, 4\n");
    fprintf (resultado,"call print_endofline\n");
    fprintf (resultado, "jmp near fin\n");
    fprintf (resultado, "fin:\n");
    fprintf (resultado, "mov dword esp, [__back]\n");
    fprintf (resultado, "pop dword edx\n");
    fprintf (resultado, "pop dword ecx\n");
    fprintf (resultado, "pop dword ebx\n");
    fprintf (resultado, "pop dword eax\n");
    fprintf (resultado, "ret\n");
    fprintf (resultado, "\n");
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

void comun (int es_direccion_op1, int es_direccion_op2){
    fprintf(resultado, "; cargar el segundo operando en edx\n");
    fprintf(resultado, "pop dword edx\n");
    if (es_direccion_op2 == 1)
        fprintf(resultado, "mov dword edx , [edx]\n");
    fprintf(resultado, "; cargar el primer operando en eax\n");
    fprintf(resultado,"pop dword eax\n");
    if (es_direccion_op1 == 1)
        fprintf(resultado, "mov dword eax , [eax]\n");
    fprintf(resultado, "; realizar la suma y dejar el resultado en eax \n");

}

void gc_suma_enteros(int es_direccion_op1, int es_direccion_op2){
    comun(es_direccion_op1, es_direccion_op2);
    fprintf(resultado, "add eax,edx\n");
    fprintf(resultado, "; apilar el resultado\n");
    fprintf(resultado, "push dword eax\n");
    fprintf (resultado, "\n");
}

void gc_resta_enteros(int es_direccion_op1, int es_direccion_op2){
    comun(es_direccion_op1, es_direccion_op2);
    fprintf(resultado, "sub eax,edx\n");
    fprintf(resultado, "; apilar el resultado\n");
    fprintf(resultado, "push dword eax\n");
    fprintf (resultado, "\n");
}

void gc_dividir_enteros(int es_direccion_op1, int es_direccion_op2){
    fprintf(resultado, "; cargar el segundo operando en edx\n");
    fprintf(resultado, "pop dword edx\n");
    if (es_direccion_op2 == 1)
        fprintf(resultado, "mov dword edx , [edx]\n");
    fprintf(resultado, "; cargar el primer operando en eax\n");
    fprintf(resultado,"pop dword eax\n");
    fprintf(resultado,"cmp edx, 0\n");
    fprintf(resultado,"je near error_2\n");
    if (es_direccion_op1 == 1)
        fprintf(resultado, "mov dword eax , [eax]\n");
    fprintf(resultado, "; realizar la suma y dejar el resultado en eax \n");
    fprintf(resultado, "mov ecx,edx\n");
    fprintf(resultado, "cdq\n");
    fprintf(resultado, "idiv ecx\n");
    fprintf(resultado, "; apilar el resultado\n");
    fprintf(resultado, "push dword eax\n");
    fprintf (resultado, "\n");
}

void gc_multiplicar_enteros(int es_direccion_op1, int es_direccion_op2){
    comun(es_direccion_op1, es_direccion_op2);
    fprintf(resultado, "imul edx\n");
    fprintf(resultado, "; apilar el resultado\n");
    fprintf(resultado, "push dword eax\n");
    fprintf (resultado, "\n");
}

void gc_negativo_enteros(int es_direccion_op1){
    fprintf(resultado, "; cargar el primer operando en eax\n");
    fprintf(resultado,"pop dword eax\n");
    if (es_direccion_op1 == 1)
        fprintf(resultado, "mov dword eax , [eax]\n");
    fprintf(resultado, "; realizar la suma y dejar el resultado en eax \n");
    fprintf(resultado, "neg eax\n");
    fprintf(resultado, "; apilar el resultado\n");
    fprintf(resultado, "push dword eax\n");
    fprintf (resultado, "\n");
}

/////////////////////////////////////////////////////////////////////////////////////////

void comun1(int es_direccion_op1, int es_direccion_op2){
    fprintf(resultado, "; cargar el segundo operando en edx\n");
    fprintf(resultado, "pop dword edx\n");
    if (es_direccion_op2 == 1)
        fprintf(resultado, "mov dword edx , [edx]\n");
    fprintf(resultado, "; cargar el primer operando en eax\n");
    fprintf(resultado,"pop dword eax\n");
    if (es_direccion_op1 == 1)
        fprintf(resultado, "mov dword eax , [eax]\n");
    fprintf(resultado, "; realizar la suma y dejar el resultado en eax \n");
}

void gc_and_bool (int es_direccion_op1, int es_direccion_op2){
    comun1(es_direccion_op1, es_direccion_op2);
    fprintf(resultado, "and eax,edx\n");
    fprintf(resultado, "; apilar el resultado\n");
    fprintf(resultado, "push dword eax\n");
    fprintf (resultado, "\n");
}

void gc_or_bool (int es_direccion_op1, int es_direccion_op2){
    comun1(es_direccion_op1, es_direccion_op2);
    fprintf(resultado, "or eax,edx\n");
    fprintf(resultado, "; apilar el resultado\n");
    fprintf(resultado, "push dword eax\n");
    fprintf (resultado, "\n");
}

void gc_not_bool (int es_direccion_op1){
    fprintf(resultado, "; cargar el operando en edx\n");
	fprintf(resultado,"pop dword eax\n");
	if (es_direccion_op1 == 1)
		fprintf(resultado,"mov dword eax , [eax]\n");
	fprintf(resultado, "or eax , eax\n");
	fprintf(resultado, "jz near negar_false%d\n", etiqueta);
	fprintf(resultado, "mov dword eax,0\n");
	fprintf(resultado, "jmp near fin_neg%d\n", etiqueta);
	fprintf(resultado, "negar_false%d: mov dword eax,1\n", etiqueta);
	fprintf(resultado, "fin_neg%d: push dword eax\n", etiqueta);
	etiqueta++;
	fprintf (resultado, "\n");
}

////////////////////////////////////////////////////////////////////////////////////////////////////

void comun2(int es_direccion_op1, int es_direccion_op2){
    fprintf(resultado, "; cargar el segundo operando en edx\n");
	fprintf(resultado,"pop dword edx\n");
	if (es_direccion_op2 == 1)
		fprintf(resultado,"mov dword edx , [edx]\n");
	fprintf(resultado,"pop dword eax\n");
	fprintf(resultado, "; cargar el primer operando en eax\n");
	if (es_direccion_op1 == 1) 
		fprintf(resultado,"mov dword eax , [eax]\n");
}

void gc_igual_cmp (int es_direccion_op1, int es_direccion_op2){
    comun2(es_direccion_op1, es_direccion_op2);
	fprintf(resultado,"cmp eax, edx\n");
	fprintf(resultado,"je near igual%d\n",etiqueta);
	fprintf(resultado,"push dword 0\n");
	fprintf(resultado,"jmp near fin_igual%d\n",etiqueta);
	fprintf(resultado,"igual%d:	push dword 1\n",etiqueta);
	fprintf(resultado,"fin_igual%d:\n",etiqueta);
    etiqueta++;
    fprintf (resultado, "\n");
}

void gc_distinto_cmp (int es_direccion_op1, int es_direccion_op2){
    comun2(es_direccion_op1, es_direccion_op2);
	fprintf(resultado,"cmp eax, edx\n");
	fprintf(resultado,"jne near distinto%d\n",etiqueta);
	fprintf(resultado,"push dword 0\n");
	fprintf(resultado,"jmp near fin_distinto%d\n",etiqueta);
	fprintf(resultado,"distinto%d:	push dword 1\n",etiqueta);
	fprintf(resultado,"fin_distinto%d:\n",etiqueta);
    etiqueta++;
    fprintf (resultado, "\n");
}

void gc_menorigual_cmp (int es_direccion_op1, int es_direccion_op2){
    comun2(es_direccion_op1, es_direccion_op2);
	fprintf(resultado,"cmp eax, edx\n");
	fprintf(resultado,"jle near menorigual%d\n",etiqueta);
	fprintf(resultado,"push dword 0\n");
	fprintf(resultado,"jmp near fin_menorigual%d\n",etiqueta);
	fprintf(resultado,"menorigual%d:	push dword 1\n",etiqueta);
	fprintf(resultado,"fin_menorigual%d:\n",etiqueta);
    etiqueta++;
    fprintf (resultado, "\n");
}

void gc_mayorigual_cmp (int es_direccion_op1, int es_direccion_op2){
    comun2(es_direccion_op1, es_direccion_op2);;
	fprintf(resultado,"cmp eax, edx\n");
	fprintf(resultado,"jge near mayorigual%d\n",etiqueta);
	fprintf(resultado,"push dword 0\n");
	fprintf(resultado,"jmp near fin_mayorigual%d\n",etiqueta);
	fprintf(resultado,"mayorigual%d:	push dword 1\n",etiqueta);
	fprintf(resultado,"fin_mayorigual%d:\n",etiqueta);
    etiqueta++;
    fprintf (resultado, "\n");
}

void gc_menor_cmp (int es_direccion_op1, int es_direccion_op2){
    comun2(es_direccion_op1, es_direccion_op2);
	fprintf(resultado,"cmp eax, edx\n");
	fprintf(resultado,"jl near menor%d\n",etiqueta);
	fprintf(resultado,"push dword 0\n");
	fprintf(resultado,"jmp near fin_menor%d\n",etiqueta);
	fprintf(resultado,"menor%d:	push dword 1\n",etiqueta);
	fprintf(resultado,"fin_menor%d:\n",etiqueta);
    etiqueta++;
    fprintf (resultado, "\n");
}

void gc_mayor_cmp (int es_direccion_op1, int es_direccion_op2){
       comun2(es_direccion_op1, es_direccion_op2);
	fprintf(resultado,"cmp eax, edx\n");
	fprintf(resultado,"jg near mayor%d\n",etiqueta);
	fprintf(resultado,"push dword 0\n");
	fprintf(resultado,"jmp near fin_mayor%d\n",etiqueta);
	fprintf(resultado,"mayor%d:	push dword 1\n",etiqueta);
	fprintf(resultado,"fin_mayor%d:\n",etiqueta);
    etiqueta++;
    fprintf (resultado, "\n");
}

/////////////////////////////////////////////////////////////////////////////////

void gc_index_vector(int es_direccion_op1, int en_explist, char *key, int tam){
	fprintf(resultado,"pop dword eax\n");
	if (es_direccion_op1==1)
		fprintf(resultado, "mov dword eax , [eax]\n");
	fprintf(resultado,"cmp eax,0\n");
	fprintf(resultado,"jl near error_1\n");
	fprintf(resultado,"cmp eax, %d\n",tam-1);
	fprintf(resultado,"jg near error_1\n");
	fprintf(resultado,"mov dword edx, 4\n");
	fprintf(resultado,"imul edx\n");
	fprintf(resultado,"mov edx, _%s\n", key);
	fprintf(resultado,"add eax,edx\n");
	if (en_explist==1)
	    fprintf(resultado, "mov dword eax , [eax]\n");
	fprintf(resultado,"push dword eax\n");
	fprintf (resultado, "\n");
}

void gc_asig_identificador(int es_direccion_op1, char *key){
	fprintf(resultado,"pop dword eax\n");
	if (es_direccion_op1==1)
		fprintf(resultado, "mov dword eax , [eax]\n");
	fprintf(resultado,"mov dword [_%s], eax\n", key);
	fprintf (resultado, "\n");
}

void gc_asig_identificador2(int es_direccion_op1, char *key){
printf("JEY\n");
	fprintf(resultado,"pop dword eax\n");
	if (es_direccion_op1==1)
		fprintf(resultado, "mov dword eax , [eax]\n");
	fprintf(resultado,"add dword [_%s], eax\n", key);
	fprintf (resultado, "\n");
}

void gc_asig_elementovector(int es_direccion_op1){
	fprintf(resultado,"pop dword eax\n");
	if (es_direccion_op1==1)
		fprintf(resultado,"mov dword eax, [eax]\n");
	fprintf(resultado,"pop dword edx\n");
	fprintf(resultado,"mov dword [edx], eax\n");
	fprintf (resultado, "\n");
}

/////////////////////////////////////////////////////////////////////////////////

void gc_lectura(int tipo, char *texto){
	if(tipo==INT){
		fprintf(resultado,"call scan_int\n");
	}
	else{
		fprintf(resultado,"call scan_boolean\n");
	}
	fprintf(resultado,"add esp,4\n");
	fprintf (resultado, "\n");
}

void gc_escritura(int es_direccion_op1, int tipo){
	if (es_direccion_op1==1){
		fprintf(resultado,"pop dword eax\n");
		fprintf(resultado,"mov dword eax, [eax]\n");
		fprintf(resultado,"push dword eax\n");
	}
	if(tipo==INT){
		fprintf(resultado,"call print_int\n");
	}
	if (tipo==BOOLEAN){
		fprintf(resultado,"call print_boolean\n");
	}
	fprintf(resultado,"add esp,4\n");
	fprintf(resultado,"call print_endofline\n");
	fprintf (resultado, "\n");
}

/////////////////////////////////////////////////////////////////////////////////////////

void gc_llamada_funcion(char *texto, int n){
	fprintf(resultado, "call _%s\n", texto);
	fprintf(resultado, "add esp, 4*%d\n", n);
	fprintf(resultado, "push dword eax\n");
	fprintf (resultado, "\n");
}

void gc_cuerpo_cabecera_funcion(char * texto, int n){
	fprintf(resultado, "_%s:\n",texto);
	fprintf(resultado, "push ebp\n");
	fprintf(resultado, "mov ebp, esp\n");
	fprintf(resultado, "sub esp, 4*%d\n",n);
	fprintf (resultado, "\n");
}

void gc_cuerpo_acaba_funcion (int es_direccion_op1){
	fprintf(resultado, "pop dword eax\n");
	if (es_direccion_op1==1){
   		fprintf(resultado,"mov eax, [eax]\n");
	}
	fprintf(resultado, "mov dword esp, ebp\n");
	fprintf(resultado, "pop dword ebp\n");
	fprintf(resultado, "ret\n");
	fprintf (resultado, "\n");
}
