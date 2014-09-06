#include "lista_colgante.h"



void lista_filtrar(lista_colgante_t* self, nodo_bool_method test_method) {
	
	nodo_t* nodo = self->primero;
	nodo_t** nodoPrevio = (nodo_t**) self;
	nodo_t* nodoSiguiente;
	
	if (nodo != NULL)
		nodoSiguiente = nodo->siguiente;
	
	while (nodo != NULL) {
		
		if (test_method(nodo)) {
			//Borro el nodo y sus descendientes.
			nodo_concatenar(nodoPrevio, nodoSiguiente);
			nodo_borrar_con_hijos(nodo);
			nodo = nodoSiguiente;
			
		} else {
			
			//Avanzo los punteros
			nodoPrevio = &((*nodoPrevio)->siguiente);
			nodo = nodoSiguiente;
		
		}
		
		if (nodo != NULL)
			nodoSiguiente = nodo->siguiente;
		
	}
	
}	
