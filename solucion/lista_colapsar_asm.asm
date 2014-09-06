
;------------------------------------------------------------------------
; ~ void lista_colapsar(lista_colgante_t* self, nodo_bool_method test_method, nodo_value_method join_method);

lista_colapsar:
	
	;rdi = puntero a lista
	;rsi = puntero a funcion de test
	;rdx = puntero a funcion de join
	push rdi
	push rsi
	push rdx
	push r11
	push r12
	push r13
	push r14
	push r15
	sub rsp, 8
	
	cmp QWORD [rdi], NULL  	;Me fijo que hayan nodos
	je .fin
	
	mov r13, rdi			;r13 = nodo_t**
	
.evaluar: 
	
	mov rdi, [r13]						;rdi = nodo_t*

	cmp QWORD rdi, NULL
	je .fin
	
	cmp QWORD [rdi+offset_hijo], NULL 	;Me fijo si el nodo base tiene hijos
	je .avanzar
	
	mov r15, rdi						;r15 = nodo_t*
	mov r14, rsi						;r14 = puntero a funcion test
	mov r12, rdx						;r12 = puntero a funcion join
	call rsi							;Veo si tengo que colapsar
	mov rdi, r15
	mov rsi, r14
	mov rdx, r12

	cmp QWORD rax, 1
	je .crearNodoYColapsar
	
.avanzar:
	mov r15, [r13]
	lea r13, [r15+offset_siguiente]		;Avanzo r13
	jmp .evaluar
	
.crearNodoYColapsar:
	
	mov r14, rsi							;r14 = funcion test
	mov r15, rdi							;r15 = nodo_t*
	mov r12, rdx							;r12 = funcion join
	
	cmp DWORD [r15+offset_tipo], ENUM_string
	je .crearNodoString
	jmp .crearNodo
	

.crearNodo:
							
	mov rdi, [r15+offset_tipo]
	mov rsi, [r15+offset_valor]
	call nodo_crear
	mov rdi, r15
	mov rsi, r14
	mov rdx, r12
	jmp .colapsar


.crearNodoString:

	mov rdi, [r15+offset_valor]
	call strlen
	inc rax
	mov rbx, rax
	mov rdi, rax
	call malloc
	mov rdi, rax
	mov rsi, [r15+offset_valor]
	mov rdx, rbx
	call strncpy
	mov rdi, [r15+offset_tipo]
	mov rsi, rax
	call nodo_crear
	mov rdi, r15
	mov rsi, r14
	mov rdx, r12

	
	jmp .colapsar



.colapsar:

	mov r15, rdi 						;Me guardo el puntero al nodo_t
	mov r14, rsi						;Me guardo el puntero a la funcion de test
	mov r12, rdx						;Me guardo el puntero a la funcion de join
	
	
	mov rdi, r13						;rdi = nodo_t**
	mov rsi, rdx						;rsi = funcion de join
	mov rdx, rax						;rdx = puntero al nuevo nodo
	call nodo_colapsar					;Colapso el nodo base
	
	mov rdi, r15						;Recupero todo
	mov rsi, r14
	mov rdx, r12
	
	mov r15, [r13]
	lea r13, [r15+offset_siguiente]		;Avanzo r13
	jmp .evaluar


.fin:

	add rsp, 8
	pop r15
	pop r14
	pop r13
	pop r12
	pop r11
	pop rdx
	pop rsi
	pop rdi

	ret




;------------------------------------------------------------------------
;   void nodo_colapsar(nodo_t** self_pointer, nodo_value_method join_method)


nodo_colapsar:

	push rdi
	push rsi
	push rdx
	push rbx
	push r12
	push r13
	push r14
	push r15
	sub rsp, 8
	
	;rdx = puntero al nuevo nodo donde voy a almacenar el resultado de colapsar todo
	mov rdi, [rdi]								;rdi = puntero a nodo base
	mov rbx, rdi								;Me guardo en rbx el puntero al inicio de la columna, para despues poder borrarla
												;con nodo_borrar_con_hijos
	
	mov r12, QWORD [rdi+offset_siguiente]		;Basicamente saco la columna anterior y pongo en su lugar el nuevo nodo
	mov QWORD [rdx+offset_siguiente], r12
	mov r12, r13
	mov QWORD [r12], rdx

	
	mov r14, [rdi+offset_hijo]					;r14 = puntero al primer hijo
	
.evaluar:
	
	cmp QWORD r14, NULL
	je .fin
	
	mov r12, rdx								;Me guardo el puntero al nodo base (al nuevo que cree)
	mov r13, rsi								;Me guardo el puntero a la funcion de join
	mov r15, rsi
	
	mov rdi, [r12+offset_valor]					;rdi = valorA
	mov rsi, [r14+offset_valor]					;rsi = valorB
	call r15									;Llamo a la funcion
	mov rdx, r12								;Recupero los punteros
	
	;Actualizo el nuevo nodo base
	cmp DWORD [rdx+offset_tipo], ENUM_string
	je .actualizarCasoString
	jmp .actualizarOtroCaso	
	
	
.actualizarOtroCaso	:
	
	mov QWORD [rdx+offset_valor], rax			;Guardo el resultado de la funcion

	jmp .continuar
	
.actualizarCasoString:
	
	mov r12, rax								;Guardo el puntero al nuevo string
	mov r15, rdx								;Guardo el puntero al nuevo nodo
	mov rdi, [rdx+offset_valor]
	call free									;Libero el viejo string
	mov rax, r12
	mov rdx, r15
	mov [rdx+offset_valor], rax					;Guardo el puntero al nuevo string

	jmp .continuar
	
	
	
.continuar:
	
	mov r14, [r14+offset_hijo]					;Apunto al proximo hijo
	mov rsi, r13								;Recupero el puntero a la funcion join
 	
 	jmp .evaluar
	
.fin:

	mov rdi, rbx
	call nodo_borrar_con_hijos					;Libero toda la columna vieja

	add rsp, 8
	pop r15
	pop r14
	pop r13
	pop r12
	pop r11
	pop rdx
	pop rsi
	pop rdi	

	ret
