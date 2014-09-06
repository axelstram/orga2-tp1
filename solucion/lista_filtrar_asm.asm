lista_filtrar:

	;rdi = puntero a lista_borrar
	;rsi = puntero a funcion
	push r13
	push r14
	push r15
	push rdi
	push rsi
	
	cmp QWORD [rdi], NULL  	;Me fijo que hayan nodos
	je .fin
	
	mov r13, rdi			;En r13 mantengo un nodo_t**, que es un puntero al puntero que apunta al nodo previo al apuntado
							;actualmente por rdi. O sea, rdi = puntero al nodo actual, r13 = puntero al puntero al nodo previo
	mov rdi, [rdi]			;Apunto al primer nodo
	

.evaluar:
	
	cmp QWORD rdi, NULL
	je .fin

	mov r15, rsi
	call rsi				;Llamo a la función que testea un nodo
	mov rsi, r15
	cmp QWORD rax, 1		;Si da true, aplico el filtro, sino, solo muevo los punteros
	je .aplicarFiltro
	
	mov r14, [r13]
	lea r13, [r14+offset_siguiente]	;Muevo r13
	mov rdi, [rdi+offset_siguiente]
	jmp .evaluar
	

.aplicarFiltro:
	
	mov r14, rdi					;r14 = puntero al nodo actual
	mov r15, rsi					;r15 = puntero a la funcion
	
	mov rdi, r13					;rdi = puntero al puntero al nodo previo al apuntado por rdi
	mov rsi, [r14+offset_siguiente]	;rsi = puntero al siguiente nodo del apuntado por rdi (puede ser NULL)
	call nodo_concatenar
	 
	mov rdi, r14					;Recupero rdi
	call nodo_borrar_con_hijos		;borro toda la columna
	mov rdi, rsi					;rdi = puntero al proximo nodo.
	mov rsi, r15					;rsi = puntero a la funcion
	
	jmp .evaluar
	


.fin:
	
	pop rsi
	pop rdi
	pop r15
	pop r14
	pop r13
	
	ret
