/*------------------------------------ 
  -   alfa.l                         -
  -   Author: Manuel Reyes Sanchez   -
  -   EPS-UAM                        -
  ------------------------------------*/

/*SECCION DE DEFINICIONES*/
%{
#include <stdio.h> /* para utilizar printf en la sección de reglas */
#include <stdlib.h>
#include <string.h>
#include "tipos.h"
#include "y.tab.h"

int columna = 1;
int fila = 1;
int err = 0;

%}

DIGITO [0-9] 
LETRA [a-zA-Z]
DIGITOYLETRA [a-zA-Z0-9]

%option noyywrap

/*SECCION DE REGLAS*/
%%

[\r] {;}
[ ] {columna++;}
[\t] {columna+=yyleng;}	
[\n] {fila++; columna = 1;}

"//".* {;}

{DIGITO}+ {columna+=yyleng; fprintf(yyout,";D:\t%s\n", yytext); 
           yylval.atributos.valor_entero = atoi(yytext);
           return TOK_CONSTANTE_ENTERA;}

"main" {columna+=yyleng; fprintf(yyout,";D:\t%s\n", yytext); return TOK_MAIN;}
"return" {columna+=yyleng; fprintf(yyout,";D:\t%s\n", yytext); return TOK_RETURN;}
"function" {columna+=yyleng; fprintf(yyout,";D:\t%s\n", yytext); return TOK_FUNCTION;}

"printf" {columna+=yyleng; fprintf(yyout,";D:\t%s\n", yytext); return TOK_PRINTF;}
"scanf" {columna+=yyleng; fprintf(yyout,";D:\t%s\n", yytext); return TOK_SCANF;}

"if" {columna+=yyleng; fprintf(yyout,";D:\t%s\n", yytext); return TOK_IF;}
"else" {columna+=yyleng; fprintf(yyout,";D:\t%s\n", yytext); return TOK_ELSE;}
"while" {columna+=yyleng; fprintf(yyout,";D:\t%s\n", yytext); return TOK_WHILE;}

"int" {columna+=yyleng; fprintf(yyout,";D:\t%s\n", yytext); return TOK_INT;}
"boolean" {columna+=yyleng; fprintf(yyout,";D:\t%s\n", yytext); return TOK_BOOLEAN;}
"true" {columna+=yyleng; fprintf(yyout,";D:\t%s\n", yytext); return TOK_TRUE;}
"false" {columna+=yyleng; fprintf(yyout,";D:\t%s\n", yytext); return TOK_FALSE;}
"array" {columna+=yyleng; fprintf(yyout,";D:\t%s\n", yytext); return TOK_ARRAY;}

";" {columna+=yyleng; fprintf(yyout,";D:\t%s\n", yytext); return TOK_PUNTOYCOMA;}
"," {columna+=yyleng; fprintf(yyout,";D:\t%s\n", yytext); return TOK_COMA;}

"==" {columna+=yyleng; fprintf(yyout,";D:\t%s\n", yytext); return TOK_IGUAL;}
"!=" {columna+=yyleng; fprintf(yyout,";D:\t%s\n", yytext); return TOK_DISTINTO;}
"<=" {columna+=yyleng; fprintf(yyout,";D:\t%s\n", yytext); return TOK_MENORIGUAL;}
">=" {columna+=yyleng; fprintf(yyout,";D:\t%s\n", yytext); return TOK_MAYORIGUAL;}
"<" {columna+=yyleng; fprintf(yyout,";D:\t%s\n", yytext); return TOK_MENOR;}
">" {columna+=yyleng; fprintf(yyout,";D:\t%s\n", yytext); return TOK_MAYOR;}

"+=" {columna+=yyleng; fprintf(yyout,";D:\t%s\n", yytext); return TOK_ASIGNACIONMAS;}
"=" {columna+=yyleng; fprintf(yyout,";D:\t%s\n", yytext); return TOK_ASIGNACION;}
"+" {columna+=yyleng; fprintf(yyout,";D:\t%s\n", yytext); return TOK_MAS;}
"-" {columna+=yyleng; fprintf(yyout,";D:\t%s\n", yytext); return TOK_MENOS;}
"/" {columna+=yyleng; fprintf(yyout,";D:\t%s\n", yytext); return TOK_DIVISION;}

"*" {columna+=yyleng; fprintf(yyout,";D:\t%s\n", yytext); return TOK_ASTERISCO;}

"&&" {columna+=yyleng; fprintf(yyout,";D:\t%s\n", yytext); return TOK_AND;}
"||" {columna+=yyleng; fprintf(yyout,";D:\t%s\n", yytext); return TOK_OR;}
"!" {columna+=yyleng; fprintf(yyout,";D:\t%s\n", yytext); return TOK_NOT;}

"(" {columna+=yyleng; fprintf(yyout,";D:\t%s\n", yytext); return TOK_PARENTESISIZQUIERDO;}
")" {columna+=yyleng; fprintf(yyout,";D:\t%s\n", yytext); return TOK_PARENTESISDERECHO;}
"[" {columna+=yyleng; fprintf(yyout,";D:\t%s\n", yytext); return TOK_CORCHETEIZQUIERDO;}
"]" {columna+=yyleng; fprintf(yyout,";D:\t%s\n", yytext); return TOK_CORCHETEDERECHO;}
"{" {columna+=yyleng; fprintf(yyout,";D:\t%s\n", yytext); return TOK_LLAVEIZQUIERDA;}
"}" {columna+=yyleng; fprintf(yyout,";D:\t%s\n", yytext); return TOK_LLAVEDERECHA;}

{LETRA}{DIGITOYLETRA}* if(yyleng<101) {
                           columna+=yyleng; 
                           fprintf(yyout,";D:\t%s\n", yytext); 
                           strcpy(yylval.atributos.lexema,yytext);
                           return TOK_IDENTIFICADOR;
                       }else{
                           err = 1;
                           printf("****Error en [lin %d, col %d]: identificador demasiado largo (%s)\n", fila, columna, yytext);
                           return TOK_ERROR;
                       }

. {err=1; printf("****Error en [lin %d, col %d]: simbolo no permitido (%s)\n", fila, columna, yytext); return TOK_ERROR;}

%% /*SECCION DE FUNCIONES DEL USUARIO*/
