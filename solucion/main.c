#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <math.h>
#include <string.h>

#include "lista_colgante.h"

int main(int argc, char *argv[]) {
	
	
	lista_colgante_t* lista = lista_crear();
	
	valor_elemento valor;
	
	valor.s = malloc(5);
	strncpy(valor.s, "9flx", 5);
	nodo_t* nodo1 = nodo_crear(String, valor);
	
	valor.s = malloc(10);
	strncpy(valor.s, "lt82vf7cb", 10);
	nodo_t* nodo2 = nodo_crear(String, valor);
	
	valor.s = malloc(8);
	strncpy(valor.s, "nod0III", 8);
	nodo_t* nodo3 = nodo_crear(String, valor);
	
	valor.s = malloc(7);
	strncpy(valor.s, "nodoIV", 7);
	nodo_t* nodo4 = nodo_crear(String, valor);
	
	valor.s = malloc(6);
	strncpy(valor.s, "nodoV", 6);
	nodo_t* nodo5 = nodo_crear(String, valor);
	
	valor.s = malloc(7);
	strncpy(valor.s, "nodoVI", 7);
	nodo_t* nodo6 = nodo_crear(String, valor);
	
	valor.s = malloc(8);
	strncpy(valor.s, "nodoVII", 8);
	nodo_t* nodo7 = nodo_crear(String, valor);
	
	
	
	lista_concatenar(lista, nodo1);
	lista_concatenar(lista, nodo2);
	lista_colgar_descendiente(lista, 1, nodo3);
	lista_colgar_descendiente(lista, 1, nodo4); 
	lista_colgar_descendiente(lista, 0, nodo5);
	lista_concatenar(lista, nodo6);
    lista_colgar_descendiente(lista, 2, nodo7);
    
    lista_imprimir(lista, "asd");

	lista_colapsar(lista, &tiene_numeros, &revolver_primeras_5);

	//lista_filtrar(lista, &tiene_numeros);	
	lista_imprimir(lista, "asd");
	
	lista_borrar(lista);
	
	
	
	/*
	lista_colgante_t* lista = lista_crear();
	
	valor_elemento valor;
	valor.i = 20;

	nodo_t* nodo1 = nodo_crear(Integer, valor);
	
	valor.i = 40;
	
	nodo_t* nodo2 = nodo_crear(Integer, valor);
	
	valor.i = 16;
	
	nodo_t* nodo3 = nodo_crear(Integer, valor);
	
	valor.i = 19;
	
	nodo_t* nodo4 = nodo_crear(Integer, valor);
	
	valor.i = 43;
	
	nodo_t* nodo5 = nodo_crear(Integer, valor);
	
	valor.i = 170;
	
	nodo_t* nodo6 = nodo_crear(Integer, valor);

	valor.i = 132;
	
	nodo_t* nodo7 = nodo_crear(Integer, valor);
		
	lista_concatenar(lista, nodo1);
	lista_concatenar(lista, nodo2);
	lista_colgar_descendiente(lista, 1, nodo3);
	lista_colgar_descendiente(lista, 1, nodo4); 
	lista_colgar_descendiente(lista, 0, nodo5);
	lista_concatenar(lista, nodo6);
	lista_concatenar(lista, nodo7);
	
	lista_imprimir(lista, "asd");
	lista_colapsar(lista, &tiene_ceros_en_decimal, &raiz_cuadrada_del_producto);
	//lista_filtrar(lista, &tiene_ceros_en_decimal);
	lista_imprimir(lista, "asd");

	
	
	lista_borrar(lista);
	
	*/
		
	
	/*
	lista_colgante_t* lista = lista_crear();
	
	valor_elemento valor;
	valor.d = 0.23;

	nodo_t* nodo1 = nodo_crear(Double, valor);
	
	valor.d = 3.0;
	
	nodo_t* nodo2 = nodo_crear(Double, valor);

	valor.d = 16.3;
	
	nodo_t* nodo3 = nodo_crear(Double, valor);
	
	valor.d = 19.4;
	
	nodo_t* nodo4 = nodo_crear(Double, valor);
	
	valor.d = 43.2;
	
	nodo_t* nodo5 = nodo_crear(Double, valor);
	
	valor.d = 5.55;
	
	nodo_t* nodo6 = nodo_crear(Double, valor);

	valor.d = 132.0;
	
	nodo_t* nodo7 = nodo_crear(Double, valor);
	
	lista_concatenar(lista, nodo1);
	lista_concatenar(lista, nodo2);
	lista_colgar_descendiente(lista, 1, nodo3);
	lista_colgar_descendiente(lista, 1, nodo4); 
	lista_colgar_descendiente(lista, 0, nodo5);
	lista_concatenar(lista, nodo6);
    lista_colgar_descendiente(lista, 2, nodo7);
	
	lista_colapsar(lista, &parte_decimal_mayor_que_un_medio, &raiz_de_la_suma);
	//lista_filtrar(lista, &parte_decimal_mayor_que_un_medio);
	
	lista_imprimir(lista, "asd");
	
	lista_borrar(lista);
	
	*/
	
	
	/*
	valor.d = 2432.01;
	
	nodo_t* nodo = nodo_crear(Double, valor);
	
	assert(parte_decimal_mayor_que_un_medio(nodo) == 0);
	
	valor_elemento valor2;
	valor_elemento valor3;
	valor2.i = 431;
	valor3.i = 234;
	
	printf("%d\n", raiz_cuadrada_del_producto(valor2, valor3).i);
	
	valor_elemento valor4;
	valor4.s = "oiuyngthnft4un";
	
	nodo_t* n2 = nodo_crear(String, valor4);
	
	assert(tiene_numeros(n2) == 1);
	
	valor_elemento valor5;
	valor_elemento valor6;
	
	valor5.d = -37.6;
	valor6.d = -14.2;
	
	printf("%f\n", raiz_de_la_suma(valor5, valor6).d);
	
	valor2.i = 210;
	
	nodo_t* n3 = nodo_crear(Integer, valor2);
	
	assert(tiene_ceros_en_decimal(n3) == 1);
	
	
	valor_elemento valor7;
	valor_elemento valor8;
	
	valor7.s = "holi";
	valor8.s = "holaaaa";
	
	printf("%s\n", revolver_primeras_5(valor7, valor8).s);
	*/
	
	exit(0);

}
