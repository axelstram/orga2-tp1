#include "lista_colgante.h"
#include <stdlib.h>
#include <string.h>

void lista_colapsar(lista_colgante_t* self, nodo_bool_method test_method, nodo_value_method join_method) {
	
	nodo_t** nodoPrevio = &(self->primero);
	nodo_t* nodo = self->primero;
	
	while (nodo != NULL) {
		
		nodo_t* nodoSiguiente = nodo->siguiente;
		
		if (test_method(nodo) && nodo->hijo != NULL) {
					
			nodo_colapsar(nodoPrevio, join_method);
			nodo_borrar_con_hijos(nodo);	//Borro la columna vieja
			
		}

		
		nodoPrevio = &((*nodoPrevio)->siguiente);
		nodo = nodoSiguiente;	//Me muevo al siguiente nodo
			
	}
		
	
}



void nodo_colapsar(nodo_t** nodoPrevio, nodo_value_method join_method) {
	
	nodo_t* nodoActual = *nodoPrevio;
	nodo_t* nodoSiguiente = nodoActual->siguiente;
	nodo_t* nodoHijo = nodoActual->hijo;
	nodo_t* nodoNuevo;
	
	if (nodoActual->tipo == String) {
		valor_elemento v;
		int length = strlen(nodoActual->valor.s) + 1;	//Incluyo '\0'
		v.s = (char*) malloc(length);
		strncpy(v.s, nodoActual->valor.s, length);
		nodoNuevo = nodo_crear(nodoActual->tipo, v);
	} else {
		nodoNuevo = nodo_crear(nodoActual->tipo, nodoActual->valor);
	}
			
	//Colapso
	while (nodoHijo != NULL) {
				
		valor_elemento valor = join_method(nodoNuevo->valor, nodoHijo->valor);
				
		if (nodoNuevo->tipo == String)
			free(nodoNuevo->valor.s);
					
		nodoNuevo->valor = valor;	
		nodoHijo = nodoHijo->hijo;
				
	}
			
	//Agrego el nodo colapsado a la lista
	nodo_concatenar(nodoPrevio, nodoNuevo);
	nodoNuevo->siguiente = nodoSiguiente;
				
}

