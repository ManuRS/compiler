###################################### 
#   Makefile compilardor alfa        #
#   Author: Manuel Reyes Sanchez     #
#   EPS-UAM                          #
######################################
CC = gcc
CFLAGS = -g

all: alfa

alfa: y.tab.o lex.yy.o tabla_simbolos.o hash.o genCodigo.o
	$(CC) -o alfa alfa.c y.tab.o lex.yy.o tabla_simbolos.o hash.o genCodigo.o
	
genCodigo.o: genCodigo.c genCodigo.h
	$(CC) $(CFLAGS) -c genCodigo.c genCodigo.h
	
tabla_simbolos.o: tabla_simbolos.c hash.h tabla_simbolos.h hash.o
	$(CC) $(CFLAGS) -c tabla_simbolos.c hash.h tabla_simbolos.h
   
hash.o: hash.c hash.h
	$(CC) $(CFLAGS) -c hash.c hash.h

lex.yy.o: lex.yy.c
	$(CC) $(CFLAGS) -c lex.yy.c

y.tab.o: y.tab.c
	$(CC) $(CFLAGS) -c y.tab.c
    
lex.yy.c: alfa.l
	flex alfa.l

y.tab.c: alfa.y
	bison -d -y -v alfa.y	

clean:
	rm -f hash.o programa.o tabla_simbolos.o y.tab.o lex.yy.o genCodigo.o *.gch core alfa y.* lex.yy.c debug.txt programa.asm programa.o ejecutable
	
clear:
	rm -f hash.o programa.o tabla_simbolos.o y.tab.o lex.yy.o genCodigo.o *.gch core y.* lex.yy.c

asm:
	./alfa fuente2.alf programa.asm
	nasm -g -o programa.o -f elf programa.asm
	gcc -o ejecutable programa.o alfalib.o
	./ejecutable
	@echo

author:
	@echo
	@echo "-----------------------------"
	@echo "-    Manuel Reyes Sanchez   -"
	@echo "-    EPS-UAM                -"
	@echo "-----------------------------"
	@echo

help:
	@echo
	@echo "-----------------------------------"
	@echo " Compilador para el lenguage alfa"
	@echo "-----------------------------------"
	@echo
	@echo "Autor:"
	@echo "\tManuel Reyes Sanchez"
	@echo "\tEPS-UAM"
	@echo	
	@echo "Crear el compilador:"
	@echo "\tmake"
	@echo
	@echo "Limpiar directorio:"
	@echo "\tmake clean"
	@echo "\tmake clear"
	@echo 
	@echo "Crear archivo en ensamblador asm:"
	@echo "\t./alfa fuente.alfa programa.asm"
	@echo "Crear ejecutable:"
	@echo "\tnasm -g -o programa.o -f elf programa.asm"
	@echo "\tgcc -o ejecutable programa.o alfalib.o"
	@echo
	@echo "Compilar y ejectar codigo alfa (ruta predefinida):"
	@echo "\tmake asm"
	@echo
	
